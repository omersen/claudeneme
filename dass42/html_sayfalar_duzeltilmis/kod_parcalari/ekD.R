# ---- Ek D: kategorik omeganın iki hesaplama biçimi ------------------------------------------
# Ana analizde obs.var = FALSE (payda modelin örtük yanıt varyansı). obs.var = TRUE paydada gözlenen
# polikorik matristen gelen varyansı kullanır; model uyumu kusursuz değilse iki değer ayrışabilir.
ekD <- do.call(rbind, lapply(c("FULL42", kisa_formlar), function(form) {
  a <- omega_values(dfa_fit[[form]], obs.var = FALSE); b <- omega_values(dfa_fit[[form]], obs.var = TRUE)
  data.frame(form = form, subscale = alt_boyutlar, omega_model = as.numeric(a), omega_gozlenen = as.numeric(b),
             fark = as.numeric(b - a))
}))
rownames(ekD) <- NULL
print(ekD, digits = 3)
write.csv(ekD, "html_ciktilari/ekD_omega_obsvar.csv", row.names = FALSE)
