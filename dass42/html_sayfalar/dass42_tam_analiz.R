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

# ---- H3. Gömme modelinin seçimi ------------------------------------------------------------
# Amaç: madde metinlerini vektöre çeviren modeli, AS1-AS5 sonuçlarına bakmadan ve analizde kullanılan
#   4.000 kişiye dokunmadan seçmek. Ölçüt önceden belirlenmiştir:
#   ANA ÖLÇÜT: alt boyut içindeki madde çiftlerinde kosinüs benzerliği ile polikorik korelasyon arasındaki
#   Spearman ilişkisi. Çalışmadaki bütün anlamsal göstergeler (ISI, SB, CL) alt boyut içi benzerliklere
#   dayandığı için modelin tam da bu düzeyde yanıt verisindeki ilişkileri ne kadar izlediğine bakılır.
#   Veri: uygun havuzdaki, analize GİRMEYEN kayıtlar (10.362 - 4.000 = 6.362 kişi). Böylece model seçimi
#   kalibrasyon ve değerlendirme gruplarını etkilemez.
#   YAN ÖLÇÜTLER: bütün 861 çiftte aynı ilişki ve Top-3 doğruluğu (Ravenda vd., 2025 ile karşılaştırılabilir);
#   yanıt verisi kullanmayan alt boyut ayrışması (alt boyut içi eksi alt boyutlar arası ortalama kosinüs,
#   birini-dışarıda-bırak en yakın merkez doğruluğu).
# Girdiler: girdiler/modeller/emb_<model>.csv (42 madde x boyut). text-embedding-3-large vektörleri Ravenda vd.
#   (2025) yayın arşivindendir (OpenAI API'si yeniden çağrılmamıştır); açık modellerin vektörleri aynı madde
#   metinlerinden ONNX sürümleriyle yerel olarak üretilmiştir (üretim betiği: girdiler/modeller/uret.py).
secim_kayitlari <- setdiff(uygun, secilen)                       # analize girmeyen kayıtlar
kontrol("model_secim_grubu_ayrik", !length(intersect(secim_kayitlari, secilen)) && length(secim_kayitlari) == 6362L)
Xsec <- Y[secim_kayitlari, ] - 1
P_sec <- lavaan::lavCor(Xsec, ordered = names(Xsec))             # 42 x 42 polikorik korelasyon
alt_etiket <- setNames(rep(names(key42), lengths(key42)), item_id(unlist(key42)))[item_id(1:42)]
ust <- upper.tri(P_sec); ayni_alt <- outer(alt_etiket, alt_etiket, "==")
model_dosyalari <- list.files(file.path(cfg$girdi_klasoru, "modeller"), "^emb_.*[.]csv$", full.names = TRUE)
model_tablosu <- do.call(rbind, lapply(model_dosyalari, function(dosya) {
  tb <- utils::read.csv(dosya, check.names = FALSE); tb <- tb[match(item_id(1:42), tb$item_id), ]
  Em <- as.matrix(tb[, -1]); rownames(Em) <- tb$item_id
  Cm <- cosine_matrix(Em)
  ic <- ust & ayni_alt; dis <- ust & !ayni_alt
  rho_f <- vapply(alt_boyutlar, function(f) { h <- item_id(key42[[f]]); u <- upper.tri(Cm[h, h])
    spearman(Cm[h, h][u], P_sec[h, h][u]) }, numeric(1))
  data.frame(model = sub("^emb_(.*)[.]csv$", "\\1", basename(dosya)), boyut = ncol(Em),
    rho_alt_boyut_ici = spearman(Cm[ic], P_sec[ic]),              # ANA ÖLÇÜT (273 çift)
    rho_D = rho_f[["D"]], rho_A = rho_f[["A"]], rho_S = rho_f[["S"]],
    rho_861_cift = spearman(Cm[ust], P_sec[ust]),
    top3 = mean(vapply(rownames(Cm), function(i) { o <- setdiff(rownames(Cm), i)
      names(which.max(P_sec[i, o])) %in% names(sort(Cm[i, o], decreasing = TRUE))[1:3] }, logical(1))),
    ic_eksi_dis = mean(Cm[ic]) - mean(Cm[dis]),
    loo_dogruluk = mean(vapply(rownames(Cm), function(i) { m <- vapply(names(key42), function(f)
      mean(Cm[i, setdiff(item_id(key42[[f]]), i)]), numeric(1)); names(which.max(m)) == alt_etiket[[i]] }, logical(1))))
}))
model_tablosu <- model_tablosu[order(-model_tablosu$rho_alt_boyut_ici), ]; rownames(model_tablosu) <- NULL
csv_yaz(model_tablosu, "tablo_H3_model_secimi.csv"); print(model_tablosu, row.names = FALSE, digits = 3)
secilen_model <- model_tablosu$model[1]
cat("Ana ölçüte göre seçilen model:", secilen_model, "\n")
# Analiz, seçilen modelin arşivlenmiş vektörleriyle sürer (Bölüm H4, cfg$vektor_dosyasi).
kontrol("secilen_model_arsivle_ayni", secilen_model == "text-embedding-3-large",
        "Seçilen model arşivdekinden farklıysa cfg$vektor_dosyasi değiştirilmeli ve bütün analiz yeniden çalıştırılmalıdır.")

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
  sonuc[[paste0("COV_esit_cozum_", f)]] <- length(esit)
}
anahtar_yap <- function(ids) paste(sort(ids), collapse = "|")
csv_yaz(do.call(rbind, lapply(names(formlar), function(nm) do.call(rbind, lapply(alt_boyutlar, function(f)
  data.frame(form = nm, subscale = f, item_id = formlar[[nm]][[f]]))))), "formlar.csv")
csv_yaz(do.call(rbind, lapply(alt_boyutlar, function(f) data.frame(subscale = f, item_id = names(ISI[[f]]),
  ISI = as.numeric(ISI[[f]])))), "ISI.csv")
log_yaz("FORMLAR_HAZIR")
formlar_tablo <- do.call(rbind, lapply(kisa_formlar, function(nm) data.frame(form = nm,
  t(vapply(formlar[[nm]], function(v) paste(sub("^Q0?", "", v), collapse = ", "), character(1))))))
csv_yaz(formlar_tablo, "tablo_formlar.csv"); print(formlar_tablo, row.names = FALSE)

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok bir araştırma sorusunu tek başına yanıtlamaz; AS2, AS3 ve AS4'te dört formun KONUMUNU verir
# ve AS5'in (alt küme testi) zeminini hazırlar. Temel fikir: bir alt boyutun 14 maddesinden 7'si
# choose(14, 7) = 3.432 farklı biçimde seçilebilir. Dört formun değerleri, aynı uzunluktaki bu bütün
# olası seçimlerin dağılımı içinde nerede duruyor?
#   İlgili sorular: AS2 (formların alfası bütün seçimler içinde ne kadar yüksek?), AS3 (tam puandan
#   sapma, yani RMSE, ne kadar küçük?), AS4 (anlamsal çeşitlilik SB ve temsil kaybı CL nerede?).
#
# Hangi veri hangi amaçla kullanılıyor?
#   alt_kume[[f]] : Bölüm 5'te yalnız madde METİNLERİNDEN hesaplanmış 3.432 kümenin anlamsal değerleri:
#                   SB (anlamsal genişlik; seçilen maddeler birbirinden ne kadar farklı), CL (temsil kaybı;
#                   elenen maddeler seçilenlere ne kadar uzak), CL_b (küme ve tümleyeninin karşılıklı temsil
#                   kaybı), tumleyen (kalan 7 maddelik kümenin satır numarası), kanonik_bolme (her iki yarılı
#                   bölünmeyi bir kez saymak için işaret), cov_esit_minimum (en küçük CL'yi veren kümeler).
#   kal, deg      : YANITLAR. Her kümenin alfa, yanlılık, s_d, RMSE ve kısa-tam r değeri iki grupta ayrı
#                   hesaplanır (alt_kume_psikometrik; tamsayı toplamlarıyla çalışır, eşit değerler eşit kalır).
#                   Yüzdelikler YALNIZ değerlendirme grubunda (deg) hesaplanır; kal değerleri AS5'teki
#                   tekrar içindir.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, genel kural 5 ve AS2-AS4 bölümleri)
#   Yüzdelik orta sıra yöntemiyle hesaplanır: dağılımda formun değerinden küçük olanların oranı artı
#   eşit olanların yarısı (x 100). Alfa ve SB'de yüksek yüzdelik daha yüksek değeri; RMSE ve CL'de düşük
#   yüzdelik daha küçük sapmayı veya daha az temsil kaybını gösterir.
#   Örnek: alfa_yzd = 90 ise formun alfası, olası yedili seçimlerin yaklaşık %90'ından yüksektir.
#   r_medyan: bütün kümelerdeki kısa-tam r'nin ortancası. Formun r değeri bununla karşılaştırılır; yüksek
#   r'nin tek başına başarı sayılmamasının nedeni, neredeyse her kümede r'nin yüksek olmasıdır.
#   Sınırlar: yüzdelikler betimseldir. 3.432 küme ortak maddeler içerdiği için bağımsız gözlem değildir;
#   p değeri verilmez. Tanım gereği sonuçlar bulgu sayılmaz (ör. COV21'in en düşük CL'si, MIN21'in yüksek
#   ve MAX21'in düşük SB'si). Bütünleşik tablo göstergeleri yan yana koyar; tek puanda birleştirmez ve
#   kazanan form ilan etmez.
#   Hangi tablo?: tablo_form_yuzdelikleri.csv (yüzdelikler), tablo_butunlesik.csv (tartışma için yan
#   yana görünüm), tum_alt_kumeler.csv (AS5 ve şekiller için bütün kümeler).
# ---------------------------------------------------------------------------------------------
tum_alt_listesi <- list()
for (f in alt_boyutlar) {
  for (g in c("kal", "deg")) {
    grup_verisi <- if (g == "kal") kal else deg
    # Adım 1. 3.432 kümenin psikometrik değerleri; satır sırası alt_kume[[f]] ile aynı kalır (merge yok).
    ps <- alt_kume_psikometrik(grup_verisi, formlar$FULL42[[f]], alt_kume[[f]]$subset_key)
    kontrol(paste0("ALT_anahtar_sirasi_", f, "_", g), identical(ps$subset_key, alt_kume[[f]]$subset_key))
    tum_alt_listesi[[paste0(f, "_", g)]] <- data.frame(subscale = f, grup = g,
      alt_kume[[f]][, c("subset_key", "SB", "CL", "CL_b", "tumleyen", "kanonik_bolme", "cov_esit_minimum")],
      ps[, c("alpha", "bias", "sd_d", "rmse", "r")], stringsAsFactors = FALSE)
    kontrol(paste0("ALT_3432_satir_", f, "_", g), nrow(tum_alt_listesi[[paste0(f, "_", g)]]) == choose(14, 7))
  }
}
tum_alt <- do.call(rbind, tum_alt_listesi); rownames(tum_alt) <- NULL   # sıra: D kal, D deg, A kal, ...

# Adım 2-3. Dört formun kendi satırı (değerlendirme grubu) ve orta sıra yüzdelikleri.
#   (Formun alfa ve RMSE değerinin AS2 ve AS3 ile aynı olduğu Sonuç bölümünde denetlenir.)
yuzdelik_listesi <- list()
for (form in kisa_formlar) {
  for (f in alt_boyutlar) {
    dilim <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]   # o alt boyutun 3.432 kümesi (deg)
    satir <- dilim[dilim$subset_key == anahtar_yap(formlar[[form]][[f]]), ]   # formun kendi satırı
    kontrol(paste0("ALT_form_satiri_", form, "_", f), nrow(satir) == 1L)
    y <- data.frame(form = form, subscale = f,
      alfa = satir$alpha, alfa_yzd = midrank_percentile(dilim$alpha, satir$alpha),
      rmse = satir$rmse, rmse_yzd = midrank_percentile(dilim$rmse, satir$rmse),
      SB = satir$SB, SB_yzd = midrank_percentile(dilim$SB, satir$SB),
      CL = satir$CL, CL_yzd = midrank_percentile(dilim$CL, satir$CL),
      r = satir$r, r_medyan = stats::median(dilim$r))
    yuzdelik_listesi[[paste0(form, "_", f)]] <- y
    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS2_alfa_yzd_", form, "_", f)]] <- y$alfa_yzd
    sonuc[[paste0("AS3_rmse_yzd_", form, "_", f)]] <- y$rmse_yzd
    sonuc[[paste0("AS4_SB_yzd_", form, "_", f)]] <- y$SB_yzd
    sonuc[[paste0("AS4_CL_yzd_", form, "_", f)]] <- y$CL_yzd
    sonuc[[paste0("AS3_r_medyan_", f)]] <- y$r_medyan   # formdan bağımsızdır; her formda aynı değer yazılır
  }
}
yuzdelik <- do.call(rbind, yuzdelik_listesi); rownames(yuzdelik) <- NULL

csv_yaz(tum_alt, "tum_alt_kumeler.csv")
csv_yaz(yuzdelik, "tablo_form_yuzdelikleri.csv")
cat("\nALT KÜME TABLOSU özeti (değerlendirme grubu; yüzdelikler 3.432 yedili küme içinde):\n")
print(yuzdelik[, c("form", "subscale", "alfa_yzd", "rmse_yzd", "SB_yzd", "CL_yzd")], row.names = FALSE, digits = 3)
log_yaz("ALT_KUME_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 1 (AS1): DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer
#   maddelerle ortalama anlamsal benzerliği (ISI) ile GRM altında kestirilen ayırt edicilik
#   parametreleri (a) arasında nasıl bir ilişki vardır?
#
# Hangi veri hangi amaçla kullanılıyor?
#   ISI[[f]] : Yalnız madde METİNLERİNDEN gelir (gömme vektörlerinin kosinüs benzerliği). Bir maddenin
#              kendi alt boyutundaki diğer 13 maddeye anlamca ortalama ne kadar benzediğini gösterir.
#              Yanıt verisi kullanılmaz; bu yüzden iki grupta da aynıdır. MIN21 (en düşük ISI) ve
#              MAX21 (en yüksek ISI) formları bu değerlerle seçilmiştir.
#   kal, deg : Katılımcı YANITLARI (0-3). GRM ile her maddenin ayırt ediciliği (a) ve eşikleri (b1-b3)
#              kestirilir. kal (kalibrasyon, 2.000 kişi) ana analizdir. deg (değerlendirme, 2.000 kişi)
#              aynı analizin ikinci, örtüşmeyen bir katılımcı grubunda tekrarıdır (ISI değerleri aynı
#              kaldığı için tam bağımsız bir tekrar değildir; deg, hiç bakılmamış bir doğrulama
#              örneklemi olarak da sunulmaz).
#   C        : 42 x 42 kosinüs matrisi; bu da madde metinlerinden gelir. Adım 6'da madde ÇİFTLERİ
#              düzeyinde anlamsal yakınlık olarak kullanılır.
#   Analiz birimi: her alt boyutta 14 sabit madde; her ilişki 14 nokta (Adım 6'da 91 çift) üzerindedir.
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS1 bölümü ve genel yorum kuralları)
#   rho_ISI_a > 0 : aynı alt boyuttaki diğer maddelere anlamca ortalama daha benzer olan maddelerin a
#                   değeri, bu 14 maddede, daha yüksek olma eğilimindedir; rho_ISI_a < 0 ise tersi.
#                   |rho| < 0,30 zayıf, 0,30-0,50 orta, 0,50 ve üstü güçlü diye adlandırılır
#                   (adlandırmadır, başarı eşiği değildir).
#   Tutarlılık    : kal, deg ve CITC aynı yönü gösterirse ilişki tutarlı sayılır. CITC, GRM'den bağımsız
#                   bir göstergedir; yerel bağımlılıktan ise a kadar etkilenebilir.
#   Model uyumu   : GRM uyumu zayıfsa a, "bu model altında kestirilen ayırt edicilik" diye adlandırılır.
#                   Paket belgeleri "zayıf uyum" için sayısal eşik vermez; ölçüt tezin yöntem metninde
#                   danışmanla belirlenir (Adım 5'teki nota bakın).
#   Sınırlar      : 14 sabit maddeye ilişkin betimsel sonuçtur. Nedensellik (benzerlik ayırt ediciliği
#                   artırır) ve madde evrenine genelleme yapılmaz; güven aralığı ve p değeri verilmez.
#   Önceki çalışma: Kilmen ve Bulut (2025) ile yalnız yön düzeyinde karşılaştırılır; ölçek, örneklem ve
#                   gömme modeli (onlarda BERT) farklıdır. ECR kaygı alt boyutunda negatif ilişki
#                   (r = -0,55) bildirmişler, kaçınma alt boyutunda ise bu ilişkiyi gözlememişlerdir.
#                   Yön farklı çıkarsa bu, önceki sonucun yanlışlanması olarak değil, ilişkinin ölçeğe ve
#                   koşullara bağlı olabileceği biçiminde yazılır.
#   Hangi tablo?  : AS1'in yanıtı tablo_AS1_ISI_a.csv'dedir. _madde_parametreleri madde düzeyindeki
#                   değerleri, _GRM_tani, _kosinus_Q3 ve _kategori_kullanimi ise tanıları verir.
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
    #   Yorum: a büyüdükçe madde, gizil düzeyi farklı kişileri daha keskin ayırır. b_k, k veya daha üst
    #   bir kategoride yanıt verme olasılığının %50 olduğu gizil düzeydir (standart birimde).
    mod <- fit_grm(Xg)
    p <- grm_parameters(mod)
    # a'yı ISI ile aynı madde sırasına getir; sıra kayarsa korelasyon yanlış maddeleri eşleştirir.
    p <- p[match(havuz, p$item_id), , drop = FALSE]; rownames(p) <- NULL
    kontrol(paste0("AS1_parametre_sirasi_", etiket), identical(p$item_id, havuz))

    # Adım 4 (Adım 3'teki ilişkilerde kullanıldığı için önce hesaplanır).
    #   CITC (düzeltilmiş madde-toplam korelasyonu): madde puanı ile aynı alt boyuttaki diğer 13
    #   maddenin toplamı arasındaki Pearson r. Buradaki "düzeltilmiş", maddenin toplamdan çıkarılması
    #   demektir. Amaç: GRM'ye bağlı olmayan destekleyici bir ayırt edicilik göstergesi.
    citc <- vapply(havuz, function(i)
      stats::cor(Xg[[i]], rowSums(Xg[, setdiff(havuz, i), drop = FALSE])), numeric(1))

    # Adım 3. AS1'in ana katsayısı: ISI ile a arasındaki Spearman sıra korelasyonu (14 madde).
    #   Açıklayıcı not (tanım değil): Spearman doğrusal olması gerekmeyen, tekdüze (monoton) ilişkiyi
    #   ölçer ve uç değerlere Pearson'dan daha az duyarlıdır.
    rho_ISI_a <- spearman(isi_f, p$a)
    rho_ISI_CITC <- spearman(isi_f, citc)   # ISI ile CITC: ana ilişkiyle aynı yönde mi?
    rho_a_CITC <- spearman(p$a, citc)       # a ile CITC: iki ayırt edicilik göstergesi birbirini tutuyor mu?

    as1_parametre_listesi[[etiket]] <- data.frame(subscale = f, grup = g, item_id = havuz, ISI = as.numeric(isi_f),
      a = p$a, b1 = p$b1, b2 = p$b2, b3 = p$b3, CITC = as.numeric(citc))
    as1_iliski[[etiket]] <- data.frame(subscale = f, grup = g, n_madde = length(havuz),
      rho_ISI_a = rho_ISI_a, rho_ISI_CITC = rho_ISI_CITC, rho_a_CITC = rho_a_CITC)

    # Adım 5. Model tanıları.
    #   C2 (Cai ve Monroe, 2014) temelli uyum: C2, df, p, RMSEA, SRMSR. GRM'nin bu 14 maddeye ne kadar
    #   uyduğunu gösterir. Büyük örneklemde (n = 2.000) kesin uyum neredeyse her zaman reddedilir;
    #   yaklaşık uyum RMSEA ve SRMSR ile birlikte değerlendirilir. Tabloda p = 0 görünmesi çok küçük bir
    #   değerin sıfıra yuvarlanmasıdır; "p < 0,001" diye yazılır.
    #   Uyum ölçütü hakkında not: Maydeu-Olivares ve Joe'nun (2014) eşikleri (RMSEA2 <= 0,05 yakın,
    #   <= 0,089 kabul edilebilir) M2 temelli RMSEA için önerilmiştir. C2 temelli RMSEA için doğrudan
    #   geçerli değildir; ancak yaklaşık bir okuma sağlar. SRMSR için 0,05 yakın uyum ölçütü olarak
    #   kullanılır (Maydeu-Olivares, 2013).
    #   Düzeltilmiş (ortalaması çıkarılmış) Q3 = ham Q3 eksi 91 çiftin ortalama Q3'ü. Ham Q3, ortak faktör
    #   denetlendikten sonra iki madde arasında kalan ilişkidir (yerel bağımlılık). Pozitif düzeltilmiş
    #   değer, çiftin kalan ilişkisinin ortalamanın üstünde olduğunu gösterir. q3_esik_ustu_cift,
    #   ortalamanın 0,20 üstündeki çiftlerin sayısıdır. Bu eşik Rasch modelleri için önerilmiş bir tarama
    #   ölçütüdür (Christensen, Makransky ve Horton, 2017); madde silme kararı için kullanılmaz.
    m2 <- tryCatch(uyarilari_kaydet(mirt::M2(mod, type = "C2")), error = function(e) {
      log_yaz("UYARI", "AS1 M2 (C2) hesaplanamadi:", etiket, conditionMessage(e)); NULL })
    m2_deger <- function(s) {
      if (is.null(m2)) return(NA_real_)
      if (!(s %in% names(m2))) { log_yaz("UYARI", "AS1 M2 sutunu yok:", s, etiket); return(NA_real_) }
      as.numeric(m2[[s]][1])
    }
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
      # birlikte_formlar: yerel bağımlı çiftin hangi kısa formlarda birlikte kaldığı (betimsel bilgi).
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

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok yeni bir hesap yapmaz; önceki blokların sonuçlarını iki şekille gösterir.
#   sekil_AS1_ISI_a.png         (AS1): Her alt boyutta 14 madde. x = ISI (madde metinlerinden),
#                                y = kalibrasyon grubundaki GRM ayırt ediciliği a (as1_parametreler).
#                                Noktalar madde kimlikleriyle etiketlidir; panel başlığında Spearman rho.
#   sekil_AS5_alt_kume_testi.png (AS5): Değerlendirme grubu (tum_alt). Üst satır: 3.432 kümede SB ile alfa;
#                                alt satır: 1.716 bölünmede CL_b ile RMSE. Gri noktalar bütün kümeler; dört
#                                form kendi satırlarındaki değerlerle ayrı şekil ve renkle işaretlidir.
#
# Nasıl okunur?
#   AS1 şekli: noktalar sağa doğru yükseliyorsa (pozitif rho), diğer maddelere anlamca daha benzer maddelerin
#     a değeri daha yüksek olma eğilimindedir. Tek tek maddeler (ör. en solda kalanlar) yorumu somutlaştırır;
#     14 noktaya dayanan bir betimlemedir, nedensellik göstermez.
#   AS5 şekli: üst satırda bulutun aşağı eğimi, çeşitlilik arttıkça alfanın düşme eğilimini; alt satırda yukarı
#     eğimi, iki yarının birbirini daha az temsil etmesiyle RMSE'nin artma eğilimini gösterir. Formların bulut
#     içindeki yeri, ALT KÜME TABLOSU'ndaki yüzdeliklerin görsel karşılığıdır. MIN21 ile MAX21 aynı bölünmenin
#     iki yarısı olduğu için alt satırda üst üste düşer; bu bir hata değildir (şeklin alt yazısında belirtilir).
#   Söylenmez: şekiller yordama iddiası, başarı eşiği veya "en iyi küme" seçimi için kullanılmaz.
# ---------------------------------------------------------------------------------------------
virgullu <- function(x, basamak = 2) sub(".", ",", formatC(x, format = "f", digits = basamak), fixed = TRUE)
alt_boyut_adi <- c(D = "Depresyon (D)", A = "Kaygı (A)", S = "Stres (S)")
eksen_virgul <- function(x) sub(".", ",", format(x, trim = TRUE), fixed = TRUE)   # eksenlerde ondalık virgül, eşit basamak

# ---- Şekil 1: AS1, ISI ile a (kalibrasyon grubu) ----
s1 <- as1_parametreler[as1_parametreler$grup == "kal", c("subscale", "item_id", "ISI", "a")]
s1$panel <- factor(paste0(alt_boyut_adi[s1$subscale], ", rho = ",
                          virgullu(unlist(sonuc[paste0("AS1_rho_kal_", s1$subscale)]))),
                   levels = paste0(alt_boyut_adi, ", rho = ", virgullu(unlist(sonuc[paste0("AS1_rho_kal_", alt_boyutlar)]))))
sekil1 <- ggplot2::ggplot(s1, ggplot2::aes(x = ISI, y = a)) +
  ggplot2::geom_point(size = 1.8, colour = "grey20") +
  ggplot2::geom_text(ggplot2::aes(label = item_id), size = 2.4, vjust = -0.8, colour = "grey30") +
  ggplot2::facet_wrap(~panel, nrow = 1, scales = "free_x") +
  ggplot2::scale_x_continuous(labels = eksen_virgul) + ggplot2::scale_y_continuous(labels = eksen_virgul) +
  ggplot2::labs(x = "ISI (alt boyuttaki diğer maddelerle ortalama kosinüs benzerliği)",
                y = "GRM ayırt edicilik (a), kalibrasyon grubu") +
  ggplot2::theme_bw(base_size = 9) +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = "white", colour = NA))
ggplot2::ggsave(file.path(out, "sekil_AS1_ISI_a.png"), sekil1, width = 9, height = 3.6, dpi = 300, bg = "white")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 2 (AS2): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21, üç faktörlü yapının desteklenmesi ve alt boyut puanlarının güvenirliği bakımından nasıl
#   farklılaşmaktadır?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi, 0-3). Bütün DFA'lar ve güvenirlikler bu
#              grupta hesaplanır. (Kalibrasyon grubu AS1'de kullanılmıştı; burada kullanılmaz.)
#   formlar  : Hangi maddenin hangi forma ve alt boyuta girdiği. Beş form karşılaştırılır:
#              FULL42 (42 madde, yalnız başvuru noktası), PUB21 (yayımlanmış DASS-21),
#              MIN21 (en düşük ISI), MAX21 (en yüksek ISI), COV21 (en küçük temsil kaybı, CL).
#              Kısa formların her alt boyutunda 7 madde vardır.
#   Analiz birimi: dört kısa form (FULL42 başvuru noktası), her formda üç alt boyut.
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS2 bölümü ve genel yorum kuralları)
#   Uyum     : CFI, TLI, RMSEA (%90 aralığıyla) ve SRMR her form için yan yana verilir. Formlar uyum
#              indekslerine göre SIRALANMAZ ve ΔCFI veya ΔRMSEA eşikleriyle "kazanan" seçilmez: farklı
#              madde kümeleriyle kurulan modeller iç içe değildir ve yükler yükseldikçe aynı yanlış
#              belirlemede RMSEA kötüleşebilir (McNeish, An ve Hancock, 2018).
#   Omega    : Güvenirliğin ana göstergesidir (obs.var = FALSE). obs.var = TRUE değeri ektedir.
#   Alfa     : Yardımcı göstergedir. Formun alfasının bütün yedili kümeler içindeki yüzdeliği sonraki
#              blokta (ALT KÜME TABLOSU) hesaplanır; bu blokta yalnız alfa değeri üretilir.
#   Sınırlar : Anlamsal olarak dar (birbirine benzeyen maddelerden oluşan) bir formun yüksek
#              güvenirliği "daha homojen puan" demektir, "daha iyi ölçme" demek değildir. Daha düşük
#              faktör korelasyonu tek başına daha iyi form anlamına gelmez. Kazanan form ilan edilmez.
#   Hangi tablo?: tablo_AS2_DFA_uyum.csv ve tablo_AS2_guvenirlik.csv AS2'nin ana yanıtıdır;
#              _yukler ve _faktor_korelasyonlari yapının ayrıntısını verir.
# ---------------------------------------------------------------------------------------------
as2_formlar <- c("FULL42", kisa_formlar)   # FULL42 başvuru noktası; ardından dört kısa form
as2_uyum_listesi <- list(); as2_yuk_listesi <- list(); as2_korelasyon_listesi <- list(); as2_guv_listesi <- list()

for (form in as2_formlar) {
  maddeler_form <- formlar[[form]]          # list(D = ..., A = ..., S = ...): alt boyut başına madde kimlikleri

  # Adım 1. Üç ilişkili faktörlü sıralı DFA (WLSMV; gizil varyanslar 1; çapraz yük ve artık kovaryans yok).
  #   Amaç: formun maddeleri kuramsal D-A-S yapısını ne ölçüde destekliyor? Model yalnız fit_cfa ile kurulur;
  #   fit_cfa yakınsamayan veya kabul edilemez (ör. negatif varyans) çözümde betiği durdurur.
  fit <- fit_cfa(deg, maddeler_form)

  # Adım 2. Uyum ölçüleri (ölçeklenmiş ki-kare, sd, p, CFI, TLI, RMSEA ve %90 aralığı, SRMR).
  #   Yorum: CFI/TLI 1'e, RMSEA ve SRMR 0'a yaklaştıkça model-veri uyumu artar. n = 2.000'de ki-kare
  #   testinin p değeri neredeyse her zaman küçüktür; değerler yan yana betimlenir, formlar sıralanmaz.
  uyum <- lavaan::fitMeasures(fit, dfa_uyum_olculeri)
  as2_uyum_listesi[[form]] <- data.frame(form = form, n_madde = length(unlist(maddeler_form)),
                                         t(as.numeric(uyum[dfa_uyum_olculeri])))
  names(as2_uyum_listesi[[form]]) <- c("form", "n_madde", dfa_uyum_olculeri)

  # Adım 3. Standartlaştırılmış faktör yükleri (op == "=~" satırları), standart hata ve %95 aralık.
  #   Yorum: yük, maddenin kendi faktörüyle ilişkisinin gücüdür; formlar arasında en düşük ve ortalama
  #   yük betimsel olarak karşılaştırılabilir.
  ss <- lavaan::standardizedSolution(fit)
  ss <- ss[ss$op == "=~", , drop = FALSE]
  as2_yuk_listesi[[form]] <- data.frame(form = form, faktor = ss$lhs, item_id = ss$rhs, yuk = ss$est.std,
                                        se = ss$se, alt = ss$ci.lower, ust = ss$ci.upper)

  # Adım 4. Faktörler arası korelasyonlar (D-A, D-S, A-S).
  #   Yorum: alt boyutların birbirinden ne ölçüde ayrıştığını gösterir; tek başına form kalitesi ölçütü değildir.
  kor <- lavaan::lavInspect(fit, "cor.lv")
  as2_korelasyon_listesi[[form]] <- data.frame(form = form, cift = c("D-A", "D-S", "A-S"),
                                               r = c(kor["D", "A"], kor["D", "S"], kor["A", "S"]))

  # Adım 5. Alt boyut güvenirliği: kategorik omega (ana), obs.var = TRUE omega (ek) ve ham alfa (yardımcı).
  #   Omega: sıralı DFA'nın yüklerinden hesaplanan güvenirlik. Alfa yalnız alpha_raw ile hesaplanır
  #   (standartlaştırılmış alfa veya başka paketlerin alfa işlevi kullanılmaz).
  omega_ana <- omega_values(fit, obs.var = FALSE)
  omega_ek <- omega_values(fit, obs.var = TRUE)
  as2_guv_listesi[[form]] <- do.call(rbind, lapply(alt_boyutlar, function(f)
    data.frame(form = form, subscale = f, omega = as.numeric(omega_ana[f]),
               omega_obsvar_true = as.numeric(omega_ek[f]), alfa = alpha_raw(deg[, maddeler_form[[f]]]))))

  # sonuc listesine yalnız hesaplanan nesneler atanır. Uyum anahtarları beş form için (FULL42 dahil),
  # omega ve alfa anahtarları yalnız dört kısa form için yazılır.
  sonuc[[paste0("AS2_CFI_", form)]] <- as.numeric(uyum["cfi.scaled"])
  sonuc[[paste0("AS2_RMSEA_", form)]] <- as.numeric(uyum["rmsea.scaled"])
  sonuc[[paste0("AS2_SRMR_", form)]] <- as.numeric(uyum["srmr"])
  if (form != "FULL42") for (f in alt_boyutlar) {
    satir <- as2_guv_listesi[[form]][as2_guv_listesi[[form]]$subscale == f, ]
    sonuc[[paste0("AS2_omega_", form, "_", f)]] <- satir$omega
    sonuc[[paste0("AS2_alfa_", form, "_", f)]] <- satir$alfa
  }
}

# Tablolar (satır sırası: FULL42, PUB21, MIN21, MAX21, COV21; güvenirlikte her formda D, A, S).
as2_guvenirlik <- do.call(rbind, as2_guv_listesi); rownames(as2_guvenirlik) <- NULL
as2_uyum <- do.call(rbind, as2_uyum_listesi); rownames(as2_uyum) <- NULL
kontrol("AS2_yuk_sayisi", nrow(do.call(rbind, as2_yuk_listesi)) == 42L + 4L * 21L)
csv_yaz(as2_uyum, "tablo_AS2_DFA_uyum.csv")
csv_yaz(do.call(rbind, as2_yuk_listesi), "tablo_AS2_yukler.csv")
csv_yaz(do.call(rbind, as2_korelasyon_listesi), "tablo_AS2_faktor_korelasyonlari.csv")
csv_yaz(as2_guvenirlik, "tablo_AS2_guvenirlik.csv")
cat("\nAS2 özeti (uyum):\n"); print(as2_uyum[, c("form", "n_madde", "cfi.scaled", "tli.scaled", "rmsea.scaled", "srmr")],
                                   row.names = FALSE, digits = 3)
cat("\nAS2 özeti (güvenirlik):\n"); print(as2_guvenirlik, row.names = FALSE, digits = 3)
log_yaz("AS2_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 3 (AS3): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21'in alt boyut puanları, DASS-42'nin ilgili alt boyut puanlarıyla ne ölçüde uyumludur?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi, 0-3). Her kişi için iki puan hesaplanır:
#              kısa puan (formun o alt boyuttaki 7 maddesinin ortalaması) ve tam puan (DASS-42'nin o alt
#              boyuttaki 14 maddesinin ortalaması). İkisi de 0-3 aralığındadır.
#   formlar  : Dört kısa form (PUB21, MIN21, MAX21, COV21) ve tam form (FULL42).
#   Analiz birimi: dört form x üç alt boyut; her satırdaki göstergeler 2.000 kişi üzerindendir.
#
# Göstergeler (d = kısa puan - tam puan, kişi başına):
#   r        : kısa ve tam puan arasındaki Pearson korelasyonu (kişilerin sıralaması ne kadar korunuyor?).
#   bias     : d'nin ortalaması (yanlılık). Pozitifse kısa form ortalamada daha YÜKSEK puan verir.
#              İşaret "kısa eksi tam" yönündedir; ters çevrilmez.
#   sd_d     : d'nin standart sapması (n paydalı); kişiden kişiye değişen sapma.
#   rmse     : sqrt(ortalama(d^2)); tam puandan ortalama sapmanın büyüklüğü (ANA gösterge).
#              rmse^2 = bias^2 + sd_d^2 olduğundan RMSE'nin yanlılıktan mı, kişi düzeyindeki dağılımdan mı
#              geldiği her zaman birlikte yazılır.
#   rmse_0_42: rmse x 14; DASS-42 alt boyut toplam puanı biriminde (0-42) aynı değer (okumayı kolaylaştırır).
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS3 bölümü ve genel yorum kuralları)
#   Düşük RMSE: seçilen yedi madde ile kalan yedi madde kişi düzeyinde birbirine daha yakın demektir
#              (kısa form, tam formun yarısıdır; ham uyum bu bölünmenin özelliğidir).
#   MIN21 ile MAX21 her alt boyutta birbirinin tümleyenidir (aynı 14 maddeyi ikiye böler). Bu yüzden
#              farkları ters işaretli, RMSE değerleri eşittir; bu yeni bir bağımsız kanıt değildir.
#   Söylenmez: RMSE "ölçme hatası" değildir; tam form gerçek puan değildir ve kısa formla ortak maddeler
#              içerir. Yüksek kısa-tam korelasyonu geçerlik veya puan eşdeğerliği kanıtı değildir; küçük
#              RMSE klinik eşdeğerlik göstermez. 0-42 birimindeki değerler klinik önem eşiği değildir.
#   Sonra    : RMSE yüzdelikleri ve r medyanı ALT KÜME TABLOSU, PUB21'e göre RMSE farklarının bootstrap
#              aralıkları BOOTSTRAP bloğunda hesaplanır; bu blok yalnız değerleri üretir.
#   Hangi tablo?: tablo_AS3_uyum.csv AS3'ün ana yanıtıdır.
# ---------------------------------------------------------------------------------------------
as3_satirlar <- list(); as3_farklar <- list()   # farklar: denetim için kişi düzeyindeki d değerleri

for (form in kisa_formlar) {
  for (f in alt_boyutlar) {
    # Adım 1. Kişi başına kısa ve tam puan (madde ortalaması, 0-3).
    kisa <- rowMeans(deg[, formlar[[form]][[f]]])
    tam <- rowMeans(deg[, formlar$FULL42[[f]]])

    # Adım 2. Uyum göstergeleri (r, bias, sd_d, rmse) Bölüm 3'teki uyum_olculeri ile.
    u <- uyum_olculeri(kisa, tam)
    as3_farklar[[paste0(form, "_", f)]] <- kisa - tam
    as3_satirlar[[paste0(form, "_", f)]] <- data.frame(form = form, subscale = f, r = u[["r"]], bias = u[["bias"]],
      sd_d = u[["sd_d"]], rmse = u[["rmse"]], rmse_0_42 = 14 * u[["rmse"]])

    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS3_r_", form, "_", f)]] <- u[["r"]]
    sonuc[[paste0("AS3_bias_", form, "_", f)]] <- u[["bias"]]
    sonuc[[paste0("AS3_rmse_", form, "_", f)]] <- u[["rmse"]]
  }
}
as3_uyum <- do.call(rbind, as3_satirlar); rownames(as3_uyum) <- NULL

# Adım 3. Tanımdan gelen eşitliklerin denetimi (hesap hatası olursa betik burada durur).
#   MIN21 ve MAX21 tümleyen olduğu için kişi düzeyinde d_MIN21 + d_MAX21 = 0 ve RMSE'ler eşittir;
#   her satırda rmse^2 = bias^2 + sd_d^2 (RMSE'nin yanlılık ve dağılım bileşenlerine ayrışması).
for (f in alt_boyutlar) {
  kontrol(paste0("AS3_MIN_MAX_farklar_toplami_", f),
          max(abs(as3_farklar[[paste0("MIN21_", f)]] + as3_farklar[[paste0("MAX21_", f)]])) < 1e-12)
  kontrol(paste0("AS3_MIN_MAX_rmse_esit_", f),
          abs(sonuc[[paste0("AS3_rmse_MIN21_", f)]] - sonuc[[paste0("AS3_rmse_MAX21_", f)]]) < 1e-12)
}
kontrol("AS3_rmse_ayrisimi", max(abs(as3_uyum$rmse^2 - (as3_uyum$bias^2 + as3_uyum$sd_d^2))) < 1e-12)

# Tablo (satır sırası: PUB21, MIN21, MAX21, COV21; her formda D, A, S).
csv_yaz(as3_uyum, "tablo_AS3_uyum.csv")
cat("\nAS3 özeti (kısa-tam uyum; bias, sd_d ve rmse 0-3 madde ortalaması biriminde):\n")
print(as3_uyum, row.names = FALSE, digits = 3)
log_yaz("AS3_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok hangi soruya hizmet eder? AS3 (RMSE farkları ana metinde) ve AS2 (alfa farkları eklerde).
#   Soru: Anlamsal formların (MIN21, MAX21, COV21) alfa ve RMSE değerleri yayımlanmış DASS-21'den (PUB21)
#   ne kadar farklıdır ve bu fark örneklemden örnekleme ne kadar oynar?
#
# Hangi veri hangi amaçla kullanılıyor?
#   deg      : Değerlendirme grubunun YANITLARI (2.000 kişi). Her tekrarda kişiler iadeli olarak yeniden
#              çekilir (katılımcı bootstrap'ı). Aynı çekilen kişiler (ix) bütün formlara ve tam puana
#              uygulanır; böylece farklar EŞLEŞTİRİLMİŞ olur (aynı kişiler üzerinde iki form karşılaştırılır).
#   formlar  : Karşılaştırılan formlar; fark her zaman "anlamsal form eksi PUB21" yönündedir.
#   Modeller yeniden kestirilmez; alfa (alpha_raw) ve RMSE doğrudan yanıtlardan hesaplanır. Rastgele sayı
#   yalnız tanımlanan biçimde kullanılır: her tekrarda set.seed(cfg$tohum_bootstrap + b) ve tek sample.int.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, genel kural 4 ve AS3 bölümü)
#   tahmin   : farkın bütün değerlendirme grubundaki değeri (bootstrap ortalaması DEĞİL).
#   alt, ust : 2.000 tekrarın 2,5. ve 97,5. yüzdelikleri; her fark için ayrı %95 aralık (eşzamanlı değil).
#   Sıfırı dışlayan aralık "bu örneklemde tutarlı bir fark" olarak okunur. Sıfırı içeren aralık
#   eşdeğerlik kanıtı DEĞİLDİR (fark yok demek değildir).
#   Yön: alfa farkı pozitifse anlamsal formun alfası PUB21'den yüksektir. RMSE farkı pozitifse anlamsal
#   formun puanı tam puandan PUB21'e göre DAHA ÇOK sapar (negatifse daha az).
#   MIN21 ile MAX21 aynı bölünmenin iki yarısı olduğu için RMSE farkları ve aralıkları aynıdır; bu yeni
#   bir kanıt değildir.
#   Söylenmez: alfa aralıkları omega aralığı değildir ve öyle sunulmaz. Aralıklar p değeri veya çoklu
#   karşılaştırma düzeltmesi içermez; kazanan form ilan edilmez.
#   Hangi tablo?: tablo_bootstrap_farklar.csv (olcu = rmse satırları AS3'te, olcu = alfa satırları eklerde).
# ---------------------------------------------------------------------------------------------
n <- nrow(deg)
boot_formlar <- anlamsal_formlar            # MIN21, MAX21, COV21 (her biri PUB21 ile karşılaştırılır)

# Bir veri kümesi (tam grup ya da bir bootstrap örneklemi) için 18 farkı hesaplayan yardımcı işlev.
# Sonuç: adları "alfa_MIN21_D", ..., "rmse_COV21_S" olan 18 elemanlı vektör.
farklari_hesapla <- function(X) {
  fark <- c()
  for (f in alt_boyutlar) {
    tam <- rowMeans(X[, formlar$FULL42[[f]]])                    # tam alt boyut puanı (0-3)
    kisa_pub <- rowMeans(X[, formlar$PUB21[[f]]])                # PUB21 kısa puanı
    alfa_pub <- alpha_raw(X[, formlar$PUB21[[f]]])
    rmse_pub <- sqrt(mean((kisa_pub - tam)^2))
    for (form in boot_formlar) {
      kisa <- rowMeans(X[, formlar[[form]][[f]]])
      fark[paste0("alfa_", form, "_", f)] <- alpha_raw(X[, formlar[[form]][[f]]]) - alfa_pub
      fark[paste0("rmse_", form, "_", f)] <- sqrt(mean((kisa - tam)^2)) - rmse_pub
    }
  }
  fark
}

# Adım 1. Nokta tahmini: bütün değerlendirme grubunda (ix = 1:n) farklar.
tahmin <- farklari_hesapla(deg)
# Tutarlılık denetimi: nokta tahminleri AS2 ve AS3'teki değerlerden elde edilen farklara eşit olmalı.
for (f in alt_boyutlar) for (form in boot_formlar) {
  kontrol(paste0("BOOT_tahmin_alfa_", form, "_", f), abs(tahmin[[paste0("alfa_", form, "_", f)]] -
    (sonuc[[paste0("AS2_alfa_", form, "_", f)]] - sonuc[[paste0("AS2_alfa_PUB21_", f)]])) < 1e-10)
  kontrol(paste0("BOOT_tahmin_rmse_", form, "_", f), abs(tahmin[[paste0("rmse_", form, "_", f)]] -
    (sonuc[[paste0("AS3_rmse_", form, "_", f)]] - sonuc[[paste0("AS3_rmse_PUB21_", f)]])) < 1e-10)
}

# Adım 2. 2.000 bootstrap tekrarı. Her tekrarda tohum tekrarın numarasına bağlıdır; bu yüzden sonuçlar
#   her çalıştırmada birebir aynı çıkar. Aynı ix bütün formlara uygulanır.
boot_matrisi <- matrix(NA_real_, nrow = cfg$B, ncol = length(tahmin), dimnames = list(NULL, names(tahmin)))
for (b in seq_len(cfg$B)) {
  set.seed(cfg$tohum_bootstrap + b)
  ix <- sample.int(n, n, replace = TRUE)
  boot_matrisi[b, ] <- farklari_hesapla(deg[ix, , drop = FALSE])
}
kontrol("BOOT_tum_tekrarlar_sonlu", all(is.finite(boot_matrisi)))

# Adım 3. %95 aralık: tekrarların 2,5. ve 97,5. yüzdelikleri (quantile type = 7).
#   Satır sırası: olcu (alfa, rmse), form (MIN21, MAX21, COV21), alt boyut (D, A, S).
boot_satirlari <- list()
for (olcu in c("alfa", "rmse")) for (form in boot_formlar) for (f in alt_boyutlar) {
  ad <- paste0(olcu, "_", form, "_", f)
  aralik <- quantile(boot_matrisi[, ad], c(0.025, 0.975), type = 7, names = FALSE)
  boot_satirlari[[ad]] <- data.frame(olcu = olcu, subscale = f, form = form, tahmin = tahmin[[ad]],
                                     alt = aralik[1], ust = aralik[2], B = cfg$B)
  # sonuc listesine yalnız hesaplanan nesneler atanır.
  sonuc[[paste0("BOOT_", olcu, "_", form, "_", f, "_alt")]] <- aralik[1]
  sonuc[[paste0("BOOT_", olcu, "_", form, "_", f, "_ust")]] <- aralik[2]
}
boot_farklar <- do.call(rbind, boot_satirlari); rownames(boot_farklar) <- NULL
# MIN21 ve MAX21 tümleyen olduğundan RMSE farkları her tekrarda eşittir (tanım denetimi).
kontrol("BOOT_MIN_MAX_rmse_esit", max(abs(boot_matrisi[, grep("^rmse_MIN21", colnames(boot_matrisi))] -
                                        boot_matrisi[, grep("^rmse_MAX21", colnames(boot_matrisi))])) < 1e-12)

csv_yaz(boot_farklar, "tablo_bootstrap_farklar.csv")
cat("\nBOOTSTRAP özeti (anlamsal form eksi PUB21; %95 aralık, B =", cfg$B, "):\n")
print(cbind(boot_farklar[, 1:3], signif(boot_farklar[, c("tahmin", "alt", "ust")], 4),
            sifiri_disliyor = boot_farklar$alt > 0 | boot_farklar$ust < 0), row.names = FALSE)
log_yaz("BOOTSTRAP_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 4 (AS4): Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış
#   DASS-21, seçilen maddelerin anlamsal çeşitliliği ve ilgili alt boyuttaki madde havuzunun anlamsal
#   temsili bakımından nasıl farklılaşmaktadır?
#
# Hangi veri hangi amaçla kullanılıyor? (bu blokta yanıt verisi KULLANILMAZ; yalnız madde metinleri)
#   alt_kume[[f]] : Bölüm 5'te gömme vektörlerinden hesaplanmış SB ve CL değerleri (3.432 küme).
#     SB (anlamsal genişlik) = 1 - seçilen 7 madde arasındaki ortalama kosinüs benzerliği.
#                             Yüksek SB: seçilen maddeler anlamca birbirinden daha farklı (daha çeşitli).
#     CL (temsil kaybı)     = her maddenin en yakın SEÇİLİ maddeye kosinüs uzaklığının 14 madde üzerinden
#                             ortalaması (seçilen maddelerin uzaklığı 0'dır). Düşük CL: elenen maddeler
#                             seçilenlerden birine anlamca yakın, yani havuz daha iyi temsil ediliyor.
#   C             : 42 x 42 kosinüs matrisi; madde temsil tablosunda her elenen maddenin en yakın seçili
#                   karşılığını bulmak için kullanılır.
#   maddeler$text : Madde metinleri; temsil tablosunda örnekleri somutlaştırmak için.
#   Analiz birimi: dört form x üç alt boyut; SB-CL ilişkisi için 3.432 küme; temsil tablosunda 84 elenen madde.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, AS4 bölümü ve genel yorum kuralları)
#   Asıl bulgular üçtür: (1) PUB21'in konumu, (2) her formun KENDİ seçim hedefi dışındaki göstergedeki
#   konumu (ör. MIN21'in CL'si, COV21'in SB'si), (3) SB ile CL'nin bütün kümelerde birlikte değişip
#   değişmediği (rho_SB_CL). Yüzdelikler ALT KÜME TABLOSU bloğundadır; burada yeniden hesaplanmaz.
#   rho_SB_CL < 0 ise: bu havuzda daha çeşitli kümeler daha az temsil kaybı verme eğilimindedir.
#   Tanım gereği olanlar bulgu değildir: MIN21'in yüksek, MAX21'in düşük SB'si, COV21'in en düşük CL'si.
#   Söylenmez: yüksek SB tek başına iyi temsil demek değildir. "Temsil" kapsam geçerliği DEĞİLDİR; yalnız
#   bu gömme uzayındaki anlamsal temsildir ve uzman içerik yargısının yerine geçmez. 3.432 küme ortak
#   maddeler içerdiği için p değeri verilmez.
#   Hangi tablo?: tablo_AS4_anlamsal.csv (formların SB ve CL'si), tablo_AS4_SB_CL.csv (ilişki),
#   tablo_AS4_madde_temsil.csv (hangi elenen madde hangi seçili maddeyle temsil ediliyor).
# ---------------------------------------------------------------------------------------------
as4_anlamsal_listesi <- list(); as4_temsil_listesi <- list(); as4_iliski_listesi <- list()

# Adım 1. Formların SB ve CL değerleri: alt_kume[[f]] içindeki kendi satırlarından okunur (yeniden hesaplanmaz).
for (form in kisa_formlar) for (f in alt_boyutlar) {
  satir <- alt_kume[[f]][alt_kume[[f]]$subset_key == anahtar_yap(formlar[[form]][[f]]), ]
  kontrol(paste0("AS4_form_satiri_", form, "_", f), nrow(satir) == 1L)
  as4_anlamsal_listesi[[paste0(form, "_", f)]] <- data.frame(form = form, subscale = f, SB = satir$SB, CL = satir$CL)
  sonuc[[paste0("AS4_SB_", form, "_", f)]] <- satir$SB
  sonuc[[paste0("AS4_CL_", form, "_", f)]] <- satir$CL
}

# Adım 2. Bütün 3.432 kümede SB ile CL arasındaki Spearman ilişkisi (her alt boyut için).
for (f in alt_boyutlar) {
  rho_SB_CL <- spearman(alt_kume[[f]]$SB, alt_kume[[f]]$CL)
  as4_iliski_listesi[[f]] <- data.frame(subscale = f, rho_SB_CL = rho_SB_CL)
  sonuc[[paste0("AS4_rho_SB_CL_", f)]] <- rho_SB_CL
}

# Adım 3. Madde temsil tablosu: her elenen madde için en yakın seçili madde ve kosinüs uzaklığı.
#   Yorum: uzaklık küçükse elenen maddenin içeriği formda anlamca yakın bir maddeyle "karşılanıyor"
#   demektir (bu gömme uzayında). en_zayif = TRUE, o form ve alt boyutta en uzak kalan (en zayıf temsil
#   edilen) elenen maddedir; tezde örnek vermek için kullanılır.
metin <- stats::setNames(maddeler$text, maddeler$item_id)
for (form in kisa_formlar) for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]
  secili <- formlar[[form]][[f]]
  elenenler <- havuz[!(havuz %in% secili)]            # havuz sırasında
  en_yakin <- vapply(elenenler, function(i) secili[which.max(C[i, secili])], character(1))
  uzaklik <- 1 - C[cbind(elenenler, en_yakin)]
  tablo <- data.frame(form = form, subscale = f, elenen = elenenler, elenen_metin = unname(metin[elenenler]),
                      en_yakin = unname(en_yakin), en_yakin_metin = unname(metin[en_yakin]),
                      uzaklik = uzaklik, en_zayif = uzaklik == max(uzaklik), stringsAsFactors = FALSE)
  # Denetim: elenen maddelerin uzaklıklarının 14'e bölünmüş toplamı formun CL değerine eşit olmalı
  # (seçilen maddelerin uzaklığı 0 olduğu için CL = toplam uzaklık / 14).
  kontrol(paste0("AS4_CL_temsil_tablosuyla_ayni_", form, "_", f),
          abs(sum(uzaklik) / 14 - sonuc[[paste0("AS4_CL_", form, "_", f)]]) < 1e-12)
  as4_temsil_listesi[[paste0(form, "_", f)]] <- tablo
}

# Tablolar (satır sırası: form PUB21, MIN21, MAX21, COV21; sonra alt boyut D, A, S).
as4_anlamsal <- do.call(rbind, as4_anlamsal_listesi); rownames(as4_anlamsal) <- NULL
as4_temsil <- do.call(rbind, as4_temsil_listesi); rownames(as4_temsil) <- NULL
csv_yaz(as4_anlamsal, "tablo_AS4_anlamsal.csv")
csv_yaz(do.call(rbind, as4_iliski_listesi), "tablo_AS4_SB_CL.csv")
csv_yaz(as4_temsil, "tablo_AS4_madde_temsil.csv")
cat("\nAS4 özeti (SB: anlamsal genişlik, CL: temsil kaybı):\n"); print(as4_anlamsal, row.names = FALSE, digits = 3)
print(do.call(rbind, as4_iliski_listesi), row.names = FALSE, digits = 3)
log_yaz("AS4_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 5 (AS5): DASS-42'nin her alt boyutundan seçilebilecek bütün yedili madde
#   kümelerinde, anlamsal çeşitlilik ve temsil ile puan güvenirliği ve tam form puanlarıyla uyum
#   arasında nasıl bir ilişki vardır?
#   AS5, ilk sonuçlar görüldükten sonra eklenmiş KEŞFEDİCİ bir sorudur; bulguları betimseldir.
#   "Alt küme testi" adı çıkarımsal bir hipotez testi değil, bütün olası kümelerin karşılaştırmasıdır.
#
# Hangi veri hangi amaçla kullanılıyor?
#   tum_alt : ALT KÜME TABLOSU bloğunda hazırlanan tablo. Her alt boyut ve grup için 3.432 kümenin
#             anlamsal değerleri (SB, CL_b; yalnız madde metinlerinden) ve psikometrik değerleri (alpha,
#             rmse, sd_d, bias; yanıtlardan) yan yanadır. Ana analiz değerlendirme (deg), tekrar
#             kalibrasyon (kal) grubundadır.
#   İki ana ilişki:
#     SB - alfa   : birim 3.432 küme. Seçilen maddeler çeşitlendikçe iç tutarlılık ne olur?
#     CL_b - RMSE : birim 1.716 bölünme. RMSE bir küme ile tümleyeninde (kalan 7 madde) aynıdır; bu yüzden
#                   bölünmenin özelliğidir ve bölünme düzeyindeki karşılıklı temsil kaybı (CL_b) ile
#                   eşleştirilir. Her bölünme bir kez sayılır (kanonik_bolme == TRUE). İki kez saymak
#                   katsayıyı değiştirmez; bu tercih analiz biriminin doğru raporlanması içindir.
#   Açıklayıcı ilişkiler (yalnız deg anahtarları): CL_b - s_d ve CL_b - |yanlılık|. RMSE'nin hangi
#   bileşeniyle (kişi düzeyindeki dağılım mı, ortalama kayma mı) daha çok ilişkili olduğunu gösterir.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, AS5 bölümü ve genel yorum kuralları)
#   rho_SB_alfa < 0 : bu havuzda çeşitlilik arttıkça iç tutarlılık düşme eğilimindedir.
#   rho_CLb_rmse > 0: iki yarının birbirini anlamsal olarak temsil etmesi zayıfladıkça tam form puanından
#                     sapma artma eğilimindedir.
#   |rho| < 0,30 zayıf, 0,30-0,50 orta, 0,50 ve üstü güçlü diye adlandırılır (başarı eşiği değildir).
#   İki grupta (ve EK ANALİZLER'deki yanıt kalitesi taramasından sonra) aynı yön görülürse ilişki tutarlı sayılır.
#   Söylenmez: "metin psikometrik sonucu öngörüyor" gibi bir yordama iddiası, başarı eşiği, yeni madde
#   havuzlarına genelleme, nedensellik. Kümeler ortak maddeler içerdiği için bağımsız değildir; p değeri
#   ve aralık verilmez. CL_b hangi yarının tutulacağını söylemez. Dağılımdan en iyi görünen küme seçilerek
#   beşinci bir form önerilmez.
#   Hangi tablo?: tablo_AS5_iliskiler.csv (şekil ŞEKİLLER bloğunda üretilir).
# ---------------------------------------------------------------------------------------------
as5_listesi <- list()
for (f in alt_boyutlar) {
  for (g in c("kal", "deg")) {
    # Bu alt boyut ve grubun 3.432 satırlık dilimi; satır sırası alt_kume[[f]] ile aynı olmalı, çünkü
    # tumleyen sütunu o sıradaki satır numarasıdır (yalnız bu dilim içinde kullanılır).
    dilim <- tum_alt[tum_alt$subscale == f & tum_alt$grup == g, ]
    kontrol(paste0("AS5_dilim_sirasi_", f, "_", g), identical(dilim$subset_key, alt_kume[[f]]$subset_key))

    # Denetim: her kümenin RMSE'si tümleyeninin RMSE'sine eşit, yanlılığı ters işaretli olmalı.
    kontrol(paste0("AS5_tumleyen_rmse_", f, "_", g), max(abs(dilim$rmse - dilim$rmse[dilim$tumleyen])) < 1e-12)
    kontrol(paste0("AS5_tumleyen_bias_", f, "_", g), max(abs(dilim$bias + dilim$bias[dilim$tumleyen])) < 1e-12)

    bolunme <- dilim[dilim$kanonik_bolme, ]   # her bölünme bir kez (1.716 satır)
    kontrol(paste0("AS5_bolunme_sayisi_", f, "_", g), nrow(bolunme) == choose(14, 7) / 2)

    # Ana ilişkiler (Spearman).
    rho_SB_alfa <- spearman(dilim$SB, dilim$alpha)            # 3.432 küme
    rho_CLb_rmse <- spearman(bolunme$CL_b, bolunme$rmse)      # 1.716 bölünme
    # Açıklayıcı ilişkiler: RMSE'nin iki bileşeni (RMSE^2 = yanlılık^2 + s_d^2).
    rho_CLb_sd <- spearman(bolunme$CL_b, bolunme$sd_d)
    rho_CLb_bias <- spearman(bolunme$CL_b, abs(bolunme$bias))

    as5_listesi[[paste0(f, "_", g)]] <- data.frame(subscale = f, grup = g, n_kume = nrow(dilim),
      n_bolunme = nrow(bolunme), rho_SB_alfa = rho_SB_alfa, rho_CLb_rmse = rho_CLb_rmse,
      rho_CLb_sd = rho_CLb_sd, rho_CLb_bias = rho_CLb_bias)

    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS5_rho_SB_alfa_", g, "_", f)]] <- rho_SB_alfa
    sonuc[[paste0("AS5_rho_CLb_rmse_", g, "_", f)]] <- rho_CLb_rmse
    if (g == "deg") {
      sonuc[[paste0("AS5_rho_CLb_sd_deg_", f)]] <- rho_CLb_sd
      sonuc[[paste0("AS5_rho_CLb_bias_deg_", f)]] <- rho_CLb_bias
    }
  }
}
as5_iliskiler <- do.call(rbind, as5_listesi); rownames(as5_iliskiler) <- NULL   # sıra: D kal, D deg, A kal, ...
csv_yaz(as5_iliskiler, "tablo_AS5_iliskiler.csv")
cat("\nAS5 özeti (bütün kümelerde Spearman ilişkileri):\n"); print(as5_iliskiler, row.names = FALSE, digits = 3)
log_yaz("AS5_HAZIR")

# (Şekil yardımcıları AS1 bölümünde tanımlandı.)
# ---- Şekil 2: AS5, alt küme testi (değerlendirme grubu) ----
deg_alt <- tum_alt[tum_alt$grup == "deg", ]
ust_ad <- function(f) paste0(alt_boyut_adi[f], ": SB ve alfa, rho = ", virgullu(sonuc[[paste0("AS5_rho_SB_alfa_deg_", f)]]))
alt_ad <- function(f) paste0(alt_boyut_adi[f], ": CL_b ve RMSE, rho = ", virgullu(sonuc[[paste0("AS5_rho_CLb_rmse_deg_", f)]]))
panel_sirasi <- c(vapply(alt_boyutlar, ust_ad, character(1)), vapply(alt_boyutlar, alt_ad, character(1)))
# Uzun biçim: üst satır bütün 3.432 küme (SB, alfa); alt satır yalnız kanonik 1.716 bölünme (CL_b, RMSE).
bulut <- rbind(
  data.frame(panel = vapply(deg_alt$subscale, ust_ad, character(1)), x = deg_alt$SB, y = deg_alt$alpha),
  data.frame(panel = vapply(deg_alt$subscale[deg_alt$kanonik_bolme], alt_ad, character(1)),
             x = deg_alt$CL_b[deg_alt$kanonik_bolme], y = deg_alt$rmse[deg_alt$kanonik_bolme]))
# Dört formun kendi satırları (her iki satır için).
form_noktalari <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  r <- deg_alt[deg_alt$subscale == f & deg_alt$subset_key == anahtar_yap(formlar[[form]][[f]]), ]
  rbind(data.frame(panel = ust_ad(f), x = r$SB, y = r$alpha, form = form),
        data.frame(panel = alt_ad(f), x = r$CL_b, y = r$rmse, form = form))
}))))
kontrol("SEKIL_form_noktalari", nrow(form_noktalari) == 24L)
bulut$panel <- factor(bulut$panel, levels = panel_sirasi)
form_noktalari$panel <- factor(form_noktalari$panel, levels = panel_sirasi)
form_noktalari$form <- factor(form_noktalari$form, levels = kisa_formlar)
sekil2 <- ggplot2::ggplot(bulut, ggplot2::aes(x = x, y = y)) +
  ggplot2::geom_point(colour = "grey75", size = 0.4, alpha = 0.6) +
  ggplot2::geom_point(data = form_noktalari, ggplot2::aes(shape = form, colour = form), size = 2.6, stroke = 0.9) +
  ggplot2::scale_shape_manual(values = c(PUB21 = 16, MIN21 = 17, MAX21 = 15, COV21 = 4)) +
  ggplot2::scale_colour_manual(values = c(PUB21 = "#1b6ca8", MIN21 = "#d1495b", MAX21 = "#edae49", COV21 = "#00798c")) +
  ggplot2::facet_wrap(~panel, nrow = 2, scales = "free") +
  ggplot2::scale_x_continuous(labels = eksen_virgul) + ggplot2::scale_y_continuous(labels = eksen_virgul) +
  ggplot2::labs(x = "Anlamsal gösterge (üst satır: SB, anlamsal genişlik; alt satır: CL_b, karşılıklı temsil kaybı)",
                y = "Psikometrik gösterge (üst satır: alfa; alt satır: RMSE)", shape = "Form", colour = "Form",
                caption = paste("Değerlendirme grubu. Gri noktalar: üst satırda 3.432 yedili küme, alt satırda 1.716 bölünme.",
                                "MIN21 ile MAX21 aynı bölünmenin iki yarısıdır; alt satırda üst üste düşer.", sep = "\n")) +
  ggplot2::theme_bw(base_size = 9) +
  ggplot2::theme(legend.position = "bottom", plot.background = ggplot2::element_rect(fill = "white", colour = NA))
ggplot2::ggsave(file.path(out, "sekil_AS5_alt_kume_testi.png"), sekil2, width = 10, height = 6.8, dpi = 300, bg = "white")
log_yaz("SEKILLER_HAZIR")

# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok ana sonuçların iki uygulama kararına DUYARLILIĞINI gösterir (tezin ekleri):
#   1. COV21 eşit çözümleri: En küçük CL'yi veren birden fazla küme olabilir; COV21 bunlar arasından madde
#      numarası sırasıyla ilki seçilmiştir. Başka bir eşit küme seçilseydi alfa ve RMSE ne olurdu?
#   2. Yanıt kalitesi (VCL): DASS arşivinde katılımcılara gerçek ve UYDURMA sözcüklerden oluşan bir liste
#      sorulmuştur. VCL6, VCL9 ve VCL12 uydurma sözcüklerdir; bunlardan en az birini "biliyorum" (1) diye
#      işaretleyen kayıt dikkatsiz yanıt vermiş olabilir. Bu kayıtlar çıkarılınca AS1, AS2, AS3 ve AS5'in
#      ana değerleri ne kadar değişir? Eksik değer tek başına dışlama nedeni değildir.
#
# Hangi veri hangi amaçla kullanılıyor?
#   tum_alt          : COV21 eşit çözümlerinin değerlendirme grubundaki alfa ve RMSE değerleri.
#   kal_ham, deg_ham : Ham arşiv satırları (kal ve deg ile aynı sırada); yalnız VCL sütunları için.
#   kal, deg         : Yanıtlar; VCL kuralıyla süzülüp modeller yeniden kestirilir.
#   sonuc            : Ana değerler buradan okunur (ör. sonuc$AS2_CFI_PUB21); ana nesneler değiştirilmez.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, "Ekler" bölümü)
#   COV21: kendi alfa ve RMSE değerinin eşit çözümler aralığındaki yeri yazılır.
#   VCL  : değişimlerin sayısal büyüklüğü (fark = dışlanmış değer - ana değer) ve form sıralarının korunup
#          korunmadığı yazılır. Birbirine çok yakın iki değerin sırası değişebilir; o zaman sıra değil,
#          değerler ve farkın büyüklüğü raporlanır. AS5'te iki grupta ve VCL sonrasında aynı yön görülürse
#          ilişki "tutarlı" sayılır.
#   Söylenmez: işaretlenen her kaydın geçersiz olduğu; çok yakın iki form arasındaki sıra değişiminin önemli
#          bir fark olduğu; denetlenmemiş "bütün sıralamalar korundu" gibi genellemeler.
#   Hangi tablo?: ek_COV21_esit_cozumler.csv, ek_VCL_orneklem.csv, ek_VCL_duyarlilik.csv.
# ---------------------------------------------------------------------------------------------

# ---- 1. COV21 eşit çözümleri (değerlendirme grubu) ----
ek_cov_listesi <- list()
for (f in alt_boyutlar) {
  dilim <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  esitler <- dilim[dilim$cov_esit_minimum, ]                                  # en küçük CL'yi veren kümeler
  cov_satiri <- dilim[dilim$subset_key == anahtar_yap(formlar$COV21[[f]]), ]   # COV21'in kendi satırı
  kontrol(paste0("EK_COV21_esitler_icinde_", f), nrow(cov_satiri) == 1L && cov_satiri$cov_esit_minimum)
  kontrol(paste0("EK_COV21_kume_sayisi_", f), nrow(esitler) == sonuc[[paste0("COV_esit_cozum_", f)]])
  ek_cov_listesi[[f]] <- data.frame(subscale = f, n_kume = nrow(esitler),
    alfa_min = min(esitler$alpha), alfa_max = max(esitler$alpha),
    rmse_min = min(esitler$rmse), rmse_max = max(esitler$rmse),
    COV21_alfa = cov_satiri$alpha, COV21_rmse = cov_satiri$rmse)
  sonuc[[paste0("EK_COV_alfa_min_", f)]] <- min(esitler$alpha)
  sonuc[[paste0("EK_COV_alfa_max_", f)]] <- max(esitler$alpha)
  sonuc[[paste0("EK_COV_rmse_min_", f)]] <- min(esitler$rmse)
  sonuc[[paste0("EK_COV_rmse_max_", f)]] <- max(esitler$rmse)
}
csv_yaz(do.call(rbind, ek_cov_listesi), "ek_COV21_esit_cozumler.csv")

# ---- 2. Yanıt kalitesi (VCL) duyarlılığı ----
# Dışlama kuralı: VCL6, VCL9, VCL12'den en az birinde değer 1. %in% kullanıldığı için eksik değer (NA)
# dışlama nedeni sayılmaz; n_eksik_vcl yalnız bilgi amaçlı sayılır.
vcl_isaretli <- function(ham) {
  V <- as.data.frame(lapply(ham[, cfg$vcl_uydurma], function(x) suppressWarnings(as.numeric(x))))
  list(dislan = apply(V, 1, function(v) any(v %in% 1)), eksik = apply(V, 1, anyNA))
}
vcl_kal <- vcl_isaretli(kal_ham); vcl_deg <- vcl_isaretli(deg_ham)
kal_v <- kal[!vcl_kal$dislan, , drop = FALSE]; deg_v <- deg[!vcl_deg$dislan, , drop = FALSE]
csv_yaz(data.frame(grup = c("kal", "deg"), n_ana = c(nrow(kal), nrow(deg)),
                   n_dislanan = c(sum(vcl_kal$dislan), sum(vcl_deg$dislan)),
                   n_kalan = c(nrow(kal_v), nrow(deg_v)),
                   n_eksik_vcl = c(sum(vcl_kal$eksik), sum(vcl_deg$eksik))), "ek_VCL_orneklem.csv")
sonuc$EK_VCL_dislanan_kal <- sum(vcl_kal$dislan)
sonuc$EK_VCL_dislanan_deg <- sum(vcl_deg$dislan)
log_yaz("EK_VCL", "dislanan kal:", sum(vcl_kal$dislan), "deg:", sum(vcl_deg$dislan))

# Duyarlılık satırlarını tek biçimde üreten yardımcı: deger = dışlanmış veriyle, ana_deger = sonuc listesinden.
vcl_satir <- function(soru, form, subscale, olcu, deger, ana_deger)
  data.frame(soru = soru, form = form, subscale = subscale, olcu = olcu, deger = deger,
             ana_deger = ana_deger, fark = deger - ana_deger, stringsAsFactors = FALSE)
ek_vcl <- list()

# (a) AS1: kalibrasyonda GRM yeniden; ISI ile a arasındaki Spearman.
for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]
  p <- grm_parameters(fit_grm(kal_v[, havuz, drop = FALSE]))
  p <- p[match(havuz, p$item_id), , drop = FALSE]
  kontrol(paste0("EK_VCL_AS1_sira_", f), identical(p$item_id, havuz))
  rho <- spearman(ISI[[f]][havuz], p$a)
  ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS1", "FULL42", f, "rho_ISI_a", rho, sonuc[[paste0("AS1_rho_kal_", f)]])
  sonuc[[paste0("EK_VCL_rho_kal_", f)]] <- rho
}

# (b) AS2: değerlendirmede dört kısa form için DFA yeniden; uyum, omega ve alfa.
for (form in kisa_formlar) {
  fit <- fit_cfa(deg_v, formlar[[form]])
  uyum <- lavaan::fitMeasures(fit, c("cfi.scaled", "rmsea.scaled", "srmr"))
  ana_uyum <- c(cfi.scaled = sonuc[[paste0("AS2_CFI_", form)]], rmsea.scaled = sonuc[[paste0("AS2_RMSEA_", form)]],
                srmr = sonuc[[paste0("AS2_SRMR_", form)]])
  for (olcu in names(ana_uyum))
    ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS2", form, NA, olcu, as.numeric(uyum[olcu]), ana_uyum[[olcu]])
  sonuc[[paste0("EK_VCL_CFI_", form)]] <- as.numeric(uyum["cfi.scaled"])
  om <- omega_values(fit, obs.var = FALSE)
  for (f in alt_boyutlar) {
    ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS2", form, f, "omega", as.numeric(om[f]),
                                               sonuc[[paste0("AS2_omega_", form, "_", f)]])
    ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS2", form, f, "alfa", alpha_raw(deg_v[, formlar[[form]][[f]]]),
                                               sonuc[[paste0("AS2_alfa_", form, "_", f)]])
    sonuc[[paste0("EK_VCL_omega_", form, "_", f)]] <- as.numeric(om[f])
  }
}

# (c) AS3: değerlendirmede dört kısa form ve üç alt boyut için yanlılık ve RMSE.
for (form in kisa_formlar) for (f in alt_boyutlar) {
  u <- uyum_olculeri(rowMeans(deg_v[, formlar[[form]][[f]]]), rowMeans(deg_v[, formlar$FULL42[[f]]]))
  ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS3", form, f, "bias", u[["bias"]], sonuc[[paste0("AS3_bias_", form, "_", f)]])
  ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS3", form, f, "rmse", u[["rmse"]], sonuc[[paste0("AS3_rmse_", form, "_", f)]])
  sonuc[[paste0("EK_VCL_rmse_", form, "_", f)]] <- u[["rmse"]]
}

# (d) AS5: dışlanmış değerlendirme grubunda aynı sabit kümelerle iki ana ilişki.
for (f in alt_boyutlar) {
  ps <- alt_kume_psikometrik(deg_v, formlar$FULL42[[f]], alt_kume[[f]]$subset_key)
  kontrol(paste0("EK_VCL_AS5_sira_", f), identical(ps$subset_key, alt_kume[[f]]$subset_key))
  kanonik <- alt_kume[[f]]$kanonik_bolme
  rho_sb <- spearman(alt_kume[[f]]$SB, ps$alpha)                    # 3.432 küme
  rho_clb <- spearman(alt_kume[[f]]$CL_b[kanonik], ps$rmse[kanonik])  # 1.716 bölünme
  ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS5", NA, f, "rho_SB_alfa", rho_sb, sonuc[[paste0("AS5_rho_SB_alfa_deg_", f)]])
  ek_vcl[[length(ek_vcl) + 1L]] <- vcl_satir("AS5", NA, f, "rho_CLb_rmse", rho_clb, sonuc[[paste0("AS5_rho_CLb_rmse_deg_", f)]])
  sonuc[[paste0("EK_VCL_AS5_SB_alfa_", f)]] <- rho_sb
  sonuc[[paste0("EK_VCL_AS5_CLb_rmse_", f)]] <- rho_clb
}
ek_vcl_tablo <- do.call(rbind, ek_vcl)
# YONERGE Kural 7: form içeren tablolarda önce form, sonra alt boyut. AS1 (FULL42) başta, AS5 (form yok) sonda;
# her formda önce uyum satırları (alt boyut yok), sonra her alt boyutta omega, alfa, yanlılık, RMSE.
olcu_sirasi <- c("rho_ISI_a", "cfi.scaled", "rmsea.scaled", "srmr", "omega", "alfa", "bias", "rmse", "rho_SB_alfa", "rho_CLb_rmse")
ek_vcl_tablo <- ek_vcl_tablo[order(match(ek_vcl_tablo$form, c("FULL42", kisa_formlar), nomatch = 99L),
                                   match(ek_vcl_tablo$subscale, alt_boyutlar, nomatch = 0L),
                                   match(ek_vcl_tablo$olcu, olcu_sirasi)), ]
rownames(ek_vcl_tablo) <- NULL
kontrol("EK_VCL_69_satir", nrow(ek_vcl_tablo) == 69L)
csv_yaz(ek_vcl_tablo, "ek_VCL_duyarlilik.csv")
cat("\nEK ANALİZLER özeti: COV21 eşit çözümleri\n"); print(do.call(rbind, ek_cov_listesi), row.names = FALSE, digits = 4)
cat("VCL: en büyük mutlak fark (ölçüye göre)\n")
print(tapply(abs(ek_vcl_tablo$fark), ek_vcl_tablo$olcu, max), digits = 3)
log_yaz("EK_ANALIZLER_HAZIR")

# ---- Sonuç: denetimler ve bütünleşik tablo ----------------------------------------
# Formların alt küme tablosundaki alfa ve RMSE değerleri, AS2 ve AS3'te ayrı yoldan hesaplanan değerlerle aynı olmalı.
for (form in kisa_formlar) for (f in alt_boyutlar) {
  y <- yuzdelik[yuzdelik$form == form & yuzdelik$subscale == f, ]
  kontrol(paste0("ALT_alfa_AS2_ile_ayni_", form, "_", f),
    abs(y$alfa - as2_guvenirlik$alfa[as2_guvenirlik$form == form & as2_guvenirlik$subscale == f]) < 1e-10)
  kontrol(paste0("ALT_rmse_AS3_ile_ayni_", form, "_", f),
    abs(y$rmse - as3_uyum$rmse[as3_uyum$form == form & as3_uyum$subscale == f]) < 1e-10)
}
# Adım 4. Bütünleşik tablo: omega (AS2) ile dört yüzdelik yan yana (tek puanda birleştirilmez).
butunlesik <- data.frame(form = yuzdelik$form, subscale = yuzdelik$subscale,
  omega = as2_guvenirlik$omega[match(paste(yuzdelik$form, yuzdelik$subscale),
                                     paste(as2_guvenirlik$form, as2_guvenirlik$subscale))],
  alfa_yzd = yuzdelik$alfa_yzd, rmse_yzd = yuzdelik$rmse_yzd, SB_yzd = yuzdelik$SB_yzd, CL_yzd = yuzdelik$CL_yzd)
csv_yaz(butunlesik, "tablo_butunlesik.csv"); print(butunlesik, row.names = FALSE, digits = 3)
csv_yaz(data.frame(anahtar = names(sonuc), deger = vapply(sonuc, function(v) as.numeric(v)[1], numeric(1)), row.names = NULL),
        "sonuc_degerleri.csv")
writeLines(capture.output(sessionInfo()), file.path(out, "oturum_bilgisi.txt"))
cat("Tamamlandı. İç denetim:", length(kontroller), "\n")

