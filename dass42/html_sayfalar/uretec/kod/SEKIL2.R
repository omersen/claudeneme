# (Şekil yardımcıları AS1 bölümünde tanımlandı.)
# ---- Şekil 2: AS5, alt küme testi (değerlendirme grubu) ----
deg_alt <- tum_alt[tum_alt$grup == "deg", ]
ust_ad <- function(f) paste0(alt_boyut_adi[f], ": SB ve alfa, rho = ", virgullu(sonuc[[paste0("AS5_rho_SB_alfa_deg_", f)]]))
alt_ad <- function(f) paste0(alt_boyut_adi[f], ": CL_b ve RMSE, rho = ", virgullu(sonuc[[paste0("AS5_rho_CLb_rmse_deg_", f)]]))
panel_sirasi <- c(vapply(alt_boyutlar, ust_ad, character(1)), vapply(alt_boyutlar, alt_ad, character(1)))
# Uzun biçim: üst satır bütün 3.432 küme (SB, alfa); alt satır yalnız kanonik 1.716 bölünme (CL_b, RMSE).
bulut <- rbind(
  data.frame(panel = vapply(deg_alt$subscale, ust_ad, character(1)), x = deg_alt$SB, y = deg_alt$alpha),
  data.frame(panel = vapply(deg_alt$subscale[deg_alt$kanonik_bolme], alt_ad, character(1)),
             x = deg_alt$CL_b[deg_alt$kanonik_bolme], y = deg_alt$rmse[deg_alt$kanonik_bolme]))
# Dört formun kendi satırları (her iki satır için).
form_noktalari <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  r <- deg_alt[deg_alt$subscale == f & deg_alt$subset_key == anahtar_yap(formlar[[form]][[f]]), ]
  rbind(data.frame(panel = ust_ad(f), x = r$SB, y = r$alpha, form = form),
        data.frame(panel = alt_ad(f), x = r$CL_b, y = r$rmse, form = form))
}))))
kontrol("SEKIL_form_noktalari", nrow(form_noktalari) == 24L)
bulut$panel <- factor(bulut$panel, levels = panel_sirasi)
form_noktalari$panel <- factor(form_noktalari$panel, levels = panel_sirasi)
form_noktalari$form <- factor(form_noktalari$form, levels = kisa_formlar)
sekil2 <- ggplot2::ggplot(bulut, ggplot2::aes(x = x, y = y)) +
  ggplot2::geom_point(colour = "grey75", size = 0.4, alpha = 0.6) +
  ggplot2::geom_point(data = form_noktalari, ggplot2::aes(shape = form, colour = form), size = 2.6, stroke = 0.9) +
  ggplot2::scale_shape_manual(values = c(PUB21 = 16, MIN21 = 17, MAX21 = 15, COV21 = 4)) +
  ggplot2::scale_colour_manual(values = c(PUB21 = "#1b6ca8", MIN21 = "#d1495b", MAX21 = "#edae49", COV21 = "#00798c")) +
  ggplot2::facet_wrap(~panel, nrow = 2, scales = "free") +
  ggplot2::scale_x_continuous(labels = eksen_virgul) + ggplot2::scale_y_continuous(labels = eksen_virgul) +
  ggplot2::labs(x = "Anlamsal gösterge (üst satır: SB, anlamsal genişlik; alt satır: CL_b, karşılıklı temsil kaybı)",
                y = "Psikometrik gösterge (üst satır: alfa; alt satır: RMSE)", shape = "Form", colour = "Form",
                caption = paste("Değerlendirme grubu. Gri noktalar: üst satırda 3.432 yedili küme, alt satırda 1.716 bölünme.",
                                "MIN21 ile MAX21 aynı bölünmenin iki yarısıdır; alt satırda üst üste düşer.", sep = "\n")) +
  ggplot2::theme_bw(base_size = 9) +
  ggplot2::theme(legend.position = "bottom", plot.background = ggplot2::element_rect(fill = "white", colour = NA))
ggplot2::ggsave(file.path(out, "sekil_AS5_alt_kume_testi.png"), sekil2, width = 10, height = 6.8, dpi = 300, bg = "white")
log_yaz("SEKILLER_HAZIR")
