# =============================================================================
# 01_prepare.R
# Ham arsivin dogrulanmasi, madde metinleri, uygunluk filtreleri, orneklem ve bolme.
# Yanit verisi bu asamada yalnizca hazirlanir; secimde kullanilmaz.
# =============================================================================
log_event("STAGE", "prepare inputs")

source_files <- c("DASS_data_21.02.19.zip", "archived_embeddings.csv", "embedding_provenance.json")
check("all_source_files_exist", all(file.exists(file.path("inputs", source_files))))
manifest <- data.frame(
  file = paste0("inputs/", source_files),
  sha256 = vapply(file.path("inputs", source_files), function(f) digest::digest(file = f, algo = "sha256"), character(1)),
  bytes = as.numeric(file.info(file.path("inputs", source_files))$size))
csv_out(manifest, "input_sha256.csv")

zip_path <- "inputs/DASS_data_21.02.19.zip"
check("raw_archive_sha256", identical(manifest$sha256[1], cfg$expected_source_sha256))
members   <- unzip(zip_path, list = TRUE)$Name
data_name <- members[grepl("(^|/)data[.]csv$", members)]
code_name <- members[grepl("(^|/)codebook[.]txt$", members)]
check("archive_members_identified", length(data_name) == 1L && length(code_name) == 1L)
check("archive_paths_safe", !any(grepl("(^/|(^|/)\\.\\.(/|$))", c(data_name, code_name))))

# --- Madde metinleri (kod kitabindan) ------------------------------------------
cb <- readLines(unz(zip_path, code_name), warn = FALSE, encoding = "UTF-8")
item_lines <- cb[grepl("^Q[0-9]+\t", cb)]
numbers <- as.integer(sub("^Q([0-9]+)\t.*$", "\\1", item_lines))
texts   <- normalise_text(sub("^Q[0-9]+\t", "", item_lines))
check("codebook_has_42_unique_items", identical(sort(numbers), 1:42))
o <- order(numbers); numbers <- numbers[o]; texts <- texts[o]
subscale <- vapply(numbers, function(i) names(key42)[vapply(key42, function(k) i %in% k, logical(1))], character(1))
items <- data.frame(item_id = item_id(numbers), original_number = numbers, subscale = subscale,
                    dass21_number = match(numbers, map21to42), text = texts,
                    word_count = word_count(texts), stringsAsFactors = FALSE)
csv_out(items, "items_used.csv")
csv_out(data.frame(dass21_number = 1:21, dass42_number = map21to42, item_id = item_id(map21to42)), "dass21_mapping.csv")

# --- Ham yanitlar -------------------------------------------------------------------
raw <- read.delim(unz(zip_path, data_name), sep = "\t", quote = "", check.names = FALSE,
                  stringsAsFactors = FALSE, na.strings = c("", "NA"))
cols <- paste0("Q", 1:42, "A")
check("response_columns_present", all(c(cols, "age", "engnat") %in% names(raw)))
Y <- as.data.frame(lapply(raw[, cols, drop = FALSE], function(x) suppressWarnings(as.numeric(x))))
names(Y) <- item_id(1:42)
age <- suppressWarnings(as.numeric(raw$age)); eng <- suppressWarnings(as.numeric(raw$engnat))
age_ok  <- !is.na(age) & age >= cfg$age_min & age <= cfg$age_max
lang_ok <- !is.na(eng) & eng == cfg$native_english_code
valid   <- apply(as.matrix(Y), 1, function(x) all(!is.na(x) & x %in% 1:4))   # 0 = yanitsiz
eligible <- which(age_ok & lang_ok & valid)
flow <- data.frame(stage = c("raw", "age_eligible", "native_english_age_eligible", "complete_valid"),
                   n = c(nrow(raw), sum(age_ok), sum(age_ok & lang_ok), length(eligible)))
csv_out(flow, "sample_flow.csv")
check("same_filter_counts_as_archive", identical(as.integer(flow$n), c(39775L, 32495L, 10362L, 10362L)))

# --- Orneklem ve bolme ---------------------------------------------------------------
set.seed(cfg$seed_sample)
ids <- if (isTRUE(cfg$use_all_eligible)) eligible else sort(sample(eligible, cfg$n_target))
n_cal <- as.integer(round(cfg$split_prop * length(ids)))
set.seed(cfg$seed_split)
cal_pos <- sort(sample(seq_along(ids), n_cal))
val_pos <- setdiff(seq_along(ids), cal_pos)
X <- Y[ids, , drop = FALSE] - 1; rownames(X) <- NULL          # 1-4 -> 0-3, ters madde yok
split <- data.frame(source_row = ids, split = ifelse(seq_along(ids) %in% cal_pos, "calibration", "validation"))

# Onceki calismanin bolmesiyle sureklilik (yalnizca ayni tasarim kullanildiginda anlamli)
prev_path <- "inputs/previous_reference/sample_split.csv"
if (file.exists(prev_path) && !isTRUE(cfg$use_all_eligible) && cfg$n_target == 4000L && cfg$split_prop == 0.5) {
  previous_split <- read.csv(prev_path, stringsAsFactors = FALSE)
  check("sample_split_matches_prior_version", identical(split, previous_split),
        "Dogrulama yarisi onceki analizlerde gorulmustur; bu bolme kor bir dis dogrulama degildir.")
}
check("sample_rows_unique_and_disjoint", !anyDuplicated(ids) && length(intersect(ids[cal_pos], ids[val_pos])) == 0L)
check("response_transformation_1_4_to_0_3", all(as.matrix(X) %in% 0:3) &&
        identical(unname(as.matrix(X + 1)), unname(as.matrix(Y[ids, , drop = FALSE]))))
csv_out(split, "sample_split.csv")
category <- do.call(rbind, lapply(names(X), function(j) do.call(rbind, lapply(c("calibration", "validation"), function(g) {
  z <- table(factor(X[split$split == g, j], levels = 0:3))
  data.frame(item_id = j, split = g, category = 0:3, n = as.integer(z))
}))))
csv_out(category, "item_category_counts.csv")
check("all_four_categories_present_per_split", all(category$n > 0L))
csv_out(data.frame(n_selected = nrow(X), n_calibration = length(cal_pos), n_validation = length(val_pos),
                   constant_response_rows = sum(apply(X, 1, function(v) length(unique(v)) == 1L)),
                   age_mean = mean(age[ids]), age_sd = stats::sd(age[ids])), "sample_summary.csv")

p <- list(items = items, cal = X[cal_pos, , drop = FALSE], val = X[val_pos, , drop = FALSE],
          split = split, cal_source_rows = ids[cal_pos], val_source_rows = ids[val_pos])
saveRDS(p, file.path(out, "prepared.rds"))
jsonlite::write_json(list(
  data_url = "https://openpsychometrics.org/_rawdata/DASS_data_21.02.19.zip",
  source_sha256 = manifest$sha256[1], language = "English",
  response_coding = "source 1:4 minus 1 to 0:3; no reverse-keyed items",
  eligibility = "age 18-80, engnat == 1, all 42 items in 1:4",
  n_selected = nrow(X), n_calibration = length(cal_pos), n_validation = length(val_pos),
  validation_history = paste(
    "The validation half was analysed in earlier runs (6 and 13 September 2026 packages).",
    "Results are a retrospective method comparison, not a blind external validation."),
  independent_rows_note = "Disjoint source rows do not prove distinct people."),
  file.path(out, "source_manifest.json"), pretty = TRUE, auto_unbox = TRUE)
rm(raw, Y, X)
log_event("PREPARED", nrow(p$cal), nrow(p$val))
