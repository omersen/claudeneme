# =============================================================================
# 07_bootstrap.R
# Eslestirilmis kisi bootstrap'i (dogrulama yarisi, B tekrar):
#   yeni form - PUB21 farklari icin noktasal %95 yuzdelik araliklari
#   - ham alfa farki (AS2)
#   - ham RMSE farki, kalan-madde korelasyonu farki (AS3)
#   - EAP RMSE farki (AS3; mirt varsa; kalibrasyon sabit, model yeniden kestirilmez)
# Madde secimi ve EAP kalibrasyonu sabittir; araliklar kosulludur ve coklu karsilastirma
# duzeltmesi icermez. Sifiri kapsayan aralik esdegerlik kaniti degildir.
# =============================================================================
log_event("STAGE", "paired participant bootstrap of differences versus PUB21")

metric_vector <- function(ix) {
  result <- numeric(0)
  for (f in names(key42)) {
    pool <- forms$FULL42[[f]]
    full <- scores[[f]]$FULL42; pub <- scores[[f]]$PUB21
    pub_alpha <- alpha_raw(p$val[ix, forms$PUB21[[f]], drop = FALSE])
    pub_raw_rmse <- sqrt(mean((pub$raw[ix] - full$raw[ix])^2))
    pub_rest <- rowMeans(p$val[ix, setdiff(pool, forms$PUB21[[f]]), drop = FALSE])
    pub_r_rest <- stats::cor(pub$raw[ix], pub_rest)
    if (grm_available) pub_eap_rmse <- sqrt(mean((pub$eap[ix] - full$eap[ix])^2))
    for (nm in new_forms) {
      z <- scores[[f]][[nm]]
      rest <- rowMeans(p$val[ix, setdiff(pool, forms[[nm]][[f]]), drop = FALSE])
      result[paste("AS2", f, nm, "alpha_raw_delta", sep = "__")] <-
        alpha_raw(p$val[ix, forms[[nm]][[f]], drop = FALSE]) - pub_alpha
      result[paste("AS3", f, nm, "raw_RMSE_delta", sep = "__")] <-
        sqrt(mean((z$raw[ix] - full$raw[ix])^2)) - pub_raw_rmse
      result[paste("AS3", f, nm, "r_remaining_delta", sep = "__")] <-
        stats::cor(z$raw[ix], rest) - pub_r_rest
      if (grm_available)
        result[paste("AS3", f, nm, "eap_RMSE_delta", sep = "__")] <-
          sqrt(mean((z$eap[ix] - full$eap[ix])^2)) - pub_eap_rmse
    }
  }
  result
}
point <- metric_vector(seq_len(nrow(p$val)))
B <- cfg$bootstrap_B; n <- nrow(p$val)
boot <- matrix(NA_real_, nrow = B, ncol = length(point), dimnames = list(NULL, names(point)))
for (b in seq_len(B)) {
  set.seed(cfg$seed_bootstrap + b)
  boot[b, ] <- metric_vector(sample.int(n, n, replace = TRUE))
  if (b %% 250L == 0L) log_event("BOOTSTRAP", b, "of", B)
}
check("bootstrap_all_draws_finite", nrow(boot) == B && all(is.finite(boot)))
limits <- apply(boot, 2, stats::quantile, probs = c(0.025, 0.975), names = FALSE, type = 7)
parts <- strsplit(names(point), "__", fixed = TRUE)
ci <- data.frame(question = vapply(parts, `[`, character(1), 1), subscale = vapply(parts, `[`, character(1), 2),
  form = vapply(parts, `[`, character(1), 3), metric = vapply(parts, `[`, character(1), 4),
  reference_form = "PUB21", estimate = unname(point), lower = limits[1, ], upper = limits[2, ],
  B = B, interval = "pointwise_percentile_95_type7", resampling_unit = "validation_participant_row",
  conditioning = "fixed item sets; EAP fixed calibration; no model refit", multiplicity_adjusted = FALSE,
  stringsAsFactors = FALSE)
csv_out(ci, "BOOT_paired_differences_vs_PUB21.csv")
csv_out(data.frame(draw = seq_len(B), boot, check.names = FALSE), "BOOT_draws.csv")
jsonlite::write_json(list(B = B, seed_rule = "seed_bootstrap + draw_number", seed_bootstrap = cfg$seed_bootstrap,
  paired = TRUE, models_refitted = FALSE, pointwise_confidence = 0.95, quantile_type = 7,
  multiplicity_adjusted = FALSE, n_intervals = nrow(ci),
  interpretation = "Differences relative to PUB21, conditional on this selection and calibration; not omega or information intervals."),
  file.path(out, "bootstrap_scope.json"), pretty = TRUE, auto_unbox = TRUE)
log_event("BOOTSTRAP_COMPLETE", nrow(ci), "intervals")
