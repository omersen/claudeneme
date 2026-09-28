# EK ANALİZLER: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez ve rehberin bulgu yazım şablonunu doldurmaz; son ifade Berkcan'a aittir.

**Bu blok neye hizmet eder?** Ana sonuçların iki uygulama kararına ne kadar duyarlı olduğunu gösterir. Sonuçlar tezin eklerinde raporlanır.

1. **COV21 eşit çözümleri.** En küçük temsil kaybını (CL) veren birden fazla küme vardır. COV21 bunlar arasından madde numarası sırasıyla ilki alınarak seçilmiştir. Başka bir eşit küme seçilseydi alfa ve RMSE ne olurdu?
2. **Yanıt kalitesi (VCL).** DASS arşivinde katılımcılara gerçek ve uydurma sözcüklerden oluşan bir liste sorulmuştur. VCL6, VCL9 ve VCL12 uydurma sözcüklerdir. Bunlardan en az birini "biliyorum" diye işaretleyen kayıtlar dışlanınca AS1, AS2, AS3 ve AS5'in ana değerleri ne kadar değişir?

## Ne yapıldı ve nasıl denetlendi

Önceki bloklara dokunmadan yalnız `TODO EK ANALİZLER` bloğu dolduruldu (129 satır eklendi). Bloğun başındaki okuma kılavuzu şunları açıklar:

- İki duyarlılık sorusu.
- VCL kuralının ne olduğu. Eksik değer tek başına dışlama nedeni sayılmaz.
- Ana değerlerin `sonuc` listesinden okunduğu ve ana nesnelerin değiştirilmediği.
- Rehberin yorum kuralları.

Duyarlılık tablosunun 69 satırı tek bir yardımcı işlevle aynı biçimde üretilir: `fark = dışlanmış değer - ana değer`.

Blok 13 iç denetim ekler. Bunlar şunları denetler:

- COV21'in kendi kümesinin eşit çözümler arasında olması.
- Eşit küme sayısının Bölüm 5'teki sayıyla aynı olması.
- Yeniden kestirilen GRM parametrelerinin ve alt küme değerlerinin doğru sırada olması.
- Duyarlılık tablosunun 69 satır olması.

| Denetim | Sonuç |
| --- | --- |
| Çalıştırma `ek_01`, bu bloğun 51 anahtarı | 51/51 `gecti` |
| Bütün anahtarlar | 278/279 `gecti`; `eksik` anahtar kalmadı |
| Kalan tek `farkli` satır | Çıktı dosyaları satırı. İki şekil ŞEKİLLER bloğunda üretileceği için beklenen durumdur |
| 13 yeni iç denetim | Hepsi geçti (toplam 181) |
| Üç ek tablo | Var; sütunlar ve satır sayıları doğru |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | **Düzeltme:** Bu belgenin ilk sürümü "üç ek tablo dahil 21 tablo aynı" diyordu. Oysa karşılaştırma betiği o sırada `ek_*` dosyalarını kapsamıyordu, yani bu iddia denetlenmemişti. ŞEKİLLER adımında denetlendi. `ek_COV21_esit_cozumler.csv` ve `ek_VCL_orneklem.csv` aynıdır. `ek_VCL_duyarlilik.csv` tablosunun 69 değeri aynıdır (en büyük fark 2 × 10⁻¹⁶), ama satır sırası farklıydı: satırlar önce soruya göre diziliyordu, bu yüzden form sırası tabloda iki kez baştan başlıyordu (YÖNERGE Kural 7). Sıralama ŞEKİLLER adımında düzeltildi; son çalıştırmada (`sekil_04`) 21 tablonun hepsi satır sırası dahil aynıdır. `ciktilar_ek_01/` klasöründeki tablo eski sıradadır. |

Sabit bölüm özeti `9bef53a2…` ile aynıdır.

## Sonuçlar

**COV21 eşit çözümleri** (değerlendirme grubu; `ek_COV21_esit_cozumler.csv`):

| Alt boyut | Eşit küme sayısı | Alfa aralığı | COV21'in alfası | RMSE aralığı | COV21'in RMSE'si |
| --- | --- | --- | --- | --- | --- |
| D | 16 | 0,900 ile 0,907 | 0,907 (en yüksek) | 0,168 ile 0,180 | 0,178 |
| A | 2 | 0,821 ile 0,830 | 0,830 (en yüksek) | 0,205 ile 0,221 | 0,221 (en yüksek) |
| S | 8 | 0,844 ile 0,849 | 0,849 (en yüksek) | 0,171 ile 0,182 | 0,180 |

**VCL örneklemi** (`ek_VCL_orneklem.csv`). Kalibrasyonda 366 kayıt (%18,3), değerlendirmede 384 kayıt (%19,2) dışlanmıştır; 1.634 ve 1.616 kayıt kalmıştır. Üç VCL sütununda eksik değeri olan kayıt yoktur.

**VCL sonrası değişimler** (`ek_VCL_duyarlilik.csv`):

| Ölçü | En büyük mutlak değişim |
| --- | --- |
| ISI-a ilişkisi (AS1) | 0,044 (S: 0,793 → 0,750) |
| AS5 CL_b-RMSE ilişkisi | 0,018 (A: 0,530 → 0,512) |
| AS5 SB-alfa ilişkisi | 0,017 (S: −0,780 → −0,797) |
| Yanlılık | 0,0075 |
| Omega | 0,0038 |
| Alfa | 0,0037 |
| RMSE | 0,0026 |
| RMSEA | 0,0020 |
| CFI | 0,0015 |
| SRMR | 0,0015 |

AS1 ilişkileri VCL sonrasında D'de 0,61, A'da 0,67, S'de 0,75 olmuştur. AS5 ilişkileri D'de −0,81 ve 0,69, A'da −0,62 ve 0,51, S'de −0,80 ve 0,75 olmuştur.

## Nasıl yorumlanır

**COV21 eşit çözümleri.** COV21'in alfası, üç alt boyutta da eşit çözümler arasında en yüksek değerdir. RMSE'si ise A'da en yüksek, D ve S'de aralığın üst yarısındadır. Rehbere göre yazılacak olan, COV21'in değerlerinin bu aralıktaki yeridir. Aralıklar dardır: alfada en fazla 0,009, RMSE'de en fazla 0,016. Bu, madde numarası sırasıyla yapılan seçimin AS2 ve AS3 sonuçlarını küçük bir aralık içinde etkilediğini gösterir. Rehberde yer almayan bir not: bu küçük aralık, BOOTSTRAP'taki bazı COV21 farklarıyla aynı büyüklüktedir. Örneğin A'da RMSE farkı 0,011'dir ve RMSE aralığı 0,016 genişliğindedir. Bu nedenle COV21'in sınırda kalan RMSE farklarını yorumlarken bu belirsizlik akılda tutulmalıdır.

**VCL duyarlılığı.**

- **Büyüklük.** Alfa, omega, RMSE ve uyum indekslerindeki değişimler binde birler düzeyindedir. En büyük değişimler, 14 madde üzerinden hesaplanan AS1 ilişkilerindedir (0,02 ile 0,04).
- **Yön.** Bütün AS1 ve AS5 ilişkilerinin yönü ve büyüklük adlandırması (güçlü) korunmuştur.
- **Sıralar.** Denetimle doğrulandı; genelleme değildir. Alfa, RMSE ve yanlılıkta dört formun sırası üç alt boyutta da korunmuştur. Omega sırası A ve S'de korunmuş, D'de değişmiştir: PUB21 ile COV21 yer değiştirmiştir. Ana analizde değerler 0,9160 ve 0,9164, VCL sonrasında 0,9156 ve 0,9152'dir; fark iki durumda da 0,0005'in altındadır. Rehbere göre bu durumda sıra değil, değerler ve farkın büyüklüğü raporlanır. Bu sıra değişimi önemli bir fark olarak sunulmamalıdır. CFI, RMSEA ve SRMR sıraları dört form arasında korunmuştur.
- **AS5'in tutarlılığı.** Rehbere göre AS5 ilişkileri, iki grupta ve yanıt kalitesi taramasından sonra aynı yönü gösterirse tutarlı sayılır. Bu koşul artık üç alt boyutta da sağlanmıştır; AS5 belgesinde ertelenen "tutarlı" niteleme verilebilir.

**Yorumda söylenmemesi gerekenler (rehberin Ekler kuralları).**

- İşaretlenen her kaydın geçersiz olduğu. Uydurma sözcüğü işaretlemek dikkatsizliğin olası bir göstergesidir, kesin kanıtı değildir.
- Değerleri çok yakın iki form arasındaki sıra değişiminin (D'de PUB21 ile COV21'in omegası) önemli bir fark olduğu.
- Denetlenmemiş "bütün sıralamalar korundu" gibi genellemeler. Burada omega için bu ifade yanlış olur.

## Danışmanın dikkatine

1. Kayıtların yaklaşık beşte biri (%18 ile %19) VCL kuralıyla dışlanmaktadır. Oran yüksek görünebilir; kural tek bir uydurma sözcüğü işaretlemeyi yeterli sayar. Tezde oranın gerekçesiyle birlikte verilmesi okuru hazırlar.
2. Danışman notundaki iki bilgi bu çalıştırmada doğrulandı: VCL sonrası AS5 değişimleri en fazla 0,018'dir ve D'de PUB21 ile COV21'in omega sırası değişmektedir.
3. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Denetim kabul testi, 13 iç denetim ve başvuru çıktısıyla tam karşılaştırmadan ibarettir.

## Dosyalar

- `berkcan_dass42_analiz.R`: şablonun güncel hâli (en son doldurulan bloklar için en yeni belgeye bakın).
- `ciktilar_ek_01/`: `ek_COV21_esit_cozumler.csv`, `ek_VCL_orneklem.csv`, `ek_VCL_duyarlilik.csv`, `sonuc_degerleri.csv`, `kabul_raporu.csv`, `cikti_denetimi.csv`, `ic_denetimler.csv`, `analiz_gunlugu.txt`, `calistirma_durumu.json`, `oturum_bilgisi.txt`, `karsilastirma_ref06.txt`.
