# GÜVENİRLİK LABORATUVARI: ŞARTNAME

Bu dosya (`guvenirlik-lab/SPEC.md`) öğrencilere gösterilen her formül, sembol, Türkçe terim ve kavramsal iddia için tek doğruluk kaynağıdır. SPEC.md'yi hiçbir zaman yeniden yazma veya düzenleme. Kendi bilginle spec çelişirse spec'i uygula, çelişkiyi `PROGRESS.md` içinde "Spec soruları" başlığı altına yaz ve çalışmaya devam et. Türetilmiş metin yazabilirsin (geri bildirimler, "Ne değişti, neden?" satırları, TGA gerekçe seçenekleri, yöntem kartı alanları, M10 çeldiricileri). Ancak her kavramsal cümle `CLAIMS.md` içinde bu dosyadaki bir kimliğe (ör. B.1, D.4, G.5, Y8) bağlanır. Bir kimliğe bağlanamayan kavramsal cümleyi yazma. `CLAIMS.md` her aşamada güncellenir; tek seferde sona bırakılmaz.

<devam_protokolu>
- Her oturumun ve her aşamanın başında şunları oku: SPEC.md'nin o aşamayla ilgili bölümleri, `PROGRESS.md`, `tests.json` ve `git log --oneline -20` çıktısı.
- Her aşama bir commit ve bir etiketle kapanır (`asama-0`, `asama-1`, ...). Commit ve etiketleri oturumun sana verdiği çalışma dalına push et; böyle bir dal yoksa `guvenirlik-lab` dalını kullan. Bulut kapsayıcısı yeniden başlasa da iş kaybolmamalıdır.
- İlk Artifact yayınından sonra adresi `PROGRESS.md` içine yaz. Sonraki her yayında Artifact aracını önce `action: "read"` ile, sonra aynı `url` ile çağır. Yeni adres üretme.
- `PROGRESS.md` şunları kaydeder: model kimliği; tarih ve saat; her aşamanın özeti; başarısız yaklaşımlar ve nedenleri; spec soruları; belirsiz noktalarda verdiğin kararlar; yaptığın düzeltmeler. Bu kayıt, LLM ile yapılmış bir eğitim simülasyonunun doğruluk denetiminde veri olarak kullanılacaktır. Düzeltmeleri gizleme.
</devam_protokolu>

<rol_ve_hedef_kitle>
Sen psikometri bilgisi güçlü bir eğitim teknolojisi geliştiricisisin. Türkiye'de eğitim fakültelerinde "Eğitimde Ölçme ve Değerlendirme" dersi alan, istatistik altyapısı olmayan lisans öğrencileri için etkileşimli bir öğrenme ortamı yapacaksın: "Güvenirlik Laboratuvarı". Öğrenciler aritmetik ortalamayı bilir, standart sapmayı en fazla betimsel olarak tanır; beklenen değer, matris ve varyans analizi bilgileri yoktur. Ders notlarından "sabit, sistematik ve tesadüfi hata" ayrımını ve "sabit ve sistematik hatalar geçerliği, tesadüfi hatalar güvenirliği etkiler" kuralını ezberlemiş olarak gelirler. Arayüz dili Türkçedir. İçerik Klasik Test Kuramı (KTK) merkezlidir ve Genellenebilirlik Kuramına (GK) kısa bir ön bakış içerir. Uygulamanın sahibi ölçme ve değerlendirme alanında bir akademisyendir. Uygulama daha sonra etkileşimli ve durağan sürümlerin karşılaştırıldığı yayımlanabilir bir araştırmada kullanılabilir. Bu yüzden içerik doğruluğu ve tekrar üretilebilirlik görsel cilalamadan önce gelir.
</rol_ve_hedef_kitle>

<amac>
Gözlenen üç sorun (modüllerde S1, S2, S3 diye anılır):
- S1. Öğrenciler güvenirlik kestirim yöntemlerinin adlarını bilir (test-tekrar test, eşdeğer formlar, yarıya bölme, KR-20, Cronbach α) ama nasıl hesaplandıklarını bilmez.
- S2. Sabit ve sistematik hatanın güvenirliği neden ve hangi koşulda değiştirmediğini, tesadüfi hatanın ise neden düşürdüğünü bilmez.
- S3. Hiçbir bireyde gözlenemeyen tesadüfi hatanın varyansını nasıl kestirebildiğimizi bilmez.

Uygulama iki düzenleyici fikre dayanır. Her modül bunlardan en az birine açıkça geri bağlanır:
- Tekrar ilkesi: KTK'da "hata", ölçme işleminin kabul edilebilir tekrarları arasında yinelenmeyen her şeydir; "gerçek puan" yinelenen her şeydir. Her güvenirlik katsayısı farklı bir tekrar tasarımına (başka maddeler, başka formlar, başka günler, başka puanlayıcılar) karşılık gelir ve bu yüzden farklı kaynakları hata sayar.
- Görünmeyen köşegeni doldurma: Aynı kişilere ait farklı ölçmelerin kovaryanslarını gözleriz. Tek bir ölçmenin varyansının ne kadarının gerçek varyans olduğunu gözleyemeyiz. Her iç tutarlılık katsayısı bu görünmeyen kısmı doldurmanın bir kuralıdır: α kovaryans matrisinin köşegenine ortalama köşegen dışı kovaryansı koyar, ω ise $\lambda_i^2$ değerini koyar. "Görmediğimiz hatayı nasıl kestiriyoruz?" sorusunun somut yanıtı budur. Bu fikir M5'te iki formla başlar, M8'de $k$ maddeye genellenir, M9'da ANOVA ile aynı sayıya varır.

Tasarımın merkezinde iki görünüm vardır:
- "Gerçek dünya": Yalnızca gözlenen puanlar $X$ görünür, tıpkı uygulamada olduğu gibi.
- "Perde arkası (simülasyon)": Simülasyon $T$, $E$ ve gerektiğinde yapı puanı $\eta$ değerlerini bildiği için bunları gösterir. $X$'ten hesaplanan her kestirim, perde açıkken gerçek parametrenin yanında durur. $\eta$ her yerde "yapı puanı (yalnızca simülasyonda)" etiketi taşır.
</amac>

<kapsam>
Kapsamda: aşağıdaki on modül; ortak kabuk (görünüm anahtarı, varyans bütçesi, formül kartı, sınıf kodu, etki haritası); Türkçe sözlük ve kaynaklar paneli; aynı içerik dosyasından üretilen durağan sürüm; bağımsız barındırma için tam belge çıktısı; varsayılan olarak kapalı, isteğe bağlı anonim olay kaydı; doğrulama düzeneği.

Kapsam dışı: Madde Tepki Kuramı; $p\times i$ ile $p\times r$ (çaprazlanmış ve iç içe) dışındaki GK desenleri; veriden faktör analiziyle ω kestirimi (ω yalnızca popülasyon modunda, kaydırıcılardan hesaplanır); glb, ordinal α, Feldt güven aralığı; fark puanlarının güvenirliği; İngilizce arayüz; öğrenci hesabı, not verme, hız rozetleri; 3B ve WebGL; araştırmanın ölçme aracı olacak kavram envanteri maddeleri (ayrıca geliştirilecek); olay kaydı sunucusunun kendisi; kullanıcı açıkça istemedikçe olay kaydı açık bir yayın.

Öncelik katmanları (zaman veya bağlam daraldığında her modülü eşit inceltme; önce üst katmanı bitir):
- Zorunlu: kabuk; M1-M9 acemi yolları; Katman A ve Katman B testleri; `CLAIMS.md`.
- Olmalı: M10; etki haritası; M4, M5 ve M7 uzman katmanları; durağan sürüm; dışa aktarma; olay kaydı (kapalı).
- Olabilir: diğer uzman katmanları (ICC bağlantıları, iç içe desen, koşullu ÖSH ve binom kapsama görseli, iki blok modu, $k>12$ bölme örneklemesi).

Bir modül ancak şu koşullar sağlandığında "bitti" sayılır: en az bir B3 yön testi geçer; formül kartındaki her canlı sayı `data-q` taşır ve B4'ü geçer; her TGA kartının bir ön ayar kimliği vardır; kontrol sorusunun yanıtı A15'te doğrulanır; `CLAIMS.md` satırları yazılmıştır.
</kapsam>

<gosterim_ve_sozluk>
Temel kural: Bir sembol arayüzde tek anlam taşır.

- Yunan harfleri popülasyon (evren) parametresidir ($\sigma^2,\rho,\lambda,\psi$). Latin harfleri veya şapkalı semboller örneklem kestirimidir ($s^2, r, \hat\alpha$). Örneklem varyansı için iki payda vardır: $s^2=\frac{1}{n-1}\sum(\cdot)^2$ ve $\hat\sigma^2=\frac{1}{n}\sum(\cdot)^2$. Her katsayı için "popülasyon modu" (kaydırıcılar parametreyi belirler, değer kesindir) ile "örneklem modu" (veri simüle edilir veya girilir, değer dalgalanır) açıkça etiketlenir.
- Kişi $p=1,\dots,n$; madde (parça, puanlayıcı) $i=1,\dots,k$; toplam puan $Y_p=\sum_i X_{pi}$ (tek puanlı modüllerde $X$). $\mathbf 1$ birler vektörüdür; $\Sigma$ (örneklemde $S$) $k\times k$ madde kovaryans matrisidir.
- Kovaryans $\sigma_{X_1X_2}$ (örneklemde $s_{X_1X_2}$), korelasyon $\rho_{X\eta}$ (örneklemde $r$), fark varyansı $\sigma^2_D$ biçiminde yazılır. Virgül ayraçlı $\operatorname{Cov}(\cdot,\cdot)$ yazımı kullanılmaz, çünkü arayüzde virgül ondalık ayırıcıdır.

| Sembol | Anlam | Not |
|---|---|---|
| $X$, $T$, $E$ | gözlenen puan, KTK gerçek puanı, hata puanı | |
| $\eta$ | yapı puanı | Yalnızca simülasyonda vardır. Her zaman "yapı puanı η (yalnızca simülasyonda)" etiketiyle yazılır; $T$ ile sözcük etiketi olmadan yan yana konmaz. |
| $\tau$ | ölçme modellerinde ortak gerçek puan | Yalnızca "tau eşdeğer" adında ve ölçme modelleri tablosunda (A.5) kullanılır. |
| $c$ | sabit hata | |
| $X^*=a+wX$ ($w\neq0$) | ortak doğrusal dönüşüm; kurala bağlı (orantılı) hata | |
| $B_p$, $\sigma_B$ | kişiye özgü kararlı yanlılık ve standart sapması | |
| $g_p\in\{0,1\}$, $\pi$, $\gamma$ | alt grup göstergesi, alt grup oranı, alt gruba özgü kayma | |
| $U_p=c+B_p+\gamma g_p$ | sistematik bileşen | |
| $\beta_i$ | özünde tau eşdeğer modelde madde sabiti | |
| $\lambda_i$, $\psi_i$, $\psi_{ij}$, $\Psi$ | faktör yükü, hata (özgül) varyansı, hata kovaryansı, hata matrisi | |
| $L_1$, $L_2$ | Guttman katsayıları | Literatürde ve SPSS çıktısında λ₁, λ₂ ("Lambda 1", "Lambda 2") diye yazılır; burada faktör yüküyle karışmasın diye $L$ kullanılır. Sözlük bunu açıklar. |
| $\mathbb E$ | beklenen değer ("sonsuz tekrardaki ortalama") | $\mathbb E(KO_p)$ dahil her yerde. |
| $\mathbb E\rho^2$, $\Phi$ | G katsayısı (bağıl kararlar), mutlak kararlar için Φ katsayısı | Literatürde $E\rho^2$ diye de yazılır; sesli okuma "G katsayısı". |
| $\sigma^2_\delta$, $\sigma^2_\Delta$ | bağıl ve mutlak hata varyansı | δ başka anlamda kullanılmaz. |
| $\mathbf 1^{\mathsf T}\Sigma\mathbf 1$ | toplam puan varyansı | Devrik için ᵀ kullanılır. Üs işareti (′) yalnızca paralel form $X'$ ve K çalışması $n_i'$ için. |
| $\rho_{\text{yeni}}$, $\sigma^2_{X,\text{yeni}}$ | yeni gruptaki güvenirlik ve varyans | |
| $r_\varphi$ | fi katsayısı | Yalnızca uzman katmanında. |
| KT, KO, sd | kareler toplamı, kareler ortalaması, serbestlik derecesi | Yalnızca ANOVA tablolarında ve açılımıyla birlikte. |

- "Klasik Test Kuramı" her modülde ilk geçtiği yerde açık yazılır; sonra KTK kısaltması kullanılabilir.
- Payda kuralı: Varsayılan $n-1$'dir, çünkü ANOVA kareler ortalamalarıyla tutarlıdır ve öğrenciler sonuçları jamovi, SPSS veya R ile karşılaştırabilir. M1 bunun nedenini serbestlik derecesi etkileşimiyle gösterir. Hesap Tezgâhında görünür bir "$n$ / $n-1$" anahtarı vardır ve her sayı hangi paydayla hesaplandığını gösterir. Anahtar yalnızca betimsel varyans ve kovaryansları, ÖSH'yi ve KR kartlarını etkiler. ANOVA ve GK nicelikleri (KO, varyans bileşenleri, $\mathbb E\rho^2$, Φ, ICC) serbestlik derecesiyle tanımlıdır ve ANOVA paneli "sd ile tanımlıdır; anahtardan etkilenmez" yazar. KR-20'de $p_iq_i$ örtük olarak $n$ paydalıdır. Bu yüzden KR-20 kartı toplam varyansı $\hat\sigma^2_Y$ ile hesaplar. Anahtar $n-1$'deyken kart madde varyansını $p_iq_i\cdot n/(n-1)$ olarak yazar ve yine aynı sonucu verir. Karışık payda yalnızca tanısal geri bildirimde yanlış örnek olarak görünür. Oran katsayılarında ($r$, α, Hoyt) paydalar tutarlı olduğu sürece seçim sonucu değiştirmez; ÖSH ve $\hat\sigma^2_E$ oran değildir ve değişir.
- Ondalık ayırıcı arayüzde virgüldür (tr-TR). TeX içinde `0{,}80` yaz. Varsayılan iki ondalık basamaktır, "Daha fazla basamak" anahtarıyla dört. "Madde silinirse α" sütunu her zaman dört basamak ve "yükselir/düşer" sözcüğüyle gösterilir.
- Terimlerde tek biçim: güvenirlik, geçerlik; gözlenen puan, gerçek puan, hata puanı; yapı puanı; sabit hata; kurala bağlı (orantılı) sistematik hata; kişiye veya gruba özgü kararlı yanlılık; tesadüfi (rastgele) hata; geçici hata; ölçmenin standart hatası (ÖSH); test-tekrar test (kararlılık katsayısı); eşdeğer formlar yöntemi (eşdeğerlik katsayısı); yarıya bölme; iç tutarlılık; paralel, tau eşdeğer, özünde tau eşdeğer, konjenerik ölçmeler; varyans-kovaryans matrisi; faktör yükü; hata (özgül) varyansı; varyans analizi; varyans bileşeni; G çalışması ve K (karar) çalışması; bağıl ve mutlak hata; G katsayısı ve mutlak kararlar için Φ katsayısı (İng. dependability coefficient); sınıf içi korelasyon katsayısı (ICC); puanlayıcı; tavan etkisi ve taban etkisi; Tahmin-Gözlem-Açıklama (TGA).
- Sözlük notları (sözlük sayfası her terimin İngilizcesini de verir):
  - "sapma" yalnızca ortalamadan uzaklıktır ($X-\bar X$). Hata kaynağı için "yanlılık" (bias), ortalamanın ötelenmesi için "kayma" (shift) kullanılır. "Ortalama sapma" ifadesi kullanılmaz; istatistikte başka bir niceliğin (ortalama mutlak sapma) adıdır.
  - popülasyon (evren): kişi evreni. GK'daki "evren puanı" farklıdır; kabul edilebilir koşullar evreni üzerindeki ortalama puandır.
  - eşdeğer formlar: yöntemin adı (aynı içeriği ölçmek için hazırlanmış iki form). Paralel ölçmeler: KTK'nın kesin koşulu (aynı gerçek puan, eşit hata varyansı). Arayüz "eşdeğer formlar yöntemi (formların paralel olduğu varsayılır)" yazar. Bazı Türkçe kaynaklar "eşdeğer ölçmeler"i tau eşdeğer anlamında kullanır; sözlük bunu belirtir.
  - "türdeş" yalnızca gruplar için kullanılır ("türdeş sınıf"); maddeler için kullanılmaz.
  - kestirim: bir parametre için veriden hesaplanan değer (estimation). yordama: regresyonla bir değişkenden ötekini öngörme (prediction). tahmin: öğrencinin TGA kartındaki öngörüsü.
  - $L_2$ ve $\mathbb E\rho^2$ yazımları yukarıdaki tabloda açıklanır. "güvenilebilirlik" terimi kullanılmaz.
- Hata türleri tablosu (M4'ün açılış kartıdır ve ders notlarıyla köprü kurar):

| Ders notlarındaki ad ve tipik örnek | Laboratuvardaki karşılığı | Güvenirliğe etkisi | Ortalamaya ve mutlak kararlara etkisi | Yapıyla ilişkiye (bir geçerlik kanıtına) etkisi |
|---|---|---|---|---|
| Sabit hata: her birime aynı miktar (öğretmenin her kâğıda 5 puan fazla vermesi; puanlama yazılımının herkesten 4 puan düşmesi) | $c$ | değişmez | ortalama $c$ kadar kayar; kesme puanındaki kararlar değişir | $\rho_{X\eta}$ değişmez; mutlak yorum ("70 aldı") ise yanlıştır |
| Sistematik hata; ders notlarında çoğunlukla "belli bir kurala göre", çoğu kez orantılı (her kilogramda 100 g eksik tartan terazi; her puanın %10 fazla sayılması) | $X^*=a+wX$ | değişmez; ÖSH $\lvert w\rvert$ katına çıkar | ortalama ve kararlar değişir | $\rho_{X\eta}$ değişmez |
| Ders notlarında ayrı adı yoktur: kişiye veya gruba özgü kararlı yanlılık (düzgün el yazısına hale etkisi; matematik testinde okuma yükü; bir gruba karşı katı puanlayıcı) | $B_p$, $\gamma g_p$ | değişir: çoğunlukla yükselir, yapıyla güçlü ters ilişkiliyse düşer | grup ortalamaları yanlı olur | düşer |
| Tesadüfi hata | $E$ | düşer | grup ortalamasında kaybolur; bireysel kararlar tutarsızlaşır | düşer |

  Tablonun altında şu cümle yer alır: "Tekrardan tekrara değişen her yanlılık, adı ne olursa olsun, o tekrar tasarımı için tesadüfi hatadır."
- Dil: Arayüzde "testin güvenirliği" yerine "bu puanların bu gruptaki güvenirliği" yazılır. "Totoloji" sözcüğü yerine "tanım gereği doğrudur" denir. Arayüz metinlerinde uzun tire (U+2014) kullanılmaz.
</gosterim_ve_sozluk>

<ortak_ogeler>
1. Görünüm anahtarı: "Gerçek dünya" / "Perde arkası". Gizli küme, bireysel $T_p$, $E_{pj}$, $\eta_p$, $B_p$, $g_p$ değerleridir ve bunlardan hesaplanan her örneklem istatistiğidir ($s_T^2$, $s_{TE}$, $r_{X\eta}$ vb.). Popülasyon modundaki kaydırıcı parametreleri gizli değildir ve "model ayarı" etiketi taşır. Görselleştiriciler yalnızca `project(state, view)` çıktısını alır. `"real"` projeksiyonunda gizli kümenin anahtarları hiç bulunmaz, dolayısıyla DOM'a, SVG koordinatlarına veya Canvas'a yazılamaz. Modül bazında davranış:

| Modül | Perde arkası ne gösterir | Varsayılan |
|---|---|---|
| M1 | yok (anahtar gizlenir) | yok |
| M2 | $T$ çizgisi, $E$ okları | açık |
| M3 | $T$ noktaları, kişi eğilim histogramları | açık |
| M4 | $\eta$, $B$, $g$, $E$ ayrışımı | açık |
| M5, M6 | $T$, $E$ ve varyans kaynakları | kapalı |
| M7 | veri modunda yok; simülasyon modunda $T$ | kapalı |
| M8 | popülasyon modunda $\Sigma_T$ ve $\Psi$ ayrışımı | kapalı |
| M9 | varyans bileşenlerinin parametre değerleri (simülasyon modunda) | kapalı |

   M2, M3 ve M4 şu TGA ile biter: "Şimdi perdeyi kapat. Yalnızca $X$'i görseydin neyi bilebilirdin?"
2. Varyans bütçesi, M3'te ilk kez görünür ve sonra aynı ekran konumunda kalır. İki parçası vardır. "Konum" şeridi ortalamayı gösterir; sabit hata, orantılı hata ve alt grup kayması burada görünür birer kayma olarak çizilir. "Yayılım" çubuğu varyansı gösterir.
   - Gerçek dünya görünümünde çubuk yalnızca $X$'ten kestirilen ayrışımı gösterir ve "kestirim" etiketi ile ayrı bir desen taşır: kestirilen gerçek varyans $s_{X_1X_2}$, kestirilen hata varyansı $s^2_{X_1}-s_{X_1X_2}$. Modülde tekrar yoksa çubuk yalnızca toplam $s_X^2$'yi gösterir ve "Ayrıştırmak için ikinci bir ölçme gerekir" yazar; "İkinci ölçmeyi ekle" düğmesi paralel bir $X_2$ çeker. Bu, S3'ün ilk ipucudur.
   - Perde açıkken gerçek ayrışım ikinci bir çubuk olarak altında durur.
   - Bölütler: M3-M6'da $\sigma_T^2$ ve $\sigma_E^2$. M4'te "yapı varyansı (η)" ve "kararlı yanlılık (B)" bölütleri, üzerlerinde "KTK gerçek puan varyansı" kıskacıyla, ardından tesadüfi hata; sabit $c$ yalnızca Konum şeridinde bir kayma ve çubukta "sabit bir sayının varyansı yoktur" etiketli sıfır genişlikte bir işaret olarak görünür. M7-M8'de toplamın kestirilen gerçek varyansı $k^2\bar s_{ij}$ ve hata varyansı. M9'da $\sigma_p^2$, $\sigma_i^2/n_i'$, $\sigma^2_{pi,e}/n_i'$.
   - Her rolün sabit bir rengi ve ek olarak bir deseni vardır. Grafiklerde $T$ dolu daire, $X$ içi boş halka, $E$ ok. Renk hiçbir yerde tek kod değildir. Telefonda kaydırma sırasında küçük bir çubuk görünür kalır.
3. Formül kartı üç basamaklıdır: Sözle / Sembolle / Sayılarla. Sayısal satır sembolik satırın altında canlı güncellenir. Formülün altında bir "Terimler" düğme satırı vardır (her düğme görünür etiketli ve en az 44 px). Bir terim düğmesine dokunmak veya klavyeyle odaklanmak hem formüldeki `.t-*` öğesini hem görseldeki karşılığını vurgular. Görsel nesneye dokunmak da terimi vurgular. KaTeX çıktısının içindeki öğelere `tabindex` verilmez, çünkü KaTeX görsel alt ağacı `aria-hidden` taşır. Fareyle üzerine gelme yalnızca ek kolaylıktır. Her formülün Türkçe bir sesli okuma cümlesi vardır (ör. "Güvenirlik, gerçek puan varyansının gözlenen puan varyansına oranıdır").
4. "Ne değişti, neden?" satırı son etkileşimin etkisini tek cümleyle açıklar. Cümle bir şablondan, parametredeki değişimle kestirimdeki değişimin ikisinden birden kurulur. "arttı/azaldı/değişmedi" sözcüğü hesaplanan farkın işaretinden gelir; $|\Delta|<0{,}005$ ise "değişmedi" yazılır. Parametre ile örneklem kestirimi ters yöne gittiyse cümle şudur: "Evren değeri düştü; bu sınıftaki kestirim örnekleme dalgalanması nedeniyle biraz yükseldi. Yeni sınıf çekerek dene."
5. Sınıf kodu (tohum) ekranda görünür ve düzenlenebilir; aynı kod herkese aynı veriyi verir. "Yeni sınıf çek" düğmesi tohumu bir artırır. Her gizil bileşen ($\eta$, $B$, $g$, $E_1$, $E_2$, madde etkileri, kişi×gün etkileri) tohumdan türetilmiş ayrı bir alt akış kullanır. Standart normal çekimler bir kez üretilir; kaydırıcılar yalnızca ölçekler ($E=\sigma_E z$). $n$ değişince aynı akışın ilk $n$ kişisi kullanılır ($n=10$ sınıfı $n=30$ sınıfının alt kümesidir). Toplu çekimler ("10 kez ölç", "1000 kez ölç", "100 sınıf çek") tohum ve $j$'den türetilen alt akışlar kullanır ve yalnızca açıkça adlandırılmış bir düğmeyle başlar. Hiçbir etkileşim yan etki olarak yeniden örnekleme yapmaz.
6. Tahmin-Gözlem-Açıklama (TGA) kartları. Tahmin: kapalı uçludur, bir yön seçimi (artar / azalır / değişmez) veya bir sayı, gerektiğinde bir güven düzeyiyle (emin değilim / emin / çok emin). Gözlem: "Sonucu göster" düğmesi sonucu açar. Açıklama: 3-4 gerekçeden biri seçilir; biri `CLAIMS.md`'deki doğru ifadeye bağlıdır, diğerleri E bölümündeki yanılgılardan kurulur. Kart "Tahminin: ... Sonuç: ..." biçiminde geri gösterilir. İsteğe bağlı serbest metin yalnızca izleyicinin tarayıcısında kalır ve kayda girmez. Her TGA kartı bir ön ayar kimliği taşır.
7. Aşamalı açılım: olgu, sonra söz, sonra sembol, sonra sayı. Her modülün bir "Acemi yolu" (10-15 dakika) ve bir "Uzman katmanı" vardır. Acemi yolunda panel başına en fazla iki etkin kaydırıcı bulunur; diğerleri görünür biçimde kilitlidir. "Uzman modu" iskeleleri atlar ve uzman katmanlarını açar. Üç ders saatlik çekirdek yol: 1. ders M1-M3; 2. ders M4-M6; 3. ders M7-M9; M10 ders dışı çalışma.
8. Animasyon yalnızca bir değişimi temsil ettiğinde kullanılır, her zaman adım adım ilerletilebilir ve durdurulabilir; kendiliğinden oynamaz.
9. Etki haritası: kalıcı bir paneldir; satırları ve hücreleri G bölümündeki tablodur. Bir hücre, öğrenci ilgili TGA'yı bitirince dolar, "Tahminin / Sonuç" gösterir ve ilgili modüle bağlantı verir. Durağan sürüm tamamlanmış tabloyu gösterir. Öğrencinin "ne neyi nasıl etkiliyor?" sorusuna toplu yanıtı budur.
</ortak_ogeler>

<moduller>
Her modülde: kazanımlar (S1-S3 ve Y kimlikleriyle etiketli), acemi yolu, uzman katmanı, formüller, görülmesi gereken, kontrol sorusu. Parantez içindeki yanıtlar doğrulanmıştır ve A15 testiyle yeniden hesaplanır.

M1. Varyans, kovaryans, korelasyon (iki ekran)
- Kazanımlar: Varyansı sapma karelerinden hesaplar ve herkese sabit eklemenin varyansı neden değiştirmediğini açıklar (S1, S2; Y3). Kovaryans ile korelasyonu dikdörtgen alanlarıyla hesaplar ve gürültünün korelasyonu neden düşürdüğünü açıklar (S1, S3).
- Ekran 1, varyans: 0-100 ekseninde sürüklenebilir sekiz puan; her sapma eksenin altında gerçek bir kare olarak çizilir. "Herkese +10" ve "Herkesi ×2" düğmeleri. "×2" sapmaları ortalama çevresinde ikiye katlar; eksen gerektiğinde genişler. M1'de hiçbir işlem kırpma yapmaz; kırpma yalnızca M4'teki tavan ve taban denetimindedir. Serbestlik derecesi etkileşimi: "Sekiz noktadan yedisini sürükle; sekizincinin sapması kendiliğinden belirlenir, çünkü sapmaların toplamı sıfırdır. Bu yüzden serbestçe değişebilen sapma sayısı $n-1$'dir (serbestlik derecesi, sd)." M9'daki sd sütunu bu etkileşime geri bağlanır.
- Ekran 2, kovaryans ve korelasyon: Test 1 ile Test 2 saçılım grafiği. Her nokta ortalama çaprazına bir dikdörtgen çizer (I. ve III. bölgede dolu, II. ve IV. bölgede taralı). "Test 2'de herkese +10" düğmesi, "Test 2'de gürültü" kaydırıcısı, z puanı anahtarı.
- Formüller: $s_X^2=\frac{1}{n-1}\sum_p (X_p-\bar X)^2$ (kart başlığı: "kareler toplamı / serbestlik derecesi, yazılımlarla aynı"; $n$ paydalı sürüm anahtar arkasında); $s_{X_1X_2}=\frac{1}{n-1}\sum_p (X_{1p}-\bar X_1)(X_{2p}-\bar X_2)$; $r=\dfrac{s_{X_1X_2}}{s_{X_1}s_{X_2}}=\dfrac{1}{n-1}\sum_p z_{1p}z_{2p}$.
- Bağlantı: $\sum$ tüm kareleri, $(X_p-\bar X)$ tek bir karenin kenarını, üs karenin alanını, kovaryanstaki çarpım dikdörtgenin alanını vurgular.
- Görülmesi gereken: +10 bütün noktaları kaydırır ama tek bir kareyi değiştirmez; ×2 her kareyi dört katına çıkarır. Gürültünün eklediği iki işaretli dikdörtgenler kovaryansta ortalamada birbirini götürür, bu yüzden pay yaklaşık aynı kalır; ama gürültü Test 2'nin karelerini büyütür, payda artar ve $r$ düşer. "Götürme" yalnızca ortalamada ve yalnızca kovaryansta olur; tek bir öğrencinin puanında hata götürülmez (Y3). Bu panel M5(b)'ye bağlantı verir. z biriminde dikdörtgen alanlarının toplamı $n-1$'e bölününce $r$ elde edilir.
- Kontrol: A sınıfı 40, 50, 60; B sınıfı 70, 80, 90 aldı. Hangisinin varyansı büyük? A'da herkese 5 puan eklenirse? (Eşit; değişmez.) Tekrar testte herkes tam 5 puan fazla alırsa $r$? (Puanlar değişkense 1.) 5 puan sınıfın rastgele yarısına verilirse? ($r<1$.) Test 2'ye gürültü eklenince kovaryans ve $r$ nasıl değişir? (Kovaryans ortalamada değişmez; $r$ düşer.)

M2. Bir öğrenci, sonsuz tekrar: $X=T+E$
- Kazanımlar: Gerçek puanı sonsuz tekrarın ortalaması olarak tanımlar ve hatanın ortalamasının neden tanım gereği sıfır olduğunu açıklar (S2). Kestirilmiş artık ile gerçek hata puanını ayırt eder (S3; Y4).
- Açılış: "Semboller" kartı (yaklaşık 3 dakika, uzman modunda atlanır). Her sembolün Türkçe sesli okuması ve bir görsele bağlantısı vardır: $\sum$ "topla" (M1 kareleri); $\bar X$ "ortalama"; $X_{pj}$ "p kişisinin j. ölçmesi" (sonra $X_{pi}$ "p kişisinin i. maddesi", tablonun satır ve sütununa bağlı); $\mathbb E$ "sonsuz tekrardaki ortalama" (bu modüldeki 1000 kez ölç histogramı); $\equiv$ "tanım gereği eşittir"; "$\mid p$" "p kişisi için"; şapka "kestirim".
- Etkileşim: Ayşe'nin "her ölçmeden sonra testi hiç görmemiş olduğu" düşünce deneyi (Lord ve Novick'in bellek silme varsayımı). "1 kez / 10 kez / 1000 kez ölç" düğmeleri, bir $\sigma_E$ kaydırıcısı, biriken $X$ histogramı. Perde açıkken $T$ kesikli çizgi, her $E_j$ $T$'den $X_j$'ye bir ok.
- Formül: $X_{pj}=T_p+E_{pj}$, $T_p\equiv\mathbb E_j(X_{pj})$, dolayısıyla $\mathbb E(E_{pj}\mid p)=0$.
- Kartta şu cümle yer alır: "Hatanın ortalamasının sıfır olması bir keşif değil, tanımdır." Sonucu: tekrarlar boyunca ortalaması sıfırlanmayan bir sapma, tanım gereği $T$'nin parçasıdır. M4 bu cümleye dayanır.
- Kontrol: Ayşe'nin tekrarları 62, 58, 65, 55, 60. $\hat T$ ve artıklar? ($\hat T=60$; $\hat E_j=X_j-\hat T=+2,-2,+5,-5,0$. Bunlar kestirilmiş artıklardır; gerçek $E_j$ yalnızca $T$'nin bilindiği perde arkasında görünür.) Aynı beş ölçmeyi, her seferinde Ayşe'ye 3 puan fazla veren bir puanlayıcı puanlasaydı $\hat T$ ve artıklar ne olurdu? ($\hat T=63$; artıklar değişmez: +2, −2, +5, −5, 0. Her tekrarda aynı kalan fazlalık hataya değil gerçek puana gider. Tekrarlarda puanlayıcı değişseydi bu sapma hata olurdu.)

M3. Sınıf düzeyinde varyans bütçesi ve güvenirlik oranı
- Kazanımlar: Güvenirliği gerçek varyansın gözlenen varyansa oranı olarak hesaplar ve bunu bireyler hakkında bir ifade gibi yorumlamaz (S1; Y1, Y8). Grup türdeşliğinin güvenirliği ve ÖSH'yi nasıl etkilediğini açıklar (Y1).
- Açılış kartı "İki dünya": evren (popülasyon) değeri $\sigma$ ile bu sınıftaki değer $s$. Kaydırıcılar $\sigma$'yı belirler; "Yeni sınıf çek" beş kez basılınca $s$ değerleri $\sigma$ çevresinde dolaşır.
- Etkileşim: 30 kişilik sınıf; $\sigma_T$ ("öğrenciler gerçekte ne kadar farklı?") ve $\sigma_E$ ("ölçme ne kadar gürültülü?") kaydırıcıları; $T$ noktalarından $X$'e oklar çizen şerit grafik; varyans bütçesi. Çekirdekte $T$-$X$ saçılımı ve şu cümle: "Gözlenen puanın gerçek puanla korelasyonu güvenirliğin kareköküdür." Perde arkasında her öğrencinin küçük bir eğilim histogramı (M2 görselinin küçük hâli) vardır; $\sigma_E^2$ genişliklerin ortalaması, ÖSH tipik genişlik olarak işaretlenir. Sesli okuma: "Hata varyansı, her öğrencinin kendi tekrarlarındaki yayılımın ortalamasıdır." Gerçek dünya görünümünde "İkinci ölçmeyi ekle" düğmesi vardır (ortak öğe 2). TGA: "Aynı test çok türdeş bir sınıfa uygulanırsa?"
- Formüller: $\sigma_X^2=\sigma_T^2+\sigma_E^2+2\sigma_{TE}$; $2\sigma_{TE}$ terimi üstü çizili gösterilir, dokununca "model gereği 0; bu sınıftaki örneklem değeri ..." yazar. $\rho_{XX'}=\dfrac{\sigma_T^2}{\sigma_X^2}=1-\dfrac{\sigma_E^2}{\sigma_X^2}=\rho_{XT}^2$. $\text{ÖSH}=\sigma_E=\sigma_X\sqrt{1-\rho_{XX'}}$. Grup türdeşliği (ÖSH gruplar arasında eşitse): $\rho_{\text{yeni}}=1-\dfrac{\sigma_X^2(1-\rho_{XX'})}{\sigma_{X,\text{yeni}}^2}$.
- Bağlantı: pay çubuğun gerçek bölütünü, payda çubuğun tamamını, "$1-$" hata bölütünün çıkarılmasını vurgular.
- Görülmesi gereken: $\sigma_E$ sabitken türdeş bir sınıfta güvenirlik düşer, ÖSH değişmez. Hata varyansı puan düzeyine bağlı değilse ÖSH gruptan gruba güvenirlik katsayısından daha az değişir; bu yüzden ikisi birlikte raporlanır (koşullu ÖSH notu için M5'e bağlantı).
- Uzman: $T$-$X$ saçılımında regresyon çizgisi ve $\rho_{XT}$ sayısı.
- Kontrol: $\sigma_T^2=64$, $\sigma_E^2=16$ ise güvenirlik? (.80.) Aynı test, $\sigma_T^2=16$? (.50.) ÖSH değişti mi? (Hayır, ikisinde de 4.)

M4. Hata Laboratuvarı: sabit, kurala bağlı, kararlı ve tesadüfi hata (S2)
- Kazanımlar: Sabit, kurala bağlı, kişiye özgü kararlı ve tesadüfi hatanın ortalama, güvenirlik ve yapıyla ilişki üzerindeki etkisini ayırt eder (S2; Y2, Y13, Y16). Bir hatanın sistematik mi tesadüfi mi sayılacağının tekrar tasarımına bağlı olduğunu örnekle açıklar (S2; Y7).
- Açılış kartı: `<gosterim_ve_sozluk>` içindeki hata türleri tablosu.
- Model (perde arkasında her bileşen görünür): $X_{pj}=\eta_p+c+B_p+\gamma g_p+E_{pj}$. Sistematik bileşen $U_p=c+B_p+\gamma g_p$. KTK gerçek puanı $T_p=\eta_p+U_p$ olur; KTK $\eta$ ile $U$'yu birbirinden ayıramaz.
- Denetimler (tek tek açılır): $c$; $\sigma_B$; "Yanlılık tekrarlarda aynı mı, değişiyor mu?" anahtarı; $\sigma_E$; orantılı hata $w$. Uzman: alt grup ($\pi$, $\gamma$); $\rho_{B\eta}$; "Sabit kayma yalnızca ikinci ölçmede"; tavan ve taban etkisi (puanlar 0-100 aralığında kesilir).
- Göstergeler: $X_1$-$X_2$ saçılımı; güvenirlik göstergesi $r_{X_1X_2}$; "Yapıyla korelasyon $\rho_{X\eta}$ (yalnızca simülasyonda)" göstergesi ve üzerinde tavan $\sqrt{\rho_{XX'}}$; ortalamadaki kayma okuması; sabit kesme puanında geçme oranı. Göstergenin altında şu not yazar: "Geçerlik bir katsayı değildir; puan yorumlarının kanıtla desteklenme derecesidir. Bu gösterge, yalnızca simülasyonda görülebilen bir kanıt türüdür." Uzman: mutlak uyum göstergesi, $n\times2$ matristen M9'un ANOVA yoluyla hesaplanan ICC(A,1) (negatif bileşen 0'a çekilerek), yanında tutarlılık karşılığı ICC(C,1); alt grup ortalamaları ve grup içi güvenirlikler.
- Formüller: $\rho_{XX'}=\dfrac{\sigma_\eta^2+\sigma_U^2+2\sigma_{\eta U}}{\sigma_\eta^2+\sigma_U^2+2\sigma_{\eta U}+\sigma_E^2}$, $\rho_{X\eta}=\dfrac{\sigma_\eta^2+\sigma_{\eta U}}{\sigma_X\,\sigma_\eta}$ ($c$ sabit olduğu için $\sigma_U^2$'ye katkı yapmaz). Sabit için cebir kartı: $(X_p+c)-(\bar X+c)=X_p-\bar X$; kartta M1'in karelerinin küçük bir kopyası değişmeden durur. Doğrusal dönüşüm $X^*=a+wX$: oranlar değişmez, $\text{ÖSH}^*=|w|\,\text{ÖSH}$. Uzman: $\rho_{XY}\le\sqrt{\rho_{XX'}\rho_{YY'}}$ ve zayıflama düzeltmesi $\rho_{T_XT_Y}=\rho_{XY}/\sqrt{\rho_{XX'}\rho_{YY'}}$ (örnekleme hatası veya uyumsuz güvenirlik kestirimleri yüzünden 1'i aşabilir).
- TGA senaryoları. Acemi yolu 1-5; uzman 6-9:
  1. Her iki ölçmede sabit $c$: aynı öğretmen iki uygulamayı da puanlıyor ve her kâğıda 5 puan fazla veriyor (ders notundaki örnek), ya da puanlama yazılımı herkesten 4 puan düşüyor. Yanlış anahtarlanmış madde örnek olarak kullanılmaz, çünkü öğrencileri farklı etkiler. Bulut köşegen boyunca kayar; $r$, varyanslar ve ÖSH aynı kalır; yalnızca ortalama ve kesme puanındaki kararlar değişir. Gerçekten sabit hataların eğitimde nadir olduğu da söylenir.
  2. Kurala bağlı (orantılı) hata: her puan %10 fazla sayılıyor ($X^*=1{,}1X$). $r$ ve α değişmez; ÖSH 1,1 katına çıkar; ortalama ve kesme puanındaki kararlar değişir (Sabit Veri A: ÖSH 2'den 2,2'ye, ortalama 12'den 13,2'ye).
  3. Kararlı kişiye özgü yanlılık $B$ (düzgün el yazısına hale etkisi; matematik testinde okuma yükü), $B\perp\eta$: $\sigma_\eta^2=60$, $\sigma_E^2=20$ iken $B$ yokken $\rho_{XX'}=.75$, $\rho_{X\eta}=\sqrt{.75}\approx.87$; $\sigma_B^2=20$ eklenince $\rho_{XX'}=.80$, $\rho_{X\eta}=\sqrt{.60}\approx.77$, tavan $\sqrt{.80}\approx.89$. Güvenirlik yükselir, yapıyla korelasyon düşer.
  4. Yanlılık tekrarlar arasında değişiyor (her seferinde farklı öğrencilere yumuşak davranan farklı puanlayıcı): $B$ bu tasarım için tesadüfi hata gibi davranır, $r$ düşer.
  5. Tesadüfi hata: $\sigma_E$ artınca hem $r$ hem yapıyla korelasyon düşer.
  6. (Uzman) Sabit kayma yalnızca ikinci ölçmede: $r$ aynı kalır, farkların ortalaması sıfır olmaz, mutlak uyum düşer (M5 verisinde $X_2$'ye +5: ICC(C,1) 17/18'de kalır, ICC(A,1) 17/18'den 408/803 ≈ .5081'e düşer). Ders: "etkilemez" ifadesi tutarlılık katsayıları için geçerlidir; uyum ve mutlak kararlar için geçerli değildir. Φ için M9'a bağlantı.
  7. (Uzman) $\rho_{B\eta}<0$ iken kararlı yanlılık güvenirliği düşürebilir (koşul $\sigma_U^2+2\sigma_{\eta U}<0$; Sabit Veri A'da düşük puanlılara madde başına +1: .80'den 2/7 ≈ .29'a).
  8. (Uzman) Alt gruba özgü kararlı kayma: havuzlanmış güvenirlik değişir (genellikle yükselir), grup içi güvenirlik değişmez, gözlenen grup ortalama farkı $\gamma$ kadar yanlıdır. Bu bir adillik ve ölçme değişmezliği sorunudur; güvenirlik katsayıları bunu yakalayamaz.
  9. (Uzman) Tavan etkisi: eklenen sabit artık herkese aynı değildir; varyanslar ve güvenirlik değişir (Sabit Veri A'da +1 ve 5'te kesme: α .80'den 280/377 ≈ .7427'ye).
- Özet kartı: Güvenirlik katsayıları yalnızca ortalamadan sapmalardan kurulur, bu yüzden herkese aynı eklenen sabitler kaybolur. Her tekrarda aynı kişide aynı biçimde yinelenen bir yanlılık, kişiler arasındaki gerçek bir farktan ayırt edilemez; KTK onu gerçek varyans olarak kaydeder ve bedeli yapıyla ilişkiye yansır. Yalnızca tekrarlar arasında değişen hata tekrarlar arasında uyumsuzluk yaratır; bu katsayılar yalnızca uyumsuzluğu görebilir. "Tesadüfi" burada "nedensiz" değil, "bu tasarımdaki tekrarlarda yinelenmeyen" demektir.
- Ders kitaplarıyla uzlaştırma kartı (tam metin): "'Sabit ve sistematik hatalar geçerliği, tesadüfi hatalar güvenirliği etkiler' kuralı iki durumda tam olarak doğrudur: hata herkese aynı miktarda eklendiğinde (sabit hata) ya da herkese aynı kuralla uygulandığında (ör. her puanın %10 fazla sayılması) ve bu her tekrarda aynı biçimde olduğunda. Bu iki durumda güvenirlik hiç değişmez; bedel ortalamaya, mutlak kararlara ve puanların mutlak yorumuna yansır. Hata kişiden kişiye değişip tekrarlarda aynı kalıyorsa güvenirliği düşürmez ama değiştirir: çoğunlukla yükseltir (senaryo 3 ve 8; Sabit Veri A'da .80'den 76/91 ≈ .84'e veya 10/11 ≈ .91'e), yapıyla güçlü ters ilişkiliyse düşürür (senaryo 7; .80'den 2/7 ≈ .29'a). Her iki durumda puanların yapıyla ilişkisi zayıflar. Hata tekrardan tekrara değişiyorsa, adı ne olursa olsun, bu tasarım için tesadüfi hatadır ve güvenirliği düşürür (senaryo 4). Uygulama kuralı çürütmez; 'etkilemez' sözcüğünü koşullarıyla birlikte okur." Katman C gözden geçiricisi bu kartı B bölümüyle karşılaştırır.
- Kontrol: Yazılım hatası herkesten 4 puan düşüyor. $r$, ÖSH, ortalama ve 50 kesme puanındaki kararlar ne olur? ($r$ ve ÖSH aynı; ortalama 4 düşer; kararlar etkilenir.) Aynı puanlayıcı iki ölçmede de düzgün yazılı kâğıtlara 5 puan fazla veriyor. (Düzgün yazı yapıyla ilişkisizse güvenirlik düşmez, yükselir; yapıyla korelasyon düşer.)

M5. Görünmeyeni kestirmek ve ÖSH (S3)
- Kazanımlar: İki paralel ölçmeden hata varyansını ve ÖSH'yi fark yolu, kovaryans yolu ve köşegen yoluyla hesaplar ve üçünün aynı sayıya vardığını gösterir (S1, S3; Y4). ÖSH bandını doğru yorumlar ve varsayımlar bozulunca kestirimin hangi yöne yanlılaştığını söyler (S3; Y9, Y14).
- Açılış TGA: "Yalnızca puanları görüyorsun. Hataların ortalama büyüklüğünü bilebilir miyiz?"
- Çalışılmış veri (M5 verisi): $X_1=10,12,14,16,18,20$ ve $X_2=11,11,15,14,19,20$.
- Etkileşim:
  (a) Fark yolu: her öğrenci için $X_1$ ile $X_2$ arasında bir çubuk. Farkların ortalaması sabit kaymayı, farkların yayılımı tesadüfi hatayı gösterir. $n-1$ ile (varsayılan): $s_D^2=1{,}6$; $\hat\sigma_E^2=0{,}8$; ortalama $s_X^2=(14+14{,}8)/2=14{,}4$; $1-0{,}8/14{,}4=17/18\approx0{,}944$; ÖSH $\approx0{,}894$. $n$ ile (anahtar arkasında): 1,333; 0,667; 12; aynı oran; ÖSH $\approx0{,}816$. Doğrudan $r\approx0{,}945$. Not: "İki değer, formların varyansları (14 ve 14,8) tam eşit olmadığı için biraz farklıdır; paralel formlarda aynıdır."
  (b) Kovaryans yolu: çapraz terimler dokunulabilir; perde açıkken küçük ve dalgalanan örneklem değerleri görünür. M1'in gürültü paneline bağlantı verir.
  (b2) İki formdan matrise: $S=\begin{pmatrix}14&13{,}6\\13{,}6&14{,}8\end{pmatrix}$. "Köşegeni doldur" köşegen dışı 13,6'yı (kestirilen gerçek varyans) iki köşegen hücresine koyar; kalanlar 0,4 ve 1,2, ortalamaları 0,8'dir; bu fark yolundaki $s_D^2/2$ ile aynıdır ($14+14{,}8-2\cdot13{,}6=1{,}6$). Ekrandaki cümle: "Fark yolu ile köşegen yolu aynı sayıyı verir." M8 bu işlemi $k(k-1)$ çiftle tekrarlar.
  (c) Yakınsama: "Yeni sınıf çek" ve $n\in\{10,30,100,1000\}$ seçici; tekrarlanan kestirimler gerçek parametre çevresinde nokta grafiği oluşturur. Küçük sınıflar kararsız güvenirlik kestirimleri verir.
  (d) Varsayım bozucular: bellek etkisi (hatalar ilişkili; güvenirlik fazla kestirilir); farklı gerçek değişim (az kestirilir); eşit olmayan hata varyansları (tau eşdeğer formlarda $r=\sqrt{\rho_1\rho_2}$, iki güvenirliğin geometrik ortalaması; ör. .8 ve .5 için .6325; $r$ artık iki formun güvenirliğinden hiçbirine eşit değildir); sabit kayma ($r$ etkilenmez, farkların ortalaması sıfırdan farklı).
  (e) ÖSH bandı: sürüklenebilir öğrenci ve $X\pm1{,}96\,\text{ÖSH}$ bandı; perde açıkken tekrarlar boyunca kapsama sayacı. Varsayılan simülasyonda hata varyansı herkes için aynıdır. Uzman: "Binom hata" anahtarı; kapsama sayacı puan düzeyine göre %95'ten görünür biçimde ayrılır ($k=20$, ÖSH = 2 için gerçek oran .5'te %88,5; .95'te %99,7). Uzman: Kelley kestirimi, üç standart hata, koşullu ÖSH.
- Formüller:
  $$D_p=X_{1p}-X_{2p}=(T_{1p}-T_{2p})+(E_{1p}-E_{2p})$$
  Tau eşdeğerlikte $T_1-T_2$ herkes için aynı sabittir; $\bar D$ onu kestirir ve $\sigma_D^2=\sigma^2_{E_1}+\sigma^2_{E_2}$ olur, yarısı ortalama hata varyansıdır. Paralel ölçmelerde $\sigma_D^2=2\sigma_E^2$ ve $\hat\sigma_E^2=\tfrac12 s_D^2$.
  $$\sigma_{X_1X_2}=\sigma_T^2+\sigma_{TE_2}+\sigma_{E_1T}+\sigma_{E_1E_2}=\sigma_T^2,\qquad \hat\sigma_E^2=s_X^2(1-r_{12})$$
  $$\hat T=\rho X+(1-\rho)\mu_X;\quad \text{ölçme: }\sigma_X\sqrt{1-\rho},\ \ \text{kestirim: }\sigma_X\sqrt{\rho(1-\rho)},\ \ \text{yordama: }\sigma_X\sqrt{1-\rho^2}$$
  Koşullu ÖSH (Lord'un binom hata modeli, 0/1 maddelerin toplam puanı): $\text{ÖSH}(x)=\sqrt{x(k-x)/(k-1)}$. Kartın notu: "Binom modelde hata varyansı gerçek düzey $\zeta$'ya bağlıdır, $k\zeta(1-\zeta)$, ve yalnızca $\zeta=0$ veya $1$'de sıfırdır. Lord kestiricisi gözlenen 0 ve $k$ puanında 0 verir; bu, tam puan alan öğrencinin hatasız ölçüldüğü anlamına gelmez (tavan etkisi)."
- M9'a köprü: İkiden fazla tekrarda havuzlanmış kişi içi varyans, tek yönlü ANOVA'daki kişi içi KO'dur. Tekrarların kendi ana etkisi yoksa bu, iki yönlü artık KO ile aynıdır. Maddeler güçlükte farklıysa tek yönlü kişi içi KO madde etkisini de içerir (Sabit Veri A: 7/6 = 1/6 + 1); iki yönlü $KO_{art}$ onu ayıklar (1). Bu fark, mutlak ve bağıl hata arasındaki farktır.
- Epistemik not kartı: Hatayı hiçbir zaman gözlemeyiz; tekrarlar arasındaki uyumsuzluğu gözler ve bir model altında hatayı çıkarsarız. Anahtarlar o modelin varsayımlarını görünür kılar.
- Kontrol: İki paralel formda $s_X^2=100$, $r=.84$. $\hat\sigma_E^2$, ÖSH ve $X=70$ için %68 bandı? (16; 4; 66-74. Bant, hata varyansının puan düzeyine bağlı olmadığı varsayımıyla ve tekrarlanan ölçmeler üzerinden yorumlanır.)

M6. Tekrar tasarımcısı: her yöntem "aynı ölçmeyi tekrarlamanın" farklı bir tanımıdır
- Kazanımlar: Test-tekrar test, eşdeğer formlar ve iç tutarlılığın hangi kaynakları hata saydığını karşılaştırır (S1, S2; Y7). Bir hata kaynağının (ör. baş ağrısı) hangi katsayıda hata, hangisinde gerçek puan sayılacağını belirler (S2).
- Acemi yolu: öğrenci iki ölçme arasında neyin değiştiğini seçer: zaman, form veya ikisi (puanlayıcı değişimi M9'da işlenir). Kaynak-rol tablosu hangi kaynakların gerçek puana, hangilerinin hataya katıldığını yeniden renklendirir. Varyans bütçesi ve bir $k$ kaydırıcısı: "Madde sayısı arttıkça maddeye özgü sapmalar ortalamada küçülür; nedenini M7'de göreceksin." "Aynı veri, dört yöntem" paneli: test-tekrar test, eşdeğer formlar, gecikmeli eşdeğer formlar ve α; perde açıkken her biri kendi kuramsal hedefinin yanında. α "M7'de elle hesaplayacaksın" etiketi taşır. Anahtarlar: bellek etkisi, farklı öğrenme.
- Uzman katmanı: simülasyondaki varyans kaynakları kişi $\sigma_p^2$, kişi×gün (geçici) $\sigma_{po}^2$, kişi×madde (madde özgüllüğü) $\sigma_{pi}^2$, artık $\sigma_e^2$; aşağıdaki üç formül.
- Formüller ($k$ maddelik bir formun madde ortalaması puanı için; puanlama nesnel varsayılır):
  $$\rho_{\text{tekrar}}=\frac{\sigma_p^2+\sigma_{pi}^2/k}{\sigma_p^2+\sigma_{pi}^2/k+\sigma_{po}^2+\sigma_e^2/k},\qquad \rho_{\text{eşdeğer}}=\frac{\sigma_p^2+\sigma_{po}^2}{\sigma_p^2+\sigma_{po}^2+(\sigma_{pi}^2+\sigma_e^2)/k}$$
  $$\rho_{\text{gecikmeli eşdeğer}}=\frac{\sigma_p^2}{\sigma_p^2+\sigma_{po}^2+(\sigma_{pi}^2+\sigma_e^2)/k}$$
  Bu simülasyon modelinde (maddeler rastgele örneklenmiş ve değiş tokuş edilebilir) tek oturumda hesaplanan α'nın hedefi eşdeğerlik katsayısıdır. Test-tekrar test ve eşdeğer formlar için $r$'nin elle hesabı M7'nin ilk sekmesindedir.
- Yöntem kartları aynı beş alanı taşır: Veri tasarımı; Hesap; Hata sayılan kaynaklar; Varsayım; Tipik tuzak. Tuzaklar arasında: test-tekrar testte gerçek değişim katsayıyı düşürür, bellek yükseltir; hız testlerinde yarıya bölme ve α şişer (ayrı zamanlanmış yarılar veya test-tekrar test kullanılır); iki uygulama arasındaki korelasyon yalnızca paralel ölçmelerde güvenirliğe eşittir.
- Görülmesi gereken: aynı öğrenciler farklı katsayılar üretir; kararlılık forma özgü hatayı görmez, eşdeğerlik güne özgü hatayı görmez, yalnızca gecikmeli eşdeğer formlar ikisini de hata sayar ve genellikle en düşük değeri verir.
- Kontrol: Bir öğrencinin test günü başı ağrıyordu. Bu test-tekrar test için hata mı? Aynı oturumdan hesaplanan α için? (Test-tekrar test için hatadır. α için gerçek puana karışır; bu yüzden α, günden güne genellemek istediğimiz güvenirliği fazla kestirir.)

M7. Hesap Tezgâhı: $r$ ve iç tutarlılık (S1)
- Kazanımlar: Pearson $r$, yarıya bölme (Spearman-Brown, Rulon), KR-20 ve α'yı elle hesaplar (S1; Y15). Test uzunluğunun ve zayıf bir maddenin α üzerindeki etkisini açıklar (S1; Y10, Y11).
- Sekmeler (acemi yolu 1, 2 ve 3'ün temel hesabı; uzman katmanı KR-21, $r_\varphi$, Lord notu ve tam madde silme tablosu):
  1. "$r$ (test-tekrar test / eşdeğer formlar)": M5 verisi. Sütunlar: $X_1$, $X_2$, $x_1$, $x_2$, $x_1^2$, $x_2^2$, $x_1x_2$, toplamlar (70, 74, 68), sonra $r=68/\sqrt{70\cdot74}\approx0{,}945$. Formül: $r=\dfrac{\sum x_1x_2}{\sqrt{\sum x_1^2\sum x_2^2}}$, $x=X-\bar X$.
  2. "Yarıya bölme": yarıya bölme gezgini ve Spearman-Brown.
  3. "α ve KR-20": varsayılan Sabit Veri A (açık uçlu sorular); 0/1 anahtarıyla Sabit Veri B.
- Ortak düzen: Sütunlar el hesabının sırasını izler ve adım adım açılır: ham puan, sapma, kare veya çarpım, toplam, formül. Bağımlılık izi: bir hücreye odaklanınca ince çizgiler hücreden sütun toplamına, formül terimine ve geometrik nesneye (kare, dikdörtgen, matris hücresi) gider. Sekmeyle ayrılmış veri yapıştırma (en fazla 50×20, "veriler tarayıcınızdan çıkmaz" notuyla); eksik hücreli satırlar liste bazında çıkarılır ve çıkarılan satır sayısı gösterilir.
- Solan çözümlü örnekler, her sekmede dört tur: 1. tur sabit veriyle tamamen çözülmüş ve öz açıklama soruları içerir ("Bu çarpım neden negatif?"); 2. turda son adım boş; 3. turda orta sütunlar boş; 4. turda yalnızca ham veri. 2-4. turlar, ezberlenmiş yanıtla geçilemesin diye tohumlu "el hesabı dostu" üreticiden gelir. α sekmesi için kısıtlar: 6 kişi, 3 veya 4 madde, 1-5 puan, her maddenin ve toplamın ortalaması tam sayı, her maddenin varyansı sıfırdan büyük ve en az üç farklı değer içerir, $0{,}5\le\hat\alpha\le0{,}9$ ($n=6$ ve tam sayı ortalamalarda $n-1$ paydalı varyanslar tek ondalıklıdır). $r$ sekmesi için: 6 kişi, 1-20 arası tam sayı puanlar, tam sayı ortalamalar, $r>0{,}5$. Yanıtlar yuvarlama toleransıyla, virgül veya nokta ile kabul edilir.
- Tanısal geri bildirim yalnızca "yanlış" demez, hatayı açıklar. $r$ için: sapma yerine ham puan kullanmak; çarpımların toplamı yerine toplamların çarpımını kullanmak; karekökü unutmak; $r$'yi paralel form koşulu olmadan "güvenirlik" saymak (Y14'e bağlantı). α için: varyans yerine standart sapma kullanmak; toplam puan varyansı yerine madde varyansları toplamını kullanmak; aynı oranda $n$ ile $n-1$'i karıştırmak (Sabit Veri B'de yanlış .7891 verir); zaten tam uzunluktaki bir katsayıya Spearman-Brown uygulamak; $k/(k-1)$ çarpanını unutmak.
- Yarıya bölme gezgini: öğrenci maddeleri A veya B yarısına koyar; tüm bölmeler 0-1 doğrusunda nokta olarak görünür (4 maddede 3, 6 maddede 10 bölme; 6 maddelik ön ayar tohumlu üreticiyle üretilir). $k$ çiftken ortalamaları işaretlenir ve Flanagan-Rulon ortalamasının α'ya eşit olduğu gösterilir. $k$ tekse gezgin $(k-1)/2$ ile $(k+1)/2$ bölmelerini gösterir, "ortalama = α" işaretini gizler ve nedenini yazar (uzman notu: bu durumda ortalama $\alpha\,(k^2-1)/k^2$'dir). $k\le12$ için tüm bölmeler, $k>12$ için tohumlu 1000 bölme kullanılır. Test uzunluğu kaydırıcısı ve Spearman-Brown eğrisi. Madde güçlüğü paneli: $p(1-p)$ eğrisi; uzman: iki madde arasındaki en büyük $r_\varphi$.
- Formüller:
  Spearman-Brown $\rho_m=\dfrac{m\rho}{1+(m-1)\rho}$; hedef için gereken uzunluk çarpanı $m=\dfrac{\rho^*(1-\rho)}{\rho(1-\rho^*)}$ (eklenen parçaların paralel olduğu varsayımıyla).
  Yarılar: $\rho_{SB}=\dfrac{2r_{hh}}{1+r_{hh}}$ (paralel yarılar gerekir); Flanagan-Rulon $2\left(1-\dfrac{s_A^2+s_B^2}{s_Y^2}\right)$; Rulon $1-\dfrac{s_D^2}{s_Y^2}$, $D=A-B$. Son ikisi cebirsel olarak özdeştir ve yalnızca özünde tau eşdeğer yarılar gerektirir. Rulon, M5'teki fark mantığının aynısıdır.
  $\hat\alpha=\dfrac{k}{k-1}\left(1-\dfrac{\sum_i s_i^2}{s_Y^2}\right)$; $\hat\sigma_Y^2=\frac1n\sum_p(Y_p-\bar Y)^2$ ile $\text{KR-20}=\dfrac{k}{k-1}\left(1-\dfrac{\sum_i p_iq_i}{\hat\sigma_Y^2}\right)$ ve $\text{KR-21}=\dfrac{k}{k-1}\left(1-\dfrac{M(k-M)}{k\,\hat\sigma_Y^2}\right)$ (KR-21 eşit madde güçlüğü varsayar; KR-21 ≤ KR-20). Örneklem ÖSH'si $s_Y\sqrt{1-\hat\alpha}$.
  Madde silinirse α; düzeltilmiş madde-toplam korelasyonu. Uzman: $\max r_\varphi=\sqrt{\dfrac{p_i(1-p_j)}{p_j(1-p_i)}}$, $p_i\le p_j$ (ör. $p=.2$ ve $.8$ için $.25$).
- Görülmesi gereken: farklı bölmeler farklı sonuç verir, tek-çift bölme yalnızca bir bölmedir; $k$ çiftken tüm eşit bölmelerin Flanagan-Rulon ortalaması α'ya eşittir, Spearman-Brown ortalaması eşit değildir; uzatmanın getirisi azalır; madde varyansları toplamı ile toplam puan varyansı arasındaki fark güvenirliğin kaynağıdır. Zayıf madde gösterimi (acemi): Sabit Veri A'ya 5. madde eklenince α 0,80'den 0,68'e düşer (15/22), madde silinince 0,80'e döner. Uzman: Sabit Veri A'da 4. madde silinince α .8015'e çıkar; kart "$n=6$'da bu fark örnekleme hatasının çok altındadır" uyarısını taşır. Aynı etki popülasyon modunda: λ = .9, .8, .3, .2 iken λ = .2 maddesi silinince α .5987'den .6758'e, ω .6667'den .7326'ya çıkar. Madde güçlüğü notu (uzman): "$p=.5$" evrensel bir kural değildir; çoktan seçmeli maddelerde en uygun ortalama güçlük, şans düzeyi ile %100'ün ortasından biraz daha kolay taraftadır (Lord, 1952); bu seçim, yetenek aralığının farklı bölgelerindeki ölçme kesinliğiyle bir ödünleşim içerir.
- Kontrol: Yarı test korelasyonu .60 ise tam test? (.75.) .75'ten test üç katına çıkarılırsa? (.90.) .60'tan .80'e çıkmak için uzunluk çarpanı? (8/3 ≈ 2,67.)

M8. Matris görünümü
- Kazanımlar: Toplam puan varyansını kovaryans matrisinin hücre toplamı olarak yazar ve α'daki $k/(k-1)$ çarpanını köşegen doldurma ile açıklar (S1, S3). α'nın ω'nın altında veya üstünde kaldığı koşulları ve α'nın tek boyutluluk göstergesi olmadığını açıklar (Y5, Y6).
- Acemi yolu: $k\times k$ ısı haritası ($k=3$ ile başlar, 8'e kadar); bir hücreye dokununca o madde çiftinin saçılımı açılır. Köşegen ve köşegen dışı toplamlar ayrı gösterilir. "Köşegeni doldur" düğmesi her köşegen hücresini kestirilen gerçek kısım (ortalama köşegen dışı değer) ile hata kalanına böler; M5(b2)'deki işlemin $k(k-1)$ çiftle yapılmış hâli olarak sunulur. Bir maddenin kalanı negatifse bayrakla gösterilir: "Bu madde için kalan negatif: örneklem dalgalanması ya da α'nın varsayımının (özünde tau eşdeğerlik) bozulması." Dört ön ayar model düğmesi (tek seferde bir tane): tau eşdeğer; konjenerik (eşit olmayan yükler); iki madde arasında ilişkili hata (aynı okuma parçasını paylaşan madde demeti); iki blok. Acemi kaydırıcıları yalnızca "ortalama yük" ve "yük yayılımı"dır.
- Uzman katmanı: tek tek λ, ψ ve $\psi_{ij}$ kaydırıcıları. Varsayılan $\psi_i=1-\lambda_i^2$; serbest ψ yalnızca uzman modunda. $|\psi_{ij}|\le0{,}9\sqrt{\psi_i\psi_j}$ sınırı ve her güncellemede Cholesky denetimi uygulanır; pozitif tanımlı olmayan bir değişiklik reddedilir ve nedeni yazılır. İki blok modu: $k=6$ veya 12, iki blok, blok içi λ = .7 ve bir faktörler arası korelasyon kaydırıcısı (0-1). Bu modda ω gösterilmez; α ve $\mathbf 1^{\mathsf T}\Sigma_T\mathbf 1/\mathbf 1^{\mathsf T}\Sigma\mathbf 1$ gösterilir. Standart α ve $L_2$.
- Formüller:
  $$\sigma_Y^2=\mathbf 1^{\mathsf T}\Sigma\mathbf 1=\operatorname{tr}(\Sigma)+\sum_{i\neq j}\sigma_{ij},\qquad \alpha=\frac{k}{k-1}\left(1-\frac{\operatorname{tr}\Sigma}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}\right)=\frac{k^2\bar\sigma_{ij}}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}$$
  Üç satırlık türetme kartı: $\bar\sigma_{ij}=\sum_{i\neq j}\sigma_{ij}/[k(k-1)]$; toplamın gerçek varyansı $\approx k^2\bar\sigma_{ij}$; $\alpha=k^2\bar\sigma_{ij}/\sigma_Y^2$.
  $\Sigma=\Sigma_T+\Sigma_E$; hatalar ilişkisizse $\Sigma_E=\Psi$ köşegendir ve köşegen dışı hücreler saf gerçek puan kovaryansıdır. Tek faktör: $\Sigma=\lambda\lambda^{\mathsf T}+\Psi$, $\omega=\dfrac{(\sum_i\lambda_i)^2}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}$ (ilişkisiz hatalarda payda $(\sum\lambda_i)^2+\sum\psi_i$). $\Psi$ köşegenken (ilişkisiz hatalar) $\alpha=\dfrac{k}{k-1}\cdot\dfrac{(\sum\lambda)^2-\sum\lambda^2}{\sigma_Y^2}\le\omega$, çünkü $(\sum\lambda)^2\le k\sum\lambda^2$; eşitlik ancak tüm λ eşitse.
  Standart α: $\alpha_{std}=\dfrac{k\bar r}{1+(k-1)\bar r}$ (ortalama madde korelasyonuna Spearman-Brown). Madde varyansları eşitse ham α'ya eşittir; genel olarak farklıdır (Sabit Veri A: .805 ve .80). Guttman: $L_2=\dfrac{\sum_{i\neq j}\sigma_{ij}+\sqrt{\frac{k}{k-1}\sum_{i\neq j}\sigma_{ij}^2}}{\sigma_Y^2}\ge\alpha$.
- Görülmesi gereken: $k/(k-1)$ çarpanı, $k$ köşegen hücresinin görünmeyen gerçek kısmını kestirmek için $k(k-1)$ köşegen dışı hücrenin ortalanmasından gelir. Eşit olmayan yükler α'yı ω'nın altına düşürür. Diğer koşullar sabitken pozitif hata kovaryansları α'yı yükseltir, ω'yı düşürür; yükler eşitse α ω'yı aşabilir (.7712 > .6588), eşit değilse aşmayabilir (.6087 < .6576). Negatif hata kovaryansı α'yı düşürür (.6975 < .7452). Birbiriyle ilişkisiz iki blokta bile α sıfırdan uzaktır ve madde sayısıyla yükselir (6 maddede .5939, 12 maddede .7747); α tek boyutluluk göstergesi değildir.
- Kontrol: Üç maddenin varyansları 4, 5, 6 ve bütün kovaryanslar 2 ise $s_Y^2$ ve α? (27; .667.)

M9. Varyans analizi, Hoyt ve GK'ya ön bakış
- Kazanımlar: Kişi × madde verisinden ANOVA tablosunu kurar, Hoyt katsayısını hesaplar ve α'ya eşitliğini gösterir (S1, S3). Bağıl ve mutlak karar için $\mathbb E\rho^2$ ile Φ'yi ayırt eder ve madde veya puanlayıcı güçlüğünün hangisine girdiğini açıklar (S2).
- Acemi yolu: "Katman soyma": veri tablosu hücre hücre toplandığında aslını veren dört tabloya ayrılır (genel ortalama, kişi etkisi, madde etkisi, artık). Her tablonun M1'deki kareleri toplanarak KT'si bulunur ve ANOVA tablosu (KT, sd, KO) satır satır kurulur. Hoyt = α kartı. Bağıl ve mutlak karar köprüsü (öğrenciler bağıl ve mutlak değerlendirmeyi aynı dersten bilir). $n_i'$ kaydırıcısı ile $\mathbb E\rho^2$ ve Φ eğrileri. "Üç yol, tek hata varyansı" kartı (aşağıda).
- Uzman katmanı: beklenen KO ve varyans bileşenleri; madde güçlüğü yayılımı kaydırıcısı; puanlayıcı görünümü (aynı veri 6 kompozisyon × 4 puanlayıcı olarak yeniden etiketlenir) ve "çaprazlanmış / iç içe" K çalışması deseni anahtarı; ICC bağlantıları; Φ(λ).
- Formüller:
  $X_{pi}=\mu+\nu_p+\nu_i+\nu_{pi,e}$; $KT_T=KT_p+KT_i+KT_{art}$; $KT_p=k\sum_p(\bar X_{p\cdot}-\bar X)^2$, $KT_i=n\sum_i(\bar X_{\cdot i}-\bar X)^2$, $KT_{art}=\sum_p\sum_i(X_{pi}-\bar X_{p\cdot}-\bar X_{\cdot i}+\bar X)^2$; sd sırasıyla $n-1$, $k-1$, $(n-1)(k-1)$.
  Hoyt: $r_H=1-\dfrac{KO_{art}}{KO_p}$. Eşdeğerlik kanıtı kartı: $s_Y^2=k\,KO_p$ ve $\sum_i s_i^2=\dfrac{KT_p+KT_{art}}{n-1}$, dolayısıyla $\hat\alpha=\dfrac{k}{k-1}\left(1-\dfrac{KT_p+KT_{art}}{k\,KT_p}\right)=1-\dfrac{KO_{art}}{KO_p}$ (eksiksiz veri ve tutarlı payda koşuluyla; eksik hücrede ve standart α'da geçerli değildir).
  Beklenen KO: $\mathbb E(KO_p)=\sigma^2_{pi,e}+n_i\sigma_p^2$, $\mathbb E(KO_i)=\sigma^2_{pi,e}+n_p\sigma_i^2$, $\mathbb E(KO_{art})=\sigma^2_{pi,e}$; buradan $\hat\sigma_p^2=(KO_p-KO_{art})/n_i$, $\hat\sigma_i^2=(KO_i-KO_{art})/n_p$, $\hat\sigma^2_{pi,e}=KO_{art}$. Negatif kestirimler geleneksel olarak 0'a çekilir ve ekranda bayrakla belirtilir.
  $\mathbb E\rho^2=\dfrac{\sigma_p^2}{\sigma_p^2+\sigma^2_{pi,e}/n_i'}$, $\Phi=\dfrac{\sigma_p^2}{\sigma_p^2+(\sigma_i^2+\sigma^2_{pi,e})/n_i'}$. Uzman: kesme puanı λ için $\Phi(\lambda)=\dfrac{\sigma_p^2+(\mu-\lambda)^2}{\sigma_p^2+(\mu-\lambda)^2+\sigma^2_\Delta}$; Φ, Φ(λ)'nın en küçük değeridir (λ = μ).
  Puanlayıcılar: çaprazlanmış $p\times r$ desende $\sigma^2_\delta=\sigma^2_{pr,e}/n_r'$ ve $\sigma^2_\Delta=(\sigma^2_r+\sigma^2_{pr,e})/n_r'$; iç içe $r{:}p$ desende $\sigma^2_\delta=\sigma^2_\Delta=\sigma^2_{r,pr,e}/n_r'$. Anahtar G çalışmasını değil K çalışması desenini değiştirir; bileşenler çaprazlanmış G çalışmasından gelir ($\sigma^2_{r,pr,e}=\sigma_r^2+\sigma^2_{pr,e}=7/6$). Uzman notu: "Veri gerçekten iç içe toplanmış olsaydı tek yönlü ANOVA yalnızca $\sigma_p^2$ ile $\sigma^2_{r,pr,e}$'yi ayırabilirdi: $KO_{içi}=7/6$, $\hat\sigma_p^2=23/24$, $\mathbb E\rho^2=\Phi=$ ICC(1,k) $=23/30\approx.7667$. Bu başka bir soruyu yanıtlar; yalnızca etiketi değiştirmek güvenirliği değiştirmez."
  Uzman ICC bağlantıları: α = ICC(C,k) = ICC(3,k); Φ = ICC(A,k) = ICC(2,k) $=\dfrac{KO_p-KO_{art}}{KO_p+(KO_i-KO_{art})/n}$; tek madde $\mathbb E\rho^2$ = ICC(C,1) $=\dfrac{KO_p-KO_{art}}{KO_p+(k-1)KO_{art}}$.
- "Üç yol, tek hata varyansı" kartı (Sabit Veri A): matris yolu $s_Y^2-k^2\bar s_{ij}=20-16=4$; ANOVA yolu $k\cdot KO_{art}=4\cdot1=4$; katsayı yolu $s_Y^2(1-\hat\alpha)=20\cdot0{,}2=4$; köşegen doldurma yolu madde hata kalanları $0{,}5+0{,}5+2{,}1+0{,}9=4$. Hepsinde ÖSH = 2. Bu kart S3'ün toplu yanıtıdır.
- Görülmesi gereken: madde güçlük farkları her öğrenci için aynıdır; öğrencileri sıralarken sabit hata gibi davranır ve Hoyt'a, α'ya, $\mathbb E\rho^2$'ye girmez; sabit bir kesme puanında önemli olan Φ'ye girer. Hoyt tam olarak α'dır. K çalışması eğrisi Spearman-Brown eğrisinin aynısıdır. İç içe desende puanlayıcı katılık farkları bağıl hataya dönüşür. $p\times i$ artığı gerçek kişi×madde etkileşimini tamamen tesadüfi hatadan ayıramaz; α ikisini de hata sayar, çünkü tekrarları yeni maddelerdir.
- Kontrol: $KO_p=10$, $KO_{art}=2$ ise Hoyt? (.80.) 70 puanda geçti/kaldı kararı için hangi katsayı uygundur, neden? (Mutlak karar için Φ; kesme puanına özgü sürümü Φ(λ)'dır ve Φ, Φ(λ)'nın en küçük değeridir. Madde güçlüğündeki kaymalar mutlak puan düzeyini değiştirir.)

M10. Kavram yanılgısı denetimi
- Kazanım: Y1-Y16 yanılgılarını tanır ve doğru ifadeyi seçer.
- E bölümündeki her yanılgı için bir biçimlendirici madde; geri bildirim açıklama yapar ve ilgili modüle bağlantı verir. Yanıtlar yalnızca izleyicinin tarayıcısında tutulur. Bu maddeler araştırmanın kavram envanteri değildir.
</moduller>

<icerik_dogrulugu>
Bu bölüm uygulamanın öğreteceği kesin iddiaları sabitler. Hiçbirini basitleştirme; her birini `CLAIMS.md` içinde ekrandaki yerine, denklemine ve kaynağına eşle.

A. KTK'nın tanımları ve varsayımları
- A.1 Tanım gereği doğru olanlar (varsayım değildir): $\mathbb E(E\mid p)=0$, dolayısıyla $\mathbb E(E)=0$ ve her kişi popülasyonunda $\sigma_{TE}=0$; buradan $\sigma_X^2=\sigma_T^2+\sigma_E^2$.
- A.2 Bozulabilen gerçek varsayımlar: farklı ölçmelerin hataları ilişkisizdir; deneysel bağımsızlık (bir ölçmenin gerçek puanı ile başka bir ölçmenin hatası ilişkisizdir).
- A.3 KTK normallik, eşit hata varyansı veya $E$ ile $T$'nin bağımsızlığını varsaymaz (yalnızca sıfır korelasyon). Doğru sayısı puanlarında hata varyansı gerçek düzeye bağlıdır; binom modelde $k\zeta(1-\zeta)$'dır ve yalnızca $\zeta=0$ veya $1$'de sıfırdır.
- A.4 $\rho_{XX'}=\sigma_T^2/\sigma_X^2=\rho_{XT}^2$. Paralel ölçmelerde iki ölçme arasındaki korelasyon bu varyans oranına eşittir; bir korelasyonun bir varyans oranı olabilmesinin nedeni budur.
- A.5 Ölçme modelleri iç içedir: paralel ($T_i=\tau$, eşit hata varyansı) ⊂ tau eşdeğer ($T_i=\tau$) ⊂ özünde tau eşdeğer ($T_i=\tau+\beta_i$) ⊂ konjenerik ($T_i=\beta_i+\lambda_i\tau$). Konjenerik modelde parametrelerin farklı olmasına izin verilir, zorunlu değildir. Buradaki τ ortak gerçek puandır (Lord ve Novick); laboratuvardaki yapı puanı η ile karıştırılmaz.

B. Sistematik ve tesadüfi hata: öğretilecek kesin ifade
- B.0 "Sistematik hata güvenirliği düşürmez" ifadesi yalnızca her tekrarda her kişiye aynı biçimde uygulanan toplamsal bir sabit veya ortak doğrusal dönüşüm ($X^*=a+wX$, $w\neq0$) için tam olarak doğrudur. Türkçe ders notlarındaki "sistematik hata" tanımı çoğunlukla bu ikinci durumdur (kurala bağlı, orantılı hata). İfade üç açıdan yanıltıcıdır:
- B.1 Kişiye özgü kararlı sistematik hata katsayıyı değiştirir. Gerçek puana katılır; $\sigma_U^2+2\sigma_{\eta U}>0$ ise güvenirliği yükseltir, $<0$ ise düşürür, $=0$ ise değiştirmez. $U$, η ile ilişkisizse yapıyla korelasyonu düşürür. Bu, "güvenirlik geçerlik değildir" ilkesinin en açık gösterimidir (Messick'in yapıyla ilgisiz varyansı).
- B.2 Sabit hata güvenirliği değiştirmez ama mutlak yorumlara (kesme puanında geçme oranı, ölçüt dayanaklı kararlar, norm karşılaştırmaları) zarar verir. Hiçbir tekrar temelli katsayı onu yakalayamaz; yalnızca dış bir başvuru (kalibrasyon, eşitleme, standart belirleme, ölçüt) yakalar.
- B.3 Bir bileşenin sistematik mi tesadüfi mi olduğu bileşenin kendi özelliği değil, tekrar tasarımının ve genellenen koşulların özelliğidir. Bir oturum içinde kararlı, oturumlar arasında değişen bir bileşen (ruh hali, yorgunluk) α için "gerçek", test-tekrar test için "hata"dır.
- B.4 "Yalnızca tesadüfi hata güvenirliği etkiler" cümlesi KTK tanımlarının doğrudan sonucudur (tanım gereği doğrudur), deneysel bir bulgu değildir; uygulama bunu böyle söyler.
- B.5 Sabit hatanın güvenirliği değiştirmemesinin nedeni "düzeltilebilir" olması değildir; varyans ve kovaryansın yalnızca ortalamadan uzaklıklara bakmasıdır. Kaynağı bilinmeyen, düzeltilemeyen bir sabit de güvenirliği değiştirmez.
- B.6 Maddeye özgü, tüm kişiler için aynı sabit: $\Sigma$ ve α değişmez; madde ortalamaları ve Φ değişir.
- B.7 Maddeye özgü çarpımsal ağırlıklar farklı bir bileşik tanımlar ve genellikle güvenirliği değiştirir.
- B.8 Doğrusal olmayan dönüşümler (harf notu bantları, geçti/kaldı, tavan ve taban etkisi) değişmezlik kapsamında değildir ve genellikle güvenirliği düşürür.
- B.9 Sabit kayma yalnızca bir ölçmede: Pearson $r$ ve bağıl G katsayısı değişmez; mutlak uyum indeksleri (ICC(A,·), Φ) düşer.
- B.10 Puanlayıcı ve gün etkileri: tüm ölçme nesnelerinde aynı olan sistematik etki bağıl (norma dayalı) güvenirliği etkilemez; örneklenen koşullar arasında değişiyorsa mutlak kararlar için Φ katsayısını etkiler; kişiler farklı koşullarla karşılaştığı için kişiden kişiye değişen etki her ikisi için de hatadır. Çaprazlanmış desende puanlayıcı katılığı yalnızca mutlak hataya girer; iç içe desende bağıl hataya da girer; puanlayıcı×kişi etkileşimi her zaman bağıl hatadır. Bir yön sabit kabul edilirse (bu puanlayıcıların ötesine genellemiyorsak) onun kişiyle etkileşimi evren puanı varyansına katılır.
- B.11 Alt gruba özgü kararlı kayma havuzlanmış güvenirliği değiştirir (genellikle yükseltir), grup içi güvenirliği değiştirmez; bu bir adillik ve ölçme değişmezliği (DMF; ölçek, yani skaler, değişmezlik) sorunudur. Bir alt grubun hata varyansı daha büyükse tek bir havuzlanmış ÖSH her iki grubun kesinliğini de yanlış verir.
- B.12 İlişkili hatalar (madde demeti, ortak okuma parçası, ters kodlu maddelerin yöntem etkisi, oturum içi geçici durumlar): diğer koşullar sabitken pozitif hata kovaryansları α'yı yükseltir, negatifler düşürür. Ortak bileşen kararlıysa KTK gerçek puanıdır ve KTK hataları ilişkisiz kalır; popülasyon α'sı yine KTK güvenirliğinin alt sınırıdır ama ortak yapı için güvenirliği (ω) abartabilir. α'nın ω'yı aşıp aşmadığı yüklerin eşitliğine bağlıdır (M8). Ortak bileşen yinelenmiyorsa KTK hatasıdır ve α KTK güvenirliğini de abartabilir.
- B.13 Sabit hata örneği olarak puanlama yazılımı hatası ve ders notlarındaki "öğretmenin her kâğıda 5 puan fazla vermesi" örneği kullanılır. Gerçekten sabit hatalar eğitimde nadirdir; bu da söylenir.

C. Tesadüfi hatanın kestirimi
- C.1 Bireysel $E_p=X_p-T_p$ gözlenemez, çünkü $T_p$ bilinmez. Yalnızca popülasyon varyansı (veya bir model altında koşullu varyansı) ve yalnızca hataları ilişkisiz en az iki tekrardan kestirilebilir: $\sigma_{XX'}=\sigma_T^2$, $\sigma_E^2=\sigma_X^2-\sigma_{XX'}$, $\sigma^2_{X-X'}=2\sigma_E^2$ (paralel ölçmelerde). Sonlu sayıda tekrardan hesaplanan $X_j-\hat T$ değerleri artıklardır, hata puanları değildir.
- C.2 Çok maddede her madde çifti küçük bir tekrardır; bilgiyi köşegen dışı kovaryanslar ve kişi×madde artıkları taşır. Kavramsal olarak $\sigma_E^2$, kişilerin eğilim dağılımı varyanslarının ortalamasıdır; simülasyonda $T$ bilindiği için bu doğrudan gösterilir (M3). Fark yolu, kovaryans yolu, köşegen doldurma ve ANOVA aynı hata varyansına varır (M5, M9).
- C.3 Katsayı ve tekrar eşlemesi: test-tekrar test (aynı form, iki gün; hata: geçici; gerçek: maddeye özgü); eşdeğer formlar (iki form, bir gün; hata: içerik örneklemesi; gerçek: geçici); gecikmeli eşdeğer formlar (ikisi de hata); yarıya bölme ve α, KR-20, $L_2$, ω (bir oturum; hata: maddeye özgü ve rastgele; gerçek: geçici, hız, ortak yöntem); puanlayıcılar arası (desenin belirttiği gibi; bkz. M9).

D. Katsayılar ve yorum
- D.1 α: popülasyon α'sı, hatalar ilişkisizse, güvenirliğin alt sınırıdır; ilişkisiz hatalar altında α = ρ ancak ve ancak özünde tau eşdeğerlikte. İlişkili hatalarla abartabilir. Tek boyutluluk göstergesi değildir. Örneklem α'sı popülasyon α'sı çevresinde dalgalanır, güvenirliği aşabilir ve negatif olabilir (ör. ters anahtarlanmış maddeler). "α alt sınırdır" cümlesini hiçbir yerde ilişkisiz hata koşulu olmadan yazma.
- D.2 $k$ çiftken tüm eşit bölmelerin Flanagan-Rulon ortalaması α'ya eşittir; Spearman-Brown ortalaması eşit değildir. $k$ tekken $(k-1)/2$ ve $(k+1)/2$ maddelik bölmelerin Flanagan-Rulon ortalaması $\alpha\,(k^2-1)/k^2$'dir.
- D.3 Hoyt, eksiksiz veride ve tutarlı paydada α'ya tam eşittir.
- D.4 $\mathbb E\rho^2(n_i')$ Spearman-Brown eğrisidir; çaprazlanmış desende $\Phi\le\mathbb E\rho^2$.
- D.5 ÖSH bir popülasyon ortalamasıdır ve puan düzeyine göre değişebilir. $X\pm1{,}96\,\text{ÖSH}$ için "%95", normal hata varsayımıyla ve bu kişinin koşullu hata standart sapması ÖSH'ye eşitse, aynı kişinin tekrarlanan ölçmelerinde bu aralıkların yaklaşık %95'inin $T_p$'yi kapsaması demektir. Aksi hâlde kapsama kişiden kişiye değişir. Tek bir aralık için "%95 olasılıkla gerçek puanı içerir" deme. Kelley aralığı farklı bir soruyu yanıtlar ve başvuru grubunun ortalamasına doğru çeker; bu yüzden başvuru grubuna bağlıdır ve adillik sonucu vardır.
- D.6 .70 evrensel bir eşik değildir; gereken düzey kullanım amacına bağlıdır (grup araştırması ile yüksek riskli bireysel karar farklıdır). Trafik ışığı renklendirmesi veya ".70 = iyi" etiketi kullanma. Çok yüksek α fazlalığa ve daralmış yapıya işaret edebilir (Loevinger'in zayıflama paradoksu).
- D.7 $\rho_{XY}\le\sqrt{\rho_{XX'}\rho_{YY'}}\le\sqrt{\rho_{XX'}}$; yapıyla korelasyon için tavan $\sqrt{\rho_{XX'}}$'dır.
- D.8 Örneklem büyüklüğü $\hat\rho$'nun kesinliğini etkiler, parametrenin kendisini etkilemez.
- D.9 Geçerlik bir katsayı değildir; puan yorumlarının kanıtla desteklenme derecesidir (AERA, APA ve NCME, 2014; Messick, 1989). $\rho_{X\eta}$ yalnızca simülasyonda görülebilen bir kanıt türüdür.

E. Yanılgılar ve doğru ifadeleri (M10 ve TGA çeldiricilerinin kaynağı)
- Y1 "Güvenirlik testin özelliğidir." Doğrusu: belirli bir tekrar tasarımı altında belirli bir popülasyondaki puanların özelliğidir.
- Y2 "Sistematik hata güvenirliği hiç etkilemez, bu yüzden zararsızdır." Doğrusu: B bölümü.
- Y3 "Tesadüfi hata birbirini götürür, önemsizdir." Doğrusu: çok kişide grup ortalamasında ortalanır ve kovaryansta ortalamada götürülür; bireysel puanda götürülmez, gözlenen varyansı şişirir ve korelasyonları zayıflatır.
- Y4 "Her kişinin hata puanını hesaplayabiliriz." Doğrusu: C bölümü; hesaplanan değerler artıklardır.
- Y5 "α güvenirliğin kendisidir." Doğrusu: D.1.
- Y6 "Yüksek α testin tek boyutlu olduğunu gösterir." Doğrusu: göstermez (M8, iki blok).
- Y7 "Bütün güvenirlik katsayıları aynı şeyi kestirir." Doğrusu: farklı kaynakları hata sayarlar ve birbirinin yerine kullanılamazlar.
- Y8 "ρ = .80, her kişinin puanının %80'i gerçektir demektir." Doğrusu: bu popülasyonda gözlenen varyansın %80'i gerçek varyanstır; bireyler hakkında bir ifade değildir.
- Y9 "ÖSH herkes için aynıdır ve $X\pm1{,}96\,$ÖSH gerçek puanı %95 olasılıkla içerir." Doğrusu: D.5.
- Y10 "Madde eklemek güvenirliği her zaman artırır." Doğrusu: Spearman-Brown artışı ancak eklenen maddeler paralelse doğru yordar; paralel olmayan maddeler güvenirliği artırabilir de düşürebilir de; yapıyla zayıf ilişkili maddeler α'yı düşürebilir (M7, 5. madde).
- Y11 "Daha yüksek her zaman daha iyidir; α ≥ .95 idealdir." Doğrusu: zayıflama paradoksu; amaç belirler.
- Y12 "Nunnally .70'i evrensel eşik olarak koydu." Doğrusu: gereken düzeyi amaca bağladı (Lance, Butts ve Michels, 2006).
- Y13 "Güvenilir test geçerlidir." Doğrusu: güvenirlik gerekli ama yeterli değildir; kararlı yapıyla ilgisiz varyans güvenirliği yükseltir, yapıyla korelasyonu düşürür.
- Y14 "İki uygulama arasındaki korelasyon her zaman güvenirliktir." Doğrusu: yalnızca paralel ölçmelerde; gerçek değişim düşürür, bellek yükseltir.
- Y15 "α 0 ile 1 arasındadır ve yarıya bölme katsayısı tek bir sayıdır." Doğrusu: örneklem α'sı negatif olabilir; yarıya bölme değeri bölmeye bağlıdır.
- Y16 "Sabit hata düzeltilebilir olduğu için güvenirliği etkilemez." Doğrusu: B.5.

F. Kaynaklar paneli yalnızca şu listeden atıf yapar ve "yayın öncesi künyeler doğrulanacaktır" notunu gösterir: AERA, APA ve NCME (2014); Baykul, Eğitimde ve psikolojide ölçme: Klasik test teorisi ve uygulaması; Brennan (2001a), Generalizability theory; Brennan (2001b), Journal of Educational Measurement, 38(4), 295-317; Brennan ve Kane (1977); Brown (1910); Crocker ve Algina (1986); Cronbach (1951); Cronbach, Gleser, Nanda ve Rajaratnam (1972); Dudek (1979); Gulliksen (1950); Guttman (1945); Hoyt (1941); Kelley (1927; künye doğrulanacak); Kuder ve Richardson (1937); Lance, Butts ve Michels (2006); Loevinger (1954); Lord (1952); Lord ve Novick (1968); McDonald (1999); McGraw ve Wong (1996); McNeish (2018); Messick (1989); Novick ve Lewis (1967); Nunnally (1978); Raykov (2001); Rulon (1939); Schmidt, Le ve Ilies (2003); Shavelson ve Webb (1991); Shrout ve Fleiss (1979); Sijtsma (2009); Spearman (1904); Spearman (1910); Thompson ve Vacha-Haase (2000).

G. Etki haritası (her satır bir manipülasyondur; diğer her şey sabittir; popülasyon düzeyinde). Sütunlar: Ortalama | Gözlenen varyans | Güvenirlik | ÖSH | Sabit kesme puanında kararlar | Yapıyla korelasyon $\rho_{X\eta}$ (yalnızca simülasyonda). "~" koşula bağlı demektir; hücrede koşul yazılır.
- G.1 Gerçek farklar artar ($\sigma_T$ veya $\sigma_\eta$ ↑): = | ↑ | ↑ | = | ~ (kesmenin ortalamaya göre yerine bağlı) | ↑ (M3)
- G.2 Tesadüfi hata artar ($\sigma_E$ ↑): = | ↑ | ↓ | ↑ | ~ | ↓ (M3, M4)
- G.3 Sabit hata $c>0$, herkese ve her tekrarda: ↑ | = | = | = | değişir | = (M4)
- G.4 Kurala bağlı hata $X^*=wX$, $w>1$: ↑ | ↑ | = | ↑ | değişir | = (M4)
- G.5 Kişiye özgü kararlı yanlılık $B$ ($B\perp\eta$): = | ↑ | ↑ | = | ~ | ↓ (M4)
- G.6 Aynı yanlılık tekrardan tekrara değişirse: = | ↑ | ↓ | ↑ | ~ | ↓ (M4)
- G.7 Alt gruba özgü kararlı kayma $\gamma>0$ ($g\perp\eta$): ↑ | ↑ | havuzlanmış ↑, grup içi = | = | değişir | ↓; gözlenen grup farkı $\gamma$ kadar yanlı (M4 uzman)
- G.8 Madde sayısı artar (paralel maddeler, madde ortalaması ölçeği): = | ↓ | ↑ | ↓ | ~ | ↑ (M6, M7)
- G.9 Grup türdeşleşir ($\sigma_T$ ↓, hata aynı): = | ↓ | ↓ | = | ~ | ↓ (M3)
- G.10 Sabit eklenirken tavan etkisi (üst sınırda kesme), eklemeden önceki duruma göre: ↑ ($c$'den az) | genellikle ↓ | genellikle ↓ (Sabit Veri A'da .80'den .7427'ye) | ~ | değişir | genellikle ↓ (M4 uzman)
- G.11 Bellek etkisi (test-tekrar test, ilişkili hatalar): güvenirlik kestirimi ↑ (fazla kestirir); diğer sütunlar = (M5)
- G.12 Farklı gerçek değişim (test-tekrar test): güvenirlik kestirimi ↓ (az kestirir) (M5)
- G.13 Sabit kayma yalnızca ikinci ölçmede: ikinci ölçmenin ortalaması ↑ | = | $r$ =, mutlak uyum ↓ | = | değişir | = (M4 uzman)
</icerik_dogrulugu>

<teknik_kisitlar>
- Skill'ler: Sayfayı yazmadan önce `artifact-design` skill'ini yükle ve sayfa sözleşmesine uy. Dışa aktarma veya olay kaydı için bir yetenek bildirmeden önce `artifact-capabilities` skill'ini yükle. Artifact aracı ilk yayında `quickstart` isterse `intent: "other"` ile çalıştır. Bu skill'lerde "bir kez bak, yayımla, test döngüsü kurma" türünden bir varsayılan varsa bu proje için geçersizdir: aşağıdaki sayısal ve tarayıcı testlerini kullanıcı açıkça istemiştir. Tüm ekran görüntülerini kaydet; aşama başına en fazla 6 tanesine (o aşamanın modülleri, 390 px, açık ve koyu) bak.
- Mimari: kaynak depoda kalır, derlenmiş sayfa yayımlanır.
  - `src/core.js`: yalnızca saf fonksiyonlar; tarayıcıda `globalThis.RelCore`, Node'da `module.exports`. Ekrandaki her sayı ve formüldeki her canlı değer bu modülden gelir. `RelCore.derive(state)` ekrandaki her canlı niceliği kimliğiyle içeren bir sözlük döndürür. `RelCore.project(state, view)` görünüme göre gizli kümeyi ayıklar.
  - `src/app.js`: tek bir `state` nesnesi ve `render(state)`; ekrandaki her sayı durumdan yeniden hesaplanır. Sayfa test kancası sunar: `window.RelLab = {getState(), setState(patch), applyPreset(id), listPresets(), setView('real'|'backstage')}`. Ekrandaki her canlı sayı `data-q="<nicelik-kimliği>"` taşır; her görsel öğe gerektiğinde `data-role` (T, E, eta, B, X ...) taşır.
  - `src/content.tr.js`: bütün arayüz metinleri, formül TeX kaynakları, kontrol soruları ve yanıt anahtarları anahtarlarla; etkileşimli ve durağan sürüm bu tek dosyadan üretilir.
  - `src/styles.css`, `build.mjs`. Derleme üç çıktı üretir: `dist/index.html` (Artifact için iskeletsiz parça: doctype, html, head, body etiketi yok; ilk satırlar `<title>Güvenirlik Laboratuvarı</title>` ve kısa bir `<style>`); `dist/static.html` (durağan sürüm, aynı biçimde); `dist/standalone/` (bağımsız barındırma için doctype'lı tam belgeler). Her şey satır içidir. `<title>` dosyanın ilk 8 KB'ı içinde kalır.
- Dış betikler yalnızca `cdnjs.cloudflare.com` veya `cdn.jsdelivr.net/npm/` adresinden ve tam sürüm numarası sabitlenerek yüklenir. Stil sayfaları yalnızca Google Fonts'tan (latin-ext alt kümesi olan bir yazı tipi, gerçek bir yedek yığınla). Başka her şey satır içidir. Çerçeve kullanma. Grafikler için düz SVG, büyük $N$ saçılımları için Canvas; D3 isteğe bağlıdır ve sabit sürümlüdür. Artifact sayfasında `<a download>`, `fetch`, `XMLHttpRequest`, `alert`, `confirm`, `prompt` ve `window.print` kullanılmaz; sayfa sözleşmesine göre bunlar izleyici için çalışmaz.
- KaTeX: `https://cdn.jsdelivr.net/npm/katex@<sürüm>/dist/katex.min.js` adresinden sabit sürümle yüklenir. KaTeX CSS'i satır içidir; yazı tipleri CSS içinde yalnızca woff2 kaynakları olarak data URI'dir (woff ve ttf satırları silinir). Çıktı `htmlAndMathml`. Formül terimlerini `\htmlClass{t-hata}{\sigma^2_E}` ile etiketle; bunun için `trust: c => c.command === "\\htmlClass"` ve `strict: c => c === "htmlExtension" ? "ignore" : "warn"` ayarlarını kullan. `trust` olmadan KaTeX hata vermez, terimi sessizce kırmızı hata metni olarak basar. Durağan sürümde KaTeX Node'da aynı ayarlarla `renderToString` ile önceden işlenir.
- Sayısal kurallar: sözde rastgele sayı üreteci mulberry32; alt akış tohumları tohum ve bileşen adından türetilir; normal çekimler Box-Muller ile ve $u=0$ korumasıyla. Üretilen her puan $10^{-6}$'ya yuvarlanır (veya tam sayı puan kullanılır) ve özetler yuvarlanmış değerlerden alınır; böylece farklı tarayıcı motorlarında aynı tohum aynı veriyi verir. Varyans iki geçişli veya Welford ile hesaplanır ($\sum x^2-n\bar x^2$ biçimi büyük sabit ekleme testinde başarısız olur). `Math.random` hiçbir yerde kullanılmaz; tek istisna `session_id` için `crypto.randomUUID()`'dir. Arayüzde $N$ yaklaşık 30 ile 2000 arasındadır; M5(c) yakınsama panelinde $n=10$'a izin verilir; büyük $N$ yalnızca testlerdedir. Animasyon karesi başına en fazla bir yeniden çizim.
- Türkçe ayrıntılar: sayılar `Intl.NumberFormat('tr-TR')` ile; büyük harf dönüşümü `toLocaleUpperCase('tr-TR')` ile; kaydırıcı `aria-valuetext` değerleri de ondalık virgüllü ve Türkçedir ("Hata standart sapması: 5 puan").
- Sayfa başlığı `Güvenirlik Laboratuvarı`. Tema: açık ve koyu tema renk belirteçleri çıplak `:root` üzerinde tanımlanır; koyu tema hem `@media (prefers-color-scheme: dark)` içinde `:root:not([data-theme="light"])` korumasıyla hem `:root[data-theme="dark"]` altında yeniden tanımlanır ve iki koyu blokta da `color-scheme: dark` ayarlanır. `body` için açıkça bir arka plan belirteci. Renk körü dostu palet ve her kodlamada şekil veya desen yedeği; metin karşıtlığı en az 4.5:1.
- Telefon genişliği: 600 px ve altında tek sütun (görsel, denetimler, katlanabilir formül kartı); en az 16 px yan boşluk; sayfada yatay kaydırma yok; matrisler, ANOVA tabloları ve uzun denklemler kendi `overflow-x:auto` kutularında kayar.
- Erişilebilirlik: her fareyle üzerine gelme işlevinin dokunma ve klavye odağı karşılığı vardır; dokunma hedefleri en az 44 px; sürüklenebilir noktaların klavye alternatifi (seç, ok tuşu ±1, Shift+ok ±5); kaydırıcılar yerel range girdisi ve düzenlenebilir sayı kutusudur ve her birinin erişilebilir adı vardır; görünür klavye odağı; `prefers-reduced-motion` desteklenir; yeniden hesaplanan değerler bırakma anında gecikmeli bir `aria-live` bölgesiyle duyurulur; her grafikte gerçek bir HTML tablosu açan "Tabloyu göster" vardır.
- `localStorage` yalnızca kolaylıklar içindir (son açık modül, TGA tahminleri, etki haritası dolulukları); her okuma ve yazma try/catch içindedir ve sayfa onsuz da doğru çalışır.
- Ortam: önceki bir bulut oturumunda Node 22 ve Playwright önceden kuruluydu (`/opt/node22/lib/node_modules/playwright`, tarayıcılar `/opt/pw-browsers`), CDN adresleri vekil sunucu üzerinden 403 döndü, npm kayıt deposu çalıştı. Bunu varsayma, kontrol et.
- Test sarmalayıcısı: testler `dist/index.html` dosyasını, `artifact-design` sayfa sözleşmesindeki iskeleti ve sıfırlamayı birebir kopyalayan bir sarmalayıcı içinde yükler (açık `color-scheme` ve `[hidden]{display:none!important}` dahil). Sarmalayıcı izin listesine uyan bir `<meta http-equiv="Content-Security-Policy">` ekler: `script-src 'unsafe-inline' https://cdnjs.cloudflare.com https://cdn.jsdelivr.net/npm/; style-src 'unsafe-inline' https://fonts.googleapis.com; font-src data: https://fonts.gstatic.com; img-src data: blob:; connect-src 'none'`. KaTeX'in aynı sürümü npm'den kurulur ve Playwright `page.route` yalnızca yukarıdaki tam KaTeX adresini yerel dosyaya yönlendirir; test rotanın çağrıldığını doğrular. Google Fonts istekleri boş 200 yanıtla karşılanır ve bu `PROGRESS.md`'ye yazılır.
- Maliyet: varsayılan çaba düzeyinde çalış; son gözden geçirici dışında alt ajan kullanma. Aynı sorunu iki kez düzeltip yine çözemezsen dur ve raporla.
</teknik_kisitlar>

<arastirma_hazirligi>
- Durağan sürüm, eşdeğerlik tablosu:
  - Her iki koşulda aynı: metin, formüller, sayılar, TGA tahmin girişi ve "Sonucu göster" düğmesi, kontrol soruları ve geri bildirimleri, M10, etki haritası (durağanda tamamlanmış olarak), sözlük ve kaynaklar.
  - Yalnızca etkileşimli sürümde: kaydırıcılar, sürükleme, veri düzenleme ve yapıştırma, yarıya bölme gezgini, uzman modu, "Yeni sınıf çek", toplu çekimler.
  - Formül-görsel vurgusu: varsayılan olarak iki sürümde de vardır (durağanda terim düğmeleri durağan şekildeki öğeyi vurgular), çünkü karşılaştırılan etken manipülasyondur, bağlantılı gösterim değildir. Kullanıcı Aşama 5a'da değiştirebilir.
  - Üretim: durağan SVG'ler derleme sırasında Playwright ile `index.html`'e her ön ayar uygulanıp ilgili öğenin `outerHTML`'i alınarak üretilir. Durağan şekiller, TGA kartlarının hedeflediği ön ayar değerlerindedir; aynı TGA soruları bu şekillerden yanıtlanır.
- Koşul seçimi: sayfa sözleşmesine göre sorgu dizesi sayfaya hiç ulaşmaz; yalnızca çıplak bir `#belirteç` (harf, rakam, `.`, `_`, `~`, `-`) `location.hash`'e ulaşır. Bu yüzden her koşul ayrı ve dondurulmuş bir Artifact olarak yayımlanır. `cond` derleme bayrağıyla (`COND=etkilesimli|duragan`) gömülür ve sayfada görünmez. `tools/assign.mjs`, şube içinde bloklu ve tohumlu bir atama listesi (katılımcı kodu, koşul adresi) üretir. İsteğe bağlı `TGA=0` bayrağı 2×2 desen içindir (sunum × TGA). Durağan sürümü yalnızca kullanıcı onay verdikten sonra yayımla.
- Sürüm etiketi: `vX.Y.Z`, derleme tarihi, `content_hash` (özet yer tutucusu boşaltılmış dist dosyasının SHA-256 özetinin ilk 12 karakteri) ve `src_hash` (`src/` altındaki tüm dosyaların birleşik özeti) altbilgide, her dışa aktarımda ve her kayıt satırında bulunur. `CHANGELOG.md` tutulur. Veri toplama sırasında bir yayın asla güncellenmez; her çalışma kendi dondurulmuş kopyasını kullanır.
- Dışa aktarma: tek bir `exportAdapter` arayüzünden geçer. Artifact'ta `downloads` yeteneği bildirilir (`capabilities: {downloads: true}`) ve `claude.use('downloads')` ile dosya sunulur; sonuç `null` ise ya da izleyici reddederse "Panoya kopyala" (tıklama işleyicisinde `navigator.clipboard.writeText`, reddedilirse seçilebilir metin kutusu) kullanılır. Bağımsız sürümde olağan indirme kullanılabilir. Simüle edilen veri matrisi CSV olarak dışa aktarılır (öğrenciler jamovi, SPSS veya R ile doğrulayabilsin diye). CSV biçimi: UTF-8 (BOM'lu), alan ayırıcı virgül, ondalık nokta, ASCII başlıklar; kod kitabı alanları Türkçe açıklar. `RESEARCH.md` her yol için herkese açık bağlantıyla gelen izleyicide çalışıp çalışmadığını "kullanıcı tarafından doğrulanacak" diye işaretler.
- Anonim olay kaydı: Artifact sürümü öğretim ve pilot içindir; kayıt için Artifact veritabanı (`db`) kullanılmaz, çünkü izleyiciler ve dış bağlantı ziyaretçileri yazamaz ve kişiye özel yollar sahibinden bile gizlidir. Kayıt kodu yalnızca `RESEARCH=1` derleme bayrağıyla derlenir ve varsayılan olarak kapalıdır. Gerçek veri toplama için `dist/standalone/` araştırmacının denetlediği bir sunucuda barındırılır ve kayıtları derleme zamanında verilen `LOG_ENDPOINT` adresine POST eder (varsayılan boş, yani kapalı). Yedek yol, katılımcının `exportAdapter` ile dışa aktardığı JSON/CSV dosyasıdır; `localStorage` yalnızca ara bellektir. Kurallar:
  - Önce sayfa içinde bir onam ekranı gelir (metin yer tutucudur; etik kurul onaylı metni kullanıcı verecek); onam olmadan hiçbir şey kaydedilmez. Onam ekranında "yerel arabelleği sil" seçeneği vardır.
  - Katılımcı kodu kâğıt üzerinde dağıtılan 6 karakterli rastgele bir kod ve bir Damm kontrol basamağıdır; geçersiz kod reddedilir. Ad, öğrenci numarası, e-posta, IP adresi, user-agent veya serbest metin kaydedilmez.
  - Şema: `pid, cond, version, content_hash, src_hash, seed, session_id, ts_iso, t_rel_ms, event, module, param, old, new, value, device_class`. `session_id` `crypto.randomUUID()` ile üretilir. `device_class` yalnızca görünüm genişliğinden türetilir (<600 telefon, 600-1024 tablet, >1024 masaüstü).
  - Olaylar: kaydırıcılar bırakma anında tek satır; TGA yön, güven ve gerekçe kimlikleri ile sonuçları; modül giriş ve çıkışı; 60 saniyelik boşta kalma eşiği.
  - Kullanıcı açıkça istemedikçe kaydı açık bir sürüm yayımlama. Etik kurul onayı ve KVKK uyumu kullanıcının sorumluluğundadır; `RESEARCH.md` hangi verinin toplandığını, nerede durduğunu ve kimin okuyabildiğini listeler.
- Denetim izi: `PROGRESS.md` (bkz. `<devam_protokolu>`).
</arastirma_hazirligi>

<sabit_veri>
Bu değerler kesin rasyonel aritmetikle ve birden çok yoldan doğrulanmıştır. Testlerde bunları kullan; değiştirme. Kesir veya kök olarak verilenler kesin değerdir; ondalık verilenler belirtilen basamağa yuvarlanmıştır.

Sabit Veri A: 5 puanlık dereceli puanlama anahtarıyla (rubrik) puanlanan 4 açık uçlu soru, 6 öğrenci. Satırlar P1-P6, sütunlar madde 1-4, son sütun $Y$:
P1: 1, 2, 1, 4 | 8
P2: 3, 4, 5, 5 | 17
P3: 1, 1, 3, 2 | 7
P4: 3, 4, 5, 3 | 15
P5: 3, 2, 2, 2 | 9
P6: 4, 2, 5, 5 | 16
- Madde ortalamaları 2,5; 2,5; 3,5; 3,5. Genel ortalama 3; $\bar Y=12$.
- $n-1$ ile: madde varyansları 3/2; 3/2; 31/10; 19/10 (toplam 8); $s_Y^2=20$; $\hat\alpha=\frac43(1-\frac{8}{20})=4/5$. $n$ ile: toplam 20/3, $\hat\sigma_Y^2=50/3$, aynı α.
- $S=\begin{pmatrix}1{,}5&0{,}7&1{,}5&0{,}7\\0{,}7&1{,}5&1{,}3&0{,}7\\1{,}5&1{,}3&3{,}1&1{,}1\\0{,}7&0{,}7&1{,}1&1{,}9\end{pmatrix}$; $\operatorname{tr}S=8$; köşegen dışı toplam 12; $\mathbf 1^{\mathsf T}S\mathbf 1=20$; $\bar s_{ij}=1$; $k^2\bar s_{ij}/s_Y^2=16/20$. Köşegen doldurma: toplamın gerçek varyansı 16, hata varyansı 4; madde hata kalanları 0,5; 0,5; 2,1; 0,9 (toplam 4).
- Korelasyonlar: $r_{12}=.4667$, $r_{13}=.6956$, $r_{14}=.4146$, $r_{23}=.6029$, $r_{24}=.4146$, $r_{34}=.4532$; $\bar r=.5080$; $\alpha_{std}=.8050$.
- ANOVA: kişi etkileri −1; 1,25; −1,25; 0,75; −0,75; 1. Madde etkileri −0,5; −0,5; 0,5; 0,5. $KT_p=25$, $KT_i=6$, $KT_{art}=15$, $KT_T=46$; sd 5, 3, 15; $KO_p=5$, $KO_i=2$, $KO_{art}=1$; Hoyt $=1-1/5=4/5$.
- Varyans bileşenleri: $\hat\sigma_p^2=1$, $\hat\sigma_i^2=1/6$, $\hat\sigma^2_{pi,e}=1$. $\mathbb E\rho^2=4/5$; $\Phi=24/31$.
- K çalışması ($n_i'$: $\mathbb E\rho^2$ / Φ): 1: 1/2 / 6/13; 2: 2/3 / 12/19; 4: 4/5 / 24/31; 8: 8/9 / 48/55; 12: 12/13 / 72/79. $\mathbb E\rho^2$ sütunu Spearman-Brown ile özdeştir.
- ICC(C,1) = 1/2; ICC(A,k) = 24/31.
- Tek yönlü (iç içe) yeniden çözümleme, yalnızca uzman notu için: $KT_{içi}=21$, $KO_{içi}=7/6$, $\hat\sigma_p^2=23/24$, ICC(1,k) = 23/30.
- Yarıya bölme (bölme: $r_{hh}^2$ / $r_{hh}$ / SB / Flanagan-Rulon): (1,3)/(2,4): 19/48 / .6292 / .7724 / 19/25; (1,2)/(3,4): 49/88 / .7462 / .8547 / 21/25; (1,4)/(2,3): 25/54 / .6804 / .8098 / 4/5. (1,3)/(2,4) için yarı varyansları 38/5 ve 24/5, kovaryans 19/5. Flanagan-Rulon ortalaması 4/5 = α; SB ortalaması .8123 ≠ α.
- $L_1=3/5$; $L_2=.8101$.
- ÖSH $=\sqrt{20\times0{,}2}=2$; kestirimin standart hatası $\sqrt{3{,}2}\approx1{,}7889$. $X=18$ için $X\pm1{,}96\,$ÖSH $=[14{,}08;\ 21{,}92]$; Kelley $\hat T=0{,}8(18)+0{,}2(12)=16{,}8$, bant $[13{,}29;\ 20{,}31]$.
- Madde silinirse α: 93/127, 99/131, 9/13, 105/131 (≈ .7323, .7557, .6923, .8015). Düzeltilmiş madde-toplam $r$: .664, .609, .734, .501.
- Zayıf madde (Sabit Veri A5): 5. madde P1-P6 = 3, 3, 4, 1, 2, 5; ortalama 3, varyans 2, ilk dört maddenin toplamıyla kovaryansı 0 (düzeltilmiş madde-toplam $r=0$). Beş maddeyle α = 15/22; 5. madde silinince 4/5.
- Manipülasyonlar (α / Φ): her hücreye +2: 4/5 / 24/31. $2X+1$: 4/5 / 24/31, $s_Y^2=80$, ÖSH = 4. $1{,}1X$: 4/5, ÖSH = 2,2, $\bar Y=13{,}2$. Yalnızca 3. maddeye herkese +1: 4/5 / 16/23 ($\hat\sigma_i^2=3/4$). Yalnızca 3. maddeye +2: 4/5 / 24/41. Her hücreye $+10^6$: α 4/5. +1 ekleyip 5'te tavan kesmesi: α = 280/377 (negatif kontrol; değişmelidir). P2 ve P3'e madde başına kararlı +1: α = 76/91, Φ = 152/187. Yüksek puanlılara (P2, P4, P6) madde başına +1: α = 10/11. Düşük puanlılara (P1, P3, P5) madde başına +1: α = 2/7.
- Puanlayıcı görünümü (aynı veri, 6 kompozisyon × 4 puanlayıcı): çaprazlanmış K çalışmasında $\mathbb E\rho^2=4/5$, $\Phi=24/31$; tek puanlayıcı 1/2 / 6/13. İç içe K çalışması (çaprazlanmış G çalışması bileşenleriyle, $\sigma^2_{r,pr,e}=7/6$): $\mathbb E\rho^2=\Phi=24/31$. Veri iç içe ANOVA ile yeniden çözümlenmez.

M5 verisi: $X_1=10,12,14,16,18,20$; $X_2=11,11,15,14,19,20$ (iki eşdeğer form, 6 öğrenci).
- $\bar X_1=\bar X_2=15$; $\sum x_1^2=70$, $\sum x_2^2=74$, $\sum x_1x_2=68$; $r=68/\sqrt{5180}\approx.9448$.
- $n-1$ ile: $s_1^2=14$, $s_2^2=74/5$, $s_{12}=68/5$, $s_D^2=8/5$, $\hat\sigma_E^2=4/5$, ortalama $s_X^2=72/5$, $1-\hat\sigma_E^2/\bar s_X^2=17/18$. $n$ ile: $\hat\sigma_D^2=4/3$, $\hat\sigma_E^2=2/3$, ortalama varyans 12, aynı oran.
- Köşegen yolu: kalanlar 2/5 ve 6/5, ortalama 4/5.
- z kimliği: $\frac{1}{n-1}\sum z_1z_2=r\approx.9448$; $\frac{1}{n}\sum z_1z_2\approx.7873$ (yanlış; $r$ değildir).
- Mutlak uyum (M9 ANOVA yolu, negatif bileşen 0'a çekilerek): ICC(C,1) = 17/18; ICC(A,1) = 17/18. $X_2$'ye +5: ICC(C,1) = 17/18, ICC(A,1) = 408/803.
- $X_1$'e +2: $\bar D$ 0'dan 2'ye çıkar ($D=X_1-X_2$), $r$ değişmez.

Sabit Veri B: doğru/yanlış puanlanan 5 maddelik kısa sınav, 8 öğrenci:
P1: 1,1,1,1,1 | P2: 1,1,1,1,0 | P3: 1,1,1,0,1 | P4: 1,1,0,1,0 | P5: 1,0,1,0,0 | P6: 1,1,0,0,0 | P7: 0,1,0,0,0 | P8: 0,0,0,0,0
- $p$ = .75, .75, .50, .375, .25; $\sum p_iq_i=67/64$; $M=21/8$; $\hat\sigma_Y^2=159/64$.
- KR-20 = 115/159 (ANOVA yolu ve iki paydada $n-1$ kullanımı da aynı). KR-21 = 33/53 ≤ KR-20.
- Payda karışımı ($p_iq_i$ $n$ ile, $s_Y^2$ $n-1$ ile) yanlış olarak 4015/5088 ≈ .7891 verir.
- ÖSH$^2=11/16$. Lord koşullu ÖSH, $x=0..5$: 0; 1; $\sqrt{3/2}$; $\sqrt{3/2}$; 1; 0.
- 10 bölmenin ($2+3$ madde) Flanagan-Rulon ortalaması 184/265 = α·24/25.

Popülasyon değerleri (standart maddeler, $\psi_i=1-\lambda_i^2$; α / ω / $L_2$, 4 ondalık):
- λ = .625 ×4: .7194 / .7194 / .7194
- λ = .5 ×6: .6667 / .6667 / .6667
- λ = .8, .7, .6, .4: .7132 / .7267 / .7208
- λ = .9, .8, .3, .2: .5987 / .6667 / .6386
- λ = .9, .8, .3 (λ = .2 silinmiş): .6758 / .7326 / .7061
- λ = .625 ×4, $\psi_{12}=\psi_{34}=.2$: .7712 / .6588 / .7752 (ilişkili hatalarda ω $=(\sum\lambda)^2/\mathbf 1^{\mathsf T}\Sigma\mathbf 1$)
- λ = .9, .8, .3, .2, $\psi_{34}=.05$: .6087 / .6576 / .6447
- λ = .625 ×4, $\psi_{12}=-.15$: .6975 / .7452 / .6995
- İki blok, blok içi λ = .7, faktörler arası korelasyon $r_f$ (α / $\mathbf 1^{\mathsf T}\Sigma_T\mathbf 1/\mathbf 1^{\mathsf T}\Sigma\mathbf 1$): $k=6$: $r_f=0$ .5939 / .7424; .3: .7043 / .7893; .5: .7580 / .8122; 1: .8522 / .8522. $k=12$: $r_f=0$ .7747 / .8522.

Hata Laboratuvarı popülasyonu: $\sigma_\eta^2=1$, $\sigma_E^2=1/2$: $\rho=2/3$, $\rho_{X\eta}=\sqrt{2/3}$. $\sigma_B^2=1/2$ eklenince ($B\perp\eta$): $\rho=3/4$, $\rho_{X\eta}=\sqrt{1/2}$. Alt grup ($\pi=1/2$, $\gamma=1$, $g\perp\eta$): havuzlanmış $\rho=5/7$, grup içi $\rho=2/3$, $\rho_{X\eta}=2/\sqrt7$. Senaryo 3: $\sigma_\eta^2=60$, $\sigma_E^2=20$: $\rho=3/4$, $\rho_{X\eta}=\sqrt{3/4}$; $\sigma_B^2=20$ ile $\rho=4/5$, $\rho_{X\eta}=\sqrt{3/5}$.

Tekrar tasarımcısı popülasyonu ($\sigma_p^2=1$, $\sigma_{po}^2=.3$, $\sigma_{pi}^2=.8$, $\sigma_e^2=.6$, $k=10$): test-tekrar test 3/4; eşdeğer formlar ve α 65/72; gecikmeli eşdeğer formlar 25/36. $\sigma^2_{X_1-X_2}/2$: test-tekrar test 9/25, eşdeğer formlar 7/50, gecikmeli 11/25.

Binom kapsama ($k=20$, ÖSH = 2, bant $\pm3{,}92$): gerçek oran $\zeta=.5$ için 115957/131072 ≈ .8847; $\zeta=.95$ için .9974.

Diğer: $s_X^2=s_{X'}^2=20$ ve kovaryans 16 ise $\sigma_T^2=16$, $\sigma_E^2=4$, $\sigma^2_{X-X'}=8$. ÖSH$^2=4$ sabitken varyansı 10 olan grupta ρ = 3/5, 40 olan grupta 9/10. Zayıflama düzeltmesi $0{,}42/\sqrt{0{,}56}$. Spearman-Brown uzunluk çarpanı (.60'tan .80'e) 8/3. Eşit olmayan hata varyansları: $\rho_1=.8$, $\rho_2=.5$ için $r=\sqrt{0{,}4}$.
</sabit_veri>

<dogrulama>
Kurallar:
- Başlangıçta `tests.json` bütün test kimliklerini "bekliyor" olarak listeler. Durumlar: bekliyor | geçti | kaldı. `tests.json` yalnızca `npm test` çalıştırıcısı tarafından yazılır; elle düzenlenmez. Her kimlik tek bir iddiadır (A1.1, A1.2, ...).
- Tolerans: kesir, tam sayı veya kök olarak verilen değerlerde 1e-9 (aksi belirtilmedikçe); $d$ ondalık basamakla verilen değerlerde $0{,}5\cdot10^{-d}$ (4 basamak için 5e-5); simülasyon testlerinde belirtilen tolerans. Test kodu beklenen değeri spec'teki biçimiyle yazar (ör. `24/41`, `Math.sqrt(3/2)`).
- Testleri silmek, gevşetmek veya toleransları değiştirmek kabul edilemez. Değerleri gömme veya yalnızca belirli test girdileriyle çalışan çözümler üretme. Bir test yanlış görünüyorsa etrafından dolaşma; bunu söyle ve "Spec soruları"na yaz. Aşama 1 onaylandıktan sonra test dosyaları ve beklenen değerler yalnızca kullanıcı onayıyla değişir ve değişiklik `git diff` ile gösterilir.

Katman A: `core.js` üzerinde Node testleri.
- A1 Sabit Veri A: varyans, matris ve ANOVA yollarıyla α = 4/5, üç yol 1e-10 içinde eşit; KT 25 + 6 + 15 = 46; KO 5, 2, 1; bileşenler 1, 1/6, 1; $\mathbb E\rho^2=4/5$; Φ = 24/31; ÖSH = 2; hata varyansı dört yoldan 4 ("Üç yol" kartı: $s_Y^2-k^2\bar s_{ij}$, $k\,KO_{art}$, $s_Y^2(1-\hat\alpha)$, madde hata kalanları toplamı); toplamın gerçek varyansı 16.
- A2 Yarıya bölme: üç bölmenin Flanagan-Rulon ve Rulon değerleri (19/25, 21/25, 4/5) ve ortalaması = α; $r_{hh}^2$ değerleri 19/48, 49/88, 25/54; SB ortalaması .8123. Sabit Veri B'de 10 bölmenin Flanagan-Rulon ortalaması 184/265.
- A3 $L_1=3/5$, $L_2=.8101$, $L_2\ge\alpha$; $\alpha_{std}=.8050$; madde silinirse α (93/127, 99/131, 9/13, 105/131); düzeltilmiş madde-toplam $r$ (.664, .609, .734, .501); Sabit Veri A5: α = 15/22, 5. madde silinince 4/5, 5. maddenin düzeltilmiş madde-toplam $r$'si 0.
- A4 K çalışması tablosu (kesirler) ve $\mathbb E\rho^2(n')$ = Spearman-Brown (1e-12); Φ ≤ $\mathbb E\rho^2$; ICC(C,1) = 1/2; ICC(A,k) = 24/31; iç içe K çalışması 24/31; tek yönlü yeniden çözümleme $KO_{içi}=7/6$, $\hat\sigma_p^2=23/24$, ICC(1,k) = 23/30.
- A5 Değişmezlik: +2, $2X+1$, $1{,}1X$, 3. maddeye +1 ve $+10^6$ α'yı değiştirmez; Φ değerleri <sabit_veri> ile eşleşir (24/31, 24/31, 16/23; 3. maddeye +2 için 24/41); $2X+1$'de $s_Y^2=80$ ve ÖSH 4; $1{,}1X$'te ÖSH 2,2. M5 verisinde $X_1$'e +2: $\bar D$ 0'dan 2'ye, $r$ değişmez (1e-12). M5 verisinde $X_2$'ye +5: ICC(C,1) 17/18'de kalır, ICC(A,1) 17/18'den 408/803'e düşer.
- A6 Negatif kontrol: tavan kesmesi α'yı 280/377'ye değiştirir (değişmezlik testlerinin boş olmadığını kanıtlar).
- A7 Kişiye özgü yanlılık manipülasyonları: 76/91 (Φ 152/187), 10/11, 2/7.
- A8 Sabit Veri B: KR-20 = 115/159; $n-1$ anahtarında da 115/159; KR-21 = 33/53; ANOVA yolu KR-20'ye eşit; payda karışımı 4015/5088 verir ve `core.js` bu karışımı tespit eden bir işlev sunar; ÖSH$^2$ = 11/16; Lord koşullu ÖSH değerleri.
- A9 Popülasyon tablosu (5e-5), iki blok değerleri dahil. $\lambda_i\sim U(0{,}2;\,0{,}9)$, $k\in\{4,\dots,8\}$, köşegen Ψ, tohum 1-200: her durumda $\omega-\alpha>0$ ve $L_2\ge\alpha$. Eşit λ durumlarında (.625 ×4, .5 ×6) $|\omega-\alpha|<10^{-12}$.
- A10 Rastgele veri matrisleri: $n\in[5,60]$, $k\in[2,10]$, ortak faktörlü 0-5 tam sayı puanlar, tohum 1-200; $s_Y^2=0$ olan matrisler atlanır. Üç α yolu göreli 1e-10 içinde eşit; KT toplamı tutar; negatif bileşenler 0'a çekilir ve bayrak döner; $k$ çiftse ($k\le10$) tüm eşit bölmelerin Flanagan-Rulon ortalaması α'ya, $k$ tekse $\alpha(k^2-1)/k^2$'ye eşittir.
- A11 Simülasyon kehanetleri: $X=\sum_{i=1}^{5}(\eta+E_i)$, $\eta\sim N(0;1)$, $E_i\sim N(0;1)$ bağımsız; toplamın gerçek puanı $T_X=5\eta$; popülasyon ρ = 5/6. $N=20000$ ve tohum 1-5 için kestirilen α, paralel formlar $r$ ve $r^2_{XT_X}$ ρ'nun 0,01 içinde; $SD(X-T_X)$ $\sqrt5$'in %2 içinde; 5'ten 10 maddeye Spearman-Brown 10/11 = gerçek 10 madde değeri (1e-12). Her maddeye kişiye özgü kararlı yanlılık $B\sim N(0;\ \text{varyans }0{,}49)$, yani standart sapma 0,7, eklenince ($X=\sum_i(\eta+B+E_i)$) KTK güvenirliği 149/169'a yükselir, $r^2_{X\eta}$ 100/169'a düşer (popülasyon değerleri; simülasyon 0,01 içinde).
- A12 Hata Laboratuvarı ve tekrar tasarımcısı: popülasyon değerleri kesin; aynı parametrelerle $N=20000$ simülasyonda kestirimler 0,015 içinde; tekrar tasarımcısında $\sigma^2_{X_1-X_2}/2$ test-tekrar test için 9/25, eşdeğer formlar için 7/50, gecikmeli için 11/25 değerini %3 içinde kurtarır.
- A13 Belirlenimcilik (Node yarısı): aynı tohum aynı verinin aynı özetini verir; farklı tohum farklı veri verir; $B$'yi açıp kapamak $E$ dizilerini bit düzeyinde değiştirmez; $\sigma_E$'yi değiştirmek z dizisini değiştirmez; $n=10$ sınıfı $n=30$ sınıfının ilk 10 kişisidir.
- A14 Diğer: Spearman-Brown uzunluk çarpanı 8/3; ranj etkisi 3/5 ve 9/10; zayıflama $0{,}42/\sqrt{0{,}56}$; paralel form özdeşliği; eşit olmayan hata varyanslarında $r=\sqrt{\rho_1\rho_2}$; M5 verisinin tüm değerleri (iki payda, 2×2 matris, köşegen kalanları, z kimliği ve yanlış $1/n$ sürümü); binom kapsama değerleri.
- A15 Yanıt anahtarları: her kontrol sorusunun ve her TGA sonucunun sayısal yanıtı `content.tr.js`'den okunur, `core.js` ile yeniden hesaplanır ve eşleşir.
- A16 El hesabı dostu üretici: tohum 1-100 için her üretilen veri kümesi M7'deki kısıtları sağlar ve üç α yolu 1e-10 içinde eşittir.
- A17 Gizli küme: her modül ve her ön ayar için `project(state, 'real')` çıktısında gizli kümenin hiçbir anahtarı yoktur.

Katman B: Playwright ile 360, 390 ve 1280 px genişlikte, açık ve koyu temada, test sarmalayıcısı içinde:
- B1 Konsolda sıfır hata ve uyarı, sıfır sayfa hatası.
- B2 Sıfır `.katex-error` öğesi; görünür metinde ham `\frac` veya `$$` yok.
- B3 Yön testleri (popülasyon modunda veya belirgin bir değişimle): $\sigma_E$ artınca güvenirlik düşer; $\sigma_T$ artınca yükselir; $c$ değişince ortalama değişir, güvenirlik değişmez; kararlı yanlılık açılınca güvenirlik aynı kalır veya yükselir ve yapıyla korelasyon düşer; tavan etkisi güvenirliği değiştirir; $n_i'$ artınca $\mathbb E\rho^2$ ve Φ artar.
- B4 Her modülde her `data-q` öğesinin tr-TR ayrıştırılmış değeri `RelCore.derive(state)` değerinden, görüntülenen son basamağın yarısından az farklıdır. `data-q` öğesi olmayan modül bu testi geçemez. B4b: Sabit Veri A ön ayarı yüklüyken DOM sabit değerleri gösterir (α 0,80; KO 5, 2, 1; Φ 0,77; ÖSH 2).
- B5 Sızıntı testi: her modülde "Gerçek dünya" görünümünde hiçbir öğe `data-role` olarak T, E, eta, B veya g taşımaz ve hiçbir `data-q` gizli kümeye ait değildir.
- B6 Her genişlikte `document.documentElement.scrollWidth <= window.innerWidth`.
- B7 Her denetime klavyeyle ulaşılır ve her denetimin erişilebilir adı vardır; ok tuşu kaydırıcı değerini ve bağlı sayıyı değiştirir.
- B8 `prefers-reduced-motion` öykünmesinde animasyon yoktur.
- B9 Durağan sürümde range girdisi ve sürüklenebilir öğe yoktur; ön ayar durumlarındaki sayılar etkileşimli sürümle aynıdır.
- B10 Her modül, genişlik ve tema için bir ekran görüntüsü bilinen bir yola kaydedilir.
- B11 Formül anlık görüntüsü: `content.tr.js`'deki her formül kimliğinin TeX kaynağı, `\htmlClass{..}{X}` sarmalayıcıları $X$'e indirgendikten sonra, Aşama 0'da SPEC.md'den çıkarılıp kullanıcıya onaylatılan `formulas.expected.json` ile karakter düzeyinde eşittir.
- B12 Geometri: varyans bütçesi çubuğunda bölüt genişlik oranları ilgili varyans oranına 1 px içinde eşittir; M1'de kare alanları sapma karesiyle orantılıdır; M8'de köşegen ve köşegen dışı toplam etiketleri `RelCore` değerleridir.
- B13 "Ne değişti" satırlarındaki "arttı/azaldı/değişmedi" sözcüğü hesaplanan farkın işaretiyle eşleşir.
- B14 Etki haritası: her dolu hücrenin yönü, o satırın ön ayarında `RelCore` ile hesaplanan yönle eşleşir.
- B15 axe-core (npm'den): iki temada `color-contrast`, `aria-hidden-focus`, `label` ve `button-name` kurallarında sıfır ihlal.
- B16 Paket taraması: Artifact derlemesinde (`dist/index.html`, `dist/static.html`) `download=`, `fetch(`, `XMLHttpRequest`, `alert(`, `confirm(`, `prompt(`, `window.print` geçmez; `content.tr.js` ve derlenmiş sayfaların görünür metninde U+2014 yoktur; `dist/index.html`'in ilk 8 KB'ı `<title>Güvenirlik Laboratuvarı</title>` içerir; KaTeX rotası çağrılmıştır.
- B17 Belirlenimcilik (tarayıcı yarısı): aynı tohum Node ve Chromium'da aynı özeti verir. `/opt/pw-browsers` içinde Firefox veya WebKit varsa onlarda da çalışır; yoksa bu bir sınırlılık olarak raporlanır.

Katman L (olay kaydı; `RESEARCH=1` derlemesinde):
- L1 Onam yokken kayıt dizisi boştur.
- L2 Her satır şemaya uyar ve şema dışı alan yoktur.
- L3 Bir kaydırıcı sürüklemesi tek satır üretir.
- L4 Dışa aktarılan CSV geri okununca satırlar eşleşir.
- L5 `RESEARCH=0` derlemesinde kayıt kodu çalışmaz ve pakette yoktur.

Katman C: yalnızca sonda, bağlamı temiz tek bir gözden geçirici alt ajan yapıyı SPEC.md ile karşılaştırır; M4 uzlaştırma kartını B bölümüyle ve etki haritasını G bölümüyle ayrıca denetler. Ona "yalnızca doğruluğu veya belirtilen gereksinimleri etkileyen eksikleri işaretle" talimatını ver.
</dogrulama>

<asamalar>
Her aşama bir commit, bir etiket ve bir push ile kapanır; `CLAIMS.md` her aşamada güncellenir. "DUR" yazan yerde kullanıcı onayı gelmeden sonraki aşamaya geçme. Diğer yerlerde rutin kararları kendin ver.

- Aşama 0. Plan, kod yok. Gösterim tablosunu, modül listesini ve test listesini kendi sözlerinle yeniden yaz; `tests.json` ("bekliyor"), `PROGRESS.md` ve SPEC.md'den çıkarılmış `formulas.expected.json` dosyalarını oluştur; spec sorularını listele. `formulas.expected.json`'u kullanıcı onayına sun. DUR.
- Aşama 1. `core.js` ve Katman A testleri. Hepsi geçerse durmadan Aşama 2'ye geç. İki denemede geçmeyen test kalırsa DUR ve raporla.
- Aşama 2. Kabuk, M1-M3, bu modüllerin Katman B testleri, ilk Artifact yayını (kullanıcının pedagojik akışı ve görsel yönü görmesi için). DUR.
- Aşama 3. M4-M6 ve etki haritasının ilgili satırları. Aynı adrese yeniden yayın. DUR.
- Aşama 4. M7-M10. Aynı adrese yeniden yayın. DUR.
- Aşama 5a. Durağan sürüm, `dist/standalone/`, `exportAdapter` ve dışa aktarma, sürüm etiketi ve özetler. Formül-görsel vurgusunun durağan sürümde kalıp kalmayacağını kullanıcıya sor. DUR.
- Aşama 5b. Varsayılan olarak kapalı olay kaydı ve Katman L, `RESEARCH.md`, Türkçe metin gözden geçirmesi, erişilebilirlik (B15), Katman C gözden geçirmesi, aynı adrese yeniden yayın, son rapor. DUR.
</asamalar>

<raporlama>
Her DUR noktasında ve sonda şu raporu ver:
- Her test kimliği için bekliyor, geçti veya kaldı; çalıştırılan komut ve çıktısından bir alıntı. Geçmeyen testleri gizleme, yeniden adlandırma veya "neredeyse geçti" diye sunma.
- Ekran görüntüsü yolları ve Artifact adresi.
- Spec'ten sapmalar ve nedenleri; açık spec soruları.
- Bilinen sınırlılıklar, en az şunlar: laboratuvardaki α ve GK sonuçları idealleştirilmiş modellerden gelir; payda kuralı ve sonuçları; yalnızca $p\times i$ ve $p\times r$ desenleri; Türkçe metinlerin ve hata türleri tablosunun alan uzmanınca ve kullanılan ders kitabıyla karşılaştırılarak gözden geçirilmesi gerekir; kaynak künyeleri yayın öncesi doğrulanmalıdır; olay kaydı gerçek öğrencilerle ve etik onayla test edilmemiştir; `downloads` yeteneğinin herkese açık bağlantıyla gelen izleyicide çalışıp çalışmadığı ve Artifact bağlantısının hesap gerektirmeden açılıp açılmadığı bu oturumda doğrulanamaz, kullanıcı doğrulamalıdır; başka tarayıcı motorlarında belirlenimcilik yalnızca B17'de sınandığı kadardır.
- Rapordaki her iddiayı bu oturumdaki bir araç sonucuyla karşılaştır. Yalnızca kanıt gösterebildiğin işi bildir; henüz doğrulanmamış bir şey varsa bunu açıkça söyle.
</raporlama>

<belirsizlik_durumunda>
Spec sessizse en basit ve psikometrik olarak en temkinli seçeneği uygula, kararı `PROGRESS.md` içine yaz ve devam et. Kullanıcıyı yalnızca DUR noktalarında veya yalnızca onun verebileceği bir girdi gerektiğinde (etik onam metni, yayın izni, kayıt açma kararı, ders kitabı tanımları) beklet.
</belirsizlik_durumunda>
