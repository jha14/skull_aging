# Helpers for the corrected skull bone-marrow BCR report.
# Chain, isotype, V-gene and matching functions retain raw contig fields.

bcr_font_family <- "Noto Sans CJK SC"
age_col <- c(Young = "#4DBBD5", Old = "#E64B35")

subtype_col <- c(
  `Pro-B` = "#F6E27A",
  `Cycling precursor` = "#E6C84A",
  `Large Pre-B` = "#E07A3D",
  `Small Pre-B` = "#F2A65A",
  `Immature B` = "#F2C14E",
  `Transitional B` = "#7EB6E8",
  `Naive B` = "#4C78A8",
  `Memory B` = "#2F5280",
  Plasma = "#B279A2",
  `CD3D+ T` = "#F4A8B8"
)

isotype_col <- c(
  IGHD = "#B5B5B5", IGHM = "#4C78A8", IGHA1 = "#F2C14E", IGHA2 = "#E6A817",
  IGHG1 = "#E45756", IGHG2 = "#C43C3B", IGHG3 = "#F08A78", IGHG4 = "#A33B3B",
  IGHE = "#54A24B"
)

isotype_group_col <- c(
  IGHD = "#B5B5B5", IGHM = "#4C78A8", IGHA = "#E6A817",
  IGHG = "#E45756", IGHE = "#54A24B"
)

theme_bcr <- function(base_size = 12) {
  ggplot2::theme_bw(base_size = base_size, base_family = bcr_font_family) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(color = "black"),
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold", size = base_size + 1),
      strip.background = ggplot2::element_rect(fill = "grey95", color = NA),
      strip.text = ggplot2::element_text(face = "bold")
    )
}

save_plot <- function(plot, name, width, height) {
  base <- file.path(fig_dir, name)
  ggplot2::ggsave(
    paste0(base, ".pdf"), plot, width = width, height = height, limitsize = FALSE, bg = "white",
    device = grDevices::cairo_pdf, family = bcr_font_family
  )
  ggplot2::ggsave(
    paste0(base, ".png"), plot, width = width, height = height, dpi = 400, limitsize = FALSE, bg = "white",
    device = ragg::agg_png
  )
  invisible(plot)
}

format_exact_p <- function(p) {
  vapply(p, function(x) {
    if (is.na(x)) {
      NA_character_
    } else {
      paste0("p = ", format.pval(x, digits = 3, eps = 0.001))
    }
  }, character(1))
}

p_lookup <- function(ids) {
  tab <- dplyr::bind_rows(get("stat_tests", envir = parent.frame()))
  hit <- tab[match(ids, tab$test_id), , drop = FALSE]
  stats::setNames(hit$p_value, ids)
}

save_heatmap <- function(ht, name, width, height) {
  grDevices::cairo_pdf(file.path(fig_dir, paste0(name, ".pdf")), width = width, height = height,
                      family = bcr_font_family)
  ComplexHeatmap::draw(ht)
  grDevices::dev.off()
  ragg::agg_png(
    file.path(fig_dir, paste0(name, ".png")),
    width = width, height = height, units = "in", res = 300
  )
  ComplexHeatmap::draw(ht)
  grDevices::dev.off()
  invisible(ht)
}

write_xlsx <- function(x, name) {
  path <- file.path(tab_dir, paste0(name, ".xlsx"))
  openxlsx::write.xlsx(x, path, overwrite = TRUE, na = "")
  invisible(path)
}

productive_flag <- function(x) {
  toupper(as.character(x)) %in% c("T", "TRUE")
}

isotype_group_of <- function(c_gene) {
  c_gene <- as.character(c_gene)
  out <- rep(NA_character_, length(c_gene))
  out[c_gene %in% c("IGHA1", "IGHA2")] <- "IGHA"
  out[c_gene %in% c("IGHG1", "IGHG2", "IGHG3", "IGHG4")] <- "IGHG"
  keep <- c_gene %in% c("IGHM", "IGHD", "IGHE")
  out[keep] <- c_gene[keep]
  out
}

switched_flag <- function(isotype_group) {
  ifelse(is.na(isotype_group), NA, isotype_group %in% c("IGHA", "IGHG", "IGHE"))
}

# Parse one reference heavy-chain V annotation.
# A comma-separated or "or" call is multi-gene and is not given a match key.
# Allele suffixes are removed only inside a single gene name.
# Only a confirmed human receptor gene is returned as match_gene.
parse_reference_heavy_v <- function(x) {
  raw <- trimws(as.character(x))
  n <- length(raw)
  out <- data.frame(
    raw = raw,
    multi = rep(FALSE, n),
    species = rep(NA_character_, n),
    gene = rep(NA_character_, n),
    match_gene = rep(NA_character_, n),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(n)) {
    item <- raw[[i]]
    if (is.na(item) || !nzchar(item)) next
    multi <- grepl("[,;]|[[:space:]]or[[:space:]]", item, ignore.case = TRUE)
    out$multi[[i]] <- multi
    species <- if (grepl("\\(\\s*human\\s*\\)", item, ignore.case = TRUE)) {
      "Human"
    } else if (grepl("\\(\\s*mouse\\s*\\)", item, ignore.case = TRUE)) {
      "Mouse"
    } else if (grepl("\\(", item)) {
      "other"
    } else {
      NA_character_
    }
    out$species[[i]] <- species
    if (multi) next
    gene <- sub("\\s*\\([^)]*\\)", "", item)
    gene <- sub("\\*[0-9A-Za-z]+$", "", trimws(gene))
    gene <- toupper(gsub("[[:space:]]", "", gene))
    if (!grepl("^IG[HKL]V[0-9]", gene)) next
    out$gene[[i]] <- gene
    if (identical(species, "Human")) out$match_gene[[i]] <- gene
  }
  out
}

reference_v_gene <- function(x) {
  parse_reference_heavy_v(x)$match_gene
}

single_ighv <- function(x) {
  x <- trimws(as.character(x))
  # /OR is part of an IMGT orphon name, not a separator between calls.
  slash_ok <- !grepl("/", x, fixed = TRUE) |
    grepl("^IGHV[0-9]+/OR[0-9]+-[0-9]+(\\*[[:alnum:]]+)?$", x)
  ok <- !is.na(x) & grepl("^IGHV[0-9]", x) & slash_ok &
    !grepl("[,;]| or |[[:space:]]", x, ignore.case = TRUE)
  ifelse(ok, x, NA_character_)
}

aa_sequence_ok <- function(x) {
  !is.na(x) & grepl("^[ACDEFGHIKLMNPQRSTVWY]+$", as.character(x))
}

# The 10x junction includes C104 and W/F118; CoV-AbDab CDRH3 excludes them.
# Retain the raw junction for traceability, but match only the canonical core.
query_cdr3_keys <- function(cdr3) {
  x <- toupper(trimws(as.character(cdr3)))
  invalid <- !aa_sequence_ok(x)
  full <- x
  full[invalid] <- NA_character_
  n <- nchar(x)
  strip <- !invalid & !is.na(n) & n >= 8 & substr(x, 1, 1) == "C" &
    substr(x, n, n) %in% c("W", "F")
  core <- rep(NA_character_, length(x))
  core[strip] <- substr(x[strip], 2, n[strip] - 1)
  data.frame(cdr3_full = full, cdr3_core = core, cdr3_invalid = invalid, stringsAsFactors = FALSE)
}

read_iedb_bcr_reference <- function(path) {
  unavailable <- function(note) list(data = NULL, note = note)
  if (!file.exists(path) || file.info(path)$size == 0) {
    return(unavailable("IEDB BCR export missing or empty"))
  }
  hdr <- utils::read.csv(path, nrows = 2, header = FALSE, stringsAsFactors = FALSE, check.names = FALSE)
  names <- paste(trimws(as.character(hdr[1, ])), trimws(as.character(hdr[2, ])))
  dat <- utils::read.csv(
    path, skip = 2, header = FALSE, stringsAsFactors = FALSE,
    check.names = FALSE, colClasses = "character"
  )
  if (ncol(dat) != length(names)) return(unavailable("IEDB BCR export has an unexpected number of columns"))
  names(dat) <- names
  needed <- c(
    "Chain 1 Type", "Chain 1 Organism IRI", "Chain 1 Curated V Gene", "Chain 1 Calculated V Gene",
    "Chain 1 CDR3 Curated", "Chain 1 CDR3 Calculated", "Receptor IEDB Receptor ID",
    "Epitope Name", "Epitope Source Molecule", "Epitope Source Organism", "Epitope IEDB IRI"
  )
  if (!all(needed %in% names(dat))) return(unavailable("IEDB BCR export schema was not recognized"))
  keep <- tolower(dat[["Chain 1 Type"]]) == "heavy" &
    grepl("NCBITaxon_9606", dat[["Chain 1 Organism IRI"]], fixed = TRUE)
  dat <- dat[keep, , drop = FALSE]
  if (!nrow(dat)) return(unavailable("IEDB BCR export has no human heavy chains"))
  curated <- parse_reference_heavy_v(dat[["Chain 1 Curated V Gene"]])
  calculated <- parse_reference_heavy_v(dat[["Chain 1 Calculated V Gene"]])
  use_curated <- !curated$multi & !is.na(curated$gene)
  v_gene <- ifelse(use_curated, curated$gene, ifelse(!calculated$multi, calculated$gene, NA_character_))
  cdr_calc <- toupper(trimws(dat[["Chain 1 CDR3 Calculated"]]))
  cdr_cur <- toupper(trimws(dat[["Chain 1 CDR3 Curated"]]))
  cdr_calc[!aa_sequence_ok(cdr_calc)] <- NA_character_
  cdr_cur[!aa_sequence_ok(cdr_cur)] <- NA_character_
  cdr3 <- ifelse(!is.na(cdr_calc), cdr_calc, cdr_cur)
  light_raw <- ifelse(nzchar(dat[["Chain 2 Curated V Gene"]]), dat[["Chain 2 Curated V Gene"]], dat[["Chain 2 Calculated V Gene"]])
  light_parsed <- parse_reference_heavy_v(light_raw)
  light_human <- grepl("NCBITaxon_9606", dat[["Chain 2 Organism IRI"]], fixed = TRUE)
  light_v <- ifelse(light_human & !light_parsed$multi, light_parsed$gene, NA_character_)
  light_cdr <- toupper(trimws(dat[["Chain 2 CDR3 Calculated"]]))
  light_cdr[!aa_sequence_ok(light_cdr)] <- NA_character_
  epitope <- paste(dat[["Epitope Name"]], dat[["Epitope Source Molecule"]], dat[["Epitope Source Organism"]], sep = " | ")
  epitope <- gsub("^( \\| )+|( \\| )+$", "", gsub("( \\| ){2,}", " | ", epitope))
  out <- data.frame(
    ref_name = paste(dat[["Receptor IEDB Receptor ID"]], dat[["Epitope IEDB IRI"]], sep = "|"),
    antigen_raw = epitope,
    v_gene = v_gene,
    ref_light_v = light_v,
    ref_light_cdr3 = light_cdr,
    cdr3_ref = cdr3,
    source = "IEDB BCR 2026-11-11",
    stringsAsFactors = FALSE
  )
  out <- out[!is.na(out$v_gene) & aa_sequence_ok(out$cdr3_ref), , drop = FALSE]
  if (!nrow(out)) return(unavailable("IEDB BCR export has no matchable human heavy chains"))
  list(data = out, note = paste0("human heavy chains with one V gene and a CDR3: ", nrow(out)))
}

read_local_antigen_reference <- function(path) {
  unavailable <- function(note) list(data = NULL, note = note)
  if (!file.exists(path) || file.info(path)$size == 0) {
    return(unavailable("reference file missing or empty"))
  }
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  n_quotes <- sum(lengths(regmatches(lines, gregexpr('"', lines, fixed = TRUE))))
  if (n_quotes %% 2L != 0L) {
    return(unavailable("reference is truncated: unclosed CSV quote"))
  }
  cov <- tryCatch(readr::read_csv(path, show_col_types = FALSE), error = identity)
  if (inherits(cov, "error")) return(unavailable(conditionMessage(cov)))
  names(cov) <- sub("^\uFEFF", "", names(cov))
  required <- c("Name", "Binds to", "Heavy V Gene", "CDRH3")
  if (!all(required %in% names(cov)) || nrow(readr::problems(cov))) {
    return(unavailable("reference schema or parsing failed"))
  }
  list(data = cov, note = "local schema and CSV checks passed; upstream completeness not verified")
}

shannon_div <- function(counts) {
  counts <- counts[counts > 0]
  if (length(counts) == 0) return(NA_real_)
  p <- counts / sum(counts)
  -sum(p * log(p))
}

exact_percent <- function(n) {
  n <- as.numeric(n)
  if (!length(n) || !is.finite(sum(n)) || sum(n) == 0) return(rep(0, length(n)))
  raw <- 100 * n / sum(n)
  raw[which.max(n)] <- raw[which.max(n)] - (sum(raw) - 100)
  raw
}

clone_bin_levels <- c("= 1", "= 2", "> 2")
clone_bin_col <- c("= 1" = "#C7E9B4", "= 2" = "#41B6C4", "> 2" = "#225EA8")

clone_size_bin <- function(size) {
  out <- rep(NA_character_, length(size))
  known <- !is.na(size)
  out[known & size <= 1] <- "= 1"
  out[known & size == 2] <- "= 2"
  out[known & size > 2] <- "> 2"
  factor(out, levels = clone_bin_levels)
}

gini_simpson <- function(ids) {
  ids <- ids[!is.na(ids) & ids != ""]
  if (!length(ids)) return(NA_real_)
  p <- as.numeric(table(ids))
  p <- p / sum(p)
  1 - sum(p * p)
}

shannon_bits <- function(counts) {
  counts <- counts[counts > 0]
  if (!length(counts)) return(0)
  p <- counts / sum(counts)
  -sum(p * log2(p))
}

startrac_indices <- function(clone_id, cluster) {
  ok <- !is.na(clone_id) & !is.na(cluster) & clone_id != ""
  clone_id <- as.character(clone_id[ok])
  cluster <- as.character(cluster[ok])
  empty <- data.frame(cell_subtype = character(), expa = numeric(), tran = numeric())
  if (!length(clone_id)) return(empty)
  tab <- table(clone_id, cluster)
  rows <- lapply(colnames(tab), function(cl) {
    col <- as.numeric(tab[, cl])
    n_pos <- sum(col > 0)
    hmax <- if (n_pos > 1) log2(n_pos) else NA_real_
    expa <- if (is.na(hmax)) NA_real_ else 1 - shannon_bits(col) / hmax
    present <- which(col > 0)
    row_h <- apply(tab[present, , drop = FALSE], 1, shannon_bits)
    w <- col[present] / sum(col[present])
    data.frame(cell_subtype = cl, expa = expa, tran = sum(w * row_h), stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

make_donut <- function(df, fill, title, colors) {
  df <- df[is.finite(df$fraction) & df$fraction > 0, , drop = FALSE]
  if (!nrow(df)) return(NULL)
  df <- df[order(df[[fill]]), , drop = FALSE]
  df$ymax <- cumsum(df$fraction)
  df$ymin <- c(0, head(df$ymax, -1))
  ggplot2::ggplot(df, ggplot2::aes(ymax = ymax, ymin = ymin, xmax = 4, xmin = 3, fill = .data[[fill]])) +
    ggplot2::geom_rect(color = "white", linewidth = 0.4) +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::xlim(1.6, 4.2) +
    ggplot2::scale_fill_manual(values = colors, drop = FALSE) +
    ggplot2::labs(title = title) +
    ggplot2::theme_void(base_family = bcr_font_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", size = 8, family = bcr_font_family),
      legend.position = "none",
      plot.background = ggplot2::element_rect(fill = "white", color = NA)
    )
}

wilcox_age <- function(df, value_col, metric, family, min_n = 3, test_id = NULL) {
  df <- df[is.finite(df[[value_col]]) & !is.na(df$age_group), , drop = FALSE]
  if (!"sample_id" %in% names(df) || anyDuplicated(df$sample_id)) {
    stop("Each test must contain one row per donor: ", metric)
  }
  n_young <- sum(df$age_group == "Young")
  n_old <- sum(df$age_group == "Old")
  if (is.null(test_id) || !nzchar(test_id)) test_id <- paste(family, metric, sep = " | ")
  out <- data.frame(
    test_id = test_id, family = family, metric = metric,
    n_young = n_young, n_old = n_old,
    median_young = NA_real_, median_old = NA_real_,
    median_difference_old_minus_young = NA_real_,
    p_value = NA_real_, note = "", stringsAsFactors = FALSE
  )
  if (n_young < min_n || n_old < min_n) {
    out$note <- paste0("not tested: fewer than ", min_n, " donors in a group")
    if (n_young > 0) out$median_young <- median(df[[value_col]][df$age_group == "Young"])
    if (n_old > 0) out$median_old <- median(df[[value_col]][df$age_group == "Old"])
    return(out)
  }
  out$median_young <- median(df[[value_col]][df$age_group == "Young"])
  out$median_old <- median(df[[value_col]][df$age_group == "Old"])
  out$median_difference_old_minus_young <- out$median_old - out$median_young
  if (length(unique(df[[value_col]])) < 2) {
    out$note <- "not tested: no variation across donors"
    return(out)
  }
  wt <- suppressWarnings(stats::wilcox.test(df[[value_col]] ~ df$age_group, exact = FALSE))
  out$p_value <- wt$p.value
  out
}

adjust_tests <- function(tests) {
  tests %>%
    dplyr::group_by(family) %>%
    dplyr::mutate(fdr = p.adjust(p_value, method = "BH")) %>%
    dplyr::ungroup()
}

add_exact_p <- function(p, data, y, p_values, facet = NULL) {
  p_values <- p_values[!is.na(p_values)]
  if (!length(p_values)) return(p)
  span <- diff(range(data[[y]], na.rm = TRUE))
  if (!is.finite(span) || span == 0) span <- max(abs(data[[y]]), na.rm = TRUE) * 0.2
  if (!is.finite(span) || span == 0) span <- 0.05
  if (is.null(facet)) {
    ymax <- max(data[[y]], na.rm = TRUE)
    stat <- data.frame(
      group1 = "Young", group2 = "Old",
      y.position = ymax + 0.055 * span,
      p.format = format_exact_p(p_values[[1]]),
      stringsAsFactors = FALSE
    )
  } else {
    stat <- dplyr::bind_rows(lapply(names(p_values), function(nm) {
      sub <- data[as.character(data[[facet]]) == nm, , drop = FALSE]
      if (!nrow(sub) || all(!is.finite(sub[[y]]))) return(NULL)
      data.frame(
        group1 = "Young", group2 = "Old",
        y.position = max(sub[[y]], na.rm = TRUE) + 0.055 * span,
        p.format = format_exact_p(p_values[[nm]]),
        stringsAsFactors = FALSE
      ) %>% dplyr::mutate("{facet}" := nm)
    }))
  }
  if (is.null(stat) || !nrow(stat)) return(p)
  p + ggpubr::stat_pvalue_manual(
    stat, label = "p.format", tip.length = 0.008, size = 2.15,
    bracket.size = 0.25, vjust = 0, inherit.aes = FALSE
  )
}

plot_age_box <- function(df, y, ylab, title = NULL, facet = NULL, p_values = NULL, percent = FALSE) {
  df <- dplyr::ungroup(df)
  df$age_group <- factor(df$age_group, levels = c("Young", "Old"))
  box_df <- df
  if (is.null(facet)) {
    keep <- names(which(table(df$age_group) >= 3))
    box_df <- df[df$age_group %in% keep, , drop = FALSE]
  } else {
    counts <- df %>%
      dplyr::count(.data[[facet]], age_group, name = ".n_box") %>%
      dplyr::filter(.n_box >= 3)
    box_df <- dplyr::semi_join(df, counts, by = c(facet, "age_group"))
  }
  p <- ggplot2::ggplot(df, ggplot2::aes(x = age_group, y = .data[[y]], fill = age_group))
  if (nrow(box_df)) {
    p <- p + ggplot2::geom_boxplot(
      data = box_df, width = 0.62, alpha = 0.8, outlier.shape = NA,
      linewidth = 0.35, color = "grey15"
    )
  }
  p <- p +
    ggplot2::geom_jitter(
      width = 0.08, height = 0, size = 1.05, shape = 21,
      color = "grey15", stroke = 0.2, alpha = 0.95
    ) +
    ggplot2::scale_fill_manual(values = age_col, drop = FALSE) +
    ggplot2::scale_x_discrete(limits = c("Young", "Old")) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.03, 0.16)),
      labels = if (percent) function(x) x * 100 else ggplot2::waiver()
    ) +
    ggplot2::labs(x = NULL, y = ylab, title = title) +
    theme_bcr(8) +
    ggplot2::theme(
      legend.position = "none",
      plot.title = ggplot2::element_text(size = 8, face = "bold", margin = ggplot2::margin(b = 1)),
      plot.margin = ggplot2::margin(3, 3, 2, 2),
      panel.border = ggplot2::element_rect(colour = "black", linewidth = 0.4, fill = NA),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(size = 7.5, colour = "black"),
      axis.text = ggplot2::element_text(size = 7, colour = "black"),
      strip.text = ggplot2::element_text(size = 7, face = "bold", margin = ggplot2::margin(2, 2, 2, 2))
    )
  if (!is.null(facet)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet)))
  }
  if (!is.null(p_values)) p <- add_exact_p(p, df, y, p_values, facet)
  p
}

theme_umap_ref <- function() {
  ggplot2::theme_bw(base_size = 8, base_family = bcr_font_family) +
    ggplot2::theme(
      aspect.ratio = 1,
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(fill = NA, color = "grey30", linewidth = 0.5),
      axis.title = ggplot2::element_text(size = 7.5),
      plot.title = ggplot2::element_text(face = "bold", size = 8),
      legend.title = ggplot2::element_blank()
    )
}

collect_age_tests <- function(items) {
  out <- dplyr::bind_rows(items)
  out <- out[!duplicated(out$test_id), , drop = FALSE]
  adjust_tests(out)
}

annotate_age_plot <- function(plot, data, value, tests, mapping, facets = character()) {
  stopifnot(!anyDuplicated(tests[c("family", "metric")]))
  ann <- dplyr::left_join(mapping, tests, by = c("family", "metric"), relationship = "many-to-one")
  if (anyNA(ann$test_id)) stop("Missing test for figure: ", paste(ann$metric[is.na(ann$test_id)], collapse = ", "))
  values <- data[[value]][is.finite(data[[value]])]
  span <- if (length(values)) max(diff(range(values)), abs(max(values)) * 0.12, 0.02) else 0.05
  shown <- ann[!is.na(ann$p_value), , drop = FALSE]
  attr(plot, "bcr_stat_annotations") <- ann
  if (!nrow(shown)) return(plot)
  if (!length(facets)) {
    shown$y.position <- max(values) + 0.08 * span
  } else {
    pos <- lapply(seq_len(nrow(shown)), function(i) {
      sub <- data
      for (facet in facets) sub <- sub[as.character(sub[[facet]]) == as.character(shown[[facet]][i]), , drop = FALSE]
      vals <- sub[[value]][is.finite(sub[[value]])]
      if (!length(vals)) return(NA_real_)
      max(vals) + 0.08 * span
    })
    shown$y.position <- unlist(pos)
    shown <- shown[is.finite(shown$y.position), , drop = FALSE]
  }
  if (!nrow(shown)) return(plot)
  shown$group1 <- "Young"
  shown$group2 <- "Old"
  shown$p.format <- format_exact_p(shown$p_value)
  for (facet in facets) {
    if (is.factor(data[[facet]])) {
      shown[[facet]] <- factor(shown[[facet]], levels = levels(data[[facet]]))
    }
  }
  out <- plot + ggpubr::stat_pvalue_manual(
    shown, label = "p.format", tip.length = 0.008, size = 2.15,
    bracket.size = 0.25, vjust = 0, inherit.aes = FALSE
  )
  attr(out, "bcr_stat_annotations") <- ann
  out
}

statistics_from_plot <- function(plot) {
  ann <- attr(plot, "bcr_stat_annotations")
  if (is.null(ann)) return(NULL)
  ann
}

test_caption <- function(tests, test_id) {
  hit <- tests[tests$test_id == test_id, , drop = FALSE]
  if (!nrow(hit)) return("No matching test")
  hit <- hit[1, ]
  if (is.na(hit$p_value)) {
    return(paste0(hit$note, "; Young n=", hit$n_young, ", Old n=", hit$n_old))
  }
  sprintf(
    "BH = %.3f; p = %.3g; Young/Old n = %d/%d; Old − Young median = %.3g",
    hit$fdr, hit$p_value, hit$n_young, hit$n_old, hit$median_difference_old_minus_young
  )
}

write_fig_xlsx <- function(id, plot_data, statistics = NULL, dictionary = NULL, parameters = NULL) {
  path <- file.path(tab_dir, paste0("fig_", id, ".xlsx"))
  sheets <- list(plot_data = plot_data)
  sheets$statistics <- if (is.null(statistics) || !nrow(statistics)) {
    data.frame(note = "Descriptive figure; no donor-level age test")
  } else statistics
  sheets$dictionary <- if (is.null(dictionary)) data.frame(field = names(plot_data), meaning = "") else dictionary
  sheets$parameters <- if (is.null(parameters)) data.frame(item = character(), value = character()) else parameters
  openxlsx::write.xlsx(sheets, path, overwrite = TRUE, na = "")
  invisible(paste0("fig_", id, ".xlsx"))
}

select_bcr_chains <- function(contigs) {
  prod <- contigs %>% dplyr::filter(productive_flag(productive))
  heavy <- prod %>% dplyr::filter(chain == "IGH")
  light <- prod %>% dplyr::filter(chain %in% c("IGK", "IGL"))
  heavy_sum <- heavy %>%
    dplyr::group_by(barcode) %>%
    dplyr::summarise(
      n_productive_igh = dplyr::n(),
      n_rearrangements = dplyr::n_distinct(paste(v_gene, j_gene, cdr3_nt)),
      n_c_genes = dplyr::n_distinct(c_gene),
      .groups = "drop"
    )
  # Highest reads, then UMIs, then contig id, so the chosen heavy chain is stable.
  selected_h <- heavy %>%
    dplyr::arrange(barcode, dplyr::desc(reads), dplyr::desc(umis), contig_id) %>%
    dplyr::group_by(barcode) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::transmute(
      barcode, sample_id, contig_id, v_gene, d_gene, j_gene, c_gene,
      cdr3_aa = cdr3, cdr3_nt, reads, umis, full_length
    )
  selected_l <- light %>%
    dplyr::arrange(barcode, dplyr::desc(reads), dplyr::desc(umis), contig_id) %>%
    dplyr::group_by(barcode) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::transmute(
      barcode,
      light_contig_id = contig_id,
      light_v = v_gene, light_j = j_gene, light_c = c_gene,
      light_cdr3_aa = cdr3, light_cdr3_nt = cdr3_nt, light_reads = reads
    )
  selected_h %>%
    dplyr::left_join(heavy_sum, by = "barcode") %>%
    dplyr::left_join(selected_l, by = "barcode") %>%
    dplyr::mutate(
      v_gene_use = single_ighv(v_gene),
      v_ambiguous = is.na(v_gene_use),
      v_orphon = grepl("/OR", v_gene, fixed = TRUE),
      isotype = factor(c_gene, levels = names(isotype_col)),
      isotype_group = isotype_group_of(c_gene),
      switched = switched_flag(isotype_group),
      paired_light = !is.na(light_contig_id) & !is.na(light_v) & light_v != "" &
        !is.na(light_j) & light_j != "" & aa_sequence_ok(light_cdr3_aa)
    )
}

add_clone_fields <- function(df) {
  df <- df %>%
    dplyr::mutate(
      clone_id = ifelse(
        !v_ambiguous & aa_sequence_ok(cdr3_aa),
        paste(sample_id, v_gene, cdr3_aa, sep = "|"),
        NA_character_
      ),
      clone_id_vj_nt = ifelse(
        !v_ambiguous & !is.na(j_gene) & !is.na(cdr3_nt) & cdr3_nt != "",
        paste(sample_id, v_gene, j_gene, cdr3_nt, sep = "|"),
        NA_character_
      ),
      clone_id_paired = ifelse(
        paired_light & !is.na(clone_id) & !is.na(j_gene) & j_gene != "",
        paste(sample_id, v_gene, j_gene, cdr3_aa, light_v, light_j, light_cdr3_aa, sep = "|"),
        NA_character_
      )
    )
  df %>%
    dplyr::add_count(sample_id, clone_id, name = "clone_size") %>%
    dplyr::add_count(sample_id, cell_subtype, clone_id, name = "subtype_clone_size") %>%
    dplyr::group_by(sample_id, isotype_group, clone_id) %>%
    dplyr::mutate(isotype_n = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      clone_size = ifelse(is.na(clone_id), NA_integer_, clone_size),
      subtype_clone_size = ifelse(is.na(clone_id), NA_integer_, subtype_clone_size),
      isotype_clone_size = ifelse(is.na(isotype_group) | is.na(clone_id), NA_integer_, isotype_n),
      expanded_repertoire = ifelse(is.na(clone_size), NA, clone_size >= 2),
      expanded_within_subtype = ifelse(is.na(subtype_clone_size), NA, subtype_clone_size >= 2),
      expanded_within_isotype = ifelse(
        is.na(isotype_clone_size), NA, isotype_clone_size >= 2
      )
    ) %>%
    dplyr::select(-isotype_n)
}

donor_clone_metrics <- function(df, key) {
  use <- df[!is.na(df[[key]]) & df[[key]] != "", , drop = FALSE]
  use$key <- use[[key]]
  sizes <- use %>% dplyr::count(sample_id, age_group, key, name = "n")
  sizes %>%
    dplyr::group_by(sample_id, age_group) %>%
    dplyr::summarise(
      n_bcr = sum(n),
      n_clones = dplyr::n(),
      expanded_frac = sum(n[n >= 2]) / sum(n),
      top10_frac = sum(utils::head(sort(n, decreasing = TRUE), 10)) / sum(n),
      shannon = shannon_div(n),
      .groups = "drop"
    )
}

rarefy_donor <- function(keys, depth, n_draws) {
  keys <- keys[!is.na(keys)]
  if (length(keys) < depth) return(NULL)
  draws <- replicate(n_draws, {
    sampled <- sample(keys, depth, replace = FALSE)
    tab <- as.numeric(table(sampled))
    p <- tab / depth
    c(
      expanded_frac = sum(tab[tab >= 2]) / depth,
      shannon = -sum(p * log(p)),
      top10_frac = sum(utils::head(sort(tab, decreasing = TRUE), 10)) / depth
    )
  })
  data.frame(
    expanded_frac = mean(draws["expanded_frac", ]),
    shannon = mean(draws["shannon", ]),
    top10_frac = mean(draws["top10_frac", ])
  )
}

v_usage_grid <- function(df, donor_ids, v_col = "v_gene", weight = c("cell", "clone")) {
  weight <- match.arg(weight)
  if (weight == "clone") {
    src <- df %>%
      dplyr::filter(!is.na(clone_id)) %>%
      dplyr::distinct(sample_id, clone_id, .data[[v_col]]) %>%
      dplyr::rename(v_gene = 3)
  } else {
    src <- df %>%
      dplyr::filter(!is.na(.data[[v_col]])) %>%
      dplyr::transmute(sample_id, v_gene = .data[[v_col]])
  }
  src <- src %>% dplyr::filter(sample_id %in% donor_ids, !is.na(v_gene))
  genes <- sort(unique(src$v_gene))
  if (length(genes) == 0) return(dplyr::tibble())
  grid <- tidyr::expand_grid(sample_id = donor_ids, v_gene = genes)
  totals <- src %>% dplyr::count(sample_id, name = "n_total")
  counts <- src %>% dplyr::count(sample_id, v_gene, name = "n")
  grid %>%
    dplyr::left_join(counts, by = c("sample_id", "v_gene")) %>%
    dplyr::left_join(totals, by = "sample_id") %>%
    dplyr::mutate(n = dplyr::coalesce(n, 0L), pct = 100 * n / n_total, weight = weight)
}

near_public_pairs <- function(df) {
  keys <- df %>%
    dplyr::filter(!v_ambiguous, aa_sequence_ok(cdr3_aa), nchar(cdr3_aa) >= 10) %>%
    dplyr::distinct(sample_id, v_gene, cdr3_aa)
  pairs <- list()
  for (v in unique(keys$v_gene)) {
    sub <- keys %>% dplyr::filter(v_gene == v)
    for (len in unique(nchar(sub$cdr3_aa))) {
      s <- sub %>% dplyr::filter(nchar(cdr3_aa) == len)
      seqs <- unique(s$cdr3_aa)
      if (length(seqs) < 2) next
      dist <- as.matrix(stringdist::stringdistmatrix(seqs, seqs, method = "hamming"))
      donor_map <- split(s$sample_id, s$cdr3_aa)
      idx <- which(dist == 1 & upper.tri(dist), arr.ind = TRUE)
      if (!nrow(idx)) next
      for (k in seq_len(nrow(idx))) {
        s1 <- seqs[idx[k, 1]]
        s2 <- seqs[idx[k, 2]]
        cross <- expand.grid(
          sample_1 = donor_map[[s1]], sample_2 = donor_map[[s2]],
          stringsAsFactors = FALSE
        )
        cross <- cross[cross$sample_1 != cross$sample_2, , drop = FALSE]
        if (!nrow(cross)) next
        # One unordered donor pair, keeping both sequence orientations collapsed.
        endpoint_1 <- paste(cross$sample_1, s1, sep = "|")
        endpoint_2 <- paste(cross$sample_2, s2, sep = "|")
        cross$pair_id <- paste(v, pmin(endpoint_1, endpoint_2), pmax(endpoint_1, endpoint_2), sep = "|")
        cross <- cross[!duplicated(cross$pair_id), , drop = FALSE]
        pairs[[length(pairs) + 1]] <- cross %>%
          dplyr::transmute(
            v_gene = v, cdr3_1 = s1, cdr3_2 = s2,
            sample_1, sample_2, hamming = 1L
          )
      }
    }
  }
  out <- dplyr::bind_rows(pairs)
  if (!nrow(out)) {
    out <- dplyr::tibble(
      v_gene = character(), cdr3_1 = character(), cdr3_2 = character(),
      sample_1 = character(), sample_2 = character(), hamming = integer()
    )
  }
  out
}

check_public_example <- function() {
  toy <- dplyr::tibble(
    sample_id = c("A", "B", "A"),
    v_gene = "IGHV1-2",
    cdr3_aa = c("CCCCCCCCCC", "CCCCCCCCCC", "CCCCCCCCCD"),
    v_ambiguous = FALSE
  )
  exact_donors <- toy %>%
    dplyr::distinct(v_gene, cdr3_aa, sample_id) %>%
    dplyr::count(v_gene, cdr3_aa, name = "n_donors")
  pairs <- near_public_pairs(toy)
  stopifnot(exact_donors$n_donors[exact_donors$cdr3_aa == "CCCCCCCCCC"] == 2)
  stopifnot(any(pairs$sample_1 == "B" & pairs$sample_2 == "A" |
                  pairs$sample_1 == "A" & pairs$sample_2 == "B"))
  stopifnot(!any(pairs$sample_1 == pairs$sample_2))
  invisible(TRUE)
}

check_isotype_expansion_case <- function() {
  toy <- dplyr::tibble(
    sample_id = "s", cell_subtype = "Memory B", v_ambiguous = FALSE,
    v_gene = "IGHV1-2", j_gene = "IGHJ4", cdr3_aa = "CARTESTTESTW", cdr3_nt = "TGT",
    isotype_group = c("IGHM", "IGHG"),
    paired_light = FALSE, light_v = NA, light_j = NA, light_cdr3_aa = NA
  )
  got <- add_clone_fields(toy)
  stopifnot(all(got$expanded_repertoire))
  stopifnot(all(!got$expanded_within_isotype))
  same <- dplyr::tibble(
    sample_id = "s", cell_subtype = "Memory B", v_ambiguous = FALSE,
    v_gene = "IGHV1-2", j_gene = "IGHJ4", cdr3_aa = "CARTESTTESTW", cdr3_nt = "TGT",
    isotype_group = c("IGHG", "IGHG"),
    paired_light = FALSE, light_v = NA, light_j = NA, light_cdr3_aa = NA
  )
  got2 <- add_clone_fields(same)
  stopifnot(all(got2$expanded_within_isotype))
  invisible(TRUE)
}
