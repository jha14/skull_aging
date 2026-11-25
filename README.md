# skull_aging

颅骨骨髓单细胞 BCR 衰老分析（年轻 vs 年老供体）。

## 在线报告

正式结果（去掉 O6 和 O11）：**https://jha14.github.io/skull_aging/**

同页还可打开 [最初 21 人交付版](https://jha14.github.io/skull_aging/archive/delivered/index.html) 和 [再去掉 O8 的版本](https://jha14.github.io/skull_aging/archive/exclude_O6_O8_O11/index.html)。

报告页顶部提供 **[bcr_delivery.zip](https://jha14.github.io/skull_aging/bcr_delivery.zip)** 完整结果下载（表格、图、源码与 `bcr_cells.rds`）。

## 本地复现

```bash
quarto render codes/bcr_skull_bm.qmd
python3 codes/package_bcr_delivery.py
```

需要项目内 `data/`、SHM 缓存及 R 依赖，详见 `codes/bcr_skull_bm.qmd`。

## GitHub Pages

`docs/` 的正式报告由 `codes/package_bcr_delivery.py` 生成。打包后再放入 `docs/archive/` 的两个历史版本。推送 `main` 分支后 Pages 从 `/docs` 发布。