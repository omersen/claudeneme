# ---- 3.2 Veri, örneklem ve gruplar ------------------------------------------------
zip_yolu <- "girdiler/DASS_data_21.02.19.zip"
stopifnot(identical(digest::digest(file = zip_yolu, algo = "sha256"),                  # ham veri değişmemiş olmalı
                    "38d1707cf1f9effec45c41f61c4fdc0ab245021da635a57a7f0e69edd965f3f5"))
uyeler <- unzip(zip_yolu, list = TRUE)$Name
ham <- read.delim(unz(zip_yolu, uyeler[grepl("(^|/)data[.]csv$", uyeler)]), sep = "\t", quote = "",
                  check.names = FALSE, stringsAsFactors = FALSE, na.strings = c("", "NA"))
kitap <- readLines(unz(zip_yolu, uyeler[grepl("(^|/)codebook[.]txt$", uyeler)]), warn = FALSE, encoding = "UTF-8")
madde_satiri <- kitap[grepl("^Q[0-9]+\t", kitap)]
metin_duzelt <- function(x) {
  x <- gsub("&#39;|&apos;", "'", x); x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE); trimws(gsub("[[:space:]]+", " ", enc2utf8(x)))
}
maddeler <- data.frame(item_id = item_id(as.integer(sub("^Q([0-9]+)\t.*$", "\\1", madde_satiri))),
                       text = metin_duzelt(sub("^Q[0-9]+\t", "", madde_satiri)))
maddeler <- maddeler[order(maddeler$item_id), ]

Y <- as.data.frame(lapply(ham[, paste0("Q", 1:42, "A")], function(x) suppressWarnings(as.numeric(x))))
names(Y) <- item_id(1:42)
yas <- suppressWarnings(as.numeric(ham$age)); dil <- suppressWarnings(as.numeric(ham$engnat))
cinsiyet <- suppressWarnings(as.numeric(ham$gender))
uygun <- which(!is.na(yas) & yas >= 18 & yas <= 80 &                         # 18-80 yaş
               !is.na(dil) & dil == 1 &                                        # ana dili İngilizce
               apply(as.matrix(Y), 1, function(x) all(!is.na(x) & x %in% 1:4)))   # 42 madde eksiksiz
set.seed(20260905); secilen <- sort(sample(uygun, 4000))                     # 4.000 kayıt
set.seed(260905);   kal_sira <- sort(sample(seq_along(secilen), 2000))        # 2.000 + 2.000 bölme
deg_sira <- setdiff(seq_along(secilen), kal_sira)
bolme <- data.frame(source_row = secilen,
                    split = ifelse(seq_along(secilen) %in% kal_sira, "calibration", "validation"))
stopifnot(identical(bolme, read.csv("girdiler/referans_sample_split.csv", stringsAsFactors = FALSE)))

X <- Y[secilen, ] - 1; rownames(X) <- NULL                                    # yanıtlar 0-3
kal <- X[kal_sira, ]; deg <- X[deg_sira, ]                                    # kalibrasyon ve değerlendirme grupları

yas_uygun <- !is.na(yas) & yas >= 18 & yas <= 80
akis <- data.frame(asama = c("Ham kayıt", "18-80 yaş", "Ana dili İngilizce", "42 madde eksiksiz ve geçerli",
                             "Seçilen örneklem", "Kalibrasyon grubu", "Değerlendirme grubu"),
                   n = c(nrow(ham), sum(yas_uygun), sum(yas_uygun & !is.na(dil) & dil == 1), length(uygun),
                         length(secilen), nrow(kal), nrow(deg)))
betim <- do.call(rbind, lapply(list(toplam = seq_along(secilen), kalibrasyon = kal_sira, degerlendirme = deg_sira),
  function(s) { i <- secilen[s]; g <- cinsiyet[i]                                # 1 erkek, 2 kadın, 3 diğer
    data.frame(n = length(i), yas_ort = mean(yas[i]), yas_ss = sd(yas[i]), kadin_yzd = 100 * mean(g %in% 2),
               erkek_yzd = 100 * mean(g %in% 1), diger_yzd = 100 * mean(g %in% 3), yanitsiz_yzd = 100 * mean(!(g %in% 1:3))) }))
betim <- cbind(grup = rownames(betim), betim); rownames(betim) <- NULL
print(akis); print(betim, digits = 3)
write.csv(akis, "html_ciktilari/orneklem_akisi.csv", row.names = FALSE)
write.csv(betim, "html_ciktilari/orneklem_betimleme.csv", row.names = FALSE)
