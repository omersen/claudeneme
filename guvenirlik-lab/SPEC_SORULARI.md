# Spec soruları (Aşama 0)

Bu liste, SPEC.md'nin Aşama 0'da şüpheci bir gözle okunmasından çıkmıştır. SPEC.md değiştirilmemiştir. Her maddede sorun, SPEC'teki yeri (satır numarası), etkisi, kullanıcı yanıt vermezse uygulanacak varsayılan karar ve kullanıcı yanıtının Aşama 1'den önce gerekip gerekmediği yazılıdır. Varsayılan kararlar `<belirsizlik_durumunda>` kuralına göre en basit ve psikometrik olarak en temkinli seçenektir; uygulandıklarında `PROGRESS.md` içine kaydedilir. `formulas.expected.json` onayı SPEC'in kendi DUR koşuludur ve bu listenin dışındadır.

Sayısal doğrulama özeti. Modül metinlerinde, `<ortak_ogeler>` içinde ve G tablosunda geçen ve `<sabit_veri>` içinde ayrıca verilmeyen her sayı Python `fractions` ile kesin aritmetikle yeniden hesaplandı; ayrıca `<sabit_veri>`'deki popülasyon tablosu (α / ω / $L_2$, iki blok dahil) kayan noktayla yeniden üretildi. Uyuşmazlık bulunmadı. Doğrulananlar: M1 (iki sınıfın varyansı 100 ve 100; +5 varyansı değiştirmez); M2 ($\hat T=60$; artıklar +2, −2, +5, −5, 0; +3 ile $\hat T=63$, artıklar aynı); M3 (0,80; 0,50; ÖSH 4); M4 senaryo 3 (0,75; √0,75 ≈ 0,8660; 0,80; √0,60 ≈ 0,7746; √0,80 ≈ 0,8944), senaryo 6 (17/18; 408/803 ≈ 0,5081), senaryo 7 (2/7), senaryo 9 ve G.10 (280/377 ≈ 0,7427), uzlaştırma kartı (76/91, 10/11); M5 ($s_D^2=1{,}6$; 0,8; 14,4; 17/18; ÖSH ≈ 0,894; $n$ paydasıyla 4/3, 2/3, 12, ÖSH ≈ 0,816; $r ≈ 0{,}9448$; köşegen kalanları 0,4 ve 1,2; √0,4 ≈ 0,6325; kontrol 16, 4, 66-74; binom kapsama 115957/131072 ≈ 0,8847 ve ≈ 0,9974); M6 (3/4, 65/72, 25/36; 9/25, 7/50, 11/25); M7 (68/√5180; 0,75; 0,90; 8/3; en büyük $r_\varphi$ 0,25; 15/22; 105/131; 0,5987'den 0,6758'e, ω 0,6667'den 0,7326'ya); M8 (27; 2/3); M9 (0,80; $KO_{içi}=7/6$, $\hat\sigma_p^2=23/24$, 23/30 ≈ 0,7667). Ayrıca yerel KaTeX 0.18.9 (npm) ile `formulas.expected.json` içindeki 137 TeX kaynağı SPEC'teki `trust` ve `strict` ayarlarıyla işlendi: hata ve konsol uyarısı yok. Artifact sayfa sözleşmesi ve `downloads` yeteneğinin tür tanımları SPEC'in dayandığı kısıtlarla (iskeletsiz parça, CDN izin listesi, yasak API'ler, yalnızca çıplak `#belirteç`, `claude.use("downloads")` ile `save({filename, data})`, CSV ve JSON uzantılarına izin) karşılaştırıldı; çelişki yok. Doğrulama betikleri depo dışında, oturumun geçici dizininde tutuldu.

## Aşama 1'den önce kullanıcı yanıtı gerekenler

1. Alt ajan kullanımı SPEC'in maliyet kuralıyla çelişiyor.
   - Soru/sorun: SPEC "son gözden geçirici dışında alt ajan kullanma" der. Aşama 0 çalışması (bu liste dahil) bir iş akışı içinde alt ajanlarla yürütülüyor. Bu, SPEC'ten bir sapmadır ve `<raporlama>` gereği açıkça bildirilmelidir. Kullanıcının "ilk adımla başla" isteği alt ajan kullanımına ilişkin bir izin içermiyor.
   - SPEC konumu: satır 354 (Maliyet); satır 489 (Katman C tek istisna).
   - Etki: orta (maliyet ve tekrar üretilebilirlik kaydı).
   - Önerilen karar: Aşama 0'daki sapma `PROGRESS.md` içinde "Spec'ten sapmalar" altında kaydedilir. Kullanıcı açıkça izin vermedikçe Aşama 1'den itibaren alt ajan kullanılmaz; Katman C gözden geçiricisi tek istisna olarak kalır.
   - Aşama 1'den önce kullanıcı yanıtı: Evet (iş akışının Aşama 1'de sürüp sürmeyeceğini belirler).

2. A11'deki $r^2_{X\eta}$ toleransı doğru bir uygulamada şans eseri kalabilir.
   - Soru/sorun: Kararlı yanlılık eklenmiş koşulda popülasyon değeri $r^2_{X\eta}=100/169≈0{,}5917$'dir. $N=20000$'de $r$'nin standart hatası yaklaşık $(1-\rho^2)/\sqrt N≈0{,}0029$, $r^2$'ninki yaklaşık $2\rho\cdot0{,}0029≈0{,}0044$'tür. 0,01 toleransı yalnızca yaklaşık 2,3 standart hataya karşılık gelir. 300 tekrarlı bir benzetimde tohum başına kalma oranı %2,7 çıktı; beş tohumdan (1-5) en az birinin kalma olasılığı yaklaşık %12,6'dır. Tohumlar sabit olduğu için sonuç belirlenimcidir: kalırsa her çalıştırmada kalır. SPEC toleransların gevşetilmesini yasaklar (satır 442). A11'in diğer denetimleri güvenlidir (ör. α için standart hata ≈ 0,0013-0,0019, tolerans 5 standart hatanın üstünde). A12'de tohum sayısı belirtilmemiştir.
   - SPEC konumu: satır 455 (A11), 456 (A12), 442.
   - Etki: orta (Aşama 1'de gereksiz bir DUR riski).
   - Önerilen karar: SPEC olduğu gibi uygulanır (tolerans 0,01, $N=20000$, tohum 1-5). A12 için de tohum 1-5 kullanılır. Test kalırsa tolerans değiştirilmez; DUR edilir ve bu hesapla raporlanır. Kullanıcı isterse şimdiden şu seçeneklerden birini onaylayabilir: bu alt denetim için $N=100000$ (standart hata ≈ 0,0020, tolerans ≈ 5 standart hata) ya da tolerans 0,015.
   - Aşama 1'den önce kullanıcı yanıtı: Evet (Aşama 1 onaylandıktan sonra test değişikliği yalnızca kullanıcı onayıyla yapılabilir).

20. `<sabit_veri>` içindeki ortalama madde korelasyonu $\bar r=.5080$ yanlış yuvarlanmış (Aşama 0 sonunda eklendi; numarası sona eklendiği için 20'dir).
   - Soru/sorun: Sabit Veri A'nın altı madde korelasyonunun ortalaması 0,507945'tir; dört basamakta .5079 olur. .5080, .507945 → .50795 → .5080 biçiminde çift yuvarlamadan gelmiş görünüyor. SPEC'teki $\alpha_{std}=.8050$ doğru değerle tutarlıdır; .5080 alınırsa $\alpha_{std}$ .8051 çıkar. Yani SPEC'in iki değeri birbiriyle çelişir ve hatalı olan .5080'dir. Değer iki bağımsız ajan ve lider tarafından ayrı ayrı yeniden hesaplandı. Yalnızca destek değeri etkilenir; ekranda gösterilen $\alpha_{std}$ doğrudur.
   - SPEC konumu: satır 388; `tests.json` A3.22.
   - Etki: düşük (içerik), ama A3.22 testi doğru bir uygulamada kalır ve Aşama 1'de gereksiz bir DUR'a yol açar.
   - Önerilen karar: Kullanıcı onaylarsa A3.22'nin beklenen değeri .5079 olur. Onay gelmezse test SPEC'teki değerle bırakılır, kalması beklenir ve bu açıklamayla raporlanır; testin toleransı gevşetilmez.
   - Aşama 1'den önce kullanıcı yanıtı: Evet.

## Kullanıcı kararı gereken, Aşama 1'i beklemeyenler

3. M4 uzlaştırma kartındaki iki cümle B.1 ile uyuşmuyor.
   - Soru/sorun: (a) Kart "güvenirliği düşürmez ama değiştirir: çoğunlukla yükseltir (...), yapıyla güçlü ters ilişkiliyse düşürür" der; aynı cümle hem "düşürmez" hem "düşürür" demektedir. (b) "Her iki durumda puanların yapıyla ilişkisi zayıflar" koşulsuz bir iddiadır; B.1 ise bunu "$U$, η ile ilişkisizse" koşuluna bağlar, G.5 de $B\perp\eta$ varsayar. Kartın örneği 10/11 (yüksek puanlılara madde başına +1) tam da yapıyla pozitif ilişkili bir yanlılıktır: Sabit Veri A'da bu göstergenin $Y$ ile kovaryansı 12/5'tir, oysa 76/91 örneğindeki (P2 ve P3) göstergenin $Y$ ile kovaryansı 0'dır. Popülasyon karşı örneği: $\sigma_\eta^2=1$, $\sigma_E^2=0{,}5$ iken $U=0{,}2\eta$ eklenirse $\rho_{XX'}$ 0,6667'den 0,7423'e, $\rho_{X\eta}$ 0,8165'ten 0,8615'e çıkar; $U=\mathbf 1\{\eta>0\}$ eklenirse $\rho_{X\eta}$ 0,8764'e çıkar (tavanla arası açılsa da korelasyonun kendisi yükselir). Katman C bu kartı B bölümüyle karşılaştıracağı için uyuşmazlık orada da görünecektir.
   - SPEC konumu: satır 173 (kart, "tam metin"); satır 271 (B.1); satır 326 (G.5); satır 399 (10/11 ve 76/91).
   - Etki: yüksek (öğrenciye gösterilen kavramsal iddia).
   - Önerilen karar: Kart "tam metin" olduğu için kullanıcı onayı olmadan değiştirilmez; yanıt gelmezse SPEC'teki metin aynen kullanılır ve çelişki `CLAIMS.md` ile `PROGRESS.md`'ye yazılır. Kullanıcıya önerilen en küçük düzeltme: "güvenirliği değiştirir: çoğunlukla yükseltir (senaryo 3 ve 8; Sabit Veri A'da .80'den 76/91 ≈ .84'e; yanlılık yüksek puanlılara yönelikse 10/11 ≈ .91'e), yapıyla güçlü ters ilişkiliyse düşürür (...). Yanlılık yapıyla ilişkisizse puanların yapıyla ilişkisi zayıflar."
   - Aşama 1'den önce kullanıcı yanıtı: Hayır (Aşama 3'ten önce gerekir).

4. `PROGRESS.md`'nin "model kimliği" alanı oturum kuralıyla çelişiyor (lider tarafından bildirilen gerilim a).
   - Soru/sorun: SPEC `PROGRESS.md`'nin model kimliğini kaydetmesini ister. Oturum kuralı, depoya gönderilen hiçbir dosyaya model tanımlayıcısı yazılmasına izin vermez. `PROGRESS.md` şu anda bu nedeni açıklıyor ve kimliği yazmıyor.
   - SPEC konumu: satır 9.
   - Etki: orta (araştırmanın doğruluk denetimi için kayıt eksikliği).
   - Önerilen karar: Kimlik hiçbir depo dosyasına yazılmaz. `PROGRESS.md` denetim kaynağı olarak oturum bağlantısını ve commit iletilerinin sonundaki `Co-Authored-By` ve `Claude-Session` satırlarını (dosya değil, git üst verisi) gösterir. Kullanıcı bunu yeterli bulmazsa kimliği kendisi depo dışında kaydeder.
   - Aşama 1'den önce kullanıcı yanıtı: Hayır (kullanıcının bilgisine ve onayına sunulur).

## Varsayılan kararla ilerlenecekler

5. `tests.json`'u Aşama 0'da kimin yazacağı (lider tarafından bildirilen gerilim b).
   - Soru/sorun: SPEC `tests.json`'un yalnızca `npm test` çalıştırıcısı tarafından yazılacağını söyler, ama Aşama 0 bu dosyanın çalıştırıcı henüz yokken "bekliyor" durumuyla oluşturulmasını ister.
   - SPEC konumu: satır 440; satır 495.
   - Etki: düşük.
   - Önerilen karar: Aşama 0 dosyası `<asamalar>` gereği tek seferlik başlangıç kaydıdır ve bu `PROGRESS.md`'de yazılır. Aşama 1'den itibaren dosyayı yalnızca çalıştırıcı yazar. Çalıştırıcı test kodundaki kimlik listesini `tests.json` ile karşılaştırır; Aşama 0 listesindeki bir kimlik test kodunda yoksa çalıştırma hata verir, böylece test sessizce silinemez.
   - Aşama 1'den önce kullanıcı yanıtı: Hayır.

6. CDN'lere bu kapsayıcıdan erişilemiyor; bağımsız sürümde üçüncü taraf istekleri (lider tarafından bildirilen gerilim c).
   - Soru/sorun: (a) `cdn.jsdelivr.net` ve `cdnjs.cloudflare.com` vekil sunucu tarafından reddediliyor. SPEC bunu öngörür ve testlerde KaTeX'i npm'den kurup `page.route` ile yönlendirir; bu yol çalışır (katex 0.18.9 npm'de var, `dist/katex.min.js` mevcut). Ancak yayımlanan Artifact'ta KaTeX izleyicinin tarayıcısında jsDelivr'den yüklenecek ve bu kapsayıcıdan doğrulanamaz. (b) `strict: "warn"` ayarıyla matematik kipinde Türkçe harf (ör. `\text` dışında `ÖSH` veya `KO_{içi}`) `unicodeTextInMathMode` uyarısı üretir; bu, B1'i (sıfır konsol uyarısı) düşürür. Yerel denemede bu iki örnek uyarı verdi, `\text{...}` içindeki biçimleri vermedi. (c) SPEC bağımsız sürüm için "Her şey satır içidir" der, ama KaTeX betiği yalnızca CDN adresinden tanımlanmıştır ve yazı tipleri Google Fonts'tan gelir. Gerçek veri toplamada bu istekler katılımcının IP adresini üçüncü taraflara iletir; bu, KVKK açısından `RESEARCH.md`'de açıklanması gereken bir veri akışıdır.
   - SPEC konumu: satır 343-345, 352-353, 365-371.
   - Etki: orta.
   - Önerilen karar: Artifact derlemeleri SPEC'teki gibi kalır; ilk yayında (Aşama 2) KaTeX'in izleyicide yüklendiği kullanıcıdan doğrulaması istenir. Türkçe sözcükler TeX içinde yalnızca `\text{...}` içinde yazılır ve bu bir derleme denetimiyle sınanır. `dist/standalone/` hiçbir üçüncü taraf isteği yapmaz: KaTeX betiği npm kopyasından satır içine alınır, yazı tipleri KaTeX'in satır içi woff2 dosyaları ve sistem yazı tipi yığınıdır (Google Fonts yok).
   - Aşama 1'den önce kullanıcı yanıtı: Hayır.

7. Varyans bütçesi çubuğunda gerçek dünya kestirimi M5 ile tutarsız.
   - Soru/sorun: Ortak öğe 2 kestirilen hata varyansını $s^2_{X_1}-s_{X_1X_2}$ olarak tanımlar. M5 verisinde bu 14 − 13,6 = 0,4'tür; oysa M5(a) ve M5(b2) aynı ekranda 0,8'i (0,4 ile 1,2'nin ortalaması, $s_D^2/2$) "hata varyansı" olarak verir. Ayrıca örneklemde $s_{X_1X_2}>s^2_{X_1}$ olabilir ve bölüt genişliği negatif çıkar; SPEC bunu ele almaz. M4'te $\sigma_{\eta U}\neq0$ iken (uzman senaryo 7) "yapı varyansı" ve "kararlı yanlılık" bölütleri $\sigma_T^2$'yi vermez; $2\sigma_{\eta U}$ terimi negatif olabilir ve B12'nin geometri testi bunu çizmeyi gerektirir.
   - SPEC konumu: satır 112, 114; satır 181-183; satır 475 (B12).
   - Etki: orta.
   - Önerilen karar: İki ölçme varken çubuk iki formun ortalama varyansını ayrıştırır: toplam $(s_1^2+s_2^2)/2$, kestirilen gerçek $s_{12}$, kestirilen hata $s_D^2/2$ (M5'te 14,4 = 13,6 + 0,8). Formların varyansları eşitse bu SPEC'teki tanımla aynıdır. Negatif kestirim 0 genişlikte çizilir ve M9'daki gibi bayrakla belirtilir. M4'te $2\sigma_{\eta U}$ ayrı, işaretli ve desenli bir bölüt olur; negatifse gerçek puan kıskacından düşülen bir bölüt olarak çizilir.
   - Aşama 1'den önce kullanıcı yanıtı: Hayır.

8. Gizli kümenin sınırı parametre düzeyindeki nicelikler için belirsiz.
   - Soru/sorun: Gizli küme bireysel gizil değerler ve onlardan hesaplanan örneklem istatistikleri olarak tanımlanır; popülasyon kaydırıcıları gizli değildir. Ama tablo M8'de $\Sigma_T$ ve $\Psi$ ayrışımını, M9'da "varyans bileşenlerinin parametre değerleri"ni yalnızca perde arkasında gösterir. Bunlar kaydırıcı değerlerinden türetilmiş parametre nicelikleridir. A17 ve B5 kesin bir anahtar listesi ister.
   - SPEC konumu: satır 97-108; satır 461 (A17); satır 468 (B5).
   - Etki: orta (Aşama 1'deki `project` işlevini etkiler).
   - Önerilen karar: `project(state, 'real')` (1) SPEC'in tanımladığı gizli kümeyi ve (2) tablonun yalnızca perde arkasında gösterdiği parametre türevlerini (M5-M9'da gerçek katsayı, $\Sigma_T$, $\Psi$, bileşen parametreleri) çıkarır. Öğrencinin doğrudan oynattığı kaydırıcı değerleri "model ayarı" etiketiyle görünür kalır. Anahtar listesi `core.js` içinde tek bir sabitte tutulur ve A17 bu sabiti kullanır.
   - Aşama 1'den önce kullanıcı yanıtı: Hayır.

9. `CLAIMS.md`: Aşama 0'da oluşturulup oluşturulmayacağı ve modül cümlelerinin kimliği.
   - Soru/sorun: SPEC `CLAIMS.md`'nin her aşamada güncellenmesini ister, ama Aşama 0'ın dosya listesinde yoktur. Ayrıca her kavramsal cümle A-G veya Y kimliğine bağlanmalıdır; oysa SPEC'in kendi modül metinlerinde hiçbir kimliği olmayan kavramsal cümleler vardır (ör. M7'de Lord 1952'ye dayanan en uygun güçlük notu, KR-21 ≤ KR-20, en büyük $r_\varphi$; M5'te Kelley ve üç standart hata; M9'da Φ(λ); M6'daki yöntem kartı tuzakları). Harfiyen okununca bu cümleler yazılamaz.
   - SPEC konumu: satır 3, 260, 493, 495.
   - Etki: orta (`CLAIMS.md` zorunlu katmandadır).
   - Önerilen karar: Aşama 0'da iskelet bir `CLAIMS.md` oluşturulur (A.1-G.13 ve Y1-Y16 satırları, ekrandaki yer "henüz yok"). SPEC'in modül bölümlerinden aynen alınan cümleler için modül çapası geçerli kimlik sayılır (ör. "M7-Formüller, satır 222"). Türetilmiş metin yine bir A-G, Y kimliğine veya bir modül çapasına bağlanır.
   - Aşama 1'den önce kullanıcı yanıtı: Hayır.

10. M5'teki "tau eşdeğerlikte" ifadesi A.5 ile uyuşmuyor.
    - Soru/sorun: M5 formül metni "Tau eşdeğerlikte $T_1-T_2$ herkes için aynı sabittir; $\bar D$ onu kestirir" der. A.5'e göre tau eşdeğerlikte $T_1=T_2=\tau$'dır, yani bu sabit 0'dır; sıfırdan farklı sabit (M5(d)'deki "sabit kayma") özünde tau eşdeğerliktir. M5(d)'deki $r=\sqrt{\rho_1\rho_2}$ sonucu da özünde tau eşdeğer formlarda geçerlidir.
    - SPEC konumu: satır 189, 185; satır 267 (A.5).
    - Etki: düşük-orta (terim tutarlılığı).
    - Önerilen karar: SPEC cümlesi korunur ve yanına A.5'e bağlı bir ek yazılır: "(tau eşdeğerlikte bu sabit 0'dır; sıfırdan farklı bir sabit özünde tau eşdeğerlik demektir, A.5)".
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

11. M8'de "negatif hata kovaryansı α'yı düşürür" iddiasının parantezi başka bir karşılaştırma yapıyor.
    - Soru/sorun: "(.6975 < .7452)" aynı modelin α'sını ω'sıyla karşılaştırır. α'nın düştüğünü gösteren karşılaştırma, kovaryanssız aynı modelle yapılandır: λ = .625 ×4 için α 0,7194'ten 0,6975'e düşer; aynı değişiklikte ω 0,7194'ten 0,7452'ye çıkar.
    - SPEC konumu: satır 236; satır 419 ve 426.
    - Etki: düşük.
    - Önerilen karar: Ekranda "(λ = .625 ×4: α .7194'ten .6975'e düşer; ω .7452'ye çıkar)" yazılır; iki değer de `<sabit_veri>`'dedir.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

12. G.8 satırının ölçeği M7'deki uzunluk kaydırıcısıyla çelişebilir.
    - Soru/sorun: G.8 madde ortalaması ölçeğindedir (gözlenen varyans ↓, ÖSH ↓). M7 ve M8 toplam puan ölçeğinde çalışır (varyans bütçesinde $k^2\bar s_{ij}$); paralel maddelerde toplam puanın gözlenen varyansı ve ÖSH'si madde eklendikçe artar. G.8 hücresi M7'deki bir TGA'dan doldurulursa öğrencinin gözlemi haritayla çelişir ve B14 başarısız olur.
    - SPEC konumu: satır 329 (G.8); satır 199, 201 (M6); satır 218 (M7); satır 114.
    - Etki: düşük-orta.
    - Önerilen karar: G.8 hücresi yalnızca M6'daki madde ortalaması ölçeğindeki $k$ TGA'sıyla dolar. M7'nin uzunluk TGA'ları yalnızca güvenirliği sorar. Harita hücresinde "madde ortalaması ölçeğinde" notu bulunur.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

13. Negatif bileşeni 0'a çekme kuralı yazılım çıktılarıyla ve bazı özdeşliklerle uyuşmaz; Φ(λ)'nın örneklem kestirimi tanımsız.
    - Soru/sorun: (a) M5 verisinde $KO_p=28$, $KO_i=0$, $KO_{art}=0{,}8$'dir. Madde bileşeni 0'a çekilince ICC(A,1) = 17/18 ≈ 0,9444 olur; SPSS ve jamovi'nin kullandığı McGraw ve Wong formülü (çekme yok) 102/107 ≈ 0,9533 verir. Payda kuralının gerekçesi yazılımla karşılaştırmadır (satır 73), bu yüzden öğrenci farkı görecektir. (b) "Φ = ICC(A,k)" özdeşliği yalnızca $KO_i\ge KO_{art}$ iken geçerlidir; aksi hâlde çekme sonrası Φ = $\mathbb E\rho^2$ olur, formül ise daha büyük bir değer verir. (c) Φ(λ) için yalnızca popülasyon formülü verilmiştir. Brennan (2001a) örneklemde $(\mu-\lambda)^2$ yerine $(\bar X-\lambda)^2-\hat\sigma^2(\bar X)$ kullanır; bu kestiricide λ = $\bar X$ iken Φ̂(λ) < Φ̂ olur, yani "Φ, Φ(λ)'nın en küçük değeridir" yalnızca popülasyon düzeyinde doğrudur.
    - SPEC konumu: satır 160, 246, 247, 249, 252, 407; satır 73.
    - Etki: düşük-orta.
    - Önerilen karar: SPEC'teki çekme kuralı ve sabit değerler korunur. Çekme uygulandığında ekranda "Negatif bileşen 0'a çekildi; SPSS ve jamovi bu durumda farklı bir değer verir" notu çıkar. A10 türü testlerde Φ = ICC(A,k) yalnızca $KO_i\ge KO_{art}$ koşulunda sınanır. Φ(λ) eğrisi bileşenler ve ortalama parametre kabul edilerek (popülasyon düzeyinde) çizilir ve böyle etiketlenir; Brennan düzeltmesi uzman notunda yalnızca adıyla anılır.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

14. KR-20 kartının $n-1$ anahtarındaki gösterimi ve anahtarın kapsamı.
    - Soru/sorun: Varsayılan anahtar $n-1$'dedir; bu durumda kart madde varyansını $p_iq_i\cdot n/(n-1)$ ve toplam varyansı $s_Y^2$ olarak yazar. Ama SPEC'teki simgesel formül $\sum p_iq_i/\hat\sigma_Y^2$'dir; varsayılan görünümde simge satırı ile sayı satırı farklı nicelikleri gösterir ve $n-1$ biçimi `formulas.expected.json`'da yoktur (B11). Anahtarın yalnızca Hesap Tezgâhında mı, yoksa M1 ve M5'te de mi ("anahtar arkasında") bulunduğu açık değildir.
    - SPEC konumu: satır 73, 132, 181, 222; satır 474 (B11).
    - Etki: düşük.
    - Önerilen karar: Tek bir genel anahtar durumda tutulur ve M1, M5 ve M7'de görünür. KR-20 kartının simgesel satırı her zaman SPEC'teki biçimdir; $n-1$ biçimi yalnızca "Sayılarla" satırında ve "sonuç aynıdır" cümlesiyle görünür; böylece yeni formül kimliği gerekmez.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

15. M10 "bitti" ölçütlerini karşılayamaz.
    - Soru/sorun: Bir modülün bitmesi için B3 yön testi, `data-q` taşıyan formül kartı (B4), ön ayar kimlikli TGA ve A15'te doğrulanan kontrol sorusu gerekir; B4 "`data-q` öğesi olmayan modül bu testi geçemez" der. M10 bir yanılgı denetimidir ve bunların hiçbirini içermez.
    - SPEC konumu: satır 41; satır 254-256; satır 466-467.
    - Etki: düşük (M10 "Olmalı" katmanında).
    - Önerilen karar: M10 için "bitti" ölçütü şudur: Y1-Y16'nın her biri için bir madde, her geri bildirimin bir `CLAIMS.md` kimliğine ve ilgili modüle bağlanması, yanıtların yalnızca tarayıcıda tutulması. M10 için B3/B4/A15 kimliği açılmaz ve bu `PROGRESS.md`'de yazılır.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

16. "Yeni adres üretme" kuralı ile ayrı koşul Artifact'ları.
    - Soru/sorun: Devam protokolü sonraki her yayının aynı adrese yapılmasını ister. Araştırma bölümü ise durağan sürümün ve her koşulun ayrı ve dondurulmuş bir Artifact olarak yayımlanmasını, veri toplama sırasında hiçbir yayının güncellenmemesini ister.
    - SPEC konumu: satır 8; satır 362-364; satır 500.
    - Etki: düşük.
    - Önerilen karar: "Yeni adres üretme" ana etkileşimli geliştirme Artifact'ı için geçerlidir. Durağan sürüm ve koşul kopyaları yalnızca kullanıcının açık onayıyla ayrı adreslerde yayımlanır; adresleri `PROGRESS.md` ve `RESEARCH.md`'ye yazılır ve veri toplama boyunca yeniden yayımlanmaz.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

17. Belirlenimcilik için alt akış düzeni belirtilmemiş.
    - Soru/sorun: SPEC mulberry32, Box-Muller ve "tohum ile bileşen adından türetilen alt akış" der, ama türetme özetini, kişi × madde veya kişi × tekrar gibi çok değerli bileşenlerde çekim sırasını ve Box-Muller'ın iki çıktısının kullanılıp kullanılmayacağını belirtmez. A13'ün "$n=10$ sınıfı $n=30$ sınıfının ilk 10 kişisidir" koşulu çok maddeli veride ancak kişi başına ayrı alt akışla ya da sabit genişlikli kişi öncelikli düzenle sağlanır.
    - SPEC konumu: satır 118, 346; satır 457 (A13); satır 480 (B17).
    - Etki: düşük-orta (Aşama 1'i etkiler).
    - Önerilen karar: Her (bileşen, kişi) çifti için alt akış tohumu `seed|bileşen|kişi` dizesinin belgelenmiş 32 bitlik bir özetinden (FNV-1a) türetilir ve mulberry32'ye verilir. Kişinin $j$. maddesi veya tekrarı o akışın $j$. çekimidir; böylece $n$ ya da $k$ değişince önceki değerler korunur. Box-Muller'ın yalnızca ilk çıktısı kullanılır. Karar `PROGRESS.md`'ye yazılır.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

18. Katılımcı kodunda Damm kontrol basamağı.
    - Soru/sorun: Standart Damm algoritması ondalık basamaklar üzerinde tanımlıdır; "6 karakterli rastgele kod" harf içerirse başka bir yarı grup tablosu gerekir.
    - SPEC konumu: satır 368.
    - Etki: düşük (Aşama 5b).
    - Önerilen karar: Kod 6 ondalık basamak ve 1 Damm basamağıdır (kâğıtta 7 basamak).
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.

19. Küçük tutarlılık notları.
    - Soru/sorun: (a) "Üç yol, tek hata varyansı" kartı dört yol sayar ve A1 de "dört yoldan" der. (b) M4 uzman katmanındaki ICC(A,1)'in formülü SPEC'te yazılı değildir (M9 yalnızca ICC(A,k) ve ICC(C,1)'i verir); bu yüzden B11 anlık görüntüsünde karşılığı yoktur. (c) SPEC spec sorularının `PROGRESS.md` içinde "Spec soruları" başlığı altında tutulmasını ister; bu liste ayrı bir dosyadadır.
    - SPEC konumu: satır 250, 445; satır 160, 249; satır 3, 9, 442.
    - Etki: düşük.
    - Önerilen karar: (a) Kart başlığı SPEC'teki gibi kalır, metin dört yolu sayar. (b) ICC(A,1) formül kartı olmadan, M9'daki ICC kartına bağlantı veren bir gösterge sayısı olarak gösterilir; değer bileşen biçiminden ($\hat\sigma_p^2/(\hat\sigma_p^2+\hat\sigma_i^2+\hat\sigma^2_{pi,e})$, $\hat\sigma_i^2$ 0'a çekilerek) hesaplanır. (c) `PROGRESS.md` içinde "Spec soruları" başlığı korunur; her maddenin numarası, durumu (açık, yanıtlandı, varsayılan uygulandı) ve bu dosyaya bağlantı orada tutulur.
    - Aşama 1'den önce kullanıcı yanıtı: Hayır.
