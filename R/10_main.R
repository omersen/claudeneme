# ============================================================================
# 10_main.R: COMPLETE PIPELINE ORCHESTRATOR
# ============================================================================
source_all_modules <- function(r_dir = "R") {
  modules <- c(
    "00_setup.R",
    "01_data_prep.R",
    "02_embeddings.R",
    "03_genie_diagnostic.R",
    "04_semantic_metrics.R",
    "05_null_benchmark.R",
    "06_psychometric_core.R",
    "07_repeated_split_robustness.R",
    "08_integration_decision.R"
  )
  invisible(lapply(modules, function(module) source(file.path(r_dir, module))))
}

main_complete_pipeline <- function(items_csv_path,
                                   data_filepath = NULL,
                                   output_dir = "outputs",
                                   use_cache = TRUE) {
  cat("\n============================================================\n")
  cat(" DASS-42 EMBEDDING-DERIVED NATURAL SHORT FORM PIPELINE\n")
  cat("============================================================\n\n")
  initialize_environment(output_dir = output_dir, auto_install = FALSE, setup_python = TRUE)
  data_prep <- run_data_prep(
    items_csv_path = items_csv_path,
    data_filepath = data_filepath,
    n_split_repeats = N_SPLIT_REPEATS
  )
  embedding_result <- run_embeddings(data_prep$items_df, output_dir = output_dir, use_cache = use_cache)
  ggplot2::ggsave(
    filename = file.path(output_dir, "figures", "01_cosine_heatmap.pdf"),
    plot = embedding_result$heatmap_plot,
    width = 10,
    height = 10
  )
  api_key <- assert_openai_key()
  genie_result <- run_genie_diagnostic(
    items_df = data_prep$items_df,
    subscale_map = data_prep$subscale_map,
    api_key = api_key,
    E_matrix = embedding_result$E_matrix,
    structure_log_path = file.path(output_dir, "logs", "01b_genie_result_structure.txt")
  )
  genie_ids <- genie_result$diagnostic$final_item_ids
  community_assignment <- genie_result$diagnostic$initial_communities
  semantic_dass42 <- compute_semantic_metrics(1:42, embedding_result$S_cosine, embedding_result$E_norm, community_assignment)
  semantic_dass21 <- compute_semantic_metrics(data_prep$dass21_indices, embedding_result$S_cosine, embedding_result$E_norm, community_assignment)
  semantic_genie <- compute_semantic_metrics(genie_ids, embedding_result$S_cosine, embedding_result$E_norm, community_assignment)
  semantic_profile <- build_semantic_profile_table(
    form_labels = c("DASS-42", "DASS-21", "GENIE"),
    semantic_results = list(semantic_dass42, semantic_dass21, semantic_genie)
  )
  coverage_table <- compute_item_coverage(embedding_result$S_cosine, genie_ids)
  write.csv(coverage_table, file.path(output_dir, "tables", "04_item_coverage.csv"), row.names = FALSE)
  adaptive_null_dass21 <- run_adaptive_null_benchmark(
    S_cosine = embedding_result$S_cosine,
    E_norm = embedding_result$E_norm,
    subscale_map = data_prep$subscale_map,
    candidate_indices = data_prep$dass21_indices,
    community_assignment = community_assignment,
    n_iter = N_NULL_ITERATIONS
  )
  adaptive_null <- run_adaptive_null_benchmark(
    S_cosine = embedding_result$S_cosine,
    E_norm = embedding_result$E_norm,
    subscale_map = data_prep$subscale_map,
    candidate_indices = genie_ids,
    community_assignment = community_assignment,
    n_iter = N_NULL_ITERATIONS
  )
  percentile_dass21 <- compute_percentile(semantic_dass21, adaptive_null_dass21$null_dist)
  percentile_genie <- compute_percentile(semantic_genie, adaptive_null$null_dist)
  write.csv(semantic_profile, file.path(output_dir, "tables", "05_semantic_profile.csv"), row.names = FALSE)
  write.csv(percentile_dass21, file.path(output_dir, "tables", "06_adaptive_percentiles_dass21.csv"), row.names = FALSE)
  write.csv(percentile_genie, file.path(output_dir, "tables", "07_adaptive_percentiles_genie.csv"), row.names = FALSE)
  write.csv(genie_result$diagnostic$final_items_df, file.path(output_dir, "tables", "03_genie_final_items.csv"), row.names = FALSE)
  writeLines(genie_result$report, file.path(output_dir, "logs", "02_genie_diagnostic_report.txt"))
  if (is.null(data_prep$data_clean)) {
    cat("No response dataset provided; semantic stage complete.\n")
    return(list(
      data_prep = data_prep,
      embeddings = embedding_result,
      genie = genie_result,
      semantic_profile = semantic_profile,
      adaptive_null_dass21 = adaptive_null_dass21,
      adaptive_null = adaptive_null,
      percentile_dass21 = percentile_dass21,
      percentile_genie = percentile_genie
    ))
  }
  psychometric_results <- run_psychometric_comparison(
    data_subset = data_prep$data_clean,
    dass21_indices = data_prep$dass21_indices,
    genie_indices = genie_ids,
    subscale_map = data_prep$subscale_map
  )
  robustness <- run_repeated_split_robustness(
    split_list = data_prep$split_list,
    dass21_indices = data_prep$dass21_indices,
    genie_indices = genie_ids,
    subscale_map = data_prep$subscale_map
  )
  integration <- run_integration_decision(
    semantic_profile = semantic_profile,
    percentile_dass21 = percentile_dass21,
    percentile_genie = percentile_genie,
    psychometric_results = psychometric_results,
    robustness_summary = robustness$summary,
    genie_diagnostic = genie_result$diagnostic
  )
  psychometric_summary <- dplyr::bind_rows(
    psychometric_results$DASS42$consistency,
    psychometric_results$DASS21$consistency,
    psychometric_results$GENIE$consistency
  )
  write.csv(psychometric_summary, file.path(output_dir, "tables", "08_psychometric_consistency.csv"), row.names = FALSE)
  write.csv(robustness$summary, file.path(output_dir, "tables", "09_repeated_split_summary.csv"), row.names = FALSE)
  write.csv(integration$integration_table, file.path(output_dir, "tables", "10_integration_table.csv"), row.names = FALSE)
  write.csv(integration$decision_matrix, file.path(output_dir, "tables", "11_decision_matrix.csv"), row.names = FALSE)
  writeLines(integration$verdict, file.path(output_dir, "logs", "12_final_verdict.txt"))
  list(
    data_prep = data_prep,
    embeddings = embedding_result,
    genie = genie_result,
    semantic_profile = semantic_profile,
    adaptive_null_dass21 = adaptive_null_dass21,
    adaptive_null = adaptive_null,
    percentile_dass21 = percentile_dass21,
    percentile_genie = percentile_genie,
    psychometric_results = psychometric_results,
    robustness = robustness,
    integration = integration
  )
}

cat("Main pipeline module loaded.\n")
