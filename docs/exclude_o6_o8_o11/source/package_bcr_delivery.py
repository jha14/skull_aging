"""Validate the rendered report and rebuild the fixed delivery archive."""

from html.parser import HTMLParser
from pathlib import Path, PurePosixPath
from urllib.parse import unquote, urlsplit
from zipfile import ZIP_DEFLATED, ZipFile
import csv
import hashlib
import os
import re
import shutil
import sys


ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results" / "bcr"


class ReportAudit(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.plots = []
        self.output_problems = []
        self.folds = 0
        self.open_folds = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = set((attrs.get("class") or "").split())
        self.output_problems.extend(classes.intersection({
            "cell-output-warning", "cell-output-stderr", "cell-output-error"
        }))
        if tag == "a" and "href" in attrs:
            self.links.append(attrs["href"])
        if tag == "img" and "src" in attrs:
            self.plots.append(attrs["src"])
        if tag == "details" and "code-fold" in classes:
            self.folds += 1
            self.open_folds += "open" in attrs


DOWNLOAD_BANNER = """<div class="bcr-download-banner" style="background:#e8f4fc;border:1px solid #b8d4e8;padding:0.75rem 1rem;margin:0 0 1rem;font-size:0.95rem;line-height:1.45;">
<strong>完整结果包（离线）：</strong>
<a href="bcr_delivery.zip">下载 bcr_delivery.zip</a>
（含全部表格、PDF/PNG、源码与 <code>bcr_cells.rds</code>；解压后打开包内 HTML 亦可阅读。）
</div>
"""


def sync_pages_docs(archive: Path, report: str, docs: Path) -> Path:
    if docs.exists():
        shutil.rmtree(docs)
    docs.mkdir(parents=True)
    with ZipFile(archive) as zf:
        for name in zf.namelist():
            if name.endswith("/") or name == "bcr_skull_bm.html":
                continue
            zf.extract(name, docs)
    index_html = re.sub(r"(<body[^>]*>)", r"\1\n" + DOWNLOAD_BANNER, report, count=1)
    (docs / "index.html").write_text(index_html)
    shutil.copy2(archive, docs / "bcr_delivery.zip")
    return docs


def build(report_html, results, pages_dir, zip_path, source_qmd, link_replacements, exclusion_note):
    report = Path(report_html).read_text()
    audit = ReportAudit()
    audit.feed(report)
    if audit.output_problems:
        raise ValueError(f"Report has warning/error output: {audit.output_problems}")
    if not audit.folds or audit.open_folds:
        raise ValueError("Analysis code must be collapsed by default")
    plot_hashes = {hashlib.sha256(p.encode()).hexdigest() for p in audit.plots}
    if len(audit.plots) < 18 or len(audit.plots) != len(plot_hashes):
        raise ValueError(f"Expected distinct report figures, found {len(audit.plots)}")

    # Rewrite only the exported report; the project HTML keeps its project links.
    for old, new in link_replacements:
        report = report.replace(old, new)
    packaged = ReportAudit()
    packaged.feed(report)
    files = {}
    with (results / "tables" / "figure_table_map.csv").open(newline="") as handle:
        for row in csv.DictReader(handle):
            files[f"tables/{row['workbook']}"] = results / "tables" / row["workbook"]
            files[f"figures/{row['pdf']}"] = results / "figures" / row["pdf"]
            files[f"figures/{row['png']}"] = results / "figures" / row["png"]
    files["tables/figure_table_map.xlsx"] = results / "tables" / "figure_table_map.xlsx"
    files["tables/study_design.xlsx"] = results / "tables" / "study_design.xlsx"
    for name in ("age_tests.xlsx", "igg_plasma.xlsx", "figure_stat_annotations.csv"):
        files[f"tables/{name}"] = results / "tables" / name
    for name in (
        "bcr_cells.xlsx",
        "cell_flow.xlsx",
        "clone_composition_donuts.xlsx",
        "clone_metrics.xlsx",
        "clone_size_bins.xlsx",
        "diversity.xlsx",
        "figure_table_map.csv",
        "file_manifest.xlsx",
        "ighv_usage.xlsx",
        "isotype.xlsx",
        "recovery.xlsx",
        "shm.xlsx",
        "shm_cache_manifest.xlsx",
        "startrac.xlsx",
        "top_clones.xlsx",
        "umap_display_audit.csv",
        "validation_checks.csv",
    ):
        source = results / "tables" / name
        if source.exists():
            files[f"tables/{name}"] = source
    files["sessionInfo.txt"] = results / "rdata" / "sessionInfo.txt"
    files["rdata/bcr_cells.rds"] = results / "rdata" / "bcr_cells.rds"
    files["source/bcr_skull_bm.qmd"] = source_qmd
    for name in ("bcr_helpers.R", "bcr_theme.scss", "check_bcr_analysis.R",
                 "package_bcr_delivery.py", "sample_info.csv", "cluster_lineage.csv"):
        files[f"source/{name}"] = ROOT / "codes" / name
    files["CHANGELOG.md"] = ROOT / "CHANGELOG.md"

    local_links = []
    for href in packaged.links:
        parsed = urlsplit(href)
        if parsed.scheme or parsed.netloc or not parsed.path:
            continue
        path = PurePosixPath(unquote(parsed.path))
        if path.is_absolute() or ".." in path.parts or str(path) not in files:
            raise ValueError(f"Broken delivery link: {href}")
        local_links.append(str(path))
    workbook_links = [p for p in local_links if p.endswith(".xlsx")]
    expected_books = len(audit.plots) + 2  # figure index and study design
    if len(workbook_links) != expected_books:
        raise ValueError(
            f"Expected one workbook per figure plus the index and study design, "
            f"got {len(workbook_links)} links and {len(audit.plots)} figures"
        )
    legacy = {
        "figures/02b_umap_panels.pdf", "figures/02b_umap_panels.png",
        "figures/23_startrac.pdf", "figures/23_startrac.png",
        "tables/fig_02b_umap_panels.xlsx", "tables/fig_23_startrac.xlsx",
    }
    if legacy & set(files):
        raise ValueError(f"Legacy files entered the archive: {sorted(legacy & set(files))}")

    archive = Path(zip_path)
    pending = archive.with_suffix(".zip.tmp")
    readme = f"""打开 bcr_skull_bm.html 阅读报告，保留 tables/ 与 figures/ 目录，正文中的下载链接才能打开。
tables/fig_*.xlsx：逐图作图数据、statistics、dictionary 和 parameters。
tables/figure_table_map.xlsx / figure_table_map.csv：图与 PDF、PNG、逐图工作簿的对应关系。
tables/age_tests.xlsx：供体层面年龄组检验（Shapiro α=0.05，正态则 Welch t，否则 Wilcoxon；含同 family 参考 BH）。{exclusion_note}
tables/igg_plasma.xlsx：IgG 浆细胞的扩增、多样性，以及 IgG 占浆细胞的比例。
tables/figure_stat_annotations.csv：图中原始 P、参考 BH 与完整检验表对应关系。
tables/bcr_cells.xlsx、clone_metrics.xlsx、clone_size_bins.xlsx、top_clones.xlsx：细胞与克隆层汇总。
tables/diversity.xlsx、startrac.xlsx、recovery.xlsx、cell_flow.xlsx、isotype.xlsx、ighv_usage.xlsx、shm.xlsx：各模块完整结果表。
tables/clone_composition_donuts.xlsx、validation_checks.csv、umap_display_audit.csv：甜甜圈作图数据、本版本结果目录生成的验证表，以及 UMAP 审计。validation_checks.csv 不从其他版本复制。
tables/file_manifest.xlsx：本地 results/bcr/ 结果文件清单（含未入包路径，非 ZIP 专用清单）；figures/：全部现行 PDF 与 PNG；rdata/bcr_cells.rds：带 BCR 注释的细胞表（R 对象）。
sessionInfo.txt：运行环境；source/：QMD 与复现辅助脚本。不含完整 Seurat 对象与 SHM 原始缓存，复现仍需项目 data/。
年龄组比较为探索性结果，诊断组成差异限制了对衰老效应的解释。
"""
    try:
        with ZipFile(pending, "w", compression=ZIP_DEFLATED) as z:
            z.writestr("bcr_skull_bm.html", report)
            z.writestr("README.txt", readme)
            for name, source in sorted(files.items()):
                z.write(source, name)
        with ZipFile(pending) as z:
            if z.testzip() is not None:
                raise ValueError("Archive integrity check failed")
            if any(p not in z.namelist() for p in local_links):
                raise ValueError("Download target missing from archive")
        os.replace(pending, archive)
    finally:
        if pending.exists():
            pending.unlink()
    sync_pages_docs(archive, report, pages_dir)
    print(f"{len(audit.plots)} distinct figures; {audit.folds} collapsed code blocks; no warning/error output.")
    print(f"Verified {len(local_links)} local download links. Archive: {archive}")
    print(f"GitHub Pages content: {pages_dir}")


def package_two():
    build(
        ROOT / "codes" / "bcr_skull_bm.html",
        ROOT / "results" / "bcr",
        ROOT / "docs" / "exclude_o6_o11",
        ROOT / "results" / "bcr_delivery.zip",
        ROOT / "codes" / "bcr_skull_bm.qmd",
        (("../results/bcr/tables/", "tables/"), ("../results/bcr/figures/", "figures/")),
        "本版已剔除 O6 与 O11。",
    )


def package_three():
    build(
        ROOT / "archive" / "bcr_exclude_O6_O8_O11" / "bcr_skull_bm.html",
        ROOT / "archive" / "bcr_exclude_O6_O8_O11" / "render_out",
        ROOT / "docs" / "exclude_o6_o8_o11",
        ROOT / "archive" / "bcr_exclude_O6_O8_O11" / "bcr_delivery.zip",
        ROOT / "archive" / "bcr_exclude_O6_O8_O11" / "bcr_skull_bm.qmd",
        (("render_out/tables/", "tables/"), ("render_out/figures/", "figures/")),
        "本版已剔除 O6、O8 与 O11。",
    )


if __name__ == "__main__":
    if "--three" in sys.argv:
        package_three()
    else:
        package_two()
