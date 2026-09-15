# =============================================================================
# config.R
# DASS-42 kisa form karsilastirmasi: PUB21, MIN21, MAX21, COV21
# Tum sabitler, tohumlar ve madde anahtarlari burada tanimlanir.
# Bu dosya on kayit metnine oldugu gibi eklenebilir.
# =============================================================================

cfg <- list(
  study = "DASS-42 semantic short forms: PUB21, MIN21, MAX21, COV21 (AS1-AS4)",

  # --- Orneklem ---------------------------------------------------------------
  seed_sample      = 20260905L,   # uygun kayitlardan cekim
  seed_split       = 260905L,     # kalibrasyon / dogrulama bolunmesi
  n_target         = 4000L,       # cekilecek kayit sayisi (use_all_eligible = TRUE ise yok sayilir)
  use_all_eligible = FALSE,       # TRUE: 10.362 uygun kaydin tamami kullanilir
  split_prop       = 0.5,         # kalibrasyon orani
  age_min = 18L, age_max = 80L,
  native_english_code = 1L,       # engnat == 1

  # --- Gomme ------------------------------------------------------------------
  embedding_model      = "text-embedding-3-large",
  embedding_dimensions = 3072L,
  semantic_tolerance   = 1e-12,
  cov_tie_rule         = "max_SB",   # "max_SB": esit minimumlar icinde SB en yuksek kume; "lexical": sozluk sirasi

  # --- Belirsizlik ---------------------------------------------------------------
  seed_bootstrap      = 20260913L,
  bootstrap_B         = 2000L,       # eslestirilmis kisi bootstrap tekrari
  seed_mantel         = 20260914L,
  mantel_permutations = 9999L,

  # --- GRM (mirt gerektirir) ----------------------------------------------------
  run_grm     = TRUE,                # mirt kurulu degilse asama atlanir ve kaydedilir
  theta       = seq(-3, 3, by = 0.1),
  info_lower  = -2, info_upper = 2,

  # --- Betimsel pratik esikler (karar kurali degil) -----------------------------
  delta_cfi   = 0.010,
  delta_rmsea = 0.015,
  mic_flag    = 0.70,                # ortalama madde ici korelasyon icin fazlalik isareti

  # --- Kaynak dogrulama -----------------------------------------------------------
  expected_source_sha256 = "38d1707cf1f9effec45c41f61c4fdc0ab245021da635a57a7f0e69edd965f3f5"
)

# DASS-42 alt boyut anahtari (Lovibond ve Lovibond, 1995)
key42 <- list(
  D = c(3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42),
  A = c(2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41),
  S = c(1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39)
)
subscale_labels <- c(D = "Depresyon", A = "Kaygi", S = "Stres")

# Yayimlanmis DASS-21 maddelerinin DASS-42 numaralari (DASS-21 sirasina gore)
map21to42 <- c(22, 2, 3, 4, 42, 6, 41, 12, 40, 10, 39, 8, 26, 35, 28, 31, 17, 18, 25, 20, 38)
key21 <- lapply(key42, function(x) intersect(x, map21to42))

item_id <- function(x) sprintf("Q%02d", x)

form_names  <- c("FULL42", "PUB21", "MIN21", "MAX21", "COV21")
short_forms <- form_names[-1]
new_forms   <- c("MIN21", "MAX21", "COV21")
items_per_subscale <- 7L

stopifnot(
  identical(as.integer(sort(unlist(key42, use.names = FALSE))), 1:42),
  all(lengths(key42) == 14L),
  all(lengths(key21) == 7L),
  identical(key21$D, c(3, 10, 17, 26, 31, 38, 42)),
  identical(key21$A, c(2, 4, 20, 25, 28, 40, 41)),
  identical(key21$S, c(6, 8, 12, 18, 22, 35, 39)),
  cfg$cov_tie_rule %in% c("max_SB", "lexical")
)
