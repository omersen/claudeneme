# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 5 (AS5): DASS-42'nin her alt boyutundan seçilebilecek bütün yedili madde
#   kümelerinde, anlamsal çeşitlilik ve temsil ile puan güvenirliği ve tam form puanlarıyla uyum
#   arasında nasıl bir ilişki vardır?
#   AS5, ilk sonuçlar görüldükten sonra eklenmiş KEŞFEDİCİ bir sorudur; bulguları betimseldir.
#   "Alt küme testi" adı çıkarımsal bir hipotez testi değil, bütün olası kümelerin karşılaştırmasıdır.
#
# Hangi veri hangi amaçla kullanılıyor?
#   tum_alt : ALT KÜME TABLOSU bloğunda hazırlanan tablo. Her alt boyut ve grup için 3.432 kümenin
#             anlamsal değerleri (SB, CL_b; yalnız madde metinlerinden) ve psikometrik değerleri (alpha,
#             rmse, sd_d, bias; yanıtlardan) yan yanadır. Ana analiz değerlendirme (deg), tekrar
#             kalibrasyon (kal) grubundadır.
#   İki ana ilişki:
#     SB - alfa   : birim 3.432 küme. Seçilen maddeler çeşitlendikçe iç tutarlılık ne olur?
#     CL_b - RMSE : birim 1.716 bölünme. RMSE bir küme ile tümleyeninde (kalan 7 madde) aynıdır; bu yüzden
#                   bölünmenin özelliğidir ve bölünme düzeyindeki karşılıklı temsil kaybı (CL_b) ile
#                   eşleştirilir. Her bölünme bir kez sayılır (kanonik_bolme == TRUE). İki kez saymak
#                   katsayıyı değiştirmez; bu tercih analiz biriminin doğru raporlanması içindir.
#   Açıklayıcı ilişkiler (yalnız deg anahtarları): CL_b - s_d ve CL_b - |yanlılık|. RMSE'nin hangi
#   bileşeniyle (kişi düzeyindeki dağılım mı, ortalama kayma mı) daha çok ilişkili olduğunu gösterir.
#
# Nasıl yorumlanır? (ANALIZ_REHBERI.md, AS5 bölümü ve genel yorum kuralları)
#   rho_SB_alfa < 0 : bu havuzda çeşitlilik arttıkça iç tutarlılık düşme eğilimindedir.
#   rho_CLb_rmse > 0: iki yarının birbirini anlamsal olarak temsil etmesi zayıfladıkça tam form puanından
#                     sapma artma eğilimindedir.
#   |rho| < 0,30 zayıf, 0,30-0,50 orta, 0,50 ve üstü güçlü diye adlandırılır (başarı eşiği değildir).
#   İki grupta (ve EK ANALİZLER'deki yanıt kalitesi taramasından sonra) aynı yön görülürse ilişki tutarlı sayılır.
#   Söylenmez: "metin psikometrik sonucu öngörüyor" gibi bir yordama iddiası, başarı eşiği, yeni madde
#   havuzlarına genelleme, nedensellik. Kümeler ortak maddeler içerdiği için bağımsız değildir; p değeri
#   ve aralık verilmez. CL_b hangi yarının tutulacağını söylemez. Dağılımdan en iyi görünen küme seçilerek
#   beşinci bir form önerilmez.
#   Hangi tablo?: tablo_AS5_iliskiler.csv (şekil ŞEKİLLER bloğunda üretilir).
# ---------------------------------------------------------------------------------------------
as5_listesi <- list()
for (f in alt_boyutlar) {
  for (g in c("kal", "deg")) {
    # Bu alt boyut ve grubun 3.432 satırlık dilimi; satır sırası alt_kume[[f]] ile aynı olmalı, çünkü
    # tumleyen sütunu o sıradaki satır numarasıdır (yalnız bu dilim içinde kullanılır).
    dilim <- tum_alt[tum_alt$subscale == f & tum_alt$grup == g, ]
    kontrol(paste0("AS5_dilim_sirasi_", f, "_", g), identical(dilim$subset_key, alt_kume[[f]]$subset_key))

    # Denetim: her kümenin RMSE'si tümleyeninin RMSE'sine eşit, yanlılığı ters işaretli olmalı.
    kontrol(paste0("AS5_tumleyen_rmse_", f, "_", g), max(abs(dilim$rmse - dilim$rmse[dilim$tumleyen])) < 1e-12)
    kontrol(paste0("AS5_tumleyen_bias_", f, "_", g), max(abs(dilim$bias + dilim$bias[dilim$tumleyen])) < 1e-12)

    bolunme <- dilim[dilim$kanonik_bolme, ]   # her bölünme bir kez (1.716 satır)
    kontrol(paste0("AS5_bolunme_sayisi_", f, "_", g), nrow(bolunme) == choose(14, 7) / 2)

    # Ana ilişkiler (Spearman).
    rho_SB_alfa <- spearman(dilim$SB, dilim$alpha)            # 3.432 küme
    rho_CLb_rmse <- spearman(bolunme$CL_b, bolunme$rmse)      # 1.716 bölünme
    # Açıklayıcı ilişkiler: RMSE'nin iki bileşeni (RMSE^2 = yanlılık^2 + s_d^2).
    rho_CLb_sd <- spearman(bolunme$CL_b, bolunme$sd_d)
    rho_CLb_bias <- spearman(bolunme$CL_b, abs(bolunme$bias))

    as5_listesi[[paste0(f, "_", g)]] <- data.frame(subscale = f, grup = g, n_kume = nrow(dilim),
      n_bolunme = nrow(bolunme), rho_SB_alfa = rho_SB_alfa, rho_CLb_rmse = rho_CLb_rmse,
      rho_CLb_sd = rho_CLb_sd, rho_CLb_bias = rho_CLb_bias)

    # sonuc listesine yalnız hesaplanan nesneler atanır.
    sonuc[[paste0("AS5_rho_SB_alfa_", g, "_", f)]] <- rho_SB_alfa
    sonuc[[paste0("AS5_rho_CLb_rmse_", g, "_", f)]] <- rho_CLb_rmse
    if (g == "deg") {
      sonuc[[paste0("AS5_rho_CLb_sd_deg_", f)]] <- rho_CLb_sd
      sonuc[[paste0("AS5_rho_CLb_bias_deg_", f)]] <- rho_CLb_bias
    }
  }
}
as5_iliskiler <- do.call(rbind, as5_listesi); rownames(as5_iliskiler) <- NULL   # sıra: D kal, D deg, A kal, ...
csv_yaz(as5_iliskiler, "tablo_AS5_iliskiler.csv")
cat("\nAS5 özeti (bütün kümelerde Spearman ilişkileri):\n"); print(as5_iliskiler, row.names = FALSE, digits = 3)
log_yaz("AS5_HAZIR")
