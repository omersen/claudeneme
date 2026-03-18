# ============================================================================
# 03_genie_diagnostic.R: GENIE NETWORK DIAGNOSTIC
# ============================================================================
run_ega_analysis <- function(E_matrix, items_df) {
  cat("Running EGA on embedding matrix...\n")
  set.seed(SET_SEED)
  ega_result <- tryCatch(
    {
      EGAnet::EGA(
        data = as.data.frame(t(E_matrix)),
        plot.EGA = FALSE
      )
    },
    error = function(e) {
      cat("EGA on raw embeddings failed, attempting on cosine similarity...\n")
      S <- E_matrix %*% t(E_matrix)
      EGAnet::EGA(
        data = as.data.frame(S),
        plot.EGA = FALSE
      )
    }
  )
  # Robust community extraction: try wc$membership, then wc directly
  wc_raw <- ega_result$wc
  if (is.list(wc_raw) && !is.null(wc_raw$membership)) {
    wc_vec <- as.integer(wc_raw$membership)
  } else if (is.numeric(wc_raw) || is.integer(wc_raw)) {
    wc_vec <- as.integer(wc_raw)
  } else {
    stop("Cannot extract community assignments from EGA result.", call. = FALSE)
  }
  stopifnot(length(wc_vec) == nrow(items_df))

  n_communities <- max(wc_vec, na.rm = TRUE)
  cat("EGA detected", n_communities, "communities.\n")
  community_df <- data.frame(
    item_number = items_df$item_number,
    community = wc_vec,
    subscale = items_df$subscale,
    stringsAsFactors = FALSE
  )
  list(
    ega = ega_result,
    communities = wc_vec,
    n_communities = n_communities,
    community_df = community_df
  )
}

select_genie_items <- function(items_df,
                               subscale_map,
                               community_df,
                               E_matrix,
                               api_key) {
  cat("Selecting GENIE natural short form items...\n")
  S_cosine <- E_matrix %*% t(E_matrix)
  selected_items <- c()
  for (sub in c("Depression", "Anxiety", "Stress")) {
    sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub) %>%
      dplyr::pull(item_number)
    sub_communities <- community_df %>%
      dplyr::filter(item_number %in% sub_items)
    community_counts <- sub_communities %>%
      dplyr::count(community, sort = TRUE)
    for (comm in community_counts$community) {
      comm_items <- sub_communities %>%
        dplyr::filter(community == comm) %>%
        dplyr::pull(item_number)
      if (length(comm_items) == 1) {
        selected_items <- c(selected_items, comm_items)
      } else {
        sub_sim <- S_cosine[comm_items, comm_items, drop = FALSE]
        avg_sim <- rowMeans(sub_sim)
        best_idx <- which.max(avg_sim)
        selected_items <- c(selected_items, comm_items[best_idx])
      }
    }
  }
  selected_items <- sort(unique(as.integer(selected_items)))
  cat("Selected", length(selected_items), "items via GENIE network method.\n")
  selected_items
}

build_diagnostic_report <- function(items_df,
                                    community_df,
                                    ega_analysis,
                                    final_item_ids) {
  final_items_df <- items_df %>%
    dplyr::filter(item_number %in% final_item_ids)
  composition <- final_items_df %>%
    dplyr::count(subscale)
  lines <- c(
    "============================================================",
    "GENIE DIAGNOSTIC REPORT",
    "============================================================",
    paste("Total items selected:", length(final_item_ids)),
    paste("EGA communities detected:", ega_analysis$n_communities),
    "",
    "Subscale composition:",
    paste0("  ", composition$subscale, ": ", composition$n, " items"),
    "",
    "Selected items:",
    paste0("  Item ", final_items_df$item_number, " [",
           final_items_df$subscale, "]: ",
           substr(final_items_df$text, 1, 60)),
    "",
    "Community assignments for selected items:",
    paste0("  Item ", community_df$item_number[community_df$item_number %in% final_item_ids],
           " -> Community ",
           community_df$community[community_df$item_number %in% final_item_ids]),
    "============================================================"
  )
  paste(lines, collapse = "\n")
}

run_genie_diagnostic <- function(items_df,
                                 subscale_map,
                                 api_key,
                                 E_matrix,
                                 structure_log_path = NULL) {
  cat("\n[M2] GENIE DIAGNOSTIC\n")
  cat(strrep("=", 60), "\n")

  ega_analysis <- run_ega_analysis(E_matrix, items_df)

  final_item_ids <- select_genie_items(
    items_df = items_df,
    subscale_map = subscale_map,
    community_df = ega_analysis$community_df,
    E_matrix = E_matrix,
    api_key = api_key
  )

  final_items_df <- items_df %>%
    dplyr::filter(item_number %in% final_item_ids)

  report <- build_diagnostic_report(
    items_df = items_df,
    community_df = ega_analysis$community_df,
    ega_analysis = ega_analysis,
    final_item_ids = final_item_ids
  )
  cat(report, "\n")

  if (!is.null(structure_log_path)) {
    log_lines <- utils::capture.output(str(ega_analysis))
    writeLines(log_lines, structure_log_path)
  }

  diagnostic <- list(
    final_item_ids = final_item_ids,
    final_n = length(final_item_ids),
    final_items_df = final_items_df,
    initial_communities = ega_analysis$communities,
    ega_analysis = ega_analysis,
    community_df = ega_analysis$community_df
  )

  cat("GENIE diagnostic complete.\n")
  invisible(list(diagnostic = diagnostic, report = report))
}

cat("GENIE diagnostic module loaded.\n")
