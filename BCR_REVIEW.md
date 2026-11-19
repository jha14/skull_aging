# 当前 BCR 报告验收

审核日期：2026-11-19。复核 Cursor 根据上一轮评审修改后的现行报告。

**本轮验收通过，可以作为探索性结果报告正式交给合作者。** 最新 HTML、工作区 Pages 文件和 ZIP 已对齐。报告把记忆 B 与浆细胞放在同一组问题下讨论，区分了观察方向、统计证据和回收深度的影响。下列小修不阻断当前交付。

交付文件：[bcr_delivery.zip](/home/han/Desktop/fangni/skull_aging/results/bcr_delivery.zip)。整包解压后打开根目录的 `bcr_skull_bm.html`，保留附件目录结构。Pages 验收针对工作区的 [docs/index.html](/home/han/Desktop/fangni/skull_aging/docs/index.html)。线上部署状态未核验。

## 上轮问题复核

| 项目 | 复核结果 |
|---|---|
| 图 05 原始 p 与参考 BH | 通过。图注从统计对象读取结果，过渡 B 的原始 p 为 0.0154，按现有丰度家族的参考 BH 为 0.0691，与图、结论表和导出表一致。 |
| 统计方法说明 | 通过。正文区分 Shapiro 未拒绝正态与证明正态，区分 Welch 比较均值与中位数描述，也分别标记原始 p 和参考 BH。本轮保留既有的探索性检验规则。 |
| 扩增和多样性方向 | 通过。记忆 B 与浆细胞的占比、扩增、SHM 和多样性并列报告，原先的「方向对解读有利」分层已去掉。「年老组扩增比例中位数较高」保留为描述，浆细胞多样性注明回收细胞数的差异。 |
| 报告与交付包同步 | 通过。ZIP 121 个文件，CRC 正常。ZIP 内 HTML 与最新 HTML 只差本地附件路径，工作区 Pages 又增加 ZIP 下载提示。全部嵌入图、源码、附表和 README 对应当前文件。ZIP 的 89 个和 Pages 的 90 个本地链接均有效。 |

## 本轮验证与可交付结论

- 隔离目录完整重渲染成功。182 条检验记录、BCR 细胞表和逐图 Excel 的 116 张工作表与当前输出一致。上一轮到此轮的 182 条原始检验结果与 BCR 细胞表也一致，统计总表新增的是参考 BH。
- 84 项验证全部通过。独立从逐图供者数据核对 73 条比较记录，供者数、Shapiro P、检验方法和原始 P 一致。总表的 164 个非空 BH 值逐项重算一致，73 条图形统计索引中的原始 P 和参考 BH 也与总表一致。
- 记忆 B 整体 V 区突变是此轮适合优先报告的观察。供者中位数 4.51% → 5.21%，原始 P = 0.0085，参考 BH = 0.0255。IgG 分层方向相同，原始 P = 0.0289，参考 BH = 0.0866，适合描述为验证线索。
- 可报告记忆 B 和浆细胞的亚型内扩增比例中位数偏高。记忆 B 为 0% → 3.45%，P = 0.130，浆细胞为 6.45% → 12.52%，P = 0.202。两组资料目前不足以确认扩增增强。浆细胞回收数中位数 31 → 91，支持正文将多样性和回收深度一起解读。年龄组取材诊断构成的限制已放在导语。
- 当前 HTML 有 29 张不同嵌入图，53 个默认折叠代码块，无 warning、stderr 或 error。本轮只更新验收记录。

## 可顺手收尾的小修

1. 图 05 末句「Plasma 比例见下表与图 05s（Memory B）」容易让读者误以为图 05s 有 Plasma。建议写「浆细胞比例见本图，记忆 B 比例见图 05s」，并把「同 family 参考 p」直接写成「同类检验参考 BH」。[图 05 动态图注](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:403) · [图注生成函数](/home/han/Desktop/fangni/skull_aging/codes/bcr_helpers.R:409)
2. 结论表的「待验证线索」套用给了所有原始 P ≥ 0.05 的结果，包括记忆 B Shannon（P = 0.903）等正文已说明未见明确差异的指标。建议去掉「读法」列，或统一写为「未见明确组间差异」，需要跟进的观察由正文说明。[结论表](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:1375)
3. README 把 `file_manifest.xlsx` 叫作 ZIP 文件清单，但它实际上列出本地结果目录，含未入包的旧图和完整 Seurat 对象路径。可把 README 改为「本地结果文件清单」，或重新生成 ZIP 相对路径清单。ZIP 中实际附件和下载链接已经核对通过。[打包 README](/home/han/Desktop/fangni/skull_aging/codes/package_bcr_delivery.py:145)

本次通过验收的 ZIP SHA256 为 `b85a6ddeaeb4553404ad0a42f1c0b6c31f4dda083eb9551ee1c8aa87b667d66e`。

<details>
<summary>2026-11-19 修改前评审，以下问题的关闭状态以本页顶部为准</summary>

审核日期：2026-11-19。对象为本地最新 `codes/bcr_skull_bm.html`、对应 QMD 和结果，以及待发送的 ZIP 与 `docs/index.html`。本轮只审核，没有修改分析或交付文件。

**结论：最新 HTML 可以作内部讨论稿，建议先修正图文和统计表述，再重新打包正式交付。** 供者作为统计单位、重链选取、克隆计算、SHM 和主要图表的计算可以复现。报告新增细胞名称解释和逐图读法，整体比前一版更容易读。主要问题是把选择性列出的方向写成跨指标一致的趋势，以及本地最新结论没有进入交付包。

## 交付前处理

1. **图 05 图注与实际统计矛盾。** 图注说 Transitional B 的 P 没到 0.05。当前导出结果是年轻组中位数 9.79%、年老组 5.04%，原始 Welch P = 0.0154。按现有丰度家族作参考 BH 是 0.0691。图和表展示原始 P 时，图注也须清楚区分原始 P 与校正 P。建议静态图注读检验表，避免切换方法后继续引用旧描述。位置：[图 05 图注](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:401)。
2. **改正统计说明与总结层级。** 该轮把固定 Wilcoxon 改成逐项用 Shapiro–Wilk 选择 Welch 或 Wilcoxon，并撤掉原来的家族内 BH 列。方法按代码正常执行，但两组样本少时 Shapiro 不显著只代表未检出偏离正态。Welch 检验的是供者均值，报告口中的两组中位数是描述量。182 条比较记录中 164 条有 P，19 条原始 P < 0.05。可在图上仍只显示原始 P，导出表保留按事先划定的检验家族校正值，正文把原始 P < 0.05 称为「探索性信号」，不要表述成「不像偶然差别」或确认年龄效应。建议按终点预先指定一种主检验，另一个作为敏感性分析。若保留当前自动规则作为探索性呈现，应准确说明选法和局限。参见[统计函数](/home/han/Desktop/fangni/skull_aging/codes/bcr_helpers.R:348)、[现有图前说明](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:322)和[正态性预检的模拟研究](https://link.springer.com/article/10.1186/1471-2288-12-81)。
3. **保留记忆 B 和浆细胞重点，去掉「方向有利」的筛选。** 摘要和表格按有利方向列趋势，会遮蔽 Plasma SHM、两个亚型的类别转换、Memory B 两个多样性指数等未给出明确差异的比较。将摘要预先固定为两个亚型各自的组成、扩增、SHM 和多样性，按研究问题并列报告。`tier` 目前硬编码「统计显著」，不随 P 变化，建议移除这一列或者从结果计算标注。位置：[导语](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:30)、[主要结论](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:1319)、[硬编码层级](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:1358)。
4. **修改后重新同步交付文件。** ZIP 和 `docs/index.html` 目前仍是较早的结论摘要，包内 QMD 也落后于 `codes/`。当前本地 HTML 与 `docs/index.html` 的 29 个嵌入图完全一致，46 份分析 Excel 的工作表内容一致，实际过期的是新导语、12 行结论表及对应 QMD。不要据导出字节时间差判断统计结果不一致。包内仍有 `public_antigen.xlsx`，README 漏了它的用途说明，可在重打包时一起补上。等正文定稿后，重新渲染和打包，核对项目 HTML、页版、ZIP 的表格和 QMD。位置：[打包入口](/home/han/Desktop/fangni/skull_aging/codes/package_bcr_delivery.py:64)。

## 记忆 B 和浆细胞的证据

数值都是年轻组 → 年老组的供者中位数，下面是**当前结果**而非新的假设检验。参考 BH 是审核对原始 P 按现有 `family` 做的重算，用于判断未经校正的措辞是否过强。它不能解决年龄与诊断构成混杂，也不能替代事先定好的统计策略。

| 问题 | Memory B | Plasma |
|---|---|---|
| 占全部 B 系细胞的比例 | 12.44% → 21.64%，原始 P = 0.256 | 5.55% → 19.96%，原始 P = 0.113。比例变化不能直接解释为绝对细胞数量变化。 |
| 亚型内扩增细胞比例 | 0.00% → 3.45%，原始 P = 0.130，9/11 名供者 | 6.45% → 12.52%，原始 P = 0.202，9/10 名供者。两项都可描述年老组中位数较高，证据不足以确认扩增增强。 |
| IGHV 区体细胞高频突变 | 4.51% → 5.21%，原始 P = 0.00850，参考 BH = 0.0255。IgG 分层 6.39% → 7.49%，原始 P = 0.0289，参考 BH = 0.0866，各 8 名供者。IgG 是后续验证线索。 | 9.38% → 9.67%，原始 P = 0.396。整体与 IgG/IgA 分层均未显示明确组间差异。 |
| 克隆多样性与集中程度 | Gini–Simpson P = 0.879，Shannon P = 0.903。缺乏一致变化的证据。 | Gini–Simpson 0.954 → 0.983，P = 0.079。Top 10 占比 45.45% → 19.41%，P = 0.094。Shannon P = 0.112。这些指标来自同一丰度分布，不能当成独立复验。 |

对 Plasma 多样性，进入比较的供者中，回收到可定义克隆的浆细胞数中位数为年轻组 **31**、年老组 **91**。在两组各自的供者之中，细胞数与 Shannon 正相关很强、与 Top 10 占比负相关很强。供者间回收数本身可能反映采样量和真实组成的共同差异。在统一深度比较前，建议把 Shannon 和 Top 10 放在附录，或与回收数并列写成描述结果。正文也别引用图 13 来支撑 Plasma Top 10，图 13 展示的是**全 B 系**。参见[克隆统计表](/home/han/Desktop/fangni/skull_aging/results/bcr/tables/clone_metrics.xlsx)、[年龄统计表](/home/han/Desktop/fangni/skull_aging/results/bcr/tables/age_tests.xlsx)、[图 13 的取数](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:1492)。

## 给实验同事的呈现

建议把导语缩成一张小结或三条结果，直接连到图 07、11、12 和 22。先用一句话说「记忆 B 细胞帮助再次应答，浆细胞负责分泌抗体」。正文先说记忆 B 的观察，再说浆细胞的观察。SHM 可解释为「相对未重排的种系 V 区参考，测到的碱基差异比例」，看图时表述为「每位供者先取一个突变率中位数」。说明 SHM 描述序列变化，抗体亲和力和分泌量属于另外的测量。流程、IGHV 基因使用、STARTRAC 与数据库比对可放附录。保留「老年组全为动脉瘤相关手术供者，年轻组为 4/10」靠近摘要。

可直接作为摘要底稿：

> 这批颅骨骨髓样本里，年老组记忆 B 细胞的重链 V 区突变比例较高。IgG 记忆 B 细胞也有同方向的观察，仍需验证。记忆 B 和浆细胞中，年老组的扩增细胞比例中位数较高，两组供者数值重叠，现有结果还不足以确认扩增增强。浆细胞整体突变比例未见明确差异。年老组回收到的浆细胞较多，克隆多样性的组间比较因此要结合回收深度。两组手术诊断构成不同，以上是本队列的年龄组观察。

另有两处易误解的小修：图 01 点的大小表示**表达该基因的细胞比例**，颜色是标准化表达量。图 22 用的是 `1 - sum(p^2)`，有限样本每细胞各一克隆时为 `1 - 1/N`，可简单说「越接近 1，克隆越分散」。抗原节的「完全相同的重链」建议统一为「同一 IGHV 和完全相同的 CDR3 氨基酸」，因为当前并非全重链匹配。参见[图 01](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:165)、[图 22](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:743)和[抗原段落](/home/han/Desktop/fangni/skull_aging/codes/bcr_skull_bm.qmd:1301)。

## 已验证

- 最新 QMD 在临时目录用现有输入和 SHM 缓存渲染成功。与现行输出相比，BCR 细胞表、182 条比较记录以及 29 份逐图 Excel 的 116 张工作表全部可复现。
- 独立用逐图供者数据复核 73 条统计记录，供者数、Shapiro P、选择的方法与组间原始 P 均一致。现行验证脚本 84 项通过。
- 最新 HTML 有 29 个嵌入图，52 个代码块默认折叠，未检出 warning、stderr 或 error，89 个本地下载链接有效。现有 ZIP 的 CRC 校验通过，三个支持文件齐全。目前待修的是上文统计解读及交付版本同步。
- 当前克隆主定义还是供者内 `IGHV + CDR3 aa` 精确匹配，未改成 0.85 家系聚类。本次交付可以继续报告按这个定义观察到的克隆型。
- `docs/` 面向 Pages 发布。包里有供者编号、年龄、性别、手术诊断信息以及细胞级 CDR3 序列。若计划通过公开链接交付，应按项目允许的共享范围选择公开的附件。

</details>

<details>
<summary>2026-11-14 历史验收记录，仅适用于当时的报告和交付包</summary>

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

</details>
