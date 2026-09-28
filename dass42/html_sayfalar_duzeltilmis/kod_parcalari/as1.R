# ---- AS1: ISI ile GRM ayırt ediciliği (a) arasındaki ilişki ----------------------------
as1 <- list(); par <- list(); tani <- list(); q3_cift <- list(); kategori <- list()
grm_mod <- list()                                                            # modeller AS2'deki test bilgisi için saklanır
for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]; isi <- as.numeric(ISI[[f]][havuz])
  hangi_form <- sapply(havuz, function(j)                                    # maddenin yer aldığı kısa formlar
    paste(kisa_formlar[sapply(kisa_formlar, function(nm) j %in% formlar[[nm]][[f]])], collapse = " "))
  for (g in c("kal", "deg")) {
    Xg <- (if (g == "kal") kal else deg)[, havuz]
    mod <- fit_grm(Xg); grm_mod[[paste(f, g)]] <- mod                      # tek boyutlu GRM
    p <- grm_parameters(mod); p <- p[match(havuz, p$item_id), ]
    citc <- sapply(havuz, function(j) cor(Xg[[j]], rowSums(Xg[, setdiff(havuz, j)])))   # düzeltilmiş madde-toplam r
    m2 <- tryCatch(mirt::M2(mod, type = "C2"), error = function(e) NULL)            # C2 temelli uyum
    q <- q3_duzeltilmis(mod); ust <- upper.tri(q); aq <- q[ust]; cs <- C[havuz, havuz][ust]
    as1[[paste(f, g)]] <- data.frame(subscale = f, grup = g, rho_ISI_a = spearman(isi, p$a),
                                     rho_ISI_CITC = spearman(isi, citc), rho_a_CITC = spearman(p$a, citc))
    par[[paste(f, g)]] <- data.frame(subscale = f, grup = g, item_id = havuz, ISI = isi, a = p$a,
                                     b1 = p$b1, b2 = p$b2, b3 = p$b3, CITC = as.numeric(citc), formlar = hangi_form)
    tani[[paste(f, g)]] <- data.frame(subscale = f, grup = g,
                                      C2 = if (is.null(m2)) NA else m2$M2, df = if (is.null(m2)) NA else m2$df,
                                      RMSEA = if (is.null(m2)) NA else m2$RMSEA, SRMSR = if (is.null(m2)) NA else m2$SRMSR,
                                      maks_Q3 = max(aq), rho_cos_Q3 = spearman(cs, aq))       # 91 madde çifti
    ij <- which(ust, arr.ind = TRUE); en <- order(-aq)[1:3]                                # en yüksek üç Q3 çifti
    q3_cift[[paste(f, g)]] <- data.frame(subscale = f, grup = g, cift = paste(havuz[ij[en, 1]], havuz[ij[en, 2]], sep = "-"),
                                         Q3 = aq[en], kosinus = cs[en])
    oran <- sapply(havuz, function(j) tabulate(Xg[[j]] + 1, nbins = 4) / nrow(Xg))  # 0-3 kategorilerinin oranı
    kategori[[paste(f, g)]] <- data.frame(subscale = f, grup = g, en_az_kullanilan = min(oran),
                                          madde = havuz[which(oran == min(oran), arr.ind = TRUE)[1, 2]],
                                          kategori_3_ort = mean(oran[4, ]), kategori_0_ort = mean(oran[1, ]))
  }
}
as1_tablo <- do.call(rbind, as1); as1_parametreler <- do.call(rbind, par)
as1_tani <- do.call(rbind, tani); as1_q3 <- do.call(rbind, q3_cift); as1_kategori <- do.call(rbind, kategori)
rownames(as1_tablo) <- rownames(as1_parametreler) <- rownames(as1_tani) <- rownames(as1_q3) <- rownames(as1_kategori) <- NULL
print(as1_tablo, digits = 3); print(as1_tani, digits = 3); print(as1_q3, digits = 3); print(as1_kategori, digits = 3)
write.csv(as1_tablo, "html_ciktilari/AS1_ISI_a.csv", row.names = FALSE)
write.csv(as1_parametreler, "html_ciktilari/AS1_madde_parametreleri.csv", row.names = FALSE)
write.csv(as1_tani, "html_ciktilari/AS1_GRM_tani.csv", row.names = FALSE)
write.csv(as1_q3, "html_ciktilari/AS1_Q3_ciftleri.csv", row.names = FALSE)
write.csv(as1_kategori, "html_ciktilari/AS1_kategori_kullanimi.csv", row.names = FALSE)

# Şekil: ISI ve a (kalibrasyon grubu)
ap <- as1_parametreler[as1_parametreler$grup == "kal", ]
rk <- as1_tablo[as1_tablo$grup == "kal", ]
etiket <- setNames(sprintf("%s (rho = %.2f)", rk$subscale, rk$rho_ISI_a), rk$subscale)
ap$panel <- factor(etiket[ap$subscale], levels = etiket)
sekil1 <- ggplot(ap, aes(x = ISI, y = a, label = item_id)) +
  geom_point(colour = "#0072B2", size = 2) + geom_text(size = 2.6, vjust = -0.8) +
  facet_wrap(~panel, nrow = 1, scales = "free") +
  labs(x = "Madde anlamsal benzerlik indeksi (ISI)", y = "GRM ayırt edicilik (a), kalibrasyon grubu") +
  theme_bw(base_size = 11)
if (interactive()) print(sekil1)
ggsave("html_ciktilari/sekil_AS1_ISI_a.png", sekil1, width = 9, height = 3.6, dpi = 300, bg = "white")
