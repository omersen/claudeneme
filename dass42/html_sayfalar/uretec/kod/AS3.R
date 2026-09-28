# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 3 (AS3): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21'in alt boyut puanları, DASS-42'nin ilgili alt boyut puanlarıyla ne ölçüde uyumludur?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi, 0-3). Her kişi için iki puan hesaplanır:
#              kısa puan (formun o alt boyuttaki 7 maddesinin ortalaması) ve tam puan (DASS-42'nin o alt
#              boyuttaki 14 maddesinin ortalaması). İkisi de 0-3 aralığındadır.
#   formlar  : Dört kısa form (PUB21, MIN21, MAX21, COV21) ve tam form (FULL42).
#   Analiz birimi: dört form x üç alt boyut; her satırdaki göstergeler 2.000 kişi üzerindendir.
#
# Göstergeler (d = kısa puan - tam puan, kişi başına):
#   r        : kısa ve tam puan arasındaki Pearson korelasyonu (kişilerin sıralaması ne kadar korunuyor?).
#   bias     : d'nin ortalaması (yanlılık). Pozitifse kısa form ortalamada daha YÜKSEK puan verir.
#              İşaret "kısa eksi tam" yönündedir; ters çevrilmez.
#   sd_d     : d'nin standart sapması (n paydalı); kişiden kişiye değişen sapma.
#   rmse     : sqrt(ortalama(d^2)); tam puandan ortalama sapmanın büyüklüğü (ANA gösterge).
#              rmse^2 = bias^2 + sd_d^2 olduğundan RMSE'nin yanlılıktan mı, kişi düzeyindeki dağılımdan mı
#              geldiği her zaman birlikte yazılır.
#   rmse_0_42: rmse x 14; DASS-42 alt boyut toplam puanı biriminde (0-42) aynı değer (okumayı kolaylaştırır).
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS3 bölümü ve genel yorum kuralları)
#   Düşük RMSE: seçilen yedi madde ile kalan yedi madde kişi düzeyinde birbirine daha yakın demektir
#              (kısa form, tam formun yarısıdır; ham uyum bu bölünmenin özelliğidir).
#   MIN21 ile MAX21 her alt boyutta birbirinin tümleyenidir (aynı 14 maddeyi ikiye böler). Bu yüzden
#              farkları ters işaretli, RMSE değerleri eşittir; bu yeni bir bağımsız kanıt değildir.
#   Söylenmez: RMSE "ölçme hatası" değildir; tam form gerçek puan değildir ve kısa formla ortak maddeler
#              içerir. Yüksek kısa-tam korelasyonu geçerlik veya puan eşdeğerliği kanıtı değildir; küçük
#              RMSE klinik eşdeğerlik göstermez. 0-42 birimindeki değerler klinik önem eşiği değildir.
#   Sonra    : RMSE yüzdelikleri ve r medyanı ALT KÜME TABLOSU, PUB21'e göre RMSE farklarının bootstrap
#              aralıkları BOOTSTRAP bloğunda hesaplanır; bu blok yalnız değerleri üretir.
#   Hangi tablo?: tablo_AS3_uyum.csv AS3'ün ana yanıtıdır.
# ---------------------------------------------------------------------------------------------
as3_satirlar <- list(); as3_farklar <- list()   # farklar: denetim için kişi düzeyindeki d değerleri

for (form in kisa_formlar) {
  for (f in alt_boyutlar) {
    # Adım 1. Kişi başına kısa ve tam puan (madde ortalaması, 0-3).
    kisa <- rowMeans(deg[, formlar[[form]][[f]]])
    tam <- rowMeans(deg[, formlar$FULL42[[f]]])

    # Adım 2. Uyum göstergeleri (r, bias, sd_d, rmse) Bölüm 3'teki uyum_olculeri ile.
    u <- uyum_olculeri(kisa, tam)
    as3_farklar[[paste0(form, "_", f)]] <- kisa - tam
    as3_satirlar[[paste0(form, "_", f)]] <- data.frame(form = form, subscale = f, r = u[["r"]], bias = u[["bias"]],
      sd_d = u[["sd_d"]], rmse = u[["rmse"]], rmse_0_42 = 14 * u[["rmse"]])

    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS3_r_", form, "_", f)]] <- u[["r"]]
    sonuc[[paste0("AS3_bias_", form, "_", f)]] <- u[["bias"]]
    sonuc[[paste0("AS3_rmse_", form, "_", f)]] <- u[["rmse"]]
  }
}
as3_uyum <- do.call(rbind, as3_satirlar); rownames(as3_uyum) <- NULL

# Adım 3. Tanımdan gelen eşitliklerin denetimi (hesap hatası olursa betik burada durur).
#   MIN21 ve MAX21 tümleyen olduğu için kişi düzeyinde d_MIN21 + d_MAX21 = 0 ve RMSE'ler eşittir;
#   her satırda rmse^2 = bias^2 + sd_d^2 (RMSE'nin yanlılık ve dağılım bileşenlerine ayrışması).
for (f in alt_boyutlar) {
  kontrol(paste0("AS3_MIN_MAX_farklar_toplami_", f),
          max(abs(as3_farklar[[paste0("MIN21_", f)]] + as3_farklar[[paste0("MAX21_", f)]])) < 1e-12)
  kontrol(paste0("AS3_MIN_MAX_rmse_esit_", f),
          abs(sonuc[[paste0("AS3_rmse_MIN21_", f)]] - sonuc[[paste0("AS3_rmse_MAX21_", f)]]) < 1e-12)
}
kontrol("AS3_rmse_ayrisimi", max(abs(as3_uyum$rmse^2 - (as3_uyum$bias^2 + as3_uyum$sd_d^2))) < 1e-12)

# Tablo (satır sırası: PUB21, MIN21, MAX21, COV21; her formda D, A, S).
csv_yaz(as3_uyum, "tablo_AS3_uyum.csv")
cat("\nAS3 özeti (kısa-tam uyum; bias, sd_d ve rmse 0-3 madde ortalaması biriminde):\n")
print(as3_uyum, row.names = FALSE, digits = 3)
log_yaz("AS3_HAZIR")
