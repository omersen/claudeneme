# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 4 (AS4): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21, seçilen maddelerin anlamsal çeşitliliği ve ilgili alt boyuttaki madde havuzunun anlamsal
#   temsili bakımından nasıl farklılaşmaktadır?
#
# Hangi veri hangi amaçla kullanılıyor? (bu blokta yanıt verisi KULLANILMAZ; yalnız madde metinleri)
#   alt_kume[[f]] : Bölüm 5'te gömme vektörlerinden hesaplanmış SB ve CL değerleri (3.432 küme).
#     SB (anlamsal genişlik) = 1 - seçilen 7 madde arasındaki ortalama kosinüs benzerliği.
#                             Yüksek SB: seçilen maddeler anlamca birbirinden daha farklı (daha çeşitli).
#     CL (temsil kaybı)     = her maddenin en yakın SEÇİLİ maddeye kosinüs uzaklığının 14 madde üzerinden
#                             ortalaması (seçilen maddelerin uzaklığı 0'dır). Düşük CL: elenen maddeler
#                             seçilenlerden birine anlamca yakın, yani havuz daha iyi temsil ediliyor.
#   C             : 42 x 42 kosinüs matrisi; madde temsil tablosunda her elenen maddenin en yakın seçili
#                   karşılığını bulmak için kullanılır.
#   maddeler$text : Madde metinleri; temsil tablosunda örnekleri somutlaştırmak için.
#   Analiz birimi: dört form x üç alt boyut; SB-CL ilişkisi için 3.432 küme; temsil tablosunda 84 elenen madde.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, AS4 bölümü ve genel yorum kuralları)
#   Asıl bulgular üçtür: (1) PUB21'in konumu, (2) her formun KENDİ seçim hedefi dışındaki göstergedeki
#   konumu (ör. MIN21'in CL'si, COV21'in SB'si), (3) SB ile CL'nin bütün kümelerde birlikte değişip
#   değişmediği (rho_SB_CL). Yüzdelikler ALT KÜME TABLOSU bloğundadır; burada yeniden hesaplanmaz.
#   rho_SB_CL < 0 ise: bu havuzda daha çeşitli kümeler daha az temsil kaybı verme eğilimindedir.
#   Tanım gereği olanlar bulgu değildir: MIN21'in yüksek, MAX21'in düşük SB'si, COV21'in en düşük CL'si.
#   Söylenmez: yüksek SB tek başına iyi temsil demek değildir. "Temsil" kapsam geçerliği DEĞİLDİR; yalnız
#   bu gömme uzayındaki anlamsal temsildir ve uzman içerik yargısının yerine geçmez. 3.432 küme ortak
#   maddeler içerdiği için p değeri verilmez.
#   Hangi tablo?: tablo_AS4_anlamsal.csv (formların SB ve CL'si), tablo_AS4_SB_CL.csv (ilişki),
#   tablo_AS4_madde_temsil.csv (hangi elenen madde hangi seçili maddeyle temsil ediliyor).
# ---------------------------------------------------------------------------------------------
as4_anlamsal_listesi <- list(); as4_temsil_listesi <- list(); as4_iliski_listesi <- list()

# Adım 1. Formların SB ve CL değerleri: alt_kume[[f]] içindeki kendi satırlarından okunur (yeniden hesaplanmaz).
for (form in kisa_formlar) for (f in alt_boyutlar) {
  satir <- alt_kume[[f]][alt_kume[[f]]$subset_key == anahtar_yap(formlar[[form]][[f]]), ]
  kontrol(paste0("AS4_form_satiri_", form, "_", f), nrow(satir) == 1L)
  as4_anlamsal_listesi[[paste0(form, "_", f)]] <- data.frame(form = form, subscale = f, SB = satir$SB, CL = satir$CL)
  sonuc[[paste0("AS4_SB_", form, "_", f)]] <- satir$SB
  sonuc[[paste0("AS4_CL_", form, "_", f)]] <- satir$CL
}

# Adım 2. Bütün 3.432 kümede SB ile CL arasındaki Spearman ilişkisi (her alt boyut için).
for (f in alt_boyutlar) {
  rho_SB_CL <- spearman(alt_kume[[f]]$SB, alt_kume[[f]]$CL)
  as4_iliski_listesi[[f]] <- data.frame(subscale = f, rho_SB_CL = rho_SB_CL)
  sonuc[[paste0("AS4_rho_SB_CL_", f)]] <- rho_SB_CL
}

# Adım 3. Madde temsil tablosu: her elenen madde için en yakın seçili madde ve kosinüs uzaklığı.
#   Yorum: uzaklık küçükse elenen maddenin içeriği formda anlamca yakın bir maddeyle "karşılanıyor"
#   demektir (bu gömme uzayında). en_zayif = TRUE, o form ve alt boyutta en uzak kalan (en zayıf temsil
#   edilen) elenen maddedir; tezde örnek vermek için kullanılır.
metin <- stats::setNames(maddeler$text, maddeler$item_id)
for (form in kisa_formlar) for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]
  secili <- formlar[[form]][[f]]
  elenenler <- havuz[!(havuz %in% secili)]            # havuz sırasında
  en_yakin <- vapply(elenenler, function(i) secili[which.max(C[i, secili])], character(1))
  uzaklik <- 1 - C[cbind(elenenler, en_yakin)]
  tablo <- data.frame(form = form, subscale = f, elenen = elenenler, elenen_metin = unname(metin[elenenler]),
                      en_yakin = unname(en_yakin), en_yakin_metin = unname(metin[en_yakin]),
                      uzaklik = uzaklik, en_zayif = uzaklik == max(uzaklik), stringsAsFactors = FALSE)
  # Denetim: elenen maddelerin uzaklıklarının 14'e bölünmüş toplamı formun CL değerine eşit olmalı
  # (seçilen maddelerin uzaklığı 0 olduğu için CL = toplam uzaklık / 14).
  kontrol(paste0("AS4_CL_temsil_tablosuyla_ayni_", form, "_", f),
          abs(sum(uzaklik) / 14 - sonuc[[paste0("AS4_CL_", form, "_", f)]]) < 1e-12)
  as4_temsil_listesi[[paste0(form, "_", f)]] <- tablo
}

# Tablolar (satır sırası: form PUB21, MIN21, MAX21, COV21; sonra alt boyut D, A, S).
as4_anlamsal <- do.call(rbind, as4_anlamsal_listesi); rownames(as4_anlamsal) <- NULL
as4_temsil <- do.call(rbind, as4_temsil_listesi); rownames(as4_temsil) <- NULL
csv_yaz(as4_anlamsal, "tablo_AS4_anlamsal.csv")
csv_yaz(do.call(rbind, as4_iliski_listesi), "tablo_AS4_SB_CL.csv")
csv_yaz(as4_temsil, "tablo_AS4_madde_temsil.csv")
cat("\nAS4 özeti (SB: anlamsal genişlik, CL: temsil kaybı):\n"); print(as4_anlamsal, row.names = FALSE, digits = 3)
print(do.call(rbind, as4_iliski_listesi), row.names = FALSE, digits = 3)
log_yaz("AS4_HAZIR")
