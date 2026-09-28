# ALT KÜME TABLOSU: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonlarını doldurmaz; son ifade Berkcan'a aittir.

**Bu blok neye hizmet eder?** ALT KÜME TABLOSU tek başına bir araştırma sorusunu yanıtlamaz. Görevi, dört formun AS2, AS3 ve AS4'teki değerlerini, aynı uzunluktaki bütün olası seçimler içinde konumlandırmaktır. Her alt boyutun 14 maddesinden 7'si 3.432 farklı biçimde seçilebilir. Blok, bu kümelerin hepsi için şu değerleri hesaplar ve AS5'in (alt küme testi) zeminini hazırlar:

- alfa,
- kısa-tam RMSE,
- anlamsal genişlik (SB),
- temsil kaybı (CL),
- kısa-tam r.

## Ne yapıldı ve nasıl denetlendi

Önceki bloklara dokunmadan yalnız `TODO ALT KÜME TABLOSU` bloğu dolduruldu (94 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- Bloğun hangi sorulara hizmet ettiği.
- Anlamsal değerlerin (SB, CL, CL_b) yalnız madde metinlerinden, psikometrik değerlerin (alfa, yanlılık, s_d, RMSE, r) yanıtlardan geldiği.
- Yüzdeliklerin yalnız değerlendirme grubunda hesaplandığı.
- Orta sıra yüzdeliğinin nasıl okunacağı.

Blok 49 iç denetim ekler: her alt boyut ve grupta 3.432 satır, formun kendi satırının tabloda bulunması, ayrıca formun alfa ve RMSE değerinin AS2 ve AS3'te ayrı yoldan hesaplanan değerlerle aynı olması (fark < 10⁻¹⁰).

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `altkume_01`, bu bloğun 51 anahtarı (12 alfa, 12 RMSE, 12 SB, 12 CL yüzdeliği ve 3 r medyanı) | 51/51 `gecti` |
| AS1, AS2 ve AS3 anahtarları aynı çalıştırmada | Hepsi `gecti` (AS2 ve AS3 artık tamamlandı) |
| 49 yeni iç denetim | Hepsi geçti (toplam 100 iç denetim) |
| `cikti_denetimi.csv`, üç yeni tablo | Üçü de var; sütunlar ve satır sayıları doğru (`tum_alt_kumeler.csv` 20.592 satır) |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | `tum_alt_kumeler.csv` dahil 13 tablonun hepsi aynı |

Toplam durum: 146 geçti, 132 eksik (sonraki bloklar), 1 farklı (çıktı dosyaları satırı; beklenen durum). Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

Değerlendirme grubunda, her formun her alt boyuttaki değerinin 3.432 yedili küme içindeki orta sıra yüzdeliği aşağıdadır. Omega AS2'den alınmıştır.

| Form | Alt boyut | Omega | Alfa yüzdeliği | RMSE yüzdeliği | SB yüzdeliği | CL yüzdeliği |
| --- | --- | --- | --- | --- | --- | --- |
| PUB21 | D | 0,916 | 17,4 | 3,5 | 70,9 | 2,9 |
| PUB21 | A | 0,855 | 58,5 | 42,4 | 51,9 | 12,7 |
| PUB21 | S | 0,860 | 10,8 | 64,6 | 96,5 | 21,1 |
| MIN21 | D | 0,914 | 5,8 | 92,5 | 100,0 | 41,1 |
| MIN21 | A | 0,830 | 1,3 | 80,1 | 99,5 | 98,4 |
| MIN21 | S | 0,845 | 0,1 | 70,6 | 100,0 | 69,1 |
| MAX21 | D | 0,936 | 92,3 | 92,5 | 0,6 | 85,6 |
| MAX21 | A | 0,889 | 99,4 | 80,1 | 0,1 | 98,3 |
| MAX21 | S | 0,901 | 98,8 | 70,6 | 0,2 | 91,7 |
| COV21 | D | 0,916 | 11,0 | 38,3 | 79,5 | 0,2 |
| COV21 | A | 0,840 | 12,0 | 64,6 | 81,5 | 0,0 |
| COV21 | S | 0,856 | 6,5 | 8,1 | 84,3 | 0,1 |

Kaynak: `tablo_butunlesik.csv`, `tablo_form_yuzdelikleri.csv`. Yüzdelikler bir ondalıkla yazılmıştır (rehber kuralı). MIN21'in D ve S'deki SB yüzdelikleri 99,99 ve 99,96'dır; yuvarlandığı için 100,0 görünür.

Kısa-tam r değerleri ve bütün kümelerdeki medyan:

| Alt boyut | r medyanı (3.432 küme) | PUB21 | MIN21 | MAX21 | COV21 |
| --- | --- | --- | --- | --- | --- |
| D | 0,980 | 0,985 | 0,976 | 0,979 | 0,981 |
| A | 0,962 | 0,968 | 0,950 | 0,958 | 0,961 |
| S | 0,967 | 0,965 | 0,964 | 0,970 | 0,972 |

## Nasıl yorumlanır

**Yüzdeliğin okunuşu.** Orta sıra yüzdeliği, dağılımda formun değerinden küçük olanların oranı ile eşit olanların yarısının toplamıdır (× 100).

- Alfa ve SB'de yüksek yüzdelik daha yüksek değer demektir. Örneğin MAX21'in A'daki alfa yüzdeliği 99,4'tür: bu formun alfası, olası yedili seçimlerin yaklaşık %99'undan yüksektir.
- RMSE ve CL'de düşük yüzdelik daha küçük sapma ya da daha az temsil kaybı demektir. Örneğin PUB21'in D'deki RMSE yüzdeliği 3,5'tir: yayımlanmış formun depresyon puanı tam puandan, olası seçimlerin yaklaşık %96'sından daha az sapar.

**Tanım gereği olanlar bulgu değildir (rehber, genel kural 2).**

- COV21 en küçük CL'ye göre seçildiği için CL yüzdeliği 0'a yakındır (0,0 ile 0,2).
- MIN21 en düşük ISI'ye göre seçildiği için SB yüzdeliği çok yüksek (99,5 ile 100,0), MAX21'in ise çok düşüktür (0,1 ile 0,6).
- MIN21 ve MAX21'in RMSE yüzdelikleri aynıdır, çünkü ikisi aynı bölünmenin iki yarısıdır.

Bunlar seçim kuralının doğrudan sonucudur ve bulgu olarak sunulmaz.

**Seçim kuralından doğrudan gelmeyen konumlar.** Rehberin AS4 bölümüne göre asıl bulgular, her formun kendi seçim hedefi dışındaki göstergelerdeki konumudur:

- **MAX21 ve alfa.** Birbirine en benzer maddeleri seçmek, alfa yüzdeliğini üç alt boyutta da en üst dilime taşımıştır (92,3; 99,4; 98,8). Aynı form temsil bakımından zayıf bir konumdadır: CL yüzdeliği 85,6, 98,3 ve 91,7'dir. Rehbere göre bu yüksek güvenirlik "daha homojen puan" olarak okunur, "daha iyi ölçme" olarak değil. Ayrıca bu formun seçtiği maddeler, elenen maddelerin anlam alanını olası seçimlerin çoğundan daha az kapsamaktadır.
- **MIN21 ve temsil.** Birbirine en az benzeyen maddeleri seçmek alfayı en alt dilime indirmiştir (5,8; 1,3; 0,1). Temsilde de açık bir kazanç sağlamamıştır: CL yüzdeliği D'de 41,1, S'de 69,1, A'da 98,4'tür. A alt boyutunda çeşitliliği en yüksek form, temsil kaybında olası seçimlerin en kötü %2'si arasındadır. Bu, rehberdeki "çeşitlilik temsil anlamına gelmemektedir" seçeneğinin veride desteklendiğini gösterir. Rehbere göre bu konu AS4'te yazılır.
- **COV21 ve diğer göstergeler.** Temsil kaybını en aza indirmek, SB'yi de ortalamanın üstünde tutmuştur (yüzdelik 79,5 ile 84,3). Alfa ise alt dilimdedir (6,5 ile 12,0). RMSE yüzdeliği alt boyuta göre değişir: S'de 8,1 (tam puana olası seçimlerin çoğundan daha yakın), D'de 38,3, A'da 64,6.
- **PUB21.** Yayımlanmış form D'de hem temsil (CL yüzdeliği 2,9) hem tam puan uyumu (RMSE yüzdeliği 3,5) bakımından olası seçimlerin en iyi dilimlerindedir. A ve S'de konumu daha orta düzeydedir: A'da CL 12,7, RMSE 42,4; S'de CL 21,1, RMSE 64,6. Alfa yüzdeliği D ve S'de düşük (17,4 ve 10,8), A'da ortadadır (58,5).

**r değerleri.** Formların kısa-tam r değerleri, bütün kümelerin medyanına çok yakındır (en büyük fark 0,012, MIN21'in A alt boyutunda). Bu, rehberin yüksek korelasyonu tek başına başarı saymama kuralının gerekçesini sayılarla gösterir: olası yedili kümelerin yarısında r, alt boyuta göre zaten 0,962, 0,967 ya da 0,980'in üstündedir. PUB21, D ve A'da medyanın biraz üstünde, S'de biraz altındadır. Bu farklar yalnız betimlenmelidir.

**Birlikte okuma.** Bütünleşik tablo göstergeleri yan yana koyar. Rehberin genel kural 8'i gereği göstergeler tek bir başarı puanında birleştirilmez ve kazanan form ilan edilmez. Tartışmada yazılacak olan, hangi anlamsal hedefin hangi özelliği koruduğu ve hangisinde sınırlı kaldığıdır. Veri bunu şöyle gösteriyor:

- Birbirine benzeyen maddeleri seçmek (MAX21), alfası yüksek ama temsili zayıf bir formla sonuçlanmıştır.
- Birbirine benzemeyen maddeleri seçmek (MIN21), çeşitliliği yüksek, alfası düşük ve temsili her alt boyutta iyi olmayan bir formla sonuçlanmıştır.
- Temsil kaybını en aza indirmek (COV21), çeşitliliği de ortalamanın üstünde olan, alfası ise alt dilimde kalan bir formla sonuçlanmıştır.

Bu cümleler betimseldir; seçim hedefinin bu özellikleri "neden olduğu" anlamına gelmez.

Bu okuma kesin değildir. PUB21'e göre farkların tutarlılığı (BOOTSTRAP) ve bütün kümeler üzerindeki ilişkiler (AS5) henüz hesaplanmamıştır.

**Sınırlar.** Yüzdelikler betimseldir. 3.432 küme ortak maddeler içerdiği için bağımsız gözlem sayılmaz ve p değeri verilmez. Sonuçlar bu madde havuzuna, bu veriye ve bu gömme matrisine koşulludur (genel kural 1).

## Danışmanın dikkatine

1. `AS3_r_medyan_<f>` anahtarı formdan bağımsızdır. Kod bu değeri her form için aynı biçimde yeniden atar (son atama geçerlidir; değer aynıdır). Bu, sonucu değiştirmez; yalnız kod okunurken şaşırtmasın diye not edilmiştir.
2. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, 49 iç denetim ve 20.592 satırlık tablo dahil başvuru çıktısıyla tam karşılaştırmadan ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni belgeye bakın).
- `ciktilar_altkume_01/`: `tum_alt_kumeler.csv`, `tablo_form_yuzdelikleri.csv`, `tablo_butunlesik.csv`, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
- `karsilastir_ref06.R`: bütün analiz tablolarını (`tablo_*` ve `tum_alt_kumeler.csv`) başvuru çıktısıyla karşılaştıran betik.
