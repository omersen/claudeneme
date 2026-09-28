# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok hangi soruya hizmet eder? AS3 (RMSE farkları ana metinde) ve AS2 (alfa farkları eklerde).
#   Soru: Anlamsal formların (MIN21, MAX21, COV21) alfa ve RMSE değerleri yayımlanmış DASS-21'den (PUB21)
#   ne kadar farklıdır ve bu fark örneklemden örnekleme ne kadar oynar?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi). Her tekrarda kişiler iadeli olarak yeniden
#              çekilir (katılımcı bootstrap'ı). Aynı çekilen kişiler (ix) bütün formlara ve tam puana
#              uygulanır; böylece farklar EŞLEŞTİRİLMİŞ olur (aynı kişiler üzerinde iki form karşılaştırılır).
#   formlar  : Karşılaştırılan formlar; fark her zaman "anlamsal form eksi PUB21" yönündedir.
#   Modeller yeniden kestirilmez; alfa (alpha_raw) ve RMSE doğrudan yanıtlardan hesaplanır. Rastgele sayı
#   yalnız tanımlanan biçimde kullanılır: her tekrarda set.seed(cfg$tohum_bootstrap + b) ve tek sample.int.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, genel kural 4 ve AS3 bölümü)
#   tahmin   : farkın bütün değerlendirme grubundaki değeri (bootstrap ortalaması DEĞİL).
#   alt, ust : 2.000 tekrarın 2,5. ve 97,5. yüzdelikleri; her fark için ayrı %95 aralık (eşzamanlı değil).
#   Sıfırı dışlayan aralık "bu örneklemde tutarlı bir fark" olarak okunur. Sıfırı içeren aralık
#   eşdeğerlik kanıtı DEĞİLDİR (fark yok demek değildir).
#   Yön: alfa farkı pozitifse anlamsal formun alfası PUB21'den yüksektir. RMSE farkı pozitifse anlamsal
#   formun puanı tam puandan PUB21'e göre DAHA ÇOK sapar (negatifse daha az).
#   MIN21 ile MAX21 aynı bölünmenin iki yarısı olduğu için RMSE farkları ve aralıkları aynıdır; bu yeni
#   bir kanıt değildir.
#   Söylenmez: alfa aralıkları omega aralığı değildir ve öyle sunulmaz. Aralıklar p değeri veya çoklu
#   karşılaştırma düzeltmesi içermez; kazanan form ilan edilmez.
#   Hangi tablo?: tablo_bootstrap_farklar.csv (olcu = rmse satırları AS3'te, olcu = alfa satırları eklerde).
# ---------------------------------------------------------------------------------------------
n <- nrow(deg)
boot_formlar <- anlamsal_formlar            # MIN21, MAX21, COV21 (her biri PUB21 ile karşılaştırılır)

# Bir veri kümesi (tam grup ya da bir bootstrap örneklemi) için 18 farkı hesaplayan yardımcı işlev.
# Sonuç: adları "alfa_MIN21_D", ..., "rmse_COV21_S" olan 18 elemanlı vektör.
farklari_hesapla <- function(X) {
  fark <- c()
  for (f in alt_boyutlar) {
    tam <- rowMeans(X[, formlar$FULL42[[f]]])                    # tam alt boyut puanı (0-3)
    kisa_pub <- rowMeans(X[, formlar$PUB21[[f]]])                # PUB21 kısa puanı
    alfa_pub <- alpha_raw(X[, formlar$PUB21[[f]]])
    rmse_pub <- sqrt(mean((kisa_pub - tam)^2))
    for (form in boot_formlar) {
      kisa <- rowMeans(X[, formlar[[form]][[f]]])
      fark[paste0("alfa_", form, "_", f)] <- alpha_raw(X[, formlar[[form]][[f]]]) - alfa_pub
      fark[paste0("rmse_", form, "_", f)] <- sqrt(mean((kisa - tam)^2)) - rmse_pub
    }
  }
  fark
}

# Adım 1. Nokta tahmini: bütün değerlendirme grubunda (ix = 1:n) farklar.
tahmin <- farklari_hesapla(deg)
# Tutarlılık denetimi: nokta tahminleri AS2 ve AS3'teki değerlerden elde edilen farklara eşit olmalı.
for (f in alt_boyutlar) for (form in boot_formlar) {
  kontrol(paste0("BOOT_tahmin_alfa_", form, "_", f), abs(tahmin[[paste0("alfa_", form, "_", f)]] -
    (sonuc[[paste0("AS2_alfa_", form, "_", f)]] - sonuc[[paste0("AS2_alfa_PUB21_", f)]])) < 1e-10)
  kontrol(paste0("BOOT_tahmin_rmse_", form, "_", f), abs(tahmin[[paste0("rmse_", form, "_", f)]] -
    (sonuc[[paste0("AS3_rmse_", form, "_", f)]] - sonuc[[paste0("AS3_rmse_PUB21_", f)]])) < 1e-10)
}

# Adım 2. 2.000 bootstrap tekrarı. Her tekrarda tohum tekrarın numarasına bağlıdır; bu yüzden sonuçlar
#   her çalıştırmada birebir aynı çıkar. Aynı ix bütün formlara uygulanır.
boot_matrisi <- matrix(NA_real_, nrow = cfg$B, ncol = length(tahmin), dimnames = list(NULL, names(tahmin)))
for (b in seq_len(cfg$B)) {
  set.seed(cfg$tohum_bootstrap + b)
  ix <- sample.int(n, n, replace = TRUE)
  boot_matrisi[b, ] <- farklari_hesapla(deg[ix, , drop = FALSE])
}
kontrol("BOOT_tum_tekrarlar_sonlu", all(is.finite(boot_matrisi)))

# Adım 3. %95 aralık: tekrarların 2,5. ve 97,5. yüzdelikleri (quantile type = 7).
#   Satır sırası: olcu (alfa, rmse), form (MIN21, MAX21, COV21), alt boyut (D, A, S).
boot_satirlari <- list()
for (olcu in c("alfa", "rmse")) for (form in boot_formlar) for (f in alt_boyutlar) {
  ad <- paste0(olcu, "_", form, "_", f)
  aralik <- quantile(boot_matrisi[, ad], c(0.025, 0.975), type = 7, names = FALSE)
  boot_satirlari[[ad]] <- data.frame(olcu = olcu, subscale = f, form = form, tahmin = tahmin[[ad]],
                                     alt = aralik[1], ust = aralik[2], B = cfg$B)
  # sonuc listesine yalnız hesaplanan nesneler atanır.
  sonuc[[paste0("BOOT_", olcu, "_", form, "_", f, "_alt")]] <- aralik[1]
  sonuc[[paste0("BOOT_", olcu, "_", form, "_", f, "_ust")]] <- aralik[2]
}
boot_farklar <- do.call(rbind, boot_satirlari); rownames(boot_farklar) <- NULL
# MIN21 ve MAX21 tümleyen olduğundan RMSE farkları her tekrarda eşittir (tanım denetimi).
kontrol("BOOT_MIN_MAX_rmse_esit", max(abs(boot_matrisi[, grep("^rmse_MIN21", colnames(boot_matrisi))] -
                                        boot_matrisi[, grep("^rmse_MAX21", colnames(boot_matrisi))])) < 1e-12)

csv_yaz(boot_farklar, "tablo_bootstrap_farklar.csv")
cat("\nBOOTSTRAP özeti (anlamsal form eksi PUB21; %95 aralık, B =", cfg$B, "):\n")
print(cbind(boot_farklar[, 1:3], signif(boot_farklar[, c("tahmin", "alt", "ust")], 4),
            sifiri_disliyor = boot_farklar$alt > 0 | boot_farklar$ust < 0), row.names = FALSE)
log_yaz("BOOTSTRAP_HAZIR")
