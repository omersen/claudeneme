# D4_v4_tum_girdiler.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# v4 betiğinin bütün üretim girdileri: D3'e ayrıntılı yazım kuralları
# (prompt.notes) ve özel sistem rolü eklenir. Yalnızca madde sayısı pilot için
# 30'a indirilmiştir; model ve öteki ayarlar aynıdır.
#
# Soru: Uzun yazım kuralları ve özel rol maddeleri iyileştiriyor mu, yoksa
# modeli fazla kısıtlayıp kalıplaşmış maddelere mi yol açıyor?
# Karşılaştırın: D3 ile D4. D4 sonuçları v4 ile üretilen maddelere
# benziyorsa, sorunun kaynağı D1-D4 merdiveninde aranabilir.
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("D4_v4_tum_girdiler.R", encoding = "UTF-8")

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
  prompt.notes = paste(
    "Maddeleri doğal Türkiye Türkçesiyle, birinci tekil kişi ve geniş zamanda yaz.",
    "Her madde 8-20 sözcükle, öğretmen adaylarının ders çalışırken gerçekten yaptığı ve",
    "rahatça kabul edebileceği tek bir somut davranışı anlatsın. Davranışı bir eksiklik",
    "veya hata olarak değil, gündelik bir çalışma alışkanlığı olarak yaz.",
    "Atlanan işlemi anlamadan, düşünmeden, kontrol etmeden, bakmadan, sorgulamadan gibi",
    "eksiklik bildiren sözcüklerle açıkça söyleme. Atlanan adım, davranışın akışından",
    "(ör. çıktıyı alıp doğrudan ödeve geçirme) veya çıktının ikna edici, anlaşılır ya da",
    "uygun görünmesi gibi yüzeysel bir ipucundan anlaşılsın.",
    "Madde yine de yalnızca sık veya verimli kullanımı değil, çıktının çalışmanın ya da",
    "kararın dayanağı yapılmasını anlatmalı; aynı ifade kalıbını yineleme.",
    "Gerekirse teslim tarihinin yaklaşması gibi yaygın bir durum ekle, ama her maddeye ekleme.",
    "Her alanın üç göstergesini yaklaşık dengeli kapsa; alanlara yapay sözel kalıplar atama.",
    "Son dört hafta yanıt çerçevesidir. Bazen, genellikle, her zaman gibi sıklık veya",
    "eskiden, artık, giderek gibi değişim sözcüklerini maddelere koyma.",
    "Ters madde, çift olumsuzluk, marka adı, teknik terim, ahlaki yargı veya damgalama kullanma.",
    "Marka adı yerine yapay zekâ yaz. Ödev, proje, sunum, sınav hazırlığı, akademik yazı,",
    "ders okumaları ve problem çözme bağlamlarını çeşitlendir. Bölüme özgü bilgi veya",
    "birçok öğrencinin karşılaşmayacağı özel koşullar gerektirme.",
    "Kapsam dışındaki konulara girme. Yayımlanmış ölçekleri ve verilen örnekleri kopyalama."),
  system.role = paste(
    "Eğitim ve psikolojide ölçme ve değerlendirme, ölçek geliştirme",
    "ve öz düzenlemeli öğrenme alanlarında uzman bir araştırmacısın.",
    "Görevin, öğretmen adaylarının akademik görevlerde üretken",
    "yapay zekâya aşırı dayanma eğilimini ölçmek için",
    "Türkçe öz bildirim maddeleri hazırlamaktır.",
    "Verilen yapı tanımına, içerik alanlarına, hedef kitlenin",
    "özelliklerine ve madde yazım kurallarına bağlı kal.",
    "İçerik alanlarını önceden doğrulanmış faktörler olarak kabul etme.",
    "Sık veya yararlı yapay zekâ kullanımını tek başına",
    "aşırı dayanma olarak değerlendirme.",
    "Maddelerde, akademik görevin gerektirdiği düşünme,",
    "kendi öğrenmesini izleme veya çıktıyı doğrulama",
    "işlemlerinin atlanmasına odaklan.",
    "Öğrenciler kendilerini olumsuz gösteren maddeleri reddetme eğilimindedir.",
    "Bu yüzden atlanan işlemi açıkça söyleme; öğrencinin gerçekte yaptığı ve",
    "rahatça kabul edebileceği somut davranışı yaz.",
    "Her maddede tek bir davranışı açık ve doğal Türkçeyle ifade et.",
    "Yargılayıcı, damgalayıcı veya bağımlılık tanısı ima eden",
    "ifadeler kullanma.",
    "Verilen örnekleri yalnızca dil ve anlatım bakımından rehber al.",
    "Örnekleri veya yayımlanmış ölçek maddelerini kopyalama.",
    "İstenen çıktı biçimine uy."),
  target.N = 30L)

deney_calistir("D4", uretim, calistir = CALISTIR, genie = GENIE)
