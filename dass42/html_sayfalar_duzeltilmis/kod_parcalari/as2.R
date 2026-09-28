# ---- AS2: faktör yapısı ve alt boyut puanlarının güvenirliği ----------------------------
uyum <- list(); guv <- list(); kor <- list(); yuk <- list(); dfa_fit <- list()   # modeller Ek D için saklanır
olculer <- c("chisq.scaled", "df.scaled", "cfi.scaled", "tli.scaled", "rmsea.scaled",
             "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr")
for (form in c("FULL42", kisa_formlar)) {
  fit <- fit_cfa(deg, formlar[[form]]); dfa_fit[[form]] <- fit             # değerlendirme grubu
  fm <- lavaan::fitMeasures(fit, olculer)
  uyum[[form]] <- data.frame(form = form, as.list(setNames(as.numeric(fm), olculer)))
  lv <- lavaan::lavInspect(fit, "cor.lv")
  kor[[form]] <- data.frame(form = form, D_A = lv["D", "A"], D_S = lv["D", "S"], A_S = lv["A", "S"])
  ss <- lavaan::standardizedSolution(fit); ss <- ss[ss$op == "=~", ]                  # standartlaştırılmış yükler
  yuk[[form]] <- data.frame(form = form, t(tapply(ss$est.std, ss$lhs, mean)[alt_boyutlar]), ortalama = mean(ss$est.std))
  om <- omega_values(fit)                                                 # ana güvenirlik göstergesi
  guv[[form]] <- data.frame(form = form, subscale = alt_boyutlar, omega = as.numeric(om),
                            alfa = sapply(alt_boyutlar, function(f) alpha_raw(deg[, formlar[[form]][[f]]])))
}
as2_uyum <- do.call(rbind, uyum); as2_kor <- do.call(rbind, kor); as2_guvenirlik <- do.call(rbind, guv)
as2_yuk <- do.call(rbind, yuk)                                              # alt boyut başına ortalama yük
rownames(as2_uyum) <- rownames(as2_kor) <- rownames(as2_guvenirlik) <- rownames(as2_yuk) <- NULL
as2_guvenirlik$alfa_yzd <- yuzdelik$alfa_yzd[match(paste(as2_guvenirlik$form, as2_guvenirlik$subscale),
                                                   paste(yuzdelik$form, yuzdelik$subscale))]   # FULL42 için NA
print(as2_uyum, digits = 3); print(as2_kor, digits = 3); print(as2_guvenirlik, digits = 3); print(as2_yuk, digits = 3)
write.csv(as2_uyum, "html_ciktilari/AS2_DFA_uyum.csv", row.names = FALSE)
write.csv(as2_guvenirlik, "html_ciktilari/AS2_guvenirlik.csv", row.names = FALSE)
write.csv(as2_kor, "html_ciktilari/AS2_faktor_korelasyonlari.csv", row.names = FALSE)
write.csv(as2_yuk, "html_ciktilari/AS2_ortalama_yukler.csv", row.names = FALSE)

# ---- AS2 alt sorusu: test bilgi fonksiyonu (GRM, değerlendirme grubu) ------------------
# Her alt boyutta AS1'de değerlendirme grubunda kestirilen 14 maddelik GRM kullanılır; yeni model kurulmaz.
# Bir formun test bilgisi, o formun yedi maddesinin madde bilgi fonksiyonlarının toplamıdır. Bu yüzden
# kısa formlar aynı ölçek (theta) üzerinde karşılaştırılabilir; 14 maddelik tam alt boyut üst sınırı verir.
# Standart hata: SH(theta) = 1 / sqrt(bilgi). theta, değerlendirme grubunda ortalaması 0, SS'si 1 olan örtük özelliktir.
theta <- seq(-3, 3, by = 0.05)
tbf <- do.call(rbind, lapply(alt_boyutlar, function(f) {
  mod <- grm_mod[[paste(f, "deg")]]; havuz <- formlar$FULL42[[f]]
  stopifnot(identical(mirt::extract.mirt(mod, "itemnames"), havuz))
  do.call(rbind, lapply(c("FULL42", kisa_formlar), function(form)
    data.frame(subscale = f, form = form, theta = theta,
               bilgi = mirt::testinfo(mod, matrix(theta), which.items = match(formlar[[form]][[f]], havuz)))))
}))
tbf_tablo <- tbf[round(tbf$theta, 2) %in% c(-2, -1, 0, 1, 2), ]
tbf_tablo$SH <- 1 / sqrt(tbf_tablo$bilgi)
tbf_tablo <- tbf_tablo[order(match(tbf_tablo$form, c("FULL42", kisa_formlar)), match(tbf_tablo$subscale, alt_boyutlar),
                             tbf_tablo$theta), ]
rownames(tbf_tablo) <- NULL
print(tbf_tablo, digits = 3)
write.csv(tbf, "html_ciktilari/AS2_test_bilgisi_egri.csv", row.names = FALSE)
write.csv(tbf_tablo, "html_ciktilari/AS2_test_bilgisi.csv", row.names = FALSE)

# Şekil: üç alt boyutta test bilgi fonksiyonları
tbf$form_ad <- factor(ifelse(tbf$form == "FULL42", "Tam alt boyut (14 madde)", tbf$form),
                      levels = c("Tam alt boyut (14 madde)", kisa_formlar))
tbf$panel <- factor(c(D = "Depresyon", A = "Kaygı", S = "Stres")[tbf$subscale], levels = c("Depresyon", "Kaygı", "Stres"))
sekil_tbf <- ggplot(tbf, aes(x = theta, y = bilgi, colour = form_ad, linetype = form_ad)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~panel, nrow = 1) +
  scale_colour_manual(values = c("Tam alt boyut (14 madde)" = "grey55", PUB21 = "#000000", MIN21 = "#0072B2",
                                 MAX21 = "#D55E00", COV21 = "#009E73")) +
  scale_linetype_manual(values = c("Tam alt boyut (14 madde)" = "dashed", PUB21 = "solid", MIN21 = "solid",
                                   MAX21 = "solid", COV21 = "solid")) +
  labs(x = expression("Örtük özellik düzeyi (" * theta * ")"), y = "Test bilgisi", colour = NULL, linetype = NULL) +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")
if (interactive()) print(sekil_tbf)
ggsave("html_ciktilari/sekil_AS2_test_bilgisi.png", sekil_tbf, width = 9.5, height = 4, dpi = 300, bg = "white")
