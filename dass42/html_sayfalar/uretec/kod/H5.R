# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok bir araştırma sorusunu tek başına yanıtlamaz; AS2, AS3 ve AS4'te dört formun KONUMUNU verir
# ve AS5'in (alt küme testi) zeminini hazırlar. Temel fikir: bir alt boyutun 14 maddesinden 7'si
# choose(14, 7) = 3.432 farklı biçimde seçilebilir. Dört formun değerleri, aynı uzunluktaki bu bütün
# olası seçimlerin dağılımı içinde nerede duruyor?
#   İlgili sorular: AS2 (formların alfası bütün seçimler içinde ne kadar yüksek?), AS3 (tam puandan
#   sapma, yani RMSE, ne kadar küçük?), AS4 (anlamsal çeşitlilik SB ve temsil kaybı CL nerede?).
#
# Hangi veri hangi amaçla kullanılıyor?
#   alt_kume[[f]] : Bölüm 5'te yalnız madde METİNLERİNDEN hesaplanmış 3.432 kümenin anlamsal değerleri:
#                   SB (anlamsal genişlik; seçilen maddeler birbirinden ne kadar farklı), CL (temsil kaybı;
#                   elenen maddeler seçilenlere ne kadar uzak), CL_b (küme ve tümleyeninin karşılıklı temsil
#                   kaybı), tumleyen (kalan 7 maddelik kümenin satır numarası), kanonik_bolme (her iki yarılı
#                   bölünmeyi bir kez saymak için işaret), cov_esit_minimum (en küçük CL'yi veren kümeler).
#   kal, deg      : YANITLAR. Her kümenin alfa, yanlılık, s_d, RMSE ve kısa-tam r değeri iki grupta ayrı
#                   hesaplanır (alt_kume_psikometrik; tamsayı toplamlarıyla çalışır, eşit değerler eşit kalır).
#                   Yüzdelikler YALNIZ değerlendirme grubunda (deg) hesaplanır; kal değerleri AS5'teki
#                   tekrar içindir.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, genel kural 5 ve AS2-AS4 bölümleri)
#   Yüzdelik orta sıra yöntemiyle hesaplanır: dağılımda formun değerinden küçük olanların oranı artı
#   eşit olanların yarısı (x 100). Alfa ve SB'de yüksek yüzdelik daha yüksek değeri; RMSE ve CL'de düşük
#   yüzdelik daha küçük sapmayı veya daha az temsil kaybını gösterir.
#   Örnek: alfa_yzd = 90 ise formun alfası, olası yedili seçimlerin yaklaşık %90'ından yüksektir.
#   r_medyan: bütün kümelerdeki kısa-tam r'nin ortancası. Formun r değeri bununla karşılaştırılır; yüksek
#   r'nin tek başına başarı sayılmamasının nedeni, neredeyse her kümede r'nin yüksek olmasıdır.
#   Sınırlar: yüzdelikler betimseldir. 3.432 küme ortak maddeler içerdiği için bağımsız gözlem değildir;
#   p değeri verilmez. Tanım gereği sonuçlar bulgu sayılmaz (ör. COV21'in en düşük CL'si, MIN21'in yüksek
#   ve MAX21'in düşük SB'si). Bütünleşik tablo göstergeleri yan yana koyar; tek puanda birleştirmez ve
#   kazanan form ilan etmez.
#   Hangi tablo?: tablo_form_yuzdelikleri.csv (yüzdelikler), tablo_butunlesik.csv (tartışma için yan
#   yana görünüm), tum_alt_kumeler.csv (AS5 ve şekiller için bütün kümeler).
# ---------------------------------------------------------------------------------------------
tum_alt_listesi <- list()
for (f in alt_boyutlar) {
  for (g in c("kal", "deg")) {
    grup_verisi <- if (g == "kal") kal else deg
    # Adım 1. 3.432 kümenin psikometrik değerleri; satır sırası alt_kume[[f]] ile aynı kalır (merge yok).
    ps <- alt_kume_psikometrik(grup_verisi, formlar$FULL42[[f]], alt_kume[[f]]$subset_key)
    kontrol(paste0("ALT_anahtar_sirasi_", f, "_", g), identical(ps$subset_key, alt_kume[[f]]$subset_key))
    tum_alt_listesi[[paste0(f, "_", g)]] <- data.frame(subscale = f, grup = g,
      alt_kume[[f]][, c("subset_key", "SB", "CL", "CL_b", "tumleyen", "kanonik_bolme", "cov_esit_minimum")],
      ps[, c("alpha", "bias", "sd_d", "rmse", "r")], stringsAsFactors = FALSE)
    kontrol(paste0("ALT_3432_satir_", f, "_", g), nrow(tum_alt_listesi[[paste0(f, "_", g)]]) == choose(14, 7))
  }
}
tum_alt <- do.call(rbind, tum_alt_listesi); rownames(tum_alt) <- NULL   # sıra: D kal, D deg, A kal, ...

# Adım 2-3. Dört formun kendi satırı (değerlendirme grubu) ve orta sıra yüzdelikleri.
#   (Formun alfa ve RMSE değerinin AS2 ve AS3 ile aynı olduğu Sonuç bölümünde denetlenir.)
yuzdelik_listesi <- list()
for (form in kisa_formlar) {
  for (f in alt_boyutlar) {
    dilim <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]   # o alt boyutun 3.432 kümesi (deg)
    satir <- dilim[dilim$subset_key == anahtar_yap(formlar[[form]][[f]]), ]   # formun kendi satırı
    kontrol(paste0("ALT_form_satiri_", form, "_", f), nrow(satir) == 1L)
    y <- data.frame(form = form, subscale = f,
      alfa = satir$alpha, alfa_yzd = midrank_percentile(dilim$alpha, satir$alpha),
      rmse = satir$rmse, rmse_yzd = midrank_percentile(dilim$rmse, satir$rmse),
      SB = satir$SB, SB_yzd = midrank_percentile(dilim$SB, satir$SB),
      CL = satir$CL, CL_yzd = midrank_percentile(dilim$CL, satir$CL),
      r = satir$r, r_medyan = stats::median(dilim$r))
    yuzdelik_listesi[[paste0(form, "_", f)]] <- y
    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS2_alfa_yzd_", form, "_", f)]] <- y$alfa_yzd
    sonuc[[paste0("AS3_rmse_yzd_", form, "_", f)]] <- y$rmse_yzd
    sonuc[[paste0("AS4_SB_yzd_", form, "_", f)]] <- y$SB_yzd
    sonuc[[paste0("AS4_CL_yzd_", form, "_", f)]] <- y$CL_yzd
    sonuc[[paste0("AS3_r_medyan_", f)]] <- y$r_medyan   # formdan bağımsızdır; her formda aynı değer yazılır
  }
}
yuzdelik <- do.call(rbind, yuzdelik_listesi); rownames(yuzdelik) <- NULL

csv_yaz(tum_alt, "tum_alt_kumeler.csv")
csv_yaz(yuzdelik, "tablo_form_yuzdelikleri.csv")
cat("\nALT KÜME TABLOSU özeti (değerlendirme grubu; yüzdelikler 3.432 yedili küme içinde):\n")
print(yuzdelik[, c("form", "subscale", "alfa_yzd", "rmse_yzd", "SB_yzd", "CL_yzd")], row.names = FALSE, digits = 3)
log_yaz("ALT_KUME_HAZIR")
