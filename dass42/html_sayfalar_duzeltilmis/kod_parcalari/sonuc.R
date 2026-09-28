# ---- Sonuç: bütünleşik tablo ---------------------------------------------------------
# Yeni hesap yapmaz; AS2, AS3 ve AS4'te üretilen değerleri form ve alt boyut satırlarında bir araya getirir.
anahtar_fs <- function(d) paste(d$form, d$subscale)
butunlesik <- yuzdelik[, c("form", "subscale")]
butunlesik$omega    <- as2_guvenirlik$omega[match(anahtar_fs(butunlesik), anahtar_fs(as2_guvenirlik))]
butunlesik$alfa_yzd <- yuzdelik$alfa_yzd
butunlesik$rmse_0_42 <- as3_uyum$rmse_0_42[match(anahtar_fs(butunlesik), anahtar_fs(as3_uyum))]
butunlesik$rmse_yzd <- yuzdelik$rmse_yzd
butunlesik$SB_yzd   <- yuzdelik$SB_yzd
butunlesik$CL_yzd   <- yuzdelik$CL_yzd
print(butunlesik, digits = 3)
write.csv(butunlesik, "html_ciktilari/butunlesik_tablo.csv", row.names = FALSE)
