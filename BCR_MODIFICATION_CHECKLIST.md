# 颅骨骨髓 BCR 分析：交付前修改清单

日期：2026-11-14  
项目目录：`/home/han/Desktop/fangni/skull_aging`  
审查对象：`codes/bcr_skull_bm.qmd`、`codes/bcr_helpers.R`、`codes/run_shm_analysis_10X.sh` 及现有输出。

这份清单保留首次审查的问题与验收要求。当前入口固定为 `codes/bcr_skull_bm.qmd` 和 `codes/bcr_helpers.R`，输出固定为 `results/bcr/`，后续直接迭代，不增加版本号。首次审查前的代码和输出已归档至 `results/bcr_review/baseline/`；最新实施状态以 `CHANGELOG.md` 和现行验证结果为准。

下文问题行号对应首次审查时的历史基线，不是当前文件行号。实施时请按变量名或 chunk 名定位。

## 1. 实施范围和输出约定

- [x] 维护 `codes/bcr_skull_bm.qmd` 和 `codes/bcr_helpers.R` 两个固定入口，不另建带版本号的副本。
- [x] 当前结果统一写入 `results/bcr/`，HTML 为 `codes/bcr_skull_bm.html`，在同一套文件上迭代。
- [x] 保留 `data/`、`meta_data.xlsx`、`codes_template/` 和历史审查基线；不删除 `results/bcr/shm/` 缓存。当前派生结果可在固定目录更新，不递归删除整个输出目录。
- [ ] 样本年龄、性别、原始 cluster 和现有注释不擅自更改；需要调整细分注释时保留原标签，并给出 marker 依据及敏感性结果。
- [ ] 先修复并验证数据提取，再重新计算所有依赖它的图表和统计，最后渲染 HTML。
- [ ] 不以重现旧 p 值或获得显著结果为目标。审查数值是回归核对基线，不是应硬编码的期望结果。

## 2. P0：确定的 bug，交付前必须修复

### P0-01 同种型误提取：D 基因被当成 IgD

**位置：** `codes/bcr_skull_bm.qmd:237`，`load-bcr` chunk。

原代码从整个重链基因拼接字符串搜索第一个匹配项：

```r
c_gene = str_extract(IGH, "IGH(?:M|D|E|A[12]|G[1-4])")
```

例如 `IGHV1-24.IGHD3-9.IGHJ4.IGHM` 会得到 `IGHD`，实际 constant gene 是 `IGHM`。

**已验证影响：** 2,559 个具有已知 constant gene 的细胞被误标；另有 4 个 constant gene 缺失的细胞被标为 IgD。原 IgD 共 2,865 个，正确为 302 个；147 个实际 IgG/IgA 细胞被归入 IgD。

**修改要求：**

- [ ] 从所选原始 IGH contig 的 `c_gene` 列读取同种型。
- [ ] 同时保留 `contig_id`、V/D/J/C、CDR3 nt/aa、reads/UMIs 和选择依据，保证所有字段来自同一条 contig。
- [ ] 缺失 constant gene 保留为 NA/Unknown；`switched` 对未知同种型也应为 NA。
- [ ] 同种型比例的分母为已知同种型细胞数，同时导出总细胞数、已知数和未知数。
- [ ] 如果只做临时修补，必须匹配字符串尾端；正式版本优先使用独立原始列。

**验收：** 所选重链的 constant gene 与原始 CSV 逐细胞一致；含 `IGHD3-9` 但以 `IGHM` 结尾的测试案例必须得到 IgM。固定为当前细胞集合和选链规则时，应复核到 302 个真正 IgD；若规则改变，要导出差异原因。

**需重算：** 同种型组成、class-switched 比例、同种型内扩增、按同种型分层的 SHM、细胞元数据、相关检验和导出对象。

### P0-02 IGHV 名称截断

**位置：** `codes/bcr_skull_bm.qmd:235`；`codes/bcr_helpers.R:121` 的 `norm_v()`。

`IGHV[0-9]+-[0-9]+` 不能完整保留 `IGHV4-30-4`、`IGHV1-69D`、`IGHV7-4-1` 等名称，影响 861 个细胞。

**修改要求：**

- [ ] 从同一条已选 IGH contig 的 `v_gene` 读取完整名称。
- [ ] 参考库归一化只处理明确的等位基因后缀、物种说明或空白，不截断额外编号、D 后缀或其他合法基因名称组成。
- [ ] 模糊、多基因注释保留原始值并明确处理，不通过宽松正则静默合并。
- [ ] 用完整 V 名称重建克隆键、V 使用率、公共克隆和抗原匹配。

**验收：** 上述三个基因名完整保留；原始 V/J/CDR3 与最终细胞表逐细胞对应。当前审查未发现截断造成同一旧克隆键内存在多个完整 V 名称，因此不能预设此次修复必然改变克隆大小。

### P0-03 “同种型内扩增”沿用了全库克隆大小

**位置：** `codes/bcr_skull_bm.qmd:732–735`，`iso_exp`。

原 `mean(expanded)` 使用整个供体的 `clone_size`。一个克隆仅有 1 个 IgM 和 1 个 IgG 细胞时，两种同种型均被错误计入“同种型内扩增”。

**修改要求：**

- [ ] 按 `sample_id + isotype_group + clone_id` 重新计数。
- [ ] 以该层内克隆大小 ≥ 2 计算同种型内扩增比例。
- [ ] 可同时保留“该同种型细胞中属于全库扩增克隆的比例”，但必须使用不同字段名、图标题和方法描述。
- [ ] 将缺失同种型排除于这类比例的分母，并记录缺失数。

**验收：** 同一克隆只有 1 个 IgM + 1 个 IgG 时，全库扩增为 TRUE，两种同种型内扩增均为 FALSE；同一同种型内有 2 个细胞时才为 TRUE。

## 3. P1：交付前需要完成的数据和方法修正

### P1-01 统一选链和多重链处理，保留可追溯信息

当前 scRepertoire 2.6.1 的 `filterMulti = TRUE` 按 reads 选择链。原始数据中有 86 个已纳入细胞具有多条 productive IGH；BCR 流程保留最高 reads 的一条，SHM 流程则剔除多条重链，策略不一致。

- [ ] 明确主分析选链规则，并保留 reads/UMIs、原始 contig 数和不同 productive 重排数。
- [ ] 区分“多条 contig”与“多个不同重排”；同一 V(D)J 对应 IgM/IgD 转录本不能仅因 contig 多就直接视为 doublet。
- [ ] SHM 按 `sample_id + selected_contig_id/sequence_id` 关联，验证 CDR3 nt 一致。所选重链未通过 IgBLAST/SHM 质控时，标为缺失并记录原因，不改选另一条链填补。
- [ ] 可维持原选链规则作为可比主结果，再补充排除多重排细胞的敏感性分析。
- [ ] 导出细胞流转表：原始 GEX、候选 B 系、productive IGH、成功匹配、已知同种型、完整配对、有效 SHM、多重排及每一步剔除原因。

### P1-02 明确主分析细胞范围和克隆定义

现有 8,759 个重链细胞中有 2,380 个来自前体。Large Pre-B / Small Pre-B 的轻链配对率约为 22% / 34%；naive、memory、plasma 约为 99%。恢复到 IGH 不能一律表述为恢复到完整成熟 BCR。

- [ ] 主结果至少分别展示 Naive B、Memory B 和 Plasma。
- [ ] Immature、Transitional 和各类 Precursor 作为明确标记的发育阶段/补充结果。
- [ ] 合并分析必须列出实际包含的亚型；现有 `lineage = Mature B` 也包含 Immature/Transitional，不能仅凭名称默认其都为成熟细胞。
- [ ] 保留“供体内完整 IGHV + 完全相同重链 CDR3aa”作为操作性克隆型定义，并在报告中这样命名。
- [ ] 亚型、合并细胞范围、同种型内的克隆大小均在相应分析范围内重算。
- [ ] 至少增加 V/J + CDR3nt，以及完整配对重轻链的严格克隆型敏感性分析，并分别报告纳入细胞和供体数。
- [ ] 暂不把 exact clonotype 等同于已经推断出的生物学克隆家族。

### P1-03 修正 V 基因使用率的零值与图表分母

**位置：** `codes/bcr_skull_bm.qmd:595–637`，`v_usage` / `v_mean` / `v_tests`。

原检验补零，但计算平均使用率、选 top genes 和画箱线图时未补零。

- [ ] 对有有效受体数据的供体 × V 基因建立完整网格，未观察到该 V 基因记为 0。
- [ ] 缺少有效受体数据的供体不能补成“全部基因为 0”并纳入比较。
- [ ] 排名、筛选、绘图和检验共用补零后的表及同一供体纳入集合。
- [ ] 并列报告细胞加权与克隆等权使用率，至少对主要信号检查是否受大克隆或亚型组成驱动。

### P1-04 修正回收率分母并展示低回收供体

原全对象回收率分母含 626 个 CD3D+ T 细胞。`MY_SkullBM_240304` 仅有 16 个进入分析的重链细胞，Cell Ranger 本身仅报 18 个 VDJ B 细胞、VDJ 比对率 40.8%。

- [ ] B 系回收率的分母排除 Non-B；同时展示各亚型及 Plasma 的回收率。
- [ ] 如保留整个对象的回收率，将其单独标为“全对象”，不要标为 B 系回收率。
- [ ] 导出每个指标的实际 n、纳入状态、阈值和排除原因。
- [ ] 对低回收供体保留 QC 展示，按预先说明的阈值排除相应推断统计，不能把低回收解释为低克隆性。

### P1-05 控制抽样深度，保持供体为独立重复

扩增比例和 top10 占比也受抽样深度影响。

- [ ] 保留全库至少 30 个重链细胞、亚型至少 10 个细胞等当前规则作为明确参数；改变阈值时另列敏感性结果。
- [ ] 增加例如 30、50、100 个细胞的供体内无放回重复抽样，设定随机种子，展示各深度保留的 Young/Old 供体数。
- [ ] 多次抽样先汇总到每个供体，再进行组间比较；不得把 200 次抽样作为 200 个独立样本。
- [ ] 默认每组至少 3 名有效供体才给检验 p 值；不足时展示描述结果和“不执行检验”的原因。
- [ ] 展示供体效应量、样本数和 BH 校正结果；检验家族及探索性分析范围写清楚。
- [ ] 不显著表述为“本数据未发现差异”，不表述为两组等价。

### P1-06 SHM 保留正确部分，删除静默回退

**位置：** `codes/bcr_skull_bm.qmd:829–842`。

独立复算已验证原 SHM 数值一致，所匹配重链 CDR3 也一致。不能仅因未调用 `createGermlines()` 就推定 V 区 SHM 无效。

- [ ] 保留 `sequence_alignment` / `germline_alignment`、`IMGT_V` 的 V 区计算。
- [ ] 删除失败后自动改用 `1-v_identity` 的逻辑；失败必须显式报错，或将 SHM 模块标记为未完成并不生成该项结论。
- [ ] 不静默隐藏关键计算失败；若展示 `1-v_identity`，使用独立指标名、定义和单独结果列。
- [ ] 导出 V 区覆盖范围、有效计算细胞数和缺失原因；高 SHM 离群值要能追溯至 contig。
- [ ] 展示每个供体 × 亚型的细胞汇总和克隆等权汇总。
- [ ] Memory B 按修正的 IgM/IgG/IgA 分层；Plasma 保留相应分层。分层后的有效供体数、细胞数和检验规则明确。

**已有信号的正确解释：** Memory B 的供体 SHM 中位数为 Young 4.51%、Old 5.21%，原 SHM 家族 BH 约 0.0486；按同种型分层后的三项 BH 均未达到 0.05。必须重算并按新结果写结论，不能概括为所有同种型均增加 SHM。

### P1-07 补充诊断混杂及供体敏感性分析

Young 动脉瘤病例为 4/10，Old 为 11/11；两组各 2 名男性。

- [ ] 主报告展示上述设计分布，不把组间差异直接归因为衰老。
- [ ] 对主要结论提供女性限制、动脉瘤病例限制和逐一移除供体的敏感性结果。
- [ ] 不虚构感染/疫苗史、药物、建库批次等当前缺少的协变量。
- [ ] 不在仅 21 名供体上默认加入大量协变量；限制分析的样本量和局限必须展示。
- [ ] 连续年龄分析若开展，明确 32–59 岁之间无样本。

### P1-08 修复公共克隆与抗原匹配的边界情况

**位置：** `qmd:923–951` 的 `near_public`；`bcr_helpers.R:108` 的 `norm_cdr3()`；`qmd:1040` 后的 `antigen`。

- [ ] 公共/近似公共匹配保留每条序列对应的全部供体，不能 `unique(sequence)` 后只保留第一个供体。
- [ ] 清晰区分 exact shared、距离恰为 1，以及距离 ≤ 1 的统计口径；去掉同供体配对和重复的无序配对。
- [ ] 区分 10x/AIRR junction 与已去锚的参考 CDR3，不能对两边一律删除首 C、尾 W。
- [ ] 统一大小写/空白时保留原序列；不通过删掉未知字符、终止符等方式制造“精确匹配”。异常序列应标记和记录。
- [ ] 参考库失败、空库或没有合格查询时标为未执行/不可计算，相关比例为 NA，不生成“0 命中”结论。
- [ ] 导出参考库版本、匹配规则、总细胞数、合格查询数、唯一命中细胞数、候选克隆数及来源。一次参考库多条匹配不能重复计数同一细胞。
- [ ] 使用本地已有参考库；渲染时不自动下载或替换版本。

**当前证据：** 修正后 exact public heavy key 仍为 0、近似共享仍为 3 对、2024-02-08 CoV-AbDab 的重链精确匹配仍为 0。相关逻辑有潜在 bug，但不能描述为这些修正已经改变了当前的命中结果。

**验收用例：** 序列 X 在供体 A/B 共有，近似序列 Y 只在 A 中；必须找出 X–X 的 A/B 共享，以及 X(B)–Y(A) 的跨供体近似关系。参考 CDR3 自身以 C 开头或 W 结尾时不能被再次剪短。

### P1-09 修复对象导出和 top clone 表

**位置：** `qmd:854` 保存对象，`qmd:899–900` 才写回 SHM；`qmd:1183–1187` 的 `top_clones`。

- [ ] 在 SHM、公共克隆及所有最终元数据写回后统一保存 Seurat 对象。
- [ ] 按 barcode 检查 Seurat 元数据与导出的细胞表一致，包括同种型、克隆大小、SHM 和公共克隆标记。
- [ ] top clone 表先按 `sample_id + clone_id` 聚合成一行，再按克隆大小排序取前 15 个。
- [ ] 细胞亚型和同种型作为汇总字段，不作为使同一克隆重复的去重条件；并列时使用明确、确定的排序规则。
- [ ] 原表有 35 个重复的克隆键；新版每个供体内 `clone_id` 必须唯一。

### P1-10 把预处理与 HTML 渲染分开，记录缓存和依赖

- [ ] 默认渲染仅读取已存在的 SHM 数据，不自动重跑所有 IgBLAST 样本。
- [ ] 明确参数：`output_dir`、`shm_cache_dir`、是否运行预处理、抽样种子/次数/深度和最小细胞数。
- [ ] 如需改 SHM shell 脚本，直接迭代固定脚本；工具、参考路径和线程数支持环境变量或参数，检查必需文件和工具。
- [ ] 缓存尽可能记录输入哈希、参数、工具和参考版本，不能仅靠输出非空判断有效。
- [ ] 老缓存缺乏生成时的记录时，明确标注追溯限制；事后计算当前参考哈希，不能证明旧输出就是由该参考生成。
- [ ] 锁定/导出实际包版本，检查 scRepertoire 的安装版本和参数行为，不直接照搬最新版教程。
- [ ] 把当前运行的图表、表格和对象写入文件清单，避免旧结果残留混入交付。
- [ ] 自包含 HTML 应能离线打开，图表与统计一致，并有简明的方法和运行说明。

### P1-11 注释和完整对象覆盖率的解释

- [ ] 保留现有 cluster → subtype 映射来源及 marker 图；不要把手工标签描述为合作者原始最终注释。
- [ ] Immature/Transitional 边界保持审慎，至少补充合并这两类的敏感性或明确不确定性。
- [ ] 不因 MKI67 高就把 cluster 5 改标为 plasmablast；结合 VPREB1/IGLL1 和 PRDM1/SDC1。
- [ ] 完整对象与 B 子集的 cluster 编号不同，不能直接按相同编号传递标签。
- [ ] 完整对象有 productive IGH 但不在 B 子集的细胞不能自动补回；需结合转录标记和 doublet/背景信号检查。
- [ ] 当前已有全对象 marker、覆盖率和 B 子集 marker 的审查表，优先复用作为依据。

## 4. P2：修复主流程后的可选扩展

这些不作为本轮最低交付的阻塞项，避免在基础数据错误尚未修复时扩大分析范围。

| 扩展 | 目的 | 前提/限制 |
|---|---|---|
| 正式克隆家族推断 | 把因 SHM 发生 CDR3 差异的相关序列归为家族 | 供体内 V/J/长度分组、距离分布和阈值评估、轻链验证；不照搬旧项目 0.1227558 |
| Memory–plasma 共享及谱系树 | 检查克隆联系和分化相关结构 | 有足够克隆内细胞和序列；横断面不能确定转化时间/方向 |
| 同克隆多同种型 | 描述类别转换相关结构 | 先排查多链和错误配对；不把单次采样直接解释为转换轨迹 |
| GEX 与 BCR 联合 | 检查扩增/高 SHM 克隆的转录状态 | 供体 × 亚型 pseudobulk 或合适层级模型，避免细胞伪重复 |
| ABC-like 状态 | 检查 memory 中 FCRL5/ITGAX/TBX21 相关状态 | 用多标记和参考支持，不能仅根据年龄组命名 |
| IEDB 等跨抗原参考库 | 为配对 VH/VL 生成有出处的候选 | 重链 CDR3 相同不能确认特异性；随后需要重组抗体与结合实验 |
| 供体种系等位基因推断、选择压力分析 | 提升 SHM 和选择分析的解释 | 需要足够序列/克隆和明确的推断质量标准 |

参考资料：

- [SHazaM IMGT 区域定义](https://shazam.readthedocs.io/en/stable/topics/IMGT_SCHEMES/)
- [Immcantation 单细胞教程](https://immcantation.readthedocs.io/en/stable/getting_started/10x_tutorial.html)
- [SCOPer hierarchicalClones](https://scoper.readthedocs.io/en/stable/topics/hierarchicalClones/)
- [Cell Ranger 克隆定义](https://www.10xgenomics.com/support/software/cell-ranger/9.0/resources/cr-5p-vdj-algorithm-clonotyping)
- [CoV-AbDab](https://opig.stats.ox.ac.uk/webapps/covabdab)
- [IEDB 受体数据说明](https://discuss.iedb.org/t/tcr-and-bcr-antibody-sequence-data/168)

## 5. 最终验收清单

- [ ] P0 三项 bug 均修复，并用有区分度的最小案例和真实数据验证。
- [ ] 输入样本无重复、分组无缺失、cluster 映射完整；barcode + sample_id 对应正确。
- [ ] 每个纳入细胞的所选 IGH contig 可追溯，V/J/C/CDR3 来自同一条链。
- [ ] 原始细胞集合保持不变时能解释 8,759 个细胞和上述纠错数；若变更过滤规则，逐项解释细胞/供体变化。
- [ ] 分母、零值、未知值和未执行状态处理正确，没有把缺失写成真实 0。
- [ ] 统计始终以供体为独立重复，有效供体不足时不执行检验。
- [ ] 深度、克隆定义、主要同种型及诊断敏感性结果完整展示。
- [ ] 导出对象与细胞表一致，top clone 一克隆一行，当前文件清单没有混入旧图表。
- [ ] 全流程运行成功；SHM 没有静默切换指标；渲染没有隐藏关键失败。
- [ ] HTML 自包含且图表可读，方法、结论、代码和统计输出一致。
- [ ] 输出变更说明：修了什么、影响多少细胞、哪些结论改变、哪些不确定性仍在。

## 6. 审查证据入口

- `codes/bcr_pre_delivery_review.html` / `.qmd`：完整审查报告及图表。
- `codes/audit_bcr_analysis.R`：独立核查与敏感性分析代码，供复用逻辑与对照，不能不经检查地视为新版生产流程。
- `results/bcr_review/audit_tables.xlsx`：汇总证据。
- `results/bcr_review/tables/`：CSV 表，包括 `audit_counts`、`isotype_confusion`、`v_confusion`、`clone_sensitivity_tests`、`rarefaction_tests`、`shm_sensitivity_tests`、`memory_shm_isotype_tests` 等。
- `results/bcr_review/input_fingerprints.csv` / `sessionInfo.txt`：审查基线及环境。

给 Cursor 的执行提示词另见同目录 `CURSOR_BCR_PROMPT.md`。
