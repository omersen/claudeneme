# Bölüm metinleri. Kullanıcının sayfalarındaki metin temel alınmış; düzeltmeler ve eklemeler işlenmiştir.
from tablolar import *

ONEM = """<section id="onem">
<h2>Önem ve amaç</h2>
<p>Kısa formlar katılımcı yükünü azaltır; ancak hangi maddelerin kaldığı, puanların güvenirliğini, faktör yapısını ve içeriğin temsilini doğrudan belirler. Dil modelleri madde seçimini yanıt verisi toplamadan, yalnız madde metinlerinden yapmaya olanak tanır; bu yolun psikometrik sonuçları ise az sayıda çalışmada incelenmiştir (ör. Kilmen ve Bulut, 2025).</p>
<p>Bu çalışmanın amacı, madde metinlerinden farklı hedeflerle yapılan seçimlerin nasıl kısa formlar ortaya çıkardığını ve bu formların psikometrik özelliklerini Depresyon Anksiyete Stres Ölçeği'nin 42 maddelik sürümü (DASS-42; Lovibond ve Lovibond, 1995) üzerinde incelemektir. İnceleme üç düzeyde yapılır: madde düzeyi (AS1), form düzeyi (AS2, AS3, AS4) ve bir alt boyuttan seçilebilecek bütün yedili formlar düzeyi (AS5). Çalışma betimsel ve karşılaştırmalıdır; nedensel bir düzenek sınanmaz.</p>
<p>Anlamsal seçim, maddelerin yanıt verisine bakılmadan yalnız metinlerinden yararlanılarak seçilmesidir. Madde metinleri bir dil modeliyle sayısal vektörlere (gömme, <i lang="en">embedding</i>) dönüştürülür; iki maddenin anlamca ne kadar benzediği bu vektörler arasındaki kosinüs benzerliğiyle ölçülür. Her alt boyutun 14 maddesinden yedisi aşağıdaki kurallardan biriyle seçilir. Kurallar Hazırlık 3.4'teki kodla uygulanır; formların maddeleri bu kodun çıktısıdır.</p>
<div class="tablo-kap"><table><thead><tr><th scope="col">Form</th><th scope="col">Seçim kuralı</th><th scope="col">Hedef</th></tr></thead><tbody>
<tr><th scope="row">""" + fh('PUB21') + """</th><td>Yayımlanmış DASS-21 (Lovibond ve Lovibond, 1995)</td><td>Karşılaştırma formu</td></tr>
<tr><th scope="row">""" + fh('MIN21') + """</th><td>Her alt boyutta ISI'si en düşük yedi madde</td><td>Anlamca en ayrışık maddeler</td></tr>
<tr><th scope="row">""" + fh('MAX21') + """</th><td>Her alt boyutta ISI'si en yüksek yedi madde</td><td>Anlamca en merkezî maddeler</td></tr>
<tr><th scope="row">""" + fh('COV21') + """</th><td>Her alt boyutta CL'si en küçük yedili küme</td><td>14 maddeye gömme uzayında en yakın küme</td></tr>
</tbody></table></div>
<dl class="tanim">
<dt>ISI</dt><dd>Madde anlamsal benzerlik indeksi: bir maddenin aynı alt boyuttaki diğer 13 maddeyle ortalama kosinüs benzerliği.</dd>
<dt>SB</dt><dd>Anlamsal çeşitlilik (<i lang="en">semantic breadth</i>): 1 eksi seçilen yedi maddenin 21 çiftinin ortalama kosinüs benzerliği. Yüksek SB daha çeşitli form demektir.</dd>
<dt>CL</dt><dd>Temsil kaybı (<i lang="en">coverage loss</i>): alt boyuttaki 14 maddenin her birinin en yakın seçili maddeye uzaklığının (1 eksi kosinüs) ortalaması. Seçili maddeler sıfır uzaklıkla katılır; bu yüzden elenen yedi maddenin ortalama uzaklığı 2 × CL'dir. Düşük CL, elenen maddelerin gömme uzayında seçilen maddelere daha yakın olduğu anlamına gelir.</dd>
<dt>CL<sub>b</sub></dt><dd>Bölünme temsil kaybı: 14 maddenin her birinin karşı yarıdaki en yakın maddeye ortalama uzaklığı. Bir küme ile tümleyeninde aynı değeri alır.</dd>
</dl>
</section>"""

def TEKRAR(mod):
    kayit = """<div class="tablo-kap"><table class="kayit"><tbody>
<tr><th scope="row">Tarih</th><td>28 Eylül 2026, saat 19.55 (UTC+3)</td></tr>
<tr><th scope="row">R ve platform</th><td>R 4.5.3 (2026-03-11); x86_64-conda-linux-gnu</td></tr>
<tr><th scope="row">Paketler</th><td>lavaan 0.7.2, semTools 0.5.9, mirt 1.47, ggplot2 4.0.3, digest 0.6.39, jsonlite 2.0.0</td></tr>
<tr><th scope="row">Rastgele sayı üreteci</th><td>Mersenne-Twister, Inversion, Rejection; tohumlar 20260905, 260905 ve 20260913 + b</td></tr>
<tr><th scope="row">Süre</th><td>2 dakika 28 saniye (Hazırlık 3.1'den Ek E'ye bütün kod; Ek C modelleri yeniden kestirir)</td></tr>
<tr><th scope="row">Vektör kaynağı</th><td><code>vektor_kaynagi = "arsiv"</code>; API çağrısı yapılmadı</td></tr>
<tr><th scope="row">Girdi özetleri (SHA-256)</th><td>veri 38d1707c…f3f5; vektörler fd765117…1955; ikisi de kayıtla aynı</td></tr>
<tr><th scope="row">Referans karşılaştırması</th><td>Kabul denetiminden geçmiş çalıştırmanın (279/279) 15 tablosuyla ortak 1.024 sayısal değer ile Ek B ve Ek C'deki 48 değer; en büyük mutlak fark 0</td></tr>
</tbody></table></div>"""
    p = ["""<section id="tekrar"><h2>Tekrarlanabilirlik</h2><p>Kodlar öğrenci paketinin klasöründe (<code>berkcan_dass42</code>) yukarıdan aşağıya sırayla çalıştırılır; her parça öncekilerin nesnelerini kullanır. Veri, gömme vektörleri ve referans örneklem bölmesi <code>girdiler/</code> klasöründen okunur; tablolar ve şekiller <code>html_ciktilari/</code> klasörüne yazılır. Tam çalıştırma yaklaşık iki buçuk dakika sürer.</p>
<div class="tablo-kap"><table><thead><tr><th scope="col">Adım</th><th scope="col">Tohum veya ayar</th><th scope="col">Etkisi</th></tr></thead><tbody>
<tr><th scope="row">Bütün adımlar</th><td><code>RNGkind("Mersenne-Twister", "Inversion", "Rejection")</code></td><td>R sürümleri arasında aynı üreteç</td></tr>
<tr><th scope="row">3.2 Örneklem seçimi</th><td><code>set.seed(20260905)</code></td><td>Uygun kayıtlardan 4.000 kayıt</td></tr>
<tr><th scope="row">3.2 Grup bölmesi</th><td><code>set.seed(260905)</code></td><td>2.000 kalibrasyon ve 2.000 değerlendirme; referans bölmeyle aynı olduğu denetlenir</td></tr>
<tr><th scope="row">AS3 Bootstrap</th><td><code>set.seed(20260913 + b)</code>, b = 1, …, 2.000</td><td>Her tekrar kendi tohumuyla başlar; sonuç tekrarların sırasından bağımsızdır</td></tr>
<tr><th scope="row">GRM, DFA, test bilgisi, gömme</th><td>yok</td><td>Rastgelelik içermez; aynı girdi aynı sonucu verir</td></tr>
</tbody></table></div>
<p>Kod, girdilerin değişmediğini SHA-256 özetleriyle denetler: ham veri <code>38d1707c…f3f5</code>, gömme vektörleri <code>fd765117…1955</code>. Vektör dosyası, Ravenda vd.'nin (2025) deposundaki <code>data/dass_embedding_large.csv</code> dosyasından (commit <code>9c7e5013</code>) yalnız satırlar madde sırasına konarak türetilmiştir; özgün dosyanın özeti <code>embedding_provenance.json</code> kaydındadır. Vektörler API ile yeniden üretilmek istenirse Hazırlık 3.3'teki yer tutucu kullanılır; o durumda yeni vektörler tarihli bir dosyaya ve özet kaydına yazılır ve sonuçlar bu sayfadaki sayılardan farklı olabilir.</p>
<p>Önerilen ortam: R 4.5.3 (R Core Team, 2026), lavaan 0.7-2, semTools 0.5-9, mirt 1.47, ggplot2, digest ve jsonlite; API seçeneği için ayrıca httr2. Bu kod, tezde kullanılan kabul denetimli betiğin (<code>berkcan_dass42_analiz.R</code>) okunabilir karşılığıdır ve aynı tanımlarla çalışır. AS2'deki test bilgi fonksiyonu, Ek A (gömme modeli denetimi) ve Ek D (omeganın ikinci hesaplama biçimi) betikte bulunmayan eklemelerdir; bu değerlerin referans karşılığı yoktur. Tezde kullanılacak sayılar kabul denetiminden geçmiş son çalıştırmadan alınır.</p>
<p><strong>Yapay zekâ kullanımı.</strong> Kod parçalarının ve sayfa metinlerinin hazırlanmasında yapay zekâ araçlarından (ChatGPT ve Claude) yararlanılmıştır. Bütün sayılar kodun çalıştırılmasıyla üretilmiş ve kabul denetimli çalıştırmayla karşılaştırılmıştır; yorumların doğruluğu ve kapsamı yazarların sorumluluğundadır.</p>"""]
    if mod in (1, 3):
        p.append('<div class="kopya-satiri"><button type="button" class="tumu">Bütün kodu kopyala</button><span class="not">Beş hazırlık parçası, beş soru, Sonuç tablosu ve beş ek, çalışma sırasıyla tek metin olarak kopyalanır.</span></div><textarea id="tum-kod-alani" class="tum-kod-alani" hidden readonly aria-label="Bütün R kodu"></textarea>')
    if mod == 3:
        p.append(bulgu('Çalıştırma kaydı', kayit + '<p>Kabul denetimli çalıştırmayla karşılaştırılan değerlerin hiçbiri farklı değildir; bu, sayfadaki kodun tezdeki betikle aynı sonuçları verdiğini gösterir. Karşılaştırma yalnız iki kodda da bulunan çıktılar için yapılabilmiştir.</p>'))
    p.append('</section>')
    return ''.join(p), kayit

# ---------------------------------------------------------------------------------------------
BOLUMLER = []

BOLUMLER.append(dict(
    id='hz1', no='3.1', nav='Paketler ve tanımlar', etiket='Hazırlık', baslik='Paketler, ayarlar ve tanım fonksiyonları',
    ne="""<p>Paketleri yükler, rastgele sayı üretecini sabitler; madde anahtarlarını ve bütün göstergelerin tanım fonksiyonlarını (ISI, SB, CL, CL<sub>b</sub>, alfa, RMSE, orta sıra yüzdeliği, GRM ve DFA kurulumu, kategorik omega) tanımlar. GRM mirt (Chalmers, 2012), sıralı DFA lavaan (Rosseel, 2012), kategorik omega semTools (Jorgensen vd., 2022), şekiller ggplot2 (Wickham, 2016) ile hesaplanır.</p>""",
    kod=('hz1', '3.1 · Paketler, ayarlar ve tanım fonksiyonları', 'h31'),
    ozet='tanımlar', yapilan='<p>Bu parça yalnız tanım yapar; tablo veya şekil üretmez. Fonksiyonlar, Önem ve amaç bölümündeki gösterge tanımlarını uygular.</p>'))

BOLUMLER.append(dict(
    id='hz2', no='3.2', nav='Veri ve örneklem', etiket='Hazırlık', baslik='Veri, örneklem ve gruplar',
    ne=liste(['Ham veri dosyasının SHA-256 özetini denetler.',
              '18-80 yaş aralığında, ana dili İngilizce olan ve 42 maddeyi 1-4 aralığında eksiksiz yanıtlayan kayıtları seçer. Ana dil ölçütü, madde metinlerinin ve gömme vektörlerinin İngilizce olmasından gelir.',
              'Uygun kayıtlardan 4.000 kişiyi <code>set.seed(20260905)</code> ile seçer; <code>set.seed(260905)</code> ile 2.000 kalibrasyon ve 2.000 değerlendirme grubuna ayırır ve bölmenin referans bölmeyle aynı olduğunu denetler.',
              'Yanıtları 0-3 aralığına çevirir; örneklem akışını ve grupların betimsel özelliklerini yazar.']),
    kod=('hz2', '3.2 · Veri, örneklem ve gruplar', 'h32'), ozet='Tablo 1, 2', ogeler=[T_akis, T_betim],
    yapilan="<p>Ham dosyadaki 39.775 kayıttan yaş ölçütünü 32.495, ana dil ölçütünü 10.362 kayıt karşılamıştır; bu kayıtların tamamı 42 maddeyi eksiksiz ve geçerli yanıtlamıştır. Uygun kayıtlardan 4.000'i seçilmiş ve iki gruba ayrılmıştır; bölme referans dosyayla aynıdır. Seçilmeyen 6.362 uygun kayıt yalnız Ek A'daki gömme modeli denetiminde kullanılır.</p>",
    okuma=['İki grubun yaş ve cinsiyet dağılımı birbirine yakın olmalıdır; bölme rastgele olduğu için farklar küçük beklenir.',
           'Ölçüt ölçüt düşen kayıt sayısı, sonuçların hangi gruba genellenebileceğini gösterir.'],
    yorum="<p>Örneklem genç (ortalama yaş 28,1) ve çoğunlukla kadındır (%71,2). İki grup yaş ve cinsiyet bakımından birbirine yakındır (kadın oranı %71,7 ve %70,7); bu nedenle bir ilişkinin iki grupta farklı çıkması, grup farkından çok örnekleme değişkenliğini yansıtır. Kayıtların çoğu ana dil ölçütüyle elenmiştir (32.495 kayıttan 10.362 kayda).</p><p>Örneklemin üç sınırlılığı yorumu doğrudan etkiler. Katılımcılar Open-Source Psychometrics Project sitesinde ölçeği kendi isteğiyle dolduran çevrimiçi gönüllülerdir; kendi kendini seçme söz konusudur ve klinik tanı bilgisi yoktur. Bulgular yalnız ana dili İngilizce olanlara ilişkindir. Kısa ve tam formlar ayrı uygulanmamıştır; kısa form puanları aynı uygulamadaki 42 maddelik yanıtlardan hesaplanır.</p>",
    soylenmez=['Örneklemin genel nüfusu veya klinik grupları temsil ettiği.', 'Bulguların ana dili İngilizce olmayan gruplara veya Türkçe uyarlamaya aktarılabileceği.']))

BOLUMLER.append(dict(
    id='hz3', no='3.3', nav='Gömme vektörleri', etiket='Hazırlık', baslik='Gömme vektörleri: model seçimi, arşiv ve API',
    ne="""<p>Kullanılan model OpenAI'nin <code>text-embedding-3-large</code> modelidir (3.072 boyut). Varsayılan çalıştırmada vektörler yeniden üretilmez; Ravenda vd.'nin (2025) yayımladığı arşivden alınır ve kod dosya özetinin kayıtla aynı olduğunu denetler. Model, analizden önce alanyazına dayanarak seçilmiştir:</p>
<ul><li><strong>Aynı ölçekte doğrudan karşılaştırma.</strong> Ravenda vd. (2025) DASS-42'nin 42 maddesinde on gömme modelini (BERT ailesi, cümle dönüştürücüleri, T5 ve üç OpenAI modeli) karşılaştırmıştır. Kosinüs benzerlikleri ile görgül madde korelasyonları arasındaki en yüksek uyumu (r = 0,77) ve bir maddenin en yüksek korelasyonlu eşini en benzer üç madde arasında bulma oranındaki en yüksek değeri (%95,2) text-embedding-3-large vermiştir (makalenin Tablo 1'i). Psikometride sık kullanılan all-mpnet-base-v2 daha düşük kalmıştır (r = 0,67; %80,1).</li>
<li><strong>Yalnız metne dayalı olma.</strong> Model genel amaçlı bir metin gömme modelidir; bilindiği kadarıyla madde korelasyonlarını hedefleyen bir ince ayardan (<i lang="en">fine-tuning</i>) geçmemiştir, ancak eğitim verisi açıklanmamıştır. SurveyBot3000 (Hommel ve Arslan, 2025) görgül madde korelasyonlarıyla ince ayar yapılmış bir modeldir ve eğitim verisi bu çalışmanın DASS arşivini de içerir; mpnet-personality (Wulff ve Mata, 2025) kişilik maddeleriyle ince ayar yapılmıştır. Bu tez anlamsal göstergelerin psikometrik özelliklerle ilişkisini sorduğu için, aynı yanıt verisiyle eğitilmiş bir model bu ilişkiyi kısmen modelin içine yerleştirir ve veri sızıntısı (<i lang="en">data leakage</i>) doğurur.</li>
<li><strong>Alana özgü ince ayarın klinik yapılarda güvencesi yoktur.</strong> Varrasi vd. (2026) DASS-21'de kişilik maddeleriyle ince ayarlı modelin kaygı ve stres faktörlerinde daha düşük uyum verdiğini bildirmiştir. Kennedy vd. (2025) belirti envanterlerinde genel amaçlı bir modelin klinik metinlerle ön eğitilmiş modellerden biraz daha isabetli olduğunu bulmuştur.</li>
<li><strong>Tekrarlanabilirlik.</strong> API ile sunulan modeller zamanla değişebilir veya kullanımdan kalkabilir. Özeti kayıtlı, yayımlanmış arşiv vektörleri analizin aynı vektörlerle tekrarlanmasını sağlar.</li></ul>
<p><strong>API ile üretim (yer tutucu).</strong> <code>vektor_kaynagi</code> <code>"api_yeni"</code> yapılırsa 42 madde metni OpenAI Embeddings API'sine gönderilir (OpenAI, 2024); anahtar koda yazılmaz, <code>OPENAI_API_KEY</code> ortam değişkeninden okunur. Yanıt tarihli bir CSV dosyasına ve özet kaydına yazılır; sonraki çalıştırmalarda aynı dosya <code>"api_kayitli"</code> seçeneğiyle, yeni çağrı yapılmadan okunur. API vektörleri arşivle karşılaştırılır (madde vektörleri arasındaki kosinüs, iki kosinüs matrisinin korelasyonu ve en büyük fark); 3.4'te iki vektör kümesiyle kurulan formların ortak madde sayısı da yazılır. Yer tutucu bu çalıştırmada kullanılmamıştır; ağ erişimi olmadığı için sınanmamıştır.</p>
<p>Seçimin bir bedeli de vardır: model kapalı ağırlıklıdır ve arşiv ortadan kalkarsa vektörler aynen yeniden üretilemeyebilir. Seçimin bu verideki davranışı, analizler belirlendikten sonra eklenen betimsel bir denetimle Ek A'da incelenmiştir.</p>""",
    kod=('hz3', '3.3 · Gömme vektörleri: arşiv ve API', 'h33'), ozet='denetim',
    yapilan="<p>Arşiv dosyasının özeti kayıtla aynı çıkmıştır; 42 × 3.072 boyutlu vektörlerden 42 × 42 kosinüs benzerliği matrisi hesaplanmıştır. Varsayılan seçenek kullanıldığı için API çağrısı yapılmamış ve karşılaştırma dosyaları üretilmemiştir.</p>",
    soylenmez=['API ile yeniden üretilen vektörlerin arşivdekilerle aynı olacağı; aynı model adı altında sonuçlar değişebilir.',
               'Modelin bütün modellerin en iyisi olduğu; seçim tek bir ölçekteki karşılaştırmaya dayanır.']))

BOLUMLER.append(dict(
    id='hz4', no='3.4', nav='Dört form', etiket='Hazırlık', baslik='Üç anlamsal seçim kuralı ve dört form',
    ne=liste(["Her alt boyutun 14 maddesi için ISI hesaplanır; ISI'si en düşük yedi madde MIN21'i, en yüksek yedi madde MAX21'i oluşturur.",
              "3.432 yedili kümenin tamamı için SB, CL ve CL<sub>b</sub> hesaplanır; CL'si en küçük küme COV21'dir. Eşit değerlerde küçük madde numarası önce gelir. Birden çok küme aynı en küçük CL'yi verirse sıralamada ilk küme alınır ve eşit çözüm sayısı raporlanır (ayrıntı Ek B'de).",
              'Vektörler API ile üretildiyse, formlar arşiv vektörleriyle kurulan formlarla karşılaştırılır.']),
    kod=('hz4', '3.4 · Üç anlamsal seçim kuralı ve dört form', 'h34'), ozet='Tablo 3', ogeler=[T_formlar],
    yapilan='<p>Kurallar 3.072 boyutlu arşiv vektörlerine uygulanmış ve dört form Tablo 3\'teki gibi oluşmuştur.</p>',
    okuma=['MIN21 ile MAX21 her alt boyutta birbirinin tümleyenidir; ikisi birlikte 14 maddenin tamamını kapsar.',
           'Eşit çözüm sayısı birden büyükse COV21 tek değildir; sonuçlar kuralın seçtiği ilk küme için geçerlidir.'],
    yorum="<p>Anlamsal formlar yayımlanmış formla kısmen örtüşür: PUB21 ile ortak madde sayısı MIN21'de 3-5, MAX21'de 2-4, COV21'de 3-4'tür. COV21 depresyonda 16, kaygıda 2, streste 8 eşit çözümden biridir; CL yalnız en yakın seçili maddeye uzaklığa baktığı için farklı kümeler aynı değeri verebilir. Ek B, eşit çözümler arasında seçimin sonuçları ne kadar değiştirebileceğini gösterir; Ek A ise formların vektör temsiline duyarlılığını verir.</p>",
    soylenmez=["Anlamsal formların DASS-21'in yerine önerildiği; formlar karşılaştırma amacıyla kurulmuştur.",
               'COV21\'in tek çözüm olduğu; eşit çözümler vardır.']))

BOLUMLER.append(dict(
    id='hz5', no='3.5', nav='Alt küme testi', etiket='Hazırlık', baslik='Alt küme testi: bütün yedili kümelerin psikometrik değerleri',
    ne="<p>Her alt boyutta 3.432 yedili kümenin tamamı için alfa, yanlılık, s<sub>d</sub>, RMSE ve kısa-tam r değerlerini iki grupta hesaplar ve dört formun bu dağılımlardaki orta sıra yüzdeliklerini çıkarır. Hesap tamsayı toplamlarıyla yapılır; böylece eşit değerler bit düzeyinde eşit kalır. Yüzdelikler AS2, AS3 ve AS4 tablolarında kullanılır.</p>",
    kod=('hz5', '3.5 · Alt küme testi', 'h35'), ozet='Tablo 4', ogeler=[T_dagilim],
    yapilan='<p>Her alt boyutta 3.432 kümenin psikometrik değerleri iki grupta hesaplanmıştır. Tablo 4 değerlendirme grubundaki dağılımı özetler.</p>',
    okuma=['Dağılımlar, aynı uzunluktaki bütün seçeneklerin ne kadar farklı sonuç verebildiğini gösterir; dört formun konumu bu aralıklar içinde okunur.'],
    yorum="<p>Aynı alt boyuttan seçilen yedili kümelerin güvenirliği sınırlı ama kayda değer bir aralıkta değişir: alfa depresyonda 0,90-0,94, kaygıda 0,81-0,89, streste 0,83-0,90 arasındadır. Tam puandan sapma daha geniş bir aralıkta değişir (RMSE 0-42 biriminde depresyonda 1,95-4,07, kaygıda 2,48-5,03, streste 2,39-3,75 puan). Kısa-tam korelasyon ise bütün kümelerde yüksektir (en düşük 0,92); ortak maddeler bu korelasyonu yükselttiği için r formları ayırt etmede zayıf bir göstergedir (Smith, McCarthy ve Anderson, 2000).</p>",
    soylenmez=['Dağılımdan en iyi görünen kümeyi seçip beşinci bir form önermek.']))

BOLUMLER.append(dict(
    id='as1', no='AS1', nav='Madde düzeyi', etiket='Madde düzeyi',
    soru="DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer maddelerle ortalama anlamsal benzerliği ile GRM altında kestirilen ayırt edicilik parametreleri arasında nasıl bir ilişki vardır?",
    ne=liste(['Her alt boyutun 14 maddesine tek boyutlu aşamalı tepki modeli (<i lang="en">graded response model</i>, GRM; Samejima, 1969) kalibrasyon grubunda kestirilir; aynı analiz değerlendirme grubunda tekrarlanır. Değerlendirme grubundaki modeller AS2\'deki test bilgisi için saklanır.',
              '14 ISI değeri ile 14 ayırt edicilik (a) parametresi arasındaki Spearman korelasyonu hesaplanır. Modelden bağımsız destek olarak ISI ile düzeltilmiş madde-toplam korelasyonu (CITC) arasındaki ilişki verilir.',
              'Model tanısı için C2 temelli uyum (Cai ve Monroe, 2014), yanıt kategorilerinin kullanımı ve ortalaması çıkarılmış Q3 (Christensen vd., 2017) incelenir; 91 madde çiftinde kosinüs benzerliği ile Q3 arasındaki ilişki ve en yüksek üç Q3 çifti raporlanır.',
              'Madde düzeyinde güven aralığı hesaplanmaz: 14 madde sabittir; ISI değerleri aynı kosinüs matrisinden, a parametreleri aynı modelden gelir.']),
    kod=('as1', 'AS1 · ISI ile GRM ayırt ediciliği', 'as1'), ozet='Tablo 5-8 · Şekil 1', ogeler=[T_as1, T_q3, T_kategori, T_param, S_as1],
    yapilan="<p>Her alt boyutta 14 maddeye GRM iki grupta ayrı ayrı kestirilmiş ve bütün modeller yakınsamıştır. ISI ile a ve CITC arasındaki Spearman korelasyonları, C2 temelli uyum, kategori kullanımı ve düzeltilmiş Q3 hesaplanmıştır. Tablo 8, madde parametrelerini ve her maddenin hangi kısa formlarda yer aldığını birlikte verir.</p>",
    okuma=['<code>rho_ISI_a</code> pozitifse anlamca merkezî (diğer maddelere daha çok benzeyen) maddelerin a değerleri daha yüksek olma eğilimindedir; negatifse tersi. İki grup ve <code>rho_ISI_CITC</code> aynı yönü gösteriyorsa ilişki tutarlı sayılır.',
           'Büyüklük adlandırması: |ρ| &lt; 0,30 zayıf, 0,30 ≤ |ρ| &lt; 0,50 orta, |ρ| ≥ 0,50 güçlü. Bu bir başarı eşiği değildir.',
           'C2 temelli RMSEA için bu çalışmada bir kesme değeri kullanılmaz; değerler sıfırdan belirgin biçimde büyükse a değerleri “bu model altında kestirilen ayırt edicilik” olarak adlandırılır. <code>rho_cos_Q3</code> pozitifse, anlamca daha yakın çiftlerde ortak faktörün açıklamadığı ilişki daha yüksek olma eğilimindedir.',
           'Şekil 1\'de her nokta bir maddedir. Uçta kalan tek bir madde görüntüyü etkileyebileceği için sıraya dayalı Spearman kullanılır.'],
    yorum="""<p>Üç alt boyutta da ilişki pozitif ve güçlüdür (ρ = 0,63-0,79); iki grupta ve CITC ile aynı yöndedir (ρ(ISI, CITC) = 0,60-0,75). a ile CITC'nin sıralaması neredeyse aynıdır (ρ = 0,97-0,99); ISI ile CITC arasındaki ilişki de benzer büyüklükte olduğundan bulgu GRM'ye özgü değildir. Bu 14 maddelik havuzlarda anlamca merkezî maddelerin a değerleri daha yüksek olma eğilimindedir. Buna uygun olarak MIN21'in maddelerinin ortalama a değeri üç alt boyutta da en düşük (2,54 / 1,65 / 1,72), MAX21'inki en yüksektir (2,97 / 2,23 / 2,20; Tablo 8). Bu yön, Kilmen ve Bulut'un (2025) ECR kaygı alt boyutunda bildirdiği negatif ilişkinin (ρ = −0,55) tersidir.</p>
<p>C2 temelli RMSEA değerleri iki grupta 0,08-0,13 aralığındadır; SRMSR 0,045-0,061'dir. Tek boyutlu GRM verinin bütün ilişkilerini açıklamamaktadır; bu nedenle a değerleri bu model altında kestirilen ayırt edicilik olarak okunur. Kategori kullanımı yeterlidir: en az kullanılan kategori kaygıda Q23'te yaklaşık %4'tür (kalibrasyon grubunda yaklaşık 85 yanıt). Kosinüs ile Q3 arasındaki ilişki orta düzeydedir (0,33-0,45): anlamca yakın çiftlerde artık korelasyon daha yüksek olma eğilimindedir. En yüksek Q3 çiftleri bu bağlantının sınırını da gösterir: depresyonda en yüksek Q3'ü Q05 (“I just couldn't seem to get going”) ile Q42 (“I found it difficult to work up the initiative to do things”) verir, ama kosinüsleri orta düzeydedir (0,55); Q17 (“I felt I wasn't worth much as a person”) ile Q34 (“I felt I was pretty worthless”) ise anlamca çok yakındır (0,82). Anlamsal yakınlık yerel bağımlılıkla ilişkilidir, ama onu tek başına belirlemez.</p>""",
    soylenmez=['Anlamsal benzerliğin ayırt ediciliği artırdığı gibi nedensel bir sonuç; ilişki 14 sabit madde içinde bir sıra korelasyonudur.',
               '14 maddenin ötesine, madde evrenine veya başka ölçeklere genelleme.',
               'Kosinüs-Q3 ilişkisinin a veya güvenirlikteki olası şişmenin miktarını gösterdiği.',
               'Kilmen ve Bulut (2025) ile yön farkının bir yanlışlama sayılması; ölçek, örneklem ve gömme modeli farklı olduğu için karşılaştırma yalnız yön düzeyindedir.']))

BOLUMLER.append(dict(
    id='as2', no='AS2', nav='Yapı, güvenirlik ve bilgi', etiket='Form düzeyi · yapı, güvenirlik ve test bilgisi',
    soru='Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21, faktör yapısı ve alt boyut puanlarının güvenirliği bakımından nasıl farklılaşmaktadır?',
    alt_soru='Alt soru: Yayımlanmış DASS-21 ile anlamsal seçim kurallarıyla oluşturulan kısa formların, ilgili tam alt boyut için kestirilen GRM altında sağladıkları test bilgisi, örtük özellik düzeyine göre nasıl farklılaşmaktadır?',
    ne=liste(['Değerlendirme grubunda beş form için (karşılaştırma olarak tam DASS-42 ve dört kısa form) üç ilişkili faktörlü sıralı doğrulayıcı faktör analizi (DFA) WLSMV kestiricisiyle kurulur; çapraz yük ve artık kovaryans eklenmez.',
              'Ölçeklenmiş χ² ve sd, CFI, TLI, RMSEA ve %90 güven aralığı, SRMR, faktör korelasyonları ve ortalama standartlaştırılmış yükler alınır.',
              'Güvenirliğin ana göstergesi kategorik omegadır. Ham alfa yardımcıdır; her formun alfası 3.432 kümenin alfa dağılımındaki orta sıra yüzdeliğiyle konumlandırılır (Hazırlık 3.5).',
              'Alt soru için AS1\'de değerlendirme grubunda kestirilen 14 maddelik GRM kullanılır; yeni model kurulmaz. Her formun test bilgisi, o formdaki yedi maddenin madde bilgilerinin toplamıdır ve θ = −3 ile 3 arasında hesaplanır. Böylece dört kısa form ve tam alt boyut aynı θ ölçeği üzerinde karşılaştırılır. Standart hata SH = 1 / √bilgi\'dir.']),
    kod=('as2', 'AS2 · Faktör yapısı, güvenirlik ve test bilgisi', 'as2'), ozet='Tablo 9-12 · Şekil 2', ogeler=[T_uyum, T_guv, T_kor, T_tbf, S_tbf],
    yapilan="<p>Değerlendirme grubunda beş form için üç ilişkili faktörlü sıralı DFA kestirilmiş; bütün modeller yakınsamış ve uygun çözüm vermiştir. Uyum, faktör korelasyonları, standartlaştırılmış yükler, kategorik omega ve ham alfa alınmıştır. Aynı grupta, her alt boyutun GRM'sinden beş formun test bilgi fonksiyonları hesaplanmıştır.</p>",
    okuma=['Formların uyum değerleri yan yana betimlenir. Farklı madde kümeleri iç içe model olmadığı için formlar ΔCFI veya ΔRMSEA eşikleriyle sıralanmaz; ayrıca yükler yükseldikçe aynı yanlış belirlemede RMSEA kötüleşebilir (McNeish, An ve Hancock, 2018).',
           'Omega farklarının büyüklüğü yazılır; omega için aralık hesaplanmamıştır. Alfa yüzdeliği 90 ise formun alfası olası yedili seçimlerin yaklaşık %90\'ından yüksektir.',
           'Anlamca dar bir formun yüksek güvenirliği “daha homojen puan” demektir, “daha iyi ölçme” değil. Faktörler arası korelasyonun düşük olması tek başına daha iyi bir form anlamına gelmez.',
           'Test bilgisi eğrisi, formun örtük özelliğin hangi düzeylerinde daha kesin ölçtüğünü gösterir. Tam alt boyut (14 madde) üst sınırdır; kısa formların ondan az bilgi vermesi beklenir. MIN21 ile MAX21 tümleyen olduğundan bilgileri toplamı tam alt boyutun bilgisine eşittir.'],
    yorum="""<p>Beş formun uyum değerleri birbirine yakındır (CFI 0,94-0,97; SRMR 0,04-0,05); kısa formlar arasında RMSEA 0,063 ile 0,079 arasındadır ve en yüksek değer MAX21'dedir. MAX21'in standartlaştırılmış yükleri de en yüksektir (ortalama 0,81, PUB21'de 0,76); yüksek yükler aynı yanlış belirlemede RMSEA'yı kötüleştirebildiği için MAX21'in RMSEA'sı yüklerle birlikte okunur. Bu farklar formları uyum bakımından sıralamaya yetmez.</p>
<p>Kısa formlar arasında MAX21 her alt boyutta en yüksek omega ve alfayı verir; omega PUB21'e göre 0,020 (depresyon), 0,033 (kaygı) ve 0,041 (stres) daha yüksektir ve alfası olası kümelerin 92,3-99,4. yüzdeliğindedir. MIN21'in omegası PUB21'den 0,002, 0,026 ve 0,016 düşüktür; alfa yüzdelikleri en fazla 5,8'dir. COV21 depresyonda PUB21 ile aynı düzeydedir (fark 0,000), kaygı ve streste biraz düşüktür (0,016 ve 0,004). PUB21'in alfası olası kümelerin 17,4 / 58,5 / 10,8. yüzdeliğindedir. Alfa farklarının bootstrap aralıkları Ek E'dedir; omeganın ikinci hesaplama biçimi depresyonda formların sırasını değiştirir (Ek D).</p>
<p>Kaygı ile stres faktörleri arasındaki korelasyon bütün kısa formlarda yüksektir (0,76-0,89); MIN21'de en yüksek, MAX21'de en düşüktür. Bu, madde kümelerinin bir özelliği olarak betimlenir: anlamca ayrışık maddelerden oluşan kaygı ve stres kümeleri bu örneklemde birbirinden daha az ayrışmıştır.</p>
<p><strong>Test bilgisi.</strong> Bütün kısa formlar bilgiyi θ = −1 ile 1 arasında yoğunlaştırır; uçlarda bilgi hızla düşer. θ = 0'da kısa formlar tam alt boyutun bilgisinin yaklaşık %34-66'sını verir (ör. depresyonda tam 31,8; PUB21 15,2; MAX21 18,3). MAX21 θ = 0 ve θ = 1'de her alt boyutta en çok bilgiyi verir (streste θ = 0'da 11,4, PUB21'de 6,9); ancak depresyon ve kaygıda θ = −2'de en az bilgiyi veren formdur (1,2 ve 0,8; SH 0,92 ve 1,14). MIN21 orta bölgede en az bilgiyi verir, düşük uçta ise depresyon ve kaygıda kısa formlar arasında en yüksek değerlere sahiptir. Başka bir deyişle, merkezî maddelerden oluşan formun bilgisi dar bir θ aralığında yüksek, ayrışık maddelerden oluşan formunki daha düz dağılmıştır. θ = 0'da PUB21 ve COV21 bu iki formun arasında kalır. Bu örüntü, MAX21'in yüksek güvenirliğinin (Tablo 10) θ ölçeğinin tamamına yayılmadığını gösterir.</p>""",
    soylenmez=['Uyum indekslerine göre kazanan bir form ilan etmek.', 'Yüksek güvenirliği tek başına daha iyi ölçme saymak.',
               'Alfa yüzdeliklerini omega için geçerli saymak.',
               'Test bilgisini ikinci bir başarı ölçütü veya klinik kesinlik göstergesi saymak; GRM uyumu sınırlıdır ve yerel bağımlılık (AS1) bilgiyi olduğundan yüksek gösterebilir. θ ölçeği bu örneklemin 14 maddelik modeline göre tanımlıdır; test bilgisi için aralık hesaplanmamıştır.',
               'Tam alt boyutun kısa formlardan daha çok bilgi vermesini bir bulgu saymak; bu, madde sayısının doğrudan sonucudur.']))

BOLUMLER.append(dict(
    id='as3', no='AS3', nav='Tam form uyumu', etiket='Form düzeyi · tam form uyumu',
    soru="Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21'in alt boyut puanları, DASS-42'nin ilgili alt boyut puanlarıyla ne ölçüde uyumludur?",
    ne=liste(['Değerlendirme grubundaki 2.000 kişi için her formun kısa (7 madde) ve tam (14 madde) alt boyut ortalamaları (0-3) karşılaştırılır: Pearson r, yanlılık (kısa eksi tam), farkların n paydalı standart sapması (s<sub>d</sub>) ve RMSE.',
              'RMSE ayrıca 14 ile çarpılarak 0-42 puan biriminde verilir. Bu değer, DASS-21 alt boyut toplamının iki katı ile DASS-42 alt boyut toplamı arasındaki farkların karesel ortalamasının köküdür.',
              "Her formun RMSE'si 3.432 kümenin RMSE dağılımında konumlandırılır; kısa-tam r bütün kümelerin medyan r'siyle karşılaştırılır.",
              "Anlamsal formların RMSE'sinin PUB21'den farkı eşleştirilmiş bootstrap ile değerlendirilir: 2.000 tekrarın her birinde aynı kişiler bütün formlara uygulanır; tekrar b, <code>set.seed(20260913 + b)</code> ile başlar. Aynı tekrarlarda alfa farkları da hesaplanır (Ek E)."]),
    kod=('as3', 'AS3 · Tam form puanlarıyla uyum ve bootstrap', 'as3'), ozet='Tablo 13, 14', ogeler=[T_as3, T_boot],
    yapilan="<p>Değerlendirme grubundaki 2.000 kişinin kısa ve tam alt boyut ortalamaları karşılaştırılmış; formların RMSE'si 3.432 kümenin dağılımında konumlandırılmış ve RMSE farkları 2.000 eşleştirilmiş bootstrap tekrarıyla değerlendirilmiştir.</p>",
    okuma=["Ana gösterge ham RMSE'dir. RMSE² = yanlılık² + s<sub>d</sub>² olduğundan, sapmanın ortalama kaymadan mı yoksa kişi düzeyindeki dağılımdan mı geldiği her zaman yazılır.",
           "Yarı uzunluktaki formlarda ham RMSE bölünmenin özelliğidir: bir küme ile tümleyeni aynı RMSE'yi verir. MIN21 ile MAX21 birbirinin tümleyeni olduğu için RMSE'leri ve PUB21'e göre farkları aynıdır; bu yeni bir bağımsız kanıt değildir. Kısa-tam korelasyon için bu eşitlik geçerli değildir.",
           'RMSE yüzdeliği düşükse form olası kümelerin çoğundan daha az sapar. Yüksek r bütün kümelerde yaygınsa tek başına başarı göstergesi sayılmaz.',
           'Bootstrap farkı “anlamsal form eksi PUB21” yönündedir. Aralık sıfırı dışlıyorsa fark, bu örneklemin yeniden örneklemelerinde tutarlı yöndedir; sıfırı içermesi eşdeğerlik kanıtı değildir. Karar yuvarlanmamış sınırlarla verilir.'],
    yorum="""<p>PUB21 depresyon ve kaygıda en düşük RMSE'yi verir; depresyonda olası kümelerin en düşük %3,5'i içindedir. Streste en düşük RMSE COV21'dedir ve PUB21'den farkının aralığı sıfırı dışlar; bu fark 0-42 biriminde yaklaşık 0,35 puandır. COV21'in kaygıdaki farkının alt sınırı sıfıra çok yakındır (0,0003). MIN21 ve MAX21 depresyonda PUB21'den belirgin biçimde daha çok sapar (fark 0,072; 0-42 biriminde yaklaşık 1,0 puan). Bu formların karesel sapmasının (RMSE²) yaklaşık dörtte biri yanlılıktan (±0,11), geri kalanı kişi düzeyindeki dağılımdan gelir; PUB21'de yanlılık depresyonda neredeyse sıfırdır (−0,004).</p>
<p>Bütün formlarda sapma 0-42 biriminde yaklaşık 2,1-3,3 puandır. Kısa-tam korelasyonlar bütün formlarda en az 0,95'tir ve bütün kümelerin medyanına yakındır; bu yüzden formları ayırt etmez. COV21 için kaygıdaki sonuç eşitlik bozma kuralına duyarlıdır: aynı en küçük CL'yi veren diğer kümenin RMSE'si PUB21'inkinden düşüktür (Ek B).</p>""",
    soylenmez=['RMSE\'yi ölçme hatası saymak; tam form gerçek puan değildir ve kısa formla ortak maddeler içerir.',
               'Yüksek kısa-tam korelasyonunu geçerlik veya puan eşdeğerliği kanıtı saymak; ortak maddeler bu korelasyonu yükseltir (Smith, McCarthy ve Anderson, 2000).',
               '0-42 birimindeki RMSE\'yi klinik önem eşiği saymak veya kesme noktalarında sınıflama doğruluğu hakkında sonuç çıkarmak; bu çalışma sınıflamayı incelemez.']))

BOLUMLER.append(dict(
    id='as4', no='AS4', nav='Çeşitlilik ve temsil', etiket='Form düzeyi · çeşitlilik ve temsil',
    soru='Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21, seçilen maddelerin anlamsal çeşitliliği ve ilgili alt boyuttaki madde havuzunun anlamsal temsili bakımından nasıl farklılaşmaktadır?',
    ne=liste(['Her formun SB ve CL değerleri ve bu değerlerin 3.432 kümedeki orta sıra yüzdelikleri alınır (Hazırlık 3.4 ve 3.5).',
              'Bütün kümelerde SB ile CL arasındaki Spearman korelasyonu hesaplanır.',
              "Her elenen madde, ona en yakın seçili madde, iki madde metni ve kosinüs uzaklığı yan yana verilir. Kod, CL'nin elenen yedi uzaklığın toplamının 14'e bölümüne eşit olduğunu da denetler."]),
    kod=('as4', 'AS4 · Anlamsal çeşitlilik ve temsil', 'as4'), ozet='Tablo 15, 16', ogeler=[T_as4, T_temsil],
    yapilan="<p>Her formun SB ve CL değerleri ile 3.432 kümedeki yüzdelikleri alınmış, bütün kümelerde SB ile CL'nin ilişkisi hesaplanmış ve her elenen madde en yakın seçili maddeyle eşleştirilmiştir. CL'nin elenen uzaklıkların toplamının 14'e bölümüne eşit olduğu denetimden geçmiştir.</p>",
    okuma=['SB yüzdeliği yüksekse form anlamca çeşitlidir; CL yüzdeliği düşükse elenen maddeler seçilen maddelere gömme uzayında yakındır.',
           "Tanım gereği beklenen sonuçlar (MIN21'in yüksek, MAX21'in düşük SB'si; COV21'in en düşük CL'si) bulgu sayılmaz. Asıl bilgi PUB21'in konumunda, her formun kendi hedefi dışındaki göstergedeki konumunda (MIN21'in CL'si, COV21'in SB'si) ve SB ile CL'nin bütün kümelerde birlikte değişip değişmediğindedir.",
           'Madde temsil tablosu CL\'nin dayandığı eşleşmeleri gösterir.'],
    yorum="""<p>PUB21'in CL yüzdeliği 2,9 / 12,7 / 21,1'dir: yayımlanmış formda elenen maddeler, olası kümelerin çoğundakinden seçilen maddelere daha yakındır. MIN21 en çeşitli formdur, ama bu çeşitlilik düşük CL'ye karşılık gelmez: CL'si her alt boyutta PUB21'inkinden yüksektir ve kaygıda olası kümelerin en yüksek %2'lik dilimindedir (CL yüzdeliği 98,4). MAX21 hem en dar formdur hem de depresyon ve streste en yüksek CL'ye sahiptir (85,6 ve 91,7); kaygıda MIN21 ile neredeyse aynıdır (98,3). COV21 CL için seçildiği hâlde çeşitlilikte de üst sıralardadır (SB yüzdeliği 79,5-84,3).</p>
<p>Bütün kümelerde SB ile CL negatif ilişkilidir (−0,55 ile −0,45): daha çeşitli kümelerin CL'si daha düşük olma eğilimindedir, ama ilişki orta düzeydedir ve en çeşitli küme en düşük CL'li küme değildir. Örneğin PUB21 depresyonda en zayıf olarak Q05'i (“I just couldn't seem to get going”) temsil eder; bu maddeye en yakın seçili madde Q31'dir (“I was unable to become enthusiastic about anything”) ve aradaki uzaklık 0,43'tür.</p>""",
    soylenmez=["Tanım gereği veya seçim kuralından beklenen sonuçları bulgu saymak: MIN21'in yüksek, MAX21'in düşük SB'si ve COV21'in en düşük CL'si.",
               'Yüksek SB\'yi tek başına düşük temsil kaybı saymak.',
               'CL\'yi içerik kapsamı veya kapsam geçerliği saymak; CL yalnız kullanılan gömme uzayındaki yakınlıktır ve uzman içerik yargısının yerine geçmez.']))

BOLUMLER.append(dict(
    id='as5', no='AS5', nav='Alt küme ilişkileri', etiket='Bütün olası formlar · alt küme testi',
    soru="DASS-42'nin her alt boyutundan seçilebilecek bütün yedili madde kümelerinde, anlamsal çeşitlilik ve temsil ile puan güvenirliği ve tam form puanlarıyla uyum arasında nasıl bir ilişki vardır?",
    ne="""<ul><li>Her alt boyutta 3.432 yedili kümenin tamamında SB ile alfa arasındaki Spearman korelasyonu hesaplanır.</li><li>RMSE bir küme ile tümleyeninde aynı olduğu için CL<sub>b</sub> ile RMSE arasındaki ilişki 1.716 benzersiz bölünmede hesaplanır. Açıklayıcı olarak CL<sub>b</sub>'nin s<sub>d</sub> ve mutlak yanlılıkla ilişkisi verilir.</li><li>Ana analiz değerlendirme grubunda, tekrar kalibrasyon grubunda yapılır. AS5 ilk sonuçlardan sonra eklenmiş keşfedici bir sorudur; kümeler ortak maddeler içerdiği için p değeri verilmez. “Alt küme testi” adı çıkarımsal bir test değil, bütün olası kümelerin betimsel karşılaştırmasıdır.</li></ul>""",
    kod=('as5', 'AS5 · Alt küme testi ilişkileri ve şekil', 'as5'), ozet='Tablo 17 · Şekil 3', ogeler=[T_as5, S_as5],
    yapilan='<p>Her alt boyutta 3.432 kümede SB ile alfa, 1.716 bölünmede CL<sub>b</sub> ile RMSE, s<sub>d</sub> ve mutlak yanlılık arasındaki Spearman korelasyonları iki grupta hesaplanmış ve Şekil 3 çizilmiştir.</p>',
    okuma=["Şekil 3'ün üst sırasında her gri nokta bir yedili kümedir (yatay SB, dikey alfa); alt sırada her gri nokta bir bölünmedir (yatay CL<sub>b</sub>, dikey RMSE). Renkli işaretler dört formdur.",
           'Üst sırada bulut sağa doğru iniyorsa daha çeşitli kümelerin alfası daha düşük olma eğilimindedir. Alt sırada bulut sağa doğru yükseliyorsa iki yarının birbirine anlamca uzak olduğu bölünmelerde tam puandan sapma daha büyük olma eğilimindedir.',
           "Sonuç “bu madde havuzundaki kümeler boyunca şu yönde ve şu büyüklükte ilişki” biçiminde yazılır. CL<sub>b</sub>'nin s<sub>d</sub> ile ilişkisi mutlak yanlılıkla ilişkisinden belirgin biçimde güçlüyse, anlamsal uzaklık kişi düzeyindeki dağılımla daha çok, madde ortalamalarından doğan yanlılıkla daha az ilişkilidir."],
    yorum="""<p>Bu havuzdaki kümeler boyunca daha çeşitli kümelerin alfası güçlü biçimde daha düşük olma eğilimindedir (−0,63 ile −0,81); iki yarının anlamca birbirine uzak olduğu bölünmelerde RMSE daha yüksektir (0,53-0,76). CL<sub>b</sub>'nin ilişkisi s<sub>d</sub> ile güçlü (0,66-0,76), mutlak yanlılıkla zayıftır (0,15-0,20). Bulgular kalibrasyon grubunda aynı yönde ve benzer büyüklüktedir; dört formda görülen örüntü yalnız bu formlara özgü değildir.</p>
<p>Uydurma sözcükleri tanıdığını bildiren kayıtlar çıkarıldığında (değerlendirme grubunda 384 kayıt) bu katsayılar en fazla 0,018 değişmiştir (Ek C).</p>""",
    soylenmez=['Metnin psikometrik sonucu yordadığı iddiası, bir başarı eşiği, yeni madde havuzlarına genelleme veya nedensellik.',
               "CL<sub>b</sub>'nin hangi yarının tutulacağını söylediği; iki yarı yer değiştirdiğinde CL<sub>b</sub> değişmez.",
               'Dağılımdan en iyi görünen kümeyi seçip beşinci bir form önermek.']))

SONUC_METIN = """<p class="sonuc-p">Bu madde havuzunda madde metinlerinden yapılan seçimler bir takas ortaya koymuştur (Tablo 18). Birbirine benzeyen maddelerden oluşan form (MAX21) en yüksek güvenirliği ve orta θ bölgesinde en yüksek test bilgisini vermiş; ama en dar içeriğe sahip olmuş, depresyon ve streste en yüksek temsil kaybını (kaygıda MIN21 ile neredeyse aynı) ve tam puandan en büyük sapmayı göstermiştir. Birbirine benzemeyen maddelerden oluşan form (MIN21) en çeşitli form olmuş, ama en düşük güvenirliği vermiş ve temsil kaybı düşük olmamıştır. COV21 tanımı gereği en düşük CL'ye sahiptir (bu kuralın sonucudur, bulgu değildir); tam puan uyumunda streste PUB21'den iyi, depresyon ve kaygıda ondan zayıf kalmıştır ve kaygıdaki sonuç eşitlik bozma kuralına duyarlıdır. Hiçbir anlamsal form incelenen göstergelerin tamamında yayımlanmış DASS-21'den daha iyi değildir.</p>
<p class="sonuc-p">Bütün olası formlar üzerindeki ilişkiler (AS5), bu takasın seçilmiş dört formla sınırlı olmadığını gösterir: bu havuzda daha çeşitli kümelerin alfası daha düşük, iki yarısı anlamca birbirine uzak bölünmelerin tam puandan sapması daha büyüktür. Bu örüntü, iç tutarlılığı en üst düzeye çıkaran madde seçiminin içeriği daraltabileceği uyarısıyla (Loevinger, 1954; Steger vd., 2023) ve kısa formların yalnız güvenirlikle değil, içerik kapsamı ve tam form uyumuyla birlikte değerlendirilmesi gerektiği görüşüyle (Smith, McCarthy ve Anderson, 2000) tutarlıdır.</p>
<p class="sonuc-p">Madde düzeyindeki ilişkinin yönü, Kilmen ve Bulut'un (2025) ECR'de bildirdiğinin tersidir: bu havuzda anlamca merkezî maddelerin a değerleri daha yüksek olma eğilimindedir ve MIN21 ortalamada daha düşük a değerli maddeleri içermektedir. Dil modellerinin maddeler arası ilişkileri metinden kestirebildiğine ilişkin bulgularla (Hommel ve Arslan, 2025; Ravenda vd., 2025; Wulff ve Mata, 2025) birlikte okunduğunda, anlamsal bilgi psikometrik ilişkilerle bağlantılıdır; ancak bağlantının yönü ölçekten ölçeğe değişebilir ve her uygulamada veriyle sınanmalıdır.</p>
<p class="sonuc-p">Kullanılan gömme modeli, analiz dışı kayıtlarda madde korelasyonlarıyla güçlü biçimde uyuşmuş ve alt ölçek yapısını neredeyse tam olarak yeniden üretmiştir (Ek A); bu denetim sonradan eklenmiş ve betimsel olarak raporlanmıştır. Formların maddeleri vektör temsiline duyarlıdır: 1.536-512 boyutta MIN21 ve MAX21 aynı kalmış, COV21 kaygıda değişmiş; 256 boyut, sözcüksel temsil ve açık ağırlıklı modeller kısmen farklı kümeler vermiştir. Sonuçlar tek ölçek, tek dil, tek gömme modeli ve çevrimiçi gönüllü bir örneklemle sınırlıdır. MAX21, COV21 ve AS5 ilk sonuçlar görüldükten sonra eklenmiştir; tam sayım bu genişlemenin etkisini azaltır ama ön kaydın yerine geçmez. Kısa ve tam puanlar aynı uygulamadan geldiği için ortak maddeler uyumu yükseltir.</p>"""

ONERILER = """<section id="oneriler" class="soru">
<h2>Öneriler</h2>
<div class="oneri-grubu"><h3>Ölçek kullanıcıları: araştırmacılar ve klinisyenler</h3><ul>
<li>Bu bulgular, yayımlanmış DASS-21 yerine anlamsal kurallarla seçilmiş bir kısa formun kullanılmasına gerekçe sağlamaz: hiçbir anlamsal form incelenen göstergelerin tamamında DASS-21'den daha iyi değildir.</li>
<li>DASS-21 alt boyut toplamı ikiyle çarpılarak DASS-42 ölçeğine taşındığında, bu veride iki puan arasındaki tipik fark yaklaşık 2-3 puandır. Bu değer ölçme hatası ya da klinik bir eşik değildir; kesme noktalarında sınıflama doğruluğu ayrıca incelenmelidir.</li></ul></div>
<div class="oneri-grubu"><h3>Kısa form geliştirenler</h3><ul>
<li>Anlamsal benzerliği tek başına seçim ölçütü yapmayın: bu havuzda en benzer maddeler daha yüksek güvenirlik ama daha dar içerik, en az benzer maddeler daha çok çeşitlilik ama daha düşük güvenirlik vermiştir.</li>
<li>Anlamsal göstergeleri (ISI, SB, CL) ön eleme ve tanı aracı olarak kullanın; son seçimi faktör uyumu, güvenirlik, test bilgisi ve tam form uyumuyla birlikte yapın. CL, elenen maddelerin gömme uzayında seçilen maddelere ne kadar yakın olduğunu yanıt verisi olmadan betimler; içerik kapsamının kendisi değildir ve uzman içerik yargısının yerine geçmez.</li>
<li>Aday formu aynı uzunluktaki bütün olası formlarla karşılaştırın (alt küme testi). Madde havuzu küçük olduğunda (ör. 14 maddeden 7) bütün kümeler hesaplanabilir ve formun konumu tek bir kıyas formuna göre daha şeffaf raporlanır.</li>
<li>Seçim kuralını ve eşitlik bozma kuralını sonuçları görmeden tanımlayın ve raporlayın; dağılımdan sonradan en iyi görünen kümeyi seçip önermeyin.</li></ul></div>
<div class="oneri-grubu"><h3>Yapay zekâ ve gömme yöntemlerini kullanan araştırmacılar</h3><ul>
<li>Gömme modelini sonuçları görmeden, aynı ölçekteki karşılaştırmalara ve modelin yanıt verisiyle eğitilip eğitilmediğine bakarak seçin. Seçimi, analiz verisinden ayrı kayıtlarda, sonuç göstergelerinden bağımsız bir denetimle (kosinüs-korelasyon uyumu, alt ölçek sınıflaması) inceleyin ve sözcüksel bir temel çizgiyle karşılaştırın.</li>
<li>Anlamsal benzerlik ile ayırt edicilik arasındaki ilişkinin yönü ölçeğe göre değişebilir; bir kuralı yeni bir ölçeğe uygulamadan önce veriyle sınayın.</li>
<li>Gömme modelini, sürümünü ve API çağrı tarihini raporlayın, vektörleri özetleriyle arşivleyin; aynı metin farklı modellerde ve boyutlarda farklı benzerlikler ve farklı formlar verebilir.</li>
<li>Yapay zekâ destekli analiz kodunu, sabit tanımlar ve referans değerler içeren bir şablonla ve kabul denetimlerinden geçirerek kullanın.</li></ul></div>
<div class="oneri-grubu"><h3>Sonraki araştırmalar</h3><ul>
<li>Yanıt verisiyle ince ayarlı modellerle (ör. SurveyBot3000) duyarlılık analizi; bu modellerde eğitim verisiyle çakışmanın denetlenmesi.</li>
<li>Başka ölçeklerde, Türkçe dahil başka dillerde ve klinik örneklemlerde tekrar.</li>
<li>Kısa ve tam formların ayrı uygulamalarla karşılaştırılması; kesme noktalarında sınıflama uyumunun incelenmesi; seçim kuralının ve analiz planının ön kaydı.</li></ul></div>
</section>"""

KAYNAKLAR = [
 'Cai, L., &amp; Monroe, S. (2014). <em>A new statistic for evaluating item response theory models for ordinal data</em> (CRESST Report 839). University of California, Los Angeles.',
 'Chalmers, R. P. (2012). mirt: A multidimensional item response theory package for the R environment. <em>Journal of Statistical Software, 48</em>(6), 1-29. https://doi.org/10.18637/jss.v048.i06',
 'Christensen, K. B., Makransky, G., &amp; Horton, M. (2017). Critical values for Yen\'s Q3: Identification of local dependence in the Rasch model using residual correlations. <em>Applied Psychological Measurement, 41</em>(3), 178-194. https://doi.org/10.1177/0146621616677520',
 'Hommel, B. E., &amp; Arslan, R. C. (2025). Language models accurately infer correlations between psychological items and scales from text alone. <em>Advances in Methods and Practices in Psychological Science, 8</em>(4).',
 'Jorgensen, T. D., Pornprasertmanit, S., Schoemann, A. M., &amp; Rosseel, Y. (2022). <em>semTools: Useful tools for structural equation modeling</em> [R paketi].',
 'Kennedy, E., Vadlamani, S., Lindsey, H. M., Peterson, K. S., Dams O\'Connor, K., vd. (2025). Linking symptom inventories using semantic textual similarity. <em>Journal of Neurotrauma, 42</em>, 1008-1020. https://doi.org/10.1089/neu.2024.0301',
 'Kilmen, S., &amp; Bulut, O. (2025). Shortening psychological scales: Semantic similarity matters. <em>Educational and Psychological Measurement, 85</em>(5), 910-934. https://doi.org/10.1177/00131644251319047',
 'Loevinger, J. (1954). The attenuation paradox in test theory. <em>Psychological Bulletin, 51</em>(5), 493-504.',
 'Lovibond, S. H., &amp; Lovibond, P. F. (1995). <em>Manual for the Depression Anxiety Stress Scales</em> (2. baskı). Psychology Foundation of Australia.',
 'McNeish, D., An, J., &amp; Hancock, G. R. (2018). The thorny relation between measurement quality and fit index cutoffs in latent variable models. <em>Journal of Personality Assessment, 100</em>(1), 43-52.',
 'OpenAI. (2024). <em>Vector embeddings</em> [Geliştirici belgesi]. https://developers.openai.com/api/docs/guides/embeddings (Erişim: 28 Eylül 2026).',
 'Open-Source Psychometrics Project. <em>DASS verisi (DASS_data_21.02.19)</em>. https://openpsychometrics.org/_rawdata/',
 'R Core Team. (2026). <em>R: A language and environment for statistical computing</em> (Sürüm 4.5.3). R Foundation for Statistical Computing.',
 'Ravenda, F., Preti, A., Poletti, M., Mira, A., &amp; Raballo, A. (2025). Rethinking psychometrics through LLMs: How item semantics shape measurement and prediction in psychological questionnaires. <em>Scientific Reports, 15</em>, 37313. https://doi.org/10.1038/s41598-025-21289-8',
 'Rosseel, Y. (2012). lavaan: An R package for structural equation modeling. <em>Journal of Statistical Software, 48</em>(2), 1-36. https://doi.org/10.18637/jss.v048.i02',
 'Samejima, F. (1969). Estimation of latent ability using a response pattern of graded scores. <em>Psychometrika Monograph Supplement, 34</em>(4, Pt. 2).',
 'Smith, G. T., McCarthy, D. M., &amp; Anderson, K. G. (2000). On the sins of short-form development. <em>Psychological Assessment, 12</em>(1), 102-111.',
 'Steger, D., Jankowsky, K., Schroeders, U., &amp; Wilhelm, O. (2023). The road to hell is paved with good intentions: How common practices in scale construction hurt validity. <em>Assessment, 30</em>(6), 1811-1824. https://doi.org/10.1177/10731911221124846',
 'Varrasi, S., Platania, G. A., Castellano, S., Ferraioli, F., Massimino, S., Vicario, C. M., Di Nuovo, S., &amp; D\'Urso, E. D. (2026). Expanding psychometrics with pretrained language models: Evaluating pseudo-factor analysis in applied and multilingual contexts. <em>Methods in Psychology, 14</em>, 100244.',
 'Wickham, H. (2016). <em>ggplot2: Elegant graphics for data analysis</em>. Springer.',
 'Wulff, D. U., &amp; Mata, R. (2025). Semantic embeddings reveal and address taxonomic incommensurability in psychological measurement. <em>Nature Human Behaviour, 9</em>, 944-954. https://doi.org/10.1038/s41562-024-02089-y',
]

EKLER = []
EKLER.append(dict(
    id='ekA', no='Ek A', nav='Gömme modeli denetimi', etiket='Ek', baslik='Gömme modeli için betimsel denetim',
    ne="""<p>Bu denetim, formlar ve analizler belirlendikten sonra eklenmiştir; bu nedenle bir karar kuralı olarak değil, betimsel bilgi olarak raporlanır ve sonucuna bakılarak model veya boyut değiştirilmemiştir. Kalibrasyon ve değerlendirme gruplarının verisini ikinci kez kullanmamak için görgül korelasyonlar, uygunluk ölçütlerini karşılayıp örnekleme seçilmeyen 6.362 kayıttan hesaplanır. Ölçütler araştırma sorularının sonuç göstergelerini kullanmaz.</p>
<dl class="tanim"><dt>Ö1 · bütün çiftler</dt><dd>861 madde çiftinde kosinüs benzerliği ile görgül korelasyonun mutlak değerleri arasındaki Pearson r ve Spearman ρ (Ravenda vd.'nin ölçütü).</dd>
<dt>Ö2 · alt ölçek içi</dt><dd>Aynı alt ölçekteki 273 çiftte aynı iki katsayı. ISI, SB ve CL alt ölçek içinde hesaplandığı için doğrudan ilgili ölçüttür.</dd>
<dt>Ö3 · ilk-k isabeti</dt><dd>Bir maddenin görgül olarak en yüksek korelasyonlu eşinin, anlamca en benzer k madde arasında bulunma oranı (k = 1, 2, 3; şans düzeyi k/41).</dd>
<dt>Ö4 · alt ölçek sınıflaması</dt><dd>Her madde, kendisi dışındaki maddelerle ortalama kosinüsünün en yüksek olduğu alt ölçeğe atanır; anahtarla uyuşma oranı hesaplanır. Yanıt verisi kullanmaz; şans düzeyi yaklaşık %33.</dd></dl>
<p>Karşılaştırma temsilleri: aynı modelin kısaltılmış boyutları (ilk 256, 512, 1.024 ve 1.536 bileşen, yeniden birim uzunluğa ölçeklenmiş; OpenAI, 2024), madde metinlerindeki sözcük örtüşmesine dayanan TF-IDF temel çizgisi (Kennedy vd., 2025) ve <code>girdiler/modeller/</code> klasöründe bulunuyorsa açık ağırlıklı modeller. Aynı kurallar bu temsillere de uygulanarak formların temsile duyarlılığı incelenir.</p>""",
    kod=('ekA', 'Ek A · Gömme modeli denetimi ve form duyarlılığı', 'ekA'), ozet='Tablo A1, A2 · Şekil A1', ogeler=[T_ekA, T_ekA2, S_ekA],
    yapilan='<p>6.362 kayıttan 42 × 42 korelasyon matrisi hesaplanmış; dört ölçüt on bir temsil için hesaplanmış ve seçim kuralları ana model dışındaki temsillere uygulanmıştır.</p>',
    okuma=["Ö1 ve Ö2 yüksekse anlamca yakın madde çiftleri yanıtlarda da daha yüksek korelasyon gösteriyordur. Ö2'nin Ö1'den düşük olması beklenir; alt ölçek içindeki korelasyonlar daha dar bir aralıktadır.",
           'Ö3 ve Ö4 şans düzeyiyle birlikte okunur. TF-IDF ile fark, benzerliğin sözcük örtüşmesinin ötesinde bilgi taşıyıp taşımadığını gösterir.',
           "Tablo A2'de 7, formun ana formla aynı olduğunu gösterir; değer düştükçe form üyeliği temsil seçimine daha duyarlıdır."],
    yorum="""<p>Analiz dışı kayıtlarda 861 çiftteki uyum r = 0,81'dir (ρ = 0,77); Ravenda vd.'nin (2025) aynı arşivin verisiyle bildirdiği değer r = 0,77'dir (makalenin Tablo 1'inde ρ = 0,73; metninde ise 0,66 yazmaktadır, tablo ile metin tutarsızdır). İlk-3 isabeti %95,2'dir ve makaledeki değerle aynıdır; analiz örnekleminin kalibrasyon grubunda (n = 2.000) bu oran %88,1 idi, bu da en yüksek korelasyonlu eşin küçük örneklemde daha değişken belirlendiğiyle tutarlıdır. Alt ölçek içindeki uyum daha düşük ama güçlüdür (0,74). 42 maddenin 41'i kendi alt ölçeğine atanmıştır (%97,6); tek istisna olan kaygı maddesi Q09 (“I found myself in situations that made me so anxious I was most relieved when they ended”) stres maddelerine atanmıştır. Bu maddenin en yakın tek komşusu bir kaygı maddesidir (Q40), ama stres maddeleriyle ortalama kosinüsü (0,43) kaygı maddeleriyle olanından (0,35) yüksektir.</p>
<p>Model sözcüksel temel çizgiden belirgin biçimde yüksektir (TF-IDF: r = 0,27, sınıflama %76,2). Boyut kısaltıldıkça 861 çiftteki r küçük adımlarla azalır (0,81'den 0,75'e); diğer ölçütlerde düzenli bir örüntü yoktur. Denenen açık ağırlıklı modeller daha düşük değerler vermiştir (r = 0,57-0,72; ilk-3 %69-81; sınıflama %81-88). Form üyeliği 1.024 boyutta aynen korunmuş; 1.536 ve 512 boyutta yalnız kaygıda COV21 değişmiştir (4 ortak madde). Bunun nedeni, kaygıda en küçük iki CL değeri arasındaki farkın çok küçük olmasıdır (0,00003; depresyon ve streste yaklaşık 0,001; Ek B). 256 boyut, TF-IDF ve açık ağırlıklı modeller 4-7 ortak madde vermiştir. Formlar vektör temsiline bağlıdır; bu, modelin ve sürümünün raporlanmasını ve vektörlerin arşivlenmesini gerekli kılar.</p>""",
    soylenmez=['Denetimin modeli bütün modellerin en iyisi yaptığı; yalnız burada hesaplanabilen temsiller karşılaştırılmıştır.',
               'Kosinüs-korelasyon uyumunun anlamsal göstergelerin geçerliği için tek başına yeterli olduğu.',
               'Denetimin önceden belirlenmiş bir karar kuralı olduğu; denetim sonradan eklenmiştir.']))
EKLER.append(dict(
    id='ekB', no='Ek B', nav='COV21 eşit çözümleri', etiket='Ek', baslik='COV21 eşit çözümleri',
    ne='<p>Aynı en küçük CL\'yi veren bütün kümeler listelenir; bu kümelerin kuralın seçtiği COV21 ile ortak madde sayısı, değerlendirme grubundaki alfa ve RMSE aralığı ve en küçük CL ile ondan büyük ilk CL arasındaki fark yazılır.</p>',
    kod=('ekB', 'Ek B · COV21 eşit çözümleri', 'ekB'), ozet='Tablo B1', ogeler=[T_ekB],
    yapilan='<p>Her alt boyutta eşit çözümler 3.432 küme içinden bulunmuş ve 3.5\'teki psikometrik değerlerle eşleştirilmiştir.</p>',
    okuma=['Alfa ve RMSE aralığı dar ise COV21\'e ilişkin sonuçlar eşitlik bozma kuralına duyarlı değildir; geniş ise sonuçlar seçilen kümeye bağlıdır.'],
    yorum="""<p>Eşit çözüm sayısı depresyonda 16, kaygıda 2, streste 8'dir. Kuralın seçtiği COV21, eşit çözümler arasında her alt boyutta en yüksek alfayı verir; RMSE'si ise aralığın üst ucundadır (kaygıda en yüksek). Kaygıdaki diğer eşit çözümün RMSE'si 0,205'tir; bu değer PUB21'in RMSE'sinden (0,210) düşüktür. Dolayısıyla AS3'teki “COV21 kaygıda PUB21'den daha çok sapar” sonucu eşitlik bozma kuralına bağlıdır. Kaygıda en küçük CL ile sonraki değer arasındaki fark 3,2 × 10<sup>−5</sup>'tir; bu yüzden vektörlerdeki küçük değişiklikler de kaygıdaki COV21'i değiştirebilir (Ek A).</p>""",
    soylenmez=['Kuralın seçtiği kümenin tek veya en iyi COV21 olduğu.']))
EKLER.append(dict(
    id='ekC', no='Ek C', nav='Yanıt kalitesi (VCL)', etiket='Ek', baslik='Yanıt kalitesi (VCL) duyarlılığı',
    ne='<p>DASS arşivindeki sözcük listesinde VCL6, VCL9 ve VCL12 uydurma sözcüklerdir. Bunlardan en az birini “biliyorum” diye işaretleyen kayıtlar iki gruptan çıkarılır ve AS1, AS2, AS3 ve AS5\'in ana değerleri yeniden hesaplanır. Formlar, ISI ve kümeler yanıt verisi kullanmadığı için değişmez.</p>',
    kod=('ekC', 'Ek C · Yanıt kalitesi duyarlılığı', 'ekC'), ozet='Tablo C1', ogeler=[T_ekC],
    yapilan='<p>Kalibrasyon grubundan 366, değerlendirme grubundan 384 kayıt çıkarılmış; GRM, DFA ve bütün küme hesapları kalan kayıtlarla yinelenmiştir.</p>',
    okuma=['Farkların büyüklüğü ve form sıralarının korunup korunmadığı yazılır; dışlama sonrası değerler ana sonuçların yerine geçmez.'],
    yorum="""<p>Değişimler küçüktür: omega ve alfada en fazla 0,004, RMSE'de 0,003, AS5 katsayılarında 0,018. ISI ile a arasındaki ilişki 0,61-0,75 aralığında kalmıştır (en büyük değişim 0,044). Tek sıra değişikliği depresyon omegasındadır: PUB21 (0,916) ile COV21 (0,916) arasındaki 0,0005'lik fark dışlama sonrasında ters dönmüştür; bu iki formun depresyon omegası pratikte aynıdır.</p>""",
    soylenmez=['VCL işaretinin geçersiz yanıtı kesin olarak belirlediği; bu bir yanıt kalitesi göstergesidir.']))
EKLER.append(dict(
    id='ekD', no='Ek D', nav='Omega hesaplama biçimi', etiket='Ek', baslik='Kategorik omeganın iki hesaplama biçimi',
    ne='<p>Ana analizde omega, paydada modelin örtük yanıt varyansını kullanır (<code>obs.var = FALSE</code>). <code>obs.var = TRUE</code> paydada gözlenen polikorik matristen gelen varyansı kullanır; model uyumu kusursuz değilse iki değer ayrışabilir.</p>',
    kod=('ekD', 'Ek D · Omega hesaplama biçimi', 'ekD'), ozet='Tablo D1', ogeler=[T_ekD],
    yapilan='<p>AS2\'deki beş DFA modelinde omega iki biçimde hesaplanmıştır.</p>',
    okuma=['Fark büyükse omega değeri hesaplama biçimine duyarlıdır; formlar arasındaki sıra her iki biçimde de korunuyorsa AS2\'nin karşılaştırmalı yorumu etkilenmez.'],
    yorum="<p><code>obs.var = TRUE</code> bütün formlarda daha yüksek değer verir (fark 0,001-0,029). Kaygı ve streste formların sırası aynıdır. Depresyonda ise MIN21 ve COV21 bu biçimde PUB21'in üstüne çıkar (0,937, 0,937 ve 0,928); depresyondaki PUB21, MIN21 ve COV21 farkları hesaplama biçimine bağlı olduğundan yorumlanmaz.</p>",
    soylenmez=['İki biçimden birinin “doğru” omega olduğu; ana analizdeki biçim önceden belirlenmiştir.']))
EKLER.append(dict(
    id='ekE', no='Ek E', nav='Alfa farkları', etiket='Ek', baslik='Alfa farkları için eşleştirilmiş bootstrap',
    ne='<p>AS3\'teki 2.000 eşleştirilmiş bootstrap tekrarında hesaplanan alfa farkları (anlamsal form eksi PUB21) verilir; yeni hesap yapılmaz.</p>',
    kod=('ekE', 'Ek E · Alfa farkları', 'ekE'), ozet='Tablo E1', ogeler=[T_ekE],
    yapilan='<p>Alfa farkları ve %95 yüzdelik aralıkları AS3\'teki bootstrap çıktısından alınmıştır.</p>',
    okuma=['Aralık sıfırı dışlıyorsa fark bu örneklemin yeniden örneklemelerinde tutarlı yöndedir; sıfırı içermesi eşdeğerlik kanıtı değildir.'],
    yorum="<p>MAX21'in alfası üç alt boyutta PUB21'den yüksektir (0,020-0,041) ve aralıklar sıfırı dışlar. MIN21'in alfası kaygı ve streste düşüktür (−0,028 ve −0,017); depresyonda aralık sıfırı içerir. COV21 yalnız kaygıda belirgin biçimde düşüktür (−0,018).</p>",
    soylenmez=['Alfa farklarını omega farkları için geçerli saymak.']))
