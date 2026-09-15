# ============================================================================
# 00_setup.R: INITIALIZATION, DEPENDENCIES, AND ENVIRONMENT CHECKS
# ============================================================================

required_packages <- c(
  "tidyverse",
  "lavaan",
  "psych",
  "httr2",
  "jsonlite",
  "reshape2",
  "ggplot2",
  "reticulate",
  "EGAnet",
  "igraph",
  "patchwork",
  "remotes",
  "uwot",
  "AIGENIE"
)

install_required_packages <- function(packages = required_packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) == 0) {
    message("All required packages already installed.")
    return(invisible(TRUE))
  }

  cran_packages <- setdiff(missing, "AIGENIE")
  if (length(cran_packages) > 0) {
    install.packages(cran_packages, repos = "https://cloud.r-project.org")
  }

  if ("AIGENIE" %in% missing) {
    install.packages(
      "AIGENIE",
      repos = c(
        "https://laralee.r-universe.dev",
        "https://cloud.r-project.org"
      )
    )
  }

  invisible(TRUE)
}

load_required_packages <- function(packages = required_packages) {
  invisible(lapply(packages, library, character.only = TRUE))
}

install_and_load_aigenie_stack <- function() {
  install_required_packages()
  load_required_packages()
  invisible(TRUE)
}

# ============================================================================
# CONSTANTS
# ============================================================================

EMBEDDING_MODEL <- "text-embedding-3-large"
EMBEDDING_DIM <- 3072

N_NULL_ITERATIONS <- 5000
N_SPLIT_REPEATS <- 100

TOLERANCE_OMEGA <- 0.05
TOLERANCE_ALPHA <- 0.05
TOLERANCE_CFI_TLI <- 0.03
TOLERANCE_RMSEA_SRMR <- 0.010
TOLERANCE_REMAINDER <- 0.10

SET_SEED <- 42

# ============================================================================
# ENVIRONMENT HELPERS
# ============================================================================

configure_openai_api_key <- function(api_key = NULL, persist = FALSE) {
  if (!is.null(api_key) && nzchar(api_key)) {
    Sys.setenv(OPENAI_API_KEY = api_key)

    if (persist) {
      renviron_path <- path.expand("~/.Renviron")
      line <- paste0("OPENAI_API_KEY=", api_key)

      if (!file.exists(renviron_path)) {
        writeLines(line, renviron_path)
      } else {
        current <- readLines(renviron_path, warn = FALSE)
        current <- current[!grepl("^OPENAI_API_KEY=", current)]
        writeLines(c(current, line), renviron_path)
      }
    }
  }

  invisible(Sys.getenv("OPENAI_API_KEY"))
}

assert_openai_key <- function() {
  key <- Sys.getenv("OPENAI_API_KEY")

  if (nchar(key) == 0) {
    stop(
      paste(
        "OPENAI_API_KEY environment variable not set.",
        "Set it before running the pipeline.",
        sep = "\n"
      ),
      call. = FALSE
    )
  }

  invisible(key)
}

assert_aigenie_installed <- function() {
  if (!requireNamespace("AIGENIE", quietly = TRUE)) {
    stop(
      paste(
        "AIGENIE package is required for this pipeline.",
        "Install it with:",
        "install.packages('AIGENIE', repos = c('https://laralee.r-universe.dev', 'https://cloud.r-project.org'))",
        sep = "\n"
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

prepare_aigenie_python <- function(force_reinstall = FALSE,
                                   include_huggingface = TRUE,
                                   include_local_llm = FALSE,
                                   gpu = FALSE) {
  assert_aigenie_installed()

  tryCatch(
    {
      AIGENIE::ensure_aigenie_python(
        force_reinstall = force_reinstall,
        include_huggingface = include_huggingface,
        include_local_llm = include_local_llm,
        gpu = gpu
      )
    },
    error = function(e) {
      stop(
        paste(
          "AIGENIE Python environment setup failed.",
          conditionMessage(e),
          "If needed, run AIGENIE::reinstall_python_env() and retry.",
          sep = "\n"
        ),
        call. = FALSE
      )
    }
  )

  invisible(TRUE)
}

create_output_dirs <- function(base = "outputs") {
  dirs <- c(
    base,
    file.path(base, "figures"),
    file.path(base, "tables"),
    file.path(base, "data"),
    file.path(base, "logs")
  )

  for (dir_path in dirs) {
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
    }
  }

  invisible(dirs)
}

write_session_info <- function(output_dir = "outputs") {
  session_path <- file.path(output_dir, "logs", "00_session_info.txt")
  capture.output(sessionInfo(), file = session_path)
  invisible(session_path)
}

initialize_environment <- function(output_dir = "outputs",
                                   auto_install = FALSE,
                                   setup_python = TRUE) {
  if (auto_install) {
    install_required_packages()
  }

  assert_openai_key()
  assert_aigenie_installed()
  load_required_packages()

  if (setup_python) {
    prepare_aigenie_python()
  }

  create_output_dirs(output_dir)
  write_session_info(output_dir)

  set.seed(SET_SEED)

  message("Environment initialized.")
  invisible(TRUE)
}

cat("Setup module loaded.\n")
