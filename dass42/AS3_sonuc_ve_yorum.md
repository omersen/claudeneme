# AS3: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonunu doldurmaz; son ifade Berkcan'a aittir.

**Araştırma sorusu 3 (AS3).** Anlamsal seçim kurallarıyla oluşturulan kısa formlar ile yayımlanmış DASS-21'in alt boyut puanları, DASS-42'nin ilgili alt boyut puanlarıyla ne ölçüde uyumludur?

## Ne yapıldı ve nasıl denetlendi

AS1 ve AS2 bloklarına dokunmadan yalnız `TODO AS3` bloğu dolduruldu (75 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- AS3'ün metni.
- Her kişi için hangi iki puanın hesaplandığı: kısa puan 7 maddenin, tam puan 14 maddenin ortalamasıdır; ikisi de 0-3 aralığındadır.
- Dört göstergenin (r, yanlılık, s_d, RMSE) ne anlama geldiği.
- Rehberin yorum kuralları.

Blok ayrıca tanımdan gelen üç eşitliği `kontrol()` ile denetler:

- MIN21 ve MAX21'in kişi düzeyindeki farkları toplamı sıfırdır.
- MIN21 ve MAX21'in RMSE değerleri eşittir.
- Her satırda RMSE² = yanlılık² + s_d² eşitliği sağlanır.

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `as3_01`, bu bloğun 36 anahtarı (12 r, 12 yanlılık, 12 RMSE) | 36/36 `gecti` |
| AS1 ve AS2 anahtarları aynı çalıştırmada | Hepsi `gecti` |
| `AS3_rmse_yzd_*` ve `AS3_r_medyan_*` (15 anahtar) | `eksik`. Beklenen durumdur; bu değerleri ALT KÜME TABLOSU bloğu üretir |
| Yedi yeni iç denetim | Hepsi geçti |
| `cikti_denetimi.csv`, `tablo_AS3_uyum.csv` | Var; sütunlar ve satır sayısı doğru |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | AS1, AS2 ve AS3'ün on tablosu aynı |

Toplam durum: 95 geçti, 183 eksik, 1 farklı (çıktı dosyaları satırı; sonraki blokların dosyaları olmadığı için beklenen durum). Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

Değerlendirme grubunda (n = 2.000) kısa ve tam alt boyut puanlarının uyumu aşağıdadır. Yanlılık, s_d ve RMSE 0-3 madde ortalaması birimindedir. Son sütun, RMSE² içinde yanlılık²'nin payıdır. Bu sütun tabloda yoktur; tablonun değerlerinden hesaplanmıştır.

| Form | Alt boyut | r | Yanlılık | s_d | RMSE | RMSE (0-42) | Yanlılığın RMSE² içindeki payı |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PUB21 | D | 0,985 | −0,004 | 0,151 | 0,151 | 2,11 | %0,1 |
| PUB21 | A | 0,968 | 0,075 | 0,196 | 0,210 | 2,94 | %12,6 |
| PUB21 | S | 0,965 | −0,050 | 0,199 | 0,206 | 2,88 | %5,9 |
| MIN21 | D | 0,976 | 0,114 | 0,192 | 0,223 | 3,12 | %26,2 |
| MIN21 | A | 0,950 | 0,065 | 0,227 | 0,236 | 3,30 | %7,5 |
| MIN21 | S | 0,964 | −0,062 | 0,199 | 0,208 | 2,92 | %9,0 |
| MAX21 | D | 0,979 | −0,114 | 0,192 | 0,223 | 3,12 | %26,2 |
| MAX21 | A | 0,958 | −0,065 | 0,227 | 0,236 | 3,30 | %7,5 |
| MAX21 | S | 0,970 | 0,062 | 0,199 | 0,208 | 2,92 | %9,0 |
| COV21 | D | 0,981 | 0,059 | 0,168 | 0,178 | 2,50 | %10,9 |
| COV21 | A | 0,961 | −0,092 | 0,201 | 0,221 | 3,09 | %17,2 |
| COV21 | S | 0,972 | 0,007 | 0,180 | 0,180 | 2,53 | %0,2 |

Kaynak: `tablo_AS3_uyum.csv`.

## Nasıl yorumlanır

**Ana gösterge RMSE'dir.** RMSE'ler 0,151 ile 0,236 arasındadır (0-42 biriminde 2,11 ile 3,30). Alt boyutlara göre örüntü şöyledir:

- D: en küçük RMSE PUB21'de (0,151), sonra COV21'de (0,178), en büyük MIN21 ve MAX21'de (0,223).
- A: PUB21 (0,210), COV21 (0,221), MIN21 ve MAX21 (0,236).
- S: COV21 (0,180), PUB21 (0,206), MIN21 ve MAX21 (0,208).

Rehbere göre düşük RMSE, seçilen yedi madde ile kalan yedi maddenin kişi düzeyinde birbirine daha yakın olduğu anlamına gelir. Kısa form tam formun yarısı olduğu için bu ham uyum, bölünmenin bir özelliğidir. Bu farkların büyüklüğünün aynı uzunluktaki bütün seçimler içindeki yeri (RMSE yüzdeliği) ALT KÜME TABLOSU bloğunda, PUB21'e göre farkların tutarlılığı ise BOOTSTRAP bloğunda hesaplanacaktır. O zamana kadar yalnız değerler ve örüntü betimlenmelidir.

**RMSE'nin kaynağı.** RMSE² = yanlılık² + s_d² olduğu için sapmanın ne kadarının ortalama kaymadan, ne kadarının kişiden kişiye değişen farktan geldiği ayrılabilir. On iki satırın hepsinde RMSE'nin büyük bölümü kişi düzeyindeki dağılımdan (s_d) gelir; yanlılığın payı %0,1 ile %26,2 arasındadır. Yanlılığın en belirgin olduğu yer D alt boyutunda MIN21 ve MAX21'dir (%26,2). MIN21 depresyon puanını ortalamada 0,114 puan yüksek, MAX21 aynı miktarda düşük verir. Yanlılık "kısa eksi tam" yönündedir: pozitif değer, kısa formun ortalamada daha yüksek puan verdiğini gösterir. PUB21'in D alt boyutunda (%0,1) ve COV21'in S alt boyutunda (%0,2) yanlılık neredeyse yoktur.

**MIN21 ve MAX21.** Bu iki form her alt boyutta aynı 14 maddeyi ikiye böler. Bu yüzden yanlılıkları ters işaretli ve eşit büyüklükte, RMSE değerleri de aynıdır; bu, blokta denetlenmiştir. Rehbere göre bu eşitlik yeni ve bağımsız bir kanıt değildir, tanımdan gelir. Buna karşılık iki formun r değerleri farklıdır (ör. D'de 0,976 ve 0,979). Bunun nedeni, korelasyonun iki yarının puan varyansına da bağlı olmasıdır. Bu açıklama rehberde yer almaz; aritmetik bir gözlemdir.

**Korelasyon.** Kısa ve tam puanlar arasındaki r değerleri 0,950 ile 0,985 arasındadır, yani hepsi çok yüksektir. Kısa puan ile tam puan ortak maddeler içerdiği için bu beklenen bir sonuçtur. Rehber bu yüzden r'nin bütün kümelerdeki medyanla karşılaştırılmasını ister; bu medyan ALT KÜME TABLOSU bloğunda hesaplanacaktır. O karşılaştırma yapılmadan yüksek r bir başarı göstergesi olarak sunulmamalıdır.

**Yorumda söylenmemesi gerekenler (rehberin AS3 kuralları).**

- RMSE'nin "ölçme hatası" olduğu. Tam form gerçek puan değildir ve kısa formla ortak maddeler içerir.
- Yüksek kısa-tam korelasyonunun geçerlik ya da puan eşdeğerliği kanıtı olduğu.
- Küçük RMSE'nin klinik eşdeğerlik gösterdiği.
- 0-42 birimindeki RMSE aralığının formlar arası fark ya da klinik önem eşiği olduğu.
- MIN21 ile MAX21'in RMSE eşitliğinin bağımsız bir bulgu olduğu.
- Kazanan bir form ilan edilmesi (genel kural 8).

## Danışmanın dikkatine

1. Yanlılığın RMSE² içindeki payı rehberde istenen bir tablo sütunu değildir. Rehberin "RMSE'nin yanlılıktan mı dağılımdan mı geldiği her zaman belirtilir" kuralını somutlaştırmak için tablonun değerlerinden hesapladım; betiğe eklenmedi. Tezde kullanılacaksa hesap yolu (yanlılık² / RMSE²) yöntem metninde belirtilmelidir.
2. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, yedi iç denetim ve başvuru çıktısıyla tablo karşılaştırmasından ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni belgeye bakın).
- `ciktilar_as3_01/`: `tablo_AS3_uyum.csv`, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
