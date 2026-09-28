# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 2 (AS2): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21, üç faktörlü yapının desteklenmesi ve alt boyut puanlarının güvenirliği bakımından nasıl
#   farklılaşmaktadır?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi, 0-3). Bütün DFA'lar ve güvenirlikler bu
#              grupta hesaplanır. (Kalibrasyon grubu AS1'de kullanılmıştı; burada kullanılmaz.)
#   formlar  : Hangi maddenin hangi forma ve alt boyuta girdiği. Beş form karşılaştırılır:
#              FULL42 (42 madde, yalnız başvuru noktası), PUB21 (yayımlanmış DASS-21),
#              MIN21 (en düşük ISI), MAX21 (en yüksek ISI), COV21 (en küçük temsil kaybı, CL).
#              Kısa formların her alt boyutunda 7 madde vardır.
#   Analiz birimi: dört kısa form (FULL42 başvuru noktası), her formda üç alt boyut.
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS2 bölümü ve genel yorum kuralları)
#   Uyum     : CFI, TLI, RMSEA (%90 aralığıyla) ve SRMR her form için yan yana verilir. Formlar uyum
#              indekslerine göre SIRALANMAZ ve ΔCFI veya ΔRMSEA eşikleriyle "kazanan" seçilmez: farklı
#              madde kümeleriyle kurulan modeller iç içe değildir ve yükler yükseldikçe aynı yanlış
#              belirlemede RMSEA kötüleşebilir (McNeish, An ve Hancock, 2018).
#   Omega    : Güvenirliğin ana göstergesidir (obs.var = FALSE). obs.var = TRUE değeri ektedir.
#   Alfa     : Yardımcı göstergedir. Formun alfasının bütün yedili kümeler içindeki yüzdeliği sonraki
#              blokta (ALT KÜME TABLOSU) hesaplanır; bu blokta yalnız alfa değeri üretilir.
#   Sınırlar : Anlamsal olarak dar (birbirine benzeyen maddelerden oluşan) bir formun yüksek
#              güvenirliği "daha homojen puan" demektir, "daha iyi ölçme" demek değildir. Daha düşük
#              faktör korelasyonu tek başına daha iyi form anlamına gelmez. Kazanan form ilan edilmez.
#   Hangi tablo?: tablo_AS2_DFA_uyum.csv ve tablo_AS2_guvenirlik.csv AS2'nin ana yanıtıdır;
#              _yukler ve _faktor_korelasyonlari yapının ayrıntısını verir.
# ---------------------------------------------------------------------------------------------
as2_formlar <- c("FULL42", kisa_formlar)   # FULL42 başvuru noktası; ardından dört kısa form
as2_uyum_listesi <- list(); as2_yuk_listesi <- list(); as2_korelasyon_listesi <- list(); as2_guv_listesi <- list()

for (form in as2_formlar) {
  maddeler_form <- formlar[[form]]          # list(D = ..., A = ..., S = ...): alt boyut başına madde kimlikleri

  # Adım 1. Üç ilişkili faktörlü sıralı DFA (WLSMV; gizil varyanslar 1; çapraz yük ve artık kovaryans yok).
  #   Amaç: formun maddeleri kuramsal D-A-S yapısını ne ölçüde destekliyor? Model yalnız fit_cfa ile kurulur;
  #   fit_cfa yakınsamayan veya kabul edilemez (ör. negatif varyans) çözümde betiği durdurur.
  fit <- fit_cfa(deg, maddeler_form)

  # Adım 2. Uyum ölçüleri (ölçeklenmiş ki-kare, sd, p, CFI, TLI, RMSEA ve %90 aralığı, SRMR).
  #   Yorum: CFI/TLI 1'e, RMSEA ve SRMR 0'a yaklaştıkça model-veri uyumu artar. n = 2.000'de ki-kare
  #   testinin p değeri neredeyse her zaman küçüktür; değerler yan yana betimlenir, formlar sıralanmaz.
  uyum <- lavaan::fitMeasures(fit, dfa_uyum_olculeri)
  as2_uyum_listesi[[form]] <- data.frame(form = form, n_madde = length(unlist(maddeler_form)),
                                         t(as.numeric(uyum[dfa_uyum_olculeri])))
  names(as2_uyum_listesi[[form]]) <- c("form", "n_madde", dfa_uyum_olculeri)

  # Adım 3. Standartlaştırılmış faktör yükleri (op == "=~" satırları), standart hata ve %95 aralık.
  #   Yorum: yük, maddenin kendi faktörüyle ilişkisinin gücüdür; formlar arasında en düşük ve ortalama
  #   yük betimsel olarak karşılaştırılabilir.
  ss <- lavaan::standardizedSolution(fit)
  ss <- ss[ss$op == "=~", , drop = FALSE]
  as2_yuk_listesi[[form]] <- data.frame(form = form, faktor = ss$lhs, item_id = ss$rhs, yuk = ss$est.std,
                                        se = ss$se, alt = ss$ci.lower, ust = ss$ci.upper)

  # Adım 4. Faktörler arası korelasyonlar (D-A, D-S, A-S).
  #   Yorum: alt boyutların birbirinden ne ölçüde ayrıştığını gösterir; tek başına form kalitesi ölçütü değildir.
  kor <- lavaan::lavInspect(fit, "cor.lv")
  as2_korelasyon_listesi[[form]] <- data.frame(form = form, cift = c("D-A", "D-S", "A-S"),
                                               r = c(kor["D", "A"], kor["D", "S"], kor["A", "S"]))

  # Adım 5. Alt boyut güvenirliği: kategorik omega (ana), obs.var = TRUE omega (ek) ve ham alfa (yardımcı).
  #   Omega: sıralı DFA'nın yüklerinden hesaplanan güvenirlik. Alfa yalnız alpha_raw ile hesaplanır
  #   (standartlaştırılmış alfa veya başka paketlerin alfa işlevi kullanılmaz).
  omega_ana <- omega_values(fit, obs.var = FALSE)
  omega_ek <- omega_values(fit, obs.var = TRUE)
  as2_guv_listesi[[form]] <- do.call(rbind, lapply(alt_boyutlar, function(f)
    data.frame(form = form, subscale = f, omega = as.numeric(omega_ana[f]),
               omega_obsvar_true = as.numeric(omega_ek[f]), alfa = alpha_raw(deg[, maddeler_form[[f]]]))))

  # sonuc listesine yalnız hesaplanan nesneler atanır. Uyum anahtarları beş form için (FULL42 dahil),
  # omega ve alfa anahtarları yalnız dört kısa form için yazılır.
  sonuc[[paste0("AS2_CFI_", form)]] <- as.numeric(uyum["cfi.scaled"])
  sonuc[[paste0("AS2_RMSEA_", form)]] <- as.numeric(uyum["rmsea.scaled"])
  sonuc[[paste0("AS2_SRMR_", form)]] <- as.numeric(uyum["srmr"])
  if (form != "FULL42") for (f in alt_boyutlar) {
    satir <- as2_guv_listesi[[form]][as2_guv_listesi[[form]]$subscale == f, ]
    sonuc[[paste0("AS2_omega_", form, "_", f)]] <- satir$omega
    sonuc[[paste0("AS2_alfa_", form, "_", f)]] <- satir$alfa
  }
}

# Tablolar (satır sırası: FULL42, PUB21, MIN21, MAX21, COV21; güvenirlikte her formda D, A, S).
as2_guvenirlik <- do.call(rbind, as2_guv_listesi); rownames(as2_guvenirlik) <- NULL
as2_uyum <- do.call(rbind, as2_uyum_listesi); rownames(as2_uyum) <- NULL
kontrol("AS2_yuk_sayisi", nrow(do.call(rbind, as2_yuk_listesi)) == 42L + 4L * 21L)
csv_yaz(as2_uyum, "tablo_AS2_DFA_uyum.csv")
csv_yaz(do.call(rbind, as2_yuk_listesi), "tablo_AS2_yukler.csv")
csv_yaz(do.call(rbind, as2_korelasyon_listesi), "tablo_AS2_faktor_korelasyonlari.csv")
csv_yaz(as2_guvenirlik, "tablo_AS2_guvenirlik.csv")
cat("\nAS2 özeti (uyum):\n"); print(as2_uyum[, c("form", "n_madde", "cfi.scaled", "tli.scaled", "rmsea.scaled", "srmr")],
                                   row.names = FALSE, digits = 3)
cat("\nAS2 özeti (güvenirlik):\n"); print(as2_guvenirlik, row.names = FALSE, digits = 3)
log_yaz("AS2_HAZIR")
