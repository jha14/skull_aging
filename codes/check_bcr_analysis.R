# Validate the current analysis and the failure cases found in review.
# Rscript codes/check_bcr_analysis.R [--unit-only]
suppressPackageStartupMessages({library(dplyr); library(tidyr)})
source("codes/bcr_helpers.R")
checks <- list()
check <- function(name, ok) {
  if (!isTRUE(ok)) stop("Validation failed: ", name)
  checks[[length(checks) + 1L]] <<- data.frame(check = name, passed = TRUE)
}
same <- function(x, y) identical(as.character(x), as.character(y))

check_isotype_expansion_case()
check("one IgM plus one IgG is not within-isotype expansion", TRUE)
check_public_example()
check("shared sequence retains all donor endpoints", TRUE)
names_to_keep <- c("IGHV4-30-4", "IGHV1-69D", "IGHV7-4-1", "IGHV3/OR16-10", "IGHV1/OR15-1")
check("complete V names, including orphons, are preserved", same(single_ighv(names_to_keep), names_to_keep))
check("multiple V calls are not single genes", all(is.na(single_ighv(c("IGHV1-2,IGHV1-3", "IGHV1-2/IGHV1-3")))))
parsed_multi <- parse_reference_heavy_v("IGHV1-2*01,IGHV1-3*01")
parsed_human <- parse_reference_heavy_v("IGHV1-2 (Human)")
parsed_mouse <- parse_reference_heavy_v("IGHV1-2 (Mouse)")
check("multi-gene reference V is not collapsed to the first call", is.na(parsed_multi$match_gene) && parsed_multi$multi)
check("human and mouse receptor labels stay distinct",
  parsed_human$species == "Human" && parsed_mouse$species == "Mouse" &&
    parsed_human$match_gene == "IGHV1-2" && is.na(parsed_mouse$match_gene))
check("legal extra V-gene numbering is preserved",
  parse_reference_heavy_v("IGHV4-30-4*01 (Human)")$match_gene == "IGHV4-30-4")
check("unknown constant gene remains unknown", is.na(switched_flag(isotype_group_of(NA_character_))))
check("D gene cannot change the selected constant gene", isotype_group_of("IGHM") == "IGHM")

toy <- tibble(sample_id = "s", cell_subtype = "Memory B", v_ambiguous = FALSE,
  v_gene = "IGHV1-2", j_gene = "IGHJ4", cdr3_aa = "CAAAAAAAAW",
  cdr3_nt = c("TGTGCTGCTGCTGCTGCTGCTGCTGCTTGG", "TGCGCTGCTGCTGCTGCTGCTGCTGCTTGG"),
  isotype_group = "IGHG", paired_light = TRUE, light_v = "IGKV1-1",
  light_j = "IGKJ1", light_cdr3_aa = "CQQQQQQF")
got <- add_clone_fields(toy)
check("paired amino-acid key does not split synonymous heavy junctions",
  n_distinct(got$clone_id_paired) == 1L && n_distinct(got$clone_id_vj_nt) == 2L)

dup <- data.frame(sample_id = c("A", "A"), age_group = c("Young", "Young"), value = 1:2)
check("repeated donor rows cannot enter an age test",
  inherits(try(wilcox_age(dup, "value", "duplicate example", "unit"), silent = TRUE), "try-error"))
vg <- tibble(sample_id = c("A", "B", "B"), v_gene = c("IGHV1-2", "IGHV1-2", "IGHV1-3"))
grid <- v_usage_grid(vg, c("A", "B"), weight = "cell")
check("unobserved V gene contributes a real zero", grid$pct[grid$sample_id == "A" & grid$v_gene == "IGHV1-3"] == 0)

edges <- near_public_pairs(tibble(sample_id = c("A", "B", "A", "B"), v_gene = "IGHV1-2",
  cdr3_aa = c("CCCCCCCCCC", "CCCCCCCCCC", "CCCCCCCCCD", "CCCCCCCCCD"), v_ambiguous = FALSE))
check("distinct cross-donor sequence endpoints are not collapsed", nrow(edges) == 2L)
check("invalid amino acids are not deleted to manufacture a match", query_cdr3_keys("CAAAA?AAAW")$cdr3_invalid)
check("unsupported junction boundaries do not become canonical CDR3", is.na(query_cdr3_keys("AAAAAAA")$cdr3_core))
ref_file <- tempfile(fileext = ".csv")
writeLines(c('Name,Binds to,Heavy V Gene,CDRH3', 'test,target,IGHV1-2,CQQQQQQW'), ref_file)
check("reference terminal C/W residues are retained", read_local_antigen_reference(ref_file)$data$CDRH3 == "CQQQQQQW")
writeLines(c('Name,Binds to,Heavy V Gene,CDRH3', 'test,target,IGHV1-2,"CQQQQQQW'), ref_file)
check("truncated reference is unavailable, not a zero-hit reference", is.null(read_local_antigen_reference(ref_file)$data))
unlink(ref_file)
if ("--unit-only" %in% commandArgs(trailingOnly = TRUE)) {
  print(bind_rows(checks)); quit(status = 0)
}

a <- readRDS("results/bcr/rdata/bcr_cells.rds")
si <- readr::read_csv("codes/sample_info.csv", show_col_types = FALSE)
check("one row per analysed cell", !anyDuplicated(a$barcode))
check("Non-B cells are excluded before clone counting", all(a$lineage != "Non-B"))
raw <- bind_rows(lapply(si$sample_id, function(s) {
  p <- file.path("data/cell_ranger_multi", s, "outs/per_sample_outs", s, "vdj_b/filtered_contig_annotations.csv")
  readr::read_csv(p, show_col_types = FALSE,
    col_types = readr::cols(.default = readr::col_character(), reads = readr::col_double(), umis = readr::col_double())) %>%
    mutate(sample_id = s, barcode = paste0(s, "_", barcode))
}))
heavy <- raw[raw$chain == "IGH" & toupper(raw$productive) %in% c("TRUE", "T"), ]
heavy <- heavy[order(heavy$barcode, -heavy$reads, -heavy$umis, heavy$contig_id, na.last = TRUE), ]
picked <- heavy[!duplicated(heavy$barcode), ]
idx <- match(a$barcode, picked$barcode)
check("every selected heavy chain is present in raw annotations", !anyNA(idx))
for (field in c("sample_id", "contig_id", "v_gene", "d_gene", "j_gene", "c_gene", "cdr3_nt")) {
  check(paste("raw contig agrees:", field), same(a[[field]], picked[[field]][idx]))
}
check("heavy-chain amino acid sequence agrees with raw contig", same(a$cdr3_aa, picked$cdr3[idx]))
check("isotype group agrees with raw constant gene", same(a$isotype_group, isotype_group_of(picked$c_gene[idx])))
count_within <- function(fields, valid) {
  key <- do.call(paste, c(a[fields], sep = "|"))
  n <- rep(NA_integer_, nrow(a))
  counts <- table(key[valid])
  n[valid] <- as.integer(counts[key[valid]])
  n
}
valid <- !is.na(a$clone_id)
expected <- count_within(c("sample_id", "clone_id"), valid)
expected_sub <- count_within(c("sample_id", "cell_subtype", "clone_id"), valid)
expected_iso <- count_within(c("sample_id", "isotype_group", "clone_id"), valid & !is.na(a$isotype_group))
check("clone sizes use exactly the retained B-lineage cells", same(a$clone_size, expected))
check("subtype clone sizes use the correct scope", same(a$subtype_clone_size, expected_sub))
check("isotype clone sizes use the correct scope", same(a$isotype_clone_size, expected_iso))
check("global expansion flags agree with retained clone sizes", same(a$expanded_repertoire, expected >= 2))
check("isotype expansion flags agree with isotype clone sizes", same(a$expanded_within_isotype, expected_iso >= 2))
check("Gini-Simpson is zero for one clone and one half for two equal clones",
  gini_simpson(rep("a", 8)) == 0 && abs(gini_simpson(rep(c("a", "b"), each = 4)) - 0.5) < 1e-12)
even <- startrac_indices(c("a", "b", "c", "d"), rep("Naive B", 4))
single <- startrac_indices(rep("a", 6), rep("Plasma", 6))
check("STARTRAC expansion is zero for equal clones and undefined for one clone",
  abs(even$expa) < 1e-12 && even$tran == 0 && is.na(single$expa) && single$tran == 0)
tests <- openxlsx::read.xlsx("results/bcr/tables/age_tests.xlsx", sheet = "tests")
check("sampling-depth tests are not part of the delivered comparison", !any(tests$family == "rarefaction"))
check("no test exceeds the available donor count",
  all(tests$n_young <= sum(si$age_group == "Young")) && all(tests$n_old <= sum(si$age_group == "Old")))
top <- openxlsx::read.xlsx("results/bcr/tables/top_clones.xlsx")
check("top-clone table contains one row per donor and clone", !anyDuplicated(top[c("sample_id", "clone_id")]))
check("truncated CoV-AbDab copy remains unusable",
  is.null(read_local_antigen_reference("data/reference/provenance/CoV-AbDab_080224.truncated.csv")$data))
check("excluded donors are absent from the analysed cells",
  !any(a$sample_id %in% c("LXY_SkullBM_240412", "ZFR_SkullBM_240315")))
obj <- readRDS("results/bcr/rdata/b_lineage_with_bcr.rds")
idx <- match(a$barcode, colnames(obj))
check("every analysed cell is present in the saved Seurat object", !anyNA(idx))
for (field in c("contig_id", "isotype", "isotype_group", "switched", "clone_id", "clone_size",
                "subtype_clone_size", "isotype_clone_size", "mu_percent")) {
  check(paste("saved Seurat metadata agrees:", field), same(a[[field]], obj@meta.data[[field]][idx]))
}
check("the SHM caches were preserved", all(file.exists(file.path("results/bcr/shm", si$sample_id, "shm_result_db-pass.tsv"))))
bins <- openxlsx::read.xlsx("results/bcr/tables/clone_size_bins.xlsx", sheet = "by_donor")
bin_sum <- tapply(bins$pct, bins$sample_id, sum)
check("every donor clone-size bar sums to 100", all(abs(bin_sum - 100) < 1e-6))
if ("WLR220308_Z" %in% bins$sample_id) {
  wlr <- bins[bins$sample_id == "WLR220308_Z" & bins$clone_bin == "= 1", ]
  check("WLR220308_Z keeps the clone-size 1 segment", nrow(wlr) == 1 && wlr$pct > 60)
} else {
  check("WLR220308_Z is excluded from this cohort", TRUE)
}
label_numbers <- function(x) as.integer(sub("^[YO]", "", unique(x)))
check("donor labels follow numeric order",
  !is.unsorted(label_numbers(bins$donor_label[bins$age_group == "Young"])) &&
    !is.unsorted(label_numbers(bins$donor_label[bins$age_group == "Old"])))
rec <- openxlsx::read.xlsx("results/bcr/tables/fig_03_recovery.xlsx", sheet = "plot_data")
comp <- openxlsx::read.xlsx("results/bcr/tables/fig_04_composition.xlsx", sheet = "plot_data")
check("recovery and composition tables keep donor labels",
  "donor_label" %in% names(rec) && "donor_label" %in% names(comp))

# Check the exported graphics against independent cell coordinates and the final tests.
umap_data <- openxlsx::read.xlsx("results/bcr/tables/fig_02_umap.xlsx", sheet = "plot_data")
coordinates <- obj[["umap"]]@cell.embeddings
coord_idx <- match(umap_data$barcode, rownames(coordinates))
check("UMAP export contains each cell exactly once",
  !anyDuplicated(umap_data$barcode) && !anyNA(coord_idx) && nrow(umap_data) == nrow(coordinates))
check("UMAP coordinates agree with the saved embedding",
  isTRUE(all.equal(as.matrix(umap_data[c("UMAP_1", "UMAP_2")]),
    unname(coordinates[coord_idx, 1:2]), check.attributes = FALSE, tolerance = 1e-12)))
display <- readr::read_csv("results/bcr/tables/umap_display_audit.csv", show_col_types = FALSE)
check("all five UMAP panels use square coordinate ranges",
  nrow(display) == 5 && all(abs((display$x_max - display$x_min) - (display$y_max - display$y_min)) < 1e-10) &&
    all(display$coordinate_ratio == 1))
check("UMAP panels share limits and keep circular points",
  nrow(unique(display[c("x_min", "x_max", "y_min", "y_max")])) == 1 && all(display$point_shape == 19))
ann <- readr::read_csv("results/bcr/tables/figure_stat_annotations.csv",
  col_types = readr::cols(.default = readr::col_guess(), figure_id = readr::col_character()))
ann_idx <- match(ann$test_id, tests$test_id)
check("all comparative figures have traceable test annotations",
  !anyNA(ann_idx) && !anyDuplicated(ann[c("figure_id", "test_id")]) &&
    setequal(unique(ann$figure_id), c("05", "05s", "06", "07", "07s", "09", "10", "11", "12", "13", "14", "16", "17", "22", "23", "24", "25", "26", "27")))
tested <- !is.na(tests$p_value)
check("age tests record the chosen test method",
  all(tests$test_method[tested] %in% c("Welch t-test", "Wilcoxon")))
for (field in c("p_value", "n_young", "n_old")) {
  check(paste("figure annotations agree with final tests:", field),
    isTRUE(all.equal(ann[[field]], tests[[field]][ann_idx], check.attributes = FALSE, tolerance = 1e-12)))
}
check("all nine subtype proportions have age tests",
  sum(ann$figure_id %in% c("05", "05s")) == 9 && all(!is.na(ann$p_value[ann$figure_id %in% c("05", "05s")])))
figure_map <- openxlsx::read.xlsx("results/bcr/tables/figure_table_map.xlsx")
figure_map$figure_id <- as.character(figure_map$figure_id)
for (id in unique(ann$figure_id)) {
  file <- figure_map$workbook[match(id, figure_map$figure_id)]
  figure_stats <- openxlsx::read.xlsx(file.path("results/bcr/tables", file), sheet = "statistics")
  check(paste("figure workbook contains its displayed tests:", id),
    setequal(figure_stats$test_id, ann$test_id[ann$figure_id == id]))
}
out <- bind_rows(checks)
readr::write_csv(out, "results/bcr/tables/validation_checks.csv")
paths <- list.files("results/bcr", full.names = TRUE, recursive = TRUE)
paths <- paths[basename(paths) != "file_manifest.xlsx"]
openxlsx::write.xlsx(data.frame(path = normalizePath(paths), bytes = file.info(paths)$size),
  "results/bcr/tables/file_manifest.xlsx", overwrite = TRUE)
cat("All", nrow(out), "checks passed.\n")
cat("Cells:", nrow(a), "; IgD:", sum(a$c_gene == "IGHD", na.rm = TRUE), "; SHM:", sum(!is.na(a$mu_percent)), "\n")
