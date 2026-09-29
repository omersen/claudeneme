# =====================================================================================
#  DASS-42 ANLAMSAL KISA FORMLAR: ANALİZ BETİĞİ
#  Bu betik DASS42_rehber.html ile birlikte okunur. Betikteki her bölüm (ör. "BÖLÜM 2", "AS3"),
#  rehberde aynı adlı kod kutusunda açıklanır.
#
#  KLASÖR:  DASS42_analiz.R · DASS42_rehber.html · girdiler/
#           girdiler/DASS_data_21.02.19.zip   ham veri (Open-Source Psychometrics Project)
#           girdiler/orneklem_bolmesi.csv     beklenen örneklem ve grup bölmesi (denetim için)
#
#  NASIL ÇALIŞTIRILIR?
#   1. Bu dosyayı RStudio'da açın.
#   2. Menüden: Session > Set Working Directory > To Source File Location.
#   3. İlk çalıştırmada BÖLÜM 0'daki paket kurulumu ve API anahtarı adımlarını yapın.
#   4. Bölümleri sırayla çalıştırın (Ctrl+Enter) ya da hepsini birden: Source (Ctrl+Shift+S).
#  Bütün tablolar ve şekiller "ciktilar" klasörüne tezdeki numarasıyla yazılır
#  (Tablo01 ... Tablo14, EkTablo1, EkTablo2, Sekil1 ... Sekil6). Süre: yaklaşık 3-6 dakika.
# =====================================================================================


# ==== BÖLÜM 0: Kurulum: paketler, çalışma klasörü ve API anahtarı ======================
# (1) PAKETLER. İlk kez kullanıyorsanız aşağıdaki satırın başındaki # işaretini silip bir kez çalıştırın.
# install.packages(c("httr2", "jsonlite", "digest", "mirt", "lavaan", "semTools", "ggplot2"))
gerekli <- c("httr2", "jsonlite", "digest", "mirt", "lavaan", "semTools", "ggplot2")
eksik <- gerekli[!sapply(gerekli, requireNamespace, quietly = TRUE)]
if (length(eksik) > 0) stop("Kurulu olmayan paket(ler): ", paste(eksik, collapse = ", "),
                            "\nKurmak için: install.packages(c(\"", paste(eksik, collapse = "\", \""), "\"))")
library(mirt)      # aşamalı tepki modeli (GRM) ve test bilgisi
library(lavaan)    # doğrulayıcı faktör analizi (DFA)
library(semTools)  # kategorik omega
library(ggplot2)   # şekiller

# (2) ÇALIŞMA KLASÖRÜ: "girdiler" klasörünü içeren klasör olmalıdır.
if (!dir.exists("girdiler") && interactive()) {
  message("'girdiler' klasörü bulunamadı. Açılan pencerede DASS42_analiz.R dosyasını seçin.")
  setwd(dirname(file.choose()))
}
if (!dir.exists("girdiler")) stop("Çalışma klasörü yanlış: 'girdiler' klasörünü içeren klasörü seçin.")
dir.create("ciktilar", showWarnings = FALSE)

# (3) RASTGELE SAYI ÜRETECİ: örneklem seçimi ve bootstrap her bilgisayarda aynı sonucu verir.
RNGkind("Mersenne-Twister", "Inversion", "Rejection")

# (4) API ANAHTARI. Anahtar bu dosyaya YAZILMAZ. İki yoldan biri kullanılır:
#  (a) Yalnız bu oturum için, konsolda bir kez:  Sys.setenv(OPENAI_API_KEY = "sk-...")
#  (b) Kalıcı olarak: konsolda file.edit("~/.Renviron") yazın, açılan dosyaya
#      OPENAI_API_KEY=sk-...  satırını ekleyin, kaydedin ve R'yi yeniden başlatın.
# Anahtar yalnız BÖLÜM 2'de, vektör dosyası (girdiler/gomme_vektorleri.csv) henüz yoksa kullanılır.
if (!file.exists("girdiler/gomme_vektorleri.csv") && !nzchar(Sys.getenv("OPENAI_API_KEY")))
  message("Uyarı: OPENAI_API_KEY tanımlı değil. BÖLÜM 2'den önce yukarıdaki (a) ya da (b) adımını yapın.")


# ==== BÖLÜM 1: Verinin yüklenmesi, örneklem ve gruplar ==================================
# Veri: Open-Source Psychometrics Project DASS arşivi (39.775 kayıt). Dosyanın değişmediği denetlenir.
zip_yolu <- "girdiler/DASS_data_21.02.19.zip"
if (digest::digest(file = zip_yolu, algo = "sha256") != "38d1707cf1f9effec45c41f61c4fdc0ab245021da635a57a7f0e69edd965f3f5")
  stop("girdiler/DASS_data_21.02.19.zip paketteki dosyayla aynı değil. Dosyayı paketten yeniden kopyalayın.")
icerik <- unzip(zip_yolu, list = TRUE)$Name
ham <- read.delim(unz(zip_yolu, icerik[grepl("data[.]csv$", icerik)]), sep = "\t", quote = "",
                  stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Ölçeğin yapısı: DASS-42 alt boyutları ve yayımlanmış DASS-21 (PUB21) maddeleri (DASS-42 numarasıyla).
key42 <- list(D = c(3, 5, 10, 13, 16, 17, 21, 24, 26, 31, 34, 37, 38, 42),
              A = c(2, 4, 7, 9, 15, 19, 20, 23, 25, 28, 30, 36, 40, 41),
              S = c(1, 6, 8, 11, 12, 14, 18, 22, 27, 29, 32, 33, 35, 39))
key21 <- list(D = c(3, 10, 17, 26, 31, 38, 42), A = c(2, 4, 20, 25, 28, 40, 41), S = c(6, 8, 12, 18, 22, 35, 39))
Q <- function(x) sprintf("Q%02d", x)
alt_boyutlar <- c("D", "A", "S")

# Madde metinleri arşivin kod kitabından alınır (API'ye yalnız bu 42 metin gönderilir).
kitap <- readLines(unz(zip_yolu, icerik[grepl("codebook[.]txt$", icerik)]), warn = FALSE, encoding = "UTF-8")
satir <- kitap[grepl("^Q[0-9]+\t", kitap)]
metin <- sub("^Q[0-9]+\t", "", satir)
metin <- gsub("&#39;|&apos;", "'", metin); metin <- gsub("&quot;", '"', metin, fixed = TRUE)
metin <- trimws(gsub("[[:space:]]+", " ", gsub("&amp;", "&", metin, fixed = TRUE)))
maddeler <- data.frame(item_id = sprintf("Q%02d", as.integer(sub("^Q([0-9]+)\t.*$", "\\1", satir))), text = metin)
maddeler <- maddeler[order(maddeler$item_id), ]
maddeler$alt_boyut <- sapply(1:42, function(i) names(key42)[sapply(key42, function(k) i %in% k)])
maddeler$PUB21 <- as.integer(1:42 %in% unlist(key21))
write.csv(maddeler, "ciktilar/maddeler.csv", row.names = FALSE)

# Yanıtlar: Q1A-Q42A sütunları, 1-4 kodlu. Analizde 0-3'e çevrilir.
Y <- as.data.frame(lapply(ham[, paste0("Q", 1:42, "A")], function(x) suppressWarnings(as.numeric(x))))
names(Y) <- sprintf("Q%02d", 1:42)
yas <- suppressWarnings(as.numeric(ham$age))
anadil <- suppressWarnings(as.numeric(ham$engnat))      # 1 = ana dili İngilizce
cinsiyet <- suppressWarnings(as.numeric(ham$gender))    # 1 erkek, 2 kadın, 3 diğer

# Uygunluk ölçütleri: 18-80 yaş, ana dili İngilizce, 42 maddenin tamamı 1-4 aralığında yanıtlanmış.
yas_ok <- !is.na(yas) & yas >= 18 & yas <= 80
dil_ok <- !is.na(anadil) & anadil == 1
tam_ok <- apply(as.matrix(Y), 1, function(x) all(x %in% 1:4))
# Yanıt kalitesi: arşivdeki sözcük listesinde VCL6, VCL9 ve VCL12 gerçekte olmayan (uydurma) sözcüklerdir.
# Bunlardan en az birini "biliyorum" (1) diye işaretleyen kayıt, dikkatsiz yanıt olasılığı nedeniyle dışlanır.
vcl_ok <- rowSums(sapply(ham[, c("VCL6", "VCL9", "VCL12")], function(x) suppressWarnings(as.numeric(x)) %in% 1)) == 0
uygun <- which(yas_ok & dil_ok & tam_ok & vcl_ok)

# Uygun kayıtlardan 4.000 kişi seçilir ve iki eşit gruba ayrılır (sabit tohumlarla).
set.seed(20260905); secilen <- sort(sample(uygun, 4000))
set.seed(260905);   kal_sira <- sort(sample(seq_along(secilen), 2000))
deg_sira <- setdiff(seq_along(secilen), kal_sira)
bolme <- data.frame(source_row = secilen, split = ifelse(seq_along(secilen) %in% kal_sira, "calibration", "validation"))
beklenen <- read.csv("girdiler/orneklem_bolmesi.csv")   # beklenen bölme: her bilgisayarda aynı olmalıdır
if (!identical(beklenen, bolme)) stop("Örneklem bölmesi beklenenden farklı çıktı. girdiler/orneklem_bolmesi.csv değiştirilmiş olabilir;\n",
                                      "girdiler/ klasörünü paketteki hâline getirin (rehber: Sık karşılaşılan mesajlar).")

X <- Y[secilen, ] - 1; rownames(X) <- NULL             # yanıtlar 0-3
kal <- X[kal_sira, ]                                    # kalibrasyon grubu (2.000)
deg <- X[deg_sira, ]                                    # değerlendirme grubu (2.000)
# Seçilen 4.000 kişinin verisi okunabilir bir dosyaya da yazılır. RStudio'da View(read.csv(...)) ile incelenebilir;
# Excel'de çift tıklamak yerine Veri > Metinden/CSV'den ile (virgül ayırıcı, ondalık nokta) açılmalıdır.
write.csv(data.frame(source_row = secilen, grup = ifelse(bolme$split == "calibration", "kalibrasyon", "degerlendirme"),
                     yas = yas[secilen], cinsiyet = cinsiyet[secilen], X),
          "ciktilar/orneklem_verisi.csv", row.names = FALSE)

orneklem_akisi <- data.frame(
  asama = c("Ham kayıt", "18-80 yaş", "Ana dili İngilizce", "42 madde eksiksiz",
            "Uydurma sözcük işaretlemeyen (VCL)", "Seçilen örneklem", "Kalibrasyon grubu", "Değerlendirme grubu"),
  n = c(nrow(ham), sum(yas_ok), sum(yas_ok & dil_ok), sum(yas_ok & dil_ok & tam_ok), length(uygun), 4000,
        nrow(kal), nrow(deg)))
betimle <- function(i, ad) data.frame(grup = ad, n = length(i), yas_ort = mean(yas[i]), yas_ss = sd(yas[i]),
  kadin_yzd = 100 * mean(cinsiyet[i] %in% 2), erkek_yzd = 100 * mean(cinsiyet[i] %in% 1),
  diger_yzd = 100 * mean(cinsiyet[i] %in% 3), yanitsiz_yzd = 100 * mean(!cinsiyet[i] %in% 1:3))
orneklem_betim <- rbind(betimle(secilen, "Toplam"), betimle(secilen[kal_sira], "Kalibrasyon"),
                        betimle(secilen[deg_sira], "Değerlendirme"))
print(orneklem_akisi); print(orneklem_betim, digits = 3)
write.csv(orneklem_akisi, "ciktilar/Tablo01_orneklem_akisi.csv", row.names = FALSE)
write.csv(orneklem_betim, "ciktilar/Tablo02_betimsel.csv", row.names = FALSE)


# ==== BÖLÜM 2: Gömme vektörlerinin API ile üretilmesi ===================================
# Model: OpenAI text-embedding-3-large (3.072 boyut). 42 madde metni tek istekte gönderilir;
# katılımcı verisi gönderilmez. Vektörler bir kez üretilir ve girdiler/gomme_vektorleri.csv
# dosyasına kaydedilir. Bu dosya artık verinin parçasıdır: SİLMEYİN. Dosya varken API çağrılmaz;
# böylece sonraki bütün çalıştırmalar (ve tezdeki bütün sayılar) aynı vektörlere dayanır.
vektor_dosyasi <- "girdiler/gomme_vektorleri.csv"
if (!file.exists(vektor_dosyasi)) {
  anahtar <- Sys.getenv("OPENAI_API_KEY")
  if (!nzchar(anahtar)) stop("OPENAI_API_KEY tanımlı değil (BÖLÜM 0, adım 4).")
  istek <- httr2::request("https://api.openai.com/v1/embeddings") |>
    httr2::req_auth_bearer_token(anahtar) |>
    httr2::req_body_json(list(model = "text-embedding-3-large", input = as.list(maddeler$text))) |>
    httr2::req_timeout(120)
  yanit <- tryCatch(httr2::req_perform(istek), error = function(e)
    stop("API isteği tamamlanamadı: ", conditionMessage(e),
         "\nAnahtarı, internet bağlantısını ve API hesabının bakiyesini denetleyin.", call. = FALSE))
  rm(anahtar, istek)
  yanit <- httr2::resp_body_json(yanit)
  stopifnot(startsWith(yanit$model, "text-embedding-3-large"), length(yanit$data) == 42)
  sira <- sapply(yanit$data, function(d) d$index)                 # yanıt, gönderilen sıraya göre dizilir
  E <- t(sapply(yanit$data[order(sira)], function(d) unlist(d$embedding)))
  write.csv(data.frame(item_id = maddeler$item_id, E), vektor_dosyasi, row.names = FALSE)
  jsonlite::write_json(list(model = yanit$model, tarih_utc = format(Sys.time(), tz = "UTC"),
                            madde_sayisi = nrow(E), boyut = ncol(E),
                            sha256 = digest::digest(file = vektor_dosyasi, algo = "sha256")),
                       "girdiler/gomme_vektorleri_kaydi.json", auto_unbox = TRUE, pretty = TRUE)
}
vek <- read.csv(vektor_dosyasi)
E <- as.matrix(vek[, -1]); rownames(E) <- vek$item_id
stopifnot(identical(rownames(E), maddeler$item_id), ncol(E) == 3072, all(is.finite(E)))


# ==== BÖLÜM 3: Yardımcı fonksiyonlar ve sabitler ========================================
kisa_formlar <- c("PUB21", "MIN21", "MAX21", "COV21")
tol <- 1e-12                                                   # sayısal eşitlik toleransı
renk <- c(PUB21 = "black", MIN21 = "#0072B2", MAX21 = "#D55E00", COV21 = "#009E73")   # şekillerde
isaret <- c(PUB21 = 15, MIN21 = 16, MAX21 = 17, COV21 = 18)
alt_ad <- c(D = "Depresyon", A = "Anksiyete", S = "Stres")

# Kosinüs benzerliği matrisi: her vektör birim uzunluğa getirilir, iç çarpımlar alınır.
kosinus <- function(E) { B <- E / sqrt(rowSums(E^2)); C <- tcrossprod(B); diag(C) <- 1; C }
# ISI: bir maddenin aynı alt boyuttaki diğer 13 maddeyle ortalama kosinüsü.
isi <- function(Cf) (rowSums(Cf) - 1) / (nrow(Cf) - 1)
# Sıralama: eşit değerlerde küçük madde numarası önce gelir.
sirala <- function(v) { v <- round(v, 12); names(v)[order(v, names(v))] }
# SB, CL ve CL_b: seçilen yedi maddenin (S) anlamsal göstergeleri.
# ort(): değerler sıralanıp toplanır; böylece aynı sayılardan oluşan kümeler tam olarak aynı sonucu verir.
ort <- function(x) sum(sort(x)) / length(x)
anlamsal <- function(Cf, S) {
  R <- setdiff(rownames(Cf), S); w <- Cf[S, S]
  c(SB   = 1 - ort(w[upper.tri(w)]),                                    # 21 çiftin ortalama uzaklığı
    CL   = ort(1 - apply(Cf[, S], 1, max)),                             # 14 maddenin en yakın seçili maddeye uzaklığı
    CL_b = ort(c(1 - apply(Cf[R, S], 1, max), 1 - apply(Cf[S, R], 1, max))))  # iki yarının karşılıklı uzaklığı
}
# Ham alfa, orta sıra yüzdeliği ve Spearman korelasyonu.
alfa <- function(X) { V <- cov(as.matrix(X)); k <- ncol(V); k / (k - 1) * (1 - sum(diag(V)) / sum(V)) }
yuzdelik <- function(dagilim, deger) 100 * (mean(dagilim < deger - tol) + 0.5 * mean(abs(dagilim - deger) <= tol))
spearman <- function(x, y) cor(x, y, method = "spearman")
# Kısa (7 madde) ve tam (14 madde) puan uyumu. Girdiler madde TOPLAMLARIDIR.
# Kısa ortalama - tam ortalama = (2 x kısa toplam - tam toplam) / 14. Tamsayılarla hesaplandığı için
# bir küme ile tümleyeni tam olarak aynı RMSE'yi verir (0-3 madde ortalaması biriminde).
uyum <- function(kisa_toplam, tam_toplam) {
  D <- 2 * kisa_toplam - tam_toplam; n <- length(D)              # D / 14 = kısa ortalama - tam ortalama
  c(r = cor(kisa_toplam, tam_toplam),
    ortalama_fark = sum(D) / (14 * n),                              # ortalama (sistematik) fark
    sd_d = sqrt(n * sum(D^2) - sum(D)^2) / (14 * n),                # farkların standart sapması (n paydalı)
    rmse = sqrt(sum(D^2) / n) / 14)                                 # RMSE^2 = ortalama_fark^2 + sd_d^2
}
# Modeller: tek boyutlu GRM ve üç ilişkili faktörlü sıralı DFA. Yakınsama denetlenir.
grm <- function(X) { m <- mirt(X, 1, itemtype = "graded", SE = FALSE, verbose = FALSE,
                               technical = list(NCYCLES = 2000L), TOL = 1e-4)
  stopifnot(extract.mirt(m, "converged")); m }
dfa <- function(X, form) {
  model <- paste(sapply(names(form), function(f) paste(f, "=~", paste(form[[f]], collapse = " + "))), collapse = "\n")
  ids <- unlist(form)
  fit <- cfa(model, data = X[, ids], ordered = ids, estimator = "WLSMV", std.lv = TRUE)
  stopifnot(lavInspect(fit, "converged")); fit
}
# Kategorik omega (Green ve Yang, 2009): sıralı toplam puanın güvenirliği (ord.scale = TRUE).
omega <- function(fit) {
  z <- compRelSEM(fit, tau.eq = FALSE, ord.scale = TRUE, obs.var = FALSE)
  sapply(alt_boyutlar, function(f) as.numeric(z[[f]]))
}


# ==== BÖLÜM 4: Anlamsal göstergeler ve dört kısa form ==================================
C <- kosinus(E)                                                # 42 x 42 kosinüs benzerliği
formlar <- list(FULL42 = lapply(key42, Q), PUB21 = lapply(key21, Q), MIN21 = list(), MAX21 = list(), COV21 = list())
ISI <- list(); kumeler <- list(); cov_esit <- c()
for (f in alt_boyutlar) {
  havuz <- Q(key42[[f]]); Cf <- C[havuz, havuz]
  ISI[[f]] <- isi(Cf)
  sira <- sirala(ISI[[f]])
  formlar$MIN21[[f]] <- sort(sira[1:7])                        # ISI'si en düşük yedi madde
  formlar$MAX21[[f]] <- sort(sira[8:14])                       # ISI'si en yüksek yedi madde
  # Bir alt boyuttan seçilebilecek 3.432 yedili kümenin tamamı ve anlamsal göstergeleri
  komb <- combn(havuz, 7)
  anahtar <- apply(komb, 2, paste, collapse = "|")
  olc <- t(apply(komb, 2, function(s) anlamsal(Cf, s)))
  kumeler[[f]] <- data.frame(anahtar, olc, kanonik = komb[1, ] == havuz[1])  # kanonik: her bölünme bir kez
  en_iyi <- which(abs(kumeler[[f]]$CL - min(kumeler[[f]]$CL)) <= tol)    # CL'si en küçük küme(ler)
  cov_esit[f] <- length(en_iyi)
  # Eşitlikte: maddeleri küçükten büyüğe dizilmiş anahtarlar arasında sözlük sırasında ilk gelen küme alınır.
  formlar$COV21[[f]] <- strsplit(sort(anahtar[en_iyi])[1], "|", fixed = TRUE)[[1]]
}
form_tablosu <- do.call(rbind, lapply(kisa_formlar, function(nm) data.frame(form = nm, alt_boyut = alt_boyutlar,
  maddeler = sapply(alt_boyutlar, function(f) paste(as.integer(sub("Q", "", formlar[[nm]][[f]])), collapse = ", ")),
  cov_esit_cozum = if (nm == "COV21") cov_esit else NA)))
print(form_tablosu, row.names = FALSE)
write.csv(form_tablosu, "ciktilar/Tablo03_formlar.csv", row.names = FALSE)

# Şekil 1: 42 maddenin kosinüs benzerliği ısı haritası (alt boyut sırasıyla; * yayımlanmış DASS-21 maddesi)
sira42 <- Q(unlist(key42)); etiket42 <- paste0(sub("Q", "", sira42), ifelse(sira42 %in% unlist(formlar$PUB21), "*", ""))
isi_veri <- expand.grid(i = factor(sira42, sira42), j = factor(sira42, rev(sira42)))
isi_veri$kosinus <- C[cbind(as.character(isi_veri$i), as.character(isi_veri$j))]
ggsave("ciktilar/Sekil1_kosinus_isi_haritasi.png", width = 8.5, height = 7.8, dpi = 200, bg = "white",
  ggplot(isi_veri, aes(i, j, fill = kosinus)) + geom_tile() +
    geom_vline(xintercept = c(14.5, 28.5)) + geom_hline(yintercept = c(14.5, 28.5)) +
    scale_fill_gradient(low = "white", high = "#0B4F8A", limits = c(0, 1), name = "Kosinüs") +
    scale_x_discrete(labels = etiket42) + scale_y_discrete(labels = rev(etiket42)) +
    labs(x = "Depresyon | Anksiyete | Stres", y = NULL) + coord_fixed() + theme_minimal(base_size = 9) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5), panel.grid = element_blank()))
# Şekil 1'in notu için: alt boyut içi (köşegen) ve alt boyutlar arası ortalama kosinüs benzerliği
blok <- sapply(alt_boyutlar, function(a) sapply(alt_boyutlar, function(b) {
  M <- C[Q(key42[[a]]), Q(key42[[b]])]; if (a == b) mean(M[upper.tri(M)]) else mean(M) }))
print(round(blok, 3))
write.csv(data.frame(alt_boyut = alt_boyutlar, blok), "ciktilar/Sekil1_not_blok_ortalamalari.csv", row.names = FALSE)


# ==== BÖLÜM 5: Bütün yedili kümelerin psikometrik değerleri (tam sayım) ================
# Her küme için değerlendirme grubunda: alfa, kısa-tam r, ortalama fark, s_d ve RMSE (0-3 biriminde).
for (f in alt_boyutlar) {
  havuz <- Q(key42[[f]]); Xf <- as.matrix(deg[, havuz]); tam <- rowSums(Xf)
  ps <- t(apply(combn(havuz, 7), 2, function(s)
    c(alfa = alfa(Xf[, s]), uyum(rowSums(Xf[, s]), tam))))
  kumeler[[f]] <- cbind(kumeler[[f]], ps)
}
# Dört formun bu dağılımlardaki konumu (orta sıra yüzdeliği; 3.432 küme içinde)
konum <- do.call(rbind, lapply(kisa_formlar, function(nm) do.call(rbind, lapply(alt_boyutlar, function(f) {
  k <- kumeler[[f]]; i <- match(paste(sort(formlar[[nm]][[f]]), collapse = "|"), k$anahtar)
  data.frame(form = nm, alt_boyut = f, alfa_yzd = yuzdelik(k$alfa, k$alfa[i]), rmse_yzd = yuzdelik(k$rmse, k$rmse[i]),
             SB = k$SB[i], SB_yzd = yuzdelik(k$SB, k$SB[i]), CL = k$CL[i], CL_yzd = yuzdelik(k$CL, k$CL[i]))
}))))
# Ek Tablo 1: bütün kümelerde alfa, RMSE ve kısa-tam r'nin aralığı
dagilim <- do.call(rbind, lapply(alt_boyutlar, function(f) { k <- kumeler[[f]]
  data.frame(alt_boyut = f, alfa_min = min(k$alfa), alfa_medyan = median(k$alfa), alfa_maks = max(k$alfa),
             rmse_min = min(k$rmse), rmse_medyan = median(k$rmse), rmse_maks = max(k$rmse),
             r_min = min(k$r), r_medyan = median(k$r)) }))
print(dagilim, digits = 3)
write.csv(dagilim, "ciktilar/EkTablo1_kume_dagilimi.csv", row.names = FALSE)


# ==== AS1: Anlamsal benzerlik (ISI) ile GRM ayırt ediciliği (a) =========================
as1 <- list(); param <- list(); grm_deg <- list()
for (f in alt_boyutlar) {
  havuz <- Q(key42[[f]])
  for (g in c("kalibrasyon", "degerlendirme")) {
    Xg <- if (g == "kalibrasyon") kal[, havuz] else deg[, havuz]
    m <- grm(Xg); if (g == "degerlendirme") grm_deg[[f]] <- m  # değerlendirme modeli AS3 ve AS4'te kullanılır
    a <- coef(m, IRTpars = TRUE, simplify = TRUE)$items[havuz, "a"]
    citc <- sapply(havuz, function(j) cor(Xg[[j]], rowSums(Xg[, setdiff(havuz, j)])))  # düzeltilmiş madde-toplam r
    q3 <- residuals(m, type = "Q3", verbose = FALSE); q3 <- q3 - mean(q3[upper.tri(q3)])  # ortalaması çıkarılmış Q3
    c2 <- M2(m, type = "C2")                                    # C2 temelli model uyumu
    as1[[paste(f, g)]] <- data.frame(alt_boyut = f, grup = g, rho_ISI_a = spearman(ISI[[f]], a),
      rho_ISI_CITC = spearman(ISI[[f]], citc), rho_a_CITC = spearman(a, citc),
      C2_RMSEA = c2$RMSEA, SRMSR = c2$SRMSR, maks_Q3 = max(q3[upper.tri(q3)]),
      rho_kosinus_Q3 = spearman(C[havuz, havuz][upper.tri(q3)], q3[upper.tri(q3)]))
    if (g == "kalibrasyon") {
      b <- coef(m, IRTpars = TRUE, simplify = TRUE)$items[havuz, c("b1", "b2", "b3")]
      param[[f]] <- data.frame(alt_boyut = f, madde = havuz, ISI = ISI[[f]], a = a, b, CITC = citc,
        formlar = sapply(havuz, function(j) paste(kisa_formlar[sapply(kisa_formlar, function(nm) j %in% formlar[[nm]][[f]])], collapse = " ")))
    }
  }
}
as1 <- do.call(rbind, as1); param <- do.call(rbind, param)
print(as1, digits = 2, row.names = FALSE)
write.csv(as1, "ciktilar/Tablo04_AS1_ISI_a_ve_GRM_tanisi.csv", row.names = FALSE)
write.csv(param, "ciktilar/Tablo05_AS1_madde_parametreleri.csv", row.names = FALSE)
ggsave("ciktilar/Sekil2_AS1_ISI_a.png", width = 9, height = 3.6, dpi = 200, bg = "white",
  ggplot(param, aes(ISI, a, label = sub("Q", "", madde))) + geom_point(colour = "#0072B2") +
    geom_text(size = 2.6, vjust = -0.8) +
    facet_wrap(~ factor(alt_boyut, alt_boyutlar, alt_ad), scales = "free") +
    labs(x = "ISI (madde anlamsal benzerlik indeksi)", y = "GRM ayırt edicilik (a)") + theme_bw())


# ==== AS2: Anlamsal çeşitlilik (SB) ve temsil (CL) ======================================
# Her formda en zayıf temsil edilen madde: en yakın seçili maddeye uzaklığı en büyük olan elenen madde.
anlamsal_tablo <- do.call(rbind, lapply(kisa_formlar, function(nm) do.call(rbind, lapply(alt_boyutlar, function(f) {
  S <- formlar[[nm]][[f]]; el <- setdiff(Q(key42[[f]]), S)
  uz <- sapply(el, function(e) 1 - max(C[e, S])); e <- names(which.max(uz))
  data.frame(konum[konum$form == nm & konum$alt_boyut == f, c("form", "alt_boyut", "SB", "SB_yzd", "CL", "CL_yzd")],
             en_zayif = e, en_yakin_secili = S[which.max(C[e, S])], uzaklik = max(uz))
}))))
rho_SB_CL <- sapply(alt_boyutlar, function(f) spearman(kumeler[[f]]$SB, kumeler[[f]]$CL))
anlamsal_tablo$rho_SB_CL <- rho_SB_CL[anlamsal_tablo$alt_boyut]                       # bütün kümelerde; tablo notunda verilir
print(anlamsal_tablo, digits = 3, row.names = FALSE)
write.csv(anlamsal_tablo, "ciktilar/Tablo06_AS2_SB_CL.csv", row.names = FALSE)
# Şekil 3: 3.432 kümenin SB ve CL değerleri; dört form renkli
tum_SB_CL <- do.call(rbind, lapply(alt_boyutlar, function(f) data.frame(alt_boyut = f, SB = kumeler[[f]]$SB, CL = kumeler[[f]]$CL)))
ggsave("ciktilar/Sekil3_AS2_SB_CL.png", width = 9.5, height = 3.8, dpi = 200, bg = "white",
  ggplot(tum_SB_CL, aes(SB, CL)) + geom_point(colour = "grey75", size = 0.4) +
    geom_point(data = anlamsal_tablo, aes(colour = form, shape = form), size = 2.8) +
    facet_wrap(~ factor(alt_boyut, alt_boyutlar, alt_ad), scales = "free") +
    scale_colour_manual(values = renk, breaks = kisa_formlar) + scale_shape_manual(values = isaret, breaks = kisa_formlar) +
    labs(x = "Anlamsal çeşitlilik (SB)", y = "Temsil kaybı (CL)", colour = NULL, shape = NULL) +
    theme_bw() + theme(legend.position = "bottom"))


# ==== AS3: Faktör yapısı (üç faktörlü modelin uyumu) ve güvenirlik ========================
dfa_tablo <- list(); guvenirlik <- list()
for (nm in c("FULL42", kisa_formlar)) {
  fit <- dfa(deg, formlar[[nm]])                                # değerlendirme grubu
  u <- fitMeasures(fit, c("chisq.scaled", "df.scaled", "cfi.scaled", "tli.scaled", "rmsea.scaled",
                          "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled", "srmr"))
  lv <- lavInspect(fit, "cor.lv")                               # faktörler arası korelasyonlar
  dfa_tablo[[nm]] <- data.frame(form = nm, as.list(setNames(as.numeric(u), names(u))),
                                r_D_A = lv["D", "A"], r_D_S = lv["D", "S"], r_A_S = lv["A", "S"])
  guvenirlik[[nm]] <- data.frame(form = nm, alt_boyut = alt_boyutlar, omega = omega(fit),
                                 alfa = sapply(alt_boyutlar, function(f) alfa(deg[, formlar[[nm]][[f]]])))
}
dfa_tablo <- do.call(rbind, dfa_tablo); guvenirlik <- do.call(rbind, guvenirlik)
guvenirlik$alfa_yzd <- konum$alfa_yzd[match(paste(guvenirlik$form, guvenirlik$alt_boyut),
                                            paste(konum$form, konum$alt_boyut))]  # FULL42 için boş
print(dfa_tablo, digits = 3, row.names = FALSE); print(guvenirlik, digits = 3, row.names = FALSE)
write.csv(dfa_tablo, "ciktilar/Tablo07_AS3_DFA.csv", row.names = FALSE)
write.csv(guvenirlik, "ciktilar/Tablo08_AS3_guvenirlik.csv", row.names = FALSE)


# ==== AS3 (devam): Test bilgi fonksiyonu ==============================================
# AS1'de değerlendirme grubunda kestirilen 14 maddelik GRM kullanılır; yeni model kurulmaz.
# Bir formun bilgisi, yedi maddesinin madde bilgilerinin toplamıdır. SH(θ) = 1 / √bilgi.
theta <- seq(-3, 3, by = 0.05)
bilgi <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(c("FULL42", kisa_formlar), function(nm)
  data.frame(alt_boyut = f, form = nm, theta = theta,
             bilgi = testinfo(grm_deg[[f]], matrix(theta), which.items = match(formlar[[nm]][[f]], Q(key42[[f]]))))))))
bilgi_tablo <- bilgi[round(bilgi$theta, 2) %in% -2:2, ]
bilgi_tablo$SH <- 1 / sqrt(bilgi_tablo$bilgi)
print(bilgi_tablo, digits = 3, row.names = FALSE)
write.csv(bilgi_tablo, "ciktilar/Tablo09_AS3_test_bilgisi.csv", row.names = FALSE)
bilgi$Form <- factor(ifelse(bilgi$form == "FULL42", "Tam alt boyut (14 madde)", bilgi$form),
                     c("Tam alt boyut (14 madde)", kisa_formlar))
ggsave("ciktilar/Sekil4_AS3_test_bilgisi.png", width = 9.5, height = 4, dpi = 200, bg = "white",
  ggplot(bilgi, aes(theta, bilgi, colour = Form, linetype = Form)) + geom_line(linewidth = 0.8) +
    facet_wrap(~ factor(alt_boyut, alt_boyutlar, alt_ad)) +
    scale_colour_manual(values = c("Tam alt boyut (14 madde)" = "grey55", renk)) +
    scale_linetype_manual(values = c("dashed", rep("solid", 4))) +
    labs(x = "Örtük özellik düzeyi (θ)", y = "Test bilgisi", colour = NULL, linetype = NULL) +
    theme_bw() + theme(legend.position = "bottom"))


# ==== AS4: Kısa ve tam form puanlarının uyumu ===========================================
# Toplam puan uyumu: r, ortalama fark, s_d ve RMSE (0-3 madde ortalaması biriminde).
# θ uyumu: AS1'deki değerlendirme grubu GRM'sinin madde parametreleriyle, kısa formda yer almayan maddeler
# eksik sayılarak EAP kestirimi yapılır ve 14 maddelik θ ile karşılaştırılır (θ, standart sapma biriminde).
theta_tam <- lapply(alt_boyutlar, function(f) fscores(grm_deg[[f]], method = "EAP")[, 1]); names(theta_tam) <- alt_boyutlar
theta_uyum <- function(nm, f) {
  havuz <- Q(key42[[f]]); Xk <- as.matrix(deg[, havuz]); Xk[, !(havuz %in% formlar[[nm]][[f]])] <- NA
  kisa <- fscores(grm_deg[[f]], method = "EAP", response.pattern = Xk)[, "F1"]
  c(r_theta = cor(kisa, theta_tam[[f]]), rmse_theta = sqrt(mean((kisa - theta_tam[[f]])^2)))
}
uyum_tablo <- do.call(rbind, lapply(kisa_formlar, function(nm) do.call(rbind, lapply(alt_boyutlar, function(f) {
  u <- uyum(rowSums(deg[, formlar[[nm]][[f]]]), rowSums(deg[, Q(key42[[f]])]))
  data.frame(form = nm, alt_boyut = f, t(u), rmse_0_42 = 14 * u[["rmse"]], t(theta_uyum(nm, f)))
}))))
uyum_tablo$rmse_yzd <- konum$rmse_yzd
print(uyum_tablo, digits = 3, row.names = FALSE)
write.csv(uyum_tablo, "ciktilar/Tablo10_AS4_uyum.csv", row.names = FALSE)

# Eşleştirilmiş bootstrap (B = 2.000): her tekrarda çekilen aynı kişi örneklemi bütün formların hesabında kullanılır.
# Her tekrarda iki fark hesaplanır: RMSE farkı ve alfa farkı (anlamsal form eksi PUB21).
farklar <- function(ix) unlist(lapply(alt_boyutlar, function(f) {
  Xs <- deg[ix, ]; tam <- rowMeans(Xs[, Q(key42[[f]])])
  r <- sapply(kisa_formlar, function(nm) sqrt(mean((rowMeans(Xs[, formlar[[nm]][[f]]]) - tam)^2)))
  a <- sapply(kisa_formlar, function(nm) alfa(Xs[, formlar[[nm]][[f]]]))
  c(setNames(r[-1] - r[1], paste("RMSE", f, names(r)[-1])), setNames(a[-1] - a[1], paste("alfa", f, names(a)[-1])))
}))
cekim <- sapply(1:2000, function(b) { set.seed(20260913 + b); farklar(sample.int(2000, 2000, replace = TRUE)) })
tahmin <- farklar(1:2000)
parca <- do.call(rbind, strsplit(names(tahmin), " "))
boot <- data.frame(olcu = parca[, 1], alt_boyut = parca[, 2], form = parca[, 3], fark = tahmin,
                   alt = apply(cekim, 1, quantile, 0.025), ust = apply(cekim, 1, quantile, 0.975))
print(boot, digits = 3, row.names = FALSE)
write.csv(boot, "ciktilar/Tablo11_AS4_bootstrap.csv", row.names = FALSE)

# Ek Tablo 2: COV21 eşit çözümleri. Aynı en küçük CL'yi veren her küme için alfa ve RMSE ile PUB21'den farkların
# bootstrap aralıkları, yukarıdaki tohumlarla (aynı kişi örneklemleriyle) hesaplanır. Böylece COV21'e ilişkin
# karşılaştırmaların eşitlik bozma kuralına duyarlı olup olmadığı görülür.
cov_esitlik <- do.call(rbind, lapply(alt_boyutlar, function(f) {
  k <- kumeler[[f]]; esit <- which(abs(k$CL - min(k$CL)) <= tol)
  S_list <- strsplit(k$anahtar[esit], "|", fixed = TRUE)
  secilen_k <- k$anahtar == paste(sort(formlar$COV21[[f]]), collapse = "|")
  pub <- k$anahtar == paste(sort(formlar$PUB21[[f]]), collapse = "|")
  ortak <- sapply(S_list, function(s) length(intersect(s, formlar$COV21[[f]])))
  fark_esit <- function(ix) {                                  # her eşit küme için: küme eksi PUB21
    Xs <- deg[ix, ]; tam <- rowMeans(Xs[, Q(key42[[f]])]); P <- formlar$PUB21[[f]]
    r_pub <- sqrt(mean((rowMeans(Xs[, P]) - tam)^2)); a_pub <- alfa(Xs[, P])
    sapply(S_list, function(s) c(sqrt(mean((rowMeans(Xs[, s]) - tam)^2)) - r_pub, alfa(Xs[, s]) - a_pub))
  }
  ce <- lapply(1:2000, function(b) { set.seed(20260913 + b); fark_esit(sample.int(2000, 2000, replace = TRUE)) })
  sifir_disi <- function(o) {                                  # o = 1: RMSE, 2: alfa
    M <- matrix(sapply(ce, function(m) m[o, ]), nrow = length(S_list))
    sum(apply(M, 1, quantile, 0.025) > 0 | apply(M, 1, quantile, 0.975) < 0)
  }
  data.frame(alt_boyut = f, esit_kume = length(esit), en_az_ortak_madde = min(ortak),
             alfa_min = min(k$alfa[esit]), alfa_maks = max(k$alfa[esit]), alfa_COV21 = k$alfa[secilen_k], alfa_PUB21 = k$alfa[pub],
             alfa_fark_sifir_disi = sifir_disi(2),
             rmse_min = min(k$rmse[esit]), rmse_maks = max(k$rmse[esit]), rmse_COV21 = k$rmse[secilen_k], rmse_PUB21 = k$rmse[pub],
             rmse_fark_sifir_disi = sifir_disi(1))
}))
print(cov_esitlik, digits = 3)
write.csv(cov_esitlik, "ciktilar/EkTablo2_COV21_esit_cozumler.csv", row.names = FALSE)
# Şekil 5: farklar ve %95 aralıkları (sıfır çizgisi: PUB21 ile aynı)
boot$Olcu <- factor(boot$olcu, c("RMSE", "alfa"), c("RMSE farkı (pozitif: tam puandan daha çok sapma)",
                                                     "Alfa farkı (pozitif: PUB21'den yüksek alfa)"))
ggsave("ciktilar/Sekil5_AS4_PUB21_farklari.png", width = 9.5, height = 4.6, dpi = 200, bg = "white",
  ggplot(boot, aes(x = fark, xmin = alt, xmax = ust, y = factor(form, rev(kisa_formlar[-1])), colour = form, shape = form)) +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") + geom_pointrange(size = 0.4) +
    facet_grid(factor(alt_boyut, alt_boyutlar, alt_ad) ~ Olcu, scales = "free_x") +
    scale_colour_manual(values = renk) + scale_shape_manual(values = isaret) +
    labs(x = "Anlamsal form eksi PUB21 (%95 bootstrap aralığı)", y = NULL) +
    theme_bw() + theme(legend.position = "none"))

# Şiddet kategorisi uyumu: kısa form toplamı x 2, DASS-42 ölçeğine taşınır ve el kitabındaki
# kesme değerleriyle (Lovibond ve Lovibond, 1995) beş kategoriye ayrılır; tam formun kategorisiyle karşılaştırılır.
# Kategoriler: 1 normal, 2 hafif, 3 orta, 4 ağır, 5 çok ağır. Değerler her kategorinin alt sınırıdır.
kesme <- list(D = c(10, 14, 21, 28), A = c(8, 10, 15, 20), S = c(15, 19, 26, 34))
kategori <- function(puan, f) findInterval(puan, kesme[[f]]) + 1
agirlikli_kappa <- function(x, y, k = 5) {                     # karesel ağırlıklı kappa
  O <- table(factor(x, 1:k), factor(y, 1:k)) / length(x)
  E <- outer(rowSums(O), colSums(O)); W <- outer(1:k, 1:k, function(i, j) (i - j)^2)
  1 - sum(W * O) / sum(W * E)
}
siddet <- do.call(rbind, lapply(kisa_formlar, function(nm) do.call(rbind, lapply(alt_boyutlar, function(f) {
  tam_k <- kategori(rowSums(deg[, Q(key42[[f]])]), f)
  kisa_k <- kategori(2 * rowSums(deg[, formlar[[nm]][[f]]]), f)
  data.frame(form = nm, alt_boyut = f, ayni_kategori = 100 * mean(kisa_k == tam_k),
             en_fazla_bir_fark = 100 * mean(abs(kisa_k - tam_k) <= 1), agirlikli_kappa = agirlikli_kappa(kisa_k, tam_k))
}))))
# Tablo 12'nin notu için: tam formda kişilerin kategorilere dağılımı (%)
tam_dagilim <- sapply(alt_boyutlar, function(f) 100 * tabulate(kategori(rowSums(deg[, Q(key42[[f]])]), f), 5) / nrow(deg))
print(siddet, digits = 3, row.names = FALSE); print(round(tam_dagilim, 1))
write.csv(siddet, "ciktilar/Tablo12_AS4_siddet_kategorisi.csv", row.names = FALSE)
write.csv(data.frame(kategori = c("Normal", "Hafif", "Orta", "Ağır", "Çok ağır"), tam_dagilim),
          "ciktilar/Tablo12_not_tam_form_kategorileri.csv", row.names = FALSE)


# ==== AS5: Bütün yedili kümelerde anlamsal ve psikometrik göstergelerin ilişkisi ========
# SB-alfa: 3.432 kümede. CL_b-RMSE: bir küme ile tümleyeni aynı RMSE'yi verdiği için 1.716 bölünmede.
as5 <- do.call(rbind, lapply(alt_boyutlar, function(f) { k <- kumeler[[f]]; b <- k[k$kanonik, ]
  data.frame(alt_boyut = f, rho_SB_alfa = spearman(k$SB, k$alfa), rho_CLb_RMSE = spearman(b$CL_b, b$rmse),
             rho_CLb_sd = spearman(b$CL_b, b$sd_d), rho_CLb_ortfark = spearman(b$CL_b, abs(b$ortalama_fark))) }))
print(as5, digits = 2, row.names = FALSE)
write.csv(as5, "ciktilar/Tablo13_AS5_iliskiler.csv", row.names = FALSE)
paneller <- c("SB ve alfa (3.432 küme)", "CL_b ve RMSE (1.716 bölünme)")
nokta <- do.call(rbind, lapply(alt_boyutlar, function(f) { k <- kumeler[[f]]; b <- k[k$kanonik, ]
  rbind(data.frame(alt_boyut = f, panel = paneller[1], x = k$SB, y = k$alfa),
        data.frame(alt_boyut = f, panel = paneller[2], x = b$CL_b, y = b$rmse)) }))
formlar_nokta <- do.call(rbind, lapply(alt_boyutlar, function(f) do.call(rbind, lapply(kisa_formlar, function(nm) {
  k <- kumeler[[f]][match(paste(sort(formlar[[nm]][[f]]), collapse = "|"), kumeler[[f]]$anahtar), ]
  data.frame(alt_boyut = f, form = nm, panel = paneller, x = c(k$SB, k$CL_b), y = c(k$alfa, k$rmse)) }))))
nokta$panel <- factor(nokta$panel, paneller); formlar_nokta$panel <- factor(formlar_nokta$panel, paneller)
formlar_nokta$form <- factor(formlar_nokta$form, kisa_formlar)
ggsave("ciktilar/Sekil6_AS5_butun_kumeler.png", width = 10, height = 6.5, dpi = 200, bg = "white",
  ggplot(nokta, aes(x, y)) + geom_point(colour = "grey75", size = 0.4) +
    geom_point(data = formlar_nokta, aes(colour = form, shape = form), size = 2.6) +
    facet_wrap(panel ~ factor(alt_boyut, alt_boyutlar, alt_ad), scales = "free") +
    scale_colour_manual(values = renk) + scale_shape_manual(values = isaret) +
    labs(x = "Anlamsal gösterge (üst: SB, alt: CL_b)", y = "Psikometrik gösterge (üst: alfa, alt: RMSE)",
         colour = NULL, shape = NULL) + theme_bw() + theme(legend.position = "bottom"))


# ==== SONUÇ: Bütünleşik tablo (dört form yan yana) ======================================
butunlesik <- merge(konum[, c("form", "alt_boyut", "alfa_yzd", "rmse_yzd", "SB_yzd", "CL_yzd")],
                    guvenirlik[, c("form", "alt_boyut", "omega")])
butunlesik <- merge(butunlesik, siddet[, c("form", "alt_boyut", "ayni_kategori")])
butunlesik <- butunlesik[order(match(butunlesik$form, kisa_formlar), match(butunlesik$alt_boyut, alt_boyutlar)), ]
print(butunlesik, digits = 3, row.names = FALSE)
write.csv(butunlesik, "ciktilar/Tablo14_butunlesik.csv", row.names = FALSE)
writeLines(capture.output(sessionInfo()), "ciktilar/oturum_bilgisi.txt")
cat("Bitti. Tablolar (Tablo01-Tablo14, EkTablo1-2) ve şekiller (Sekil1-Sekil6) 'ciktilar' klasöründedir.\n")
