# =============================================================================
# run_all.R
# Kullanim:  Rscript run_all.R <run_id>      (ornek: Rscript run_all.R run1)
# Her kosu outputs/<run_id> altina yazar; var olan dizinin uzerine yazilmaz.
# =============================================================================
args   <- commandArgs(trailingOnly = TRUE)
run_id <- if (length(args)) args[1] else format(Sys.time(), "run_%Y%m%d_%H%M%S")
if (!grepl("^[A-Za-z0-9_-]+$", run_id)) stop("Gecersiz run_id.")
file_arg <- grep("^--file=", commandArgs(), value = TRUE)
if (length(file_arg)) setwd(dirname(normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE)))
if (!file.exists("config.R") || !dir.exists("R")) stop("Proje kokunden calistirin.")
out <- file.path("outputs", run_id)
if (dir.exists(out)) stop("Cikti dizini zaten var; yeni bir run_id secin: ", out)
dir.create(out, recursive = TRUE); dir.create(file.path(out, "models"))
started <- Sys.time(); checks <- list()

required <- c("lavaan", "semTools", "ggplot2", "jsonlite", "digest")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Eksik paketler: ", paste(missing, collapse = ", "))
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
source("config.R", encoding = "UTF-8")
source("R/00_functions.R", encoding = "UTF-8")

source_paths <- c("config.R", "run_all.R", sort(list.files("R", pattern = "[.]R$", full.names = TRUE)))
csv_out(data.frame(file = source_paths,
  sha256 = vapply(source_paths, function(f) digest::digest(file = f, algo = "sha256"), character(1))), "code_sha256.csv")
jsonlite::write_json(cfg, file.path(out, "config_used.json"), pretty = TRUE, auto_unbox = TRUE)
writeLines(capture.output(sessionInfo()), file.path(out, "sessionInfo.txt"))

status <- tryCatch({
  log_event("RUN_START", run_id)
  for (f in source_paths) parse(file = f, encoding = "UTF-8")
  modules <- c("01_prepare.R", "02_semantic_forms.R", "03_as1_isi_discrimination.R",
               "04_as2_structure_reliability.R", "05_as3_score_agreement.R",
               "06_exhaustive_reference.R", "07_bootstrap.R", "08_figures.R")
  for (m in modules) source(file.path("R", m), encoding = "UTF-8")
  check("input_files_unchanged_after_run",
        all(vapply(manifest$file, function(f) digest::digest(file = f, algo = "sha256"), character(1)) == manifest$sha256))
  log_event("RUN_COMPLETE", run_id)
  list(status = "PASS", error = NULL)
}, error = function(e) {
  log_event("RUN_FAILED", conditionMessage(e))
  list(status = "FAIL", error = conditionMessage(e))
})
status$run_id <- run_id
status$grm_stage_run <- exists("grm_available") && isTRUE(grm_available)
status$started_utc <- format(started, tz = "UTC", usetz = TRUE)
status$ended_utc <- format(Sys.time(), tz = "UTC", usetz = TRUE)
status$elapsed_seconds <- as.numeric(difftime(Sys.time(), started, units = "secs"))
status$checks_passed <- sum(vapply(checks, function(x) isTRUE(x$passed), logical(1)))
status$checks_total <- length(checks)
jsonlite::write_json(status, file.path(out, "run_status.json"), pretty = TRUE, auto_unbox = TRUE, na = "null")
if (status$status != "PASS") { cat("FAIL:", status$error, "\n"); quit(status = 1L) }
cat("PASS:", run_id, "\n")
