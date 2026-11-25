# BCR 分析迭代记录

日期：2026-11-14

## 固定入口

后续只维护一套现行代码和派生结果，不再增加版本号：

- 分析：`codes/bcr_skull_bm.qmd`
- 函数：`codes/bcr_helpers.R`
- 报告：`codes/bcr_skull_bm.html`
- 结果：`results/bcr/`
- 验证：`codes/check_bcr_analysis.R`

首次审查前的代码和结果只归档一次到 `results/bcr_review/baseline/`，用于复现初次发现的问题。SHM 缓存一直保留在 `results/bcr/shm/`。历史审查报告已有明确提示，不代表现行分析。`codes/audit_bcr_analysis.R` 读取历史基线；现行流程的验证使用 `codes/check_bcr_analysis.R`。

## 图 19 尺寸

两组克隆大小分布图收到约 50×57 mm，与两分组比较小图接近。

## 收尾

补充图 05s、07s 改为与 PDF 相同的 5.3×4.3 英寸代码块。Marker 图例标题改为 Scaled expression 和 Cells expressing (%)。图 19 标题改为 Clone-size distribution，图 24 改为 Clonal sharing。未成熟 B 的表述改为比例较低。结论移到附录和下载索引之前。作图表补上供者短编号，顺序与图上的 Y1–Y10、O1–O11 一致。交付包按 figure_table_map 收录现行 PDF、PNG 和工作簿，不再带入旧的组合图。

## 审核后的修订

图 18 不再用会删掉堆叠柱段的 y 轴硬上限，WLR220308_Z 的大小为 1 的柱段保留。警告改回显示，并去掉重复的 y 轴 scale。抗原正文和结尾统一为：8633 条合格重链分别与 CoV-AbDab、IEDB 比较 V 基因加 CDR3，两库都没有命中。Marker 标签不再重叠。UMAP 拆成四个面板，STARTRAC 拆成扩增和亚型间共享两张图，亚型比例和亚型内扩增各拆成主图与补充图。回收率图例改为 Eligible/Excluded，柱状图横轴使用供者短编号。图 18–24 的作图表补了字段说明。本次 `check_bcr_analysis.R` 通过 82 项。等深度抽样仍未做，Shannon 不能单独解释为年龄差异。

## 柱状图、UMAP 和 IEDB

柱状图和甜甜圈按双栏 panel 放大，箱线图保持较小的比较面板。UMAP 点的透明度改为 0.35。抗原比对加入 IEDB 2026-11-11 的人源 BCR 导出，与 CoV-AbDab 使用同一套 V 基因加 CDR3 规则。

## 图面尺寸

比较图改为可直接放入双栏图的 panel：单张 Young–Old 箱线图约 47 × 55 mm，三个分面一行、九个分面一块，比例一致。不再导出 SVG。供体敏感性分析已从报告和 `age_tests.xlsx` 中移除。抗原部分写明目前只比对了 CoV-AbDab。

## 克隆展示

按模板补上这套数据自己的克隆大小分层：每位供者的大小构成、年轻/年老平均柱状图、亚型甜甜圈，以及扩增细胞来自哪些亚型。多样性使用 Gini–Simpson。STARTRAC 只计算扩增指数和亚型间转换指数；没有配对外周血，不做组织迁移。固定深度抽样已从报告和检验表中移除。

抗原比较此前已经在完整 CoV-AbDab 上跑完，结果是没有序列命中。供体敏感性和结果导出改为附录，不再作为正文第 9–11 节。

## 报告文字和比较图

正文改为按比较说明观察和生物学含义。方法只保留必要步骤，诊断组成、年龄缺口、克隆定义、突变缓存和抗原库范围集中在文末说明。

比较图改为填色箱线图。图内标题、坐标、分面和图例使用英文；中文留在正文。每项 Young–Old 比较只标注一个原始 P，格式与 `format.pval(digits = 3)` 一致，数值来自现有供体层面双侧 Wilcoxon（`exact = FALSE`）。BH、供体数和效应量仍在 Excel。供体不足或没有变异的比较不在图上给出 P。图同时导出 PDF、SVG 和 400 dpi PNG。UMAP 多面板背景改为白色。

代码默认折叠、sessionInfo、逐图 Excel 和图表索引保持不变。渲染日志没有 warning。验证仍为 97 项。

## UMAP、统计展示和 warnings 复查

- UMAP 的旧箭头沿整条轴线绘制，并叠加图框。现移除长箭头，所有 UMAP 使用相同的正方形坐标范围及等比例单位，保留圆点；亚型标签由 3 放大到 4.8，并加浅色底以便阅读。
- 细胞比例等比较图曾同时标出原始 p、BH、供体数和星号。随后改为图上只保留一个原始 P；BH 和供体数留在 Excel。`figure_stat_annotations.csv` 仍与 `age_tests.xlsx` 核对。
- 原 HTML 的 202 处警告输出来自基础 PDF 设备的中文转换。除切换导出设备外，也改用 cowplot 的 ragg 内部设备，按具体位置提取图例，并统一抽样分面的深度类型。保留 `warning: true`，最终 HTML 中 warning/stderr/error 输出为 0。
- 修复图例缺失，移除重复打印的图，18 张图各显示一次；各代码块按实际图形尺寸渲染，代码默认折叠。
- 各图 Excel 的 statistics 与对应分面一致，plot_data 按实际绘图范围导出。新增 `umap_display_audit.csv` 记录真实绘图对象的坐标范围；新增固定打包脚本 `codes/package_bcr_delivery.py`，检查图数、折叠、警告及 19 个下载链接后覆盖同一交付压缩包。
- 本轮前后逐列对照：168 条年龄组检验记录，以及 12,084 个细胞的 UMAP 坐标和标签均未改变。新增的核查只检查展示及导出一致性，现共通过 97 项。

## Cursor 首轮已经修好的部分

从同一条原始 productive IGH contig 读取 V/J/C 和 CDR3，修复 D 基因误判 IgD 及 V 名称截断；未知同种型保持缺失。同种型内计数已有独立字段。SHM 按所选 contig 对应，删除了失败后替换成 `1-v_identity` 的逻辑。回收率排除 Non-B，并补充深度、克隆定义和诊断敏感性分析。原始数据、样本分组和 marker 工作标签未改变。

## 本轮复查发现并修复的问题

| 问题 | 影响及修正 |
|---|---|
| 抽样检验使用 `depth == depth` | 该筛选恒为真，合并三个深度，把 Young 9 / Old 11 名供体计成 27 / 33 个重复。改用明确的环境变量筛选深度；检验函数强制每位供体一行。 |
| 在排除 Non-B 前计克隆大小 | 旧表中 40 个 B 系细胞的全库克隆大小、35 个已知同种型细胞的同种型内大小被放大，分别影响 6 和 5 个扩增标记。现在先确定 B 系范围，再计算克隆大小。供体汇总函数原本独立重算的部分不因此一律判为错误。 |
| 把含 `/OR` 的 V 名称当作多基因歧义 | 这是 IMGT orphon 名称的一部分。4 个细胞保留完整名称，并增加 `v_orphon` 质控标记，不再因斜杠而丢失克隆键。其生物学注释仍需谨慎。此前两个供体 × 同种型层因混有 NA 克隆键而整层扩增比例为 NA，现已恢复可计算。 |
| 配对链定义名为氨基酸，重链实际用了核苷酸 | 现按重链 V/J/CDR3aa + 轻链 V/J/CDR3aa 定义配对氨基酸键；重链 V/J/CDR3nt 保持为另一种敏感性定义。 |
| 公共序列只按 V/CDR3 设置近似标记 | 改为使用供体 + V + CDR3 端点；也不再合并实际不同的跨供体序列端点。当前距离 1 的配对仍为 3 对。 |
| 参考 CDR3 混合使用 full/core 查询 | CoV-AbDab 仅与规范化的去锚 CDR3 匹配；不改变参考序列本身的首 C/尾 W。无法确认查询边界时不匹配。 |
| 截断参考库被当成正常的 0 命中 | 本地文件尾部 CSV 引号未闭合，现检测为不可计算；命中数与比例为 NA。原“0 命中”的解释不再用于当前报告。 |
| 渲染删除整个输出目录 | 移除了递归删除输出目录的代码，防止固定输出目录下的 SHM 缓存被一起删除。 |
| 主流程依赖旧 RDS 和固定的 302 计数断言 | 移到独立原始数据核查思路，不再让现行分析依赖上一轮结果或硬编码的细胞数。 |
| 最终 Seurat 元数据不完整 | 统一写回同种型、克隆键/大小、SHM、公共标记、多链和配对质量字段，并逐细胞核对。 |

IMGT 名称依据：[human IG orphons](https://www.imgt.org/IMGTrepertoire/LocusGenes/listIG_TR/human/IG/orphons/Hu_ORIG.html)。

修复前的错误抽样统计保存在 `results/bcr_review/cursor_rarefaction_before.csv`；对 Cursor 提交代码的修正差异保存在 `results/bcr_review/cursor_corrections.patch`。这些是审查证据，不是另一套分析入口。

## 交付整改

同一扩增假设不再进两次 BH 校正。初始 B、记忆 B 和浆细胞的扩增比例只保留主定义那一条；全 B 系扩增比例的 p 仍是 0.171，校正后 BH 为 0.639。参考库 V 基因先判断是不是单基因和人源受体，再去掉等位基因；`IGHV1-2*01,IGHV1-3*01` 不再被收成 `IGHV1-2`，小鼠 `IGHV1-2` 不参与人源匹配。

报告改为面向合作者的结果说明，分析代码默认折叠。UMAP 使用方形图框、圆点和放大的亚型标签，并补了年龄、克隆大小、同种型和突变面板。另补了 Top 10 占比、Shannon、固定深度抽样、同种型内扩增和浆细胞分同种型突变图。每张图有 `results/bcr/tables/fig_*.xlsx`，索引是 `figure_table_map.xlsx`。交付包 `results/bcr_delivery.zip` 解压后 19 个表格链接都能打开。HTML 附录含完整 sessionInfo。

完整 CoV-AbDab 2024-02-08 快照（12,918 条可解析记录，SHA256 `fdc7e649e8b2e72902ddd7080e8c81e8a8af1ae6afda37913dc578b229763b96`）已用于候选比较。8,633 条合格重链查询没有人源单基因 V 加去锚 CDR3 的精确对应，这是完整库上的未命中，不是损坏文件造成的未计算。损坏的旧文件留在 `data/reference/provenance/`。IEDB 全受体压缩包没有纳入：公开入口不提供文件大小，本轮没有把它整理成核对过的人源 BCR 表。

IGHV4-59 的亚型内结果只写成“尚未支持明确的亚型内差异”，不再解释成已经证明全库差异来自亚型组成。

## 本轮补充

细胞流转表补上了 SHM 结果：所选 contig 上有效 IMGT V 区突变 8,739 个，MakeDb 中缺失 20 个，比对失败 4 个，CDR3 不一致 0 个。4 个 `/OR` orphon 名称单独计数，不再和“歧义 V 基因”混在一起。

对细胞加权 p < 0.05 的 V 基因，增加了 Naive、Memory、Plasma 内部的使用率检验，用来看全库差异是不是亚型组成带来的。本轮只有 IGHV4-59 进入这一检查。全库细胞加权是年轻 3.28%、年老 5.39%，BH 0.038；克隆等权是 3.30% / 5.76%，BH 0.064。分到三个亚型之后，Naive 为 2.86% / 4.81%（p = 0.080），Memory 为 4.55% / 3.70%（p = 0.970），Plasma 为 4.00% / 5.79%（p = 0.219）。因此不能把 IGHV4-59 的全库差异写成某一个亚型内部的使用率变化。年老组里带这条 V 基因的细胞更多落在浆细胞（28% 对 12%），亚型组成可以解释一部分全库信号。

## 当前计数与结论

- B 系 productive IGH 细胞 8,763 个，其中已知同种型 8,707 个、未知 56 个，真正 IgD 302 个。
- 合格轻链配对 7,035 个；不同 productive IGH 重排超过一条的细胞 86 个；`/OR` 名称细胞 4 个。
- 有效 SHM 8,739 个、缺失 24 个。相较首次分析，按明确的所选 contig 规则恢复了部分原来因多重链被整体剔除的 SHM，因此部分供体汇总和 p 值发生变化，不是换了突变指标。
- 修正后，全 B 系原始扩增比例 p = 0.1715，BH = 0.6386。统一深度 30/50/100 的 p 分别为 0.2379、0.0626、0.0946，对应 BH 均未达到 0.05。此前因重复计数得到的 BH 约 0.0186 不成立。
- Immature B 比例仍为 Young 11.87% / Old 4.29%，BH = 0.0249；Immature + Transitional 合并比例为 21.74% / 9.14%，作为补充敏感性结果报告。
- Memory B 总体 SHM 中位数为 4.51% / 5.21%，p = 0.0216，所属检验家族 BH = 0.0648；动脉瘤限制分析 p = 0.0767。IgG memory 分层为 6.39% / 7.49%，8 对 8 名供体，分层家族 BH = 0.0469，仍属探索性分层结果。
- 精确公共重链键为 0，距离恰为 1 的跨供体配对为 3。完整 CoV-AbDab 快照上的人源单基因 V + 去锚 CDR3 精确匹配已执行，8,633 条合格查询未命中；IEDB 扩展尚未执行。
- IGHV4-59 的全库细胞加权差异在 Naive、Memory、Plasma 内部分别检验后都没有 p < 0.05，不作为亚型内部的 V 基因结论。

## 验证与复现

```bash
Rscript codes/check_bcr_analysis.R --unit-only
quarto render codes/bcr_skull_bm.qmd
Rscript codes/check_bcr_analysis.R
python3 codes/package_bcr_delivery.py
```

`Rscript codes/check_bcr_analysis.R` 通过 97 项检查，其中包括多基因 V 注释、人源/小鼠标签和截断参考库。结果见 `results/bcr/tables/validation_checks.csv`。没有重跑或删除 IgBLAST/MakeDb 缓存，也没有修改原始测序数据和临床分组。本轮使用本机 Noto Sans CJK SC 字体及 Cairo/ragg 设备，HTML 中 warning、stderr 和 error 输出均为 0。

## 保留的限制

Young 动脉瘤 4/10、Old 11/11，两组各 2 名男性，32–59 岁之间无样本；组间差异不能直接归因于衰老。Immature/Transitional 是工作标签，完整对象里未入 B 子集的 IGH 条码也没有自动补回。旧 SHM 缓存缺乏生成时的完整参考记录，事后校验不能补足历史来源。正式克隆家族、谱系树和抗原结合实验尚未开展。IEDB 人源 BCR 子集还没有整理进匹配。CoV-AbDab 只覆盖冠状病毒抗体，未命中不能说明这些细胞没有其他抗原特异性。
