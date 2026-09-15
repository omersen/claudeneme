# =============================================================================
# 05_as3_score_agreement.R
# AS3: Kisa form alt boyut puanlarinin tam alt boyut puanlariyla uyumu (dogrulama yarisi)
#   - ham puan (0-3 madde ortalamasi): r, rho, CCC, yanlilik, RMSE, nRMSE
#   - ortak madde sismesi: kisa form ile disarida kalan 7 maddenin korelasyonu (ortak madde yok)
#     ve sisme = r_ham - r_kalan
#   - EAP puanlari (mirt): kalibrasyon GRM'si sabit, form disi maddeler maskelenir
#   - MIN21 / MAX21 tumleyen ozdesligi denetimi
# =============================================================================
log_event("STAGE", "AS3 score agreement (validation half)")
scores <- list(); agree_rows <- remain_rows <- comp_rows <- person_rows <- list()
for (f in names(key42)) {
  pool <- forms$FULL42[[f]]; Xf <- p$val[, pool, drop = FALSE]
  scores[[f]] <- list()
  for (nm in form_names) {
    ids <- forms[[nm]][[f]]
    s <- list(raw = rowMeans(Xf[, ids, drop = FALSE]))
    if (grm_available) {
      z <- eap_fixed(cal_grm[[f]], Xf, ids); s$eap <- z$theta; s$posterior_sd <- z$posterior_sd
    }
    scores[[f]][[nm]] <- s
    person_rows[[paste(f, nm)]] <- data.frame(validation_row = seq_len(nrow(Xf)), source_row = p$val_source_rows,
      subscale = f, form = nm, raw_item_mean = s$raw,
      eap = if (grm_available) s$eap else NA_real_, posterior_sd = if (grm_available) s$posterior_sd else NA_real_)
  }
  # Tumleyen ozdesligi
  complementary <- setequal(union(forms$MIN21[[f]], forms$MAX21[[f]]), pool) &&
    length(intersect(forms$MIN21[[f]], forms$MAX21[[f]])) == 0L
  err_min <- scores[[f]]$MIN21$raw - scores[[f]]$FULL42$raw
  err_max <- scores[[f]]$MAX21$raw - scores[[f]]$FULL42$raw
  comp_rows[[f]] <- data.frame(subscale = f, MIN_MAX_complementary_sets = complementary,
    raw_bias_MIN21 = mean(err_min), raw_bias_MAX21 = mean(err_max),
    raw_RMSE_MIN21 = sqrt(mean(err_min^2)), raw_RMSE_MAX21 = sqrt(mean(err_max^2)),
    max_abs_person_error_sum = max(abs(err_min + err_max)),
    note = if (complementary) "FULL14 mean = (MIN7 mean + MAX7 mean)/2; raw RMSE equality is algebraic" else "sets not complementary")
  for (nm in short_forms) {
    remaining <- setdiff(pool, forms[[nm]][[f]])
    rs <- rowMeans(Xf[, remaining, drop = FALSE])
    r_raw  <- stats::cor(scores[[f]][[nm]]$raw, scores[[f]]$FULL42$raw)
    r_rest <- stats::cor(scores[[f]][[nm]]$raw, rs)
    remain_rows[[paste(f, nm)]] <- data.frame(subscale = f, form = nm, n_common_items = 0L,
      r_short_full_with_overlap = r_raw, r_short_remaining = r_rest, overlap_inflation = r_raw - r_rest,
      note = "remaining set differs by form; not an external criterion")
    kinds <- if (grm_available) c("raw", "eap") else "raw"
    for (kind in kinds) {
      st <- score_stats(scores[[f]][[nm]][[kind]], scores[[f]]$FULL42[[kind]])
      agree_rows[[paste(f, nm, kind)]] <- data.frame(subscale = f, form = nm, score_type = kind,
        r = st["r"], rho = st["rho"], CCC = st["CCC"], bias = st["bias"], RMSE = st["RMSE"], nRMSE = st["nRMSE"],
        reference = "FULL42 subscale score (shares items); full score is not a true score")
    }
  }
}
agree <- do.call(rbind, agree_rows)
agree$delta_RMSE_vs_PUB21 <- agree$RMSE - agree$RMSE[match(paste("PUB21", agree$subscale, agree$score_type),
                                                            paste(agree$form, agree$subscale, agree$score_type))]
csv_out(agree, "AS3_score_agreement.csv")
csv_out(do.call(rbind, remain_rows), "AS3_overlap_inflation.csv")
csv_out(do.call(rbind, comp_rows), "AS3_MIN_MAX_complement_identity.csv")
csv_out(do.call(rbind, person_rows), "AS3_person_scores.csv")
saveRDS(scores, file.path(out, "scores.rds"))
log_event("AS3_COMPLETE")
