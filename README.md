# skull_aging

颅骨骨髓单细胞 BCR 衰老分析（年轻 vs 年老供体）。

## 在线报告

最初 21 人交付版仍在：**https://jha14.github.io/skull_aging/**

去掉 O6 和 O11：https://jha14.github.io/skull_aging/exclude_o6_o11/

再去掉 O8：https://jha14.github.io/skull_aging/exclude_o6_o8_o11/

## 本地复现

```bash
quarto render codes/bcr_skull_bm.qmd
python3 codes/package_bcr_delivery.py
```

需要项目内 `data/`、SHM 缓存及 R 依赖，详见 `codes/bcr_skull_bm.qmd`。

## GitHub Pages

网站根目录 `docs/` 保持最初 21 人交付版。`codes/package_bcr_delivery.py` 只更新 `docs/exclude_o6_o11/`。推送 `main` 分支后 Pages 从 `/docs` 发布。