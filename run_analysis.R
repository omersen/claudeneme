# ============================================================================
# run_analysis.R: COMPLETE ENTRY POINT
# ============================================================================
source("R/10_main.R")
source_all_modules()

# ----------------------------------------------------------------------------
# OPTIONAL FIRST-RUN SETUP
# ----------------------------------------------------------------------------
# Uncomment the next line on a new machine to install the core stack,
# install AIGENIE from r-universe, and load all required packages.
# install_and_load_aigenie_stack()
#
# The AIGENIE Python bridge is required for GENIE. The pipeline will also
# call this during initialization, but it can be run explicitly if desired.
# library(AIGENIE)
# AIGENIE::ensure_aigenie_python()
#
# You can define your OpenAI API key explicitly before running the pipeline.
# Example:
# configure_openai_api_key("sk-your-key-here", persist = FALSE)
# Or set it in the shell before execution:
# Sys.setenv(OPENAI_API_KEY = "sk-your-key-here")

items_csv <- "dass42_items.csv"
data_csv <- "data/openpsychometrics_dass.csv"
output_dir <- "outputs"

# If you prefer to set the API key inside R, assign it here and uncomment the
# next line. Leaving it NULL means the pipeline will use Sys.getenv().
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
