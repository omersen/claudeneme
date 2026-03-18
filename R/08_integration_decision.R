# ============================================================================
# 08_integration_decision.R: INTEGRATION AND DECISION
# ============================================================================
get_percentile_value <- function(percentile_df, metric_name) {
  row <- percentile_df %>% dplyr::filter(metric == metric_name)
  if (nrow(row) == 0) return(NA_real_)
  row$percentile[[1]]
}

extract_mean_omega <- function(psycho_result, form_name) {
  cons <- psycho_result[[form_name]]$consistency
  if (nrow(cons) == 0) return(NA_real_)
  mean(cons$omega, na.rm = TRUE)
}

extract_cfa_value <- function(psycho_result, form_name, metric) {
  psycho_result[[form_name]]$cfa_measures[[metric]]
}

extract_mean_remainder <- function(psycho_result, form_name) {
  rem <- psycho_result[[form_name]]$remainder
  if (nrow(rem) == 0) return(NA_real_)
  mean(rem$remainder_correlation, na.rm = TRUE)
}

build_integration_table <- function(semantic_profile,
                                    percentile_dass21,
                                    percentile_genie,
                                    psychometric_results,
                                    robustness_summary) {
  forms <- c("DASS-42", "DASS-21", "GENIE")
  psycho_keys <- c("DASS42", "DASS21", "GENIE")
  rows <- lapply(seq_along(forms), function(i) {
    form_label <- forms[[i]]
    key <- psycho_keys[[i]]
    sem_row <- semantic_profile %>% dplyr::filter(form == form_label)
    rob_row <- robustness_summary %>% dplyr::filter(form == key)
    data.frame(
      Form = form_label,
      SRI = sem_row$SRI[[1]],
      SB = sem_row$SB[[1]],
      CL = sem_row$CL[[1]],
      CC = sem_row$CC[[1]],
      CL_Pct = if (form_label == "GENIE") get_percentile_value(percentile_genie, "CL") else if (form_label == "DASS-21") get_percentile_value(percentile_dass21, "CL") else NA_real_,
      SRI_Pct = if (form_label == "GENIE") get_percentile_value(percentile_genie, "SRI") else if (form_label == "DASS-21") get_percentile_value(percentile_dass21, "SRI") else NA_real_,
      Omega_Mean = extract_mean_omega(psychometric_results, key),
      CFI = extract_cfa_value(psychometric_results, key, "cfi"),
      RMSEA = extract_cfa_value(psychometric_results, key, "rmsea"),
      Remainder_Mean = extract_mean_remainder(psychometric_results, key),
      Stability = if (nrow(rob_row) == 1) rob_row$verdict[[1]] else NA_character_,
      stringsAsFactors = FALSE
    )
  })
  dplyr::bind_rows(rows)
}

create_decision_matrix <- function(integration_table) {
  genie_row <- integration_table %>% dplyr::filter(Form == "GENIE")
  dass21_row <- integration_table %>% dplyr::filter(Form == "DASS-21")
  semantic_advantage <- !is.na(genie_row$CL) && !is.na(dass21_row$CL) && genie_row$CL < dass21_row$CL
  psychometric_ok <- !is.na(genie_row$Omega_Mean) && !is.na(dass21_row$Omega_Mean) &&
    abs(genie_row$Omega_Mean - dass21_row$Omega_Mean) <= TOLERANCE_OMEGA
  stability_ok <- identical(genie_row$Stability, "STABLE")
  decision <- dplyr::case_when(
    semantic_advantage && psychometric_ok && stability_ok ~ "PROMISING",
    semantic_advantage && psychometric_ok && !stability_ok ~ "PROMISING_WITH_CAVEATS",
    semantic_advantage && !psychometric_ok ~ "SEMANTICALLY_PROMISING_BUT_PSYCHOMETRICALLY_WEAK",
    TRUE ~ "NO_CLEAR_ADVANTAGE"
  )
  reasoning <- dplyr::case_when(
    decision == "PROMISING" ~ "GENIE natural form shows lower coverage loss, acceptable psychometric parity, and stable split performance.",
    decision == "PROMISING_WITH_CAVEATS" ~ "GENIE natural form looks promising, but repeated split stability should be improved or interpreted cautiously.",
    decision == "SEMANTICALLY_PROMISING_BUT_PSYCHOMETRICALLY_WEAK" ~ "GENIE natural form improves semantic coverage but does not yet achieve psychometric parity with DASS-21.",
    TRUE ~ "Current evidence does not show a clear advantage over DASS-21."
  )
  data.frame(
    Decision = decision,
    Reasoning = reasoning,
    Semantic_Advantage = semantic_advantage,
    Psychometric_Acceptable = psychometric_ok,
    Split_Stable = stability_ok,
    stringsAsFactors = FALSE
  )
}

generate_verdict <- function(decision_matrix, genie_diagnostic) {
  sprintf(
    paste(
      "===========================================================",
      "FINAL INTEGRATED VERDICT",
      "===========================================================",
      "GENIE natural solution length: %d items",
      "Decision: %s",
      "Reasoning: %s",
      "Next step: %s",
      "===========================================================",
      sep = "\n"
    ),
    genie_diagnostic$final_n,
    decision_matrix$Decision,
    decision_matrix$Reasoning,
    ifelse(
      genie_diagnostic$final_n > 21,
      "Inspect the natural solution first, then decide whether a constrained second phase is needed.",
      "Natural solution can proceed directly to interpretation and reporting."
    )
  )
}

run_integration_decision <- function(semantic_profile,
                                     percentile_dass21,
                                     percentile_genie,
                                     psychometric_results,
                                     robustness_summary,
                                     genie_diagnostic) {
  cat("\n[M7] INTEGRATION AND DECISION\n")
  cat(strrep("=", 60), "\n")
  integration_table <- build_integration_table(
    semantic_profile = semantic_profile,
    percentile_dass21 = percentile_dass21,
    percentile_genie = percentile_genie,
    psychometric_results = psychometric_results,
    robustness_summary = robustness_summary
  )
  decision_matrix <- create_decision_matrix(integration_table)
  verdict <- generate_verdict(decision_matrix, genie_diagnostic)
  cat(verdict, "\n")
  list(
    integration_table = integration_table,
    decision_matrix = decision_matrix,
    verdict = verdict
  )
}

cat("Integration and decision module loaded.\n")
