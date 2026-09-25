# D5_kilavuz_ornek2_ozel_istem.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# Kılavuzdaki Örnek 2 ("Using AI-GENIE with Custom Prompts"). İstemi paket değil
# araştırmacı yazar (main.prompts) ve özel sistem rolü verilir. Kılavuzdaki gibi
# yalnızca ölçek adı eklenir; tanım, örnek ve yazım kuralları istemin içindedir.
#
# Paketin iki kuralı (AIGENIE 2.1.2 kaynak kodu):
#   - İstem her alan kodunu AYNEN içermelidir. İçermezse paket yalnızca bir not
#     yazar ve sessizce kendi otomatik istemine döner. Önizleme dosyası bu
#     durumda başta UYARI satırı gösterir.
#   - Otomatik istemdeki "her alandan 2 madde yaz" cümlesi özel istemde yoktur;
#     madde sayısını istemin kendisi söylemelidir. JSON biçim talimatını paket ekler.
#
# Soru: Paketin İngilizce istem iskeleti yerine tamamen Türkçe ve davranışa
# odaklı bir istem daha uygun maddeler üretiyor mu? Karşılaştırın: D4 ile D5.
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("D5_kilavuz_ornek2_ozel_istem.R", encoding = "UTF-8")

CALISTIR <- FALSE  # TRUE: maddeler üretilir (ücretli API çağrısı)
GENIE <- FALSE     # TRUE: gömme alınır (ücretli) ve GENIE elemesi yapılır

source("00_ortak_calistirici.R", encoding = "UTF-8")

uretim <- list(
  item.attributes = list(academic_overreliance = c(
    "skipping_learning_processes",
    "skipping_learning_monitoring",
    "adopting_output_unverified")),
  main.prompts = list(academic_overreliance = paste(
    "Öğretmen adaylarının ders işlerinde üretken yapay zekâya aşırı dayanma eğilimini",
    "ölçen Türkçe öz bildirim maddeleri yaz. Aşırı dayanma, öğrencinin yapay zekâ",
    "çıktısını kendi düşünmesinin, öğrenmesini izlemesinin veya doğrulamasının yerine",
    "koyarak çalışmasının dayanağı yapmasıdır. Sık veya verimli kullanım tek başına",
    "aşırı dayanma değildir.",
    "Üç içerik alanı vardır:",
    "(1) skipping_learning_processes: Öğrenci, kendisinin yapması gereken düşünme işini",
    "(çözüm, gerekçe, argüman, alıştırma) yapay zekâya bırakır ve çıktıyı çalışmasında kullanır.",
    "(2) skipping_learning_monitoring: Öğrenci, konuyu ne kadar anladığına veya",
    "çalışmasının yeterli olup olmadığına yapay zekâ çıktısına bakarak karar verir.",
    "(3) adopting_output_unverified: Öğrenci, yapay zekânın verdiği bilgi, kaynak ve",
    "yanıtları olduğu gibi çalışmasına katar.",
    "Her içerik alanı için tam olarak 2 madde yaz (toplam 6 madde).",
    "Maddeler birinci tekil kişi ve geniş zamanda, 8-20 sözcük uzunluğunda olsun.",
    "Her madde, öğretmen adaylarının ders çalışırken gerçekten yaptığı ve rahatça kabul",
    "edebileceği tek bir somut davranışı anlatsın; davranışı hata veya eksiklik olarak sunma.",
    "Yanıtlar 'Hiçbir zaman'dan 'Her zaman'a uzanan beşli sıklık ölçeğiyle verilecek;",
    "bu yüzden maddelere sıklık sözcüğü koyma. Ödev, proje, sunum, sınav hazırlığı,",
    "ders okumaları ve problem çözme bağlamlarını çeşitlendir.",
    "Ters madde, çift olumsuzluk ve marka adı kullanma.")),
  system.role = paste(
    "Sen, üniversite öğrencileri için Türkçe öz bildirim ölçekleri geliştiren deneyimli",
    "bir ölçme ve değerlendirme uzmanısın. Maddelerin öğrencilerin gündelik çalışma",
    "alışkanlıklarını doğal ve yargısız bir dille anlatmasına özen gösterirsin."),
  scale.title = "Akademik Görevlerde Üretken Yapay Zekâya Aşırı Dayanma Ölçeği",
  target.N = 30L)

deney_calistir("D5", uretim, calistir = CALISTIR, genie = GENIE)
