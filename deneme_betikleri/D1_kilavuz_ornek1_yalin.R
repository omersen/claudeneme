# D1_kilavuz_ornek1_yalin.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# Kılavuzdaki Örnek 1'e ("Using AI-GENIE with Default Prompts") en yakın deneme.
# Pakete yalnızca alan kodları, tek cümlelik bir tanım, alan (domain) ve ölçek adı
# verilir. Örnek madde, hedef kitle, yanıt seçeneği ve özel sistem rolü yoktur.
# Tek ek, maddelerin Türkçe yazılmasını isteyen bir satırdır; paketin istemi
# İngilizce olduğu için bu satır olmadan maddeler İngilizce gelir.
#
# Soru: En az yönlendirmeyle model ne üretiyor? Diğer denemelerin karşılaştırma
# noktası budur.
#
# Çalıştırma: RStudio'da çalışma dizinini deneme_betikleri klasörü yapın, sonra
#   source("D1_kilavuz_ornek1_yalin.R", encoding = "UTF-8")
# İlk çalıştırma yalnızca istem önizlemesini yazar (ücretsiz).

CALISTIR <- FALSE  # TRUE: maddeler üretilir (ücretli API çağrısı)
GENIE <- FALSE     # TRUE: gömme alınır (ücretli) ve GENIE elemesi yapılır

source("00_ortak_calistirici.R", encoding = "UTF-8")

uretim <- list(
  item.attributes = list(academic_overreliance = c(
    "skipping_learning_processes",
    "skipping_learning_monitoring",
    "adopting_output_unverified")),
  item.type.definitions = list(academic_overreliance = paste(
    "Akademik görevlerde üretken yapay zekâya aşırı dayanma, öğrencinin kendi düşünmesi,",
    "öğrenmesini izlemesi ve doğrulaması yerine yapay zekâ çıktılarını çalışmasının",
    "dayanağı yapma eğilimidir.")),
  domain = "educational psychology",
  scale.title = "Akademik Görevlerde Üretken Yapay Zekâya Aşırı Dayanma Ölçeği",
  prompt.notes = "Bütün maddeleri Türkiye Türkçesiyle, birinci tekil kişi ve geniş zamanda yaz.",
  target.N = 30L)  # Pilot: tür başına 30 madde (her alandan yaklaşık 10)

deney_calistir("D1", uretim, calistir = CALISTIR, genie = GENIE)
