# ---- H3. Gömme modelinin seçimi ------------------------------------------------------------
# Amaç: madde metinlerini vektöre çeviren modeli, AS1-AS5 sonuçlarına bakmadan ve analizde kullanılan
#   4.000 kişiye dokunmadan seçmek. Ölçüt önceden belirlenmiştir:
#   ANA ÖLÇÜT: alt boyut içindeki madde çiftlerinde kosinüs benzerliği ile polikorik korelasyon arasındaki
#   Spearman ilişkisi. Çalışmadaki bütün anlamsal göstergeler (ISI, SB, CL) alt boyut içi benzerliklere
#   dayandığı için modelin tam da bu düzeyde yanıt verisindeki ilişkileri ne kadar izlediğine bakılır.
#   Veri: uygun havuzdaki, analize GİRMEYEN kayıtlar (10.362 - 4.000 = 6.362 kişi). Böylece model seçimi
#   kalibrasyon ve değerlendirme gruplarını etkilemez.
#   YAN ÖLÇÜTLER: bütün 861 çiftte aynı ilişki ve Top-3 doğruluğu (Ravenda vd., 2025 ile karşılaştırılabilir);
#   yanıt verisi kullanmayan alt boyut ayrışması (alt boyut içi eksi alt boyutlar arası ortalama kosinüs,
#   birini-dışarıda-bırak en yakın merkez doğruluğu).
# Girdiler: girdiler/modeller/emb_<model>.csv (42 madde x boyut). text-embedding-3-large vektörleri Ravenda vd.
#   (2025) yayın arşivindendir (OpenAI API'si yeniden çağrılmamıştır); açık modellerin vektörleri aynı madde
#   metinlerinden ONNX sürümleriyle yerel olarak üretilmiştir (üretim betiği: girdiler/modeller/uret.py).
secim_kayitlari <- setdiff(uygun, secilen)                       # analize girmeyen kayıtlar
kontrol("model_secim_grubu_ayrik", !length(intersect(secim_kayitlari, secilen)) && length(secim_kayitlari) == 6362L)
Xsec <- Y[secim_kayitlari, ] - 1
P_sec <- lavaan::lavCor(Xsec, ordered = names(Xsec))             # 42 x 42 polikorik korelasyon
alt_etiket <- setNames(rep(names(key42), lengths(key42)), item_id(unlist(key42)))[item_id(1:42)]
ust <- upper.tri(P_sec); ayni_alt <- outer(alt_etiket, alt_etiket, "==")
model_dosyalari <- list.files(file.path(cfg$girdi_klasoru, "modeller"), "^emb_.*[.]csv$", full.names = TRUE)
model_tablosu <- do.call(rbind, lapply(model_dosyalari, function(dosya) {
  tb <- utils::read.csv(dosya, check.names = FALSE); tb <- tb[match(item_id(1:42), tb$item_id), ]
  Em <- as.matrix(tb[, -1]); rownames(Em) <- tb$item_id
  Cm <- cosine_matrix(Em)
  ic <- ust & ayni_alt; dis <- ust & !ayni_alt
  rho_f <- vapply(alt_boyutlar, function(f) { h <- item_id(key42[[f]]); u <- upper.tri(Cm[h, h])
    spearman(Cm[h, h][u], P_sec[h, h][u]) }, numeric(1))
  data.frame(model = sub("^emb_(.*)[.]csv$", "\\1", basename(dosya)), boyut = ncol(Em),
    rho_alt_boyut_ici = spearman(Cm[ic], P_sec[ic]),              # ANA ÖLÇÜT (273 çift)
    rho_D = rho_f[["D"]], rho_A = rho_f[["A"]], rho_S = rho_f[["S"]],
    rho_861_cift = spearman(Cm[ust], P_sec[ust]),
    top3 = mean(vapply(rownames(Cm), function(i) { o <- setdiff(rownames(Cm), i)
      names(which.max(P_sec[i, o])) %in% names(sort(Cm[i, o], decreasing = TRUE))[1:3] }, logical(1))),
    ic_eksi_dis = mean(Cm[ic]) - mean(Cm[dis]),
    loo_dogruluk = mean(vapply(rownames(Cm), function(i) { m <- vapply(names(key42), function(f)
      mean(Cm[i, setdiff(item_id(key42[[f]]), i)]), numeric(1)); names(which.max(m)) == alt_etiket[[i]] }, logical(1))))
}))
model_tablosu <- model_tablosu[order(-model_tablosu$rho_alt_boyut_ici), ]; rownames(model_tablosu) <- NULL
csv_yaz(model_tablosu, "tablo_H3_model_secimi.csv"); print(model_tablosu, row.names = FALSE, digits = 3)
secilen_model <- model_tablosu$model[1]
cat("Ana ölçüte göre seçilen model:", secilen_model, "\n")
# Analiz, seçilen modelin arşivlenmiş vektörleriyle sürer (Bölüm H4, cfg$vektor_dosyasi).
kontrol("secilen_model_arsivle_ayni", secilen_model == "text-embedding-3-large",
        "Seçilen model arşivdekinden farklıysa cfg$vektor_dosyasi değiştirilmeli ve bütün analiz yeniden çalıştırılmalıdır.")
