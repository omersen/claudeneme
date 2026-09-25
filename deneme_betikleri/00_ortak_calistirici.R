# 00_ortak_calistirici.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# D1-D6 deneme betiklerinin ortak işlemleri. Bu dosyayı doğrudan çalıştırmayın;
# deneme betikleri source() ile kendisi yükler.
#
# Amaç: Uygun olmayan maddelerin nedenini bulmak. Her deneme betiği AIGENIE'ye
# giden girdilerden yalnızca bir kısmını değiştirir. Model, sıcaklık ve madde
# sayısı bütün denemelerde aynıdır; böylece farkı girdilere bağlayabilirsiniz.
#
#   D1  Kılavuz Örnek 1'e en yakın: kısa tanım, alan kodları, alan ve ölçek adı
#   D2  D1 + ayrıntılı yapı tanımı, hedef kitle, yanıt seçenekleri
#   D3  D2 + örnek maddeler                   (D2 ile karşılaştırma: örneklerin etkisi)
#   D4  v4 betiğinin bütün girdileri          (D3 ile karşılaştırma: yazım kuralları ve rol)
#   D5  Kılavuz Örnek 2: araştırmacının yazdığı Türkçe istem ve sistem rolü
#   D6  Kılavuz Örnek 1'in yapısı: üç madde türü, dokuz davranış etiketi
#
# Her deneme üç adımda çalışır:
#   1. İstem önizlemesi (ücretsiz): modele gidecek sistem rolü ve kullanıcı istemi
#      gonderilen_istem.txt dosyasına yazılır. API çağrısı yapılmaz.
#   2. Madde üretimi (ücretli): yalnızca deneme betiğinde CALISTIR <- TRUE ise.
#   3. GENIE elemesi (gömme ücretli, eleme ücretsiz): yalnızca GENIE <- TRUE ise.
# Her adımın sonucu .rds dosyasına kaydedilir; yeniden çalıştırmada API'ye gidilmez.

if (!requireNamespace("AIGENIE", quietly = TRUE))
  stop("Önce install.packages('AIGENIE') komutunu çalıştırın.", call. = FALSE)
if (packageVersion("AIGENIE") != "2.1.2")
  stop("Bu betikler AIGENIE 2.1.2 için yazıldı; kurulu sürüm: ",
       packageVersion("AIGENIE"), call. = FALSE)

# Bütün denemelerde sabit tutulan ayarlar -----------------------------------
MODEL <- "gpt-5.4-2026-03-05"          # Paket varsayılanı "gpt4o"
GOMME_MODELI <- "text-embedding-3-large"
GENIE_AYARLARI <- list(                 # v4 betiğiyle aynı (paket varsayılanları + tek çekirdek)
  EGA.model = NULL, EGA.algorithm = "walktrap", EGA.uni.method = "louvain",
  uva.cut.off = 0.20, boot.iter = 500L, ncores = 1L, plot = FALSE, silently = FALSE)

# Yardımcılar ------------------------------------------------------------------
.yaz <- function(satirlar, dosya) writeLines(enc2utf8(satirlar), dosya, useBytes = TRUE)

.csv_yaz <- function(tablo, dosya) {  # Noktalı virgüllü, BOM'lu UTF-8 (Türkçe Excel için)
  satirlar <- capture.output(write.csv2(tablo, row.names = FALSE, na = ""))
  satirlar[1] <- paste0("﻿", satirlar[1])
  .yaz(satirlar, dosya)
}

.api_anahtari <- function() {
  anahtar <- trimws(Sys.getenv("OPENAI_API_KEY"))
  if (!nzchar(anahtar))
    stop("OPENAI_API_KEY tanımlı değil. Console'da Sys.setenv(OPENAI_API_KEY = \"sk-...\") ",
         "komutunu çalıştırın.", call. = FALSE)
  anahtar
}

# Kaba metin göstergeleri. Karar vermek için değil, gözle incelemeyi yönlendirmek içindir.
.sozcuk <- function(x) lengths(strsplit(trimws(x), "[[:space:]]+"))
.eksiklik <- function(x)  # "-madan/-meden" ile biten sözcük: anlamadan, bakmadan, düşünmeden...
  grepl("\\p{L}+(madan|meden)(?!\\p{L})", tolower(x), perl = TRUE)
.siklik <- function(x)
  grepl("(?<!\\p{L})(genellikle|sık sık|her zaman|bazen|çoğu zaman|hiçbir zaman|nadiren|sürekli|daima)(?!\\p{L})",
        tolower(x), perl = TRUE)
.baslangic <- function(x)  # İlk iki sözcük: kalıp tekrarını görmek için
  vapply(strsplit(trimws(x), "[[:space:]]+"), function(s) paste(head(s, 2), collapse = " "), "")

# İstem önizlemesi -------------------------------------------------------------
# AIGENIE() fonksiyonunun istem kurma adımlarını API'ye gitmeden yineler
# (paketin iç fonksiyonları; AIGENIE 2.1.2 kaynak kodundaki sırayla).
istem_onizle <- function(uretim) {
  g <- function(ad) uretim[[ad]]
  v <- AIGENIE:::validate_user_input_AIGENIE(
    item.attributes = g("item.attributes"), openai.API = "onizleme", hf.token = NULL,
    main.prompts = g("main.prompts"), groq.API = NULL, anthropic.API = NULL, jina.API = NULL,
    model = MODEL, temperature = 1, top.p = 1, embedding.model = GOMME_MODELI,
    target.N = g("target.N"), domain = g("domain"), scale.title = g("scale.title"),
    item.examples = g("item.examples"), audience = g("audience"),
    item.type.definitions = g("item.type.definitions"),
    response.options = g("response.options"), prompt.notes = g("prompt.notes"),
    system.role = g("system.role"), EGA.model = NULL, EGA.algorithm = NULL,
    EGA.uni.method = NULL, keep.org = FALSE, items.only = TRUE, embeddings.only = FALSE,
    adaptive = TRUE, run.overall = FALSE, all.together = FALSE, plot = FALSE, silently = TRUE)
  rol <- AIGENIE:::create_system.role(g("domain"), g("scale.title"), g("audience"),
                                      g("response.options"), g("system.role"))
  istemler <- if (v$custom) {
    AIGENIE:::modify_main.prompts(v$main.prompts, v$item.attributes, v$item.type.definitions,
      g("domain"), g("scale.title"), v$prompt.notes, g("audience"), v$item.examples)
  } else {
    AIGENIE:::create_main.prompts(v$item.attributes, v$item.type.definitions,
      g("domain"), g("scale.title"), v$prompt.notes, g("audience"), v$item.examples)
  }
  uyari <- if (!is.null(g("main.prompts")) && !v$custom)
    c("UYARI: Özel istem kullanılmayacak. İstem her alan kodunu aynen içermediği için",
      "paket otomatik istem kurdu. Aşağıdaki istem, gerçekte gönderilecek olandır.", "")
  c(uyari, "=== SİSTEM ROLÜ ===", rol, "",
    unlist(lapply(names(istemler), function(tur)
      c(paste0("=== KULLANICI İSTEMİ: ", tur, " ==="), istemler[[tur]], ""))),
    "Not: İlk çağrıdan sonra paket, o ana kadar üretilen maddeleri istemin sonuna",
    "ekler ve bunları yinelememesini ister (adaptive = TRUE).")
}

# Ana işlev --------------------------------------------------------------------
deney_calistir <- function(deney_adi, uretim, calistir = FALSE, genie = FALSE) {
  klasor <- file.path(getwd(), "Deneme_Ciktilari", deney_adi)
  dir.create(klasor, recursive = TRUE, showWarnings = FALSE)
  yol <- function(dosya) file.path(klasor, dosya)
  uretim <- c(uretim, list(model = MODEL, items.only = TRUE, silently = FALSE))

  # 1. İstem önizlemesi (ücretsiz)
  .yaz(istem_onizle(uretim), yol("gonderilen_istem.txt"))
  if (!calistir) {
    message(deney_adi, ": istem önizlemesi yazıldı -> ", yol("gonderilen_istem.txt"),
            "\nİstemi okuyun. Madde üretmek için betikte CALISTIR <- TRUE yapın.")
    return(invisible(NULL))
  }

  # 2. Ayar kaydı: kayıtlı sonuçlar yalnızca aynı ayarlarla yeniden kullanılır.
  ayarlar <- list(uretim = uretim, gomme_modeli = GOMME_MODELI, genie = GENIE_AYARLARI,
                  AIGENIE = as.character(packageVersion("AIGENIE")))
  if (!file.exists(yol("ayarlar.rds"))) saveRDS(ayarlar, yol("ayarlar.rds"))
  if (!identical(readRDS(yol("ayarlar.rds")), ayarlar))
    stop(deney_adi, " ayarları kayıttan farklı. Deneme adını değiştirin (ör. \"",
         deney_adi, "b\") ya da eski klasörü başka bir yere taşıyın.", call. = FALSE)

  # 3. Madde üretimi (ücretli; kayıt varsa tekrarlanmaz)
  if (file.exists(yol("uretilen_maddeler.rds"))) {
    ham <- readRDS(yol("uretilen_maddeler.rds"))
  } else {
    anahtar <- .api_anahtari()
    AIGENIE::ensure_aigenie_python(include_huggingface = FALSE)
    ham <- do.call(AIGENIE::AIGENIE, c(uretim, list(openai.API = anahtar)))
    saveRDS(ham, yol("uretilen_maddeler.rds"))
  }
  if (!is.data.frame(ham) || nrow(ham) == 0)
    stop(deney_adi, ": üretim madde döndürmedi. uretilen_maddeler.rds kaydını inceleyin.",
         call. = FALSE)
  ham <- ham[, c("ID", "type", "attribute", "statement")]
  ham[] <- lapply(ham, as.character)
  gecerli <- mapply(function(t, a) a %in% uretim$item.attributes[[t]], ham$type, ham$attribute)

  maddeler <- data.frame(
    Deney = deney_adi, Kimlik = ham$ID, Tur = ham$type, Alan = ham$attribute,
    Madde = ham$statement, Sozcuk = .sozcuk(ham$statement),
    Eksiklik_kalibi = .eksiklik(ham$statement), Siklik_sozcugu = .siklik(ham$statement),
    Tanim_disi_etiket = !gecerli, GENIE_karari = NA, Eleme_gerekcesi = NA, EGA_toplulugu = NA)
  bas <- sort(table(.baslangic(ham$statement)), decreasing = TRUE)
  tanilama <- data.frame(
    Deney = deney_adi, Madde_sayisi = nrow(ham),
    Ortalama_sozcuk = round(mean(maddeler$Sozcuk), 1),
    Eksiklik_kalibi_yuzde = round(100 * mean(maddeler$Eksiklik_kalibi)),
    Siklik_sozcugu_yuzde = round(100 * mean(maddeler$Siklik_sozcugu)),
    En_sik_baslangic = names(bas)[1],
    En_sik_baslangic_yuzde = round(100 * bas[[1]] / nrow(ham)),
    Tanim_disi_etiket = sum(!gecerli),
    GENIE_kalan = NA, GENIE_boyut = NA, GENIE_NMI_son = NA)

  # 4. GENIE elemesi (isteğe bağlı). Pilot denemede havuz kesilmez: tanımlı
  #    etiket taşıyan bütün maddeler analize girer.
  if (genie) {
    maddeler_g <- ham[gecerli, ]
    if (file.exists(yol("gomme.rds"))) {
      gomme <- readRDS(yol("gomme.rds"))
    } else {
      anahtar <- .api_anahtari()
      AIGENIE::ensure_aigenie_python(include_huggingface = FALSE)
      gomme <- AIGENIE::GENIE(items = maddeler_g, openai.API = anahtar,
        embedding.model = GOMME_MODELI, embeddings.only = TRUE, plot = FALSE)
      saveRDS(gomme, yol("gomme.rds"))
    }
    if (file.exists(yol("genie_sonucu.rds"))) {
      sonuc <- readRDS(yol("genie_sonucu.rds"))
    } else {
      sonuc <- do.call(AIGENIE::GENIE,
                       c(list(items = maddeler_g, embedding.matrix = gomme), GENIE_AYARLARI))
      saveRDS(sonuc, yol("genie_sonucu.rds"))
    }
    ozet <- c()
    kalan <- data.frame(ID = character(), EGA_com = character())
    for (tur in unique(maddeler_g$type)) {
      x <- sonuc$item_type_level[[tur]]
      if (is.null(x) || is.null(x$final_EGA) || nrow(x$reduction_summary) == 0) {
        ozet <- c(ozet, paste0(tur, ": GENIE tamamlanmadı (Console uyarılarına bakın)"), "")
        next
      }
      kalan <- rbind(kalan, data.frame(ID = as.character(x$final_items$ID),
                                       EGA_com = as.character(x$final_items$EGA_com)))
      ozet <- c(ozet, paste0(tur, ": başlangıç ", x$start_N, ", kalan ", x$final_N,
                             ", boyut ", x$final_EGA$EGA$n.dim,
                             ", NMI ", round(x$initial_NMI, 3), " -> ", round(x$final_NMI, 3)),
                capture.output(print(x$reduction_summary)), "")
    }
    analizde <- maddeler$Kimlik %in% maddeler_g$ID
    audit <- sonuc$filtering_audit
    maddeler$GENIE_karari <- ifelse(!analizde, "Analize alınmadı",
                               ifelse(maddeler$Kimlik %in% kalan$ID, "Tutuldu", "Elendi"))
    maddeler$EGA_toplulugu <- kalan$EGA_com[match(maddeler$Kimlik, kalan$ID)]
    if (nrow(audit) > 0)
      maddeler$Eleme_gerekcesi <- ifelse(maddeler$GENIE_karari == "Elendi",
        paste(audit$removal_stage, audit$reason, sep = ": ")[
          match(maddeler$Kimlik, as.character(audit$ID))], NA)
    tanilama$GENIE_kalan <- sum(maddeler$GENIE_karari == "Tutuldu")
    tanilama$GENIE_boyut <- paste(vapply(unique(maddeler_g$type), function(t)
      paste0(t, "=", if (is.null(sonuc$item_type_level[[t]]$final_EGA)) "?" else
        sonuc$item_type_level[[t]]$final_EGA$EGA$n.dim), ""), collapse = "; ")
    tanilama$GENIE_NMI_son <- paste(vapply(unique(maddeler_g$type), function(t) {
      n <- sonuc$item_type_level[[t]]$final_NMI
      paste0(t, "=", if (is.null(n)) "?" else round(n, 3))}, ""), collapse = "; ")
    .yaz(c(paste("Deney:", deney_adi), "", ozet,
           "NMI 1'e çok yakınsa maddeler alanlara göre kalıplaşmış olabilir; yapı kanıtı sayılmaz."),
         yol("genie_ozeti.txt"))
  }

  # 5. Çıktılar
  .csv_yaz(maddeler, yol("maddeler.csv"))
  .csv_yaz(tanilama, yol("tanilama.csv"))
  gruplar <- split(maddeler, paste(maddeler$Tur, maddeler$Alan, sep = " / "))
  .yaz(c(paste("Deney:", deney_adi, "| Madde sayısı:", nrow(maddeler)), "",
         unlist(lapply(names(gruplar), function(g) c(paste0("## ", g),
           paste0(gruplar[[g]]$Kimlik, ". ", gruplar[[g]]$Madde,
                  ifelse(is.na(gruplar[[g]]$GENIE_karari), "",
                         paste0("  [", gruplar[[g]]$GENIE_karari, "]"))), "")))),
       yol("maddeler.txt"))
  message(deney_adi, " tamamlandı: ", nrow(maddeler), " madde. Çıktılar: ", klasor)
  invisible(maddeler)
}
