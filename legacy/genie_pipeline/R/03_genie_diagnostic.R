# ============================================================================
# 03_genie_diagnostic.R: GENIE NATURAL REDUCTION DIAGNOSTIC
# ============================================================================

build_genie_items_df <- function(items_df) {
  data.frame(
    statement = items_df$text,
    attribute = tolower(items_df$subscale),
    type = rep("dass", nrow(items_df)),
    ID = as.character(items_df$item_number),
    stringsAsFactors = FALSE
  )
}

write_genie_structure_log <- function(genie_result, structure_log_path = NULL) {
  if (is.null(structure_log_path)) {
    return(invisible(NULL))
  }

  capture.output(str(genie_result, max.level = 3), file = structure_log_path)
  invisible(structure_log_path)
}

call_genie_natural <- function(items_df,
                               api_key,
                               E_matrix = NULL,
                               structure_log_path = NULL) {
  assert_aigenie_installed()
  prepare_aigenie_python()

  cat("\n[GENIE] Running natural reduction\n")
  cat(strrep("=", 60), "\n")

  genie_input <- build_genie_items_df(items_df)

  embedding_for_genie <- NULL
  if (!is.null(E_matrix)) {
    embedding_for_genie <- t(as.matrix(E_matrix))
    colnames(embedding_for_genie) <- genie_input$ID
    cat(
      "Passing precomputed embedding matrix:",
      nrow(embedding_for_genie), "dims x",
      ncol(embedding_for_genie), "items\n"
    )
  }

  genie_result <- tryCatch(
    {
      AIGENIE::GENIE(
        items = genie_input,
        embedding.matrix = embedding_for_genie,
        openai.API = api_key,
        embedding.model = EMBEDDING_MODEL,
        all.together = TRUE,
        plot = FALSE,
        silently = FALSE
      )
    },
    error = function(e) {
      stop("GENIE call failed: ", conditionMessage(e), call. = FALSE)
    }
  )

  write_genie_structure_log(genie_result, structure_log_path = structure_log_path)
  invisible(genie_result)
}

safe_extract <- function(obj, ...) {
  fields <- list(...)
  current <- obj

  for (field in fields) {
    if (is.null(current)) {
      return(NULL)
    }
    current <- current[[field]]
  }

  current
}

extract_primary_genie_block <- function(genie_result) {
  if (!is.null(genie_result$final_items)) {
    return(genie_result)
  }

  if (!is.null(genie_result$overall) && !is.null(genie_result$overall$final_items)) {
    return(genie_result$overall)
  }

  if (!is.null(genie_result$item_type_level)) {
    if ("dass" %in% names(genie_result$item_type_level)) {
      return(genie_result$item_type_level[["dass"]])
    }
    if (length(genie_result$item_type_level) == 1) {
      return(genie_result$item_type_level[[1]])
    }
  }

  stop("Could not identify the primary GENIE result block.", call. = FALSE)
}

coerce_final_items_to_ids <- function(final_items_obj) {
  if (is.null(final_items_obj)) {
    return(NULL)
  }

  if (is.data.frame(final_items_obj)) {
    if (!"ID" %in% colnames(final_items_obj)) {
      stop("GENIE final_items data frame does not contain an ID column.", call. = FALSE)
    }
    return(as.integer(as.character(final_items_obj$ID)))
  }

  if (is.vector(final_items_obj) || is.factor(final_items_obj)) {
    return(as.integer(as.character(final_items_obj)))
  }

  stop("Unsupported GENIE final_items object type: ", class(final_items_obj)[1], call. = FALSE)
}

extract_community_membership <- function(ega_obj) {
  if (is.null(ega_obj)) return(NULL)

  if (!is.null(ega_obj$community)) {
    return(as.vector(ega_obj$community))
  }

  if (!is.null(ega_obj$wc$membership)) {
    return(as.vector(ega_obj$wc$membership))
  }

  if (!is.null(ega_obj$wc) && is.numeric(ega_obj$wc)) {
    return(as.vector(ega_obj$wc))
  }

  NULL
}

extract_genie_diagnostic <- function(genie_result, items_df, subscale_map) {
  primary_block <- extract_primary_genie_block(genie_result)

  final_items_df <- primary_block$final_items
  if (is.null(final_items_df)) {
    stop("Could not extract final_items from GENIE output.", call. = FALSE)
  }

  final_item_ids <- coerce_final_items_to_ids(final_items_df)
  final_item_ids <- sort(unique(final_item_ids))

  diagnostic <- list()
  diagnostic$start_n <- nrow(items_df)
  diagnostic$final_items_df <- final_items_df
  diagnostic$final_item_ids <- final_item_ids
  diagnostic$final_n <- length(final_item_ids)
  diagnostic$reduction_rate <- (diagnostic$start_n - diagnostic$final_n) / diagnostic$start_n * 100

  breakdown <- subscale_map %>%
    dplyr::filter(item_number %in% final_item_ids) %>%
    dplyr::count(subscale)

  diagnostic$subscale_breakdown <- breakdown
  diagnostic$initial_NMI <- primary_block$initial_NMI
  diagnostic$final_NMI <- primary_block$final_NMI
  diagnostic$initial_EGA <- primary_block$initial_EGA
  diagnostic$final_EGA <- primary_block$final_EGA
  diagnostic$UVA <- primary_block$UVA
  diagnostic$bootEGA <- primary_block$bootEGA

  diagnostic$initial_communities <- extract_community_membership(diagnostic$initial_EGA)
  diagnostic$final_communities <- extract_community_membership(diagnostic$final_EGA)

  cat("GENIE natural solution extracted.\n")
  cat("Start N:", diagnostic$start_n, "\n")
  cat("Final N:", diagnostic$final_n, "\n")
  cat("Reduction rate:", round(diagnostic$reduction_rate, 1), "%\n")
  print(breakdown)

  invisible(diagnostic)
}

post_genie_decision <- function(diagnostic) {
  all_three_present <- length(unique(diagnostic$subscale_breakdown$subscale)) == 3

  if (!all_three_present) {
    category <- "DIMENSION_LOSS_RISK"
    action <- "INVESTIGATE"
    recommendation <- "Natural GENIE solution does not preserve all three subscales."
  } else if (diagnostic$final_n <= 21) {
    category <- "NATURAL_SHORT_FORM"
    action <- "EVALUATE_DIRECTLY"
    recommendation <- "Evaluate the natural GENIE solution directly without forcing a target length."
  } else {
    category <- "NATURAL_LONG_FORM"
    action <- "EVALUATE_THEN_DECIDE"
    recommendation <- paste(
      "Natural GENIE solution is longer than 21 items.",
      "Evaluate semantics and psychometrics first, then decide whether a constrained second phase is needed."
    )
  }

  list(
    category = category,
    action = action,
    recommendation = recommendation,
    final_n = diagnostic$final_n
  )
}

generate_diagnostic_report <- function(diagnostic, decision) {
  breakdown_str <- paste(
    apply(diagnostic$subscale_breakdown, 1, function(x) {
      sprintf("  %s: %s", x[["subscale"]], x[["n"]])
    }),
    collapse = "\n"
  )

  init_nmi <- ifelse(is.null(diagnostic$initial_NMI), NA, round(diagnostic$initial_NMI, 3))
  final_nmi <- ifelse(is.null(diagnostic$final_NMI), NA, round(diagnostic$final_NMI, 3))

  sprintf(
    paste(
      "===========================================================",
      "GENIE NATURAL REDUCTION DIAGNOSTIC REPORT",
      "===========================================================",
      "INPUT:  %d items",
      "OUTPUT: %d items (%.1f%% reduction)",
      "SUBSCALE COMPOSITION:",
      "%s",
      "STRUCTURAL QUALITY:",
      "  Initial NMI: %s",
      "  Final NMI:   %s",
      "DECISION:",
      "  Category: %s",
      "  Action:   %s",
      "  Note:     %s",
      "===========================================================",
      sep = "\n"
    ),
    diagnostic$start_n,
    diagnostic$final_n,
    diagnostic$reduction_rate,
    breakdown_str,
    init_nmi,
    final_nmi,
    decision$category,
    decision$action,
    decision$recommendation
  )
}

run_genie_diagnostic <- function(items_df,
                                 subscale_map,
                                 api_key,
                                 E_matrix = NULL,
                                 structure_log_path = NULL) {
  cat("\n[M2] GENIE NATURAL REDUCTION DIAGNOSTIC\n")
  cat(strrep("=", 60), "\n")

  genie_result <- call_genie_natural(
    items_df = items_df,
    api_key = api_key,
    E_matrix = E_matrix,
    structure_log_path = structure_log_path
  )

  diagnostic <- extract_genie_diagnostic(genie_result, items_df, subscale_map)
  decision <- post_genie_decision(diagnostic)
  report <- generate_diagnostic_report(diagnostic, decision)

  cat(report, "\n")

  invisible(list(
    genie_result = genie_result,
    diagnostic = diagnostic,
    decision = decision,
    report = report
  ))
}

cat("GENIE diagnostic module loaded.\n")
