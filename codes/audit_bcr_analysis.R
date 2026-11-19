# Historical pre-delivery audit; reads the preserved initial baseline.
# Run from the project root: Rscript codes/audit_bcr_analysis.R
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(Seurat)
  library(ggplot2)
})
options(dplyr.summarise.inform = FALSE)
args <- commandArgs(trailingOnly = TRUE)
project_dir <- normalizePath(if (length(args)) args[[1]] else ".")
setwd(project_dir)
out_dir <- file.path(project_dir, "results/bcr_review")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(out_dir, "tables"), showWarnings = FALSE)
write_tab <- function(x, name) {
  write_csv(x, file.path(out_dir, "tables", paste0(name, ".csv")), na = "")
  x
}
flag <- function(x) toupper(as.character(x)) %in% c("TRUE", "T")
iso_group <- function(x) case_when(
  x %in% c("IGHA1", "IGHA2") ~ "IGHA",
  x %in% paste0("IGHG", 1:4) ~ "IGHG",
  x %in% c("IGHM", "IGHD", "IGHE") ~ x,
  TRUE ~ NA_character_
)
switched <- function(x) x %in% c("IGHA", "IGHG", "IGHE")
age_test <- function(d, value, metric, family) {
  stopifnot(!anyDuplicated(d$sample_id))
  d <- d[is.finite(d[[value]]) & !is.na(d$age_group), ]
  y <- d[[value]][d$age_group == "Young"]
  o <- d[[value]][d$age_group == "Old"]
  enough <- length(y) >= 3 && length(o) >= 3
  variable <- length(unique(c(y, o))) > 1
  tibble(family, metric, n_young = length(y), n_old = length(o),
         median_young = if (length(y)) median(y) else NA_real_,
         median_old = if (length(o)) median(o) else NA_real_,
         old_minus_young = if (length(y) && length(o)) median(o) - median(y) else NA_real_,
         p_value = if (enough && variable) suppressWarnings(wilcox.test(y, o, exact = FALSE)$p.value) else NA_real_)
}
adjust_tests <- function(d) d %>% group_by(family) %>%
  mutate(fdr = p.adjust(p_value, "BH")) %>% ungroup()
clone_metrics <- function(d, key, definition, compartment) {
  d %>% count(sample_id, age_group, clone = .data[[key]], name = "size") %>%
    group_by(sample_id, age_group) %>%
    summarise(n_bcr = sum(size), n_clones = n(),
              expanded_frac = sum(size[size >= 2]) / sum(size),
              top10_frac = sum(head(sort(size, decreasing = TRUE), 10)) / sum(size),
              shannon = -sum((size / sum(size)) * log(size / sum(size))),
              inv_simpson = 1 / sum((size / sum(size))^2), .groups = "drop") %>%
    mutate(definition, compartment)
}

message("Reading original B-lineage object and saved BCR cells")
sample_info <- read_csv("codes/sample_info.csv", show_col_types = FALSE) %>%
  mutate(aneurysm = grepl("aneurysm", notes, ignore.case = TRUE))
map <- read_csv("codes/cluster_lineage.csv", show_col_types = FALSE) %>%
  mutate(cluster = as.character(cluster))
b <- readRDS("results/bcr_review/baseline/results/bcr/rdata/bcr_cells.rds") %>%
  mutate(across(c(age_group, cell_subtype, lineage, compare_group, isotype, isotype_group), as.character))
obj <- readRDS("data/scRNA_harmony_luguB_quan.rds")
meta <- obj@meta.data %>% tibble::rownames_to_column("barcode") %>%
  mutate(sample_id = as.character(sample_id), cluster = as.character(seurat_clusters)) %>%
  left_join(map, by = "cluster") %>%
  left_join(sample_info %>% select(sample_id, age_group), by = "sample_id")
stopifnot(!anyDuplicated(sample_info$sample_id), !anyDuplicated(map$cluster),
          !anyDuplicated(b$barcode), setequal(sample_info$sample_id, meta$sample_id),
          all(b$barcode %in% meta$barcode), !anyNA(meta$cell_subtype),
          all(b$sample_id == meta$sample_id[match(b$barcode, meta$barcode)]),
          all(b$age_group == meta$age_group[match(b$barcode, meta$barcode)]))
original_tests <- openxlsx::read.xlsx("results/bcr_review/baseline/results/bcr/tables/age_tests.xlsx")

message("Validating selected heavy chains against the raw 10x columns")
raw <- bind_rows(lapply(sample_info$sample_id, function(s) {
  p <- file.path("data/cell_ranger_multi", s, "outs/per_sample_outs", s,
                 "vdj_b/filtered_contig_annotations.csv")
  read_csv(p, show_col_types = FALSE,
           col_types = cols(.default = col_character(), reads = col_double(), umis = col_double())) %>%
    mutate(sample_id = s, barcode = paste0(s, "_", barcode))
}))
heavy <- raw %>% filter(chain == "IGH", flag(productive))
heavy_n <- heavy %>% count(barcode, name = "n_productive_igh")
selected <- heavy %>% arrange(desc(reads)) %>% distinct(barcode, .keep_all = TRUE) %>%
  transmute(barcode, raw_contig_id = contig_id, raw_v = v_gene, raw_j = j_gene,
            raw_c = c_gene, raw_cdr3_nt = cdr3_nt, raw_cdr3_aa = cdr3,
            raw_full_length = full_length, raw_reads = reads, raw_umis = umis)
c <- b %>% left_join(selected, by = "barcode", relationship = "one-to-one") %>%
  left_join(heavy_n, by = "barcode") %>%
  mutate(correct_isotype_group = iso_group(raw_c),
         valid_light = !is.na(cdr3_aa2) & cdr3_aa2 != "" & !is.na(IGLC),
         corrected_h_aa = paste(sample_id, raw_v, cdr3_aa, sep = "|"),
         corrected_h_vj_nt = paste(sample_id, raw_v, raw_j, cdr3_nt, sep = "|"),
         corrected_pair_aa = if_else(valid_light,
           paste(sample_id, raw_v, raw_j, cdr3_aa, IGLC, cdr3_aa2, sep = "|"), NA_character_))
stopifnot(!anyNA(c$raw_contig_id), all(c$cdr3_nt == c$raw_cdr3_nt),
          all(c$cdr3_aa == c$raw_cdr3_aa),
          all(sub("\\..*", "", c$IGH) == c$raw_v))
isotype_confusion <- c %>% count(original = c_gene, corrected = raw_c, name = "n_cells")
v_confusion <- c %>% filter(v_gene != raw_v) %>% count(original = v_gene, corrected = raw_v, name = "n_cells")
audit_counts <- tibble(
  item = c("gex_b_subset", "saved_bcr_cells", "donors", "wrong_known_isotype", "missing_c_mislabeled", "wrong_v_gene",
           "original_igd", "correct_igd", "isotype_switched_to_igd", "multi_igh_in_bcr", "missing_shm",
           "precursor_bcr", "bcr_with_paired_light"),
  n = c(ncol(obj), nrow(b), n_distinct(b$sample_id),
        sum(c$c_gene != c$raw_c, na.rm = TRUE), sum(is.na(c$raw_c) & !is.na(c$c_gene)),
        sum(c$v_gene != c$raw_v, na.rm = TRUE),
        sum(c$c_gene == "IGHD", na.rm = TRUE), sum(c$raw_c == "IGHD", na.rm = TRUE),
        sum(c$c_gene == "IGHD" & switched(c$correct_isotype_group), na.rm = TRUE),
        sum(c$n_productive_igh > 1), sum(is.na(b$mu_percent)), sum(b$lineage == "Precursor"),
        sum(c$valid_light)))
isotype_donor <- c %>% group_by(sample_id, age_group) %>% summarise(
  n_bcr = n(), n_known_original = sum(!is.na(isotype_group)),
  n_known_corrected = sum(!is.na(correct_isotype_group)),
  old_igd = mean(isotype_group == "IGHD", na.rm = TRUE),
  correct_igd = mean(correct_isotype_group == "IGHD", na.rm = TRUE),
  old_switched = mean(switched(isotype_group[!is.na(isotype_group)])),
  correct_switched = mean(switched(correct_isotype_group[!is.na(correct_isotype_group)])),
  .groups = "drop")
recovery <- meta %>% filter(lineage != "Non-B") %>% count(sample_id, age_group, cell_subtype, lineage, name = "n_gex") %>%
  left_join(c %>% count(sample_id, cell_subtype, name = "n_bcr"), by = c("sample_id", "cell_subtype")) %>%
  mutate(n_bcr = replace_na(n_bcr, 0L), recovery = n_bcr / n_gex)
paired <- c %>% group_by(cell_subtype, lineage) %>%
  summarise(n_bcr = n(), paired_frac = mean(valid_light), multi_igh = sum(n_productive_igh > 1), .groups = "drop")

message("Checking cell annotations with an expanded marker panel")
markers <- intersect(c("CD34", "DNTT", "RAG1", "RAG2", "VPREB1", "IGLL1", "MME", "MKI67", "TOP2A",
  "TCL1A", "MS4A1", "CD19", "FCER2", "IGHD", "IGHM", "CD24", "CD38", "CD27", "TNFRSF13B",
  "FCRL5", "ITGAX", "TBX21", "XBP1", "MZB1", "JCHAIN", "PRDM1", "SDC1", "CD3D", "CD3E", "NKG7"), rownames(obj))
x <- GetAssayData(obj, assay = "RNA", layer = "data")[markers, , drop = FALSE]
marker_summary <- bind_rows(lapply(unique(meta$cluster), function(k) {
  idx <- which(meta$cluster == k)
  tibble(cluster = k, cell_subtype = meta$cell_subtype[idx[1]], gene = markers,
         pct_positive = 100 * Matrix::rowMeans(x[, idx, drop = FALSE] > 0),
         mean_log_expression = Matrix::rowMeans(x[, idx, drop = FALSE]), n_cells = length(idx))
}))
cluster_donor <- meta %>% count(cluster, cell_subtype, sample_id, age_group, name = "n")
cluster_balance <- cluster_donor %>% group_by(cluster, cell_subtype) %>%
  summarise(n_cells = sum(n), n_donors = n_distinct(sample_id), top_donor_fraction = max(n) / sum(n),
            .groups = "drop")
rm(obj, x); gc(FALSE)

message("Comparing clone definitions and compartments")
definitions <- c(original_h_aa = "clone_id", corrected_h_aa = "corrected_h_aa", heavy_vj_nt = "corrected_h_vj_nt", paired_vj_aa = "corrected_pair_aa")
compartments <- c("All", "Mature B + Plasma", "Naive B", "Memory B", "Plasma")
clone_sensitivity <- bind_rows(lapply(compartments, function(comp) {
  d <- switch(comp, All = c, `Mature B + Plasma` = filter(c, lineage != "Precursor"), filter(c, cell_subtype == comp))
  bind_rows(lapply(names(definitions), function(def) {
    dd <- filter(d, !is.na(.data[[definitions[[def]]]]))
    clone_metrics(dd, definitions[[def]], def, comp)
  }))
}))
clone_tests <- bind_rows(lapply(split(clone_sensitivity, interaction(clone_sensitivity$definition, clone_sensitivity$compartment, drop = TRUE)), function(d) {
  comp <- d$compartment[1]; def <- d$definition[1]
  minimum <- if (comp %in% c("All", "Mature B + Plasma")) 30 else 10
  d <- filter(d, n_bcr >= minimum)
  bind_rows(lapply(c("expanded_frac", "top10_frac", "shannon", "inv_simpson"), function(m) {
    age_test(d, m, paste(comp, def, m, sep = "; "), "clone_sensitivity")
  }))
})) %>% adjust_tests()
clone_v_collisions <- c %>% group_by(clone_id) %>%
  summarise(n = n(), n_full_v = n_distinct(raw_v), n_j = n_distinct(raw_j),
            n_nt = n_distinct(cdr3_nt), n_light = n_distinct(paste(IGLC[valid_light], cdr3_aa2[valid_light])), .groups = "drop") %>%
  filter(n_full_v > 1 | n_j > 1 | n_nt > 1 | n_light > 1)

# Standardize cell sampling within each compartment; no cells cross donors.
message("Repeated rarefaction (200 draws, 100 cells per donor and compartment)")
set.seed(20261114)
rarefaction <- bind_rows(lapply(c("Mature B + Plasma", "Naive B", "Memory B", "Plasma"), function(comp) {
  d <- if (comp == "Mature B + Plasma") filter(c, lineage != "Precursor") else filter(c, cell_subtype == comp)
  bind_rows(lapply(split(d, d$sample_id), function(s) {
    if (nrow(s) < 100) return(NULL)
    draws <- replicate(200, {
      counts <- table(sample(s$corrected_h_aa, 100, replace = FALSE))
      p <- as.numeric(counts) / 100
      c(expanded_frac = sum(counts[counts >= 2]) / 100, shannon = -sum(p * log(p)),
        inv_simpson = 1 / sum(p^2), top10_frac = sum(head(sort(counts, decreasing = TRUE), 10)) / 100)
    })
    tibble(sample_id = s$sample_id[1], age_group = s$age_group[1], compartment = comp,
      n_available = nrow(s), depth = 100L, n_draws = 200L,
      expanded_frac = mean(draws["expanded_frac", ]), expanded_sd = sd(draws["expanded_frac", ]),
      shannon = mean(draws["shannon", ]), inv_simpson = mean(draws["inv_simpson", ]), top10_frac = mean(draws["top10_frac", ]))
  }))
}))
rarefaction_tests <- bind_rows(lapply(split(rarefaction, rarefaction$compartment), function(d) {
  bind_rows(lapply(c("expanded_frac", "shannon", "inv_simpson", "top10_frac"), function(m) {
    age_test(d, m, paste(d$compartment[1], m, sep = "; "), "rarefaction")
  }))
})) %>% adjust_tests()

message("Recomputing SHM with the existing IMGT-aligned references, without a fallback")
db <- bind_rows(lapply(sample_info$sample_id, function(s) {
  read_tsv(file.path("results/bcr/shm", s, "shm_result_db-pass.tsv"), show_col_types = FALSE) %>%
    mutate(sample_id = s, barcode = paste0(s, "_", cell_id))
}))
db_heavy <- db %>% filter(locus == "IGH", flag(productive))
db_valid <- db_heavy %>% filter(!is.na(sequence_alignment), !is.na(germline_alignment),
       nchar(sequence_alignment) > 0, nchar(sequence_alignment) == nchar(germline_alignment))
db_multiple <- db_valid %>% count(barcode) %>% filter(n > 1)
sh <- db_valid %>% filter(!barcode %in% db_multiple$barcode, barcode %in% c$barcode)
sh <- shazam::observedMutations(sh, sequenceColumn = "sequence_alignment",
  germlineColumn = "germline_alignment", regionDefinition = shazam::IMGT_V,
  frequency = TRUE, combine = TRUE, nproc = 1) %>%
  mutate(recomputed_mu_percent = 100 * mu_freq,
         callable_bases_approx = mapply(function(a, g) {
           aa <- strsplit(substr(a, 1, 312), "")[[1]]; gg <- strsplit(substr(g, 1, 312), "")[[1]]
           sum(aa %in% c("A", "T", "C", "G") & gg %in% c("A", "T", "C", "G"))
         }, sequence_alignment, germline_alignment))
shm_validation <- c %>% left_join(sh %>% select(barcode, recomputed_mu_percent, junction_10x,
  junction_10x_aa, v_germline_start, v_germline_end, callable_bases_approx), by = "barcode") %>%
  mutate(shm_delta = recomputed_mu_percent - mu_percent,
         same_shm_contig = cdr3_nt == junction_10x)
stopifnot(all(abs(shm_validation$shm_delta) < 1e-8, na.rm = TRUE))
shm_qc <- shm_validation %>% group_by(sample_id, age_group, cell_subtype) %>%
  summarise(n_bcr = n(), n_shm = sum(!is.na(recomputed_mu_percent)),
    n_missing_shm = sum(is.na(recomputed_mu_percent)), n_sequence_mismatch = sum(!same_shm_contig, na.rm = TRUE),
    median_callable_bases = median(callable_bases_approx, na.rm = TRUE),
    median_mu = median(recomputed_mu_percent, na.rm = TRUE), .groups = "drop")
shm_clone <- shm_validation %>% filter(!is.na(recomputed_mu_percent)) %>%
  group_by(sample_id, age_group, cell_subtype, corrected_h_aa) %>%
  summarise(clone_mu = median(recomputed_mu_percent), n_cells = n(), .groups = "drop") %>%
  group_by(sample_id, age_group, cell_subtype) %>%
  summarise(n_clones = n(), n_cells = sum(n_cells), median_clone_mu = median(clone_mu), .groups = "drop")
shm_tests <- bind_rows(lapply(unique(c$cell_subtype), function(st) {
  a <- filter(shm_qc, cell_subtype == st, n_shm >= 10)
  z <- filter(shm_clone, cell_subtype == st, n_cells >= 10, n_clones >= 10)
  bind_rows(age_test(a, "median_mu", paste("Cell-weighted SHM", st, sep = "; "), "shm_cells"),
            age_test(z, "median_clone_mu", paste("Clone-balanced SHM", st, sep = "; "), "shm_clones"))
})) %>% adjust_tests()
memory_shm_isotype <- shm_validation %>%
  filter(cell_subtype == "Memory B", !is.na(recomputed_mu_percent), !is.na(correct_isotype_group)) %>%
  group_by(sample_id, age_group, correct_isotype_group) %>%
  summarise(n_shm = n(), median_mu = median(recomputed_mu_percent), .groups = "drop")
memory_isotype_tests <- bind_rows(lapply(c("IGHM", "IGHG", "IGHA"), function(ig) {
  age_test(filter(memory_shm_isotype, correct_isotype_group == ig, n_shm >= 10),
           "median_mu", paste("Memory SHM within", ig), "memory_shm_by_isotype")
})) %>% adjust_tests()

message("Checking within-isotype expansion and corrected class switching")
iso_cells <- c %>% filter(!is.na(correct_isotype_group)) %>%
  add_count(sample_id, correct_isotype_group, corrected_h_aa, name = "within_isotype_clone_n") %>%
  add_count(sample_id, corrected_h_aa, name = "whole_clone_n")
iso_expansion <- iso_cells %>% group_by(sample_id, age_group, correct_isotype_group) %>%
  summarise(n_bcr = n(), within_isotype_expanded = mean(within_isotype_clone_n >= 2),
            globally_expanded = mean(whole_clone_n >= 2), .groups = "drop")
switch_sensitivity <- c %>% group_by(sample_id, age_group, cell_subtype) %>%
  summarise(n_bcr = n(), n_known = sum(!is.na(correct_isotype_group)),
            old_switched = mean(switched(isotype_group[!is.na(isotype_group)])),
            corrected_switched = mean(switched(correct_isotype_group[!is.na(correct_isotype_group)])),
            .groups = "drop")

message("Recomputing corrected isotype and zero-completed IGHV tests")
iso_tests <- list()
donors <- c %>% count(sample_id, age_group, name = "n_bcr") %>% filter(n_bcr >= 30)
iso_tests[[1]] <- age_test(filter(isotype_donor, n_bcr >= 30), "correct_switched", "Class-switched fraction", "isotype")
for (iso in c("IGHM", "IGHD", "IGHA", "IGHG")) {
  one <- iso_cells %>% count(sample_id, correct_isotype_group, name = "n") %>%
    group_by(sample_id) %>% mutate(fraction = n / sum(n)) %>% ungroup() %>%
    filter(correct_isotype_group == iso)
  z <- donors %>% left_join(select(one, sample_id, fraction), by = "sample_id") %>% mutate(fraction = replace_na(fraction, 0))
  iso_tests[[length(iso_tests)+1]] <- age_test(z, "fraction", paste(iso, "fraction"), "isotype")
}
for (iso in c("IGHM", "IGHA", "IGHG")) {
  z <- filter(iso_expansion, correct_isotype_group == iso, n_bcr >= 10)
  iso_tests[[length(iso_tests)+1]] <- age_test(z, "within_isotype_expanded", paste("Expanded fraction within", iso), "isotype")
}
for (st in unique(c$cell_subtype)) {
  z <- filter(switch_sensitivity, cell_subtype == st, n_bcr >= 10)
  iso_tests[[length(iso_tests)+1]] <- age_test(z, "corrected_switched", paste("Class-switched fraction,", st), "isotype")
  for (iso in c(IGHG = "ighg_frac", IGHA = "igha_frac", IGHM = "ighm_frac")) {
    ig <- names(c(IGHG = "ighg_frac", IGHA = "igha_frac", IGHM = "ighm_frac"))[match(iso, c(IGHG = "ighg_frac", IGHA = "igha_frac", IGHM = "ighm_frac"))]
    z2 <- c %>% filter(cell_subtype == st, !is.na(correct_isotype_group)) %>%
      group_by(sample_id, age_group) %>% summarise(n_bcr = n(), fraction = mean(correct_isotype_group == ig), .groups = "drop") %>% filter(n_bcr >= 10)
    iso_tests[[length(iso_tests)+1]] <- age_test(z2, "fraction", paste0(ig, " fraction, ", st), "isotype")
  }
}
iso_tests <- bind_rows(iso_tests) %>% adjust_tests()
v_usage <- c %>% count(sample_id, raw_v, name = "n") %>%
  complete(sample_id = sample_info$sample_id, raw_v, fill = list(n = 0L)) %>%
  group_by(sample_id) %>% mutate(pct = 100 * n / sum(n)) %>% ungroup() %>%
  left_join(select(sample_info, sample_id, age_group), by = "sample_id")
v_mean <- v_usage %>% group_by(raw_v) %>% summarise(mean_pct = mean(pct), .groups = "drop")
v_tests <- bind_rows(lapply(filter(v_mean, mean_pct >= 1)$raw_v, function(v) {
  age_test(filter(v_usage, raw_v == v, sample_id %in% donors$sample_id), "pct", paste("IGHV usage,", v), "gene_usage")
})) %>% adjust_tests()

message("Testing potential disease confounding and leave-one-donor sensitivity")
design <- sample_info %>% count(age_group, aneurysm, sex, name = "n_donors")
sequencing_qc <- bind_rows(lapply(sample_info$sample_id, function(s) {
  p <- file.path("data/cell_ranger_multi", s, "outs/per_sample_outs", s, "metrics_summary.csv")
  z <- read_csv(p, col_types = cols(.default = col_character()), show_col_types = FALSE) %>%
    filter(`Library Type` == "VDJ B") %>%
    select(`Metric Name`, `Metric Value`) %>% distinct()
  get_metric <- function(n) {
    v <- z$`Metric Value`[z$`Metric Name` %in% n]
    if (length(v)) v[[1]] else NA_character_
  }
  version <- jsonlite::fromJSON(file.path("data/cell_ranger_multi", s, "_versions"))$pipelines
  tibble(sample_id = s, cellranger = version,
    vdj_cells = parse_number(get_metric(c("VDJ cells", "VDJ Cells"))),
    mean_reads_per_vdj_cell = parse_number(get_metric("Mean reads per cell")),
    mapped_vdj_pct = parse_number(get_metric("Reads mapped to any V(D)J gene")),
    productive_pair_pct = parse_number(get_metric("Cells with productive V-J spanning pair")))
})) %>% left_join(select(sample_info, sample_id, age_group), by = "sample_id")
full_obj <- readRDS("data/scRNA_harmony_luguquan.rds")
full_meta <- full_obj@meta.data
full_subset_qc <- full_meta %>% tibble::rownames_to_column("barcode") %>%
  group_by(sample_id) %>% summarise(n_full_gex = n(), n_in_b_subset = sum(barcode %in% meta$barcode),
    n_full_with_igh = sum(barcode %in% heavy$barcode),
    n_igh_outside_subset = sum(barcode %in% heavy$barcode & !barcode %in% meta$barcode), .groups = "drop")
full_cluster_coverage <- full_meta %>% tibble::rownames_to_column("barcode") %>%
  group_by(seurat_clusters) %>% summarise(n_full_gex = n(), n_in_b_subset = sum(barcode %in% meta$barcode),
    n_full_with_igh = sum(barcode %in% heavy$barcode),
    n_igh_outside_subset = sum(barcode %in% heavy$barcode & !barcode %in% meta$barcode), .groups = "drop")
full_genes <- intersect(c("MS4A1", "CD19", "CD79A", "CD79B", "CD74", "MZB1", "JCHAIN", "XBP1", "PRDM1", "SDC1",
  "IGKC", "CD3D", "CD3E", "NKG7", "GNLY", "LST1", "S100A8", "CD34", "DNTT", "VPREB1", "RAG1", "IGLL1", "MKI67", "PF4", "PPBP", "HBB"), rownames(full_obj))
full_x <- GetAssayData(full_obj, assay = "RNA", layer = "data")[full_genes, , drop = FALSE]
full_markers <- bind_rows(lapply(unique(as.character(full_obj$seurat_clusters)), function(k) {
  i <- which(as.character(full_obj$seurat_clusters) == k)
  tibble(cluster = k, gene = full_genes, pct = 100 * Matrix::rowMeans(full_x[, i, drop = FALSE] > 0),
    avg = Matrix::rowMeans(full_x[, i, drop = FALSE]), n_cells = length(i))
}))
stopifnot(all(meta$barcode %in% rownames(full_meta)))
rm(full_obj, full_meta, full_x); gc(FALSE)
memory_shm <- filter(shm_qc, cell_subtype == "Memory B", n_shm >= 10) %>%
  left_join(select(sample_info, sample_id, age, sex, aneurysm), by = "sample_id")
design_tests <- bind_rows(
  age_test(memory_shm, "median_mu", "Memory SHM; all donors", "design"),
  age_test(filter(memory_shm, sex == "F"), "median_mu", "Memory SHM; females", "design"),
  age_test(filter(memory_shm, aneurysm), "median_mu", "Memory SHM; aneurysm donors", "design"))
leave_one_out <- bind_rows(lapply(memory_shm$sample_id, function(s) {
  age_test(filter(memory_shm, sample_id != s), "median_mu", s, "memory_shm_leave_one_out")
}))

message("Checking public-clone and antigen edge cases")
# Unlike unique(sequence) + first donor, retain every donor for each sequence.
public_key <- c %>% distinct(sample_id, raw_v, cdr3_aa) %>% count(raw_v, cdr3_aa, name = "n_donors") %>% filter(n_donors > 1)
keys <- c %>% distinct(sample_id, raw_v, cdr3_aa) %>% filter(nchar(cdr3_aa) >= 10)
near <- list()
for (v in unique(keys$raw_v)) {
  for (len in unique(nchar(keys$cdr3_aa[keys$raw_v == v]))) {
    z <- filter(keys, raw_v == v, nchar(cdr3_aa) == len)
    if (nrow(z) < 2) next
    dm <- stringdist::stringdistmatrix(z$cdr3_aa, z$cdr3_aa, method = "hamming")
    idx <- which(upper.tri(dm) & dm <= 1 & outer(z$sample_id, z$sample_id, "!="), arr.ind = TRUE)
    if (!nrow(idx)) next
    near[[length(near)+1]] <- tibble(raw_v = v, sample_1 = z$sample_id[idx[,1]],
      sample_2 = z$sample_id[idx[,2]], cdr3_1 = z$cdr3_aa[idx[,1]], cdr3_2 = z$cdr3_aa[idx[,2]], hamming = dm[idx])
  }
}
near <- bind_rows(near)
cov <- read_csv("data/reference/CoV-AbDab_080224.csv", show_col_types = FALSE)
# CoV-AbDab CDRH3 is already without the conserved C104 / W118 anchors.
ref <- cov %>% transmute(ref_name = Name, antigen = `Binds to`, ref_v = sub(" .*$", "", `Heavy V Gene`),
  ref_cdr3 = toupper(CDRH3), light_v = `Light V Gene`, light_cdr3 = CDRL3)
query <- c %>% mutate(query_cdr3 = sub("W$", "", sub("^C", "", cdr3_aa)))
antigen_hits <- query %>% inner_join(ref, by = c("raw_v" = "ref_v", "query_cdr3" = "ref_cdr3"), relationship = "many-to-many")
antigen_qc <- tibble(item = c("reference_rows", "reference_cdr3_start_C", "reference_cdr3_end_W", "corrected_exact_hit_cells", "public_heavy_keys", "corrected_near_pairs"),
  n = c(nrow(ref), sum(grepl("^C", ref$ref_cdr3)), sum(grepl("W$", ref$ref_cdr3)),
        n_distinct(antigen_hits$barcode), nrow(public_key), nrow(near)))

message("Exporting audit evidence")
tables <- list(audit_counts = audit_counts, isotype_confusion = isotype_confusion, v_confusion = v_confusion,
  isotype_by_donor = isotype_donor, recovery_by_subtype = recovery, paired_chain_by_subtype = paired,
  marker_summary = marker_summary, cluster_balance = cluster_balance, cluster_by_donor = cluster_donor,
  clone_sensitivity = clone_sensitivity, clone_sensitivity_tests = clone_tests, clone_collisions = clone_v_collisions,
  rarefaction = rarefaction, rarefaction_tests = rarefaction_tests, shm_qc = shm_qc,
  shm_clone_balanced = shm_clone, shm_sensitivity_tests = shm_tests,
  memory_shm_by_isotype = memory_shm_isotype, memory_shm_isotype_tests = memory_isotype_tests,
  corrected_isotype_tests = iso_tests,
  corrected_v_tests = v_tests, within_isotype_expansion = iso_expansion,
  switched_by_subtype = switch_sensitivity, corrected_v_usage = v_usage,
  study_design = design, sequencing_qc = sequencing_qc, full_subset_qc = full_subset_qc,
  full_cluster_coverage = full_cluster_coverage, full_object_marker_summary = full_markers,
  disease_sensitivity = design_tests, memory_shm_leave_one_out = leave_one_out,
  original_tests = original_tests, antigen_qc = antigen_qc, corrected_public_keys = public_key)
if (nrow(near)) tables$corrected_near_public_pairs <- near
if (nrow(antigen_hits)) tables$corrected_antigen_candidates <- antigen_hits %>%
  select(barcode, sample_id, age_group, cell_subtype, raw_v, raw_j, raw_c, query_cdr3, cdr3_aa2, IGLC, ref_name, antigen, light_v, light_cdr3)
invisible(lapply(names(tables), function(n) write_tab(tables[[n]], n)))
openxlsx::write.xlsx(tables, file.path(out_dir, "audit_tables.xlsx"), overwrite = TRUE)
saveRDS(list(tables = tables, shm_max_abs_difference = max(abs(shm_validation$shm_delta), na.rm = TRUE),
  n_shm_mismatched_contigs = sum(!shm_validation$same_shm_contig, na.rm = TRUE),
  created_at = format(Sys.time(), tz = "Asia/Shanghai", usetz = TRUE)), file.path(out_dir, "audit_results.rds"))
saveRDS(c %>% select(barcode, sample_id, age_group, cell_subtype, lineage, raw_contig_id,
  raw_v, raw_j, raw_c, correct_isotype_group, cdr3_aa, cdr3_nt, IGLC, cdr3_aa2, cdr3_nt2,
  n_productive_igh, valid_light, corrected_h_aa, corrected_h_vj_nt, corrected_pair_aa, mu_percent),
  file.path(out_dir, "corrected_cells_for_sensitivity.rds"))
writeLines(capture.output(sessionInfo()), file.path(out_dir, "sessionInfo.txt"))
inputs <- c("results/bcr_review/baseline/codes/bcr_skull_bm.qmd", "results/bcr_review/baseline/codes/bcr_helpers.R", "codes/run_shm_analysis_10X.sh",
  "codes/sample_info.csv", "codes/cluster_lineage.csv", "meta_data.xlsx",
  "data/scRNA_harmony_luguB_quan.rds", "data/scRNA_harmony_luguquan.rds",
  "results/bcr_review/baseline/results/bcr/rdata/bcr_cells.rds", "data/reference/CoV-AbDab_080224.csv")
write_csv(tibble(path = inputs, md5 = unname(tools::md5sum(inputs))), file.path(out_dir, "input_fingerprints.csv"))
print(audit_counts)
print(filter(original_tests, fdr < .05))
print(design_tests)
message("Audit complete: ", out_dir)
