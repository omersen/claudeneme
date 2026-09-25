# D3_tanim_ve_ornekler.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# D2 ile aynı girdiler + her alandan bir örnek madde. Başka hiçbir şey değişmez.
# Paket, örnekleri modele "yapısını MUTLAKA taklit et" diyerek verir; bu yüzden
# örnekler maddelerin kalıbını güçlü biçimde belirleyebilir.
#
# Soru: Örnek maddeler maddeleri iyileştiriyor mu, yoksa kalıba mı sokuyor?
# Karşılaştırın: D2 ile D3. Örnekleri değiştirip yeni bir deneme adıyla
# (ör. "D3b") yeniden çalıştırarak farklı örnek setlerini de sınayabilirsiniz.
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("D3_tanim_ve_ornekler.R", encoding = "UTF-8")

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
  # Örnekler: öğrencinin gerçekte yaptığı, eksikliği açıkça söylemeyen davranışlar (v4).
  item.examples = data.frame(
    type = "academic_overreliance",
    attribute = c("skipping_learning_processes", "skipping_learning_monitoring",
                  "adopting_output_unverified"),
    statement = c(
      "Bir tartışma sorusunda yapay zekânın savunduğu görüşü ve gerekçelerini ödevime kendi görüşüm olarak yazarım.",
      "Yapay zekânın açıklaması bana anlaşılır geldiğinde konuyu öğrenmiş sayar ve sonraki konuya geçerim.",
      "Yapay zekânın önerdiği kaynaklar konuma uygun görünüyorsa onları kaynakçama doğrudan eklerim."),
    stringsAsFactors = FALSE),
  prompt.notes = "Bütün maddeleri Türkiye Türkçesiyle, birinci tekil kişi ve geniş zamanda yaz.",
  target.N = 30L)

deney_calistir("D3", uretim, calistir = CALISTIR, genie = GENIE)
