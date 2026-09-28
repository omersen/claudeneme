# ---- 3.1 Paketler, ayarlar ve tanım fonksiyonları ---------------------------------
# Bütün kodlar öğrenci paketinin klasöründe (berkcan_dass42) ve yukarıdan aşağıya sırayla çalıştırılır.
# Önerilen sürümler: R 4.5.3, lavaan 0.7-2, semTools 0.5-9, mirt 1.47, ggplot2; ayrıca digest ve jsonlite.
# httr2 yalnız 3.3'te vektörler API ile yeniden üretilecekse gerekir.
library(lavaan); library(semTools); library(mirt); library(ggplot2)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
dir.create("html_ciktilari", showWarnings = FALSE)

key42 <- list(D = c(3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42),   # DASS-42 alt boyutları
              A = c(2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41),
              S = c(1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39))
key21 <- list(D = c(3, 10, 17, 26, 31, 38, 42),                              # yayımlanmış DASS-21 (PUB21)
              A = c(2, 4, 20, 25, 28, 40, 41),
              S = c(6, 8, 12, 18, 22, 35, 39))
item_id <- function(x) sprintf("Q%02d", x)
alt_boyutlar <- c("D", "A", "S")
kisa_formlar <- c("PUB21", "MIN21", "MAX21", "COV21")
anlamsal_formlar <- c("MIN21", "MAX21", "COV21")
tol <- 1e-12                                                  # sayısal eşitlik toleransı

# Anlamsal göstergeler
cosine_matrix <- function(E) {
  nr <- sqrt(rowSums(E^2)); C <- tcrossprod(E / nr)
  C[C > 1] <- 1; C[C < -1] <- -1; diag(C) <- 1
  dimnames(C) <- list(rownames(E), rownames(E)); C
}
isi_values <- function(Cf) (rowSums(Cf) - diag(Cf)) / (nrow(Cf) - 1)   # ISI: diğer 13 maddeye ortalama kosinüs
rank_with_tolerance <- function(values, decreasing = FALSE) {           # eşitlikte küçük madde numarası önce
  z <- if (decreasing) -values else values
  kalan <- names(z)[order(z, names(z))]; sira <- character(0)
  while (length(kalan)) {
    grup <- kalan[z[kalan] <= z[kalan[1L]] + tol]
    sira <- c(sira, sort(grup)); kalan <- setdiff(kalan, grup)
  }
  sira
}
sirali_ortalama <- function(x) sum(sort(x)) / length(x)
anlamsal_olcu <- function(Cf, S) {   # SB, CL ve CL_b (14 maddelik havuz üzerinden)
  w <- Cf[S, S, drop = FALSE]; R <- setdiff(rownames(Cf), S)
  c(SB   = 1 - sirali_ortalama(w[upper.tri(w)]),                        # 1 - 21 çiftin ortalama kosinüsü
    CL   = sirali_ortalama(1 - apply(Cf[, S, drop = FALSE], 1L, max)),  # 14 maddenin en yakın seçili maddeye uzaklığı
    CL_b = sirali_ortalama(c(1 - apply(Cf[R, S, drop = FALSE], 1L, max),
                             1 - apply(Cf[S, R, drop = FALSE], 1L, max))))  # karşı yarıdaki en yakın maddeye uzaklık
}
alt_kume_anlamsal <- function(Cf) {   # 3.432 yedili kümenin tamamı
  pool <- sort(rownames(Cf)); kombin <- utils::combn(pool, 7)
  anahtar <- apply(kombin, 2, paste, collapse = "|")
  o <- order(anahtar); kombin <- kombin[, o, drop = FALSE]; anahtar <- anahtar[o]
  olc <- t(apply(kombin, 2, function(s) anlamsal_olcu(Cf, s)))
  tumleyen <- match(apply(kombin, 2, function(s) paste(setdiff(pool, s), collapse = "|")), anahtar)
  data.frame(subset_key = anahtar, SB = olc[, "SB"], CL = olc[, "CL"], CL_b = olc[, "CL_b"],
             tumleyen = tumleyen, kanonik_bolme = kombin[1, ] == pool[1], stringsAsFactors = FALSE)
}

# Psikometrik göstergeler
alt_kume_psikometrik <- function(X, pool, anahtarlar) {   # bütün kümeler için alfa, yanlılık, s_d, RMSE, r
  k <- 7; kumeler <- strsplit(anahtarlar, "|", fixed = TRUE)          # tamsayı toplamlarıyla (eşitlikler korunur)
  Xf <- as.matrix(X[, pool, drop = FALSE]); n <- nrow(Xf)
  G <- vapply(kumeler, function(s) as.numeric(pool %in% s), numeric(length(pool)))
  Ss <- Xf %*% G; U <- rowSums(Xf); Dt <- 2 * Ss - U                  # Dt / 14 = kısa ortalama - tam ortalama
  sD <- colSums(Dt); sD2 <- colSums(Dt^2); sS <- colSums(Ss); vS <- n * colSums(Ss^2) - sS^2
  vi <- n * colSums(Xf^2) - colSums(Xf)^2; sU <- sum(U); vU <- n * sum(U^2) - sU^2
  data.frame(subset_key = anahtarlar, alpha = k / (k - 1) * (1 - as.numeric(crossprod(G, vi)) / vS),
             bias = sD / (14 * n), sd_d = sqrt(n * sD2 - sD^2) / (14 * n), rmse = sqrt(sD2 / n) / 14,
             r = (n * colSums(Ss * U) - sS * sU) / sqrt(vS * vU), stringsAsFactors = FALSE)
}
midrank_percentile <- function(dagilim, deger)             # orta sıra yüzdeliği
  100 * (mean(dagilim < deger - tol) + 0.5 * mean(abs(dagilim - deger) <= tol))
alpha_raw <- function(X) { V <- stats::cov(as.matrix(X)); k <- ncol(V); k / (k - 1) * (1 - sum(diag(V)) / sum(V)) }
uyum_olculeri <- function(kisa, tam) {
  d <- kisa - tam
  c(r = stats::cor(kisa, tam), bias = mean(d), sd_d = sqrt(mean((d - mean(d))^2)), rmse = sqrt(mean(d^2)))
}
spearman <- function(x, y) stats::cor(x, y, method = "spearman")

# Modeller
fit_grm <- function(X) {
  mod <- mirt::mirt(X, 1, itemtype = "graded", SE = FALSE, verbose = FALSE,
                    technical = list(NCYCLES = 2000L), TOL = 1e-4)
  stopifnot(mirt::extract.mirt(mod, "converged")); mod
}
grm_parameters <- function(mod) {
  z <- mirt::coef(mod, IRTpars = TRUE, simplify = TRUE)$items
  data.frame(item_id = rownames(z), a = as.numeric(z[, "a"]), z[, setdiff(colnames(z), "a"), drop = FALSE],
             row.names = NULL)
}
q3_duzeltilmis <- function(mod) {   # ortalaması çıkarılmış Q3; yalnız üst üçgen kullanılır
  q <- mirt::residuals(mod, type = "Q3", verbose = FALSE); q - mean(q[upper.tri(q)])
}
fit_cfa <- function(X, form) {      # üç ilişkili faktörlü sıralı DFA (WLSMV)
  ids <- unlist(form, use.names = FALSE)
  model <- paste(vapply(names(form), function(f) paste(f, "=~", paste(form[[f]], collapse = " + ")), ""),
                 collapse = "\n")
  fit <- lavaan::cfa(model, data = X[, ids, drop = FALSE], ordered = ids, estimator = "WLSMV", std.lv = TRUE)
  stopifnot(lavaan::lavInspect(fit, "converged"), lavaan::lavInspect(fit, "post.check")); fit
}
omega_values <- function(fit, obs.var = FALSE) {
  z <- semTools::compRelSEM(fit, tau.eq = FALSE, ord.scale = TRUE, obs.var = obs.var)
  if (is.list(z)) z <- vapply(z[c("D", "A", "S")], as.numeric, numeric(1))
  z[c("D", "A", "S")]
}
