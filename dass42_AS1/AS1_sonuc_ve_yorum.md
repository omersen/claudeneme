# AS1: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Bu belge `blok_notlari.md` yerine geçmez. Rehbere göre blok notu Berkcan'ın kendi cümleleriyle yazılır ve rehberdeki bulgu yazım şablonlarını yapay zekâ aracı doldurmaz. Bu nedenle aşağıda şablon cümleleri doldurulmamış, sonuçların nasıl okunacağı açıklanmıştır.

**Araştırma sorusu 1 (AS1).** DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer maddelerle ortalama anlamsal benzerliği (ISI) ile GRM altında kestirilen ayırt edicilik parametreleri (a) arasında nasıl bir ilişki vardır?

## Ne yapıldı ve nasıl denetlendi

`berkcan_dass42_analiz.R` şablonunda yalnız `TODO AS1` bloğu dolduruldu. Açıklama ve işaret satırlarına dokunulmadı; özgün şablonla fark, bloğun içine eklenen 125 satırdan ibarettir. Kodun başındaki okuma kılavuzu üç şeyi açıklar: AS1'in metni, her verinin hangi amaçla kullanıldığı (ISI yalnız madde metinlerinden, a ve CITC yanıtlardan, kosinüs matrisi madde çiftlerinden gelir) ve sonuçların nasıl yorumlanacağı. Kodun her adımında da o adımın amacını ve yorumunu anlatan kısa notlar vardır.

Bu bulut ortamında R kurulu değildi. Paketteki `ortam/linux-explicit.txt` dosyasıyla sabit conda-forge ortamı yalnız bu geçici bulut ortamına kuruldu. Kurulan sürümler önerilenlerle aynıdır: R 4.5.3, lavaan 0.7.2, semTools 0.5.9, mirt 1.47. Bu, paketteki `CLAUDE.md` dosyasının "R'yi veya paketleri kurmaya çalışma" kuralından bilinçli bir sapmadır. Kural Berkcan'ın bilgisayarını korumak için yazılmıştır; burada ne Berkcan'ın bilgisayarına ne de pakete dokunuldu.

| Denetim | Sonuç |
| --- | --- |
| Boş şablon (`bos01`) | 8 geçti, 270 eksik, 1 farklı; sabit bölüm özeti `9bef53a2…` (beklenenle aynı) |
| AS1 çalıştırması (`as1_01`), 12 AS1 anahtarı | 12/12 `gecti`; en büyük fark 4,4 × 10⁻¹⁶ |
| Dört BUTUNLUK satırı | Üçü `gecti`. `BUTUNLUK_cikti_dosyalari` `farkli`, çünkü sonraki blokların dosyaları henüz yok (beklenen durum) |
| `cikti_denetimi.csv`, beş AS1 tablosu | Beşi de var; sütunlar ve satır sayıları doğru |
| İç denetimler | 43 denetimin hepsi geçti (AS1 bloğu 21 denetim ekledi: ISI, parametre ve Q3 sırası, kategori toplamları) |
| Günlükteki uyarılar | GRM, M2 veya Q3 için hiç uyarı yok |
| Danışman başvuru çıktısı `ref06` ile tablo karşılaştırması (kod yazılıp çalıştırıldıktan sonra yapıldı; başvuru çözümünün kodu okunmadı) | Beş AS1 tablosu, puanlanmayan değerler ve satır sırası dahil aynı; en büyük fark 1,0 × 10⁻¹¹ (C2 değerinde) |

`KABUL`, hesapların başvuru değerleriyle eşleştiğini gösterir; GRM'nin iyi uyum verdiğini göstermez (rehber, kural 7). Tanılar aşağıda ayrıca değerlendirilmiştir.

## Sonuçlar

| Alt boyut | Grup | ρ(ISI, a) | ρ(ISI, CITC) | ρ(a, CITC) | C2 RMSEA | SRMSR | En büyük düzeltilmiş Q3 | Q3 > 0,20 çift sayısı (91 çiftte) | ρ(kosinüs, Q3) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D | kal | 0,63 | 0,60 | 0,99 | 0,122 | 0,049 | 0,48 | 7 | 0,39 |
| D | deg | 0,73 | 0,71 | 0,89 | 0,133 | 0,054 | 0,47 | 10 | 0,38 |
| A | kal | 0,63 | 0,60 | 0,97 | 0,080 | 0,045 | 0,31 | 3 | 0,42 |
| A | deg | 0,70 | 0,71 | 0,97 | 0,093 | 0,052 | 0,37 | 3 | 0,45 |
| S | kal | 0,79 | 0,75 | 0,99 | 0,115 | 0,060 | 0,45 | 6 | 0,42 |
| S | deg | 0,69 | 0,72 | 0,93 | 0,116 | 0,061 | 0,46 | 6 | 0,33 |

Kaynak: `tablo_AS1_ISI_a.csv`, `tablo_AS1_GRM_tani.csv`, `tablo_AS1_kosinus_Q3.csv`. Bütün C2 testlerinde sd = 77 ve p < 0,001'dir. Somut bir örnek: kalibrasyon grubunda en düşük ISI değerine sahip maddelerin a değeri de düşüktür (D: Q42, a = 1,66; A: Q02, a = 1,15). En yüksek ISI değerine sahip maddelerin a değeri yüksektir (D: Q21, a = 3,60; A: Q07, a = 2,37). En seyrek kullanılan yanıt kategorisi A alt boyutunda Q23'ün (yutkunma güçlüğü) en üst kategorisidir: kalibrasyonda 85, değerlendirmede 101 kişi. Dört kategori her maddede gözlenmiştir.

## Nasıl yorumlanır

**Yön ve büyüklük.** Üç alt boyutta ve iki grupta ISI ile a arasındaki Spearman korelasyonu pozitiftir ve 0,63 ile 0,79 arasındadır. Rehberin adlandırmasıyla (|ρ| ≥ 0,50) bu "güçlü" bir ilişkidir; bu adlandırma bir başarı eşiği değildir. Okunuşu şudur: bu 14 maddelik havuzlarda, alt boyutun diğer maddelerine anlamca daha yakın maddelerin, GRM altında kestirilen ayırt ediciliği daha yüksek olma eğilimindedir.

**Tutarlılık.** Rehberin tanımına göre, kalibrasyon, değerlendirme ve modelden bağımsız CITC göstergesi aynı yönü gösterdiğinde ilişki tutarlı sayılır. Bu koşul üç alt boyutta da sağlanmıştır: ISI ile CITC arasındaki ilişki 0,60 ile 0,75 arasındadır. a ile CITC arasındaki ilişki 0,89 ile 0,99 arasındadır; yani iki ayırt edicilik göstergesi maddeleri hemen hemen aynı sırayla dizer. Büyüklük gruplar arasında değişir: D ve A'da değerlendirme grubunda, S'de kalibrasyon grubunda daha yüksektir. Bu nedenle tek bir değer değil, iki gruptaki değer birlikte yazılmalıdır. Bu farklar da yorumlanmamalıdır. n = 14 iken tek bir maddenin sırasının değişmesi katsayıyı belirgin biçimde oynatır.

**Model tanıları ve adlandırma.** C2 temelli RMSEA, D ve S'de 0,12 ile 0,13 arasında, A'da 0,08 ile 0,09 arasındadır. Yaygın kullanılan ölçütlere göre bu değerler, özellikle D ve S'de, zayıf yaklaşık uyuma işaret eder. SRMSR 0,045 ile 0,061 arasındadır. Yerel bağımlılık belirgindir: düzeltilmiş Q3 tarama eşiğini (0,20) D'de 7 ile 10, S'de 6, A'da 3 madde çifti aşmaktadır. Rehberin kuralı gereği a değerleri tezde "bu model altında kestirilen ayırt edicilik" diye adlandırılmalıdır. Tanılar sınırlılıklar bölümüne bırakılmadan bulgunun yanında raporlanmalıdır. Büyük örneklemde C2'nin p değeri neredeyse her zaman küçük çıkacağı için ondan ayrıca bir sonuç çıkarılmamalıdır.

**Kosinüs ile Q3 arasındaki ilişki.** Bu ilişki altı durumun hepsinde pozitif ve orta büyüklüktedir (0,33 ile 0,45 arası). Anlamca daha yakın madde çiftlerinde, ortak faktörün açıklamadığı ilişki daha yüksek olma eğilimindedir. En yüksek Q3 değerine sahip çiftler bu okunuşu somutlaştırır; bunlar birbirinin neredeyse başka sözcüklerle yazılmış hâli olan madde çiftleridir:

- Q17 "I felt I wasn't worth much as a person" ile Q34 "I felt I was pretty worthless" (kosinüs 0,82),
- Q07 "shakiness" ile Q41 "trembling" (0,71),
- Q08 "difficult to relax" ile Q22 "hard to wind down" (0,77).

Buna karşılık D'deki en yüksek Q3 çifti Q05 ile Q42'dir: "I just couldn't seem to get going" ile "I found it difficult to work up the initiative to do things". Bu çiftin kosinüs benzerliği daha düşüktür (0,55). Anlamsal yakınlık yerel bağımlılığın tek kaynağı değildir. 91 çift ortak maddeler içerdiği için bağımsız gözlem sayılmaz.

**Rehberde yazmayan bir gözlem (sınanmamış, alternatif açıklama).** ISI ile a arasındaki pozitif ilişki ile kosinüs ile Q3 arasındaki pozitif ilişki birlikte düşünüldüğünde, akla bir alternatif açıklama gelir: anlamca merkezî maddelerin yüksek a değerinin bir bölümü, bu maddelerin birbirleriyle paylaştığı yerel bağımlılıktan kaynaklanıyor olabilir. Tek boyutlu modelde birbirine benzeyen madde kümeleri gizil değişkeni kendi ortak içeriklerine doğru çekebilir. Bu çalışma bu olasılığı sınamamaktadır ve rehberin kuralına göre kosinüs-Q3 ilişkisi şişmenin miktarını göstermez. Tezde "olası bir açıklama, bu çalışmada sınanmamıştır" düzeyinde kalmalıdır. Bu açıklamanın, MAX21 formunun AS2'deki güvenirlik değerleri yorumlanırken de akılda tutulması yararlı olur.

**Önceki çalışmayla karşılaştırma.** Rehbere göre Kılmen ve Bulut (2025), ECR kaygı alt boyutunda negatif bir ilişki (r = −0,55) bildirmiştir. Bu çalışmadaki yön terstir. Rehberin kuralına göre bu fark bir yanlışlama olarak değil, ilişkinin ölçeğe ve koşullara bağlı olabileceği biçiminde yazılır. Karşılaştırma yalnız yön düzeyinde yapılır, çünkü ölçek, örneklem ve gömme modeli farklıdır.

**Yorumda söylenmemesi gerekenler.** Anlamsal benzerliğin ayırt ediciliği artırdığı gibi nedensel bir ifade. 14 maddenin ötesine, madde evrenine ya da başka ölçeklere genelleme. Madde düzeyinde güven aralığı veya p değeri (ISI değerleri aynı kosinüs matrisinden, a değerleri aynı modelden gelir; bağımsız değildir). Kosinüs-Q3 ilişkisinin a değerlerindeki ya da güvenirlikteki şişmenin miktarını gösterdiği. Gruplar arasındaki küçük katsayı farklarından sonuç çıkarılması.

## Dosyalar

- `berkcan_dass42_analiz.R`: yalnız AS1 bloğu doldurulmuş şablon.
- `ciktilar_as1_01/`: beş AS1 tablosu, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`.

Bu betik Berkcan'ın paketindeki şablonun yerine kopyalanırsa, sonraki blok (AS2) aynı dosya üzerinde sürdürülebilir. Ancak yönergeye göre Berkcan'ın kendi aracıyla blok blok ilerlemesi ve blok notunu kendisinin yazması beklenir. Bu dosyanın ona verilip verilmeyeceği danışmanın kararıdır.
