# ---- Ek A: gömme modeli için sonradan eklenen betimsel denetim -------------------------
# Denetim, analiz örnekleminde kullanılmayan uygun kayıtlarda (10.362 - 4.000 = 6.362 kayıt) yapılır; böylece
# kalibrasyon ve değerlendirme gruplarının verisi iki kez kullanılmaz. Ölçütler araştırma sorularının
# sonuç göstergelerini kullanmaz. Denetim, form ve analiz kararları verildikten sonra eklenmiştir.
disari <- setdiff(uygun, secilen)
R_disari <- cor(Y[disari, ] - 1)                                            # 42 x 42 görgül madde korelasyonu

tfidf <- function(metin, kimlik) {                                          # sözcüksel temel çizgi
  s <- lapply(strsplit(gsub("[^a-z']+", " ", tolower(metin)), " "), function(x) x[nzchar(x)])
  sozluk <- sort(unique(unlist(s)))
  tf <- t(vapply(s, function(x) as.numeric(table(factor(x, levels = sozluk))), numeric(length(sozluk))))
  w <- sweep(tf, 2, log(length(metin) / colSums(tf > 0)), "*"); rownames(w) <- kimlik; w
}
boyutlar <- c(3072, 1536, 1024, 512, 256)                                   # ilk d bileşen; kosinüs yeniden ölçekler
temsiller <- c(setNames(lapply(boyutlar, function(d) cosine_matrix(E[, 1:d, drop = FALSE])), boyutlar),
               list(`TF-IDF` = cosine_matrix(tfidf(maddeler$text, maddeler$item_id))))
# İsteğe bağlı: girdiler/modeller/ klasöründe açık ağırlıklı modellerin vektörleri (emb_<model>.csv) varsa eklenir.
for (yol in list.files("girdiler/modeller", "^emb_.*[.]csv$", full.names = TRUE)) {
  ad <- sub("^emb_(.*)[.]csv$", "\\1", basename(yol))
  if (ad != "text-embedding-3-large") temsiller[[ad]] <- cosine_matrix(vektor_oku(yol))
}

alt_of <- setNames(rep(names(key42), lengths(key42)), item_id(unlist(key42)))[rownames(C)]
ust <- upper.tri(C); ic <- ust & outer(alt_of, alt_of, "==")                # 861 çift; 273 alt ölçek içi çift
alt_olcek_tahmini <- function(Cm) sapply(rownames(Cm), function(i)         # yanıt verisi kullanmaz
  names(which.max(sapply(names(key42), function(f) mean(Cm[i, setdiff(item_id(key42[[f]]), i)])))))
model_denetimi <- function(Cm, R) {
  Cm <- Cm[rownames(R), rownames(R)]
  ilk_k <- sapply(1:3, function(k) mean(sapply(rownames(R), function(i) {   # en yüksek r'li eş ilk k komşuda mı
    diger <- setdiff(rownames(R), i)
    names(which.max(abs(R[i, diger]))) %in% diger[order(-Cm[i, diger])][1:k]
  })))
  c(r_tum = cor(abs(Cm[ust]), abs(R[ust])), rho_tum = spearman(abs(Cm[ust]), abs(R[ust])),
    r_ic = cor(Cm[ic], R[ic]), rho_ic = spearman(Cm[ic], R[ic]),
    ilk1 = ilk_k[1], ilk2 = ilk_k[2], ilk3 = ilk_k[3], alt_olcek = mean(alt_olcek_tahmini(Cm) == alt_of[rownames(Cm)]))
}
denetim <- do.call(rbind, lapply(names(temsiller), function(m)
  data.frame(temsil = m, t(model_denetimi(temsiller[[m]], R_disari)))))
denetim$n <- length(disari)
print(denetim, digits = 3)
write.csv(denetim, "html_ciktilari/ekA_model_denetimi.csv", row.names = FALSE)
tahmin_as <- alt_olcek_tahmini(C)                                           # yanlış sınıflanan maddeler
print(data.frame(madde = names(tahmin_as), anahtar = alt_of[names(tahmin_as)], tahmin = tahmin_as)[tahmin_as != alt_of[names(tahmin_as)], ],
      row.names = FALSE)

# Formların temsile duyarlılığı: başka temsillerle kurulan formların ana formlarla ortak madde sayısı (7 üzerinden)
duyarlilik <- do.call(rbind, lapply(setdiff(names(temsiller), "3072"), function(m) {
  z <- form_olustur(temsiller[[m]])
  do.call(rbind, lapply(anlamsal_formlar, function(nm)
    data.frame(temsil = m, form = nm, t(sapply(alt_boyutlar, function(f) length(intersect(z[[nm]][[f]], formlar[[nm]][[f]])))))))
}))
rownames(duyarlilik) <- NULL
print(duyarlilik)
write.csv(duyarlilik, "html_ciktilari/ekA_form_duyarliligi.csv", row.names = FALSE)

# Şekil: kosinüs benzerliği ve görgül korelasyon (6.362 kayıt, 861 çift)
cift <- data.frame(kosinus = C[ust], r = R_disari[ust],
                   tur = ifelse(ic[ust], "Alt ölçek içi (273 çift)", "Alt ölçekler arası (588 çift)"))
sekil_ekA <- ggplot(cift, aes(x = kosinus, y = r, colour = tur)) +
  geom_point(size = 1.1, alpha = 0.65) +
  scale_colour_manual(values = c("Alt ölçek içi (273 çift)" = "#0072B2", "Alt ölçekler arası (588 çift)" = "grey62")) +
  labs(x = "Kosinüs benzerliği (text-embedding-3-large, 3072 boyut)",
       y = "Görgül madde korelasyonu (analiz dışı 6.362 kayıt)", colour = NULL) +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")
if (interactive()) print(sekil_ekA)
ggsave("html_ciktilari/sekil_ekA_kosinus_r.png", sekil_ekA, width = 6.8, height = 4.8, dpi = 300, bg = "white")
