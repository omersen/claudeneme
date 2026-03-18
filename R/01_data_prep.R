# ============================================================================
# 01_data_prep.R: DATA PREPARATION
# ============================================================================
normalize_in_dass21 <- function(x) {
  if (is.logical(x)) return(x)
  x_chr <- tolower(trimws(as.character(x)))
  x_chr %in% c("1", "true", "t", "yes", "y")
}

load_dass42_items <- function(items_csv_path) {
  if (!file.exists(items_csv_path)) {
    stop("Items file not found: ", items_csv_path, call. = FALSE)
  }
  items_df <- read.csv(items_csv_path, stringsAsFactors = FALSE)
  required_cols <- c("item_id", "text", "subscale", "in_dass21")
  missing_cols <- setdiff(required_cols, colnames(items_df))
  if (length(missing_cols) > 0) {
    stop(
      "Missing required columns in items CSV: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  items_df <- items_df %>%
    dplyr::rename(item_number = item_id) %>%
    dplyr::mutate(
      item_number = as.integer(item_number),
      in_dass21 = normalize_in_dass21(in_dass21),
      subscale = as.character(subscale),
      text = as.character(text)
    ) %>%
    dplyr::arrange(item_number)
  stopifnot(nrow(items_df) == 42)
  stopifnot(identical(sort(unique(items_df$subscale)), c("Anxiety", "Depression", "Stress")))
  stopifnot(all(items_df %>% dplyr::count(subscale) %>% dplyr::pull(n) == 14))
  stopifnot(identical(items_df$item_number, 1:42))
  cat("DASS-42 item map loaded successfully.\n")
  invisible(items_df)
}

get_dass21_indices <- function(items_df) {
  dass21_indices <- items_df %>%
    dplyr::filter(in_dass21) %>%
    dplyr::pull(item_number) %>%
    sort()
  stopifnot(length(dass21_indices) == 21)
  subscale_counts <- items_df %>%
    dplyr::filter(item_number %in% dass21_indices) %>%
    dplyr::count(subscale)
  stopifnot(all(subscale_counts$n == 7))
  cat("DASS-21 reference indices extracted.\n")
  invisible(dass21_indices)
}

load_and_clean_data <- function(filepath) {
  if (!file.exists(filepath)) {
    stop("Data file not found: ", filepath, call. = FALSE)
  }
  data_raw <- read.csv(filepath)
  cat("Raw data dimensions:", nrow(data_raw), "x", ncol(data_raw), "\n")
  if (ncol(data_raw) != 42) {
    stop("Expected 42 item columns, got ", ncol(data_raw), call. = FALSE)
  }
  colnames(data_raw) <- paste0("item_", seq_len(42))
  data_clean <- na.omit(data_raw)
  cat("After listwise deletion:", nrow(data_clean), "rows\n")
  constant_rows <- apply(data_clean, 1, function(x) length(unique(x)) == 1)
  if (any(constant_rows)) {
    cat("Removing", sum(constant_rows), "constant-response rows\n")
    data_clean <- data_clean[!constant_rows, , drop = FALSE]
  }
  value_range <- range(unlist(data_clean), na.rm = TRUE)
  if (value_range[1] < 0 || value_range[2] > 4) {
    warning(
      "Observed values outside expected DASS range [0, 4]: [",
      value_range[1], ", ", value_range[2], "]"
    )
  }
  cat("Final cleaned data:", nrow(data_clean), "rows\n")
  invisible(data_clean)
}

create_repeated_splits <- function(data_clean,
                                   n_repeats = N_SPLIT_REPEATS,
                                   seed = SET_SEED) {
  set.seed(seed)
  n_total <- nrow(data_clean)
  if (n_total < 20) {
    stop("Not enough observations to create repeated splits.", call. = FALSE)
  }
  split_list <- vector("list", n_repeats)
  for (i in seq_len(n_repeats)) {
    idx_a <- sample(seq_len(n_total), floor(n_total / 2), replace = FALSE)
    idx_b <- setdiff(seq_len(n_total), idx_a)
    split_list[[i]] <- list(
      split_id = i,
      idx_a = idx_a,
      idx_b = idx_b,
      data_split_A = data_clean[idx_a, , drop = FALSE],
      data_split_B = data_clean[idx_b, , drop = FALSE]
    )
  }
  cat("Created", n_repeats, "repeated random splits.\n")
  invisible(split_list)
}

run_data_prep <- function(items_csv_path,
                          data_filepath = NULL,
                          n_split_repeats = N_SPLIT_REPEATS) {
  cat("\n[M0] DATA PREPARATION\n")
  cat(strrep("=", 60), "\n")
  items_df <- load_dass42_items(items_csv_path)
  subscale_map <- items_df %>% dplyr::select(item_number, subscale)
  dass21_indices <- get_dass21_indices(items_df)
  result <- list(
    items_df = items_df,
    subscale_map = subscale_map,
    dass21_indices = dass21_indices
  )
  if (!is.null(data_filepath)) {
    data_clean <- load_and_clean_data(data_filepath)
    split_list <- create_repeated_splits(data_clean, n_repeats = n_split_repeats)
    result$data_clean <- data_clean
    result$split_list <- split_list
  }
  cat("Data preparation complete.\n")
  invisible(result)
}

cat("Data prep module loaded.\n")
