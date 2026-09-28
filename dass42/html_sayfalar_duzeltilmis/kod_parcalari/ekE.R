# ---- Ek E: alfa farkları için eşleştirilmiş bootstrap -----------------------------------------
# Yeni hesap yapmaz; AS3'teki 2.000 bootstrap tekrarında hesaplanan alfa farklarını (anlamsal form eksi PUB21) yazar.
ekE <- boot_tablo[boot_tablo$olcu == "alfa", ]
print(ekE, digits = 3)
write.csv(ekE, "html_ciktilari/ekE_alfa_bootstrap.csv", row.names = FALSE)
