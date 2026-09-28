# ---- H1. Paketler, ayarlar ve tanım fonksiyonları ------------------------------
# Çalıştırma: öğrenci paketinin klasöründe (berkcan_dass42), UTF-8 yerel ayarıyla, bütün bölümler sırayla.
# Önerilen ortam: R 4.5.3, lavaan 0.7-2, semTools 0.5-9, mirt 1.47, digest, jsonlite, ggplot2.
# Rastgelelik: örneklem seçimi tohum 20260905, bölme 260905, bootstrap 20260913 + tekrar no (cfg içinde).
kimlik <- "html"; out <- "html_ciktilari"; dir.create(out, showWarnings = FALSE)
if (!isTRUE(l10n_info()$`UTF-8`)) stop("UTF-8 yerel ayarı gerekli (ör. LANG=C.UTF-8).")
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
gerekli <- c("lavaan", "semTools", "mirt", "digest", "jsonlite", "ggplot2")
eksik <- gerekli[!vapply(gerekli, requireNamespace, logical(1), quietly = TRUE)]
if (length(eksik)) stop("Eksik paketler: ", paste(eksik, collapse = ", "))
beklenen_surum <- c(R = "4.5.3", lavaan = "0.7.2", semTools = "0.5.9", mirt = "1.47")
surum_notu <- c(R = paste(R.version$major, R.version$minor, sep = "."),
  vapply(names(beklenen_surum)[-1], function(p) as.character(utils::packageVersion(p)), character(1)))
sonuc <- list()        # hesaplanan ana değerler (sonuc_degerleri.csv)
kontroller <- list()   # iç denetimler (ic_denetimler.csv)

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
