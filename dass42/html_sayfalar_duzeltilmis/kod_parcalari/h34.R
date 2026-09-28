# ---- 3.4 Üç anlamsal seçim kuralı ve dört form ---------------------------------------
form_olustur <- function(Cm) {   # MIN21, MAX21 ve COV21 kurallarını verilen kosinüs matrisine uygular
  z <- list(ISI = list(), alt_kume = list(), MIN21 = list(), MAX21 = list(), COV21 = list())
  for (f in alt_boyutlar) {
    havuz <- item_id(key42[[f]]); Cf <- Cm[havuz, havuz]
    z$ISI[[f]] <- isi_values(Cf)
    z$MIN21[[f]] <- sort(rank_with_tolerance(z$ISI[[f]])[1:7])                      # ISI en düşük yedi madde
    z$MAX21[[f]] <- sort(rank_with_tolerance(z$ISI[[f]], decreasing = TRUE)[1:7])   # ISI en yüksek yedi madde
    ak <- alt_kume_anlamsal(Cf)                                                      # 3.432 kümenin SB, CL, CL_b
    esit <- which(abs(ak$CL - min(ak$CL)) <= tol); ak$cov_esit_minimum <- seq_len(nrow(ak)) %in% esit
    z$COV21[[f]] <- strsplit(sort(ak$subset_key[esit])[1], "|", fixed = TRUE)[[1]]   # CL en küçük küme
    z$alt_kume[[f]] <- ak
  }
  z
}
ana <- form_olustur(C)
formlar <- list(FULL42 = lapply(key42, item_id), PUB21 = lapply(key21, item_id),
                MIN21 = ana$MIN21, MAX21 = ana$MAX21, COV21 = ana$COV21)
ISI <- ana$ISI; alt_kume <- ana$alt_kume
anahtar_yap <- function(ids) paste(sort(ids), collapse = "|")
form_tablosu <- do.call(rbind, lapply(kisa_formlar, function(nm)
  data.frame(form = nm, subscale = alt_boyutlar,
             maddeler = sapply(alt_boyutlar, function(f) paste(formlar[[nm]][[f]], collapse = " ")),
             cov_esit_cozum = if (nm == "COV21") sapply(alt_boyutlar, function(f) sum(alt_kume[[f]]$cov_esit_minimum)) else NA)))
rownames(form_tablosu) <- NULL
print(form_tablosu)
write.csv(form_tablosu, "html_ciktilari/formlar.csv", row.names = FALSE)

# API ile üretilmiş vektörler kullanıldıysa: arşiv vektörleriyle kurulan formlarla ortak madde sayısı (7 üzerinden)
if (exists("E_api")) {
  ana_arsiv <- form_olustur(cosine_matrix(E_arsiv))
  api_form <- do.call(rbind, lapply(anlamsal_formlar, function(nm)
    data.frame(form = nm, t(sapply(alt_boyutlar, function(f) length(intersect(ana_arsiv[[nm]][[f]], formlar[[nm]][[f]])))))))
  print(api_form)                                                            # 7'den küçük değer: form arşivdekinden farklı
  write.csv(api_form, "html_ciktilari/api_arsiv_form_uyelik.csv", row.names = FALSE)
}
