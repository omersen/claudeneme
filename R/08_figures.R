# =============================================================================
# 08_figures.R
# Tamamlanmis bir kosunun CSV ciktilarindan sekiller. Ayrica calistirilabilir:
#   out <- "outputs/run1"; source("config.R"); source("R/08_figures.R")
# =============================================================================
if (!exists("out") || !dir.exists(out)) stop("out, tamamlanmis bir cikti dizini olmali.")
fig_dir <- file.path(out, "figures"); dir.create(fig_dir, showWarnings = FALSE)
read_result <- function(name) read.csv(file.path(out, name), stringsAsFactors = FALSE, check.names = FALSE)
palette_forms <- c(FULL42 = "#202020", PUB21 = "#0072B2", MIN21 = "#D55E00", MAX21 = "#8A60A8", COV21 = "#009E73")
domain_factor <- function(x) factor(x, levels = c("D", "A", "S"), labels = c("Depresyon", "Kaygi", "Stres"))
plot_theme <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), legend.position = "bottom",
                 legend.title = ggplot2::element_blank(), strip.background = ggplot2::element_rect(fill = "#F2F2F2"))
save_figure <- function(plot, stem, width = 7.5, height = 3.6) {
  ggplot2::ggsave(file.path(fig_dir, paste0(stem, ".png")), plot, width = width, height = height, dpi = 300, bg = "white")
  ggplot2::ggsave(file.path(fig_dir, paste0(stem, ".pdf")), plot, width = width, height = height)
}
figures_made <- character(0)

# Sekil 1: ISI ile CITC (ve varsa GRM a)
item <- read_result("AS1_item_level.csv"); item$domain <- domain_factor(item$subscale)
assoc <- read_result("AS1_ISI_discrimination.csv"); assoc$domain <- domain_factor(assoc$subscale)
assoc$label <- sprintf("rho = %.2f [%.2f, %.2f]", assoc$rho_ISI_CITC, assoc$rho_ISI_CITC_lower, assoc$rho_ISI_CITC_upper)
p1 <- ggplot2::ggplot(item, ggplot2::aes(ISI, CITC_full14_calibration)) +
  ggplot2::geom_point(size = 2, colour = "#0072B2") +
  ggplot2::geom_text(ggplot2::aes(label = sub("^Q0?", "", item_id)), size = 2.4, vjust = -0.9) +
  ggplot2::facet_wrap(~domain, nrow = 1, scales = "free") +
  ggplot2::geom_text(data = assoc, ggplot2::aes(x = -Inf, y = Inf, label = label), inherit.aes = FALSE,
                     hjust = -0.05, vjust = 1.5, size = 3) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.08, 0.25))) +
  ggplot2::labs(x = "Madde benzerlik indeksi (ISI)", y = "Duzeltilmis madde-toplam korelasyonu (kalibrasyon)") + plot_theme
save_figure(p1, "Sekil_1_ISI_CITC"); figures_made <- c(figures_made, "Sekil_1_ISI_CITC")
if ("a_GRM_calibration" %in% names(item) && any(is.finite(item$a_GRM_calibration))) {
  p1b <- ggplot2::ggplot(item, ggplot2::aes(ISI, a_GRM_calibration)) +
    ggplot2::geom_point(size = 2, colour = "#D55E00") +
    ggplot2::facet_wrap(~domain, nrow = 1, scales = "free") +
    ggplot2::labs(x = "Madde benzerlik indeksi (ISI)", y = "GRM ayirt edicilik (a), kalibrasyon") + plot_theme
  save_figure(p1b, "Sekil_1b_ISI_GRM_a"); figures_made <- c(figures_made, "Sekil_1b_ISI_GRM_a")
}

# Sekil 2: SB - CL duzleminde tum yedili kumeler ve dort form
cloud <- read_result("AS4_exact_subset_distribution.csv"); cloud$domain <- domain_factor(cloud$subscale)
sem <- subset(read_result("AS4_semantic_metrics.csv"), form != "FULL42"); sem$domain <- domain_factor(sem$subscale)
sem$form <- factor(sem$form, levels = names(palette_forms)[-1])
p2 <- ggplot2::ggplot(cloud, ggplot2::aes(SB, CL_dropped)) +
  ggplot2::geom_point(colour = "#B5B5B5", alpha = 0.25, size = 0.5) +
  ggplot2::geom_point(data = sem, ggplot2::aes(colour = form, shape = form), size = 2.8, stroke = 1) +
  ggplot2::facet_wrap(~domain, nrow = 1, scales = "free") +
  ggplot2::scale_colour_manual(values = palette_forms[-1]) +
  ggplot2::scale_shape_manual(values = c(PUB21 = 16, MIN21 = 17, MAX21 = 15, COV21 = 18)) +
  ggplot2::labs(x = "Anlamsal cesitlilik (SB = 1 - MIISS)", y = "Kapsam kaybi (CL, disarida kalan maddeler)") + plot_theme
save_figure(p2, "Sekil_2_SB_CL_tum_kumeler"); figures_made <- c(figures_made, "Sekil_2_SB_CL_tum_kumeler")

# Sekil 3: PUB21'e gore farklar ve noktasal %95 araliklar
ci <- read_result("BOOT_paired_differences_vs_PUB21.csv"); ci$domain <- domain_factor(ci$subscale)
ci$form <- factor(ci$form, levels = c("COV21", "MAX21", "MIN21"))
lab <- c(alpha_raw_delta = "Ham alfa farki", raw_RMSE_delta = "Ham RMSE farki",
         r_remaining_delta = "Kalan-madde r farki", eap_RMSE_delta = "EAP RMSE farki")
ci$metric_label <- factor(lab[ci$metric], levels = lab)
p3 <- ggplot2::ggplot(ci, ggplot2::aes(estimate, form, colour = form)) +
  ggplot2::geom_vline(xintercept = 0, colour = "#777777", linetype = "dashed", linewidth = 0.4) +
  ggplot2::geom_segment(ggplot2::aes(x = lower, xend = upper, yend = form), linewidth = 0.8) +
  ggplot2::geom_point(size = 2.2) + ggplot2::facet_grid(metric_label ~ domain, scales = "free_x") +
  ggplot2::scale_colour_manual(values = palette_forms) +
  ggplot2::labs(x = "PUB21'e gore fark ve noktasal %95 bootstrap araligi", y = NULL) +
  plot_theme + ggplot2::theme(legend.position = "none")
save_figure(p3, "Sekil_3_PUB21_farklari", height = 5.5); figures_made <- c(figures_made, "Sekil_3_PUB21_farklari")

# Sekil 4: 3.432 kume icinde alfa - RMSE duzlemi ve dort form
ref <- read_result("REF_all_subsets_response_and_semantic.csv"); ref$domain <- domain_factor(ref$subscale)
pos <- read_result("REF_selected_form_positions.csv"); pos$domain <- domain_factor(pos$subscale)
pos$form <- factor(pos$form, levels = names(palette_forms)[-1])
p4 <- ggplot2::ggplot(ref, ggplot2::aes(alpha_raw, raw_RMSE)) +
  ggplot2::geom_point(colour = "#B5B5B5", alpha = 0.25, size = 0.5) +
  ggplot2::geom_point(data = pos, ggplot2::aes(colour = form, shape = form), size = 2.8, stroke = 1) +
  ggplot2::facet_wrap(~domain, nrow = 1, scales = "free") +
  ggplot2::scale_colour_manual(values = palette_forms[-1]) +
  ggplot2::scale_shape_manual(values = c(PUB21 = 16, MIN21 = 17, MAX21 = 15, COV21 = 18)) +
  ggplot2::labs(x = "Ham alfa (dogrulama)", y = "Tam alt boyut puanina gore ham RMSE") + plot_theme
save_figure(p4, "Sekil_4_alfa_RMSE_tum_kumeler"); figures_made <- c(figures_made, "Sekil_4_alfa_RMSE_tum_kumeler")

# Sekil 5: test bilgisi (mirt varsa)
if (file.exists(file.path(out, "AS2_information_curves.csv"))) {
  info <- read_result("AS2_information_curves.csv"); info$domain <- domain_factor(info$subscale)
  info$form <- factor(info$form, levels = names(palette_forms))
  p5 <- ggplot2::ggplot(info, ggplot2::aes(theta, information, colour = form, linetype = form)) +
    ggplot2::geom_line(linewidth = 0.7) + ggplot2::facet_wrap(~domain, nrow = 1) +
    ggplot2::scale_colour_manual(values = palette_forms) +
    ggplot2::scale_linetype_manual(values = c(FULL42 = "longdash", PUB21 = "solid", MIN21 = "dotted", MAX21 = "dotdash", COV21 = "twodash")) +
    ggplot2::labs(x = expression(theta), y = "Test bilgisi (ortak tam alt boyut kalibrasyonu)") + plot_theme
  save_figure(p5, "Sekil_5_test_bilgisi"); figures_made <- c(figures_made, "Sekil_5_test_bilgisi")
}
write.csv(data.frame(figure = figures_made, png = paste0("figures/", figures_made, ".png")),
          file.path(out, "figure_manifest.csv"), row.names = FALSE)
