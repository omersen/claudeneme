log_yaz("BASLANGIC", kimlik)
log_yaz("SURUMLER", paste(names(surum_notu), surum_notu, collapse = "; "),
        if (identical(unname(surum_notu), unname(beklenen_surum))) "(beklenenle aynı)" else
          "(BEKLENENDEN FARKLI: model tabanlı değerlerde küçük farklar olabilir)")
zip_yolu <- file.path(cfg$girdi_klasoru, cfg$ham_veri_zip)
kontrol("ham_veri_sha256", identical(digest::digest(file = zip_yolu, algo = "sha256"), cfg$ham_veri_sha256))
uyeler <- unzip(zip_yolu, list = TRUE)$Name
veri_adi <- uyeler[grepl("(^|/)data[.]csv$", uyeler)]
kitap_adi <- uyeler[grepl("(^|/)codebook[.]txt$", uyeler)]
kitap <- readLines(unz(zip_yolu, kitap_adi), warn = FALSE, encoding = "UTF-8")
madde_satirlari <- kitap[grepl("^Q[0-9]+\t", kitap)]
numaralar <- as.integer(sub("^Q([0-9]+)\t.*$", "\\1", madde_satirlari))
metinler <- normalise_text(sub("^Q[0-9]+\t", "", madde_satirlari))
o <- order(numaralar); numaralar <- numaralar[o]; metinler <- metinler[o]
kontrol("kod_kitabi_42_madde", identical(numaralar, 1:42))
maddeler <- data.frame(item_id = item_id(numaralar), dass42 = numaralar,
  subscale = vapply(numaralar, function(i) names(key42)[vapply(key42, function(k) i %in% k, logical(1))], character(1)),
  dass21 = match(numaralar, map21to42), text = metinler, stringsAsFactors = FALSE)
ham <- read.delim(unz(zip_yolu, veri_adi), sep = "\t", quote = "", check.names = FALSE,
                  stringsAsFactors = FALSE, na.strings = c("", "NA"))
Y <- as.data.frame(lapply(ham[, paste0("Q", 1:42, "A")], function(x) suppressWarnings(as.numeric(x))))
names(Y) <- item_id(1:42)
yas <- suppressWarnings(as.numeric(ham$age)); dil <- suppressWarnings(as.numeric(ham$engnat))
cinsiyet <- suppressWarnings(as.numeric(ham$gender))
yas_ok <- !is.na(yas) & yas >= cfg$yas_alt & yas <= cfg$yas_ust
dil_ok <- !is.na(dil) & dil == cfg$anadil_ingilizce
gecerli <- apply(as.matrix(Y), 1, function(x) all(!is.na(x) & x %in% 1:4))
uygun <- which(yas_ok & dil_ok & gecerli)
akis <- c(nrow(ham), sum(yas_ok), sum(yas_ok & dil_ok), length(uygun))
csv_yaz(data.frame(asama = c("ham", "yas_18_80", "anadil_ingilizce", "eksiksiz_gecerli"), n = akis), "orneklem_akisi.csv")
kontrol("orneklem_akisi", identical(as.integer(akis), cfg$beklenen_akis))
set.seed(cfg$tohum_orneklem); secilen <- sort(sample(uygun, cfg$n_hedef))
set.seed(cfg$tohum_bolme); kal_sira <- sort(sample(seq_along(secilen), cfg$n_kalibrasyon))
deg_sira <- setdiff(seq_along(secilen), kal_sira)
X <- Y[secilen, , drop = FALSE] - 1; rownames(X) <- NULL
bolme <- data.frame(source_row = secilen, split = ifelse(seq_along(secilen) %in% kal_sira, "calibration", "validation"))
referans_bolme <- utils::read.csv(file.path(cfg$girdi_klasoru, cfg$referans_bolme), stringsAsFactors = FALSE)
kontrol("bolme_referansla_ayni", identical(bolme, referans_bolme))
kal <- X[kal_sira, , drop = FALSE]; deg <- X[deg_sira, , drop = FALSE]   # kalibrasyon / değerlendirme
kal_ham <- ham[secilen[kal_sira], , drop = FALSE]; deg_ham <- ham[secilen[deg_sira], , drop = FALSE]
kontrol("gruplar_2000_2000", nrow(kal) == cfg$n_kalibrasyon && nrow(deg) == cfg$n_degerlendirme && all(as.matrix(X) %in% 0:3))
betimle <- function(sat, ad) data.frame(grup = ad, n = length(sat), yas_ort = mean(yas[sat]), yas_ss = stats::sd(yas[sat]),
  kadin_yzd = 100 * mean(cinsiyet[sat] %in% 2), erkek_yzd = 100 * mean(cinsiyet[sat] %in% 1),
  diger_yzd = 100 * mean(cinsiyet[sat] %in% 3), yanitsiz_yzd = 100 * mean(!(cinsiyet[sat] %in% 1:3)))
csv_yaz(rbind(betimle(secilen, "toplam"), betimle(secilen[kal_sira], "kalibrasyon"),
              betimle(secilen[deg_sira], "degerlendirme")), "orneklem_betimleme.csv")
csv_yaz(bolme, "orneklem_bolmesi.csv"); csv_yaz(maddeler, "madde_sozlugu.csv")
sonuc$n_ham <- akis[1]; sonuc$n_uygun <- akis[4]
log_yaz("VERI_HAZIR", nrow(kal), nrow(deg))
