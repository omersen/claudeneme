# =============================================================================
# 04_as2_structure_reliability.R
# AS2: Dogrulama yarisinda bes form icin
#   - uc iliskili faktorlu ordinal DFA (WLSMV): olcekli uyum, yukler, faktor korelasyonlari
#   - PUB21'e gore delta CFI / delta RMSEA (betimsel; pratik esikler karar kurali degildir)
#   - ordinal omega (semTools::compRelSEM, ord.scale = TRUE; obs.var duyarliligi ayri)
#   - ham alfa, duzeltilmis madde-toplam korelasyonlari, ortalama madde ici korelasyon
#   - test bilgisi: dogrulama yarisinda tam 14 maddelik GRM, secili maddelerin bilgi toplami (mirt)
# =============================================================================
log_event("STAGE", "AS2 structure, reliability and information (validation half)")
dir.create(file.path(out, "models"), showWarnings = FALSE)

cfas <- list(); fit_rows <- rel_rows <- citc_rows <- conv_rows <- list()
take <- c("chisq.scaled", "df.scaled", "pvalue.scaled", "cfi.scaled", "tli.scaled",
          "rmsea.scaled", "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr")
for (nm in form_names) {
  log_event("FIT_CFA_START", nm)
  cfas[[nm]] <- fit_cfa(p$val, forms[[nm]])
  saveRDS(cfas[[nm]], file.path(out, "models", paste0("CFA_", nm, ".rds")))
  fm <- logged(lavaan::fitMeasures(cfas[[nm]]))
  fit_rows[[nm]] <- data.frame(form = nm, n_items = length(unlist(forms[[nm]])), t(as.numeric(fm[take])),
                               estimator = "WLSMV", sample = "validation")
  names(fit_rows[[nm]])[3:(2 + length(take))] <- take
  om_main <- omega_values(cfas[[nm]], obs.var = FALSE)
  om_sens <- omega_values(cfas[[nm]], obs.var = TRUE)
  rel_rows[[nm]] <- data.frame(
    form = nm, subscale = names(key42), n_items = as.integer(lengths(forms[[nm]])),
    omega_ordinal = as.numeric(om_main), omega_ordinal_obs_var = as.numeric(om_sens),
    alpha_raw = vapply(names(key42), function(f) alpha_raw(p$val[, forms[[nm]][[f]], drop = FALSE]), numeric(1)),
    mean_interitem_r = vapply(names(key42), function(f) mean_interitem_r(p$val[, forms[[nm]][[f]], drop = FALSE]), numeric(1)))
  rel_rows[[nm]]$redundancy_flag <- rel_rows[[nm]]$mean_interitem_r > cfg$mic_flag
  for (f in names(key42)) {
    ids <- forms[[nm]][[f]]
    citc_rows[[paste(nm, f)]] <- data.frame(form = nm, subscale = f, item_id = ids,
                                            corrected_item_total_r = citc_values(p$val[, ids, drop = FALSE]))
  }
  csv_out(lavaan::standardizedSolution(cfas[[nm]]), paste0("AS2_loadings_", nm, ".csv"))
  lv <- lavaan::lavInspect(cfas[[nm]], "cor.lv")
  csv_out(data.frame(factor = rownames(lv), lv), paste0("AS2_factor_correlations_", nm, ".csv"))
  conv_rows[[nm]] <- data.frame(model = paste0("CFA_", nm), family = "CFA", sample = "validation",
    converged = isTRUE(lavaan::lavInspect(cfas[[nm]], "converged")),
    admissible = isTRUE(logged(lavaan::lavInspect(cfas[[nm]], "post.check"))))
  log_event("FIT_CFA_DONE", nm)
}
fit <- do.call(rbind, fit_rows)
ref <- fit[fit$form == "PUB21", ]
fit$delta_CFI_vs_PUB21   <- fit$cfi.scaled - ref$cfi.scaled
fit$delta_RMSEA_vs_PUB21 <- fit$rmsea.scaled - ref$rmsea.scaled
fit$exceeds_descriptive_threshold <- abs(fit$delta_CFI_vs_PUB21) > cfg$delta_cfi | abs(fit$delta_RMSEA_vs_PUB21) > cfg$delta_rmsea
fit$threshold_note <- "delta thresholds (0.010 CFI, 0.015 RMSEA) are descriptive; models use different observed items, no nested test"
fit$exceeds_descriptive_threshold[fit$form %in% c("FULL42", "PUB21")] <- NA
csv_out(fit, "AS2_CFA_fit.csv")
rel <- do.call(rbind, rel_rows)
rel$delta_omega_vs_PUB21 <- rel$omega_ordinal - rel$omega_ordinal[match(paste("PUB21", rel$subscale), paste(rel$form, rel$subscale))]
rel$delta_alpha_vs_PUB21 <- rel$alpha_raw - rel$alpha_raw[match(paste("PUB21", rel$subscale), paste(rel$form, rel$subscale))]
csv_out(rel, "AS2_reliability.csv")
csv_out(do.call(rbind, citc_rows), "AS2_corrected_item_total_correlations.csv")

# --- Test bilgisi (mirt) ---------------------------------------------------------------
val_grm <- list(); curves <- weighted_rows <- diag_rows <- list()
if (grm_available) {
  for (f in names(key42)) {
    pool <- forms$FULL42[[f]]
    log_event("FIT_GRM_START", f, "validation")
    val_grm[[f]] <- fit_grm(p$val[, pool, drop = FALSE])
    saveRDS(val_grm[[f]], file.path(out, "models", paste0("GRM_", f, "_validation.rds")))
    z <- grm_parameters(val_grm[[f]])
    diag_rows[[f]] <- grm_diagnostics(val_grm[[f]], paste0(f, "_validation"))
    conv_rows[[paste("GRM", f)]] <- data.frame(model = paste0("GRM_", f, "_validation"), family = "GRM",
      sample = "validation", converged = isTRUE(mirt::extract.mirt(val_grm[[f]], "converged")),
      admissible = all(is.finite(z$a) & z$a > 0))
    Ifull <- information(val_grm[[f]], pool, pool)
    for (nm in form_names) {
      I <- information(val_grm[[f]], forms[[nm]][[f]], pool)
      check(paste0("short_information_le_full_", f, "_", nm), all(I <= Ifull + 1e-7) && all(I > 0))
      curves[[paste(f, nm)]] <- data.frame(subscale = f, form = nm, theta = cfg$theta, information = I,
                                           SEM = 1 / sqrt(I), information_retained = I / Ifull)
      weighted_rows[[paste(f, nm)]] <- data.frame(subscale = f, form = nm, weighted_information = weighted_info(I),
        weighting = "standard normal on theta grid -2..2", calibration = "validation full14 GRM",
        interpretation = "conditional on GRM fit")
    }
    log_event("FIT_GRM_DONE", f, "validation")
  }
  wt <- do.call(rbind, weighted_rows)
  wt$delta_vs_PUB21 <- wt$weighted_information - wt$weighted_information[match(paste("PUB21", wt$subscale), paste(wt$form, wt$subscale))]
  wt$percent_change_vs_PUB21 <- 100 * wt$delta_vs_PUB21 / wt$weighted_information[match(paste("PUB21", wt$subscale), paste(wt$form, wt$subscale))]
  csv_out(do.call(rbind, curves), "AS2_information_curves.csv")
  csv_out(wt, "AS2_weighted_information.csv")
  csv_out(do.call(rbind, diag_rows), "GRM_diagnostics_validation.csv")
} else {
  log_event("GRM_SKIPPED", "information curves not computed")
}
model_check <- do.call(rbind, conv_rows)
check("all_models_converged_and_admissible", all(model_check$converged) && all(model_check$admissible))
csv_out(model_check, "model_convergence.csv")
saveRDS(list(cfas = cfas, cal_grm = cal_grm, val_grm = val_grm), file.path(out, "models_all.rds"))
log_event("AS2_COMPLETE")
