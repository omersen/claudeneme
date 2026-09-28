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
