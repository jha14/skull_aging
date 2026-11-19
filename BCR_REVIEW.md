# 当前 BCR 报告验收

审核日期：2026-11-14。本次最终验收针对Cursor补齐支持文件后的`results/bcr_delivery.zip`，核对README、当前HTML、29组PDF/PNG/逐图Excel及源码。此前分析、正文和panel验收结论继续有效；本轮不增加或重跑分析，没有改动报告和交付包，只更新本文件及审核证据。

**最终验收通过：三个支持文件已补齐，README用途说明已更新，交付包与当前报告、逐图PDF/PNG/Excel及源码一致。没有本轮遗留的交付阻断项，当前ZIP可以正式交给合作者。**

交付文件：[bcr_delivery.zip](/home/han/Desktop/fangni/skull_aging/results/bcr_delivery.zip)。使用时整包解压，打开根目录的`bcr_skull_bm.html`；保留`tables/`与`figures/`文件夹，表格和图形下载链接均依赖原目录结构。

图已具备论文组图源图的基本质量，但必须按下面的实际物理尺寸使用。小箱线图与单张UMAP可以直接排入组图；三联图、Marker、IGHV和甜甜圈不能统一缩成同样宽度的小panel。是否适合某篇论文，仍取决于最终组图、图注和文章所要支持的结论。

## 上轮问题逐项验收

| 上轮问题 | 本轮状态与证据 |
|---|---|
| 图05s、07s的HTML高度与PDF不一致 | 已解决。各有独立尺寸代码块；HTML均为1526×1238像素，与约134.4×109.0 mm的PDF一致。29张现行图的HTML、PNG、PDF长宽比差异均小于1%。 |
| Marker没有图例标题 | 已解决。实际PDF与HTML可见颜色图例“Average Expression”、点大小图例“Percent Expressed”。Seurat保留其默认guide标题，不能仅因代码中的labs名称不同判为未显示。 |
| UMAP图例点过小、灰色含义不清 | 已解决。离散图例色点放大；四张特征UMAP分别说明年龄、克隆、恒定区和SHM，灰色含义有区分。图框为方形，保留圆点。 |
| 所有点都被说成供者 | 已解决。开头说明组间比较以供者为单位，特征UMAP图注说明每点为细胞。 |
| 图19标题和尺寸不合适 | 已解决。实际标题为Clone-size distribution，当前PDF约49.4×57.2 mm，7–8 pt，适合作小panel。 |
| 图24正文说共享、图中仍说转换 | 图内标题已改为Clonal sharing；正文也解释STARTRAC tran不代表转换方向或速度。章节标题仍包含“转换”一词，属可选措辞润色，不影响当前图意。 |
| “未成熟B更少”容易被理解为绝对数量下降 | 已解决。主要发现与结论均表述为B系细胞中的比例较低。 |
| 结论在附录之后、下载索引标题在列表之后 | 已解决。主要结论先于补充结果，图表数据标题先于下载列表。 |
| 图03、04的Excel缺短编号，图18顺序不同 | 已解决。三份plot_data均有donor_label，身份与study_design一致，顺序均为Y1–Y10、O1–O11。 |
| 交付包混入旧UMAP/STARTRAC组合图 | 已解决。按现行figure_table_map白名单打包，仅保留29份现行PDF、29份PNG和29份逐图工作簿。三个支持文件也已补入，详见下一节。 |
| 图中警告、代码折叠、环境信息 | 现行HTML无warning/stderr/error输出；上一轮完整重渲染也通过。53个代码块默认折叠；sessionInfo打包内容与现行文件一致。 |
| 图18柱段、Gini作图表、补充字典等早先问题 | 保持修复。O8的大小1克隆为445/672=66.22%；Gini作图表79行；逐图Excel保留plot_data、statistics、dictionary和parameters。 |

## 补包问题最终验收

上一轮唯一待收尾的打包遗漏已解决。三个文件均在ZIP的`tables/`目录中，与项目内文件逐字节一致；现有打包脚本也已把它们加入白名单，不是仅手工补入这一次压缩包。

| 支持文件 | README用途说明 | 大小/字节 | SHA256前16位 | 验收 |
|---|---|---:|---|---|
| `age_tests.xlsx` | 完整176条年龄比较，含未逐项画出的结果和克隆等权IGHV | 23778 | `3bbf4f9dab140ef7` | 通过 |
| `public_antigen.xlsx` | CoV-AbDab与IEDB的参考条目、筛选及命中汇总 | 13999 | `ed32fd359414a0c2` | 通过 |
| `figure_stat_annotations.csv` | 图中原始P与完整统计的对应关系，含BH、供者数和检验标识 | 15120 | `e40cc927870c93ab` | 通过 |

README与当前打包脚本中的模板一致，上述三个文件均有正确用途说明；所列具体路径及工作簿通配符均能在包中对应。README也说明复现仍需原始数据、SHM缓存及R依赖，未把结果交付包误写成包含全部原始数据的运行环境。

正式交付包共有**103个文件**：29份PDF、29份PNG、33份Excel、1份统计标注CSV，以及HTML、README、环境信息、源码和变更记录。包内没有旧UMAP/STARTRAC组合图。完整清单、大小和SHA256见[delivery_file_manifest.csv](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/delivery_file_manifest.csv)。

## 代码、HTML、PDF、Excel是否一致

- 上一轮现有验证脚本**84项通过**。本轮分析QMD、辅助函数、HTML和验证脚本SHA256均与上一轮相同，只有打包脚本按要求更新，因此没有重复运行分析。
- 上一轮已在临时目录沿用已有输入和SHM缓存完整重渲染。细胞数据与当前结果一致，**176条年龄比较逐项一致**，29份逐图Excel的**116张工作表全部一致**。这验证当前报告可重现，不包含重新进行SHM原始比对或细胞注释。
- 上一轮独立核算的**73条供者层面Wilcoxon比较**全部对应。本轮另核对打包后的统计标注CSV，73条P、BH和供者数均与完整176条检验工作簿对应，没有在补包时改变统计。
- 现行HTML有**29张不同图、53个默认折叠代码块、0处warning/stderr/error输出**。**89个本地下载链接**均指向包内文件：29份PDF、29份PNG，以及29份逐图Excel、索引和study_design。
- ZIP校验通过。包内HTML与当前HTML仅有下载路径改写；29组PDF/PNG/逐图Excel与现行文件字节一致；源码、分组表与sessionInfo均为当前文件。
- 重跑既有图形与交付检查，**193项全部通过**，此前3项支持文件缺失均已修复。额外独立核对文件清单、逐文件字节、README、33个Excel结构和统计对应关系，**161项全部通过**。

## 给实验合作者的阅读与结论

**已经达到可以讨论结果的程度。** 开头先给三条观察，随后按细胞组成、克隆扩增、多样性、同种型、V基因、SHM、共享与抗原候选展开，最后回到主要发现。结论先于附录，合作者无需读代码即可找到答案。分母、供者单位、亚型内与全库克隆大小的区别，以及IgM浆细胞不画检验的原因，都已有解释。

正文仍有少量重复：样本年龄和Marker解释各出现两次；“重链选择”有较多技术细节；部分图还可加一句就近编号。这些属于后续润色，不再列为本轮交付阻断，也不需要因此再增加分析。

| 主要问题 | 当前结果与证据强度 |
|---|---|
| 未成熟B比例是否变化 | 年轻/年老供者中位数约11.9%/4.3%，BH约0.0249。可作为本队列较清楚的比例变化。 |
| 总体克隆扩增是否增强 | 中位数约4.66%/7.06%，P约0.171，BH约0.639。目前未检出明确组间差异。 |
| IGHV4-59是否更高 | 细胞加权比较BH约0.0383；克隆等权BH约0.0641，亚型内未见明确差异。结论限定在全库细胞加权观察。 |
| SHM是否更高 | 全体记忆B校正后未达阈值；IgG记忆B的两组各8位供者，BH约0.0469。可作为探索性分层信号。 |
| 抗原分析是否执行 | CoV-AbDab和IEDB均已执行，同一IGHV加相同重链CDR3氨基酸的精确匹配均为0。可报告没有精确候选，不能解释为没有抗原特异性。 |

当前文字没有把这些结果扩大为普遍的年龄机制。年轻组4/10、年老组11/11为动脉瘤相关手术供者，结论适合描述该队列的年龄分组观察和后续验证线索。这个限制已在报告说明；本轮不新增等深度或诊断分层分析。

## 每张图作为论文panel的使用条件

下表按独立PDF的真实页面尺寸与文字测量。字号为PDF中最小文字，不是网页缩放后的视觉估计。排版参考常见约89 mm单栏、183 mm双栏，以及最终小字约5–7 pt的可读范围；具体以目标期刊要求为准，可参照[Nature图形指南](https://research-figure-guide.nature.com/figures/building-and-exporting-figure-panels/)。

**可以从这些PDF开始组图，无需重做分析；不能把29张整图一律缩成同样的小panel。** 英文图内文字、统计标注和图例已基本统一。三联图整幅缩89 mm后最小字约4.1 pt；Marker和IGHV缩89 mm更小。四张特征UMAP单张按89 mm宽可读，但原样拼2×2约197 mm高，需要在最终组图中安排位置。最终加a/b/c面板字母、统一留白和完整图注属于投稿组图排版。

| 图 | PDF宽×高/mm | 最小字/pt | 当前使用判断 |
|---|---:|---:|---|
| [01](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/01_marker_dotplot.pdf) | 182.7×142.2 | 6.40 | 约160–183 mm宽；图例标题已显示。不要把整图缩到89 mm。 |
| [02](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/02_umap_subtype.pdf) | 116.8×116.8 | 7.50 | 约89–117 mm宽；89 mm时最小字约5.7 pt，方形坐标框正确。 |
| [02b](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/02b_umap_age.pdf) | 116.8×129.5 | 7.00 | 约89–117 mm宽；89 mm时最小字约5.3 pt。 |
| [02c](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/02b_umap_clone.pdf) | 116.8×129.5 | 7.00 | 约89–117 mm宽；无可用重链用灰色，图例色点已放大。 |
| [02d](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/02b_umap_isotype.pdf) | 116.8×129.5 | 7.00 | 约89–117 mm宽；灰色恒定区未知已在图注解释。 |
| [02e](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/02b_umap_shm.pdf) | 116.8×129.5 | 7.00 | 约89–117 mm宽；灰色SHM缺失已在图注解释。 |
| [03](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/03_b_lineage_recovery.pdf) | 182.7×91.4 | 6.40 | 约160–183 mm宽；供者编号与Excel一致。 |
| [04](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/04_subtype_composition.pdf) | 182.7×116.8 | 6.40 | 约160–183 mm宽；供者顺序与图03、18一致。 |
| [05](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/05_subtype_fraction_by_age.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽；整图缩89 mm时最小字仅4.1 pt。 |
| [05s](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/05s_subtype_fraction_other.pdf) | 134.4×109.0 | 6.12 | 约120–134 mm宽；HTML和PDF的两行分面高度现已一致。 |
| [06](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/06_expanded_fraction_all.pdf) | 46.9×54.3 | 6.12 | 约45–47 mm宽，可直接作为小比较panel。 |
| [07](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/07_expanded_fraction_by_subtype.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽；更窄时需分别排现有分面。 |
| [07s](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/07s_expanded_other_subtypes.pdf) | 134.4×109.0 | 6.12 | 约120–134 mm宽；HTML和PDF比例现已一致。 |
| [08](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/08_isotype_by_subtype.pdf) | 182.7×96.3 | 6.40 | 约160–183 mm宽；属于亚型构成展示。 |
| [09](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/09_switched_by_main_subtype.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽。 |
| [10](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/10_ighv_usage.pdf) | 182.7×131.9 | 5.97 | 约160–183 mm宽；最小字约6 pt，最大字现为9 pt；缩89 mm仍不可读。 |
| [11](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/11_shm_main_subtypes.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽。 |
| [12](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/12_shm_memory_by_isotype.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽；IgG分层信号作为探索性结果。 |
| [13](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/13_top10_fraction.pdf) | 46.9×54.3 | 6.12 | 约45–47 mm宽，可作为小panel；结果定位为描述性。 |
| [14](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/14_shannon_main_subtypes.pdf) | 131.9×55.7 | 6.12 | 约120–132 mm宽；保留为描述性补充结果。 |
| [16](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/16_expansion_within_isotype.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽。 |
| [17](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/17_shm_plasma_by_isotype.pdf) | 131.9×55.7 | 6.12 | 三联图保留约120–132 mm宽；IgM不画检验的原因已说明。 |
| [18](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/18_clone_size_by_donor.pdf) | 182.7×96.3 | 6.40 | 约160–183 mm宽；O8柱段、Y/O编号和顺序均已核对。 |
| [19](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/19_clone_homeostasis.pdf) | 49.4×57.1 | 7.00 | 约45–50 mm宽，可直接作为小panel；标题、比例及尺寸已修复。 |
| [20](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/20_clone_size_donuts.pdf) | 139.7×134.4 | 7.00 | 约100–140 mm宽；当前不是旧版大字号，缩89 mm最小字约4.5 pt。 |
| [21](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/21_expanded_subtype_donuts.pdf) | 131.9×81.1 | 7.00 | 约100–132 mm宽；缩89 mm最小字约4.7 pt。 |
| [22](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/22_gini_simpson.pdf) | 106.5×101.6 | 6.12 | 约89–107 mm宽；89 mm时最小字约5.1 pt。 |
| [23](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/23_startrac_expansion.pdf) | 134.4×109.0 | 6.12 | 约120–134 mm宽，适合作较大panel或补充图。 |
| [24](/home/han/Desktop/fangni/skull_aging/results/bcr/figures/23_startrac_transition.pdf) | 134.4×109.0 | 6.12 | 约120–134 mm宽；英文标题已统一为Clonal sharing。 |

全部测量、HTML像素及缩至89 mm后的字号见[pdf_panel_audit.csv](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/pdf_panel_audit.csv)。现行29图概览见[figure_overview.png](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/figure_overview.png)。

## 本轮最终交付证据

- [最终交付检查：161/161](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/final_delivery_checks.csv)
- [最终验收摘要及交付包SHA256](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/final_acceptance_summary.json)
- [103个包内文件的SHA256清单](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/delivery_file_manifest.csv)
- [当前包内README原文](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/delivery_README.txt)

当前包SHA256：`8eec5210cda69e243b27bc7713676c99667abcd54797ff7865bfd2f64d1b9ac3`。

## 延续有效的分析验收证据

- [84项现有验证](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/existing_validation_checks.csv)
- [完整重渲染日志](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/rerender.log)及[重算一致性](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/reproduction_checks.log)
- [116张Excel工作表重算对照](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/workbook_reproduction.csv)
- [73条独立P与供者数核查](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/independent_stat_checks.csv)
- [本轮重跑193项图形与交付检查：全部通过](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/artifact_checks.csv)
- [供者编号、参考库及主结果核对](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/numeric_checks.log)
- [本轮源文件SHA256](/home/han/Desktop/fangni/skull_aging/results/bcr_review/current/source_fingerprints.json)

同上一轮相比，分析QMD、辅助函数、HTML和验证脚本保持相同SHA256；打包脚本仅按本轮任务更新。其前后指纹在最终摘要中保留。审核过程只更新本审查文件和审核证据，没有修改分析、报告或交付包。
