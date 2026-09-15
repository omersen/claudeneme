# =============================================================================
# 06_exhaustive_reference.R
# Kucuk karsilastirma: her alt boyutta 3.432 olasi yedili kume icin dogrulama yarisinda
#   - ham alfa
#   - tam alt boyut puanina gore ham RMSE ve yanlilik
#   - kisa form ile disarida kalan 7 maddenin korelasyonu (ortak madde yok)
# Secilen dort formun bu dagilimdaki orta sira yuzdelikleri raporlanir.
# Bu konumlar betimseldir; p degeri degildir ve madde secimi icin kullanilmaz.
# =============================================================================
log_event("STAGE", "exhaustive response-based reference for all seven-item subsets")

# Kovaryans ve ortalamalardan hizli hesap: her aday icin agirlik vektoru w
#   kisa ortalama - tam ortalama = w'x, w = 1/7 (secili) - 1/14 (hepsi)
exhaustive_response_metrics <- function(X, candidates) {
  X <- as.matrix(X); n <- nrow(X); pnum <- ncol(X)
  V <- stats::cov(X) * (n - 1) / n          # N paydali ikinci moment
  mu <- colMeans(X)
  t(apply(candidates, 2, function(ids) {
    rest <- setdiff(colnames(X), ids)
    w <- rep(-1 / pnum, pnum); names(w) <- colnames(X)
    w[ids] <- w[ids] + 1 / length(ids)
    bias <- sum(w * mu)
    mse  <- as.numeric(t(w) %*% V %*% w) + bias^2
    ws <- rep(0, pnum); names(ws) <- colnames(X); ws[ids] <- 1 / length(ids)
    wr <- rep(0, pnum); names(wr) <- colnames(X); wr[rest] <- 1 / length(rest)
    cov_sr <- as.numeric(t(ws) %*% V %*% wr)
    var_s <- as.numeric(t(ws) %*% V %*% ws); var_r <- as.numeric(t(wr) %*% V %*% wr)
    Vs <- stats::cov(X[, ids, drop = FALSE])
    c(alpha_raw = alpha_raw(X[, ids, drop = FALSE]), raw_bias = bias, raw_RMSE = sqrt(max(mse, 0)),
      r_short_remaining = cov_sr / sqrt(var_s * var_r), mean_interitem_r = mean_interitem_r(X[, ids, drop = FALSE]))
  }))
}

all_rows <- pos_rows <- list()
for (f in names(key42)) {
  pool <- forms$FULL42[[f]]; Xf <- p$val[, pool, drop = FALSE]
  candidates <- utils::combn(sort(pool), items_per_subscale)
  keys <- apply(candidates, 2, paste, collapse = "|")
  m <- exhaustive_response_metrics(Xf, candidates)
  dist <- data.frame(subscale = f, subset_key = keys, m, stringsAsFactors = FALSE)
  # Anlamsal tablodaki ayni anahtarla birlestir
  sem_sub <- sel$subsets[sel$subsets$subscale == f, c("subset_key", "SB", "CL_dropped", "CL_max")]
  dist <- merge(dist, sem_sub, by = "subset_key", sort = FALSE)
  all_rows[[f]] <- dist
  for (nm in short_forms) {
    key <- paste(sort(forms[[nm]][[f]]), collapse = "|")
    row <- dist[match(key, dist$subset_key), ]
    check(paste0("exhaustive_matches_direct_", f, "_", nm),
          abs(row$alpha_raw - alpha_raw(Xf[, forms[[nm]][[f]], drop = FALSE])) < 1e-10 &&
            abs(row$raw_RMSE - sqrt(mean((rowMeans(Xf[, forms[[nm]][[f]], drop = FALSE]) - rowMeans(Xf))^2))) < 1e-10)
    pos_rows[[paste(f, nm)]] <- data.frame(
      subscale = f, form = nm, alpha_raw = row$alpha_raw, raw_RMSE = row$raw_RMSE,
      r_short_remaining = row$r_short_remaining,
      alpha_percentile = midrank_percentile(dist$alpha_raw, row$alpha_raw),
      RMSE_percentile = midrank_percentile(dist$raw_RMSE, row$raw_RMSE),
      r_remaining_percentile = midrank_percentile(dist$r_short_remaining, row$r_short_remaining),
      alpha_preferred = "higher", RMSE_preferred = "lower", r_remaining_preferred = "higher",
      note = "descriptive midrank position among all 3432 seven-item subsets; not a p value")
  }
}
csv_out(do.call(rbind, all_rows), "REF_all_subsets_response_and_semantic.csv")
csv_out(do.call(rbind, pos_rows), "REF_selected_form_positions.csv")
log_event("EXHAUSTIVE_REFERENCE_COMPLETE")
