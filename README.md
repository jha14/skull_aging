# skull_aging

颅骨骨髓单细胞 BCR 衰老分析（年轻 vs 年老供体）。

## 在线报告

最初 21 人交付版仍在：**https://jha14.github.io/skull_aging/**

去掉 O6 和 O11 的交付版：https://jha14.github.io/skull_aging/exclude_o6_o11/

去掉 O6、O8 和 O11 的交付版：https://jha14.github.io/skull_aging/exclude_o6_o8_o11/

## 本地复现

```bash
quarto render codes/bcr_skull_bm.qmd
Rscript codes/check_bcr_analysis.R results/bcr
python3 codes/package_bcr_delivery.py

quarto render archive/bcr_exclude_O6_O8_O11/bcr_skull_bm.qmd
Rscript codes/check_bcr_analysis.R archive/bcr_exclude_O6_O8_O11/render_out
python3 codes/package_bcr_delivery.py --three
```

`check_bcr_analysis.R` 的第一个参数是该版本自己的结果目录。`--three` 打包去掉 O6、O8、O11 的交付版，不会改写 21 人原版的网站根目录。

需要项目内 `data/`、SHM 缓存及 R 依赖，详见 `codes/bcr_skull_bm.qmd`。

## GitHub Pages

网站根目录 `docs/` 保持最初 21 人交付版。`codes/package_bcr_delivery.py` 只更新 `docs/exclude_o6_o11/`。推送 `main` 分支后 Pages 从 `/docs` 发布。