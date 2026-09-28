# Analiz tablolarını danışman başvuru çıktısıyla (ref06) karşılaştırır.
# Kullanım: Rscript karsilastir_as1_ref06.R <AS1 çalıştırma klasörü> <ref06 klasörü>
# YZ_ISTEMLERI.md'nin son bölümündeki karşılaştırma koduna dayanır; yalnız tablo_* ve tum_alt_kumeler.csv dosyalarını okur.
args <- commandArgs(trailingOnly = TRUE)
a_klasor <- args[1]; b_klasor <- args[2]
stopifnot(dir.exists(a_klasor), dir.exists(b_klasor))
dosyalar <- grep("^(tablo_|tum_alt_kumeler)", intersect(list.files(a_klasor, "\\.csv$"), list.files(b_klasor, "\\.csv$")), value = TRUE)
karsilastir <- function(d) {
  a <- read.csv(file.path(a_klasor, d)); b <- read.csv(file.path(b_klasor, d))
  if (!identical(dim(a), dim(b)) || !identical(names(a), names(b)))
    return(data.frame(dosya = d, durum = "yapi farkli", en_buyuk_fark = NA))
  m <- !(vapply(a, is.numeric, logical(1)) & vapply(b, is.numeric, logical(1)))   # sayısal olmayan sütunlar
  A <- as.matrix(a[!m]); B <- as.matrix(b[!m])
  fark <- if (any(!m)) suppressWarnings(max(abs(A - B), 0, na.rm = TRUE)) else 0
  durum <- c(if (!identical(a[m], b[m])) "metin farkli", if (!identical(is.na(A), is.na(B))) "eksik deger farkli",
             if (fark > 1e-8) "sayisal fark")
  data.frame(dosya = d, durum = if (length(durum)) paste(durum, collapse = " + ") else "ayni (satir sirasi dahil)",
             en_buyuk_fark = fark)
}
print(do.call(rbind, lapply(dosyalar, karsilastir)), row.names = FALSE)
