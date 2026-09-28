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
