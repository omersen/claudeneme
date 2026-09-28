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
