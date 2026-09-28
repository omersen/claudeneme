# ---- Ek B: COV21 eşit çözümleri ---------------------------------------------------------
# Aynı en küçük CL'yi veren bütün kümeler; kuralın seçtiği küme ile ortak madde sayıları ve bu kümelerin
# değerlendirme grubundaki alfa ve RMSE aralığı. En küçük CL ile ondan sonraki farklı CL arasındaki boşluk da verilir.
ekB <- do.call(rbind, lapply(alt_boyutlar, function(f) {
  ak <- alt_kume[[f]]; tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  esit <- ak$subset_key[ak$cov_esit_minimum]; sec <- anahtar_yap(formlar$COV21[[f]])
  ps <- tv[match(esit, tv$subset_key), ]
  ortak <- sapply(strsplit(esit, "|", fixed = TRUE), function(s) length(intersect(s, formlar$COV21[[f]])))
  cl <- sort(ak$CL); sonraki <- cl[cl > min(cl) + tol][1]
  data.frame(subscale = f, n_esit = length(esit), ortak_min = min(ortak),
             alfa_min = min(ps$alpha), alfa_maks = max(ps$alpha), alfa_COV21 = tv$alpha[tv$subset_key == sec],
             rmse_min = min(ps$rmse), rmse_maks = max(ps$rmse), rmse_COV21 = tv$rmse[tv$subset_key == sec],
             CL_min = min(cl), CL_bosluk = sonraki - min(cl))
}))
print(ekB, digits = 4)
write.csv(ekB, "html_ciktilari/ekB_COV21_esit_cozumler.csv", row.names = FALSE)
