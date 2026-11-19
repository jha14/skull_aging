# skull_aging

颅骨骨髓单细胞 BCR 衰老分析（年轻 vs 年老供体）。

## 在线报告

部署后访问：**https://jha14.github.io/skull_aging/**

报告页顶部提供 **[bcr_delivery.zip](https://jha14.github.io/skull_aging/bcr_delivery.zip)** 完整结果下载（表格、图、源码与 `bcr_cells.rds`）。

## 本地复现

```bash
quarto render codes/bcr_skull_bm.qmd
python3 codes/package_bcr_delivery.py
```

需要项目内 `data/`、SHM 缓存及 R 依赖，详见 `codes/bcr_skull_bm.qmd`。

## GitHub Pages

`docs/` 由 `codes/package_bcr_delivery.py` 自动生成，勿手工编辑；推送 `main` 分支后 Pages 从 `/docs` 发布。