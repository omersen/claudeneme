# DASS-42 anlamsal kısa formlar: PUB21, MIN21, MAX21, COV21

Yüksek lisans tezi için R analiz hattı. Dört araştırma sorusu (AS1-AS4) için DASS-42'nin her alt boyutundan yedi madde seçen üç anlamsal kural, yayımlanmış DASS-21 ile karşılaştırılır. Yanıt verisi madde seçiminde kullanılmaz; bütün psikometrik değerlendirme doğrulama yarısında yapılır.

Kod incelemesi ve tasarım kararları: `docs/inceleme_R_kodlari.md`. Eski GENIE tabanlı hat `legacy/genie_pipeline/` altında değiştirilmeden saklanmaktadır.

## Çalıştırma

Gerekli paketler: lavaan, semTools, ggplot2, jsonlite, digest. GRM, test bilgisi ve EAP puanları için ayrıca mirt gerekir; mirt yoksa bu aşamalar atlanır ve `run_status.json` içinde `grm_stage_run = false` yazılır.

```r
install.packages(c("lavaan", "semTools", "mirt", "ggplot2", "jsonlite", "digest"))
```

```sh
Rscript run_all.R run1
```

Her koşu `outputs/run1/` altına yazar; var olan dizinin üzerine yazılmaz. Sabitler, tohumlar ve madde anahtarları `config.R` içindedir.

## Girdiler

| Dosya | İçerik | Doğrulama |
| --- | --- | --- |
| `inputs/DASS_data_21.02.19.zip` | OpenPsychometrics DASS arşivi (39.775 kayıt, kod kitabı) | SHA-256 `config.R` içinde |
| `inputs/archived_embeddings.csv` | 42 madde × 3072 boyut, text-embedding-3-large (Ravenda ve ark., 2025 deposundan) | SHA-256 `embedding_provenance.json` içinde |
| `inputs/previous_reference/` | Önceki analizlerin örneklem bölmesi ve seçilen maddeleri | Süreklilik kontrolü |

Uygunluk: yaş 18-80, ana dili İngilizce, 42 maddenin tamamı 1-4 aralığında. 10.362 uygun kayıttan 4.000'i çekilir ve 2.000/2.000 kalibrasyon/doğrulama olarak bölünür (`use_all_eligible = TRUE` ile tüm uygun kayıtlar kullanılabilir). Doğrulama yarısı önceki analizlerde görülmüştür; bu bir kör dış doğrulama değildir ve `source_manifest.json` bunu kaydeder.

## Formlar

| Form | Seçim | Yanıt verisi |
| --- | --- | --- |
| FULL42 | Tam form (referans) | Yalnız değerlendirmede |
| PUB21 | Yayımlanmış DASS-21: D {3,10,17,26,31,38,42}, A {2,4,20,25,28,40,41}, S {6,8,12,18,22,35,39} | Hayır |
| MIN21 | Alt boyuttaki diğer 13 maddeye ortalama kosinüs benzerliği (ISI) en düşük 7 madde | Hayır |
| MAX21 | ISI en yüksek 7 madde | Hayır |
| COV21 | 3.432 yedili küme içinde kapsam kaybını (CL, dışarıda kalan maddeler üzerinden) en aza indiren küme; eşit minimumlar SB en yüksek küme ile bozulur (`cov_tie_rule`) | Hayır |

## Modüller ve çıktılar

| Modül | Soru | Ana çıktılar |
| --- | --- | --- |
| `01_prepare.R` | Tümü | `sample_flow.csv`, `sample_split.csv`, `items_used.csv`, `source_manifest.json` |
| `02_semantic_forms.R` | AS4 | `selected_items.csv`, `AS4_semantic_metrics.csv` (SB, CL, CL_max ve 3.432 küme içindeki yüzdelikler), `AS4_COV_optimum_audit.csv`, `AS4_form_overlap.csv` |
| `03_as1_isi_discrimination.R` | AS1 | `AS1_ISI_discrimination.csv` (ISI ile CITC Spearman rho ve bootstrap GA; GRM a ikincil), `AS1_item_level.csv`, `AS1_semantic_polychoric_Mantel.csv` |
| `04_as2_structure_reliability.R` | AS2 | `AS2_CFA_fit.csv` (WLSMV, PUB21'e göre ΔCFI/ΔRMSEA), `AS2_reliability.csv` (ordinal omega, ham alfa), `AS2_corrected_item_total_correlations.csv`, mirt varsa `AS2_weighted_information.csv` |
| `05_as3_score_agreement.R` | AS3 | `AS3_score_agreement.csv` (r, CCC, yanlılık, RMSE), `AS3_overlap_inflation.csv` (kalan-madde korelasyonu ve şişme), `AS3_MIN_MAX_complement_identity.csv` |
| `06_exhaustive_reference.R` | AS2-AS3 | `REF_selected_form_positions.csv`: formların 3.432 küme içindeki alfa, RMSE ve kalan-madde korelasyonu yüzdelikleri |
| `07_bootstrap.R` | AS2-AS3 | `BOOT_paired_differences_vs_PUB21.csv`: 2.000 eşleştirilmiş kişi bootstrap'ı |
| `08_figures.R` | Tümü | `figures/Sekil_1..5` |

Her koşu ayrıca `validation_checks.csv` (iç kontroller), `code_sha256.csv`, `input_sha256.csv`, `analysis_log.txt` ve `sessionInfo.txt` üretir.

## Yorum sınırları

- ISI ve CITC (ya da a) ikisi de merkezilik ölçer; pozitif ilişki beklenir ve nedensel değildir. Alt boyut başına 14 madde vardır; bootstrap aralıkları yalnız kişi örneklemesini yansıtır.
- MIN21 ve MAX21 her alt boyutta birbirinin tümleyenidir; ham puanda RMSE ve kalan-madde korelasyonları cebirsel olarak eşittir.
- COV21'in CL'de en iyi çıkması seçim hedefinin sonucudur. Eşit minimumlar karşılıklı en yakın komşu çiftlerinden gelir; sayıları `AS4_COV_optimum_audit.csv` içindedir.
- SB = 1 − MIISS olduğundan iki bağımsız gösterge değildir. Yüzdelikler betimseldir, p değeri değildir. Tam form gerçek puan değildir.
- GRM tanılamaları (C2, Q3) uyumsuzluk gösteriyorsa a parametreleri ve bilgi eğrileri modele koşullu okunmalıdır.
