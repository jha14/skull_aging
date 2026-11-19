打开 bcr_skull_bm.html 阅读报告，保留 tables/ 与 figures/ 目录，正文中的下载链接才能打开。
tables/fig_*.xlsx：逐图作图数据、statistics、dictionary 和 parameters。
tables/figure_table_map.xlsx / figure_table_map.csv：图与 PDF、PNG、逐图工作簿的对应关系。
tables/age_tests.xlsx：完整年龄组 Wilcoxon 检验（176 条）；public_antigen.xlsx：公共抗原库比对汇总。
tables/figure_stat_annotations.csv：图中原始 P 与完整统计及 BH 的对应关系。
tables/bcr_cells.xlsx、clone_metrics.xlsx、clone_size_bins.xlsx、top_clones.xlsx：细胞与克隆层汇总。
tables/diversity.xlsx、startrac.xlsx、recovery.xlsx、cell_flow.xlsx、isotype.xlsx、ighv_usage.xlsx、shm.xlsx：各模块完整结果表。
tables/clone_composition_donuts.xlsx、validation_checks.csv、umap_display_audit.csv：甜甜圈作图数据、验证与 UMAP 审计。
tables/file_manifest.xlsx：本压缩包文件清单；figures/：全部现行 PDF 与 PNG；rdata/bcr_cells.rds：带 BCR 注释的细胞表（R 对象）。
sessionInfo.txt：运行环境；source/：QMD 与复现辅助脚本。不含完整 Seurat 对象与 SHM 原始缓存，复现仍需项目 data/。
年龄组比较为探索性结果，诊断组成差异限制了对衰老效应的解释。
