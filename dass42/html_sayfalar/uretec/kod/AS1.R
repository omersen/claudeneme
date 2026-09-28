# ---------------------------------------------------------------------------------------------
# OKUMA KILAVUZU (yukarıdaki satırlar bloğun bağlayıcı tanımıdır; aşağıdaki notlar yalnız kodu
# anlamayı kolaylaştırır ve tanımı değiştirmez)
#
# Araştırma sorusu 1 (AS1): DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer
#   maddelerle ortalama anlamsal benzerliği (ISI) ile GRM altında kestirilen ayırt edicilik
#   parametreleri (a) arasında nasıl bir ilişki vardır?
#
# Hangi veri hangi amaçla kullanılıyor?
#   ISI[[f]] : Yalnız madde METİNLERİNDEN gelir (gömme vektörlerinin kosinüs benzerliği). Bir maddenin
#              kendi alt boyutundaki diğer 13 maddeye anlamca ortalama ne kadar benzediğini gösterir.
#              Yanıt verisi kullanılmaz; bu yüzden iki grupta da aynıdır. MIN21 (en düşük ISI) ve
#              MAX21 (en yüksek ISI) formları bu değerlerle seçilmiştir.
#   kal, deg : Katılımcı YANITLARI (0-3). GRM ile her maddenin ayırt ediciliği (a) ve eşikleri (b1-b3)
#              kestirilir. kal (kalibrasyon, 2.000 kişi) ana analizdir. deg (değerlendirme, 2.000 kişi)
#              aynı analizin ikinci, örtüşmeyen bir katılımcı grubunda tekrarıdır (ISI değerleri aynı
#              kaldığı için tam bağımsız bir tekrar değildir; deg, hiç bakılmamış bir doğrulama
#              örneklemi olarak da sunulmaz).
#   C        : 42 x 42 kosinüs matrisi; bu da madde metinlerinden gelir. Adım 6'da madde ÇİFTLERİ
#              düzeyinde anlamsal yakınlık olarak kullanılır.
#   Analiz birimi: her alt boyutta 14 sabit madde; her ilişki 14 nokta (Adım 6'da 91 çift) üzerindedir.
#
# Nasıl yorumlanır? (ayrıntı: ANALIZ_REHBERI.md, AS1 bölümü ve genel yorum kuralları)
#   rho_ISI_a > 0 : aynı alt boyuttaki diğer maddelere anlamca ortalama daha benzer olan maddelerin a
#                   değeri, bu 14 maddede, daha yüksek olma eğilimindedir; rho_ISI_a < 0 ise tersi.
#                   |rho| < 0,30 zayıf, 0,30-0,50 orta, 0,50 ve üstü güçlü diye adlandırılır
#                   (adlandırmadır, başarı eşiği değildir).
#   Tutarlılık    : kal, deg ve CITC aynı yönü gösterirse ilişki tutarlı sayılır. CITC, GRM'den bağımsız
#                   bir göstergedir; yerel bağımlılıktan ise a kadar etkilenebilir.
#   Model uyumu   : GRM uyumu zayıfsa a, "bu model altında kestirilen ayırt edicilik" diye adlandırılır.
#                   Paket belgeleri "zayıf uyum" için sayısal eşik vermez; ölçüt tezin yöntem metninde
#                   danışmanla belirlenir (Adım 5'teki nota bakın).
#   Sınırlar      : 14 sabit maddeye ilişkin betimsel sonuçtur. Nedensellik (benzerlik ayırt ediciliği
#                   artırır) ve madde evrenine genelleme yapılmaz; güven aralığı ve p değeri verilmez.
#   Önceki çalışma: Kilmen ve Bulut (2025) ile yalnız yön düzeyinde karşılaştırılır; ölçek, örneklem ve
#                   gömme modeli (onlarda BERT) farklıdır. ECR kaygı alt boyutunda negatif ilişki
#                   (r = -0,55) bildirmişler, kaçınma alt boyutunda ise bu ilişkiyi gözlememişlerdir.
#                   Yön farklı çıkarsa bu, önceki sonucun yanlışlanması olarak değil, ilişkinin ölçeğe ve
#                   koşullara bağlı olabileceği biçiminde yazılır.
#   Hangi tablo?  : AS1'in yanıtı tablo_AS1_ISI_a.csv'dedir. _madde_parametreleri madde düzeyindeki
#                   değerleri, _GRM_tani, _kosinus_Q3 ve _kategori_kullanimi ise tanıları verir.
# ---------------------------------------------------------------------------------------------
as1_gruplar <- list(kal = kal, deg = deg)   # kal: ana analiz; deg: tekrar
as1_kategori <- list(); as1_parametre_listesi <- list(); as1_iliski <- list(); as1_tani <- list(); as1_q3 <- list()

for (f in alt_boyutlar) {                   # D = depresyon, A = kaygı, S = stres
  havuz <- formlar$FULL42[[f]]              # bu alt boyutun 14 maddesi, sabit sırada
  isi_f <- ISI[[f]][havuz]                  # metinden gelen ISI değerleri (havuz sırasında)
  C_f <- C[havuz, havuz]                    # 14 x 14 kosinüs benzerlikleri
  kontrol(paste0("AS1_ISI_sirasi_", f), identical(names(isi_f), havuz))

  for (g in names(as1_gruplar)) {
    Xg <- as1_gruplar[[g]][, havuz, drop = FALSE]   # 2.000 kişi x 14 madde
    etiket <- paste0(f, "_", g)

    # Adım 1. Kategori kullanımı (0, 1, 2, 3).
    #   Amaç: GRM'nin her madde için üç eşik kestirebilmesi dört kategorinin de gözlenmesine bağlıdır.
    #   Yorum: çok seyrek kullanılan bir kategori (özellikle 3) o maddenin b3 eşiğini belirsizleştirir.
    as1_kategori[[etiket]] <- do.call(rbind, lapply(havuz, function(i)
      data.frame(subscale = f, grup = g, item_id = i, kategori = 0:3,
                 n = vapply(0:3, function(k) sum(Xg[[i]] == k), integer(1)))))
    kontrol(paste0("AS1_kategori_toplami_", etiket), all(tapply(as1_kategori[[etiket]]$n,
      as1_kategori[[etiket]]$item_id, sum) == nrow(Xg)))

    # Adım 2. Tek boyutlu GRM (Samejima'nın dereceli tepki modeli), yalnız bu alt boyutun 14 maddesiyle.
    #   Amaç: her maddenin ayırt ediciliği (a) ve eşikleri (b1-b3).
    #   Yorum: a büyüdükçe madde, gizil düzeyi farklı kişileri daha keskin ayırır. b_k, k veya daha üst
    #   bir kategoride yanıt verme olasılığının %50 olduğu gizil düzeydir (standart birimde).
    mod <- fit_grm(Xg)
    p <- grm_parameters(mod)
    # a'yı ISI ile aynı madde sırasına getir; sıra kayarsa korelasyon yanlış maddeleri eşleştirir.
    p <- p[match(havuz, p$item_id), , drop = FALSE]; rownames(p) <- NULL
    kontrol(paste0("AS1_parametre_sirasi_", etiket), identical(p$item_id, havuz))

    # Adım 4 (Adım 3'teki ilişkilerde kullanıldığı için önce hesaplanır).
    #   CITC (düzeltilmiş madde-toplam korelasyonu): madde puanı ile aynı alt boyuttaki diğer 13
    #   maddenin toplamı arasındaki Pearson r. Buradaki "düzeltilmiş", maddenin toplamdan çıkarılması
    #   demektir. Amaç: GRM'ye bağlı olmayan destekleyici bir ayırt edicilik göstergesi.
    citc <- vapply(havuz, function(i)
      stats::cor(Xg[[i]], rowSums(Xg[, setdiff(havuz, i), drop = FALSE])), numeric(1))

    # Adım 3. AS1'in ana katsayısı: ISI ile a arasındaki Spearman sıra korelasyonu (14 madde).
    #   Açıklayıcı not (tanım değil): Spearman doğrusal olması gerekmeyen, tekdüze (monoton) ilişkiyi
    #   ölçer ve uç değerlere Pearson'dan daha az duyarlıdır.
    rho_ISI_a <- spearman(isi_f, p$a)
    rho_ISI_CITC <- spearman(isi_f, citc)   # ISI ile CITC: ana ilişkiyle aynı yönde mi?
    rho_a_CITC <- spearman(p$a, citc)       # a ile CITC: iki ayırt edicilik göstergesi birbirini tutuyor mu?

    as1_parametre_listesi[[etiket]] <- data.frame(subscale = f, grup = g, item_id = havuz, ISI = as.numeric(isi_f),
      a = p$a, b1 = p$b1, b2 = p$b2, b3 = p$b3, CITC = as.numeric(citc))
    as1_iliski[[etiket]] <- data.frame(subscale = f, grup = g, n_madde = length(havuz),
      rho_ISI_a = rho_ISI_a, rho_ISI_CITC = rho_ISI_CITC, rho_a_CITC = rho_a_CITC)

    # Adım 5. Model tanıları.
    #   C2 (Cai ve Monroe, 2014) temelli uyum: C2, df, p, RMSEA, SRMSR. GRM'nin bu 14 maddeye ne kadar
    #   uyduğunu gösterir. Büyük örneklemde (n = 2.000) kesin uyum neredeyse her zaman reddedilir;
    #   yaklaşık uyum RMSEA ve SRMSR ile birlikte değerlendirilir. Tabloda p = 0 görünmesi çok küçük bir
    #   değerin sıfıra yuvarlanmasıdır; "p < 0,001" diye yazılır.
    #   Uyum ölçütü hakkında not: Maydeu-Olivares ve Joe'nun (2014) eşikleri (RMSEA2 <= 0,05 yakın,
    #   <= 0,089 kabul edilebilir) M2 temelli RMSEA için önerilmiştir. C2 temelli RMSEA için doğrudan
    #   geçerli değildir; ancak yaklaşık bir okuma sağlar. SRMSR için 0,05 yakın uyum ölçütü olarak
    #   kullanılır (Maydeu-Olivares, 2013).
    #   Düzeltilmiş (ortalaması çıkarılmış) Q3 = ham Q3 eksi 91 çiftin ortalama Q3'ü. Ham Q3, ortak faktör
    #   denetlendikten sonra iki madde arasında kalan ilişkidir (yerel bağımlılık). Pozitif düzeltilmiş
    #   değer, çiftin kalan ilişkisinin ortalamanın üstünde olduğunu gösterir. q3_esik_ustu_cift,
    #   ortalamanın 0,20 üstündeki çiftlerin sayısıdır. Bu eşik Rasch modelleri için önerilmiş bir tarama
    #   ölçütüdür (Christensen, Makransky ve Horton, 2017); madde silme kararı için kullanılmaz.
    m2 <- tryCatch(uyarilari_kaydet(mirt::M2(mod, type = "C2")), error = function(e) {
      log_yaz("UYARI", "AS1 M2 (C2) hesaplanamadi:", etiket, conditionMessage(e)); NULL })
    m2_deger <- function(s) {
      if (is.null(m2)) return(NA_real_)
      if (!(s %in% names(m2))) { log_yaz("UYARI", "AS1 M2 sutunu yok:", s, etiket); return(NA_real_) }
      as.numeric(m2[[s]][1])
    }
    q <- q3_duzeltilmis(mod)
    kontrol(paste0("AS1_Q3_sirasi_", etiket), identical(rownames(q), havuz) && identical(colnames(q), havuz))
    ust <- upper.tri(q)   # her madde çifti bir kez (91 çift)
    as1_tani[[etiket]] <- data.frame(subscale = f, grup = g, C2 = m2_deger("M2"), df = m2_deger("df"),
      p = m2_deger("p"), RMSEA = m2_deger("RMSEA"), SRMSR = m2_deger("SRMSR"),
      maks_Q3 = max(q[ust]), q3_esik_ustu_cift = sum(q[ust] > cfg$q3_tarama_esigi))

    # Adım 6. Kosinüs benzerliği ile düzeltilmiş Q3 arasındaki Spearman ilişkisi (91 çift).
    #   Yorum: pozitifse, anlamca daha yakın madde çiftlerinde ortak faktörün açıklamadığı ilişki daha
    #   yüksek olma eğilimindedir. 91 çift ortak maddeler içerdiği için bağımsız gözlem değildir; bu
    #   ilişki a'daki veya güvenirlikteki olası şişmenin miktarını göstermez.
    rho_cos_Q3 <- spearman(C_f[ust], q[ust])
    q_ust <- q[ust]; satir <- row(q)[ust]; sutun <- col(q)[ust]
    en_yuksek <- order(q_ust, decreasing = TRUE)[1:3]   # en yüksek üç düzeltilmiş Q3
    as1_q3[[etiket]] <- do.call(rbind, lapply(seq_along(en_yuksek), function(s) {
      k <- en_yuksek[s]; i <- havuz[satir[k]]; j <- havuz[sutun[k]]   # üst üçgen: i havuzda j'den önce gelir
      # birlikte_formlar: yerel bağımlı çiftin hangi kısa formlarda birlikte kaldığı (betimsel bilgi).
      birlikte <- kisa_formlar[vapply(kisa_formlar, function(nm) all(c(i, j) %in% formlar[[nm]][[f]]), logical(1))]
      data.frame(subscale = f, grup = g, rho_cos_Q3 = rho_cos_Q3, sira = s, cift = paste0(i, "-", j),
                 Q3 = q_ust[k], kosinus = C_f[i, j],
                 birlikte_formlar = if (length(birlikte)) paste(birlikte, collapse = ", ") else "yok")
    }))

    # sonuc listesine yalnız hesaplanan nesneler atanır (kabul denetimi bu değerleri okur).
    sonuc[[paste0("AS1_rho_", g, "_", f)]] <- rho_ISI_a
    if (g == "kal") {
      sonuc[[paste0("AS1_rhoCITC_kal_", f)]] <- rho_ISI_CITC
      sonuc[[paste0("AS1_cosQ3_kal_", f)]] <- rho_cos_Q3
    }
  }
}

# Tablolar (satır sırası: alt boyut D, A, S; her alt boyutta önce kal, sonra deg).
as1_parametreler <- do.call(rbind, as1_parametre_listesi); rownames(as1_parametreler) <- NULL
csv_yaz(do.call(rbind, as1_kategori), "tablo_AS1_kategori_kullanimi.csv")
csv_yaz(as1_parametreler, "tablo_AS1_madde_parametreleri.csv")
csv_yaz(do.call(rbind, as1_iliski), "tablo_AS1_ISI_a.csv")
csv_yaz(do.call(rbind, as1_tani), "tablo_AS1_GRM_tani.csv")
csv_yaz(do.call(rbind, as1_q3), "tablo_AS1_kosinus_Q3.csv")
cat("\nAS1 özeti (ISI-a, ISI-CITC ve a-CITC Spearman katsayıları):\n")
print(do.call(rbind, as1_iliski), row.names = FALSE, digits = 3)
log_yaz("AS1_HAZIR")
