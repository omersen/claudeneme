# ---- 3.1 Paketler, ayarlar ve tanım fonksiyonları ---------------------------------
# Bütün kodlar öğrenci paketinin klasöründe (berkcan_dass42) ve yukarıdan aşağıya sırayla çalıştırılır.
# Önerilen sürümler: R 4.5.3, lavaan 0.7-2, semTools 0.5-9, mirt 1.47, ggplot2; ayrıca digest ve jsonlite.
# httr2 yalnız 3.3'te vektörler API ile yeniden üretilecekse gerekir.
library(lavaan); library(semTools); library(mirt); library(ggplot2)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
dir.create("html_ciktilari", showWarnings = FALSE)

key42 <- list(D = c(3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42),   # DASS-42 alt boyutları
              A = c(2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41),
              S = c(1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39))
key21 <- list(D = c(3, 10, 17, 26, 31, 38, 42),                              # yayımlanmış DASS-21 (PUB21)
              A = c(2, 4, 20, 25, 28, 40, 41),
              S = c(6, 8, 12, 18, 22, 35, 39))
item_id <- function(x) sprintf("Q%02d", x)
alt_boyutlar <- c("D", "A", "S")
kisa_formlar <- c("PUB21", "MIN21", "MAX21", "COV21")
anlamsal_formlar <- c("MIN21", "MAX21", "COV21")
tol <- 1e-12                                                  # sayısal eşitlik toleransı

# Anlamsal göstergeler
cosine_matrix <- function(E) {
  nr <- sqrt(rowSums(E^2)); C <- tcrossprod(E / nr)
  C[C > 1] <- 1; C[C < -1] <- -1; diag(C) <- 1
  dimnames(C) <- list(rownames(E), rownames(E)); C
}
isi_values <- function(Cf) (rowSums(Cf) - diag(Cf)) / (nrow(Cf) - 1)   # ISI: diğer 13 maddeye ortalama kosinüs
rank_with_tolerance <- function(values, decreasing = FALSE) {           # eşitlikte küçük madde numarası önce
  z <- if (decreasing) -values else values
  kalan <- names(z)[order(z, names(z))]; sira <- character(0)
  while (length(kalan)) {
    grup <- kalan[z[kalan] <= z[kalan[1L]] + tol]
    sira <- c(sira, sort(grup)); kalan <- setdiff(kalan, grup)
  }
  sira
}
sirali_ortalama <- function(x) sum(sort(x)) / length(x)
anlamsal_olcu <- function(Cf, S) {   # SB, CL ve CL_b (14 maddelik havuz üzerinden)
  w <- Cf[S, S, drop = FALSE]; R <- setdiff(rownames(Cf), S)
  c(SB   = 1 - sirali_ortalama(w[upper.tri(w)]),                        # 1 - 21 çiftin ortalama kosinüsü
    CL   = sirali_ortalama(1 - apply(Cf[, S, drop = FALSE], 1L, max)),  # 14 maddenin en yakın seçili maddeye uzaklığı
    CL_b = sirali_ortalama(c(1 - apply(Cf[R, S, drop = FALSE], 1L, max),
                             1 - apply(Cf[S, R, drop = FALSE], 1L, max))))  # karşı yarıdaki en yakın maddeye uzaklık
}
alt_kume_anlamsal <- function(Cf) {   # 3.432 yedili kümenin tamamı
  pool <- sort(rownames(Cf)); kombin <- utils::combn(pool, 7)
  anahtar <- apply(kombin, 2, paste, collapse = "|")
  o <- order(anahtar); kombin <- kombin[, o, drop = FALSE]; anahtar <- anahtar[o]
  olc <- t(apply(kombin, 2, function(s) anlamsal_olcu(Cf, s)))
  tumleyen <- match(apply(kombin, 2, function(s) paste(setdiff(pool, s), collapse = "|")), anahtar)
  data.frame(subset_key = anahtar, SB = olc[, "SB"], CL = olc[, "CL"], CL_b = olc[, "CL_b"],
             tumleyen = tumleyen, kanonik_bolme = kombin[1, ] == pool[1], stringsAsFactors = FALSE)
}

# Psikometrik göstergeler
alt_kume_psikometrik <- function(X, pool, anahtarlar) {   # bütün kümeler için alfa, yanlılık, s_d, RMSE, r
  k <- 7; kumeler <- strsplit(anahtarlar, "|", fixed = TRUE)          # tamsayı toplamlarıyla (eşitlikler korunur)
  Xf <- as.matrix(X[, pool, drop = FALSE]); n <- nrow(Xf)
  G <- vapply(kumeler, function(s) as.numeric(pool %in% s), numeric(length(pool)))
  Ss <- Xf %*% G; U <- rowSums(Xf); Dt <- 2 * Ss - U                  # Dt / 14 = kısa ortalama - tam ortalama
  sD <- colSums(Dt); sD2 <- colSums(Dt^2); sS <- colSums(Ss); vS <- n * colSums(Ss^2) - sS^2
  vi <- n * colSums(Xf^2) - colSums(Xf)^2; sU <- sum(U); vU <- n * sum(U^2) - sU^2
  data.frame(subset_key = anahtarlar, alpha = k / (k - 1) * (1 - as.numeric(crossprod(G, vi)) / vS),
             bias = sD / (14 * n), sd_d = sqrt(n * sD2 - sD^2) / (14 * n), rmse = sqrt(sD2 / n) / 14,
             r = (n * colSums(Ss * U) - sS * sU) / sqrt(vS * vU), stringsAsFactors = FALSE)
}
midrank_percentile <- function(dagilim, deger)             # orta sıra yüzdeliği
  100 * (mean(dagilim < deger - tol) + 0.5 * mean(abs(dagilim - deger) <= tol))
alpha_raw <- function(X) { V <- stats::cov(as.matrix(X)); k <- ncol(V); k / (k - 1) * (1 - sum(diag(V)) / sum(V)) }
uyum_olculeri <- function(kisa, tam) {
  d <- kisa - tam
  c(r = stats::cor(kisa, tam), bias = mean(d), sd_d = sqrt(mean((d - mean(d))^2)), rmse = sqrt(mean(d^2)))
}
spearman <- function(x, y) stats::cor(x, y, method = "spearman")

# Modeller
fit_grm <- function(X) {
  mod <- mirt::mirt(X, 1, itemtype = "graded", SE = FALSE, verbose = FALSE,
                    technical = list(NCYCLES = 2000L), TOL = 1e-4)
  stopifnot(mirt::extract.mirt(mod, "converged")); mod
}
grm_parameters <- function(mod) {
  z <- mirt::coef(mod, IRTpars = TRUE, simplify = TRUE)$items
  data.frame(item_id = rownames(z), a = as.numeric(z[, "a"]), z[, setdiff(colnames(z), "a"), drop = FALSE],
             row.names = NULL)
}
q3_duzeltilmis <- function(mod) {   # ortalaması çıkarılmış Q3; yalnız üst üçgen kullanılır
  q <- mirt::residuals(mod, type = "Q3", verbose = FALSE); q - mean(q[upper.tri(q)])
}
fit_cfa <- function(X, form) {      # üç ilişkili faktörlü sıralı DFA (WLSMV)
  ids <- unlist(form, use.names = FALSE)
  model <- paste(vapply(names(form), function(f) paste(f, "=~", paste(form[[f]], collapse = " + ")), ""),
                 collapse = "\n")
  fit <- lavaan::cfa(model, data = X[, ids, drop = FALSE], ordered = ids, estimator = "WLSMV", std.lv = TRUE)
  stopifnot(lavaan::lavInspect(fit, "converged"), lavaan::lavInspect(fit, "post.check")); fit
}
omega_values <- function(fit, obs.var = FALSE) {
  z <- semTools::compRelSEM(fit, tau.eq = FALSE, ord.scale = TRUE, obs.var = obs.var)
  if (is.list(z)) z <- vapply(z[c("D", "A", "S")], as.numeric, numeric(1))
  z[c("D", "A", "S")]
}
# ---- 3.2 Veri, örneklem ve gruplar ------------------------------------------------
zip_yolu <- "girdiler/DASS_data_21.02.19.zip"
stopifnot(identical(digest::digest(file = zip_yolu, algo = "sha256"),                  # ham veri değişmemiş olmalı
                    "38d1707cf1f9effec45c41f61c4fdc0ab245021da635a57a7f0e69edd965f3f5"))
uyeler <- unzip(zip_yolu, list = TRUE)$Name
ham <- read.delim(unz(zip_yolu, uyeler[grepl("(^|/)data[.]csv$", uyeler)]), sep = "\t", quote = "",
                  check.names = FALSE, stringsAsFactors = FALSE, na.strings = c("", "NA"))
kitap <- readLines(unz(zip_yolu, uyeler[grepl("(^|/)codebook[.]txt$", uyeler)]), warn = FALSE, encoding = "UTF-8")
madde_satiri <- kitap[grepl("^Q[0-9]+\t", kitap)]
metin_duzelt <- function(x) {
  x <- gsub("&#39;|&apos;", "'", x); x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE); trimws(gsub("[[:space:]]+", " ", enc2utf8(x)))
}
maddeler <- data.frame(item_id = item_id(as.integer(sub("^Q([0-9]+)\t.*$", "\\1", madde_satiri))),
                       text = metin_duzelt(sub("^Q[0-9]+\t", "", madde_satiri)))
maddeler <- maddeler[order(maddeler$item_id), ]

Y <- as.data.frame(lapply(ham[, paste0("Q", 1:42, "A")], function(x) suppressWarnings(as.numeric(x))))
names(Y) <- item_id(1:42)
yas <- suppressWarnings(as.numeric(ham$age)); dil <- suppressWarnings(as.numeric(ham$engnat))
cinsiyet <- suppressWarnings(as.numeric(ham$gender))
uygun <- which(!is.na(yas) & yas >= 18 & yas <= 80 &                         # 18-80 yaş
               !is.na(dil) & dil == 1 &                                        # ana dili İngilizce
               apply(as.matrix(Y), 1, function(x) all(!is.na(x) & x %in% 1:4)))   # 42 madde eksiksiz
set.seed(20260905); secilen <- sort(sample(uygun, 4000))                     # 4.000 kayıt
set.seed(260905);   kal_sira <- sort(sample(seq_along(secilen), 2000))        # 2.000 + 2.000 bölme
deg_sira <- setdiff(seq_along(secilen), kal_sira)
bolme <- data.frame(source_row = secilen,
                    split = ifelse(seq_along(secilen) %in% kal_sira, "calibration", "validation"))
stopifnot(identical(bolme, read.csv("girdiler/referans_sample_split.csv", stringsAsFactors = FALSE)))

X <- Y[secilen, ] - 1; rownames(X) <- NULL                                    # yanıtlar 0-3
kal <- X[kal_sira, ]; deg <- X[deg_sira, ]                                    # kalibrasyon ve değerlendirme grupları

yas_uygun <- !is.na(yas) & yas >= 18 & yas <= 80
akis <- data.frame(asama = c("Ham kayıt", "18-80 yaş", "Ana dili İngilizce", "42 madde eksiksiz ve geçerli",
                             "Seçilen örneklem", "Kalibrasyon grubu", "Değerlendirme grubu"),
                   n = c(nrow(ham), sum(yas_uygun), sum(yas_uygun & !is.na(dil) & dil == 1), length(uygun),
                         length(secilen), nrow(kal), nrow(deg)))
betim <- do.call(rbind, lapply(list(toplam = seq_along(secilen), kalibrasyon = kal_sira, degerlendirme = deg_sira),
  function(s) { i <- secilen[s]; g <- cinsiyet[i]                                # 1 erkek, 2 kadın, 3 diğer
    data.frame(n = length(i), yas_ort = mean(yas[i]), yas_ss = sd(yas[i]), kadin_yzd = 100 * mean(g %in% 2),
               erkek_yzd = 100 * mean(g %in% 1), diger_yzd = 100 * mean(g %in% 3), yanitsiz_yzd = 100 * mean(!(g %in% 1:3))) }))
betim <- cbind(grup = rownames(betim), betim); rownames(betim) <- NULL
print(akis); print(betim, digits = 3)
write.csv(akis, "html_ciktilari/orneklem_akisi.csv", row.names = FALSE)
write.csv(betim, "html_ciktilari/orneklem_betimleme.csv", row.names = FALSE)
# ---- 3.3 Gömme vektörleri: arşiv (varsayılan) ve API ile üretim (yer tutucu) ----------
# vektor_kaynagi üç değer alır:
#   "arsiv"       Ravenda vd. (2025) arşivindeki vektörler; özet denetlenir, API çağrısı yapılmaz (varsayılan).
#   "api_yeni"    Vektörler OpenAI API ile yeniden üretilir, tarihli bir dosyaya ve özet kaydına yazılır.
#   "api_kayitli" Daha önce "api_yeni" ile yazılmış dosya okunur ve özeti denetlenir; yeni çağrı yapılmaz.
# API vektörleri arşivle bit düzeyinde aynı olmayabilir; bu durumda formlar ve bütün sonuçlar değişebilir.
# Bu yüzden API ile üretilen vektörler aşağıda arşivle karşılaştırılır (3.4'te form üyeliği de karşılaştırılır).
vektor_kaynagi <- "arsiv"
api_dosyasi <- "girdiler/api_embeddings_GGGGAAGG.csv"         # YER TUTUCU: "api_kayitli" için dosya adını yazın

vektor_yolu <- "girdiler/archived_embeddings.csv"
kaynak <- jsonlite::fromJSON("girdiler/embedding_provenance.json")
stopifnot(identical(digest::digest(file = vektor_yolu, algo = "sha256"), kaynak$derived_sha256),
          kaynak$model == "text-embedding-3-large", isFALSE(kaynak$new_API_call))   # arşiv dosyası değişmemiş olmalı
vektor_oku <- function(yol) {
  tab <- read.csv(yol, check.names = FALSE, stringsAsFactors = FALSE)
  tab <- tab[match(maddeler$item_id, tab$item_id), ]
  E <- as.matrix(tab[, setdiff(names(tab), "item_id")]); rownames(E) <- tab$item_id
  stopifnot(identical(rownames(E), maddeler$item_id), !anyNA(E)); E
}
E_arsiv <- vektor_oku(vektor_yolu)                                                  # 42 x 3072

# API YER TUTUCUSU. Anahtar koda yazılmaz; R oturumundan önce OPENAI_API_KEY ortam değişkeni tanımlanır.
# Gönderilen tek veri 42 madde metnidir (katılımcı verisi gönderilmez). httr2 paketi gerekir.
api_embedding <- function(metin, model = "text-embedding-3-large") {
  anahtar <- Sys.getenv("OPENAI_API_KEY")
  if (!nzchar(anahtar)) stop("OPENAI_API_KEY tanımlı değil.")
  yanit <- httr2::request("https://api.openai.com/v1/embeddings") |>
    httr2::req_auth_bearer_token(anahtar) |>
    httr2::req_body_json(list(model = model, input = as.list(metin), encoding_format = "float")) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  sira <- vapply(yanit$data, function(d) d$index, numeric(1))                      # yanıt sırası girdi sırasına göre dizilir
  E <- do.call(rbind, lapply(yanit$data[order(sira)], function(d) unlist(d$embedding)))
  rownames(E) <- names(metin); list(E = E, model = yanit$model)
}
if (vektor_kaynagi == "api_yeni") {
  api <- api_embedding(setNames(maddeler$text, maddeler$item_id))
  api_dosyasi <- sprintf("girdiler/api_embeddings_%s.csv", format(Sys.Date(), "%Y%m%d"))
  write.csv(data.frame(item_id = rownames(api$E), api$E, check.names = FALSE), api_dosyasi, row.names = FALSE)
  jsonlite::write_json(list(model_istenen = "text-embedding-3-large", model_yanit = api$model,
                            cagri_zamani_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
                            boyut = ncol(api$E), madde = nrow(api$E),
                            sha256 = digest::digest(file = api_dosyasi, algo = "sha256")),
                       sub("[.]csv$", "_kaynak.json", api_dosyasi), auto_unbox = TRUE, pretty = TRUE)
}
if (vektor_kaynagi %in% c("api_yeni", "api_kayitli")) {
  api_kayit <- jsonlite::fromJSON(sub("[.]csv$", "_kaynak.json", api_dosyasi))
  stopifnot(identical(digest::digest(file = api_dosyasi, algo = "sha256"), api_kayit$sha256))
  E_api <- vektor_oku(api_dosyasi)
  birim <- function(E) E / sqrt(rowSums(E^2))
  C_ars <- cosine_matrix(E_arsiv); C_api <- cosine_matrix(E_api); u <- upper.tri(C_ars)
  api_arsiv <- data.frame(madde_vektor_kosinusu_min = min(rowSums(birim(E_arsiv) * birim(E_api))),
                          kosinus_matrisi_r = cor(C_ars[u], C_api[u]),
                          kosinus_en_buyuk_fark = max(abs(C_ars[u] - C_api[u])))
  print(api_arsiv, digits = 4)                                               # 1'e çok yakın değilse sonuçlar değişebilir
  write.csv(api_arsiv, "html_ciktilari/api_arsiv_karsilastirma.csv", row.names = FALSE)
  E <- E_api
} else E <- E_arsiv
C <- cosine_matrix(E)                                                                 # 42 x 42 kosinüs benzerliği
# ---- 3.4 Üç anlamsal seçim kuralı ve dört form ---------------------------------------
form_olustur <- function(Cm) {   # MIN21, MAX21 ve COV21 kurallarını verilen kosinüs matrisine uygular
  z <- list(ISI = list(), alt_kume = list(), MIN21 = list(), MAX21 = list(), COV21 = list())
  for (f in alt_boyutlar) {
    havuz <- item_id(key42[[f]]); Cf <- Cm[havuz, havuz]
    z$ISI[[f]] <- isi_values(Cf)
    z$MIN21[[f]] <- sort(rank_with_tolerance(z$ISI[[f]])[1:7])                      # ISI en düşük yedi madde
    z$MAX21[[f]] <- sort(rank_with_tolerance(z$ISI[[f]], decreasing = TRUE)[1:7])   # ISI en yüksek yedi madde
    ak <- alt_kume_anlamsal(Cf)                                                      # 3.432 kümenin SB, CL, CL_b
    esit <- which(abs(ak$CL - min(ak$CL)) <= tol); ak$cov_esit_minimum <- seq_len(nrow(ak)) %in% esit
    z$COV21[[f]] <- strsplit(sort(ak$subset_key[esit])[1], "|", fixed = TRUE)[[1]]   # CL en küçük küme
    z$alt_kume[[f]] <- ak
  }
  z
}
ana <- form_olustur(C)
formlar <- list(FULL42 = lapply(key42, item_id), PUB21 = lapply(key21, item_id),
                MIN21 = ana$MIN21, MAX21 = ana$MAX21, COV21 = ana$COV21)
ISI <- ana$ISI; alt_kume <- ana$alt_kume
anahtar_yap <- function(ids) paste(sort(ids), collapse = "|")
form_tablosu <- do.call(rbind, lapply(kisa_formlar, function(nm)
  data.frame(form = nm, subscale = alt_boyutlar,
             maddeler = sapply(alt_boyutlar, function(f) paste(formlar[[nm]][[f]], collapse = " ")),
             cov_esit_cozum = if (nm == "COV21") sapply(alt_boyutlar, function(f) sum(alt_kume[[f]]$cov_esit_minimum)) else NA)))
rownames(form_tablosu) <- NULL
print(form_tablosu)
write.csv(form_tablosu, "html_ciktilari/formlar.csv", row.names = FALSE)

# API ile üretilmiş vektörler kullanıldıysa: arşiv vektörleriyle kurulan formlarla ortak madde sayısı (7 üzerinden)
if (exists("E_api")) {
  ana_arsiv <- form_olustur(cosine_matrix(E_arsiv))
  api_form <- do.call(rbind, lapply(anlamsal_formlar, function(nm)
    data.frame(form = nm, t(sapply(alt_boyutlar, function(f) length(intersect(ana_arsiv[[nm]][[f]], formlar[[nm]][[f]])))))))
  print(api_form)                                                            # 7'den küçük değer: form arşivdekinden farklı
  write.csv(api_form, "html_ciktilari/api_arsiv_form_uyelik.csv", row.names = FALSE)
}
# ---- 3.5 Alt küme testi: bütün yedili kümelerin psikometrik değerleri -----------------
tum_alt <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(c("kal", "deg"), function(g) {
  ps <- alt_kume_psikometrik(if (g == "kal") kal else deg, formlar$FULL42[[f]], alt_kume[[f]]$subset_key)
  data.frame(subscale = f, grup = g, alt_kume[[f]], ps[, c("alpha", "bias", "sd_d", "rmse", "r")])
}))))
yuzdelik <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  i <- match(anahtar_yap(formlar[[form]][[f]]), tv$subset_key)
  data.frame(form = form, subscale = f,
             alfa = tv$alpha[i], alfa_yzd = midrank_percentile(tv$alpha, tv$alpha[i]),
             rmse = tv$rmse[i],  rmse_yzd = midrank_percentile(tv$rmse, tv$rmse[i]),
             SB = tv$SB[i],      SB_yzd = midrank_percentile(tv$SB, tv$SB[i]),
             CL = tv$CL[i],      CL_yzd = midrank_percentile(tv$CL, tv$CL[i]),
             r = tv$r[i],        r_medyan = median(tv$r))
}))))
write.csv(yuzdelik, "html_ciktilari/form_yuzdelikleri.csv", row.names = FALSE)
dagilim <- do.call(rbind, lapply(alt_boyutlar, function(f) {                 # değerlendirme grubunda 3.432 küme
  tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  data.frame(subscale = f, alfa_min = min(tv$alpha), alfa_medyan = median(tv$alpha), alfa_maks = max(tv$alpha),
             rmse_min = min(tv$rmse), rmse_medyan = median(tv$rmse), rmse_maks = max(tv$rmse),
             r_min = min(tv$r), r_medyan = median(tv$r), r_maks = max(tv$r))
}))
print(dagilim, digits = 3)
write.csv(dagilim, "html_ciktilari/alt_kume_dagilimi.csv", row.names = FALSE)
# ---- AS1: ISI ile GRM ayırt ediciliği (a) arasındaki ilişki ----------------------------
as1 <- list(); par <- list(); tani <- list(); q3_cift <- list(); kategori <- list()
grm_mod <- list()                                                            # modeller AS2'deki test bilgisi için saklanır
for (f in alt_boyutlar) {
  havuz <- formlar$FULL42[[f]]; isi <- as.numeric(ISI[[f]][havuz])
  hangi_form <- sapply(havuz, function(j)                                    # maddenin yer aldığı kısa formlar
    paste(kisa_formlar[sapply(kisa_formlar, function(nm) j %in% formlar[[nm]][[f]])], collapse = " "))
  for (g in c("kal", "deg")) {
    Xg <- (if (g == "kal") kal else deg)[, havuz]
    mod <- fit_grm(Xg); grm_mod[[paste(f, g)]] <- mod                      # tek boyutlu GRM
    p <- grm_parameters(mod); p <- p[match(havuz, p$item_id), ]
    citc <- sapply(havuz, function(j) cor(Xg[[j]], rowSums(Xg[, setdiff(havuz, j)])))   # düzeltilmiş madde-toplam r
    m2 <- tryCatch(mirt::M2(mod, type = "C2"), error = function(e) NULL)            # C2 temelli uyum
    q <- q3_duzeltilmis(mod); ust <- upper.tri(q); aq <- q[ust]; cs <- C[havuz, havuz][ust]
    as1[[paste(f, g)]] <- data.frame(subscale = f, grup = g, rho_ISI_a = spearman(isi, p$a),
                                     rho_ISI_CITC = spearman(isi, citc), rho_a_CITC = spearman(p$a, citc))
    par[[paste(f, g)]] <- data.frame(subscale = f, grup = g, item_id = havuz, ISI = isi, a = p$a,
                                     b1 = p$b1, b2 = p$b2, b3 = p$b3, CITC = as.numeric(citc), formlar = hangi_form)
    tani[[paste(f, g)]] <- data.frame(subscale = f, grup = g,
                                      C2 = if (is.null(m2)) NA else m2$M2, df = if (is.null(m2)) NA else m2$df,
                                      RMSEA = if (is.null(m2)) NA else m2$RMSEA, SRMSR = if (is.null(m2)) NA else m2$SRMSR,
                                      maks_Q3 = max(aq), rho_cos_Q3 = spearman(cs, aq))       # 91 madde çifti
    ij <- which(ust, arr.ind = TRUE); en <- order(-aq)[1:3]                                # en yüksek üç Q3 çifti
    q3_cift[[paste(f, g)]] <- data.frame(subscale = f, grup = g, cift = paste(havuz[ij[en, 1]], havuz[ij[en, 2]], sep = "-"),
                                         Q3 = aq[en], kosinus = cs[en])
    oran <- sapply(havuz, function(j) tabulate(Xg[[j]] + 1, nbins = 4) / nrow(Xg))  # 0-3 kategorilerinin oranı
    kategori[[paste(f, g)]] <- data.frame(subscale = f, grup = g, en_az_kullanilan = min(oran),
                                          madde = havuz[which(oran == min(oran), arr.ind = TRUE)[1, 2]],
                                          kategori_3_ort = mean(oran[4, ]), kategori_0_ort = mean(oran[1, ]))
  }
}
as1_tablo <- do.call(rbind, as1); as1_parametreler <- do.call(rbind, par)
as1_tani <- do.call(rbind, tani); as1_q3 <- do.call(rbind, q3_cift); as1_kategori <- do.call(rbind, kategori)
rownames(as1_tablo) <- rownames(as1_parametreler) <- rownames(as1_tani) <- rownames(as1_q3) <- rownames(as1_kategori) <- NULL
print(as1_tablo, digits = 3); print(as1_tani, digits = 3); print(as1_q3, digits = 3); print(as1_kategori, digits = 3)
write.csv(as1_tablo, "html_ciktilari/AS1_ISI_a.csv", row.names = FALSE)
write.csv(as1_parametreler, "html_ciktilari/AS1_madde_parametreleri.csv", row.names = FALSE)
write.csv(as1_tani, "html_ciktilari/AS1_GRM_tani.csv", row.names = FALSE)
write.csv(as1_q3, "html_ciktilari/AS1_Q3_ciftleri.csv", row.names = FALSE)
write.csv(as1_kategori, "html_ciktilari/AS1_kategori_kullanimi.csv", row.names = FALSE)

# Şekil: ISI ve a (kalibrasyon grubu)
ap <- as1_parametreler[as1_parametreler$grup == "kal", ]
rk <- as1_tablo[as1_tablo$grup == "kal", ]
etiket <- setNames(sprintf("%s (rho = %.2f)", rk$subscale, rk$rho_ISI_a), rk$subscale)
ap$panel <- factor(etiket[ap$subscale], levels = etiket)
sekil1 <- ggplot(ap, aes(x = ISI, y = a, label = item_id)) +
  geom_point(colour = "#0072B2", size = 2) + geom_text(size = 2.6, vjust = -0.8) +
  facet_wrap(~panel, nrow = 1, scales = "free") +
  labs(x = "Madde anlamsal benzerlik indeksi (ISI)", y = "GRM ayırt edicilik (a), kalibrasyon grubu") +
  theme_bw(base_size = 11)
if (interactive()) print(sekil1)
ggsave("html_ciktilari/sekil_AS1_ISI_a.png", sekil1, width = 9, height = 3.6, dpi = 300, bg = "white")
# ---- AS2: faktör yapısı ve alt boyut puanlarının güvenirliği ----------------------------
uyum <- list(); guv <- list(); kor <- list(); yuk <- list(); dfa_fit <- list()   # modeller Ek D için saklanır
olculer <- c("chisq.scaled", "df.scaled", "cfi.scaled", "tli.scaled", "rmsea.scaled",
             "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr")
for (form in c("FULL42", kisa_formlar)) {
  fit <- fit_cfa(deg, formlar[[form]]); dfa_fit[[form]] <- fit             # değerlendirme grubu
  fm <- lavaan::fitMeasures(fit, olculer)
  uyum[[form]] <- data.frame(form = form, as.list(setNames(as.numeric(fm), olculer)))
  lv <- lavaan::lavInspect(fit, "cor.lv")
  kor[[form]] <- data.frame(form = form, D_A = lv["D", "A"], D_S = lv["D", "S"], A_S = lv["A", "S"])
  ss <- lavaan::standardizedSolution(fit); ss <- ss[ss$op == "=~", ]                  # standartlaştırılmış yükler
  yuk[[form]] <- data.frame(form = form, t(tapply(ss$est.std, ss$lhs, mean)[alt_boyutlar]), ortalama = mean(ss$est.std))
  om <- omega_values(fit)                                                 # ana güvenirlik göstergesi
  guv[[form]] <- data.frame(form = form, subscale = alt_boyutlar, omega = as.numeric(om),
                            alfa = sapply(alt_boyutlar, function(f) alpha_raw(deg[, formlar[[form]][[f]]])))
}
as2_uyum <- do.call(rbind, uyum); as2_kor <- do.call(rbind, kor); as2_guvenirlik <- do.call(rbind, guv)
as2_yuk <- do.call(rbind, yuk)                                              # alt boyut başına ortalama yük
rownames(as2_uyum) <- rownames(as2_kor) <- rownames(as2_guvenirlik) <- rownames(as2_yuk) <- NULL
as2_guvenirlik$alfa_yzd <- yuzdelik$alfa_yzd[match(paste(as2_guvenirlik$form, as2_guvenirlik$subscale),
                                                   paste(yuzdelik$form, yuzdelik$subscale))]   # FULL42 için NA
print(as2_uyum, digits = 3); print(as2_kor, digits = 3); print(as2_guvenirlik, digits = 3); print(as2_yuk, digits = 3)
write.csv(as2_uyum, "html_ciktilari/AS2_DFA_uyum.csv", row.names = FALSE)
write.csv(as2_guvenirlik, "html_ciktilari/AS2_guvenirlik.csv", row.names = FALSE)
write.csv(as2_kor, "html_ciktilari/AS2_faktor_korelasyonlari.csv", row.names = FALSE)
write.csv(as2_yuk, "html_ciktilari/AS2_ortalama_yukler.csv", row.names = FALSE)

# ---- AS2 alt sorusu: test bilgi fonksiyonu (GRM, değerlendirme grubu) ------------------
# Her alt boyutta AS1'de değerlendirme grubunda kestirilen 14 maddelik GRM kullanılır; yeni model kurulmaz.
# Bir formun test bilgisi, o formun yedi maddesinin madde bilgi fonksiyonlarının toplamıdır. Bu yüzden
# kısa formlar aynı ölçek (theta) üzerinde karşılaştırılabilir; 14 maddelik tam alt boyut üst sınırı verir.
# Standart hata: SH(theta) = 1 / sqrt(bilgi). theta, değerlendirme grubunda ortalaması 0, SS'si 1 olan örtük özelliktir.
theta <- seq(-3, 3, by = 0.05)
tbf <- do.call(rbind, lapply(alt_boyutlar, function(f) {
  mod <- grm_mod[[paste(f, "deg")]]; havuz <- formlar$FULL42[[f]]
  stopifnot(identical(mirt::extract.mirt(mod, "itemnames"), havuz))
  do.call(rbind, lapply(c("FULL42", kisa_formlar), function(form)
    data.frame(subscale = f, form = form, theta = theta,
               bilgi = mirt::testinfo(mod, matrix(theta), which.items = match(formlar[[form]][[f]], havuz)))))
}))
tbf_tablo <- tbf[round(tbf$theta, 2) %in% c(-2, -1, 0, 1, 2), ]
tbf_tablo$SH <- 1 / sqrt(tbf_tablo$bilgi)
tbf_tablo <- tbf_tablo[order(match(tbf_tablo$form, c("FULL42", kisa_formlar)), match(tbf_tablo$subscale, alt_boyutlar),
                             tbf_tablo$theta), ]
rownames(tbf_tablo) <- NULL
print(tbf_tablo, digits = 3)
write.csv(tbf, "html_ciktilari/AS2_test_bilgisi_egri.csv", row.names = FALSE)
write.csv(tbf_tablo, "html_ciktilari/AS2_test_bilgisi.csv", row.names = FALSE)

# Şekil: üç alt boyutta test bilgi fonksiyonları
tbf$form_ad <- factor(ifelse(tbf$form == "FULL42", "Tam alt boyut (14 madde)", tbf$form),
                      levels = c("Tam alt boyut (14 madde)", kisa_formlar))
tbf$panel <- factor(c(D = "Depresyon", A = "Kaygı", S = "Stres")[tbf$subscale], levels = c("Depresyon", "Kaygı", "Stres"))
sekil_tbf <- ggplot(tbf, aes(x = theta, y = bilgi, colour = form_ad, linetype = form_ad)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~panel, nrow = 1) +
  scale_colour_manual(values = c("Tam alt boyut (14 madde)" = "grey55", PUB21 = "#000000", MIN21 = "#0072B2",
                                 MAX21 = "#D55E00", COV21 = "#009E73")) +
  scale_linetype_manual(values = c("Tam alt boyut (14 madde)" = "dashed", PUB21 = "solid", MIN21 = "solid",
                                   MAX21 = "solid", COV21 = "solid")) +
  labs(x = expression("Örtük özellik düzeyi (" * theta * ")"), y = "Test bilgisi", colour = NULL, linetype = NULL) +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")
if (interactive()) print(sekil_tbf)
ggsave("html_ciktilari/sekil_AS2_test_bilgisi.png", sekil_tbf, width = 9.5, height = 4, dpi = 300, bg = "white")
# ---- AS3: kısa ve tam form puanlarının uyumu ----------------------------------------
uy <- list()
for (form in kisa_formlar) for (f in alt_boyutlar) {
  tam  <- rowMeans(deg[, formlar$FULL42[[f]]])                            # 14 maddelik ortalama (0-3)
  kisa <- rowMeans(deg[, formlar[[form]][[f]]])                           # 7 maddelik ortalama (0-3)
  u <- uyum_olculeri(kisa, tam)
  uy[[paste(form, f)]] <- data.frame(form = form, subscale = f, r = u[["r"]], bias = u[["bias"]],
                                     sd_d = u[["sd_d"]], rmse = u[["rmse"]], rmse_0_42 = 14 * u[["rmse"]])
}
as3_uyum <- do.call(rbind, uy); rownames(as3_uyum) <- NULL
ek <- yuzdelik[match(paste(as3_uyum$form, as3_uyum$subscale), paste(yuzdelik$form, yuzdelik$subscale)), ]
as3_uyum$rmse_yzd <- ek$rmse_yzd; as3_uyum$r_medyan <- ek$r_medyan            # konum ve karşılaştırma değerleri
print(as3_uyum, digits = 3)
write.csv(as3_uyum, "html_ciktilari/AS3_uyum.csv", row.names = FALSE)

# Eşleştirilmiş bootstrap: anlamsal form eksi PUB21 (RMSE; alfa farkları ek için)
n <- nrow(deg); Dm <- as.matrix(deg)
olcum <- function(ix) {
  Xs <- Dm[ix, , drop = FALSE]; v <- numeric(0)
  for (f in alt_boyutlar) {
    tam <- rowMeans(Xs[, formlar$FULL42[[f]], drop = FALSE])
    pub_alfa <- alpha_raw(Xs[, formlar$PUB21[[f]], drop = FALSE])
    pub_rmse <- sqrt(mean((rowMeans(Xs[, formlar$PUB21[[f]], drop = FALSE]) - tam)^2))
    for (form in anlamsal_formlar) {
      v[paste("alfa", f, form, sep = "|")] <- alpha_raw(Xs[, formlar[[form]][[f]], drop = FALSE]) - pub_alfa
      v[paste("rmse", f, form, sep = "|")] <- sqrt(mean((rowMeans(Xs[, formlar[[form]][[f]], drop = FALSE]) - tam)^2)) - pub_rmse
    }
  }
  v
}
tahmin <- olcum(seq_len(n))
cekim <- t(sapply(1:2000, function(b) { set.seed(20260913 + b); olcum(sample.int(n, n, replace = TRUE)) }))
sinir <- apply(cekim, 2, quantile, probs = c(0.025, 0.975), type = 7, names = FALSE)
parca <- strsplit(names(tahmin), "|", fixed = TRUE)
boot_tablo <- data.frame(olcu = sapply(parca, `[`, 1), subscale = sapply(parca, `[`, 2), form = sapply(parca, `[`, 3),
                         tahmin = unname(tahmin), alt = sinir[1, ], ust = sinir[2, ],
                         sifiri_disliyor = sinir[1, ] > 0 | sinir[2, ] < 0)
boot_tablo <- boot_tablo[order(boot_tablo$olcu, match(boot_tablo$form, anlamsal_formlar),
                               match(boot_tablo$subscale, alt_boyutlar)), ]
rownames(boot_tablo) <- NULL
print(boot_tablo[boot_tablo$olcu == "rmse", ], digits = 3)
write.csv(boot_tablo, "html_ciktilari/bootstrap_farklar.csv", row.names = FALSE)
# ---- AS4: anlamsal çeşitlilik (SB) ve temsil (CL) -------------------------------------
as4_tablo <- yuzdelik[, c("form", "subscale", "SB", "SB_yzd", "CL", "CL_yzd")]
sb_cl <- data.frame(subscale = alt_boyutlar,
                    rho_SB_CL = sapply(alt_boyutlar, function(f) spearman(alt_kume[[f]]$SB, alt_kume[[f]]$CL)))
temsil <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  S <- formlar[[form]][[f]]; elenen <- setdiff(formlar$FULL42[[f]], S)
  en_yakin <- sapply(elenen, function(e) S[which.max(C[e, S])])          # elenen maddeye en yakın seçili madde
  uzaklik <- 1 - C[cbind(elenen, en_yakin)]
  data.frame(form = form, subscale = f, elenen = elenen, en_yakin = unname(en_yakin), uzaklik = uzaklik,
             en_zayif = uzaklik == max(uzaklik),
             elenen_metin = maddeler$text[match(elenen, maddeler$item_id)],
             en_yakin_metin = maddeler$text[match(en_yakin, maddeler$item_id)])
}))))
rownames(temsil) <- NULL
# Denetim: CL = elenen yedi maddenin uzaklıklarının toplamı / 14 (seçili maddeler sıfırla katılır)
stopifnot(all(abs(tapply(temsil$uzaklik, paste(temsil$form, temsil$subscale), sum)[paste(as4_tablo$form, as4_tablo$subscale)] / 14 -
                  as4_tablo$CL) < 1e-12))
print(as4_tablo, digits = 3); print(sb_cl, digits = 3)
print(temsil[temsil$en_zayif, c("form", "subscale", "elenen", "en_yakin", "uzaklik")], digits = 3)
write.csv(as4_tablo, "html_ciktilari/AS4_anlamsal.csv", row.names = FALSE)
write.csv(sb_cl, "html_ciktilari/AS4_SB_CL.csv", row.names = FALSE)
write.csv(temsil, "html_ciktilari/AS4_madde_temsil.csv", row.names = FALSE)
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
ggsave("html_ciktilari/sekil_AS5_alt_kume_testi.png", sekil2, width = 10, height = 6.8, dpi = 300, bg = "white")# ---- Sonuç: bütünleşik tablo ---------------------------------------------------------
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
# ---- Ek A: gömme modeli için sonradan eklenen betimsel denetim -------------------------
# Denetim, analiz örnekleminde kullanılmayan uygun kayıtlarda (10.362 - 4.000 = 6.362 kayıt) yapılır; böylece
# kalibrasyon ve değerlendirme gruplarının verisi iki kez kullanılmaz. Ölçütler araştırma sorularının
# sonuç göstergelerini kullanmaz. Denetim, form ve analiz kararları verildikten sonra eklenmiştir.
disari <- setdiff(uygun, secilen)
R_disari <- cor(Y[disari, ] - 1)                                            # 42 x 42 görgül madde korelasyonu

tfidf <- function(metin, kimlik) {                                          # sözcüksel temel çizgi
  s <- lapply(strsplit(gsub("[^a-z']+", " ", tolower(metin)), " "), function(x) x[nzchar(x)])
  sozluk <- sort(unique(unlist(s)))
  tf <- t(vapply(s, function(x) as.numeric(table(factor(x, levels = sozluk))), numeric(length(sozluk))))
  w <- sweep(tf, 2, log(length(metin) / colSums(tf > 0)), "*"); rownames(w) <- kimlik; w
}
boyutlar <- c(3072, 1536, 1024, 512, 256)                                   # ilk d bileşen; kosinüs yeniden ölçekler
temsiller <- c(setNames(lapply(boyutlar, function(d) cosine_matrix(E[, 1:d, drop = FALSE])), boyutlar),
               list(`TF-IDF` = cosine_matrix(tfidf(maddeler$text, maddeler$item_id))))
# İsteğe bağlı: girdiler/modeller/ klasöründe açık ağırlıklı modellerin vektörleri (emb_<model>.csv) varsa eklenir.
for (yol in list.files("girdiler/modeller", "^emb_.*[.]csv$", full.names = TRUE)) {
  ad <- sub("^emb_(.*)[.]csv$", "\\1", basename(yol))
  if (ad != "text-embedding-3-large") temsiller[[ad]] <- cosine_matrix(vektor_oku(yol))
}

alt_of <- setNames(rep(names(key42), lengths(key42)), item_id(unlist(key42)))[rownames(C)]
ust <- upper.tri(C); ic <- ust & outer(alt_of, alt_of, "==")                # 861 çift; 273 alt ölçek içi çift
alt_olcek_tahmini <- function(Cm) sapply(rownames(Cm), function(i)         # yanıt verisi kullanmaz
  names(which.max(sapply(names(key42), function(f) mean(Cm[i, setdiff(item_id(key42[[f]]), i)])))))
model_denetimi <- function(Cm, R) {
  Cm <- Cm[rownames(R), rownames(R)]
  ilk_k <- sapply(1:3, function(k) mean(sapply(rownames(R), function(i) {   # en yüksek r'li eş ilk k komşuda mı
    diger <- setdiff(rownames(R), i)
    names(which.max(abs(R[i, diger]))) %in% diger[order(-Cm[i, diger])][1:k]
  })))
  c(r_tum = cor(abs(Cm[ust]), abs(R[ust])), rho_tum = spearman(abs(Cm[ust]), abs(R[ust])),
    r_ic = cor(Cm[ic], R[ic]), rho_ic = spearman(Cm[ic], R[ic]),
    ilk1 = ilk_k[1], ilk2 = ilk_k[2], ilk3 = ilk_k[3], alt_olcek = mean(alt_olcek_tahmini(Cm) == alt_of[rownames(Cm)]))
}
denetim <- do.call(rbind, lapply(names(temsiller), function(m)
  data.frame(temsil = m, t(model_denetimi(temsiller[[m]], R_disari)))))
denetim$n <- length(disari)
print(denetim, digits = 3)
write.csv(denetim, "html_ciktilari/ekA_model_denetimi.csv", row.names = FALSE)
tahmin_as <- alt_olcek_tahmini(C)                                           # yanlış sınıflanan maddeler
print(data.frame(madde = names(tahmin_as), anahtar = alt_of[names(tahmin_as)], tahmin = tahmin_as)[tahmin_as != alt_of[names(tahmin_as)], ],
      row.names = FALSE)

# Formların temsile duyarlılığı: başka temsillerle kurulan formların ana formlarla ortak madde sayısı (7 üzerinden)
duyarlilik <- do.call(rbind, lapply(setdiff(names(temsiller), "3072"), function(m) {
  z <- form_olustur(temsiller[[m]])
  do.call(rbind, lapply(anlamsal_formlar, function(nm)
    data.frame(temsil = m, form = nm, t(sapply(alt_boyutlar, function(f) length(intersect(z[[nm]][[f]], formlar[[nm]][[f]])))))))
}))
rownames(duyarlilik) <- NULL
print(duyarlilik)
write.csv(duyarlilik, "html_ciktilari/ekA_form_duyarliligi.csv", row.names = FALSE)

# Şekil: kosinüs benzerliği ve görgül korelasyon (6.362 kayıt, 861 çift)
cift <- data.frame(kosinus = C[ust], r = R_disari[ust],
                   tur = ifelse(ic[ust], "Alt ölçek içi (273 çift)", "Alt ölçekler arası (588 çift)"))
sekil_ekA <- ggplot(cift, aes(x = kosinus, y = r, colour = tur)) +
  geom_point(size = 1.1, alpha = 0.65) +
  scale_colour_manual(values = c("Alt ölçek içi (273 çift)" = "#0072B2", "Alt ölçekler arası (588 çift)" = "grey62")) +
  labs(x = "Kosinüs benzerliği (text-embedding-3-large, 3072 boyut)",
       y = "Görgül madde korelasyonu (analiz dışı 6.362 kayıt)", colour = NULL) +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")
if (interactive()) print(sekil_ekA)
ggsave("html_ciktilari/sekil_ekA_kosinus_r.png", sekil_ekA, width = 6.8, height = 4.8, dpi = 300, bg = "white")
# ---- Ek B: COV21 eşit çözümleri ---------------------------------------------------------
# Aynı en küçük CL'yi veren bütün kümeler; kuralın seçtiği küme ile ortak madde sayıları ve bu kümelerin
# değerlendirme grubundaki alfa ve RMSE aralığı. En küçük CL ile ondan sonraki farklı CL arasındaki boşluk da verilir.
ekB <- do.call(rbind, lapply(alt_boyutlar, function(f) {
  ak <- alt_kume[[f]]; tv <- tum_alt[tum_alt$subscale == f & tum_alt$grup == "deg", ]
  esit <- ak$subset_key[ak$cov_esit_minimum]; sec <- anahtar_yap(formlar$COV21[[f]])
  ps <- tv[match(esit, tv$subset_key), ]
  ortak <- sapply(strsplit(esit, "|", fixed = TRUE), function(s) length(intersect(s, formlar$COV21[[f]])))
  cl <- sort(ak$CL); sonraki <- cl[cl > min(cl) + tol][1]
  data.frame(subscale = f, n_esit = length(esit), ortak_min = min(ortak),
             alfa_min = min(ps$alpha), alfa_maks = max(ps$alpha), alfa_COV21 = tv$alpha[tv$subset_key == sec],
             rmse_min = min(ps$rmse), rmse_maks = max(ps$rmse), rmse_COV21 = tv$rmse[tv$subset_key == sec],
             CL_min = min(cl), CL_bosluk = sonraki - min(cl))
}))
print(ekB, digits = 4)
write.csv(ekB, "html_ciktilari/ekB_COV21_esit_cozumler.csv", row.names = FALSE)
# ---- Ek C: yanıt kalitesi (VCL) duyarlılığı -----------------------------------------------
# Arşivdeki sözcük listesinde VCL6, VCL9 ve VCL12 uydurma sözcüklerdir. Bunlardan en az birini "biliyorum" (1)
# diye işaretleyen kayıtlar iki gruptan çıkarılır; AS1, AS2, AS3 ve AS5'in ana değerleri yeniden hesaplanır.
# Formlar, ISI ve bütün kümeler değişmez (bunlar yanıt verisi kullanmaz).
vcl_dislan <- apply(ham[secilen, c("VCL6", "VCL9", "VCL12")], 1, function(v) any(suppressWarnings(as.numeric(v)) %in% 1))
kal_v <- kal[!vcl_dislan[kal_sira], ]; deg_v <- deg[!vcl_dislan[deg_sira], ]
ekC_orneklem <- data.frame(grup = c("kal", "deg"), n_dislanan = c(sum(vcl_dislan[kal_sira]), sum(vcl_dislan[deg_sira])),
                           n_kalan = c(nrow(kal_v), nrow(deg_v)))
print(ekC_orneklem)
satir <- function(soru, form, f, olcu, deger, ana) data.frame(soru = soru, form = form, subscale = f, olcu = olcu,
                                                             deger = deger, ana_deger = ana, fark = deger - ana)
ekC <- list()
for (f in alt_boyutlar) {                                                    # AS1: kalibrasyon grubu
  havuz <- formlar$FULL42[[f]]; p <- grm_parameters(fit_grm(kal_v[, havuz])); p <- p[match(havuz, p$item_id), ]
  ekC[[length(ekC) + 1]] <- satir("AS1", "FULL42", f, "rho_ISI_a", spearman(ISI[[f]][havuz], p$a),
                                  as1_tablo$rho_ISI_a[as1_tablo$subscale == f & as1_tablo$grup == "kal"])
}
for (form in kisa_formlar) {                                                 # AS2 ve AS3: değerlendirme grubu
  om <- omega_values(fit_cfa(deg_v, formlar[[form]]))
  for (f in alt_boyutlar) {
    ana <- as2_guvenirlik[as2_guvenirlik$form == form & as2_guvenirlik$subscale == f, ]
    ekC[[length(ekC) + 1]] <- satir("AS2", form, f, "omega", as.numeric(om[f]), ana$omega)
    ekC[[length(ekC) + 1]] <- satir("AS2", form, f, "alfa", alpha_raw(deg_v[, formlar[[form]][[f]]]), ana$alfa)
    u <- uyum_olculeri(rowMeans(deg_v[, formlar[[form]][[f]]]), rowMeans(deg_v[, formlar$FULL42[[f]]]))
    ekC[[length(ekC) + 1]] <- satir("AS3", form, f, "rmse", u[["rmse"]],
                                    as3_uyum$rmse[as3_uyum$form == form & as3_uyum$subscale == f])
  }
}
for (f in alt_boyutlar) {                                                    # AS5: değerlendirme grubu
  ps <- alt_kume_psikometrik(deg_v, formlar$FULL42[[f]], alt_kume[[f]]$subset_key); kb <- alt_kume[[f]]$kanonik_bolme
  ana <- as5[as5$subscale == f & as5$grup == "deg", ]
  ekC[[length(ekC) + 1]] <- satir("AS5", NA, f, "rho_SB_alfa", spearman(alt_kume[[f]]$SB, ps$alpha), ana$rho_SB_alfa)
  ekC[[length(ekC) + 1]] <- satir("AS5", NA, f, "rho_CLb_rmse", spearman(alt_kume[[f]]$CL_b[kb], ps$rmse[kb]), ana$rho_CLb_rmse)
}
ekC <- do.call(rbind, ekC); rownames(ekC) <- NULL
ekC_ozet <- aggregate(cbind(en_buyuk_mutlak_fark = abs(fark)) ~ soru + olcu, data = ekC, FUN = max)
print(ekC_ozet, digits = 3)
write.csv(ekC_orneklem, "html_ciktilari/ekC_VCL_orneklem.csv", row.names = FALSE)
write.csv(ekC, "html_ciktilari/ekC_VCL_duyarlilik.csv", row.names = FALSE)
write.csv(ekC_ozet, "html_ciktilari/ekC_VCL_ozet.csv", row.names = FALSE)
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
# ---- Ek E: alfa farkları için eşleştirilmiş bootstrap -----------------------------------------
# Yeni hesap yapmaz; AS3'teki 2.000 bootstrap tekrarında hesaplanan alfa farklarını (anlamsal form eksi PUB21) yazar.
ekE <- boot_tablo[boot_tablo$olcu == "alfa", ]
print(ekE, digits = 3)
write.csv(ekE, "html_ciktilari/ekE_alfa_bootstrap.csv", row.names = FALSE)
