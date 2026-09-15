# ============================================================================
# 06_psychometric_core.R: CORE PSYCHOMETRIC COMPARISON
# ============================================================================
MIN_ITEMS_CFA <- 3
MIN_ITEMS_OMEGA <- 3
MIN_ITEMS_CITC <- 3

compute_citc <- function(data_subset, form_indices, subscale_map) {
  out <- list()
  for (sub in c("Depression", "Anxiety", "Stress")) {
    sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub, item_number %in% form_indices) %>%
      dplyr::pull(item_number)
    if (length(sub_items) < MIN_ITEMS_CITC) {
      next
    }
    data_sub <- data_subset[, paste0("item_", sub_items), drop = FALSE]
    citc_values <- vapply(seq_along(sub_items), function(j) {
      item_score <- data_sub[[j]]
      rest_score <- rowSums(data_sub[, -j, drop = FALSE], na.rm = TRUE)
      stats::cor(item_score, rest_score, use = "complete.obs")
    }, numeric(1))
    out[[sub]] <- data.frame(
      subscale = sub,
      item_number = sub_items,
      citc = citc_values
    )
  }
  if (length(out) == 0) return(data.frame())
  dplyr::bind_rows(out)
}

compute_consistency <- function(data_subset, form_indices, subscale_map) {
  out <- list()
  for (sub in c("Depression", "Anxiety", "Stress")) {
    sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub, item_number %in% form_indices) %>%
      dplyr::pull(item_number)
    if (length(sub_items) < MIN_ITEMS_OMEGA) {
      next
    }
    data_sub <- data_subset[, paste0("item_", sub_items), drop = FALSE]
    omega_val <- tryCatch({
      psych::omega(data_sub, plot = FALSE, warnings = FALSE)$omega.tot
    }, error = function(e) NA_real_)
    alpha_val <- tryCatch({
      psych::alpha(data_sub, check.keys = FALSE, warnings = FALSE)$total$raw_alpha
    }, error = function(e) NA_real_)
    out[[sub]] <- data.frame(
      subscale = sub,
      omega = omega_val,
      alpha = alpha_val,
      n_items = length(sub_items)
    )
  }
  if (length(out) == 0) return(data.frame())
  dplyr::bind_rows(out)
}

generate_cfa_syntax <- function(form_indices, subscale_map) {
  lines <- c()
  for (sub in c("Depression", "Anxiety", "Stress")) {
    sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub, item_number %in% form_indices) %>%
      dplyr::pull(item_number)
    if (length(sub_items) < MIN_ITEMS_CFA) {
      return(NULL)
    }
    lines <- c(lines, paste0(sub, " =~ ", paste0("item_", sub_items, collapse = " + ")))
  }
  paste(lines, collapse = "\n")
}

fit_cfa <- function(data_subset, form_indices, subscale_map) {
  syntax <- generate_cfa_syntax(form_indices, subscale_map)
  if (is.null(syntax)) {
    return(list(
      fit = NULL,
      measures = c(cfi = NA_real_, tli = NA_real_, rmsea = NA_real_, srmr = NA_real_)
    ))
  }
  form_cols <- paste0("item_", form_indices)
  missing_cols <- setdiff(form_cols, colnames(data_subset))
  if (length(missing_cols) > 0) {
    stop("Missing columns in data for CFA: ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }
  data_form <- data_subset[, form_cols, drop = FALSE]
  fit <- tryCatch({
    lavaan::cfa(
      model = syntax,
      data = data_form,
      estimator = "WLSMV",
      ordered = colnames(data_form),
      std.lv = TRUE
    )
  }, error = function(e) NULL)
  if (is.null(fit)) {
    return(list(
      fit = NULL,
      measures = c(cfi = NA_real_, tli = NA_real_, rmsea = NA_real_, srmr = NA_real_)
    ))
  }
  measures <- tryCatch({
    lavaan::fitMeasures(fit, c("cfi", "tli", "rmsea", "srmr"))
  }, error = function(e) c(cfi = NA_real_, tli = NA_real_, rmsea = NA_real_, srmr = NA_real_))
  list(fit = fit, measures = measures)
}

compute_remainder <- function(data_subset, form_indices, subscale_map) {
  out <- list()
  for (sub in c("Depression", "Anxiety", "Stress")) {
    form_sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub, item_number %in% form_indices) %>%
      dplyr::pull(item_number)
    full_sub_items <- subscale_map %>%
      dplyr::filter(subscale == sub) %>%
      dplyr::pull(item_number)
    remainder_items <- setdiff(full_sub_items, form_sub_items)
    if (length(form_sub_items) == 0 || length(remainder_items) == 0) {
      out[[sub]] <- data.frame(
        subscale = sub,
        remainder_correlation = NA_real_,
        n_form_items = length(form_sub_items),
        n_remainder_items = length(remainder_items)
      )
      next
    }
    form_score <- rowMeans(data_subset[, paste0("item_", form_sub_items), drop = FALSE], na.rm = TRUE)
    remainder_score <- rowMeans(data_subset[, paste0("item_", remainder_items), drop = FALSE], na.rm = TRUE)
    out[[sub]] <- data.frame(
      subscale = sub,
      remainder_correlation = stats::cor(form_score, remainder_score, use = "complete.obs"),
      n_form_items = length(form_sub_items),
      n_remainder_items = length(remainder_items)
    )
  }
  dplyr::bind_rows(out)
}

compute_psychometric_profile <- function(data_subset, form_indices, subscale_map, form_name) {
  consistency <- compute_consistency(data_subset, form_indices, subscale_map)
  if (nrow(consistency) > 0) consistency$form <- form_name
  citc <- compute_citc(data_subset, form_indices, subscale_map)
  if (nrow(citc) > 0) citc$form <- form_name
  cfa_result <- fit_cfa(data_subset, form_indices, subscale_map)
  remainder <- compute_remainder(data_subset, form_indices, subscale_map)
  if (nrow(remainder) > 0) remainder$form <- form_name
  list(
    consistency = consistency,
    citc = citc,
    cfa_fit = cfa_result$fit,
    cfa_measures = cfa_result$measures,
    remainder = remainder
  )
}

run_psychometric_comparison <- function(data_subset,
                                        dass21_indices,
                                        genie_indices,
                                        subscale_map) {
  cat("\n[M5] PSYCHOMETRIC ANALYSIS\n")
  cat(strrep("=", 60), "\n")
  list(
    DASS42 = compute_psychometric_profile(data_subset, 1:42, subscale_map, "DASS-42"),
    DASS21 = compute_psychometric_profile(data_subset, dass21_indices, subscale_map, "DASS-21"),
    GENIE = compute_psychometric_profile(data_subset, genie_indices, subscale_map, "GENIE")
  )
}

cat("Psychometric core module loaded.\n")
