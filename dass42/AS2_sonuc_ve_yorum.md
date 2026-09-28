# AS2: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. AS1 belgesinde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonunu doldurmaz. Yorum kuralları ve verinin hangi seçeneği desteklediği gerekçesiyle gösterilir; son ifade Berkcan'a aittir.

**Araştırma sorusu 2 (AS2).** Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış DASS-21, üç faktörlü yapının desteklenmesi ve alt boyut puanlarının güvenirliği bakımından nasıl farklılaşmaktadır?

## Ne yapıldı ve nasıl denetlendi

AS1 bloğuna dokunmadan yalnız `TODO AS2` bloğu dolduruldu (98 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- AS2'nin metni.
- Kullanılan veri: yalnız değerlendirme grubunun yanıtları (2.000 kişi).
- Beş formun ne olduğu: FULL42 yalnız başvuru noktasıdır; karşılaştırılan dört kısa form PUB21, MIN21, MAX21 ve COV21'dir.
- Sonuçların nasıl yorumlanacağı.

Her adımda (DFA, uyum, yükler, faktör korelasyonları, güvenirlik) amaç ve yorum notu vardır.

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `as2_01`, 39 AS2 anahtarı | 39/39 `gecti` (15 uyum değeri, 12 omega, 12 alfa) |
| AS1 anahtarları aynı çalıştırmada | 12/12 `gecti` |
| `AS2_alfa_yzd_*` (12 anahtar) | `eksik`. Bu beklenen durumdur; bu değerleri sonraki blok (ALT KÜME TABLOSU) üretir |
| Bütünlük satırları | Sabit bölümler, elle sayı yok ve blok sayısı `gecti`. Çıktı dosyaları satırı, sonraki blokların dosyaları olmadığı için `farkli` (beklenen durum) |
| `cikti_denetimi.csv`, dört AS2 tablosu | Dördü de var; sütun adları ve satır sayıları doğru |
| Günlükteki uyarılar | Hiç uyarı yok; beş DFA yakınsadı ve kabul edilebilir çözüm verdi |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | Dört AS2 tablosu, yükler ve faktör korelasyonları dahil aynı; en büyük fark 1,0 × 10⁻¹¹ |

Toplam durum: 59 geçti, 219 eksik, 1 farklı (çıktı dosyaları satırı). Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

Üç ilişkili faktörlü sıralı DFA (WLSMV) sonuçları, değerlendirme grubunda:

| Form | Madde | Ölçeklenmiş χ² (sd) | CFI | TLI | RMSEA [%90 aralık] | SRMR |
| --- | --- | --- | --- | --- | --- | --- |
| FULL42 (başvuru) | 42 | 8236,3 (816) | 0,942 | 0,938 | 0,067 [0,066; 0,069] | 0,049 |
| PUB21 | 21 | 1675,7 (186) | 0,968 | 0,964 | 0,063 [0,061; 0,066] | 0,041 |
| MIN21 | 21 | 1967,8 (186) | 0,961 | 0,955 | 0,069 [0,066; 0,072] | 0,044 |
| MAX21 | 21 | 2488,4 (186) | 0,964 | 0,960 | 0,079 [0,076; 0,081] | 0,047 |
| COV21 | 21 | 2015,6 (186) | 0,959 | 0,954 | 0,070 [0,067; 0,073] | 0,045 |

Bütün χ² testlerinde p < 0,001'dir (tabloda 0 görünür).

Alt boyut güvenirliği: omega ana göstergedir, alfa yardımcı göstergedir. Tabloda önce omega, parantez içinde alfa verilmiştir:

| Form | D | A | S |
| --- | --- | --- | --- |
| FULL42 (başvuru) | 0,962 (0,956) | 0,923 (0,917) | 0,934 (0,928) |
| PUB21 | 0,916 (0,908) | 0,855 (0,848) | 0,860 (0,852) |
| MIN21 | 0,914 (0,905) | 0,830 (0,820) | 0,845 (0,835) |
| MAX21 | 0,936 (0,928) | 0,889 (0,876) | 0,901 (0,892) |
| COV21 | 0,916 (0,907) | 0,840 (0,830) | 0,856 (0,849) |

Standartlaştırılmış yükler ve faktör korelasyonları:

| Form | Ortalama yük D / A / S | En düşük yük (madde) | Korelasyon D-A / D-S / A-S |
| --- | --- | --- | --- |
| FULL42 | 0,84 / 0,73 / 0,75 | 0,55 (Q02) | 0,66 / 0,70 / 0,83 |
| PUB21 | 0,82 / 0,72 / 0,73 | 0,54 (Q02) | 0,65 / 0,70 / 0,84 |
| MIN21 | 0,82 / 0,69 / 0,70 | 0,55 (Q02) | 0,68 / 0,72 / 0,89 |
| MAX21 | 0,87 / 0,78 / 0,79 | 0,67 (Q32) | 0,64 / 0,68 / 0,76 |
| COV21 | 0,82 / 0,71 / 0,72 | 0,58 (Q02) | 0,66 / 0,71 / 0,83 |

Kaynak: `tablo_AS2_DFA_uyum.csv`, `tablo_AS2_guvenirlik.csv`, `tablo_AS2_yukler.csv`, `tablo_AS2_faktor_korelasyonlari.csv`. obs.var = TRUE omega değerleri ektedir (`tablo_AS2_guvenirlik.csv`, `omega_obsvar_true` sütunu). Rehbere göre bu değerler ana metinde yorumlanmaz.

## Nasıl yorumlanır

**Yapı.** Beş formda da üç ilişkili faktörlü model yakınsamış ve kabul edilebilir bir çözüm vermiştir. Kısa formların CFI değerleri 0,959 ile 0,968, TLI değerleri 0,954 ile 0,964, RMSEA değerleri 0,063 ile 0,079, SRMR değerleri 0,041 ile 0,047 arasındadır. Rehber, bu değerlerin yan yana betimlenmesini ister. Formların uyum indekslerine göre sıralanmasını ve ΔCFI ya da ΔRMSEA eşikleriyle bir "kazanan" seçilmesini yasaklar. İki gerekçe vardır: farklı madde kümeleriyle kurulan modeller iç içe değildir, ve yükler yükseldikçe aynı yanlış belirlemede RMSEA kötüleşebilir (McNeish, An ve Hancock, 2018). Bu çalışmada bu ikinci durumun somut bir örneği görülür. En yüksek yüklere sahip MAX21 (ortalama yükler 0,87, 0,78 ve 0,79), en yüksek RMSEA değerini (0,079) verir. Bu nedenle MAX21'in RMSEA'sı tek başına "daha kötü yapı" diye okunmamalıdır.

Rehberde yer almayan bir ek not: kısa formların hepsi için bir mutlak eşik yorumu yapılacaksa (ör. CFI ≥ 0,95), hangi ölçütün kullanıldığı yöntem metninde belirtilmeli ve kategorik veride bu eşiklerin tartışmalı olduğu not edilmelidir. Paket belgeleri bu konuda bir eşik vermez.

**Güvenirlik.** Omega örüntüsü üç alt boyutta aynıdır: en yüksek değer MAX21'de, en düşük değer MIN21'dedir. PUB21 ve COV21 arada ve birbirine çok yakındır. D alt boyutunda PUB21 ve COV21'in omega değerleri üç ondalıkta aynıdır (0,916). PUB21'e göre farklar (yuvarlanmamış değerlerden, dört ondalıkla) şöyledir:

| Alt boyut | MIN21 | MAX21 | COV21 |
| --- | --- | --- | --- |
| D | −0,0019 | +0,0200 | +0,0005 |
| A | −0,0256 | +0,0333 | −0,0157 |
| S | −0,0158 | +0,0410 | −0,0040 |

Rehberin çerçevesi şöyledir. MAX21 anlamca birbirine en benzer maddelerden oluşur. Bu yüzden yüksek güvenirliği "daha homojen puan" olarak okunur; "daha iyi ölçme" olarak okunmaz. Bu okuma AS1 bulgusuyla da tutarlıdır: yüksek ISI'ye sahip maddelerin a değerleri de yüksekti.

Alfanın, bütün yedili kümeler içindeki yüzdeliği (rehberdeki "MAX21'in alfası yüzdeliğin kaçıncı dilimindedir" sorusu) ve PUB21'e göre farkların bootstrap aralıkları sonraki bloklarda hesaplanır. Bu nedenle omega farklarının büyüklüğü için şimdilik yalnız değerler verilmelidir; farkların "tutarlı" olup olmadığı henüz söylenemez.

**Faktör korelasyonları.** A-S korelasyonu formlar arasında en çok değişen korelasyondur: MIN21'de 0,89, MAX21'de 0,76, PUB21'de 0,84. Rehbere göre daha düşük faktör korelasyonu tek başına daha iyi form anlamına gelmez. Betimsel olarak şu yazılabilir: bu seçimde anlamca birbirine en benzeyen maddeleri seçmek (MAX21), kaygı ve stres faktörlerini daha ayrışık gösteren bir çözüm vermiştir. Bunun nedeni bu çalışmada sınanmamıştır.

**En düşük yükler.** FULL42'de en düşük yük A alt boyutundaki Q02'dedir ("dryness of my mouth", 0,55); bu madde AS1'de en düşük ISI değerine sahipti. Q02, MAX21 dışındaki bütün kısa formlarda yer alır.

**Yorumda söylenmemesi gerekenler (rehberin AS2 kuralları).**

- Formların uyum indekslerine göre sıralanması veya ΔCFI/ΔRMSEA eşikleriyle kazanan seçilmesi.
- Daha düşük faktör korelasyonunun tek başına daha iyi bir form anlamına geldiği.
- Yüksek güvenirliğin "daha iyi ölçme" olduğu.
- Alfa için hesaplanacak bootstrap aralıklarının omega aralığı olduğu.
- Kazanan bir form ilan edilmesi ya da göstergelerin tek bir başarı puanında birleştirilmesi (genel kural 8).

## Danışmanın dikkatine

1. McNeish, An ve Hancock (2018) künyesini bu oturumda ayrıca doğrulamadım. Künye bilgim şu: "The thorny relation between measurement quality and fit index cutoffs in latent variable models", *Journal of Personality Assessment, 100*(1), 43-52. Tezde kullanılmadan önce denetlenmesi önerilir.
2. AS2 bulgularının yorumu (özellikle MAX21'in yüksek omegası) ALT KÜME TABLOSU ve BOOTSTRAP blokları tamamlandığında kesinleşir. Yüzdelikler ve aralıklar, farkın aynı uzunluktaki bütün seçimler içindeki konumunu gösterecektir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni AS belgesine bakın).
- `ciktilar_as2_01/`: dört AS2 tablosu, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
- `karsilastir_ref06.R`: AS tablolarını danışman başvuru çıktısıyla karşılaştıran betik.
