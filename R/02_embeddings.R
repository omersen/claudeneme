# ============================================================================
# 02_embeddings.R: EMBEDDING GENERATION
# ============================================================================
request_openai_embeddings <- function(text_vector,
                                      model = EMBEDDING_MODEL,
                                      cache_path = NULL,
                                      use_cache = TRUE) {
  if (!is.null(cache_path) && use_cache && file.exists(cache_path)) {
    cat("Loading cached embeddings from:", cache_path, "\n")
    return(readRDS(cache_path))
  }
  api_key <- assert_openai_key()
  endpoint <- "https://api.openai.com/v1/embeddings"
  cat("Requesting embeddings from OpenAI API...\n")
  cat("Model:", model, "\n")
  cat("Number of items:", length(text_vector), "\n")
  response <- httr2::request(endpoint) %>%
    httr2::req_auth_bearer_token(api_key) %>%
    httr2::req_body_json(list(
      model = model,
      input = as.list(text_vector),
      encoding_format = "float"
    )) %>%
    httr2::req_retry(max_tries = 3, backoff = ~ 2) %>%
    httr2::req_perform()
  result <- httr2::resp_body_json(response)
  embeddings <- do.call(rbind, lapply(result$data, function(x) unlist(x$embedding)))
  embeddings <- unname(embeddings)
  stopifnot(nrow(embeddings) == length(text_vector))
  stopifnot(ncol(embeddings) == EMBEDDING_DIM)
  if (!is.null(cache_path)) {
    saveRDS(embeddings, cache_path)
  }
  cat("Embeddings generated:", nrow(embeddings), "x", ncol(embeddings), "\n")
  invisible(embeddings)
}

l2_normalize <- function(E_matrix) {
  E_matrix <- as.matrix(E_matrix)
  row_norms <- sqrt(rowSums(E_matrix^2))
  if (any(row_norms == 0)) {
    stop("Encountered zero-norm embedding vector.", call. = FALSE)
  }
  E_norm <- E_matrix / row_norms
  norm_check <- sqrt(rowSums(E_norm^2))
  stopifnot(all(abs(norm_check - 1) < 1e-6))
  cat("L2 normalization complete.\n")
  invisible(E_norm)
}

compute_cosine_similarity <- function(E_norm) {
  S_cosine <- E_norm %*% t(E_norm)
  stopifnot(all(abs(diag(S_cosine) - 1) < 1e-6))
  stopifnot(max(abs(S_cosine - t(S_cosine))) < 1e-10)
  cat("Cosine similarity matrix computed:\n")
  cat("Dimensions:", nrow(S_cosine), "x", ncol(S_cosine), "\n")
  invisible(S_cosine)
}

plot_cosine_heatmap <- function(S_cosine, items_df) {
  rownames(S_cosine) <- items_df$item_number
  colnames(S_cosine) <- items_df$item_number
  S_melted <- reshape2::melt(S_cosine)
  colnames(S_melted) <- c("Item1", "Item2", "Cosine")
  ggplot2::ggplot(S_melted, ggplot2::aes(x = Item1, y = Item2, fill = Cosine)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradient2(
      low = "blue",
      mid = "white",
      high = "red",
      midpoint = 0.5,
      limits = c(0, 1)
    ) +
    ggplot2::labs(
      title = "DASS-42 Cosine Similarity Heatmap",
      x = "Item",
      y = "Item"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 6))
}

run_embeddings <- function(items_df, output_dir = "outputs", use_cache = TRUE) {
  cat("\n[M1] EMBEDDING GENERATION\n")
  cat(strrep("=", 60), "\n")
  cache_path <- file.path(output_dir, "data", "01_embeddings.rds")
  E_matrix <- request_openai_embeddings(
    text_vector = items_df$text,
    model = EMBEDDING_MODEL,
    cache_path = cache_path,
    use_cache = use_cache
  )
  rownames(E_matrix) <- as.character(items_df$item_number)
  E_norm <- l2_normalize(E_matrix)
  rownames(E_norm) <- as.character(items_df$item_number)
  S_cosine <- compute_cosine_similarity(E_norm)
  heatmap_plot <- plot_cosine_heatmap(S_cosine, items_df)
  cat("Embedding module complete.\n")
  invisible(list(
    E_matrix = E_matrix,
    E_norm = E_norm,
    S_cosine = S_cosine,
    heatmap_plot = heatmap_plot,
    cache_path = cache_path
  ))
}

cat("Embedding module loaded.\n")
