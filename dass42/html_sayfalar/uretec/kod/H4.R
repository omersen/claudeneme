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
