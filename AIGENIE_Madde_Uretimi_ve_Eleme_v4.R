# AIGENIE_Madde_Uretimi_ve_Eleme_v4.R | 25 Eylül 2026 | UTF-8
#
# Bu betik üç iş yapar:
#   1. OpenAI API ile madde adayları üretir (AIGENIE).
#   2. Her içerik alanından 30 aday alarak 90 maddelik havuz kurar.
#   3. Havuzu GENIE ile eler ve sonuçları TXT ve CSV dosyalarına yazar.
# Uzman puanlaması, saha verisi analizi, form kısaltma veya benzetim içermez.
#
# Çalıştırma
#   İlk kullanımda: install.packages("AIGENIE")
#   API anahtarını yalnızca RStudio Console'da tanımlayın, bu dosyaya yazmayın:
#     Sys.setenv(OPENAI_API_KEY = "sk-proj-...")
#   Çalışma dizinini bu dosyanın klasörü yapın ve şunu çalıştırın:
#     source("AIGENIE_Madde_Uretimi_ve_Eleme_v4.R", encoding = "UTF-8")
#
# Ücret ve kayıtlar
#   Madde üretimi ve gömme (embedding) adımları ücretli API çağrısı yapar.
#   Her adımın sonucu bir .rds dosyasına kaydedilir. Betik yeniden
#   çalıştırıldığında kayıtlı sonuç kullanılır ve API'ye yeniden gidilmez.
#   RDS dosyalarını elle değiştirmeyin.
#
# Kaynak: AIGENIE 2.1.2 kılavuzu ve kaynak kodu
#   https://cran.r-project.org/web/packages/AIGENIE/AIGENIE.pdf
# Durum: API adımları çalıştırılmadı. GENIE ve çıktı adımları, paketin kendi
#   örnek verisiyle (items.gpt5.4.example) API'siz olarak denendi.


## 1. Hazırlık ---------------------------------------------------------------

if (!requireNamespace("AIGENIE", quietly = TRUE))
  stop("Önce install.packages('AIGENIE') komutunu çalıştırın.", call. = FALSE)
if (packageVersion("AIGENIE") != "2.1.2")
  stop("Bu betik AIGENIE 2.1.2 için yazıldı; kurulu sürüm: ",
       packageVersion("AIGENIE"), call. = FALSE)

# Bütün çıktılar bu klasöre yazılır. Yeni bir üretim veya farklı ayarlar için
# klasör adını değiştirin. Eski klasörü silmeyin; önceki koşunun kaydıdır.
cikti <- file.path(getwd(), "AIGENIE_Madde_Ciktilari_v4")
dir.create(cikti, showWarnings = FALSE)
yol <- function(dosya) file.path(cikti, dosya)

alan_basina <- 30L  # Her içerik alanından havuza alınacak aday sayısı (3 x 30 = 90)

# API anahtarını Console'da tanımlanan ortam değişkeninden okur.
api_anahtari <- function() {
  anahtar <- trimws(Sys.getenv("OPENAI_API_KEY"))
  if (!nzchar(anahtar))
    stop("OPENAI_API_KEY tanımlı değil. Başlıktaki Sys.setenv() komutunu kullanın.",
         call. = FALSE)
  anahtar
}

# Dosyalar UTF-8 yazılır; Türkçe karakterler Windows'ta da doğru görünür.
txt_yaz <- function(satirlar, dosya)
  writeLines(enc2utf8(satirlar), yol(dosya), useBytes = TRUE)

# Noktalı virgüllü CSV. Baştaki BOM işareti, Türkçe Excel'in UTF-8'i tanımasını sağlar.
csv_yaz <- function(tablo, dosya) {
  satirlar <- capture.output(write.csv2(tablo, row.names = FALSE, na = ""))
  satirlar[1] <- paste0("﻿", satirlar[1])
  txt_yaz(satirlar, dosya)
}

madde_listesi_yaz <- function(d, dosya)
  txt_yaz(c(scale.title, paste("Madde sayısı:", nrow(d)),
            "Biçim: Madde kimliği | Önsel içerik alanı | Madde metni", "",
            paste(d$ID, d$attribute, d$statement, sep = " | ")), dosya)


## 2. Ölçek tanımı: yapı, içerik alanları ve yazım kuralları ----------------

# Tek madde türü (type) içinde üç içerik alanı (attribute). Üç alan birlikte
# analiz edilir; ayrı üç ölçek değildir ve doğrulanmış faktör sayılmaz.
#   skipping_learning_processes  = öğrenme için gerekli düşünme işlemlerini atlama (1a-1c)
#   skipping_learning_monitoring = kendi öğrenmesini izlemeyi ve değerlendirmeyi atlama (2a-2c)
#   adopting_output_unverified   = çıktıyı sınamadan benimseme (3a-3c)
item.attributes <- list(academic_overreliance = c(
  "skipping_learning_processes",
  "skipping_learning_monitoring",
  "adopting_output_unverified"))

domain <- "educational psychology: self-regulated learning and reliance on generative AI in higher education"
scale.title <- "Akademik Görevlerde Üretken Yapay Zekâya Aşırı Dayanma Ölçeği"
audience <- paste("Türkiye'deki eğitim fakültelerinde lisans öğrenimi gören, 18 yaşını",
  "tamamlamış ve son dört haftada ders işleri için üretken yapay zekâ kullanmış öğretmen adayları")

# Sıklık, madde cümlesiyle değil yanıt seçenekleriyle ölçülür. Paket bu
# seçenekleri sistem rolünün sonuna ekler; maddelere yazdırmaz.
response.options <- c("Hiçbir zaman", "Nadiren", "Bazen", "Çoğu zaman", "Her zaman")

# Yapı tanımı. Dokuz gösterge tanımın parçasıdır; ayrı attribute olarak verilmez
# ve paketten dokuz boyut bulması istenmez.
item.type.definitions <- list(academic_overreliance = paste(
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
  "huzursuzluk, yalnızlık, duygusal bağ; öz yeterlik, beceri kaybı algısı, kopya, intihal ve hile."))

# Üç üslup örneği (her alandan bir: 1b, 2b, 3b). Geçerliği gösterilmiş maddeler
# değildir ve havuza eklenmez. Paket statement, attribute ve type sütunlarını ister.
# Paket, modelden örneklerin yapısını taklit etmesini istediği için maddelerin
# tonunu en çok bu örnekler belirler. Örnekler bu yüzden eksikliği açıkça
# söylemez ("anlamadan", "bakmadan" gibi). Öğrencinin gerçekten yaptığı ve
# kolayca kabul edebileceği davranışı anlatır. Atlanan adım, davranışın
# akışından ya da çıktının yüzeysel bir özelliğinden ("anlaşılır gelince",
# "uygun görünüyorsa") anlaşılır.
item.examples <- data.frame(
  type = "academic_overreliance", attribute = item.attributes[[1]],
  statement = c(
    "Bir tartışma sorusunda yapay zekânın savunduğu görüşü ve gerekçelerini ödevime kendi görüşüm olarak yazarım.",
    "Yapay zekânın açıklaması bana anlaşılır geldiğinde konuyu öğrenmiş sayar ve sonraki konuya geçerim.",
    "Yapay zekânın önerdiği kaynaklar konuma uygun görünüyorsa onları kaynakçama doğrudan eklerim."),
  stringsAsFactors = FALSE)

# Paketin standart istemine eklenen, araştırmaya özgü içerik ve dil kuralları.
# Amaç: sosyal beğenirlik nedeniyle "Hiçbir zaman" yanıtında yığılmayı azaltmak.
prompt.notes <- paste(
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
  "Kapsam dışındaki konulara girme. Yayımlanmış ölçekleri ve verilen örnekleri kopyalama.")

# Özel sistem rolü: paketin kendi uzman rolünün yerine geçer.
system.role <- paste(
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
  "İstenen çıktı biçimine uy.")


## 3. Üretim ve eleme ayarları -----------------------------------------------
# Her iki liste ayarlar.rds dosyasına aynen kaydedilir. Yöntem bölümünde
# raporlanacak değerler bunlardır.

uretim <- list(
  item.attributes = item.attributes, item.type.definitions = item.type.definitions,
  domain = domain, scale.title = scale.title, audience = audience,
  response.options = response.options, item.examples = item.examples,
  prompt.notes = prompt.notes,
  model = "gpt-5.4-2026-03-05",  # Sabit model sürümü; paket varsayılanı "gpt4o"
  target.N = 105L,  # Toplam aday hedefi; paket varsayılanı tür başına 60
  temperature = 1,  # Paket varsayılanı
  top.p = 1,        # Paket varsayılanı
  adaptive = TRUE,  # Paket varsayılanı: önceki maddeler tekrarı önlemek için isteme eklenir
  main.prompts = NULL,  # Kullanıcı istemini paket, yukarıdaki bilgilerle kurar
  system.role = system.role,
  items.only = TRUE,  # Yalnızca madde üret; eleme 5. bölümde ayrıca yapılır
  plot = FALSE, silently = FALSE)
# Paket her API çağrısında her alandan 2 madde ister. Bu yüzden toplam 105'i
# biraz aşabilir (ör. 108). Üretilen bütün adaylar saklanır.

eleme <- list(
  embedding.model = "text-embedding-3-large",  # Paket varsayılanı 3-small
  EGA.model = NULL,            # Paket varsayılanı: glasso ve TMFG denenir
  EGA.algorithm = "walktrap",  # Tek madde türünde paket varsayılanı
  EGA.uni.method = "louvain",  # Paket varsayılanı
  uva.cut.off = 0.20,          # Paket varsayılanı: UVA'daki wTO eşiği
  boot.iter = 500L,            # Paket varsayılanı: bootEGA yineleme sayısı
  ncores = 1L,                 # Tek çekirdek; masaüstünde kaynak kullanımını sınırlar
  run.overall = FALSE, all.together = FALSE,  # Varsayılanlar; tek madde türü var
  plot = FALSE, silently = FALSE)
# Açıklamalar:
# - Büyük gömme modelinin Türkçe havuzda üstün olduğu gösterilmiş değildir.
# - EGA.model = NULL iken paket, NMI'yi yükselten modeli ve gömme türünü seçer.
#   NMI seçimde kullanıldığı için NMI artışı bağımsız geçerlik kanıtı değildir.
# - wTO değeri 0.20 ve üzeri olan madde çiftleri gereksiz tekrar sayılır.
# - bootEGA, gömmeler üzerinde yeniden örnekleme yapar; saha bootstrap'ı değildir.
# - Paket içinde sabit iki değer vardır ve argüman olarak verilmez:
#   madde kararlılığı eşiği 0.75, bootEGA tohum değeri (seed = 123).

# Kayıtlı sonuçlar yalnızca aynı ayarlarla yeniden kullanılır. API anahtarı kaydedilmez.
ayarlar <- list(uretim = uretim, eleme = eleme, alan_basina = alan_basina,
  AIGENIE = as.character(packageVersion("AIGENIE")),
  EGAnet = as.character(packageVersion("EGAnet")))
if (!file.exists(yol("ayarlar.rds"))) saveRDS(ayarlar, yol("ayarlar.rds"))
if (!identical(readRDS(yol("ayarlar.rds")), ayarlar))
  stop("Ayarlar bu klasördeki kayıttan farklı. Yeni koşu için çıktı klasörünün adını değiştirin.",
       call. = FALSE)


## 4. Madde üretimi ve 90 maddelik havuz -------------------------------------

if (file.exists(yol("uretilen_adaylar.rds"))) {
  ham <- readRDS(yol("uretilen_adaylar.rds"))
} else {
  anahtar <- api_anahtari()
  # Python ortamını HuggingFace paketleri olmadan hazırlar (OpenAI için gerekmez).
  AIGENIE::ensure_aigenie_python(include_huggingface = FALSE)
  # do.call(), uretim listesindeki her ögeyi AIGENIE() fonksiyonuna argüman olarak verir.
  ham <- do.call(AIGENIE::AIGENIE, c(uretim, list(openai.API = anahtar)))
  saveRDS(ham, yol("uretilen_adaylar.rds"))
}
# Not: Paket, art arda 40 denemede yeni madde alamazsa üretimi kendisi durdurur.

if (!is.data.frame(ham) || nrow(ham) == 0)
  stop("Üretim madde tablosu döndürmedi. uretilen_adaylar.rds kaydını inceleyin.", call. = FALSE)
ham <- ham[, c("ID", "statement", "attribute", "type")]
ham[] <- lapply(ham, as.character)
madde_listesi_yaz(ham, "00_uretilen_tum_adaylar.txt")

# İçerik denetimi: tanım dışı alan etiketi, yinelenen madde, örnek madde kopyası.
metin <- trimws(gsub("[[:space:]]+", " ", ham$statement))
if (any(!ham$attribute %in% item.attributes[[1]]) || anyDuplicated(metin) ||
    any(metin %in% item.examples$statement))
  stop("Tanım dışı etiket, yinelenen madde veya örnek madde kopyası var. ",
       "00_uretilen_tum_adaylar.txt dosyasını inceleyin.", call. = FALSE)

# Havuz kuralı: her alanın üretim sırasındaki ilk 30 adayı. Dışarıda kalan
# adaylar GENIE tarafından elenmiş sayılmaz; hepsi 00 numaralı dosyadadır.
havuz_id <- c()
for (alan in item.attributes[[1]]) {
  alan_id <- ham$ID[ham$attribute == alan]
  if (length(alan_id) < alan_basina)
    stop(alan, " alanında ", length(alan_id), " aday var; ", alan_basina, " gerekli.",
         call. = FALSE)
  havuz_id <- c(havuz_id, head(alan_id, alan_basina))
}
havuz <- ham[ham$ID %in% havuz_id, ]
saveRDS(havuz, yol("eleme_oncesi_havuz.rds"))
madde_listesi_yaz(havuz, "01_eleme_oncesi_maddeler.txt")


## 5. Gömme ve GENIE elemesi -------------------------------------------------

# Gömmeler bir kez alınır (ücretli) ve kaydedilir. Sonuç bir matristir:
# satırlar gömme boyutları, sütunlar madde kimlikleridir.
if (file.exists(yol("gomme.rds"))) {
  gomme <- readRDS(yol("gomme.rds"))
} else {
  anahtar <- api_anahtari()
  AIGENIE::ensure_aigenie_python(include_huggingface = FALSE)
  gomme <- AIGENIE::GENIE(items = havuz, openai.API = anahtar,
    embedding.model = eleme$embedding.model, embeddings.only = TRUE, plot = FALSE)
  saveRDS(gomme, yol("gomme.rds"))
}

# Eleme API'siz yapılır: UVA (gereksiz tekrar) ve bootEGA (kararlılık).
# GENIE, gömme sütunlarının havuzdaki kimliklerle eşleştiğini kendisi denetler.
if (file.exists(yol("genie_sonucu.rds"))) {
  sonuc <- readRDS(yol("genie_sonucu.rds"))
} else {
  sonuc <- do.call(AIGENIE::GENIE, c(list(items = havuz, embedding.matrix = gomme), eleme))
  saveRDS(sonuc, yol("genie_sonucu.rds"))
}

# Eleme tamamlanmadıysa kısmi sonuç kaydedilir ama "eleme sonrası" diye raporlanmaz.
x <- sonuc$item_type_level$academic_overreliance
if (is.null(x) || is.null(x$final_EGA) || nrow(x$reduction_summary) == 0)
  stop("GENIE tamamlanmış bir çözüm vermedi. Console uyarılarını ve genie_sonucu.rds ",
       "dosyasını inceleyin.", call. = FALSE)

kalan_id <- as.character(x$final_items$ID)
tutuldu <- havuz$ID %in% kalan_id
kalan <- havuz[tutuldu, ]
elenen <- havuz[!tutuldu, ]

# Eleme kaydı: elenen her madde için aşama (UVA, bootEGA...) ve gerekçe.
audit <- sonuc$filtering_audit
if (nrow(audit) == 0)
  audit <- data.frame(ID = character(), removal_stage = character(), reason = character())
if (!setequal(as.character(audit$ID), elenen$ID))
  warning("GENIE eleme kaydı elenen maddelerle tam örtüşmüyor; ",
          "eksik gerekçeler 'Raporlanmadı' olarak yazılır.", call. = FALSE)

# Son EGA çözümünde kestirilen boyut sayısı. final_EGA bir EGA.fit nesnesidir;
# boyut sayısı $EGA$n.dim içindedir. Önsel üç alan bu sayıyı üçe sabitlemez.
boyut_sayisi <- x$final_EGA$EGA$n.dim
boyut_satiri <- paste("GENIE sonunda kestirilen boyut sayısı:",
  if (is.null(boyut_sayisi)) "Raporlanmadı" else boyut_sayisi)


## 6. Çıktı dosyaları --------------------------------------------------------
# Bu bölüm yalnızca GENIE sonucunu dışa aktarır; yeni analiz veya API çağrısı yapmaz.

madde_listesi_yaz(kalan, "02_eleme_sonrasi_maddeler.txt")
madde_listesi_yaz(elenen, "03_elenen_maddeler.txt")

# Türkçe alan adları yalnızca çıktılar içindir; pakete verilen etiketler değişmez.
alan_tr <- c(skipping_learning_processes  = "Öğrenme işlemlerini atlama",
             skipping_learning_monitoring = "Öğrenmeyi izlemeyi atlama",
             adopting_output_unverified   = "Çıktıyı sınamadan benimseme")

# Genel karar listesi: havuzdaki her madde bir satır. match(), satır sırasına
# göre değil madde kimliğine göre eşleştirir. Gerekçeler paketin kaydından
# aynen alınır. EGA topluluğu yalnızca kalan maddelerde vardır.
kayit <- match(havuz$ID, as.character(audit$ID))
genel <- data.frame(
  Sira               = seq_len(nrow(havuz)),
  Madde_kimligi      = havuz$ID,
  Madde_metni        = havuz$statement,
  Onsel_icerik_alani = unname(alan_tr[havuz$attribute]),
  Icerik_alani_kodu  = havuz$attribute,
  GENIE_karari       = ifelse(tutuldu, "Tutuldu", "Elendi"),
  Eleme_asamasi      = ifelse(tutuldu, NA, audit$removal_stage[kayit]),
  Eleme_gerekcesi    = ifelse(tutuldu, NA, audit$reason[kayit]),
  EGA_toplulugu      = x$final_items$EGA_com[match(havuz$ID, kalan_id)])
csv_yaz(genel, "05_genel_madde_karar_listesi.csv")

# Aynı listenin okunabilir TXT biçimi (uzun madde metinleri kesilmez).
yoksa <- function(deger, metin) ifelse(is.na(deger), metin, as.character(deger))
maddeler <- paste0(
  genel$Sira, ". ", genel$Madde_kimligi, " | ", genel$GENIE_karari,
  "\nMadde: ", genel$Madde_metni,
  "\nÖnsel içerik alanı: ", genel$Onsel_icerik_alani, " [", genel$Icerik_alani_kodu, "]",
  "\nSon EGA topluluğu: ",
  ifelse(tutuldu, yoksa(genel$EGA_toplulugu, "Raporlanmadı"), "Uygulanmaz (madde elendi)"),
  "\nEleme aşaması: ",
  ifelse(tutuldu, "Uygulanmaz (madde tutuldu)", yoksa(genel$Eleme_asamasi, "Raporlanmadı")),
  "\nEleme gerekçesi: ",
  ifelse(tutuldu, "Uygulanmaz (madde tutuldu)", yoksa(genel$Eleme_gerekcesi, "Raporlanmadı")),
  "\n")
txt_yaz(c(scale.title, "GENEL MADDE KARAR LİSTESİ", strrep("=", 72),
  paste("Havuz:", nrow(havuz), "| Tutulan:", nrow(kalan), "| Elenen:", nrow(elenen)),
  boyut_satiri,
  "Önsel içerik alanı ile son EGA topluluğu ayrı bilgilerdir; aynı olmak zorunda değildir.",
  "EGA toplulukları madde metinlerinin gömmelerinden kestirilir; katılımcı yanıtı kullanılmamıştır.",
  "Liste yalnızca GENIE'ye verilen havuzu kapsar; üretim fazlası adaylar 00 numaralı dosyadadır.",
  "", maddeler), "05_genel_madde_karar_listesi.txt")

# Kısa özet. Eleme kaydının tamamı (25 sütun) genie_sonucu.rds içindedir.
kayit_ozeti <- audit[, intersect(c("ID", "attribute", "removal_stage", "reason"),
                                 names(audit)), drop = FALSE]
txt_yaz(c(paste("Başlangıç:", nrow(havuz)), paste("Kalan:", nrow(kalan)),
  paste("Elenen:", nrow(elenen)), boyut_satiri,
  "Boyut sayısı metin gömmelerindeki son EGA çözümüne aittir; saha doğrulaması değildir.",
  "Genel madde karar listesi: 05_genel_madde_karar_listesi.txt / .csv", "",
  "Aşama özeti (NMI: önsel alanlar ile EGA toplulukları arasındaki uyum):",
  capture.output(print(x$reduction_summary)), "",
  "Eleme gerekçeleri:", capture.output(print(kayit_ozeti))), "04_GENIE_ozeti.txt")
txt_yaz(capture.output(sessionInfo()), "oturum_bilgisi.txt")

message("Tamamlandı. Başlangıç: ", nrow(havuz), "; kalan: ", nrow(kalan),
        "; elenen: ", nrow(elenen), "\n", boyut_satiri,
        "\nÇıktı klasörü: ", normalizePath(cikti, winslash = "/"))
# Kalan maddeler GENIE'nin doğal çıktısıdır; 18 maddelik nihai saha formu değildir.
