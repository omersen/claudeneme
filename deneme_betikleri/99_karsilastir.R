# 99_karsilastir.R | 25 Eylül 2026 | UTF-8
#
# Çalıştırılmış denemelerin (Deneme_Ciktilari/D*) sonuçlarını bir araya getirir.
# API çağrısı yapmaz. Üç dosya yazar (Deneme_Ciktilari klasörüne):
#
#   karsilastirma_ozet.csv       Deneme başına kaba metin göstergeleri (ve varsa GENIE)
#   kor_degerlendirme_formu.csv  Bütün maddeler karışık sırada, deneme adı gizli.
#                                Siz veya uzmanlar her maddeyi puanlarsınız.
#   kor_degerlendirme_anahtari.csv  Sıra numarasının hangi denemeye ait olduğu.
#                                Puanlama bitmeden açmayın.
#
# Neden kör değerlendirme? Hangi denemeden geldiğini bilmek, maddeyi okurken
# yargıyı etkileyebilir. Kaba göstergeler (eksiklik kalıbı, sıklık sözcüğü,
# tekrar eden başlangıç) yalnızca yol gösterir; maddenin uygunluğuna karar
# vermez.
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("99_karsilastir.R", encoding = "UTF-8")

source("00_ortak_calistirici.R", encoding = "UTF-8")
kok <- file.path(getwd(), "Deneme_Ciktilari")
klasorler <- list.dirs(kok, recursive = FALSE)
klasorler <- klasorler[file.exists(file.path(klasorler, "maddeler.csv"))]
if (length(klasorler) == 0)
  stop("Henüz madde üretilmiş deneme yok. Önce bir deneme betiğini CALISTIR <- TRUE ile çalıştırın.",
       call. = FALSE)

oku <- function(dosya) read.csv2(dosya, fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)
ozet <- do.call(rbind, lapply(file.path(klasorler, "tanilama.csv"), oku))
maddeler <- do.call(rbind, lapply(file.path(klasorler, "maddeler.csv"), oku))
.csv_yaz(ozet, file.path(kok, "karsilastirma_ozet.csv"))

set.seed(20260925)  # Karışık sıra her çalıştırmada aynı olsun
sira <- sample(nrow(maddeler))
form <- data.frame(
  Sira = seq_along(sira),
  Madde = maddeler$Madde[sira],
  Uygunluk_1_5 = "",            # 1 = hiç uygun değil, 5 = tamamen uygun
  Ogrenci_kabul_eder_mi_1_5 = "",  # Öğrenci bu davranışı dürüstçe onaylayabilir mi?
  Yapiyi_yansitiyor_mu_1_5 = "",   # Sık kullanımı değil, aşırı dayanmayı mı anlatıyor?
  Not = "")
anahtar <- data.frame(Sira = seq_along(sira), Deney = maddeler$Deney[sira],
                      Kimlik = maddeler$Kimlik[sira], Tur = maddeler$Tur[sira],
                      Alan = maddeler$Alan[sira])
.csv_yaz(form, file.path(kok, "kor_degerlendirme_formu.csv"))
.csv_yaz(anahtar, file.path(kok, "kor_degerlendirme_anahtari.csv"))

print(ozet[, c("Deney", "Madde_sayisi", "Ortalama_sozcuk", "Eksiklik_kalibi_yuzde",
               "Siklik_sozcugu_yuzde", "En_sik_baslangic", "En_sik_baslangic_yuzde",
               "Tanim_disi_etiket")], row.names = FALSE)
message("Karşılaştırma dosyaları yazıldı: ", kok,
        "\nPuanlamadan sonra formu anahtarla Sira sütunu üzerinden birleştirin ",
        "ve puanları denemelere göre karşılaştırın.")
