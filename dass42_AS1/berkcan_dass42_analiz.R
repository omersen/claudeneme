# =============================================================================
# berkcan_dass42_analiz.R
# DASS-42 kısa form tezi: analiz betiği ŞABLONU (sürüm 2026-09-28)
#
# Kurallar
#   * TODO blokları dışındaki her satır SABİTTİR: değiştirilmez, silinmez, araya satır eklenmez.
#     Bölüm 14, sabit satırların SHA-256 özetini sabit_bolumler.sha256 ile karşılaştırır.
#   * Kod yalnız "# >>> TODO ... >>>" ile "# <<< TODO ... <<<" satırlarının arasına yazılır.
#     Bloktaki açıklama satırları silinmez; kod açıklamaların altına eklenir.
#   * Her blok sonuçlarını `sonuc` listesine belirtilen adlarla yazar. Bölüm 14 bu değerleri
#     referans_degerler.csv ile karşılaştırır. `sonuc`a elle sayı yazılmaz.
#   * Ayrıntılı tanımlar ve çalışma sırası: YONERGE.md
#
# Çalıştırma (proje kökünde, UTF-8 yerel ayarıyla):
#   Terminal: Rscript berkcan_dass42_analiz.R <calistirma_kimligi>
#   RStudio : projeyi açın ve "Source" düğmesine basın (kimlik saatten üretilir).
# Çıktılar: ciktilar/<calistirma_kimligi>/  (var olan klasörün üzerine yazılmaz)
# =============================================================================

# ---- Bölüm 0. Başlangıç (SABİT) ---------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
kimlik <- if (length(args)) args[1] else if (exists("calistirma_kimligi")) calistirma_kimligi else
  format(Sys.time(), "calisma_%Y%m%d_%H%M%S")
if (!grepl("^[A-Za-z0-9_-]+$", kimlik)) stop("Geçersiz çalıştırma kimliği: yalnız harf, rakam, _ ve -.")
if (!isTRUE(l10n_info()$`UTF-8`)) stop("UTF-8 yerel ayarı gerekli (ör. LANG=C.UTF-8).")
gerekli_dosyalar <- c("berkcan_dass42_analiz.R", "referans_degerler.csv", "sabit_bolumler.sha256")
if (!all(file.exists(gerekli_dosyalar)) || !dir.exists("girdiler"))
  stop("Proje kökünden çalıştırın (berkcan_dass42_analiz.R, referans_degerler.csv, sabit_bolumler.sha256 ve girdiler/ aynı klasörde olmalı).")
out <- file.path("ciktilar", kimlik)
if (dir.exists(out)) stop("Bu çıktı klasörü zaten var; yeni bir kimlik seçin: ", out)
dir.create(out, recursive = TRUE)
baslangic <- Sys.time()
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
gerekli <- c("lavaan", "semTools", "mirt", "digest", "jsonlite", "ggplot2")
eksik <- gerekli[!vapply(gerekli, requireNamespace, logical(1), quietly = TRUE)]
if (length(eksik)) stop("Eksik paketler: ", paste(eksik, collapse = ", "))
beklenen_surum <- c(R = "4.5.3", lavaan = "0.7.2", semTools = "0.5.9", mirt = "1.47")
surum_notu <- c(R = paste(R.version$major, R.version$minor, sep = "."),
  vapply(names(beklenen_surum)[-1], function(p) as.character(utils::packageVersion(p)), character(1)))
sonuc <- list()        # kabul denetimine giden değerler (ad = referans_degerler.csv$anahtar)
kontroller <- list()   # iç denetimler

# ---- Bölüm 1. Ayarlar (SABİT) ------------------------------------------------
cfg <- list(
  betik = "berkcan_dass42_analiz.R",
  girdi_klasoru = "girdiler",
  ham_veri_zip = "DASS_data_21.02.19.zip",
  ham_veri_sha256 = "38d1707cf1f9effec45c41f61c4fdc0ab245021da635a57a7f0e69edd965f3f5",
  vektor_dosyasi = "archived_embeddings.csv",
  vektor_sha256 = "fd7651177d49e63179df92bb349db4d8b0b96660e3369d05b28252f9bc3c1955",
  referans_bolme = "referans_sample_split.csv",
  tohum_orneklem = 20260905L, tohum_bolme = 260905L, tohum_bootstrap = 20260913L,
  n_hedef = 4000L, n_kalibrasyon = 2000L, n_degerlendirme = 2000L,
  yas_alt = 18L, yas_ust = 80L, anadil_ingilizce = 1L,
  beklenen_akis = c(39775L, 32495L, 10362L, 10362L),
  B = 2000L, tolerans = 1e-12, madde_sayisi_kisa = 7L,
  vcl_uydurma = c("VCL6", "VCL9", "VCL12"),
  q3_tarama_esigi = 0.20
)

# ---- Bölüm 2. Anahtarlar (SABİT) ----------------------------------------------
key42 <- list(
  D = c(3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42),
  A = c(2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41),
  S = c(1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39)
)
map21to42 <- c(22, 2, 3, 4, 42, 6, 41, 12, 40, 10, 39, 8, 26, 35, 28, 31, 17, 18, 25, 20, 38)
key21 <- lapply(key42, function(x) intersect(x, map21to42))
item_id <- function(x) sprintf("Q%02d", x)
alt_boyutlar <- c("D", "A", "S")
kisa_formlar <- c("PUB21", "MIN21", "MAX21", "COV21")
anlamsal_formlar <- c("MIN21", "MAX21", "COV21")
stopifnot(identical(as.integer(sort(unlist(key42))), 1:42), all(lengths(key42) == 14L),
          identical(key21$D, c(3, 10, 17, 26, 31, 38, 42)),
          identical(key21$A, c(2, 4, 20, 25, 28, 40, 41)),
          identical(key21$S, c(6, 8, 12, 18, 22, 35, 39)))
beklenen_formlar <- list(   # metinden üretilen formların beklenen üyelikleri (denetim için)
  MIN21 = list(D = c(5, 13, 17, 24, 26, 37, 42), A = c(2, 9, 19, 23, 25, 30, 40), S = c(6, 12, 14, 18, 22, 33, 35)),
  MAX21 = list(D = c(3, 10, 16, 21, 31, 34, 38), A = c(4, 7, 15, 20, 28, 36, 41), S = c(1, 8, 11, 27, 29, 32, 39)),
  COV21 = list(D = c(5, 10, 13, 17, 21, 31, 42), A = c(2, 4, 7, 19, 23, 36, 40), S = c(6, 8, 11, 12, 14, 18, 32))
)

# ---- Bölüm 3. Tanım fonksiyonları (SABİT) ---------------------------------------
log_yaz <- function(...) {
  m <- paste(format(Sys.time(), tz = "UTC", usetz = TRUE), paste(..., collapse = " "))
  cat(m, "\n"); cat(m, "\n", file = file.path(out, "analiz_gunlugu.txt"), append = TRUE)
}
uyarilari_kaydet <- function(expr) withCallingHandlers(expr, warning = function(w) {
  log_yaz("UYARI", conditionMessage(w)); invokeRestart("muffleWarning") })
csv_yaz <- function(x, ad) utils::write.csv(x, file.path(out, ad), row.names = FALSE, na = "", fileEncoding = "UTF-8")
kontrol <- function(ad, kosul, ayrinti = "") {
  gecti <- isTRUE(kosul)
  kontroller[[length(kontroller) + 1L]] <<- data.frame(kontrol = ad, gecti = gecti, ayrinti = ayrinti)
  csv_yaz(do.call(rbind, kontroller), "ic_denetimler.csv")
  if (!gecti) stop("DENETİM BAŞARISIZ: ", ad, " ", ayrinti, call. = FALSE)
  invisible(TRUE)
}
normalise_text <- function(x) {
  x <- gsub("&#39;|&apos;", "'", x); x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE); trimws(gsub("[[:space:]]+", " ", enc2utf8(x)))
}
cosine_matrix <- function(E) {
  nr <- sqrt(rowSums(E^2)); C <- tcrossprod(E / nr)
  C[C > 1] <- 1; C[C < -1] <- -1; diag(C) <- 1
  dimnames(C) <- list(rownames(E), rownames(E)); C
}
isi_values <- function(Cf) (rowSums(Cf) - diag(Cf)) / (nrow(Cf) - 1)
rank_with_tolerance <- function(values, decreasing = FALSE, tolerance = cfg$tolerans) {
  z <- if (decreasing) -values else values
  kalan <- names(z)[order(z, names(z))]; sonuc_sira <- character(0)
  while (length(kalan)) {
    grup <- kalan[z[kalan] <= z[kalan[1L]] + tolerance]
    sonuc_sira <- c(sonuc_sira, sort(grup)); kalan <- setdiff(kalan, grup)
  }
  sonuc_sira
}
sirali_ortalama <- function(x) sum(sort(x)) / length(x)   # aynı terimler her sırada bit düzeyinde aynı sonucu verir
anlamsal_olcu <- function(Cf, S) {   # SB, CL ve CL_b (tam 14 maddelik havuz üzerinden)
  w <- Cf[S, S, drop = FALSE]; R <- setdiff(rownames(Cf), S)
  c(SB = 1 - sirali_ortalama(w[upper.tri(w)]),
    CL = sirali_ortalama(1 - apply(Cf[, S, drop = FALSE], 1L, max)),
    CL_b = sirali_ortalama(c(1 - apply(Cf[R, S, drop = FALSE], 1L, max), 1 - apply(Cf[S, R, drop = FALSE], 1L, max))))
}
alt_kume_anlamsal <- function(Cf) {   # 3.432 yedili küme; anahtarlar sıralı madde kimlikleri
  pool <- sort(rownames(Cf))
  kombin <- utils::combn(pool, cfg$madde_sayisi_kisa)
  anahtar <- apply(kombin, 2, paste, collapse = "|")
  o <- order(anahtar); kombin <- kombin[, o, drop = FALSE]; anahtar <- anahtar[o]
  olc <- t(apply(kombin, 2, function(s) anlamsal_olcu(Cf, s)))
  tumleyen <- match(apply(kombin, 2, function(s) paste(setdiff(pool, s), collapse = "|")), anahtar)
  data.frame(subset_key = anahtar, SB = olc[, "SB"], CL = olc[, "CL"], CL_b = olc[, "CL_b"], tumleyen = tumleyen,
             kanonik_bolme = kombin[1, ] == pool[1], stringsAsFactors = FALSE)
}
alt_kume_psikometrik <- function(X, pool, anahtarlar) {   # alfa, yanlılık, s_d, RMSE, r
  # Tamsayı toplamlarıyla hesaplanır: matematiksel olarak eşit değerler bit düzeyinde eşit kalır (Spearman eşitlikleri).
  k <- cfg$madde_sayisi_kisa; kumeler <- strsplit(anahtarlar, "|", fixed = TRUE)
  Xf <- as.matrix(X[, pool, drop = FALSE]); n <- nrow(Xf)
  G <- vapply(kumeler, function(s) as.numeric(pool %in% s), numeric(length(pool)))
  Ss <- Xf %*% G; U <- rowSums(Xf); Dt <- 2 * Ss - U            # Dt / 14 = kısa ortalama - tam ortalama
  sD <- colSums(Dt); sD2 <- colSums(Dt^2); sS <- colSums(Ss); vS <- n * colSums(Ss^2) - sS^2
  vi <- n * colSums(Xf^2) - colSums(Xf)^2; sU <- sum(U); vU <- n * sum(U^2) - sU^2
  data.frame(subset_key = anahtarlar, alpha = k / (k - 1) * (1 - as.numeric(crossprod(G, vi)) / vS),
    bias = sD / (14 * n), sd_d = sqrt(n * sD2 - sD^2) / (14 * n), rmse = sqrt(sD2 / n) / 14,
    r = (n * colSums(Ss * U) - sS * sU) / sqrt(vS * vU), stringsAsFactors = FALSE)
}
midrank_percentile <- function(dagilim, deger, tolerance = cfg$tolerans)
  100 * (mean(dagilim < deger - tolerance) + 0.5 * mean(abs(dagilim - deger) <= tolerance))
alpha_raw <- function(X) {
  V <- stats::cov(as.matrix(X)); k <- ncol(V)
  k / (k - 1) * (1 - sum(diag(V)) / sum(V))
}
uyum_olculeri <- function(kisa, tam) {
  d <- kisa - tam
  c(r = stats::cor(kisa, tam), bias = mean(d), sd_d = sqrt(mean((d - mean(d))^2)), rmse = sqrt(mean(d^2)))
}
spearman <- function(x, y) stats::cor(x, y, method = "spearman")
cfa_syntax <- function(form) paste(vapply(names(form), function(f)
  paste(f, "=~", paste(form[[f]], collapse = " + ")), character(1)), collapse = "\n")
fit_cfa <- function(X, form) {
  ids <- unlist(form, use.names = FALSE)
  fit <- uyarilari_kaydet(lavaan::cfa(cfa_syntax(form), data = X[, ids, drop = FALSE], ordered = ids,
                                      estimator = "WLSMV", std.lv = TRUE))
  if (!isTRUE(lavaan::lavInspect(fit, "converged"))) stop("DFA yakınsamadı.")
  if (!isTRUE(uyarilari_kaydet(lavaan::lavInspect(fit, "post.check")))) stop("DFA kabul edilemez çözüm.")
  fit
}
dfa_uyum_olculeri <- c("chisq.scaled", "df.scaled", "pvalue.scaled", "cfi.scaled", "tli.scaled",
                       "rmsea.scaled", "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr")
omega_values <- function(fit, obs.var = FALSE) {
  z <- uyarilari_kaydet(semTools::compRelSEM(fit, tau.eq = FALSE, ord.scale = TRUE, obs.var = obs.var))
  if (is.list(z)) z <- vapply(z[c("D", "A", "S")], as.numeric, numeric(1))
  z[c("D", "A", "S")]
}
fit_grm <- function(X) {
  if (anyNA(X) || any(vapply(X, function(z) length(unique(z)), integer(1)) != 4L))
    stop("GRM: her maddede dört yanıt kategorisinin tamamı gözlenmeli.")
  mod <- uyarilari_kaydet(mirt::mirt(X, 1, itemtype = "graded", SE = FALSE, verbose = FALSE,
                                     technical = list(NCYCLES = 2000L), TOL = 1e-4))
  if (!isTRUE(mirt::extract.mirt(mod, "converged"))) stop("GRM yakınsamadı.")
  mod
}
grm_parameters <- function(mod) {
  z <- mirt::coef(mod, IRTpars = TRUE, simplify = TRUE)$items
  data.frame(item_id = rownames(z), a = as.numeric(z[, "a"]), z[, setdiff(colnames(z), "a"), drop = FALSE],
             row.names = NULL)
}
q3_duzeltilmis <- function(mod) {   # ortalaması çıkarılmış Q3 (üst üçgen ortalaması); yalnız üst üçgeni kullanın
  q <- uyarilari_kaydet(mirt::residuals(mod, type = "Q3", verbose = FALSE))
  q - mean(q[upper.tri(q)])
}
betik_satirlari <- function(dosya) {   # sabit satırlar ve TODO blok içleri
  s <- sub("[[:space:]]+$", "", readLines(dosya, encoding = "UTF-8", warn = FALSE))
  bas <- grep("^# >>> TODO", s); son <- grep("^# <<< TODO", s)
  if (length(bas) != length(son) || !length(bas) || any(son <= bas)) stop("TODO işaretleri bozulmuş.")
  ic <- logical(length(s))
  for (k in seq_along(bas)) if (son[k] > bas[k] + 1L) ic[(bas[k] + 1L):(son[k] - 1L)] <- TRUE
  list(satir = s, ic = ic, blok_sayisi = length(bas))
}
elle_desen <- paste0("sonuc[[:space:]]*(\\$[[:space:]]*[A-Za-z0-9_.]+|\\[\\[[^]]*\\]\\])[[:space:]]*(<-|=)",
                     "[[:space:]]*[-+]?[0-9][0-9.]*([eE][-+]?[0-9]+)?[[:space:]]*(;|#|$)")

# ---- Bölüm 4. Veri hazırlama (SABİT) ----------------------------------------------
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

# ---- Bölüm 5. Anlamsal temsil ve formlar (SABİT) ---------------------------------
vektor_yolu <- file.path(cfg$girdi_klasoru, cfg$vektor_dosyasi)
kontrol("vektor_sha256", identical(digest::digest(file = vektor_yolu, algo = "sha256"), cfg$vektor_sha256))
tab <- utils::read.csv(vektor_yolu, check.names = FALSE, stringsAsFactors = FALSE)
tab <- tab[match(maddeler$item_id, tab$item_id), , drop = FALSE]
E <- as.matrix(tab[, setdiff(names(tab), "item_id")]); rownames(E) <- tab$item_id
kontrol("vektor_boyutu", nrow(E) == 42L && ncol(E) == 3072L && all(is.finite(E)))
C <- cosine_matrix(E)
formlar <- list(FULL42 = lapply(key42, item_id), PUB21 = lapply(key21, item_id),
                MIN21 = list(), MAX21 = list(), COV21 = list())
ISI <- list(); alt_kume <- list()
for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]; Cf <- C[havuz, havuz]
  ISI[[f]] <- isi_values(Cf)
  formlar$MIN21[[f]] <- sort(rank_with_tolerance(ISI[[f]])[1:7])
  formlar$MAX21[[f]] <- sort(rank_with_tolerance(ISI[[f]], decreasing = TRUE)[1:7])
  alt_kume[[f]] <- alt_kume_anlamsal(Cf)
  esit <- which(abs(alt_kume[[f]]$CL - min(alt_kume[[f]]$CL)) <= cfg$tolerans)
  alt_kume[[f]]$cov_esit_minimum <- seq_len(nrow(alt_kume[[f]])) %in% esit
  formlar$COV21[[f]] <- strsplit(sort(alt_kume[[f]]$subset_key[esit])[1], "|", fixed = TRUE)[[1]]
  kontrol(paste0("alt_kume_sayisi_", f), nrow(alt_kume[[f]]) == choose(14, 7))
  kontrol(paste0("CL_b_tanimi_", f), max(abs(alt_kume[[f]]$CL_b - alt_kume[[f]]$CL - alt_kume[[f]]$CL[alt_kume[[f]]$tumleyen])) < 1e-12)
  for (nm in anlamsal_formlar) kontrol(paste0("form_uyeligi_", nm, "_", f),
    identical(formlar[[nm]][[f]], item_id(beklenen_formlar[[nm]][[f]])))
  sonuc[[paste0("COV_esit_cozum_", f)]] <- length(esit)
}
anahtar_yap <- function(ids) paste(sort(ids), collapse = "|")
csv_yaz(do.call(rbind, lapply(names(formlar), function(nm) do.call(rbind, lapply(alt_boyutlar, function(f)
  data.frame(form = nm, subscale = f, item_id = formlar[[nm]][[f]]))))), "formlar.csv")
csv_yaz(do.call(rbind, lapply(alt_boyutlar, function(f) data.frame(subscale = f, item_id = names(ISI[[f]]),
  ISI = as.numeric(ISI[[f]])))), "ISI.csv")
log_yaz("FORMLAR_HAZIR")

# =============================================================================
# Bölüm 6-13: TODO blokları. Tanımlar YONERGE.md'dedir; açıklamalara birebir uyun.
# Hazır nesneler: kal, deg (0-3 yanıtlar, 2.000'er satır), kal_ham, deg_ham (VCL sütunları için),
#   maddeler, C, ISI, formlar, alt_kume, key42, alt_boyutlar, kisa_formlar, anlamsal_formlar, cfg
#   ve Bölüm 3'teki fonksiyonlar. İstatistiksel hesaplar bu fonksiyonlarla yapılır; model yalnız fit_grm,
#   fit_cfa ve omega_values ile kurulur. Temel R işlevleri ile blokta adı geçen lavaan, mirt ve ggplot2
#   işlevleri serbesttir. Bloklar yardımcı nesne oluşturabilir ve önceki blokların sonuc değerlerini okuyabilir.
# Adlandırma: <form> = PUB21, MIN21, MAX21, COV21 (belirtilen yerde FULL42); <f> = D, A, S; <g> = kal, deg.
#   Tablolardaki grup sütunu da "kal" ve "deg" değerlerini alır.
# Satır sırası: form içeren tablolarda önce form (FULL42, PUB21, MIN21, MAX21, COV21), sonra alt boyut (D, A, S);
#   grup içeren tablolarda önce alt boyut, sonra grup (kal, deg).
# Bloklar arasında kullanılan nesneler: as1_parametreler, as2_guvenirlik, as3_uyum, tum_alt, yuzdelik.
# =============================================================================

# >>> TODO AS1 (Bölüm 6) >>>
# Amaç: AS1. ISI ile GRM ayırt ediciliği (a) arasındaki ilişki; kalibrasyon ana analiz, değerlendirme tekrar.
# Her f ve her grup g (kal, deg) için, havuz <- formlar$FULL42[[f]] ve Xg <- grup[, havuz]:
#  1. Kategori kullanımı: her maddede 0, 1, 2, 3 kategorilerinin frekansı.
#  2. mod <- fit_grm(Xg); p <- grm_parameters(mod); p satırlarını havuz sırasına getirin (kontrol() ile doğrulayın).
#  3. rho_ISI_a <- spearman(ISI[[f]][havuz], p$a). Madde düzeyinde güven aralığı hesaplanmaz: 14 madde sabittir ve
#     ISI değerleri aynı kosinüs matrisinden, a parametreleri aynı modelden geldiği için birbirinden bağımsız değildir.
#  4. CITC: her madde ile aynı alt boyuttaki diğer 13 maddenin toplam puanı arasındaki Pearson r (stats::cor).
#     rho_ISI_CITC <- spearman(ISI[[f]][havuz], CITC); ayrıca rho_a_CITC <- spearman(p$a, CITC).
#  5. Tanı: m2 <- mirt::M2(mod, type = "C2") uyarilari_kaydet ile; hata verirse değerler NA yazılır ve log_yaz ile
#     kaydedilir. Sütunlar: C2 (m2$M2; type = "C2" iken de mirt sütunu M2 adıyla verir), df, p, RMSEA, SRMSR.
#     q <- q3_duzeltilmis(mod); ust <- upper.tri(q): maks_Q3 = max(q[ust]); q3_esik_ustu_cift = sum(q[ust] > cfg$q3_tarama_esigi).
#  6. Kosinüs-Q3: rho_cos_Q3 <- spearman(C[havuz, havuz][ust], q[ust]) (91 çift). En yüksek üç Q3 çifti (büyükten küçüğe);
#     cift biçimi "Q05-Q42" (havuz sırasında önce gelen madde önce). birlikte_formlar: iki maddenin aynı alt boyutta
#     birlikte bulunduğu kısa formlar, kisa_formlar sırasında ve ", " ile ayrılmış; hiçbiri yoksa "yok".
# Çıktılar: tablo_AS1_kategori_kullanimi.csv (subscale, grup, item_id, kategori, n)
#           tablo_AS1_madde_parametreleri.csv (subscale, grup, item_id, ISI, a, b1, b2, b3, CITC)
#           tablo_AS1_ISI_a.csv (subscale, grup, n_madde, rho_ISI_a, rho_ISI_CITC, rho_a_CITC)
#           tablo_AS1_GRM_tani.csv (subscale, grup, C2, df, p, RMSEA, SRMSR, maks_Q3, q3_esik_ustu_cift)
#           tablo_AS1_kosinus_Q3.csv (subscale, grup, rho_cos_Q3, sira, cift, Q3, kosinus, birlikte_formlar)
# Nesne: as1_parametreler (tablo_AS1_madde_parametreleri ile aynı)
# sonuc: AS1_rho_kal_<f> ve AS1_rho_deg_<f> (rho_ISI_a); AS1_rhoCITC_kal_<f> (rho_ISI_CITC, kalibrasyon);
#        AS1_cosQ3_kal_<f> (rho_cos_Q3, kalibrasyon)
#
# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar tanımdır; aşağıdaki notlar yalnız kodu anlamayı kolaylaştırır)
#
# Araştırma sorusu 1 (AS1): DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer
#   maddelerle ortalama anlamsal benzerliği (ISI) ile GRM altında kestirilen ayırt edicilik
#   parametreleri (a) arasında nasıl bir ilişki vardır?
#
# Hangi veri hangi amaçla kullanılıyor?
#   ISI[[f]] : Yalnız madde METİNLERİNDEN gelir (gömme vektörlerinin kosinüs benzerliği). Bir maddenin
#              kendi alt boyutundaki diğer 13 maddeye anlamca ortalama ne kadar yakın olduğunu gösterir.
#              MIN21 (en düşük ISI) ve MAX21 (en yüksek ISI) formları bu değerlerle seçilmiştir.
#   kal, deg : Katılımcı YANITLARI (0-3). GRM ile her maddenin ayırt ediciliği (a) ve eşikleri (b1-b3)
#              kestirilir. kal (kalibrasyon, 2.000 kişi) ana analizdir; deg (değerlendirme, 2.000 kişi)
#              aynı analizin tekrarıdır ve ilişkinin iki bağımsız grupta aynı yönde olup olmadığını gösterir.
#   C        : 42 x 42 kosinüs matrisi. Madde ÇİFTLERİ düzeyinde anlamsal yakınlık (Adım 6).
#   Analiz birimi: her alt boyutta 14 sabit madde; her ilişki 14 nokta (Adım 6'da 91 çift) üzerindedir.
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS1 bölümü)
#   rho_ISI_a > 0 : anlamca alt boyutun ortak içeriğine yakın maddelerin a değeri daha yüksek olma
#                   eğilimindedir; rho_ISI_a < 0 ise tersi. |rho| < 0,30 zayıf, 0,30-0,50 orta,
#                   0,50 ve üstü güçlü diye adlandırılır (adlandırmadır, başarı eşiği değildir).
#   Tutarlılık    : kal, deg ve CITC (modelden bağımsız destek) aynı yönü gösterirse ilişki tutarlı sayılır.
#   Sınırlar      : 14 sabit maddeye ilişkin betimsel sonuçtur. Nedensellik (benzerlik ayırt ediciliği
#                   artırır) ve madde evrenine genelleme yapılmaz; güven aralığı ve p değeri verilmez.
#                   GRM uyumu zayıfsa a, "bu model altında kestirilen ayırt edicilik" diye adlandırılır.
#                   Kılmen ve Bulut (2025) ile yalnız yön düzeyinde karşılaştırılır (ölçek, örneklem ve
#                   gömme modeli farklıdır; ECR kaygı alt boyutunda r = -0,55 bildirmişlerdir).
# ---------------------------------------------------------------------------------------------
as1_gruplar <- list(kal = kal, deg = deg)   # kal: ana analiz; deg: tekrar
as1_kategori <- list(); as1_parametre_listesi <- list(); as1_iliski <- list(); as1_tani <- list(); as1_q3 <- list()

for (f in alt_boyutlar) {                   # D = depresyon, A = kaygı, S = stres
  havuz <- formlar$FULL42[[f]]              # bu alt boyutun 14 maddesi, sabit sırada
  isi_f <- ISI[[f]][havuz]                  # metinden gelen ISI değerleri (havuz sırasında)
  C_f <- C[havuz, havuz]                    # 14 x 14 kosinüs benzerlikleri
  kontrol(paste0("AS1_ISI_sirasi_", f), identical(names(isi_f), havuz))

  for (g in names(as1_gruplar)) {
    Xg <- as1_gruplar[[g]][, havuz, drop = FALSE]   # 2.000 kişi x 14 madde
    etiket <- paste0(f, "_", g)

    # Adım 1. Kategori kullanımı (0, 1, 2, 3).
    #   Amaç: GRM'nin her madde için üç eşik kestirebilmesi dört kategorinin de gözlenmesine bağlıdır.
    #   Yorum: çok seyrek kullanılan bir kategori (özellikle 3) o maddenin b3 eşiğini belirsizleştirir.
    as1_kategori[[etiket]] <- do.call(rbind, lapply(havuz, function(i)
      data.frame(subscale = f, grup = g, item_id = i, kategori = 0:3,
                 n = vapply(0:3, function(k) sum(Xg[[i]] == k), integer(1)))))
    kontrol(paste0("AS1_kategori_toplami_", etiket), all(tapply(as1_kategori[[etiket]]$n,
      as1_kategori[[etiket]]$item_id, sum) == nrow(Xg)))

    # Adım 2. Tek boyutlu GRM (Samejima'nın dereceli tepki modeli), yalnız bu alt boyutun 14 maddesiyle.
    #   Amaç: her maddenin ayırt ediciliği (a) ve eşikleri (b1-b3).
    #   Yorum: a büyüdükçe madde, gizil düzeyi farklı kişileri daha keskin ayırır; b'ler, bir üst
    #   kategoriye geçmenin gizil ölçekteki konumudur.
    mod <- fit_grm(Xg)
    p <- grm_parameters(mod)
    p <- p[match(havuz, p$item_id), , drop = FALSE]; rownames(p) <- NULL
    kontrol(paste0("AS1_parametre_sirasi_", etiket), identical(p$item_id, havuz))

    # Adım 4. CITC: madde puanı ile aynı alt boyuttaki diğer 13 maddenin toplamı arasındaki Pearson r.
    #   Amaç: GRM'ye bağlı olmayan, modelden bağımsız bir ayırt edicilik göstergesi (destekleyici kanıt).
    citc <- vapply(havuz, function(i)
      stats::cor(Xg[[i]], rowSums(Xg[, setdiff(havuz, i), drop = FALSE])), numeric(1))

    # Adım 3. AS1'in ana katsayısı: ISI ile a arasındaki Spearman sıra korelasyonu (14 madde).
    #   Spearman kullanılır: 14 noktada sıra ilişkisi, uç değerlere Pearson'dan daha az duyarlıdır.
    rho_ISI_a <- spearman(isi_f, p$a)
    rho_ISI_CITC <- spearman(isi_f, citc)   # ISI ile CITC: ana ilişkiyle aynı yönde mi?
    rho_a_CITC <- spearman(p$a, citc)       # a ile CITC: iki ayırt edicilik göstergesi birbirini tutuyor mu?

    as1_parametre_listesi[[etiket]] <- data.frame(subscale = f, grup = g, item_id = havuz, ISI = as.numeric(isi_f),
      a = p$a, b1 = p$b1, b2 = p$b2, b3 = p$b3, CITC = as.numeric(citc))
    as1_iliski[[etiket]] <- data.frame(subscale = f, grup = g, n_madde = length(havuz),
      rho_ISI_a = rho_ISI_a, rho_ISI_CITC = rho_ISI_CITC, rho_a_CITC = rho_a_CITC)

    # Adım 5. Model tanıları.
    #   C2 temelli uyum (C2, df, p, RMSEA, SRMSR): GRM'nin bu 14 maddeye ne kadar uyduğunu gösterir.
    #   Büyük örneklemde (n = 2.000) p neredeyse her zaman küçüktür; asıl RMSEA ve SRMSR'ye bakılır.
    #   Düzeltilmiş Q3: ortak faktör denetlendikten sonra iki madde arasında kalan ilişki (yerel bağımlılık).
    #   cfg$q3_tarama_esigi (0,20) bir tarama eşiğidir, karar kuralı değildir.
    m2 <- tryCatch(uyarilari_kaydet(mirt::M2(mod, type = "C2")), error = function(e) {
      log_yaz("UYARI", "AS1 M2 (C2) hesaplanamadi:", etiket, conditionMessage(e)); NULL })
    m2_deger <- function(s) if (is.null(m2) || !(s %in% names(m2))) NA_real_ else as.numeric(m2[[s]][1])
    q <- q3_duzeltilmis(mod)
    kontrol(paste0("AS1_Q3_sirasi_", etiket), identical(rownames(q), havuz) && identical(colnames(q), havuz))
    ust <- upper.tri(q)   # her madde çifti bir kez (91 çift)
    as1_tani[[etiket]] <- data.frame(subscale = f, grup = g, C2 = m2_deger("M2"), df = m2_deger("df"),
      p = m2_deger("p"), RMSEA = m2_deger("RMSEA"), SRMSR = m2_deger("SRMSR"),
      maks_Q3 = max(q[ust]), q3_esik_ustu_cift = sum(q[ust] > cfg$q3_tarama_esigi))

    # Adım 6. Kosinüs benzerliği ile düzeltilmiş Q3 arasındaki Spearman ilişkisi (91 çift).
    #   Yorum: pozitifse, anlamca daha yakın madde çiftlerinde ortak faktörün açıklamadığı ilişki daha
    #   yüksek olma eğilimindedir. 91 çift ortak maddeler içerdiği için bağımsız gözlem değildir; bu
    #   ilişki a'daki veya güvenirlikteki olası şişmenin miktarını göstermez.
    rho_cos_Q3 <- spearman(C_f[ust], q[ust])
    q_ust <- q[ust]; satir <- row(q)[ust]; sutun <- col(q)[ust]
    en_yuksek <- order(q_ust, decreasing = TRUE)[1:3]   # en yüksek üç düzeltilmiş Q3
    as1_q3[[etiket]] <- do.call(rbind, lapply(seq_along(en_yuksek), function(s) {
      k <- en_yuksek[s]; i <- havuz[satir[k]]; j <- havuz[sutun[k]]   # üst üçgen: i havuzda j'den önce gelir
      birlikte <- kisa_formlar[vapply(kisa_formlar, function(nm) all(c(i, j) %in% formlar[[nm]][[f]]), logical(1))]
      data.frame(subscale = f, grup = g, rho_cos_Q3 = rho_cos_Q3, sira = s, cift = paste0(i, "-", j),
                 Q3 = q_ust[k], kosinus = C_f[i, j],
                 birlikte_formlar = if (length(birlikte)) paste(birlikte, collapse = ", ") else "yok")
    }))

    # sonuc listesine yalnız hesaplanan nesneler atanır (kabul denetimi bu değerleri okur).
    sonuc[[paste0("AS1_rho_", g, "_", f)]] <- rho_ISI_a
    if (g == "kal") {
      sonuc[[paste0("AS1_rhoCITC_kal_", f)]] <- rho_ISI_CITC
      sonuc[[paste0("AS1_cosQ3_kal_", f)]] <- rho_cos_Q3
    }
  }
}

# Tablolar (satır sırası: alt boyut D, A, S; her alt boyutta önce kal, sonra deg).
as1_parametreler <- do.call(rbind, as1_parametre_listesi); rownames(as1_parametreler) <- NULL
csv_yaz(do.call(rbind, as1_kategori), "tablo_AS1_kategori_kullanimi.csv")
csv_yaz(as1_parametreler, "tablo_AS1_madde_parametreleri.csv")
csv_yaz(do.call(rbind, as1_iliski), "tablo_AS1_ISI_a.csv")
csv_yaz(do.call(rbind, as1_tani), "tablo_AS1_GRM_tani.csv")
csv_yaz(do.call(rbind, as1_q3), "tablo_AS1_kosinus_Q3.csv")
cat("\nAS1 özeti (ISI-a, ISI-CITC ve a-CITC Spearman katsayıları):\n")
print(do.call(rbind, as1_iliski), row.names = FALSE, digits = 3)
log_yaz("AS1_HAZIR")
# <<< TODO AS1 <<<

# >>> TODO AS2 (Bölüm 7) >>>
# Amaç: AS2. Faktör yapısı ve güvenirlik; değerlendirme grubu (deg).
# Her form (FULL42, PUB21, MIN21, MAX21, COV21) için:
#  1. fit <- fit_cfa(deg, formlar[[form]]).
#  2. Uyum: lavaan::fitMeasures(fit, dfa_uyum_olculeri); n_madde formun toplam madde sayısıdır (42 veya 21).
#  3. Yükler: lavaan::standardizedSolution(fit) içinde op == "=~" satırları (lhs, rhs, est.std, se, ci.lower, ci.upper).
#  4. Faktör korelasyonları: lavaan::lavInspect(fit, "cor.lv") içinden D-A, D-S, A-S (bu sırayla).
#  5. Her f için: omega = omega_values(fit, obs.var = FALSE)[f] (ana gösterge);
#     omega_obsvar_true = omega_values(fit, obs.var = TRUE)[f] (ek); alfa = alpha_raw(deg[, formlar[[form]][[f]]]).
#     tablo_AS2_guvenirlik FULL42 dahil beş formu içerir.
# Çıktılar: tablo_AS2_DFA_uyum.csv (form, n_madde ve dfa_uyum_olculeri'ndeki dokuz ölçü, aynı adlarla)
#           tablo_AS2_yukler.csv (form, faktor, item_id, yuk, se, alt, ust)
#           tablo_AS2_faktor_korelasyonlari.csv (form, cift, r)
#           tablo_AS2_guvenirlik.csv (form, subscale, omega, omega_obsvar_true, alfa)
# Nesne: as2_guvenirlik (tablo_AS2_guvenirlik ile aynı)
# sonuc: AS2_CFI_<form>, AS2_RMSEA_<form>, AS2_SRMR_<form> (FULL42 dahil beş form; cfi.scaled, rmsea.scaled, srmr)
#        AS2_omega_<form>_<f>, AS2_alfa_<form>_<f> (yalnız dört kısa form)
# <<< TODO AS2 <<<

# >>> TODO AS3 (Bölüm 8) >>>
# Amaç: AS3. Kısa form puanlarının DASS-42 alt boyut puanlarıyla uyumu; değerlendirme grubu.
#  1. Her kısa form ve f için: kisa <- rowMeans(deg[, formlar[[form]][[f]]]); tam <- rowMeans(deg[, formlar$FULL42[[f]]]).
#  2. u <- uyum_olculeri(kisa, tam) (r, bias = ortalama(kisa - tam), sd_d n paydalı, rmse); rmse_0_42 <- 14 * rmse.
#  3. Denetimler (kontrol()): her f için kişi düzeyinde d_MIN21 + d_MAX21 = 0 (en büyük |toplam| < 1e-12) ve
#     RMSE_MIN21 = RMSE_MAX21 (|fark| < 1e-12); her satırda rmse^2 = bias^2 + sd_d^2 (|fark| < 1e-12).
# Çıktı: tablo_AS3_uyum.csv (form, subscale, r, bias, sd_d, rmse, rmse_0_42)
# Nesne: as3_uyum (tablo_AS3_uyum ile aynı)
# sonuc: AS3_r_<form>_<f>, AS3_bias_<form>_<f>, AS3_rmse_<form>_<f>
# <<< TODO AS3 <<<

# >>> TODO ALT KÜME TABLOSU (Bölüm 9) >>>
# Amaç: alt küme testinin psikometrik tarafı; AS2-AS5 için ortak tablo. Bu blokta merge kullanılmaz.
#  1. Her f ve grup g (kal, deg) için ps <- alt_kume_psikometrik(grup, formlar$FULL42[[f]], alt_kume[[f]]$subset_key).
#     kontrol(): identical(ps$subset_key, alt_kume[[f]]$subset_key). Satır sırası alt_kume[[f]] ile aynı kalır.
#     alt_kume[[f]] sütunları (subset_key, SB, CL, CL_b, tumleyen, kanonik_bolme, cov_esit_minimum) ile ps'nin
#     alpha, bias, sd_d, rmse, r sütunları yan yana konur; başa subscale ve grup sütunları eklenir.
#  2. Denetimler: her f ve g için 3.432 satır; dört formun anahtarı (anahtar_yap) tabloda bulunur;
#     deg grubunda formun alpha ve rmse değeri as2_guvenirlik ve as3_uyum ile aynıdır (|fark| < 1e-10).
#  3. Dört kısa form ve f için deg grubunda orta sıra yüzdelikleri, dağılım o f ve deg'in 3.432 değeri:
#     alfa_yzd = midrank_percentile(alpha, formun alpha'sı); rmse_yzd, SB_yzd, CL_yzd aynı biçimde.
#     Formun alpha, rmse, SB, CL ve r değerleri tum_alt'taki kendi satırından alınır. r_medyan = median(r) (o f, deg).
#  4. Bütünleşik tablo: form, subscale, omega (as2_guvenirlik), alfa_yzd, rmse_yzd, SB_yzd, CL_yzd.
# Çıktılar: tum_alt_kumeler.csv (3 x 2 x 3.432 = 20.592 satır)
#           tablo_form_yuzdelikleri.csv (form, subscale, alfa, alfa_yzd, rmse, rmse_yzd, SB, SB_yzd, CL, CL_yzd, r, r_medyan)
#           tablo_butunlesik.csv
# Nesneler: tum_alt, yuzdelik (tablo_form_yuzdelikleri ile aynı)
# sonuc: AS2_alfa_yzd_<form>_<f>, AS3_rmse_yzd_<form>_<f>, AS3_r_medyan_<f>, AS4_SB_yzd_<form>_<f>, AS4_CL_yzd_<form>_<f>
# <<< TODO ALT KÜME TABLOSU <<<

# >>> TODO BOOTSTRAP (Bölüm 10) >>>
# Amaç: anlamsal formların alfa ve RMSE değerlerinin PUB21'den farkı için eşleştirilmiş katılımcı bootstrap'ı (AS2, AS3).
# n <- nrow(deg); for (b in seq_len(cfg$B)) { set.seed(cfg$tohum_bootstrap + b); ix <- sample.int(n, n, replace = TRUE); ... }
#   Her tekrarda AYNI ix bütün formlara ve tam puana uygulanır; modeller yeniden kestirilmez; döngüde başka
#   rastgele sayı çağrısı yapılmaz.
#   fark_alfa = alpha_raw(deg[ix, formlar[[form]][[f]]]) - alpha_raw(deg[ix, formlar$PUB21[[f]]])
#   fark_rmse = rmse(form) - rmse(PUB21); rmse = sqrt(mean((kisa - tam)^2)), kisa ve tam deg[ix, ] satırlarından.
#   form = MIN21, MAX21, COV21; f = D, A, S (18 fark). Nokta tahmini (tahmin) bootstrap ortalaması değildir;
#   aynı farkların bütün değerlendirme grubundaki (ix = 1:n) değeridir.
# Aralık: quantile(farklar, c(0.025, 0.975), type = 7, names = FALSE). Bütün tekrarlar sonlu olmalı (kontrol()).
# Çıktı: tablo_bootstrap_farklar.csv (olcu, subscale, form, tahmin, alt, ust, B); olcu değerleri "alfa" ve "rmse";
#   satır sırası olcu (alfa, rmse), form (MIN21, MAX21, COV21), alt boyut (D, A, S).
# sonuc: BOOT_alfa_<form>_<f>_alt, BOOT_alfa_<form>_<f>_ust, BOOT_rmse_<form>_<f>_alt, BOOT_rmse_<form>_<f>_ust
# <<< TODO BOOTSTRAP <<<

# >>> TODO AS4 (Bölüm 11) >>>
# Amaç: AS4. Anlamsal çeşitlilik ve temsil.
#  1. Dört form ve f için SB ve CL: alt_kume[[f]] içinde subset_key == anahtar_yap(formlar[[form]][[f]]) satırı.
#     (Yüzdelikler Bölüm 9'daki yuzdelik tablosundadır; SB ve CL yeniden hesaplanmaz.)
#  2. Her f için bütün kümelerde rho_SB_CL <- spearman(SB, CL) (3.432 küme).
#  3. Madde temsil tablosu: her form, f ve elenen madde i için (havuz sırasında) S <- formlar[[form]][[f]];
#     en yakın seçili madde j <- S[which.max(C[i, S])]; uzaklik <- 1 - C[i, j]; iki maddenin metni (maddeler$text);
#     her form ve f içinde en büyük uzaklığa eşit satırlarda en_zayif = TRUE.
#     Denetim: her form ve f için sum(uzaklik) / 14 = CL (|fark| < 1e-12).
# Çıktılar: tablo_AS4_anlamsal.csv (form, subscale, SB, CL), tablo_AS4_SB_CL.csv (subscale, rho_SB_CL)
#           tablo_AS4_madde_temsil.csv (form, subscale, elenen, elenen_metin, en_yakin, en_yakin_metin, uzaklik, en_zayif)
# sonuc: AS4_SB_<form>_<f>, AS4_CL_<form>_<f>, AS4_rho_SB_CL_<f>
# <<< TODO AS4 <<<

# >>> TODO AS5 (Bölüm 12) >>>
# Amaç: AS5 (alt küme testi). Bütün kümelerde anlamsal göstergelerle psikometrik göstergelerin ilişkisi.
# Her f ve grup g için tum_alt'ın o f ve g dilimi (3.432 satır, alt_kume[[f]] sırasında) üzerinden:
#   rho_SB_alfa  = spearman(SB, alpha)           bütün 3.432 küme
#   rho_CLb_rmse = spearman(CL_b, rmse)          kanonik_bolme == TRUE olan 1.716 bölünme (her bölünme bir kez;
#                                                bu katsayıyı değiştirmez, analiz birimini doğru raporlar)
#   rho_CLb_sd   = spearman(CL_b, sd_d)          aynı 1.716 bölünme
#   rho_CLb_bias = spearman(CL_b, abs(bias))     aynı 1.716 bölünme
# Denetimler: kanonik bölünme sayısı 1.716; her kümenin rmse değeri tümleyeninin rmse değerine eşit ve bias değeri
#   ters işaretli (|fark| < 1e-12). tumleyen, alt_kume[[f]] içindeki satır numarasıdır; yalnız aynı f ve g dilimi
#   içinde kullanılır (bütün tum_alt üzerinde değil).
# Çıktı: tablo_AS5_iliskiler.csv (subscale, grup, n_kume, n_bolunme, rho_SB_alfa, rho_CLb_rmse, rho_CLb_sd, rho_CLb_bias)
# sonuc: AS5_rho_SB_alfa_<g>_<f>, AS5_rho_CLb_rmse_<g>_<f>, AS5_rho_CLb_sd_deg_<f>, AS5_rho_CLb_bias_deg_<f>
# <<< TODO AS5 <<<

# >>> TODO EK ANALİZLER (Bölüm 13) >>>
# 1. COV21 eşit çözümleri: her f için tum_alt içinde grup == "deg" ve cov_esit_minimum == TRUE olan kümeler;
#    küme sayısı, alfa ve rmse değerlerinin en küçüğü ve en büyüğü, COV21'in kendi satırındaki alfa ve rmse.
#    Çıktı: ek_COV21_esit_cozumler.csv (subscale, n_kume, alfa_min, alfa_max, rmse_min, rmse_max, COV21_alfa, COV21_rmse)
#    sonuc: EK_COV_alfa_min_<f>, EK_COV_alfa_max_<f>, EK_COV_rmse_min_<f>, EK_COV_rmse_max_<f>
# 2. Yanıt kalitesi (VCL): kal_ham ve deg_ham içinde cfg$vcl_uydurma sütunlarından en az birinde değeri 1 olan
#    kayıtlar dışlanır (satır sırası kal ve deg ile aynıdır). Eksik değer tek başına dışlama nedeni değildir;
#    n_eksik_vcl, bu üç sütundan en az birinde eksik değeri olan kayıt sayısıdır. Dışlanmış verilerle:
#    (a) AS1: kalibrasyonda her f için fit_grm yeniden; spearman(ISI, a).
#    (b) AS2: değerlendirmede dört kısa form için fit_cfa yeniden; cfi.scaled, rmsea.scaled, srmr;
#        her f için omega (obs.var = FALSE) ve alfa.
#    (c) AS3: değerlendirmede dört kısa form ve f için bias ve rmse.
#    (d) AS5: değerlendirmede aynı sabit kümeler için ps <- alt_kume_psikometrik(dışlanmış deg, formlar$FULL42[[f]],
#        alt_kume[[f]]$subset_key); rho_SB_alfa = spearman(SB, alpha) (3.432 küme); rho_CLb_rmse = spearman(CL_b, rmse)
#        yalnız kanonik_bolme == TRUE olan 1.716 bölünmede. Yeni soru veya yöntem eklenmez.
#    Ana değerler sonuc listesinden okunur (ör. sonuc[[paste0("AS2_CFI_", form)]]); ana nesneler değiştirilmez.
#    ek_VCL_duyarlilik.csv 69 satırdır: AS1 3 (form = "FULL42"), uyum 12 (subscale = NA), omega ve alfa 24, bias ve rmse 24,
#    AS5 6 (form = NA). olcu değerleri: rho_ISI_a, cfi.scaled, rmsea.scaled, srmr, omega, alfa, bias, rmse, rho_SB_alfa,
#    rho_CLb_rmse; fark = deger - ana_deger.
#    Çıktılar: ek_VCL_orneklem.csv (grup, n_ana, n_dislanan, n_kalan, n_eksik_vcl)
#              ek_VCL_duyarlilik.csv (soru, form, subscale, olcu, deger, ana_deger, fark)
#    sonuc: EK_VCL_dislanan_kal, EK_VCL_dislanan_deg, EK_VCL_rho_kal_<f>, EK_VCL_CFI_<form>,
#           EK_VCL_omega_<form>_<f>, EK_VCL_rmse_<form>_<f>, EK_VCL_AS5_SB_alfa_<f>, EK_VCL_AS5_CLb_rmse_<f>
#           (dışlanmış veriyle elde edilen değerler, fark değil; bias yalnız tabloya yazılır)
# (Omega için obs.var = TRUE ek analizi AS2 bloğunda üretilir.)
# <<< TODO EK ANALİZLER <<<

# >>> TODO ŞEKİLLER (Bölüm 13b) >>>
# ggplot2 ile, beyaz zeminli 300 dpi PNG; yeni paket kullanılmaz.
# sekil_AS1_ISI_a.png (9 x 3,6 inç): üç panel (D, A, S); x = ISI, y = kalibrasyon grubundaki a (as1_parametreler);
#   noktalar madde kimlikleriyle etiketli; panel başlığında rho.
# sekil_AS5_alt_kume_testi.png (10 x 6,8 inç): iki satır, üç sütun (D, A, S), değerlendirme grubu (tum_alt).
#   Üst satır: x = SB, y = alfa (3.432 küme). Alt satır: x = CL_b, y = RMSE (1.716 kanonik bölünme).
#   Eksenler satıra göre değiştiği için veriler uzun biçime getirilir ve ggplot2::facet_wrap(~panel, nrow = 2,
#   scales = "free") kullanılır. Gri noktalar bütün kümeler; dört form ayrı şekil ve renkle (formun kendi satırındaki
#   değerlerle); panel başlığında rho. Şeklin alt yazısı (caption), MIN21 ile MAX21'in aynı bölünme olduğunu ve
#   alt satırda üst üste düştüğünü belirtir.
# <<< TODO ŞEKİLLER <<<

# ---- Bölüm 14. Kabul ve bütünlük denetimi (SABİT) ----------------------------------------
beklenen_ciktilar <- list(   # dosya = list(satır sayısı, sütunlar); şekiller için NULL
  tablo_AS1_kategori_kullanimi.csv = list(336, c("subscale", "grup", "item_id", "kategori", "n")),
  tablo_AS1_madde_parametreleri.csv = list(84, c("subscale", "grup", "item_id", "ISI", "a", "b1", "b2", "b3", "CITC")),
  tablo_AS1_ISI_a.csv = list(6, c("subscale", "grup", "n_madde", "rho_ISI_a", "rho_ISI_CITC", "rho_a_CITC")),
  tablo_AS1_GRM_tani.csv = list(6, c("subscale", "grup", "C2", "df", "p", "RMSEA", "SRMSR", "maks_Q3", "q3_esik_ustu_cift")),
  tablo_AS1_kosinus_Q3.csv = list(18, c("subscale", "grup", "rho_cos_Q3", "sira", "cift", "Q3", "kosinus", "birlikte_formlar")),
  tablo_AS2_DFA_uyum.csv = list(5, c("form", "n_madde", dfa_uyum_olculeri)),
  tablo_AS2_yukler.csv = list(126, c("form", "faktor", "item_id", "yuk", "se", "alt", "ust")),
  tablo_AS2_faktor_korelasyonlari.csv = list(15, c("form", "cift", "r")),
  tablo_AS2_guvenirlik.csv = list(15, c("form", "subscale", "omega", "omega_obsvar_true", "alfa")),
  tablo_AS3_uyum.csv = list(12, c("form", "subscale", "r", "bias", "sd_d", "rmse", "rmse_0_42")),
  tum_alt_kumeler.csv = list(20592, c("subscale", "grup", "subset_key", "SB", "CL", "CL_b", "tumleyen", "kanonik_bolme",
                                      "cov_esit_minimum", "alpha", "bias", "sd_d", "rmse", "r")),
  tablo_form_yuzdelikleri.csv = list(12, c("form", "subscale", "alfa", "alfa_yzd", "rmse", "rmse_yzd", "SB", "SB_yzd",
                                           "CL", "CL_yzd", "r", "r_medyan")),
  tablo_butunlesik.csv = list(12, c("form", "subscale", "omega", "alfa_yzd", "rmse_yzd", "SB_yzd", "CL_yzd")),
  tablo_bootstrap_farklar.csv = list(18, c("olcu", "subscale", "form", "tahmin", "alt", "ust", "B")),
  tablo_AS4_anlamsal.csv = list(12, c("form", "subscale", "SB", "CL")),
  tablo_AS4_SB_CL.csv = list(3, c("subscale", "rho_SB_CL")),
  tablo_AS4_madde_temsil.csv = list(84, c("form", "subscale", "elenen", "elenen_metin", "en_yakin", "en_yakin_metin",
                                          "uzaklik", "en_zayif")),
  tablo_AS5_iliskiler.csv = list(6, c("subscale", "grup", "n_kume", "n_bolunme", "rho_SB_alfa", "rho_CLb_rmse",
                                      "rho_CLb_sd", "rho_CLb_bias")),
  ek_COV21_esit_cozumler.csv = list(3, c("subscale", "n_kume", "alfa_min", "alfa_max", "rmse_min", "rmse_max",
                                         "COV21_alfa", "COV21_rmse")),
  ek_VCL_orneklem.csv = list(2, c("grup", "n_ana", "n_dislanan", "n_kalan", "n_eksik_vcl")),
  ek_VCL_duyarlilik.csv = list(69, c("soru", "form", "subscale", "olcu", "deger", "ana_deger", "fark")),
  sekil_AS1_ISI_a.png = NULL, sekil_AS5_alt_kume_testi.png = NULL)
cikti_denetimi <- do.call(rbind, lapply(names(beklenen_ciktilar), function(d) {
  yol <- file.path(out, d); var <- file.exists(yol) && isTRUE(file.info(yol)$size > 0); b <- beklenen_ciktilar[[d]]
  if (!var || is.null(b)) return(data.frame(dosya = d, var = var, sutunlar_dogru = var, satir_sayisi_dogru = var))
  x <- utils::read.csv(yol, check.names = FALSE, stringsAsFactors = FALSE)
  data.frame(dosya = d, var = TRUE, sutunlar_dogru = identical(names(x), b[[2]]), satir_sayisi_dogru = nrow(x) == b[[1]])
}))
csv_yaz(cikti_denetimi, "cikti_denetimi.csv")
bt <- betik_satirlari(cfg$betik)
sabit_ozet <- digest::digest(paste(bt$satir[!bt$ic & nzchar(bt$satir)], collapse = "\n"), algo = "sha256", serialize = FALSE)
beklenen_ozet <- trimws(readLines("sabit_bolumler.sha256", warn = FALSE)[1])
elle <- grep(elle_desen, bt$satir[bt$ic & !grepl("^[[:space:]]*#", bt$satir)], value = TRUE)
if (length(elle)) log_yaz("ELLE_SAYI_ATAMASI", paste(elle, collapse = " || "))
ref <- utils::read.csv("referans_degerler.csv", stringsAsFactors = FALSE)
kabul <- do.call(rbind, lapply(seq_len(nrow(ref)), function(i) {
  deger <- sonuc[[ref$anahtar[i]]]
  var_mi <- !is.null(deger) && length(deger) == 1L && is.finite(suppressWarnings(as.numeric(deger)))
  fark <- if (var_mi) abs(as.numeric(deger) - ref$deger[i]) else NA_real_
  gecti <- var_mi && fark <= ref$tolerans[i]
  data.frame(anahtar = ref$anahtar[i], referans = if (var_mi) ref$deger[i] else NA_real_,
             bulunan = if (var_mi) as.numeric(deger) else NA_real_, fark = fark, tolerans = ref$tolerans[i], gecti = gecti,
             durum = if (!var_mi) "eksik" else if (gecti) "gecti" else "farkli")
}))
butunluk <- c(BUTUNLUK_sabit_bolumler = identical(sabit_ozet, beklenen_ozet),
              BUTUNLUK_elle_sayi_yok = !length(elle), BUTUNLUK_todo_blok_sayisi = bt$blok_sayisi == 9L,
              BUTUNLUK_cikti_dosyalari = all(as.matrix(cikti_denetimi[, -1])))
kabul <- rbind(data.frame(anahtar = names(butunluk), referans = 1, bulunan = as.numeric(butunluk), fark = as.numeric(!butunluk),
                          tolerans = 0, gecti = unname(butunluk), durum = ifelse(butunluk, "gecti", "farkli")), kabul)
if (!butunluk[["BUTUNLUK_cikti_dosyalari"]]) log_yaz("EKSIK_VEYA_HATALI_CIKTILAR",
  paste(cikti_denetimi$dosya[!apply(as.matrix(cikti_denetimi[, -1]), 1, all)], collapse = ", "))
fazla <- setdiff(names(sonuc), ref$anahtar)
if (length(fazla)) log_yaz("REFERANSTA_OLMAYAN_ANAHTARLAR", paste(fazla, collapse = ", "))
csv_yaz(data.frame(anahtar = names(sonuc), deger = vapply(sonuc, function(v)
  if (length(v) == 1L && is.numeric(v)) as.numeric(v) else NA_real_, numeric(1)), row.names = NULL), "sonuc_degerleri.csv")
csv_yaz(kabul, "kabul_raporu.csv")
print(table(bolum = sub("_.*$", "", kabul$anahtar), durum = kabul$durum))
log_yaz("KABUL", sum(kabul$gecti), "/", nrow(kabul), "| eksik:", sum(kabul$durum == "eksik"),
        "| farkli:", sum(kabul$durum == "farkli"))

# ---- Bölüm 15. Kapanış (SABİT) --------------------------------------------------------
kaynaklar <- c(cfg$betik, "referans_degerler.csv", "sabit_bolumler.sha256", zip_yolu, vektor_yolu,
               file.path(cfg$girdi_klasoru, cfg$referans_bolme))
csv_yaz(data.frame(dosya = kaynaklar, sha256 = vapply(kaynaklar, function(d) digest::digest(file = d, algo = "sha256"),
                                                      character(1)), row.names = NULL), "dosya_ozetleri.csv")
writeLines(capture.output(sessionInfo()), file.path(out, "oturum_bilgisi.txt"))
durum <- list(kimlik = kimlik, baslangic = format(baslangic, tz = "UTC", usetz = TRUE),
              bitis = format(Sys.time(), tz = "UTC", usetz = TRUE), surumler = as.list(surum_notu),
              beklenen_surumler = as.list(beklenen_surum), sabit_bolumler_ozeti = sabit_ozet,
              ic_denetim = length(kontroller), kabul_gecen = sum(kabul$gecti), kabul_eksik = sum(kabul$durum == "eksik"),
              kabul_farkli = sum(kabul$durum == "farkli"), kabul_toplam = nrow(kabul),
              durum = if (all(kabul$gecti)) "KABUL" else "RED")
jsonlite::write_json(durum, file.path(out, "calistirma_durumu.json"), pretty = TRUE, auto_unbox = TRUE)
if (!all(kabul$gecti)) {
  print(utils::head(kabul[!kabul$gecti, ], 40), row.names = FALSE)
  stop("Kabul denetimi geçmedi: ", sum(kabul$durum == "eksik"), " eksik, ", sum(kabul$durum == "farkli"),
       " farklı değer. Ayrıntı: ", file.path(out, "kabul_raporu.csv"), call. = FALSE)
}
cat("KABUL:", kimlik, "\n")
