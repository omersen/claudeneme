# ============================================================================
# 05_null_benchmark.R: ADAPTIVE NULL BENCHMARK
# ============================================================================
generate_null_form <- function(subscale_map, per_subscale) {
  if (length(per_subscale) == 1) {
    per_subscale <- c(
      Depression = per_subscale,
      Anxiety = per_subscale,
      Stress = per_subscale
    )
  }
  out <- c()
  for (sub in names(per_subscale)) {
    n_select <- per_subscale[[sub]]
    if (n_select == 0) next
    pool <- subscale_map %>%
      dplyr::filter(subscale == sub) %>%
      dplyr::pull(item_number)
    if (n_select > length(pool)) {
      stop("Cannot sample ", n_select, " items from subscale ", sub, call. = FALSE)
    }
    out <- c(out, sample(pool, n_select, replace = FALSE))
  }
  sort(out)
}

run_adaptive_null_benchmark <- function(S_cosine,
                                        E_norm,
                                        subscale_map,
                                        candidate_indices,
                                        community_assignment = NULL,
                                        n_iter = N_NULL_ITERATIONS) {
  cat("\n[M4] ADAPTIVE NULL BENCHMARK\n")
  cat(strrep("=", 60), "\n")
  candidate_composition <- subscale_map %>%
    dplyr::filter(item_number %in% candidate_indices) %>%
    dplyr::count(subscale)
  per_sub <- setNames(candidate_composition$n, candidate_composition$subscale)
  for (sub in c("Depression", "Anxiety", "Stress")) {
    if (is.null(per_sub[[sub]]) || is.na(per_sub[[sub]])) {
      per_sub[[sub]] <- 0
    }
  }
  per_sub <- per_sub[c("Depression", "Anxiety", "Stress")]
  cat("Candidate composition:\n")
  for (sub in names(per_sub)) {
    cat(" ", sub, ":", per_sub[[sub]], "\n")
  }
  set.seed(SET_SEED + 1)
  null_dist <- list(
    SRI = numeric(n_iter),
    SB = numeric(n_iter),
    CL = numeric(n_iter),
    CC = numeric(n_iter)
  )
  for (i in seq_len(n_iter)) {
    null_form <- generate_null_form(subscale_map, per_sub)
    metrics <- compute_semantic_metrics(
      form_indices = null_form,
      S_cosine = S_cosine,
      E_norm = E_norm,
      community_assignment = community_assignment
    )
    null_dist$SRI[i] <- metrics$SRI
    null_dist$SB[i] <- metrics$SB
    null_dist$CL[i] <- metrics$CL
    null_dist$CC[i] <- metrics$CC
    if (i %% 1000 == 0) {
      cat("  Iteration", i, "/", n_iter, "\n")
    }
  }
  list(
    null_dist = null_dist,
    composition = per_sub,
    total_n = sum(per_sub)
  )
}

compute_percentile <- function(observed_metrics, null_distributions) {
  data.frame(
    metric = c("SRI", "SB", "CL", "CC"),
    observed = c(
      observed_metrics$SRI,
      observed_metrics$SB,
      observed_metrics$CL,
      observed_metrics$CC
    ),
    percentile = c(
      mean(null_distributions$SRI <= observed_metrics$SRI, na.rm = TRUE) * 100,
      mean(null_distributions$SB <= observed_metrics$SB, na.rm = TRUE) * 100,
      mean(null_distributions$CL >= observed_metrics$CL, na.rm = TRUE) * 100,
      mean(null_distributions$CC <= observed_metrics$CC, na.rm = TRUE) * 100
    )
  )
}

cat("Adaptive null benchmark module loaded.\n")
