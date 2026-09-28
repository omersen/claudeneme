# ---- 3.5 Alt küme testi: bütün yedili kümelerin psikometrik değerleri -----------------
tum_alt <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(c("kal", "deg"), function(g) {
  ps <- alt_kume_psikometrik(if (g == "kal") kal else deg, formlar$FULL42[[f]], alt_kume[[f]]$subset_key)
  data.frame(subscale = f, grup = g, alt_kume[[f]], ps[, c("alpha", "bias", "sd_d", "rmse", "r")])
}))))
yuzdelik <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  i <- match(anahtar_yap(formlar[[form]][[f]]), tv$subset_key)
  data.frame(form = form, subscale = f,
             alfa = tv$alpha[i], alfa_yzd = midrank_percentile(tv$alpha, tv$alpha[i]),
             rmse = tv$rmse[i],  rmse_yzd = midrank_percentile(tv$rmse, tv$rmse[i]),
             SB = tv$SB[i],      SB_yzd = midrank_percentile(tv$SB, tv$SB[i]),
             CL = tv$CL[i],      CL_yzd = midrank_percentile(tv$CL, tv$CL[i]),
             r = tv$r[i],        r_medyan = median(tv$r))
}))))
write.csv(yuzdelik, "html_ciktilari/form_yuzdelikleri.csv", row.names = FALSE)
dagilim <- do.call(rbind, lapply(alt_boyutlar, function(f) {                 # değerlendirme grubunda 3.432 küme
  tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  data.frame(subscale = f, alfa_min = min(tv$alpha), alfa_medyan = median(tv$alpha), alfa_maks = max(tv$alpha),
             rmse_min = min(tv$rmse), rmse_medyan = median(tv$rmse), rmse_maks = max(tv$rmse),
             r_min = min(tv$r), r_medyan = median(tv$r), r_maks = max(tv$r))
}))
print(dagilim, digits = 3)
write.csv(dagilim, "html_ciktilari/alt_kume_dagilimi.csv", row.names = FALSE)
