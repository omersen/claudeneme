# =============================================================================
# 00_functions.R
# Ortak yardimci fonksiyonlar. Hicbir analiz burada calistirilmaz.
# =============================================================================

# --- Kayit ve kontrol ---------------------------------------------------------
csv_out <- function(x, name) {
  utils::write.csv(x, file.path(out, name), row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
log_event <- function(...) {
  msg <- paste(..., collapse = " ")
  line <- paste(format(Sys.time(), tz = "UTC", usetz = TRUE), msg)
  cat(line, "\n")
  cat(line, "\n", file = file.path(out, "analysis_log.txt"), append = TRUE)
}
logged <- function(expr) {
  withCallingHandlers(expr, warning = function(w) {
    log_event("WARNING", conditionMessage(w)); invokeRestart("muffleWarning")
  })
}
check <- function(name, condition, detail = "") {
  ok <- isTRUE(condition)
  checks[[length(checks) + 1L]] <<- data.frame(check = name, passed = ok, detail = detail,
                                               stringsAsFactors = FALSE)
  csv_out(do.call(rbind, checks), "validation_checks.csv")
  if (!ok) stop("CHECK FAILED: ", name, " ", detail, call. = FALSE)
  invisible(TRUE)
}
has_pkg <- function(p) requireNamespace(p, quietly = TRUE)

# --- Metin ----------------------------------------------------------------------
normalise_text <- function(x) {
  x <- gsub("&#39;|&apos;", "'", x)
  x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE)
  trimws(gsub("[[:space:]]+", " ", enc2utf8(x)))
}
word_count <- function(x) vapply(strsplit(trimws(x), "[[:space:]]+"), length, integer(1))

# --- Anlamsal geometri -----------------------------------------------------------
cosine_matrix <- function(E) {
  if (!is.matrix(E) || !is.numeric(E) || any(!is.finite(E)))
    stop("Gomme matrisi sayisal ve sonlu olmali.")
  nr <- sqrt(rowSums(E^2))
  if (any(nr <= 0)) stop("Sifir normlu gomme vektoru.")
  C <- tcrossprod(E / nr)
  C[C > 1] <- 1; C[C < -1] <- -1; diag(C) <- 1
  dimnames(C) <- list(rownames(E), rownames(E))
  C
}

# ISI: maddenin ayni alt boyuttaki diger maddelerle ortalama kosinus benzerligi
isi_values <- function(Cf) (rowSums(Cf) - diag(Cf)) / (nrow(Cf) - 1)

# Toleransli siralama: esit degerler sozluk sirasiyla cozulur
rank_with_tolerance <- function(values, decreasing = FALSE, tolerance = cfg$semantic_tolerance) {
  z <- if (decreasing) -values else values
  remaining <- names(z)[order(z, names(z))]
  result <- character(0)
  while (length(remaining)) {
    anchor <- z[remaining[1L]]
    group <- remaining[z[remaining] <= anchor + tolerance]
    result <- c(result, sort(group))
    remaining <- setdiff(remaining, group)
  }
  result
}

# Form duzeyi anlamsal gostergeler (alt boyut havuzu icinde)
#   MIISS      : secili maddeler arasi ortalama ikili kosinus benzerligi
#   SB         : 1 - MIISS (anlamsal cesitlilik; MIISS'in dogrusal donusumu)
#   CL_dropped : disarida kalan her maddenin en yakin secili maddeye kosinus uzakliginin ortalamasi (ANA)
#   CL_all     : ayni ortalama, secili maddeler sifir uzaklikla dahil (yardimci)
#   CL_max     : disarida kalan maddeler icinde en kotu kapsanan maddenin uzakligi
semantic_metrics <- function(Cf, selected) {
  pool <- rownames(Cf)
  if (!all(selected %in% pool) || length(selected) < 2L) stop("Gecersiz anlamsal alt kume.")
  within  <- Cf[selected, selected, drop = FALSE]
  nearest <- 1 - apply(Cf[, selected, drop = FALSE], 1L, max)
  dropped <- setdiff(pool, selected)
  miiss <- mean(within[upper.tri(within)])
  c(MIISS = miiss, SB = 1 - miiss,
    CL_dropped = if (length(dropped)) mean(nearest[dropped]) else 0,
    CL_all = mean(nearest),
    CL_max = if (length(dropped)) max(nearest[dropped]) else 0)
}

# Orta sira yuzdeligi: kucuk degerlerin orani + esitlerin yarisi
midrank_percentile <- function(null, observed, tolerance = cfg$semantic_tolerance) {
  100 * (mean(null < observed - tolerance) + 0.5 * mean(abs(null - observed) <= tolerance))
}
jaccard <- function(a, b) length(intersect(a, b)) / length(union(a, b))

# --- Klasik psikometri ----------------------------------------------------------
alpha_raw <- function(X) {
  V <- stats::cov(as.matrix(X)); k <- ncol(V)
  if (!is.finite(sum(V)) || sum(V) <= 0) return(NA_real_)
  k / (k - 1) * (1 - sum(diag(V)) / sum(V))
}
citc_values <- function(X) {
  X <- as.matrix(X)
  vapply(seq_len(ncol(X)), function(j) stats::cor(X[, j], rowSums(X[, -j, drop = FALSE])), numeric(1))
}
mean_interitem_r <- function(X) {
  R <- stats::cor(as.matrix(X)); mean(R[upper.tri(R)])
}
spearman <- function(x, y) stats::cor(x, y, method = "spearman")
# Kismi Spearman: r_xy.z, sira korelasyonlarindan
partial_spearman <- function(x, y, z) {
  rxy <- spearman(x, y); rxz <- spearman(x, z); ryz <- spearman(y, z)
  (rxy - rxz * ryz) / sqrt((1 - rxz^2) * (1 - ryz^2))
}
score_stats <- function(short, full) {
  stopifnot(length(short) == length(full), all(is.finite(short)), all(is.finite(full)))
  ms <- mean(short); mf <- mean(full)
  vs <- mean((short - ms)^2); vf <- mean((full - mf)^2)
  cv <- mean((short - ms) * (full - mf)); den <- vs + vf + (ms - mf)^2
  c(r = stats::cor(short, full), rho = spearman(short, full),
    CCC = if (den > 0) 2 * cv / den else NA_real_, bias = ms - mf,
    RMSE = sqrt(mean((short - full)^2)), nRMSE = sqrt(mean((short - full)^2)) / stats::sd(full))
}

# --- Ordinal DFA ve omega -----------------------------------------------------
cfa_syntax <- function(form) paste(vapply(names(form), function(f)
  paste(f, "=~", paste(form[[f]], collapse = " + ")), character(1)), collapse = "\n")
fit_cfa <- function(X, form) {
  ids <- unlist(form, use.names = FALSE)
  fit <- logged(lavaan::cfa(cfa_syntax(form), data = X[, ids, drop = FALSE], ordered = ids,
                            estimator = "WLSMV", std.lv = TRUE))
  if (!isTRUE(lavaan::lavInspect(fit, "converged"))) stop("DFA yakinsamadi.")
  if (!isTRUE(logged(lavaan::lavInspect(fit, "post.check")))) stop("DFA uygunsuz cozum.")
  fit
}
omega_values <- function(fit, obs.var = FALSE) {
  z <- logged(semTools::compRelSEM(fit, ord.scale = TRUE, obs.var = obs.var))
  if (is.list(z)) z <- vapply(z[c("D", "A", "S")], as.numeric, numeric(1))
  if (!is.numeric(z) || !all(c("D", "A", "S") %in% names(z))) stop("compRelSEM sonucu beklenmedik.")
  z[c("D", "A", "S")]
}
polychoric_matrix <- function(X, ids) {
  R <- as.matrix(logged(lavaan::lavCor(X[, ids, drop = FALSE], ordered = ids, output = "cor")))
  dimnames(R) <- list(ids, ids)
  R
}

# --- GRM (mirt kuruluysa) -----------------------------------------------------------
fit_grm <- function(X) {
  if (anyNA(X) || any(vapply(X, function(z) length(unique(z)), integer(1)) != 4L))
    stop("GRM icin her maddede dort kategori gerekli.")
  mod <- logged(mirt::mirt(X, 1, itemtype = "graded", SE = FALSE, verbose = FALSE,
                           technical = list(NCYCLES = 2000L), TOL = 1e-4))
  if (!isTRUE(mirt::extract.mirt(mod, "converged"))) stop("GRM yakinsamadi.")
  pp <- grm_parameters(mod)
  if (any(!is.finite(pp$a)) || any(pp$a <= 0)) stop("GRM gecersiz ayirt edicilik.")
  mod
}
grm_parameters <- function(mod) {
  z <- mirt::coef(mod, IRTpars = TRUE, simplify = TRUE)$items
  an <- intersect(c("a", "a1"), colnames(z))[1]
  if (is.na(an) || any(!is.finite(z))) stop("Gecersiz GRM parametreleri.")
  data.frame(item_id = rownames(z), a = as.numeric(z[, an]),
             z[, setdiff(colnames(z), an), drop = FALSE], row.names = NULL)
}
information <- function(mod, ids, pool) {
  ix <- match(ids, pool); stopifnot(!anyNA(ix))
  as.numeric(mirt::testinfo(mod, Theta = matrix(cfg$theta, ncol = 1), which.items = ix))
}
weighted_info <- function(I) {
  take <- cfg$theta >= cfg$info_lower & cfg$theta <= cfg$info_upper
  sum(I[take] * stats::dnorm(cfg$theta[take])) / sum(stats::dnorm(cfg$theta[take]))
}
eap_fixed <- function(mod, X, selected) {
  masked <- X; masked[, setdiff(names(X), selected)] <- NA_real_
  z <- as.matrix(logged(mirt::fscores(mod, method = "EAP", response.pattern = masked,
                                      full.scores = TRUE, full.scores.SE = TRUE, verbose = FALSE)))
  if (nrow(z) != nrow(X) || ncol(z) < 2L || any(!is.finite(z[, 1:2]))) stop("Gecersiz EAP puanlari.")
  data.frame(theta = z[, 1], posterior_sd = z[, 2])
}
grm_diagnostics <- function(mod, label) {
  z <- tryCatch(logged(mirt::M2(mod, type = "C2")), error = function(e) {
    log_event(label, "C2_FAILED", conditionMessage(e)); NULL })
  q <- tryCatch(logged(mirt::residuals(mod, type = "Q3", verbose = FALSE)), error = function(e) {
    log_event(label, "Q3_FAILED", conditionMessage(e)); NULL })
  if (!is.null(z)) csv_out(data.frame(z), paste0("diagnostic_", label, "_C2.csv"))
  if (!is.null(q)) csv_out(data.frame(item_id = rownames(q), q), paste0("diagnostic_", label, "_Q3.csv"))
  aq <- if (!is.null(q)) q[upper.tri(q)] - mean(q[upper.tri(q)]) else NA_real_
  maxq <- if (all(is.na(aq))) NA_real_ else max(aq, na.rm = TRUE)
  data.frame(model = label, max_adjusted_Q3 = maxq, review_Q3_above_020 = is.na(maxq) || maxq > 0.20,
             C2_available = !is.null(z),
             C2 = if (!is.null(z)) as.numeric(z$M2) else NA_real_,
             C2_df = if (!is.null(z)) as.numeric(z$df) else NA_real_,
             C2_p = if (!is.null(z)) as.numeric(z$p) else NA_real_,
             C2_RMSEA = if (!is.null(z)) as.numeric(z$RMSEA) else NA_real_,
             C2_SRMSR = if (!is.null(z)) as.numeric(z$SRMSR) else NA_real_)
}
