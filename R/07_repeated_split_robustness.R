# ============================================================================
# 07_repeated_split_robustness.R: REPEATED SPLIT ROBUSTNESS
# ============================================================================
safe_mean <- function(x) {
  if (length(x) == 0 || all(is.na(x))) {
    return(NA_real_)
  }
  mean(x, na.rm = TRUE)
}

evaluate_single_split <- function(split_obj,
                                  dass21_indices,
                                  genie_indices,
                                  subscale_map) {
  psycho_A <- run_psychometric_comparison(
    data_subset = split_obj$data_split_A,
    dass21_indices = dass21_indices,
    genie_indices = genie_indices,
    subscale_map = subscale_map
  )
  psycho_B <- run_psychometric_comparison(
    data_subset = split_obj$data_split_B,
    dass21_indices = dass21_indices,
    genie_indices = genie_indices,
    subscale_map = subscale_map
  )
  # `split_id` is used deliberately; `repeat` is reserved in R and should not be
  # reused as a column name in downstream summaries.
  list(A = psycho_A, B = psycho_B, split_id = split_obj$split_id)
}

summarize_form_stability <- function(split_results, form_name) {
  omega_deltas <- c()
  alpha_deltas <- c()
  cfi_deltas <- c()
  tli_deltas <- c()
  rmsea_deltas <- c()
  srmr_deltas <- c()
  remainder_deltas <- c()
  for (res in split_results) {
    cons_A <- res$A[[form_name]]$consistency
    cons_B <- res$B[[form_name]]$consistency
    if (nrow(cons_A) > 0 && nrow(cons_B) > 0) {
      joined <- cons_A %>%
        dplyr::select(subscale, omega, alpha) %>%
        dplyr::rename(omega_A = omega, alpha_A = alpha) %>%
        dplyr::inner_join(
          cons_B %>%
            dplyr::select(subscale, omega, alpha) %>%
            dplyr::rename(omega_B = omega, alpha_B = alpha),
          by = "subscale"
        )
      omega_deltas <- c(omega_deltas, abs(joined$omega_A - joined$omega_B))
      alpha_deltas <- c(alpha_deltas, abs(joined$alpha_A - joined$alpha_B))
    }
    meas_A <- res$A[[form_name]]$cfa_measures
    meas_B <- res$B[[form_name]]$cfa_measures
    cfi_deltas <- c(cfi_deltas, abs(meas_A["cfi"] - meas_B["cfi"]))
    tli_deltas <- c(tli_deltas, abs(meas_A["tli"] - meas_B["tli"]))
    rmsea_deltas <- c(rmsea_deltas, abs(meas_A["rmsea"] - meas_B["rmsea"]))
    srmr_deltas <- c(srmr_deltas, abs(meas_A["srmr"] - meas_B["srmr"]))
    rem_A <- res$A[[form_name]]$remainder
    rem_B <- res$B[[form_name]]$remainder
    if (nrow(rem_A) > 0 && nrow(rem_B) > 0) {
      joined_rem <- rem_A %>%
        dplyr::select(subscale, remainder_correlation) %>%
        dplyr::rename(rem_A = remainder_correlation) %>%
        dplyr::inner_join(
          rem_B %>%
            dplyr::select(subscale, remainder_correlation) %>%
            dplyr::rename(rem_B = remainder_correlation),
          by = "subscale"
        )
      remainder_deltas <- c(remainder_deltas, abs(joined_rem$rem_A - joined_rem$rem_B))
    }
  }
  summary_row <- data.frame(
    form = form_name,
    median_delta_omega = stats::median(omega_deltas, na.rm = TRUE),
    median_delta_alpha = stats::median(alpha_deltas, na.rm = TRUE),
    median_delta_cfi = stats::median(cfi_deltas, na.rm = TRUE),
    median_delta_tli = stats::median(tli_deltas, na.rm = TRUE),
    median_delta_rmsea = stats::median(rmsea_deltas, na.rm = TRUE),
    median_delta_srmr = stats::median(srmr_deltas, na.rm = TRUE),
    median_delta_remainder = stats::median(remainder_deltas, na.rm = TRUE),
    pass_rate_omega = safe_mean(omega_deltas <= TOLERANCE_OMEGA),
    pass_rate_alpha = safe_mean(alpha_deltas <= TOLERANCE_ALPHA),
    pass_rate_cfi = safe_mean(cfi_deltas <= TOLERANCE_CFI_TLI),
    pass_rate_tli = safe_mean(tli_deltas <= TOLERANCE_CFI_TLI),
    pass_rate_rmsea = safe_mean(rmsea_deltas <= TOLERANCE_RMSEA_SRMR),
    pass_rate_srmr = safe_mean(srmr_deltas <= TOLERANCE_RMSEA_SRMR),
    pass_rate_remainder = safe_mean(remainder_deltas <= TOLERANCE_REMAINDER),
    stringsAsFactors = FALSE
  )
  pass_rates <- c(
    summary_row$pass_rate_omega,
    summary_row$pass_rate_alpha,
    summary_row$pass_rate_cfi,
    summary_row$pass_rate_tli,
    summary_row$pass_rate_rmsea,
    summary_row$pass_rate_srmr,
    summary_row$pass_rate_remainder
  )
  non_na_rates <- pass_rates[!is.na(pass_rates)]
  summary_row$verdict <- if (length(non_na_rates) == 0) {
    "UNSTABLE"
  } else if (mean(non_na_rates) >= 0.80) {
    "STABLE"
  } else {
    "UNSTABLE"
  }
  summary_row
}

run_repeated_split_robustness <- function(split_list,
                                          dass21_indices,
                                          genie_indices,
                                          subscale_map) {
  cat("\n[M6] REPEATED SPLIT ROBUSTNESS\n")
  cat(strrep("=", 60), "\n")
  split_results <- lapply(split_list, function(split_obj) {
    evaluate_single_split(split_obj, dass21_indices, genie_indices, subscale_map)
  })
  summary_table <- dplyr::bind_rows(
    summarize_form_stability(split_results, "DASS42"),
    summarize_form_stability(split_results, "DASS21"),
    summarize_form_stability(split_results, "GENIE")
  )
  list(split_results = split_results, summary = summary_table)
}

cat("Repeated split robustness module loaded.\n")
