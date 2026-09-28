# BOOTSTRAP: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonlarını doldurmaz; son ifade Berkcan'a aittir.

**Bu blok neye hizmet eder?** Anlamsal formların (MIN21, MAX21, COV21) alfa ve RMSE değerlerinin yayımlanmış DASS-21'den (PUB21) farkını ve bu farkın örneklemden örnekleme ne kadar oynadığını gösterir. RMSE farkları AS3'te ana metinde, alfa farkları eklerde raporlanır.

## Ne yapıldı ve nasıl denetlendi

Önceki bloklara dokunmadan yalnız `TODO BOOTSTRAP` bloğu dolduruldu (93 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- Katılımcı bootstrap'ının ne yaptığı: kişiler iadeli olarak yeniden çekilir.
- Neden aynı kişilerin bütün formlara uygulandığı: farklar eşleştirilmiş olsun diye.
- Farkların yönü: her zaman "anlamsal form eksi PUB21".
- Aralığın nasıl okunacağı.

Kod, 18 farkı hesaplayan tek bir yardımcı işlev kullanır. Bu işlev hem bütün grupta (nokta tahmini) hem her bootstrap tekrarında aynı biçimde çalışır; böylece iki hesap arasında tutarsızlık olamaz.

Blok 20 iç denetim ekler:
- 18 nokta tahmininin, AS2 ve AS3'te ayrı yoldan hesaplanan değerlerin farkına eşit olması.
- 2.000 tekrarın hepsinin sonlu olması.
- MIN21 ile MAX21'in RMSE farklarının her tekrarda eşit olması (tümleyen oldukları için).

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `boot_01`, bu bloğun 36 anahtarı (18 fark × alt ve üst sınır) | 36/36 `gecti` (tolerans 10⁻⁸) |
| Önceki blokların anahtarları aynı çalıştırmada | Hepsi `gecti` |
| 20 yeni iç denetim | Hepsi geçti (toplam 120) |
| `tablo_bootstrap_farklar.csv` | Var; sütunlar ve 18 satır doğru |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | 14 tablonun hepsi aynı |
| Çalışma süresi | Tam betik yaklaşık 1,5 dakika (bootstrap bunun çoğunu alır) |

Toplam durum: 182 geçti, 96 eksik (AS4, AS5, EK ANALİZLER), 1 farklı (çıktı dosyaları satırı; beklenen durum). Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

Farklar "anlamsal form eksi PUB21" yönündedir. B = 2.000; %95 yüzdelik aralığı; rehber kuralına göre dört ondalıkla verilmiştir. Son sütunun kararı, rehber kuralı gereği yuvarlanmamış değerlerle verilmiştir.

| Ölçü | Form | Alt boyut | Tahmin | %95 aralık | Aralık sıfırı dışlıyor mu? |
| --- | --- | --- | --- | --- | --- |
| RMSE | MIN21 ve MAX21 | D | 0,0724 | [0,0631; 0,0820] | Evet |
| RMSE | MIN21 ve MAX21 | A | 0,0262 | [0,0150; 0,0370] | Evet |
| RMSE | MIN21 ve MAX21 | S | 0,0028 | [−0,0057; 0,0107] | Hayır |
| RMSE | COV21 | D | 0,0276 | [0,0193; 0,0357] | Evet |
| RMSE | COV21 | A | 0,0112 | [0,0003; 0,0223] | Evet (alt sınır 0,000256) |
| RMSE | COV21 | S | −0,0251 | [−0,0336; −0,0161] | Evet |
| Alfa | MIN21 | D | −0,0036 | [−0,0073; 0,0003] | Hayır |
| Alfa | MIN21 | A | −0,0281 | [−0,0370; −0,0204] | Evet |
| Alfa | MIN21 | S | −0,0167 | [−0,0221; −0,0115] | Evet |
| Alfa | MAX21 | D | 0,0196 | [0,0165; 0,0229] | Evet |
| Alfa | MAX21 | A | 0,0287 | [0,0222; 0,0355] | Evet |
| Alfa | MAX21 | S | 0,0406 | [0,0342; 0,0480] | Evet |
| Alfa | COV21 | D | −0,0019 | [−0,0050; 0,0013] | Hayır |
| Alfa | COV21 | A | −0,0178 | [−0,0257; −0,0105] | Evet |
| Alfa | COV21 | S | −0,0029 | [−0,0089; 0,0029] | Hayır |

Kaynak: `tablo_bootstrap_farklar.csv`. MIN21 ve MAX21'in RMSE satırları tabloda ayrı ayrı yer alır, ama değerleri aynıdır; burada tek satırda gösterilmiştir.

## Nasıl yorumlanır

**Aralığın okunuşu.** Tahmin, farkın bütün değerlendirme grubundaki değeridir; bootstrap tekrarlarının ortalaması değildir. Aralık, 2.000 tekrardaki farkların 2,5. ve 97,5. yüzdelikleridir. Rehberin genel kural 4'üne göre iki okuma vardır:

- Sıfırı dışlayan bir aralık "bu örneklemde tutarlı bir fark" olarak okunur.
- Sıfırı içeren bir aralık eşdeğerlik kanıtı değildir. "Fark yok" diye yazılmaz; "bu örneklemde farkın yönü belirlenemedi" düzeyinde kalınır.

Aralıklar her fark için ayrı ayrı hesaplanmıştır; eşzamanlı değildir ve çoklu karşılaştırma düzeltmesi içermez.

**RMSE farkları (AS3).** Pozitif fark, anlamsal formun puanının tam puandan PUB21'e göre daha çok saptığını gösterir.

- MIN21 ve MAX21: D ve A'da PUB21'den tutarlı biçimde daha çok sapar (D'de 0,072, A'da 0,026 madde ortalaması birimi). S'de aralık sıfırı içerir. MIN21 ile MAX21'in farkları tanım gereği aynıdır; rehbere göre bu yeni bir bağımsız kanıt değildir.
- COV21: D'de PUB21'den tutarlı biçimde daha çok sapar (0,028), S'de ise tutarlı biçimde daha az sapar (−0,025). A'da fark küçüktür (0,011) ve aralığın alt sınırı sıfıra çok yakındır (0,00026). Bu yüzden "tutarlı" okuması teknik olarak geçerli olsa da sınırdadır ve öyle yazılması dürüst olur.
- Bu örüntü ALT KÜME TABLOSU'ndaki RMSE yüzdelikleriyle tutarlıdır. Örneğin COV21'in S'deki RMSE yüzdeliği 8,1, PUB21'inki 64,6 idi.

**Alfa farkları (ekler).**

- MAX21'in alfası üç alt boyutta da PUB21'den tutarlı biçimde yüksektir (0,020 ile 0,041).
- MIN21'in alfası A ve S'de tutarlı biçimde düşüktür (−0,028 ve −0,017). D'de aralık sıfırı içerir.
- COV21'in alfası yalnız A'da tutarlı biçimde düşüktür (−0,018); D ve S'de aralık sıfırı içerir.
- Rehbere göre bu aralıklar yalnız alfa içindir. AS2'nin ana göstergesi omega olduğu için bu aralıklar omega farkının aralığı gibi sunulmamalıdır. Yüksek alfa da "daha iyi ölçme" değil, "daha homojen puan" olarak okunur.

**Birlikte okuma.** PUB21 ile karşılaştırıldığında hiçbir anlamsal form her ölçüde ve her alt boyutta aynı yönde ayrışmamaktadır. MAX21 iç tutarlılıkta yukarıda, tam puan uyumunda D ve A'da geridedir. COV21 S'de tam puana daha yakın, D'de daha uzaktır. Rehberin genel kural 8'i gereği bu örüntüden kazanan bir form çıkarılmaz.

**Yorumda söylenmemesi gerekenler.**

- Sıfırı içeren aralığın iki formun eşdeğer olduğunu gösterdiği.
- Alfa aralıklarının omega farkı için de geçerli olduğu.
- Aralıkların eşzamanlı olduğu ya da bir p değeri yerine geçtiği.
- MIN21 ile MAX21'in aynı RMSE farkının iki ayrı bulgu olduğu.

## Danışmanın dikkatine

1. COV21'in A alt boyutundaki RMSE farkının alt sınırı 0,000256'dır. Dört ondalıkla 0,0003 yazılır ve sıfırı dışlar. Rehberin kuralı (karar yuvarlanmamış değerle verilir) izlenmiştir; ancak farklı bir tohum ya da B değeri bu kararı değiştirebilir. Tezde bu satır "sınırda" diye nitelenebilir.
2. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, 20 iç denetim ve başvuru çıktısıyla tam karşılaştırmadan ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni belgeye bakın).
- `ciktilar_boot_01/`: `tablo_bootstrap_farklar.csv`, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
