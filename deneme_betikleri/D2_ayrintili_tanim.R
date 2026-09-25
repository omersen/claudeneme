# D2_ayrintili_tanim.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# D1'e ayrıntılı yapı tanımı (dokuz gösterge ve kapsam dışı ile), hedef kitle ve
# yanıt seçenekleri eklenir. Örnek madde ve ek yazım kuralı yoktur.
#
# Soru: Ayrıntılı tanım maddeleri iyileştiriyor mu, yoksa tanımdaki
# "anlamadan", "değerlendirmeden" gibi ifadeler maddelere mi taşınıyor?
# Karşılaştırın: D1 ile D2.
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("D2_ayrintili_tanim.R", encoding = "UTF-8")

CALISTIR <- FALSE  # TRUE: maddeler üretilir (ücretli API çağrısı)
GENIE <- FALSE     # TRUE: gömme alınır (ücretli) ve GENIE elemesi yapılır

source("00_ortak_calistirici.R", encoding = "UTF-8")

uretim <- list(
  item.attributes = list(academic_overreliance = c(
    "skipping_learning_processes",
    "skipping_learning_monitoring",
    "adopting_output_unverified")),
  item.type.definitions = list(academic_overreliance = paste(
    "Akademik görevlerde üretken yapay zekâya aşırı dayanma, kişinin görevin öğrenme",
    "amacı ve doğruluk gereklilikleri bakımından gerekli düşünme, doğrulama ve kendi",
    "öğrenmesini izleme süreçlerini yeterince yürütmeden yapay zekâ çıktılarını",
    "çalışmasının veya kararlarının dayanağı yapma eğilimidir.",
    "Sık kullanım tek başına aşırı dayanma değildir. Bu bir öz bildirim eğilimidir;",
    "yanlış öneriye fiilen uyma, öğrenme kaybı veya bağımlılık tanısı doğrudan ölçülmez.",
    "Üç içerik alanı ve dokuz gösterge aşağıdadır; bunlar doğrulanmış faktörler değildir.",
    "(1) skipping_learning_processes: Öğrenme için gerekli düşünme işlemlerini atlama.",
    "1a: Çözümün, açıklamanın veya argümanın gerekçesini anlamadan kullanma.",
    "1b: Kendi gerekçesini oluşturmadan yapay zekânın yargısını benimseme.",
    "1c: Öğrenme amacıyla kendisinin yürütmesi gereken işlemi çıktıyla geçiştirme.",
    "(2) skipping_learning_monitoring: Kendi öğrenmesini izlemeyi ve değerlendirmeyi atlama.",
    "2a: Önerilen çalışma planını kendi ihtiyacına uygunluğunu değerlendirmeden izleme.",
    "2b: Yanıt elde edilince kendi anlama düzeyini yoklamadan ilerleme.",
    "2c: Çalışmasının yeterliğine kendi değerlendirmesini yapmadan karar verme.",
    "(3) adopting_output_unverified: Çıktıyı sınamadan benimseme.",
    "3a: Doğrulama gerektiren bilgiyi güvenilir kaynakla karşılaştırmadan kullanma.",
    "3b: Kaynağın varlığını ve iddiayı destekleyip desteklemediğini denetlememe.",
    "3c: Şüphe veya çelişki varken çıktının dayanağını sınamadan benimseme.",
    "Kapsam dışı: Yalnızca sık, verimli, stratejik veya ilk başvuru kaynağı olarak kullanma;",
    "kendi değerlendirmesinden sonra öneri kabul etme; biçim ve dil düzeltmesi gibi",
    "düşük riskli kullanımlar; genel güven veya tutum; kaygı, yoksunluk, erişemeyince",
    "huzursuzluk, yalnızlık, duygusal bağ; öz yeterlik, beceri kaybı algısı, kopya, intihal ve hile.")),
  domain = "educational psychology: self-regulated learning and reliance on generative AI in higher education",
  scale.title = "Akademik Görevlerde Üretken Yapay Zekâya Aşırı Dayanma Ölçeği",
  audience = paste("Türkiye'deki eğitim fakültelerinde lisans öğrenimi gören, 18 yaşını",
    "tamamlamış ve son dört haftada ders işleri için üretken yapay zekâ kullanmış öğretmen adayları"),
  response.options = c("Hiçbir zaman", "Nadiren", "Bazen", "Çoğu zaman", "Her zaman"),
  prompt.notes = "Bütün maddeleri Türkiye Türkçesiyle, birinci tekil kişi ve geniş zamanda yaz.",
  target.N = 30L)

deney_calistir("D2", uretim, calistir = CALISTIR, genie = GENIE)
