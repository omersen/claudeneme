# AS4: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonunu doldurmaz; son ifade Berkcan'a aittir.

**Araştırma sorusu 4 (AS4).** Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış DASS-21, seçilen maddelerin anlamsal çeşitliliği ve ilgili alt boyuttaki madde havuzunun anlamsal temsili bakımından nasıl farklılaşmaktadır?

## Ne yapıldı ve nasıl denetlendi

Önceki bloklara dokunmadan yalnız `TODO AS4` bloğu dolduruldu (81 satır eklendi). Bu blokta yanıt verisi kullanılmaz; bütün değerler madde metinlerinin gömme vektörlerinden gelir. Bloğun başındaki okuma kılavuzu şunları açıklar:

- AS4'ün metni.
- SB'nin tanımı: anlamsal genişlik, yani 1 eksi seçilen yedi madde arasındaki ortalama kosinüs benzerliği. Yüksek SB, daha çeşitli bir seçim demektir.
- CL'nin tanımı: temsil kaybı, yani her maddenin en yakın seçili maddeye uzaklığının ortalaması. Düşük CL, daha iyi temsil demektir.
- Madde temsil tablosunun nasıl okunacağı.
- Rehberin yorum kuralları.

Blok 24 iç denetim ekler. Bunlar her formun kendi satırının bulunmasını ve temsil tablosundaki uzaklıkların toplamının 14'e bölümünün formun CL değerine eşit olmasını denetler.

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `as4_01`, bu bloğun 27 anahtarı (12 SB, 12 CL, 3 SB-CL ilişkisi) | 27/27 `gecti` |
| ALT KÜME TABLOSU'nun ürettiği 24 AS4 yüzdeliği | 24/24 `gecti`; AS4 böylece tamamlandı (51/51) |
| Önceki blokların anahtarları | Hepsi `gecti` |
| 24 yeni iç denetim | Hepsi geçti (toplam 144) |
| Üç AS4 tablosu | Var; sütunlar ve satır sayıları doğru (temsil tablosu 84 satır) |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | 17 tablonun hepsi aynı; madde metinleri ve `en_zayif` işaretleri dahil |

Toplam durum: 209 geçti, 69 eksik (AS5, EK ANALİZLER), 1 farklı (çıktı dosyaları satırı; beklenen durum). Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

SB ve CL değerleri ile bu değerlerin 3.432 yedili küme içindeki yüzdelikleri aşağıdadır. Yüzdelikler ALT KÜME TABLOSU bloğundan alınmıştır. SB'de yüksek yüzdelik daha çeşitli, CL'de düşük yüzdelik daha iyi temsil demektir.

| Form | Alt boyut | SB | SB yüzdeliği | CL | CL yüzdeliği |
| --- | --- | --- | --- | --- | --- |
| PUB21 | D | 0,502 | 70,9 | 0,138 | 2,9 |
| PUB21 | A | 0,603 | 51,9 | 0,214 | 12,7 |
| PUB21 | S | 0,544 | 96,5 | 0,153 | 21,1 |
| MIN21 | D | 0,568 | 100,0 | 0,157 | 41,1 |
| MIN21 | A | 0,659 | 99,5 | 0,252 | 98,4 |
| MIN21 | S | 0,568 | 100,0 | 0,174 | 69,1 |
| MAX21 | D | 0,395 | 0,6 | 0,178 | 85,6 |
| MAX21 | A | 0,507 | 0,1 | 0,252 | 98,3 |
| MAX21 | S | 0,386 | 0,2 | 0,188 | 91,7 |
| COV21 | D | 0,510 | 79,5 | 0,132 | 0,2 |
| COV21 | A | 0,625 | 81,5 | 0,198 | 0,0 |
| COV21 | S | 0,525 | 84,3 | 0,131 | 0,1 |

Bütün kümelerde SB ile CL arasındaki Spearman korelasyonu D'de −0,45, A'da −0,45, S'de −0,55'tir.

Kaynak: `tablo_AS4_anlamsal.csv`, `tablo_AS4_SB_CL.csv`, `tablo_form_yuzdelikleri.csv`. A alt boyutunda MIN21 ve MAX21'in CL değerleri üç ondalıkta aynı görünür (0,2522 ve 0,2516).

En zayıf temsil edilen elenen maddeler (`tablo_AS4_madde_temsil.csv`, `en_zayif = TRUE`), kosinüs uzaklığıyla:

| Form | D | A | S |
| --- | --- | --- | --- |
| PUB21 | Q05 → Q31 (0,434) | Q23 → Q04 (0,525) | Q14 → Q39 (0,372) |
| MIN21 | Q16 → Q24 (0,423) | Q20 → Q40 (0,572) | Q01 → Q14 (0,444) |
| MAX21 | Q05 → Q31 (0,434) | Q02 → Q15 (0,596) | Q12 → Q27 (0,474) |
| COV21 | Q03 → Q31 (0,359) | Q25 → Q04 (0,476) | Q33 → Q12 (0,353) |

Örnek: PUB21'in A alt boyutunda en zayıf temsil edilen madde Q23'tür ("I had difficulty in swallowing"). Formdaki en yakın karşılığı Q04'tür ("I experienced breathing difficulty…"). İkisi de bedensel belirtidir ama farklı belirtilerdir; uzaklık 0,525'tir. Karşı örnek olarak PUB21'in D alt boyutunda Q21 ("life wasn't worthwhile") formdaki Q38 ("life was meaningless") ile 0,147 uzaklıkla, yani çok yakından temsil edilir.

## Nasıl yorumlanır

Rehbere göre AS4'ün asıl bulguları üç tanedir.

**1. PUB21'in konumu.** Yayımlanmış form, temsil bakımından olası seçimlerin iyi dilimlerindedir: CL yüzdeliği D'de 2,9, A'da 12,7, S'de 21,1'dir. Yani rehberin şablonundaki [iyi/orta düzeyde/zayıf] seçeneği için veri D'de "iyi", A ve S'de "iyi ile orta arası"nı destekler. Bu seçim de ölçütlerin danışmanla netleştirilmesini gerektirir; rehber yüzdelik sınırları vermez. PUB21'in çeşitliliği D ve A'da ortalamanın üstünde ya da ortada (70,9 ve 51,9), S'de çok yüksektir (96,5).

**2. Her formun kendi hedefi dışındaki konumu.**

- **MIN21'in CL'si (çeşitlilik temsil anlamına mı geliyor?).** MIN21'in çeşitliliği en üst dilimdedir. Temsili ise D'de ortada (41,1), S'de ortanın altında (69,1), A'da olası seçimlerin en kötü %2'si arasındadır (98,4). Veri, rehberin şablonundaki "çeşitlilik temsil anlamına gelmemektedir" seçeneğini destekler.
- **COV21'in SB'si.** Temsil kaybını en aza indiren form, çeşitlilikte de ortalamanın üstündedir (79,5 ile 84,3). Yani bu havuzda iyi temsil, maddelerin birbirine benzemesiyle değil, belirli bir çeşitlilikle birlikte görülmüştür.
- **MAX21'in CL'si.** Birbirine en benzer maddeleri seçmek, temsili zayıf bir formla sonuçlanmıştır (85,6 ile 98,3). ALT KÜME TABLOSU ve BOOTSTRAP bloklarında görülen yüksek alfa ile birlikte okunduğunda: MAX21'in puanı daha homojendir, ama elenen maddelerin anlam alanını daha az kapsar.

**3. SB ile CL'nin birlikte değişmesi.** Bütün yedili kümelerde SB ile CL arasındaki ilişki negatiftir ve orta ile güçlü arasındadır (−0,45, −0,45, −0,55). Bu havuzda daha çeşitli kümeler daha az temsil kaybı verme eğilimindedir. İlişki mükemmel değildir; bu yüzden en çeşitli seçim (MIN21) en iyi temsili vermez. MIN21 ISI'ye göre seçilmiştir, yani doğrudan en yüksek SB'ye göre değil, ama SB yüzdeliği 99,5 ile 100,0 arasındadır. Ortalama bir eğilim ile uçtaki bir seçimin davranışı ayrı şeylerdir. Kümeler ortak maddeler içerdiği için bu katsayılar betimseldir ve p değeri verilmez.

**Tanım gereği olanlar bulgu değildir (genel kural 2).** MIN21'in yüksek ve MAX21'in düşük SB değeri seçim kuralından beklenir. COV21'in en düşük CL değeri tanım gereğidir.

**Yorumda söylenmemesi gerekenler (rehberin AS4 kuralları).**

- Yüksek SB'nin tek başına iyi temsil demek olduğu.
- "Temsil"in kapsam geçerliği olduğu. Buradaki temsil yalnız bu gömme uzayındaki anlamsal temsildir ve uzman içerik yargısının yerine geçmez.
- Tanım gereği olan sonuçların bulgu olarak sunulması.

Rehberde yer almayan bir öneri: temsil tablosundaki örnekler (ör. Q23 → Q04), CL'nin ne anlama geldiğini somutlaştırmak için iyidir. Ancak bir iki örnekle sınırlı kalınmalı ve bu örnekler uzman içerik yargısı yerine konmamalıdır.

## Danışmanın dikkatine

1. PUB21'in temsilini "iyi/orta/zayıf" diye nitelemek için rehberde yüzdelik sınırı yok. Tezde kullanılacak sınır (ör. alt çeyrek = iyi) yöntem metninde önceden belirtilmelidir; yoksa nitelendirme keyfî görünebilir.
2. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, 24 iç denetim ve başvuru çıktısıyla tam karşılaştırmadan ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni belgeye bakın).
- `ciktilar_as4_01/`: üç AS4 tablosu, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
