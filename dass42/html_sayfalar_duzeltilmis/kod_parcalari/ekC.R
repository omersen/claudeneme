# ---- Ek C: yanıt kalitesi (VCL) duyarlılığı -----------------------------------------------
# Arşivdeki sözcük listesinde VCL6, VCL9 ve VCL12 uydurma sözcüklerdir. Bunlardan en az birini "biliyorum" (1)
# diye işaretleyen kayıtlar iki gruptan çıkarılır; AS1, AS2, AS3 ve AS5'in ana değerleri yeniden hesaplanır.
# Formlar, ISI ve bütün kümeler değişmez (bunlar yanıt verisi kullanmaz).
vcl_dislan <- apply(ham[secilen, c("VCL6", "VCL9", "VCL12")], 1, function(v) any(suppressWarnings(as.numeric(v)) %in% 1))
kal_v <- kal[!vcl_dislan[kal_sira], ]; deg_v <- deg[!vcl_dislan[deg_sira], ]
ekC_orneklem <- data.frame(grup = c("kal", "deg"), n_dislanan = c(sum(vcl_dislan[kal_sira]), sum(vcl_dislan[deg_sira])),
                           n_kalan = c(nrow(kal_v), nrow(deg_v)))
print(ekC_orneklem)
satir <- function(soru, form, f, olcu, deger, ana) data.frame(soru = soru, form = form, subscale = f, olcu = olcu,
                                                             deger = deger, ana_deger = ana, fark = deger - ana)
ekC <- list()
for (f in alt_boyutlar) {                                                    # AS1: kalibrasyon grubu
  havuz <- formlar$FULL42[[f]]; p <- grm_parameters(fit_grm(kal_v[, havuz])); p <- p[match(havuz, p$item_id), ]
  ekC[[length(ekC) + 1]] <- satir("AS1", "FULL42", f, "rho_ISI_a", spearman(ISI[[f]][havuz], p$a),
                                  as1_tablo$rho_ISI_a[as1_tablo$subscale == f & as1_tablo$grup == "kal"])
}
for (form in kisa_formlar) {                                                 # AS2 ve AS3: değerlendirme grubu
  om <- omega_values(fit_cfa(deg_v, formlar[[form]]))
  for (f in alt_boyutlar) {
    ana <- as2_guvenirlik[as2_guvenirlik$form == form & as2_guvenirlik$subscale == f, ]
    ekC[[length(ekC) + 1]] <- satir("AS2", form, f, "omega", as.numeric(om[f]), ana$omega)
    ekC[[length(ekC) + 1]] <- satir("AS2", form, f, "alfa", alpha_raw(deg_v[, formlar[[form]][[f]]]), ana$alfa)
    u <- uyum_olculeri(rowMeans(deg_v[, formlar[[form]][[f]]]), rowMeans(deg_v[, formlar$FULL42[[f]]]))
    ekC[[length(ekC) + 1]] <- satir("AS3", form, f, "rmse", u[["rmse"]],
                                    as3_uyum$rmse[as3_uyum$form == form & as3_uyum$subscale == f])
  }
}
for (f in alt_boyutlar) {                                                    # AS5: değerlendirme grubu
  ps <- alt_kume_psikometrik(deg_v, formlar$FULL42[[f]], alt_kume[[f]]$subset_key); kb <- alt_kume[[f]]$kanonik_bolme
  ana <- as5[as5$subscale == f & as5$grup == "deg", ]
  ekC[[length(ekC) + 1]] <- satir("AS5", NA, f, "rho_SB_alfa", spearman(alt_kume[[f]]$SB, ps$alpha), ana$rho_SB_alfa)
  ekC[[length(ekC) + 1]] <- satir("AS5", NA, f, "rho_CLb_rmse", spearman(alt_kume[[f]]$CL_b[kb], ps$rmse[kb]), ana$rho_CLb_rmse)
}
ekC <- do.call(rbind, ekC); rownames(ekC) <- NULL
ekC_ozet <- aggregate(cbind(en_buyuk_mutlak_fark = abs(fark)) ~ soru + olcu, data = ekC, FUN = max)
print(ekC_ozet, digits = 3)
write.csv(ekC_orneklem, "html_ciktilari/ekC_VCL_orneklem.csv", row.names = FALSE)
write.csv(ekC, "html_ciktilari/ekC_VCL_duyarlilik.csv", row.names = FALSE)
write.csv(ekC_ozet, "html_ciktilari/ekC_VCL_ozet.csv", row.names = FALSE)
