# ============================================================================
# run_analysis.R: COMPLETE ENTRY POINT
# ============================================================================

source("R/00_setup.R")
source("R/01_data_prep.R")
source("R/02_embeddings.R")
source("R/03_genie_diagnostic.R")
source("R/04_semantic_metrics.R")
source("R/05_null_benchmark.R")
source("R/06_psychometric_core.R")
source("R/07_repeated_split_robustness.R")
source("R/08_integration_decision.R")
source("R/10_main.R")

# ----------------------------------------------------------------------------
# OPTIONAL FIRST-RUN SETUP
# ----------------------------------------------------------------------------
# install_and_load_aigenie_stack()
# configure_openai_api_key("sk-your-key-here", persist = FALSE)

items_csv <- "dass42_items.csv"
data_csv <- "data/openpsychometrics_dass.csv"
output_dir <- "outputs"

api_key <- NULL
# configure_openai_api_key(api_key, persist = FALSE)

data_path <- if (file.exists(data_csv)) data_csv else NULL
if (is.null(data_path)) {
  cat("Optional response dataset not found. Running semantic-only mode.\n")
}

results <- main_complete_pipeline(
  items_csv_path = items_csv,
  data_filepath = data_path,
  output_dir = output_dir,
  use_cache = TRUE
)

if (!is.null(results$integration)) {
  cat(results$integration$verdict)
} else {
  cat("Pipeline completed without psychometric/integration stage.\n")
}
