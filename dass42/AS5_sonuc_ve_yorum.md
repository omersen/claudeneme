# AS5: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonunu doldurmaz; son ifade Berkcan'a aittir.

**Araştırma sorusu 5 (AS5).** DASS-42'nin her alt boyutundan seçilebilecek bütün yedili madde kümelerinde, anlamsal çeşitlilik ve temsil ile puan güvenirliği ve tam form puanlarıyla uyum arasında nasıl bir ilişki vardır?

Rehbere göre AS5, ilk sonuçlar görüldükten sonra eklenmiş keşfedici bir sorudur ve bulguları betimseldir. "Alt küme testi" adı çıkarımsal bir hipotez testini değil, bütün olası kümelerin betimsel karşılaştırmasını anlatır.

## Ne yapıldı ve nasıl denetlendi

Önceki bloklara dokunmadan yalnız `TODO AS5` bloğu dolduruldu (76 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- AS5'in metni ve keşfedici niteliği.
- Hangi değerin metinden (SB, CL_b), hangisinin yanıtlardan (alfa, RMSE, s_d, yanlılık) geldiği.
- İki ana ilişkinin analiz birimi. SB ile alfa ilişkisi 3.432 küme üzerindedir. CL_b ile RMSE ilişkisi 1.716 bölünme üzerindedir, çünkü RMSE bir küme ile tümleyeninde aynıdır.
- Rehberin yorum kuralları.

Blok 24 iç denetim ekler:

- Dilimin satır sırasının `alt_kume` ile aynı olması.
- Her kümenin RMSE değerinin tümleyenininkine eşit, yanlılığının ters işaretli olması (fark < 10⁻¹²).
- Her alt boyut ve grupta bölünme sayısının 1.716 olması.

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `as5_01`, bu bloğun 18 anahtarı | 18/18 `gecti` |
| Önceki blokların anahtarları | Hepsi `gecti` |
| 24 yeni iç denetim | Hepsi geçti (toplam 168) |
| `tablo_AS5_iliskiler.csv` | Var; sütunlar ve 6 satır doğru |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | 18 tablonun hepsi aynı |

Toplam durum: 227 geçti, 51 eksik (EK ANALİZLER), 1 farklı. Farklı satır, çıktı dosyaları satırıdır; iki şekil ŞEKİLLER bloğunda üretileceği için beklenen durumdur. Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

Bütün kümelerde Spearman ilişkileri:

| Alt boyut | Grup | SB - alfa (3.432 küme) | CL_b - RMSE (1.716 bölünme) | CL_b - s_d | CL_b - mutlak yanlılık |
| --- | --- | --- | --- | --- | --- |
| D | kal | −0,79 | 0,67 | 0,69 | 0,19 |
| D | deg | −0,81 | 0,69 | 0,72 | 0,20 |
| A | kal | −0,60 | 0,53 | 0,67 | 0,19 |
| A | deg | −0,63 | 0,53 | 0,66 | 0,20 |
| S | kal | −0,74 | 0,75 | 0,75 | 0,17 |
| S | deg | −0,78 | 0,76 | 0,76 | 0,15 |

Kaynak: `tablo_AS5_iliskiler.csv`. Ana analiz değerlendirme grubundadır (deg); kalibrasyon grubu (kal) tekrardır. Rehbere göre açıklayıcı iki ilişki (s_d ve mutlak yanlılık) yalnız değerlendirme grubunda anahtar olarak raporlanır; tabloda iki grup da vardır.

## Nasıl yorumlanır

**SB ile alfa.** İlişki üç alt boyutta ve iki grupta negatif ve güçlüdür (değerlendirmede −0,81, −0,63, −0,78). Rehberin okunuşuyla: bu madde havuzunda, seçilen maddeler anlamca çeşitlendikçe iç tutarlılık düşme eğilimindedir. Bu, AS2-AS4'te dört formda görülen örüntünün (MAX21'in yüksek alfası ile düşük SB'si, MIN21'in tersi) yalnız bu formlara özgü olmadığını, bütün seçimler boyunca görüldüğünü gösterir.

**CL_b ile RMSE.** İlişki pozitif ve güçlüdür (değerlendirmede 0,69, 0,53, 0,76). CL_b, bir bölünmenin iki yarısının birbirini anlamsal olarak ne kadar temsil ettiğini gösterir; düşükse iki yarı birbirini iyi temsil eder. Rehberin okunuşuyla: iki yarının birbirini anlamsal olarak temsil etmesi zayıfladıkça, kısa puanın tam form puanından sapması artma eğilimindedir.

**RMSE'nin hangi bileşeni?** CL_b'nin s_d ile ilişkisi (0,66 ile 0,76) mutlak yanlılıkla ilişkisinden (0,15 ile 0,20, zayıf) belirgin biçimde güçlüdür. Rehberin önerdiği okunuş şudur: anlamsal temsil, kişi düzeyindeki dağılımla daha çok, madde ortalamalarından doğan yanlılıkla daha az ilişkilidir. Olası bir açıklama, madde metinlerinin madde ortalamalarını (güçlük düzeyini) yansıtmamasıdır. Rehberin açıkça belirttiği gibi bu açıklama bu çalışmada sınanmamıştır ve öyle yazılmalıdır.

**Tutarlılık.** Rehbere göre iki grupta ve yanıt kalitesi taramasından sonra aynı yön görülürse ilişki tutarlı sayılır. İki grupta yön ve büyüklük adlandırması aynıdır; kalibrasyon ve değerlendirme değerleri arasındaki en büyük fark 0,035'tir (S'de SB-alfa). Yanıt kalitesi taraması (VCL) EK ANALİZLER bloğunda yapılacaktır. Bu yüzden şimdilik "iki grupta aynı yön" denebilir; "tutarlı" nitelemesi o blok tamamlanınca verilmelidir. Danışman notuna (`DANISMAN_NOTU.md`) göre VCL sonrası değişimler en fazla 0,018'dir; bu, betik tamamlandığında doğrulanacaktır.

**Yorumda söylenmemesi gerekenler (rehberin AS5 kuralları).**

- "Metin psikometrik sonucu öngörüyor" gibi bir yordama iddiası ya da bir başarı eşiği.
- Yeni madde havuzlarına genelleme ya da nedensellik.
- p değeri ya da kümeleri bağımsız sayan bir aralık. Kümeler ortak maddeler içerir.
- CL_b'nin hangi yarının tutulacağını söylediği. CL_b iki yarı yer değiştirdiğinde değişmez.
- CL_b'nin bölünme düzeyinde tanımlanmasının bir yöntem üstünlüğü olduğu. Bu yalnız RMSE'nin bir küme ile tümleyeninde aynı olmasına uyum içindir.
- Dağılımdan en iyi görünen küme seçilerek beşinci bir form önerilmesi.

## Danışmanın dikkatine

1. SB ile alfa ilişkisinin güçlü olması kısmen beklenebilir: SB, seçilen maddeler arasındaki ortalama kosinüs benzerliğinden, alfa ise maddeler arası kovaryanslardan türer. AS1'de ISI ile a arasında güçlü bir ilişki bulunduğu için, anlamca yakın maddelerin ampirik olarak da daha yüksek ilişkili olması bu sonucu doğal kılar. Bu gözlem rehberde yer almaz. Tartışmada "tanım gereği" değil ama "önceki bulgudan beklenen" bir sonuç olarak konumlandırılması düşünülebilir.
2. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, 24 iç denetim ve başvuru çıktısıyla tam karşılaştırmadan ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: AS1-AS5, ALT KÜME TABLOSU ve BOOTSTRAP blokları doldurulmuş şablon.
- `ciktilar_as5_01/`: `tablo_AS5_iliskiler.csv`, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
