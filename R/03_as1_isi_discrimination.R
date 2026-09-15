# =============================================================================
# 03_as1_isi_discrimination.R
# AS1: Alt boyut icinde madde anlamsal benzerligi (ISI) ile madde ayirt ediciligi.
#   Ana gosterge      : duzeltilmis madde-toplam korelasyonu (CITC), 14 maddelik alt boyut,
#                       kalibrasyon yarisi; Spearman rho + 2000 kisi bootstrap GA
#   Ikincil gosterge  : GRM a parametresi (mirt kuruluysa); nokta kestirimi, modele kosullu
#   Destekleyici      : kosinus ile polikorik matrislerin Mantel karsilastirmasi
#   Kontrol           : madde uzunlugu (sozcuk sayisi) kismi korelasyonu
# =============================================================================
log_event("STAGE", "AS1 ISI versus discrimination (calibration half)")

isi_tab <- sel$ISI
wc_tab  <- p$items$word_count; names(wc_tab) <- p$items$item_id
as1_rows <- item_rows <- boot_rows <- list()
B <- cfg$bootstrap_B; n_cal <- nrow(p$cal)

for (f in names(key42)) {
  pool <- forms$FULL42[[f]]; Xf <- p$cal[, pool, drop = FALSE]
  isi  <- isi_tab$ISI[match(pool, isi_tab$item_id)]
  citc <- citc_values(Xf)
  wc   <- wc_tab[pool]
  rho_citc <- spearman(isi, citc)
  rho_citc_partial_wc <- partial_spearman(isi, citc, wc)
  rho_isi_wc <- spearman(isi, wc)

  # Eslestirilmis kisi bootstrap'i: CITC her tekrarda yeniden hesaplanir, ISI sabittir
  draws <- numeric(B)
  for (b in seq_len(B)) {
    set.seed(cfg$seed_bootstrap + b)
    ix <- sample.int(n_cal, n_cal, replace = TRUE)
    draws[b] <- spearman(isi, citc_values(Xf[ix, , drop = FALSE]))
  }
  ci <- stats::quantile(draws, c(0.025, 0.975), names = FALSE, type = 7)
  boot_rows[[f]] <- data.frame(subscale = f, draw = seq_len(B), rho_ISI_CITC = draws)

  item_rows[[f]] <- data.frame(item_id = pool, subscale = f, ISI = isi, CITC_full14_calibration = citc,
                               word_count = as.integer(wc), stringsAsFactors = FALSE)
  as1_rows[[f]] <- data.frame(
    subscale = f, n_items = length(pool), sample = "calibration",
    rho_ISI_CITC = rho_citc, rho_ISI_CITC_lower = ci[1], rho_ISI_CITC_upper = ci[2],
    rho_ISI_CITC_partial_wordcount = rho_citc_partial_wc, rho_ISI_wordcount = rho_isi_wc,
    bootstrap = "2000 paired participant draws; ISI fixed; percentile 95% interval",
    inference_note = "14 fixed items per subscale; interval reflects respondent sampling only, not item sampling")
}
as1 <- do.call(rbind, as1_rows)

# --- Ikincil: GRM a parametresi (mirt) ----------------------------------------------
grm_available <- isTRUE(cfg$run_grm) && has_pkg("mirt")
cal_grm <- list(); grm_param_rows <- diag_rows <- list()
as1$rho_ISI_GRM_a <- NA_real_; as1$rho_ISI_GRM_a_partial_wordcount <- NA_real_
if (grm_available) {
  for (f in names(key42)) {
    pool <- forms$FULL42[[f]]
    log_event("FIT_GRM_START", f, "calibration")
    cal_grm[[f]] <- fit_grm(p$cal[, pool, drop = FALSE])
    saveRDS(cal_grm[[f]], file.path(out, "models", paste0("GRM_", f, "_calibration.rds")))
    z <- grm_parameters(cal_grm[[f]]); z$subscale <- f; z$sample <- "calibration"
    grm_param_rows[[f]] <- z
    diag_rows[[f]] <- grm_diagnostics(cal_grm[[f]], paste0(f, "_calibration"))
    item_rows[[f]]$a_GRM_calibration <- z$a[match(pool, z$item_id)]
    as1$rho_ISI_GRM_a[as1$subscale == f] <- spearman(item_rows[[f]]$ISI, item_rows[[f]]$a_GRM_calibration)
    as1$rho_ISI_GRM_a_partial_wordcount[as1$subscale == f] <-
      partial_spearman(item_rows[[f]]$ISI, item_rows[[f]]$a_GRM_calibration, item_rows[[f]]$word_count)
    log_event("FIT_GRM_DONE", f, "calibration")
  }
  as1$GRM_note <- "point estimate only; conditional on unidimensional GRM fit (see GRM_diagnostics_calibration.csv)"
  csv_out(do.call(rbind, grm_param_rows), "AS1_GRM_parameters_calibration.csv")
  csv_out(do.call(rbind, diag_rows), "GRM_diagnostics_calibration.csv")
} else {
  as1$GRM_note <- if (isTRUE(cfg$run_grm)) "mirt not installed; GRM stage skipped" else "run_grm = FALSE"
  log_event("GRM_SKIPPED", as1$GRM_note[1])
}
csv_out(as1, "AS1_ISI_discrimination.csv")
csv_out(do.call(rbind, item_rows), "AS1_item_level.csv")
csv_out(do.call(rbind, boot_rows), "AS1_bootstrap_draws.csv")

# --- Destekleyici: kosinus - polikorik Mantel ----------------------------------------
mantel_rows <- pair_rows <- list()
for (f in names(key42)) {
  pool <- forms$FULL42[[f]]; Cf <- C[pool, pool, drop = FALSE]
  poly <- polychoric_matrix(p$cal, pool)
  check(paste0("polychoric_matrix_", f), all(is.finite(poly)) && max(abs(poly - t(poly))) < 1e-12)
  csv_out(data.frame(item_id = pool, poly, check.names = FALSE), paste0("AS1_polychoric_", f, ".csv"))
  tri <- upper.tri(Cf); ij <- which(tri, arr.ind = TRUE)
  pair_rows[[f]] <- data.frame(subscale = f, item_i = pool[ij[, 1]], item_j = pool[ij[, 2]],
                               cosine = Cf[tri], polychoric = poly[tri])
  observed <- spearman(Cf[tri], poly[tri])
  set.seed(cfg$seed_mantel + match(f, names(key42)))
  draws <- vapply(seq_len(cfg$mantel_permutations), function(b) {
    pm <- sample.int(length(pool)); spearman(Cf[tri], poly[pm, pm][tri])
  }, numeric(1))
  mantel_rows[[f]] <- data.frame(subscale = f, n_items = 14L, n_pairs = 91L,
    rho_semantic_polychoric = observed, permutations = length(draws),
    p_permutation = (1 + sum(abs(draws) >= abs(observed) - 1e-12)) / (length(draws) + 1),
    sidedness = "two_sided_absolute", sample = "calibration")
}
mantel <- do.call(rbind, mantel_rows); mantel$p_Holm <- stats::p.adjust(mantel$p_permutation, method = "holm")
csv_out(mantel, "AS1_semantic_polychoric_Mantel.csv")
csv_out(do.call(rbind, pair_rows), "AS1_semantic_polychoric_pairs.csv")
log_event("AS1_COMPLETE")
