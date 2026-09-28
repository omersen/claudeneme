# ---- AS5: bütün olası formlarda anlamsal ve psikometrik göstergelerin ilişkisi (alt küme testi) ----
as5 <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(c("kal", "deg"), function(g) {
  tb <- tum_alt[tum_alt$subscale == f & tum_alt$grup == g, ]              # 3.432 küme
  bl <- tb[tb$kanonik_bolme, ]                                            # 1.716 benzersiz bölünme
  data.frame(subscale = f, grup = g, n_kume = nrow(tb), n_bolunme = nrow(bl),
             rho_SB_alfa  = spearman(tb$SB, tb$alpha),
             rho_CLb_rmse = spearman(bl$CL_b, bl$rmse),
             rho_CLb_sd   = spearman(bl$CL_b, bl$sd_d),
             rho_CLb_bias = spearman(bl$CL_b, abs(bl$bias)))
}))))
print(as5, digits = 3)
write.csv(as5, "html_ciktilari/AS5_iliskiler.csv", row.names = FALSE)

# Şekil: bütün kümeler (gri) ve dört form (değerlendirme grubu)
tv <- tum_alt[tum_alt$grup == "deg", ]; bl <- tv[tv$kanonik_bolme, ]
gri <- rbind(data.frame(satir = "SB-alfa", subscale = tv$subscale, x = tv$SB, y = tv$alpha),
             data.frame(satir = "CLb-RMSE", subscale = bl$subscale, x = bl$CL_b, y = bl$rmse))
form_d <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(kisa_formlar, function(form) {
  z <- tv[tv$subscale == f & tv$subset_key == anahtar_yap(formlar[[form]][[f]]), ]
  data.frame(satir = c("SB-alfa", "CLb-RMSE"), subscale = f, form = form, x = c(z$SB, z$CL_b), y = c(z$alpha, z$rmse))
}))))
form_d$form <- factor(form_d$form, levels = kisa_formlar)
d <- as5[as5$grup == "deg", ]
etiket <- c(setNames(sprintf("%s | SB ve alfa (rho = %.2f)", d$subscale, d$rho_SB_alfa), paste("SB-alfa", d$subscale)),
            setNames(sprintf("%s | CL_b ve RMSE (rho = %.2f)", d$subscale, d$rho_CLb_rmse), paste("CLb-RMSE", d$subscale)))
duzey <- etiket[c(paste("SB-alfa", alt_boyutlar), paste("CLb-RMSE", alt_boyutlar))]
gri$panel <- factor(etiket[paste(gri$satir, gri$subscale)], levels = duzey)
form_d$panel <- factor(etiket[paste(form_d$satir, form_d$subscale)], levels = duzey)
sekil2 <- ggplot(gri, aes(x = x, y = y)) +
  geom_point(colour = "grey72", size = 0.35, alpha = 0.5) +
  geom_point(data = form_d, aes(colour = form, shape = form), size = 2.6, stroke = 0.9) +
  facet_wrap(~panel, nrow = 2, scales = "free") +
  scale_colour_manual(values = c(PUB21 = "#000000", MIN21 = "#0072B2", MAX21 = "#D55E00", COV21 = "#009E73")) +
  scale_shape_manual(values = c(PUB21 = 15, MIN21 = 16, MAX21 = 17, COV21 = 18)) +
  labs(x = "Anlamsal gösterge (üst sıra: SB; alt sıra: CL_b)", y = "Psikometrik gösterge (üst sıra: alfa; alt sıra: RMSE)",
       caption = "Gri noktalar: üst sırada 3.432 küme, alt sırada 1.716 bölünme. MIN21 ile MAX21 aynı bölünmedir; alt sırada üst üste düşer.") +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom", legend.title = element_blank(), plot.caption = element_text(hjust = 0))
if (interactive()) print(sekil2)
ggsave("html_ciktilari/sekil_AS5_alt_kume_testi.png", sekil2, width = 10, height = 6.8, dpi = 300, bg = "white")