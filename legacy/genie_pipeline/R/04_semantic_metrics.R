# ============================================================================
# 04_semantic_metrics.R: SEMANTIC METRICS AND COVERAGE
# ============================================================================
compute_semantic_metrics <- function(form_indices,
                                     S_cosine,
                                     E_norm,
                                     community_assignment = NULL) {
  form_indices <- sort(unique(as.integer(form_indices)))
  if (length(form_indices) == 0) {
    return(list(SRI = NA_real_, SB = NA_real_, CL = NA_real_, CC = NA_real_))
  }
  S_sub <- S_cosine[form_indices, form_indices, drop = FALSE]
  upper_tri <- S_sub[upper.tri(S_sub)]
  sri <- if (length(upper_tri) == 0) NA_real_ else mean(upper_tri)
  E_sub <- E_norm[form_indices, , drop = FALSE]
  centroid <- colMeans(E_sub)
  centroid_norm <- sqrt(sum(centroid^2))
  sb <- if (centroid_norm == 0) {
    NA_real_
  } else {
    centroid <- centroid / centroid_norm
    distances <- 1 - as.numeric(E_sub %*% centroid)
    mean(distances)
  }
  n_total <- nrow(S_cosine)
  cl_values <- vapply(seq_len(n_total), function(i) {
    if (i %in% form_indices) {
      return(0)
    }
    1 - max(S_cosine[i, form_indices])
  }, numeric(1))
  cl <- mean(cl_values)
  cc <- NA_real_
  if (!is.null(community_assignment)) {
    community_assignment <- as.vector(community_assignment)
    communities <- unique(community_assignment[!is.na(community_assignment)])
    if (length(communities) > 0) {
      represented <- sum(vapply(communities, function(comm) {
        any(form_indices %in% which(community_assignment == comm))
      }, logical(1)))
      cc <- represented / length(communities)
    }
  }
  list(SRI = sri, SB = sb, CL = cl, CC = cc)
}

compute_item_coverage <- function(S_cosine, form_indices) {
  n_items <- nrow(S_cosine)
  form_indices <- sort(unique(as.integer(form_indices)))
  coverage_loss <- vapply(seq_len(n_items), function(i) {
    if (i %in% form_indices) {
      return(0)
    }
    1 - max(S_cosine[i, form_indices])
  }, numeric(1))
  data.frame(
    item_number = seq_len(n_items),
    coverage_loss = coverage_loss,
    is_selected = seq_len(n_items) %in% form_indices
  )
}

plot_umap_embeddings <- function(E_norm, items_df, selected_ids = NULL) {
  if (!requireNamespace("uwot", quietly = TRUE)) {
    warning("Package 'uwot' not installed; skipping UMAP plot.")
    return(NULL)
  }
  set.seed(SET_SEED)
  umap_coords <- uwot::umap(E_norm, n_neighbors = 10, min_dist = 0.15, metric = "cosine")
  plot_df <- data.frame(
    UMAP1 = umap_coords[, 1],
    UMAP2 = umap_coords[, 2],
    item_number = items_df$item_number,
    subscale = items_df$subscale,
    selected = items_df$item_number %in% selected_ids
  )
  ggplot2::ggplot(plot_df, ggplot2::aes(x = UMAP1, y = UMAP2, color = subscale, shape = selected)) +
    ggplot2::geom_point(size = 3) +
    ggplot2::geom_text(ggplot2::aes(label = item_number), vjust = -0.7, size = 3) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "UMAP of DASS-42 Item Embeddings")
}

build_semantic_profile_table <- function(form_labels, semantic_results) {
  rows <- lapply(seq_along(form_labels), function(i) {
    metrics <- semantic_results[[i]]
    data.frame(
      form = form_labels[[i]],
      SRI = metrics$SRI,
      SB = metrics$SB,
      CL = metrics$CL,
      CC = metrics$CC,
      stringsAsFactors = FALSE
    )
  })
  dplyr::bind_rows(rows)
}

cat("Semantic metrics module loaded.\n")
