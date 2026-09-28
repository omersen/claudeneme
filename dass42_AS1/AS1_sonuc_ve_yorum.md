# AS1: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Bu belge `blok_notlari.md` yerine geçmez. Rehbere göre blok notu Berkcan'ın kendi cümleleriyle yazılır; rehberdeki bulgu yazım şablonunu da yapay zekâ aracı doldurmaz. Bu nedenle aşağıda hazır tez cümlesi verilmemiştir. Bunun yerine şunlar gösterilmiştir: rehberin yorum kuralları, şablondaki seçeneklerden hangisini verinin desteklediği ve bunun gerekçesi. Son ifade Berkcan'a aittir.

**Araştırma sorusu 1 (AS1).** DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer maddelerle ortalama anlamsal benzerliği (ISI) ile GRM (Samejima'nın dereceli tepki modeli) altında kestirilen ayırt edicilik parametreleri (a) arasında nasıl bir ilişki vardır?

## Ne yapıldı ve nasıl denetlendi

`berkcan_dass42_analiz.R` şablonunda yalnız `TODO AS1` bloğu dolduruldu. Açıklama ve işaret satırlarına dokunulmadı; özgün şablonla fark, bloğun içine eklenen 157 satırdan ibarettir. Bloğun başındaki "okuma kılavuzu" üç şeyi açıklar:

- AS1'in metni.
- Her verinin hangi amaçla kullanıldığı. ISI ve kosinüs matrisi yalnız madde metinlerinden gelir. a, b ve CITC (düzeltilmiş madde-toplam korelasyonu) ise yanıtlardan gelir.
- Sonuçların nasıl yorumlanacağı.

Kodun her adımında da o adımın amacını ve yorumunu anlatan kısa notlar vardır.

Bu bulut ortamında R kurulu değildi. Paketteki `ortam/linux-explicit.txt` dosyasıyla sabit conda-forge ortamı yalnız bu geçici bulut ortamına kuruldu. Kurulan sürümler önerilenlerle aynıdır: R 4.5.3, lavaan 0.7.2, semTools 0.5.9, mirt 1.47. Bu, paketteki `CLAUDE.md` dosyasının "R'yi veya paketleri kurmaya çalışma" kuralından bilinçli bir sapmadır. Kural Berkcan'ın bilgisayarını korumak için yazılmıştır; burada ne Berkcan'ın bilgisayarına ne de paketin dosyalarına dokunuldu.

| Denetim | Sonuç |
| --- | --- |
| Boş şablon (`bos01`) | 8 geçti, 270 eksik, 1 farklı; sabit bölüm özeti `9bef53a2…` (beklenenle aynı) |
| AS1 çalıştırması (`as1_02`, son sürüm), 12 AS1 anahtarı | 12/12 `gecti`; en büyük fark 4,4 × 10⁻¹⁶ |
| Dört bütünlük satırı | Üçü `gecti`. Çıktı dosyaları satırı `farkli`, çünkü sonraki blokların dosyaları henüz yok (beklenen durum) |
| `cikti_denetimi.csv`, beş AS1 tablosu | Beşi de var; sütun adları ve satır sayıları doğru |
| İç denetimler | 43 denetimin hepsi geçti; AS1 bloğu 21 denetim ekledi (ISI, parametre ve Q3 sırası, kategori toplamları) |
| Günlükteki uyarılar | GRM, M2 veya Q3 için hiç uyarı yok |
| Danışman başvuru çıktısı `ref06` ile karşılaştırma | Beş AS1 tablosu aynı, raporda puanlanmayan değerler (madde parametreleri, Q3 çiftleri, tanılar) ve satır sırası dahil; en büyük fark 1,0 × 10⁻¹¹ (C2 değerinde). Karşılaştırma kod yazılıp çalıştırıldıktan sonra yapıldı ve başvuru çözümünün kodu okunmadı. Betik: `karsilastir_as1_ref06.R` |
| Bağımsız gözden geçirme | Ayrı bir ajan AS1'i yalnız tanımdan yeniden yazdı ve beş tabloyu birebir üretti. İki ajan daha sayıları, yorumları ve kaynakları denetledi; bulunan hatalar bu sürümde düzeltildi (belgenin sonuna bakın) |

`KABUL`, hesapların başvuru değerleriyle eşleştiğini gösterir; GRM'nin iyi uyum verdiğini göstermez (rehber, genel kural 7). Tanılar aşağıda ayrıca değerlendirilmiştir.

## Sonuçlar

| Alt boyut | Grup | ρ(ISI, a) | ρ(ISI, CITC) | ρ(a, CITC) | C2 (sd = 77) | C2 RMSEA | SRMSR | En büyük düzeltilmiş Q3 | Düzeltilmiş Q3 > 0,20 çift sayısı (91 çiftte) | ρ(kosinüs, düzeltilmiş Q3) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D | kal | 0,63 | 0,60 | 0,99 | 2360,2 | 0,122 | 0,049 | 0,48 | 7 | 0,39 |
| D | deg | 0,73 | 0,71 | 0,89 | 2807,8 | 0,133 | 0,054 | 0,47 | 10 | 0,38 |
| A | kal | 0,63 | 0,60 | 0,969 | 1060,9 | 0,080 | 0,045 | 0,31 | 3 | 0,42 |
| A | deg | 0,70 | 0,71 | 0,965 | 1418,5 | 0,093 | 0,052 | 0,37 | 3 | 0,45 |
| S | kal | 0,79 | 0,75 | 0,99 | 2116,1 | 0,115 | 0,060 | 0,45 | 6 | 0,42 |
| S | deg | 0,69 | 0,72 | 0,93 | 2135,3 | 0,116 | 0,061 | 0,46 | 6 | 0,33 |

Kaynak: `tablo_AS1_ISI_a.csv`, `tablo_AS1_GRM_tani.csv`, `tablo_AS1_kosinus_Q3.csv`. Bütün C2 testlerinde p < 0,001'dir; tabloda p = 0 görünmesi çok küçük bir değerin sıfıra yuvarlanmasıdır. A alt boyutundaki iki ρ(a, CITC) değeri birbirine çok yakın olduğu için rehberin kuralı gereği üç ondalıkla yazılmıştır.

ISI yanıt verisine bağlı değildir. En düşük ve en yüksek ISI değerine sahip maddelerin kalibrasyon grubundaki a değerleri şöyledir. D'de en düşük ISI Q42'dedir (a = 1,66), en yüksek ISI Q21'dedir (a = 3,60). A'da en düşük ISI Q02'dedir (a = 1,15), en yüksek ISI Q07'dedir (a = 2,37). S'de en düşük ISI Q35'tedir (a = 1,60), en yüksek ISI Q11'dedir (a = 2,50).

En seyrek kullanılan yanıt kategorisi, A alt boyutunda Q23'ün ("difficulty in swallowing") en üst kategorisidir: kalibrasyonda 85, değerlendirmede 101 kişi. Dört kategori her maddede gözlenmiştir.

En yüksek düzeltilmiş Q3 değerine sahip çiftler ve bu çiftlerin birlikte bulunduğu kısa formlar (`tablo_AS1_kosinus_Q3.csv`) şunlardır:

| Alt boyut | Kalibrasyonda en yüksek çift (Q3; kosinüs; birlikte olduğu formlar) | Değerlendirmede en yüksek çift |
| --- | --- | --- |
| D | Q05-Q42 (0,48; 0,55; MIN21, COV21) | Q17-Q34 (0,47; 0,82; hiçbiri). Q05-Q42 ikinci sıradadır (0,47) |
| A | Q07-Q41 (0,31; 0,71; MAX21) | Q07-Q41 (0,37) |
| S | Q12-Q33 (0,45; 0,65; MIN21) | Q12-Q33 (0,46) |

Maddelerin metinleri:

- Q05: "I just couldn't seem to get going". Q42: "I found it difficult to work up the initiative to do things".
- Q17: "I felt I wasn't worth much as a person". Q34: "I felt I was pretty worthless".
- Q07: "I had a feeling of shakiness". Q41: "I experienced trembling".
- Q12: "I felt that I was using a lot of nervous energy". Q33: "I was in a state of nervous tension".

## Nasıl yorumlanır

**Yön ve büyüklük.** Üç alt boyutta ve iki grupta ISI ile a arasındaki Spearman korelasyonu pozitiftir ve 0,63 ile 0,79 arasındadır. Rehberin adlandırmasıyla (|ρ| ≥ 0,50) bu, güçlü bir ilişkidir; bu adlandırma bir başarı eşiği değildir. Okunuşu şudur: bu 14 maddelik havuzlarda, aynı alt boyuttaki diğer maddelere anlamca ortalama daha benzer olan maddelerin, bu model altında kestirilen ayırt ediciliği daha yüksek olma eğilimindedir. Rehberin şablonundaki [pozitif/negatif] seçeneği için veri, üç alt boyutta da "pozitif"i destekler.

**Tutarlılık.** Rehberin tanımına göre, kalibrasyon, değerlendirme ve CITC aynı yönü gösterdiğinde ilişki tutarlı sayılır. Bu koşul üç alt boyutta da sağlanmıştır. ISI ile CITC arasındaki ilişki 0,60 ile 0,75 arasındadır, yani şablondaki [aynı/ters] seçeneği için "aynı"dır. İki noktaya dikkat edilmelidir:

- CITC, GRM'den bağımsızdır ama yerel bağımlılıktan a kadar etkilenebilir. a ile CITC arasındaki ilişki 0,89 ile 0,99 arasındadır; iki gösterge maddeleri hemen hemen aynı sırayla dizer. Bu yüzden CITC'nin desteği, sonucun model seçimine (GRM ya da klasik test kuramı) karşı sağlam olduğunu gösterir. Bağımsız ikinci bir kanıt değildir.
- Değerlendirme grubu tekrarı ayrı bir katılımcı grubunda yapılmıştır, ancak ISI değerleri iki grupta aynıdır. Bu nedenle tam bağımsız bir tekrar sayılmaz.

ISI ile a arasındaki ilişkinin büyüklüğü gruplar arasında değişir: D ve A'da değerlendirme grubunda, S'de kalibrasyon grubunda daha yüksektir. Rehber bu farkın yorumlanmasını öngörmez; iki gruptaki değer birlikte yazılır. Aşağıdaki gözlem rehberde yer almaz, ek bir öneridir. Bu farkları önemli sayma nedeni yoktur: 14 maddede birkaç maddenin sıra değiştirmesi katsayıyı 0,05 ile 0,10 düzeyinde değiştirebilir. Tek bir komşu sıra değişimi ise yalnız yaklaşık 0,004 değiştirir.

**Model tanıları.** C2 testi (Cai ve Monroe, 2014) her durumda kesin uyumu reddeder. n = 2.000'de bu beklenir; yaklaşık uyum RMSEA ile SRMSR birlikte okunarak değerlendirilir. C2 temelli RMSEA değerleri D'de 0,122 ve 0,133, S'de 0,115 ve 0,116, A'da 0,080 ve 0,093'tür.

C2 temelli RMSEA için doğrulanmış eşik bulunmamaktadır. Maydeu-Olivares ve Joe'nun (2014) M2 temelli RMSEA2 için önerdiği ölçütler şunlardır: 0,05 ve altı yakın uyum, 0,089 ve altı kabul edilebilir uyum. Bu ölçütler C2 temelli RMSEA için doğrudan geçerli değildir; yaklaşık bir okuma sağlarlar. Bu okumaya göre uyum D ve S'de zayıf, A'da sınırdadır.

SRMSR ise farklı bir tablo çizer. Değerler 0,045 ile 0,061 arasındadır ve yakın uyum için önerilen 0,05 ölçütüne (Maydeu-Olivares, 2013) yakındır; D ve A'nın kalibrasyon değerleri bu ölçütün altındadır. Ortalama artık korelasyon küçüktür. Bu örüntü, uyumsuzluğun geniş bir alana yayılmak yerine bazı madde çiftlerinde toplanmış olabileceğini düşündürür. Düzeltilmiş Q3 bu okumayla uyumludur: ortalamanın 0,20 üstünde kalan çift sayısı D'de 7 ve 10, S'de 6, A'da 3'tür; en büyük değerler 0,31 ile 0,48 arasındadır.

Bu 0,20 eşiği Rasch modelleri için önerilmiş bir tarama ölçütüdür (Christensen, Makransky ve Horton, 2017). GRM için yaklaşık bir göstergedir, karar kuralı değildir.

Bu durumda rehberin "uyum zayıfsa a değerleri bu model altında kestirilen ayırt edicilik olarak adlandırılır" kuralı en azından D ve S için uygulanmalıdır. Hangi ölçütün kullanılacağı ise tezin yöntem metninde açıkça belirtilmelidir, çünkü paket belgeleri sayısal bir eşik vermez. Tanılar, rehberin kuralı gereği bulgunun yanında raporlanır.

**Kosinüs ile Q3 arasındaki ilişki.** Bu ilişki üç alt boyutta ve iki grupta pozitif ve orta büyüklüktedir (0,33 ile 0,45 arası). Anlamca daha yakın madde çiftlerinde, ortak faktörün açıklamadığı ilişki daha yüksek olma eğilimindedir. A'daki Q07-Q41 ("shakiness" ile "trembling", kosinüs 0,71) ve D'nin değerlendirme grubundaki Q17-Q34 (değersizlik duygusu, kosinüs 0,82) bu okumaya uyan örneklerdir. D'nin kalibrasyon grubundaki en yüksek çift Q05-Q42'nin kosinüs değeri (0,55) ise daha düşüktür, oysa iki madde metni birbirine çok yakındır ("harekete geçememe" ile "işe başlama isteği bulamama"). Bu örnek, bu gömme matrisindeki kosinüs değerinin iki madde arasındaki içerik örtüşmesinin hepsini yansıtmayabileceğini düşündürür. Bu çıkarım rehberde yer almaz. 91 çift ortak maddeler içerdiği için bağımsız gözlem sayılmaz. Bu ilişki a değerlerindeki ya da güvenirlikteki olası şişmenin miktarını da göstermez.

**Önceki çalışmayla karşılaştırma.** Kilmen ve Bulut (2025), GRM ve BERT gömmeleriyle ECR ölçeğinde çalışmıştır. Kaygı alt boyutunda ayırt edicilik ile anlamsal benzerlik arasında negatif bir ilişki bildirmişlerdir (r = −0,55; yöntemde Spearman korelasyonu kullanılmıştır). Ters puanlanan maddeler içeren kaçınma alt boyutunda ise bu ilişkiyi gözlememişlerdir. Bu çalışmadaki yön pozitiftir. Rehberin kuralına göre bu fark bir yanlışlama olarak değil, ilişkinin ölçeğe ve koşullara bağlı olabileceği biçiminde yazılır. Karşılaştırma yalnız yön düzeyinde yapılır, çünkü ölçek, örneklem ve gömme modeli farklıdır.

**Denetimde çürüyen bir açıklama.** Belgenin ilk sürümünde şu olasılık öne sürülmüştü: anlamca merkezî maddelerin yüksek a değerinin bir bölümü, bu maddelerin birbirleriyle paylaştığı yerel bağımlılıktan kaynaklanıyor olabilir. Yerel bağımlılığın ayırt edicilik kestirimlerini şişirebileceği alanyazında bilinmektedir (Chen ve Thissen, 1997; Tuerlinckx ve De Boeck, 2001). Ancak bu çalışmanın verisi bu açıklamayı büyük ölçüde desteklemiyor:

- D'de en yüksek Q3 çifti Q05-Q42, en düşük ISI'ye sahip iki maddedir ve a değerleri düşüktür.
- S'de en yüksek çift Q12-Q33, en düşük ikinci ve üçüncü ISI değerlerine sahiptir.
- Açıklamaya yalnız A uyar (Q07, en yüksek ISI'ye sahip maddedir).

Bu nedenle açıklama bulgu yorumundan çıkarıldı. Yalnız danışmanın bilgisi için burada bırakıldı.

**Yorumda söylenmemesi gerekenler (rehberin AS1 kuralları).**

- Anlamsal benzerliğin ayırt ediciliği artırdığı gibi nedensel bir ifade.
- 14 maddenin ötesine, madde evrenine genelleme. Genel kural 1 ayrıca başka ölçeklere ve dillere genellemeyi de dışlar.
- Kosinüs-Q3 ilişkisinin a değerlerindeki ya da güvenirlikteki şişmenin miktarını gösterdiği.
- Kilmen ve Bulut (2025) ile yön farkının onların sonucunu yanlışladığı.

Rehberin genel kuralları gereği madde düzeyinde güven aralığı veya p değeri de verilmez, çünkü ISI değerleri aynı kosinüs matrisinden, a değerleri aynı modelden gelir ve bağımsız değildir.

## Danışmanın dikkatine

1. `ANALIZ_REHBERI.md` (AS1 bölümü) yazarın soyadını "Kılmen" diye yazıyor. Yayımlanmış künyede ad Sevilay Kilmen'dir (DergiPark profilinde KİLMEN). Tez metninde düzeltilmesi gerekir. Rehber paketin sabit dosyası olduğu için bu oturumda ona dokunulmadı.
2. Rehberdeki Kilmen ve Bulut özeti yalnız kaygı alt boyutundaki negatif ilişkiyi veriyor. Kaçınma alt boyutunda ilişkinin gözlenmediğini eklemek, karşılaştırmayı daha dengeli yapar.
3. "Zayıf uyum" için tezin yöntem metninde bir ölçüt adı verilmesi gerekir. Paket belgeleri eşik vermiyor ve C2 temelli RMSEA için doğrulanmış bir eşik bulunamadı.
4. Kaynak doğrulaması hakkında bir sınırlılık: Kilmen ve Bulut'taki −0,546 değeri ve kaçınma alt boyutu bulgusu, makalenin özeti ve arama motoru alıntılarıyla doğrulandı. Bu oturumun ağ politikası makalenin tam metnine erişimi engelledi.

## Kaynaklar (bu belgede ve kod notlarında geçen)

- Cai, L., & Monroe, S. (2014). *A new statistic for evaluating item response theory models for ordinal data* (CRESST Report 839). UCLA/CRESST.
- Chen, W.-H., & Thissen, D. (1997). Local dependence indexes for item pairs using item response theory. *Journal of Educational and Behavioral Statistics, 22*(3), 265-289.
- Christensen, K. B., Makransky, G., & Horton, M. (2017). Critical values for Yen's Q3: Identification of local dependence in the Rasch model using residual correlations. *Applied Psychological Measurement, 41*(3), 178-194. https://doi.org/10.1177/0146621616677520
- Kilmen, S., & Bulut, O. (2025). Shortening psychological scales: Semantic similarity matters. *Educational and Psychological Measurement, 85*(5), 910-934. https://doi.org/10.1177/00131644251319047
- Maydeu-Olivares, A. (2013). Goodness-of-fit assessment of item response theory models. *Measurement: Interdisciplinary Research and Perspectives, 11*(3), 71-101. https://doi.org/10.1080/15366367.2013.831680
- Maydeu-Olivares, A., & Joe, H. (2014). Assessing approximate fit in categorical data analysis. *Multivariate Behavioral Research, 49*(4), 305-328. https://doi.org/10.1080/00273171.2014.911075
- Samejima, F. (1969). Estimation of latent ability using a response pattern of graded scores. *Psychometrika Monograph Supplement, 17*.
- Tuerlinckx, F., & De Boeck, P. (2001). The effect of ignoring item interactions on the estimated discrimination parameters in item response theory. *Psychological Methods, 6*(2), 181-195.

## Dosyalar

- `berkcan_dass42_analiz.R`: yalnız AS1 bloğu doldurulmuş şablon.
- `ciktilar_as1_02/`: beş AS1 tablosu, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`.
- `karsilastir_as1_ref06.R`: AS1 tablolarını danışman başvuru çıktısıyla karşılaştıran betik; çıktısı `ciktilar_as1_02/karsilastirma_ref06.txt` dosyasındadır.

Bu betik Berkcan'ın paketindeki şablonun yerine kopyalanırsa, sonraki blok (AS2) aynı dosya üzerinde sürdürülebilir. Ancak yönergeye göre Berkcan'ın kendi aracıyla blok blok ilerlemesi ve blok notunu kendisinin yazması beklenir. Bu dosyanın ona verilip verilmeyeceği danışmanın kararıdır.
