# ---- AS3: kısa ve tam form puanlarının uyumu ----------------------------------------
uy <- list()
for (form in kisa_formlar) for (f in alt_boyutlar) {
  tam  <- rowMeans(deg[, formlar$FULL42[[f]]])                            # 14 maddelik ortalama (0-3)
  kisa <- rowMeans(deg[, formlar[[form]][[f]]])                           # 7 maddelik ortalama (0-3)
  u <- uyum_olculeri(kisa, tam)
  uy[[paste(form, f)]] <- data.frame(form = form, subscale = f, r = u[["r"]], bias = u[["bias"]],
                                     sd_d = u[["sd_d"]], rmse = u[["rmse"]], rmse_0_42 = 14 * u[["rmse"]])
}
as3_uyum <- do.call(rbind, uy); rownames(as3_uyum) <- NULL
ek <- yuzdelik[match(paste(as3_uyum$form, as3_uyum$subscale), paste(yuzdelik$form, yuzdelik$subscale)), ]
as3_uyum$rmse_yzd <- ek$rmse_yzd; as3_uyum$r_medyan <- ek$r_medyan            # konum ve karşılaştırma değerleri
print(as3_uyum, digits = 3)
write.csv(as3_uyum, "html_ciktilari/AS3_uyum.csv", row.names = FALSE)

# Eşleştirilmiş bootstrap: anlamsal form eksi PUB21 (RMSE; alfa farkları ek için)
n <- nrow(deg); Dm <- as.matrix(deg)
olcum <- function(ix) {
  Xs <- Dm[ix, , drop = FALSE]; v <- numeric(0)
  for (f in alt_boyutlar) {
    tam <- rowMeans(Xs[, formlar$FULL42[[f]], drop = FALSE])
    pub_alfa <- alpha_raw(Xs[, formlar$PUB21[[f]], drop = FALSE])
    pub_rmse <- sqrt(mean((rowMeans(Xs[, formlar$PUB21[[f]], drop = FALSE]) - tam)^2))
    for (form in anlamsal_formlar) {
      v[paste("alfa", f, form, sep = "|")] <- alpha_raw(Xs[, formlar[[form]][[f]], drop = FALSE]) - pub_alfa
      v[paste("rmse", f, form, sep = "|")] <- sqrt(mean((rowMeans(Xs[, formlar[[form]][[f]], drop = FALSE]) - tam)^2)) - pub_rmse
    }
  }
  v
}
tahmin <- olcum(seq_len(n))
cekim <- t(sapply(1:2000, function(b) { set.seed(20260913 + b); olcum(sample.int(n, n, replace = TRUE)) }))
sinir <- apply(cekim, 2, quantile, probs = c(0.025, 0.975), type = 7, names = FALSE)
parca <- strsplit(names(tahmin), "|", fixed = TRUE)
boot_tablo <- data.frame(olcu = sapply(parca, `[`, 1), subscale = sapply(parca, `[`, 2), form = sapply(parca, `[`, 3),
                         tahmin = unname(tahmin), alt = sinir[1, ], ust = sinir[2, ],
                         sifiri_disliyor = sinir[1, ] > 0 | sinir[2, ] < 0)
boot_tablo <- boot_tablo[order(boot_tablo$olcu, match(boot_tablo$form, anlamsal_formlar),
                               match(boot_tablo$subscale, alt_boyutlar)), ]
rownames(boot_tablo) <- NULL
print(boot_tablo[boot_tablo$olcu == "rmse", ], digits = 3)
write.csv(boot_tablo, "html_ciktilari/bootstrap_farklar.csv", row.names = FALSE)
