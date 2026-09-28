# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Bu blok yeni bir hesap yapmaz; önceki blokların sonuçlarını iki şekille gösterir.
#   sekil_AS1_ISI_a.png         (AS1): Her alt boyutta 14 madde. x = ISI (madde metinlerinden),
#                                y = kalibrasyon grubundaki GRM ayırt ediciliği a (as1_parametreler).
#                                Noktalar madde kimlikleriyle etiketlidir; panel başlığında Spearman rho.
#   sekil_AS5_alt_kume_testi.png (AS5): Değerlendirme grubu (tum_alt). Üst satır: 3.432 kümede SB ile alfa;
#                                alt satır: 1.716 bölünmede CL_b ile RMSE. Gri noktalar bütün kümeler; dört
#                                form kendi satırlarındaki değerlerle ayrı şekil ve renkle işaretlidir.
#
# Nasıl okunur?
#   AS1 şekli: noktalar sağa doğru yükseliyorsa (pozitif rho), diğer maddelere anlamca daha benzer maddelerin
#     a değeri daha yüksek olma eğilimindedir. Tek tek maddeler (ör. en solda kalanlar) yorumu somutlaştırır;
#     14 noktaya dayanan bir betimlemedir, nedensellik göstermez.
#   AS5 şekli: üst satırda bulutun aşağı eğimi, çeşitlilik arttıkça alfanın düşme eğilimini; alt satırda yukarı
#     eğimi, iki yarının birbirini daha az temsil etmesiyle RMSE'nin artma eğilimini gösterir. Formların bulut
#     içindeki yeri, ALT KÜME TABLOSU'ndaki yüzdeliklerin görsel karşılığıdır. MIN21 ile MAX21 aynı bölünmenin
#     iki yarısı olduğu için alt satırda üst üste düşer; bu bir hata değildir (şeklin alt yazısında belirtilir).
#   Söylenmez: şekiller yordama iddiası, başarı eşiği veya "en iyi küme" seçimi için kullanılmaz.
# ---------------------------------------------------------------------------------------------
virgullu <- function(x, basamak = 2) sub(".", ",", formatC(x, format = "f", digits = basamak), fixed = TRUE)
alt_boyut_adi <- c(D = "Depresyon (D)", A = "Kaygı (A)", S = "Stres (S)")
eksen_virgul <- function(x) sub(".", ",", format(x, trim = TRUE), fixed = TRUE)   # eksenlerde ondalık virgül, eşit basamak

# ---- Şekil 1: AS1, ISI ile a (kalibrasyon grubu) ----
s1 <- as1_parametreler[as1_parametreler$grup == "kal", c("subscale", "item_id", "ISI", "a")]
s1$panel <- factor(paste0(alt_boyut_adi[s1$subscale], ", rho = ",
                          virgullu(unlist(sonuc[paste0("AS1_rho_kal_", s1$subscale)]))),
                   levels = paste0(alt_boyut_adi, ", rho = ", virgullu(unlist(sonuc[paste0("AS1_rho_kal_", alt_boyutlar)]))))
sekil1 <- ggplot2::ggplot(s1, ggplot2::aes(x = ISI, y = a)) +
  ggplot2::geom_point(size = 1.8, colour = "grey20") +
  ggplot2::geom_text(ggplot2::aes(label = item_id), size = 2.4, vjust = -0.8, colour = "grey30") +
  ggplot2::facet_wrap(~panel, nrow = 1, scales = "free_x") +
  ggplot2::scale_x_continuous(labels = eksen_virgul) + ggplot2::scale_y_continuous(labels = eksen_virgul) +
  ggplot2::labs(x = "ISI (alt boyuttaki diğer maddelerle ortalama kosinüs benzerliği)",
                y = "GRM ayırt edicilik (a), kalibrasyon grubu") +
  ggplot2::theme_bw(base_size = 9) +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = "white", colour = NA))
ggplot2::ggsave(file.path(out, "sekil_AS1_ISI_a.png"), sekil1, width = 9, height = 3.6, dpi = 300, bg = "white")
