# Üç sayfanın ortak metin ve tablo tanımları. Sayılar tablolardan okunur; metindeki sayılar son çalıştırmayla denetlenmiştir.
F = ['PUB21', 'MIN21', 'MAX21', 'COV21']
AD = {'D': 'Depresyon', 'A': 'Kaygı', 'S': 'Stres'}

def t(dosya, baslik, sutunlar, **k):
    d = dict(tur='tablo', dosya=dosya, baslik=baslik, sutunlar=sutunlar); d.update(k); return d

def adlandir(alan):
    def f(rows):
        for r in rows:
            if alan in r and r[alan] in AD: r[alan] = AD[r[alan]]
            if r.get('grup') == 'kal': r['grup'] = 'kalibrasyon'
            if r.get('grup') == 'deg': r['grup'] = 'değerlendirme'
        return rows
    return f

SAYFA_URL = {1: 'https://claude.ai/artifact/AhURgaACqyrmEv7wRx9oMt', 2: 'https://claude.ai/artifact/Jzb1GEqGGYxKvnwaYTkG8Q', 3: 'https://claude.ai/artifact/V2uhPiF26YVgjxwEo9ANnN'}

def sayfa_nav(etkin):
    ad = {1: '1 · Kod ve boş tablolar', 2: '2 · Sonuçlar', 3: '3 · Bulgular'}
    ak = ' aria-current="page"'
    return ''.join('<a href="' + SAYFA_URL[i] + '"' + (ak if i == etkin else '') + '>' + ad[i] + '</a>' for i in (1, 2, 3))

GENEL = {
    'kunye': ('<div><dt>Veri</dt><dd>Open-Source Psychometrics Project DASS arşivi, 39.775 kayıt</dd></div>'
              '<div><dt>Çalışma grubu</dt><dd>4.000 kişi: 2.000 kalibrasyon, 2.000 değerlendirme; model seçimi için ayrı 6.362 kişi</dd></div>'
              '<div><dt>Gömme modeli</dt><dd>text-embedding-3-large (3.072 boyut), altı model içinden önceden belirlenen ölçütle seçildi</dd></div>'
              '<div><dt>Tekrarlanabilirlik</dt><dd>Tohumlar 20260905, 260905, 20260913; R 4.5.3, lavaan 0.7-2, semTools 0.5-9, mirt 1.47</dd></div>'),
    1: dict(title='DASS-42 Analiz Kodu', ust='Yüksek lisans tezi · Sayfa 1 / 3',
            h1='DASS-42 Analiz Kodu',
            giris='Hazırlıktan beş araştırma sorusuna kadar adım adım ilerleyen R kodu ve her adımın üreteceği tabloların iskeleti. Bu sayfada hiçbir sonuç yoktur; kısa formlar da verilmez, kodun içinde madde metinlerinden oluşturulur.',
            son_not='Bu sayfa sonuç içermez. Sonuçlar 2. sayfada, yorumlu bulgular 3. sayfadadır. Kod, kabul denetiminden 279/279 ile geçen şablon betiğinin blok blok düzenlenmiş hâlidir; aynı 275 değeri farksız üretir.'),
    2: dict(title='DASS-42 Analiz Sonuçları', ust='Yüksek lisans tezi · Sayfa 2 / 3',
            h1='DASS-42 Analiz Sonuçları',
            giris='1. sayfadaki kodun bu çalışmada çalıştırılmasıyla elde edilen gerçek tablolar ve şekiller. Yorum yoktur; yorumlu anlatım 3. sayfadadır.',
            ust_metin=('<section id="calistirma"><h2>Çalıştırma kaydı</h2><div class="tablo-kap"><table><tbody>'
                       '<tr><th scope="row">Tarih</th><td>28 Eylül 2026, tek parça betik (<code>dass42_tam_analiz.R</code>), yaklaşık 2 dakika</td></tr>'
                       '<tr><th scope="row">Ortam</th><td>R 4.5.3, lavaan 0.7.2, semTools 0.5.9, mirt 1.47 (paketteki sabit conda-forge ortamı)</td></tr>'
                       '<tr><th scope="row">Tohumlar</th><td>Örneklem 20260905, bölme 260905, bootstrap 20260913 + tekrar numarası (B = 2.000)</td></tr>'
                       '<tr><th scope="row">Girdiler</th><td>DASS arşivi SHA-256 38d1707c…, gömme vektörleri fd765117…, başvuru bölmesiyle aynı örneklem</td></tr>'
                       '<tr><th scope="row">Denetim</th><td>174 iç denetimin hepsi geçti; 21 tablo ve 275 değer, kabul denetimli şablon çalıştırmasıyla (279/279) farksız aynı</td></tr>'
                       '</tbody></table></div></section>'),
            son_not='Sayılar ondalık virgülle; korelasyonlar iki, RMSE ve uyum değerleri üç, yüzdelikler bir, bootstrap farkları dört ondalıkla yazılmıştır.'),
    3: dict(title='DASS-42 Bulgular', ust='Yüksek lisans tezi · Sayfa 3 / 3',
            h1='DASS-42 Bulgular',
            giris='Her adımda ne yapıldığı, elde edilen tablo ve şekiller ve bunların nasıl yorumlanacağı. İlgili R kodu her bölümün altında, tıklayınca açılır.',
            son_not='Bu sayfadaki yorumlar ANALIZ_REHBERI.md kurallarına göre yazılmıştır ve tezin bulgular bölümü için bir okuma kılavuzudur; tez metni Berkcan\'ın kendi anlatımıyla yazılır. Hazırlayan: Claude Code, 28 Eylül 2026.'),
}
for i in (1, 2, 3): GENEL[i]['sayfalar'] = sayfa_nav(i)

KAYNAKLAR = []  # alanyazın bölümünden sonra doldurulur

TANIMLAR = ('<dl class="tanim">'
            '<dt>ISI</dt><dd>Bir maddenin aynı alt boyuttaki diğer 13 maddeyle ortalama kosinüs benzerliği.</dd>'
            '<dt>SB</dt><dd>Anlamsal genişlik: 1 eksi seçilen yedi maddenin 21 çiftinin ortalama kosinüs benzerliği. Yüksek SB daha çeşitli seçim demektir.</dd>'
            '<dt>CL</dt><dd>Temsil kaybı: alt boyuttaki 14 maddenin her birinin en yakın seçili maddeye uzaklığının (1 eksi kosinüs) ortalaması. Seçili maddeler sıfır uzaklıkla katılır. Düşük CL daha iyi temsil demektir.</dd>'
            '<dt>CL_b</dt><dd>Bölünme temsil kaybı: 14 maddenin her birinin karşı yarıdaki en yakın maddeye ortalama uzaklığı; bir küme ile tümleyeninde aynıdır.</dd>'
            '<dt>MIN21, MAX21, COV21</dt><dd>Her alt boyutta ISI en düşük yedi madde, ISI en yüksek yedi madde ve CL en küçük yedili küme. Yayımlanmış DASS-21 (PUB21) ile birlikte dört kısa form karşılaştırılır.</dd>'
            '</dl>')

BOLUMLER = []

KAYNAKLAR[:] = [
 'Cai, L., &amp; Monroe, S. (2014). <em>A new statistic for evaluating item response theory models for ordinal data</em> (CRESST Report 839). UCLA/CRESST.',
 'Christensen, K. B., Makransky, G., &amp; Horton, M. (2017). Critical values for Yen\'s Q3. <em>Applied Psychological Measurement, 41</em>(3), 178-194. https://doi.org/10.1177/0146621616677520',
 'Hommel, B. E., &amp; Arslan, R. C. (2025). Language models accurately infer correlations between psychological items and scales from text alone. <em>Advances in Methods and Practices in Psychological Science</em>. https://doi.org/10.1177/25152459251377093',
 'Kilmen, S., &amp; Bulut, O. (2025). Shortening psychological scales: Semantic similarity matters. <em>Educational and Psychological Measurement, 85</em>(5), 910-934. https://doi.org/10.1177/00131644251319047',
 'Kojima, Soda ve Yamashita (2025). Language or syndrome? <em>Psychiatry and Clinical Neurosciences</em>. https://doi.org/10.1111/pcn.70010',
 'Maydeu-Olivares, A. (2013). Goodness-of-fit assessment of item response theory models. <em>Measurement, 11</em>(3), 71-101. https://doi.org/10.1080/15366367.2013.831680',
 'Maydeu-Olivares, A., &amp; Joe, H. (2014). Assessing approximate fit in categorical data analysis. <em>Multivariate Behavioral Research, 49</em>(4), 305-328. https://doi.org/10.1080/00273171.2014.911075',
 'McElroy, E., Wood, T., Bond, R., vd. (2024). Using natural language processing to facilitate the harmonisation of mental health questionnaires. <em>BMC Psychiatry, 24</em>, 530. https://doi.org/10.1186/s12888-024-05954-2',
 'McNeish, D., An, J., &amp; Hancock, G. R. (2018). The thorny relation between measurement quality and fit index cutoffs in latent variable models. <em>Journal of Personality Assessment, 100</em>(1), 43-52. (Künye bu çalışmada ayrıca doğrulanmadı.)',
 'Muennighoff, N., Tazi, N., Magne, L., &amp; Reimers, N. (2023). MTEB: Massive Text Embedding Benchmark. <em>Proceedings of EACL 2023</em>, 2014-2037. https://doi.org/10.18653/v1/2023.eacl-main.148',
 'Pellert, M., Lechner, C., Sen, I., &amp; Strohmaier, M. (2025). Neural network embeddings recover value dimensions from psychometric survey items on par with human data. arXiv:2509.24906.',
 'Ravenda, F., Preti, A., Poletti, M., vd. (2025). Rethinking psychometrics through LLMs: how item semantics shape measurement and prediction in psychological questionnaires. <em>Scientific Reports, 15</em>, 37313. https://doi.org/10.1038/s41598-025-21289-8',
 'Russell-Lasalandra, L. L., Christensen, A. P., &amp; Golino, H. (2026). AI-GENIE. <em>Behavior Research Methods, 58</em>, 217. https://doi.org/10.3758/s13428-026-03082-1 (künye arama sonucundan; ayrıca doğrulanmadı)',
 'Samejima, F. (1969). Estimation of latent ability using a response pattern of graded scores. <em>Psychometrika Monograph Supplement, 17</em>.',
 'Wulff, D. U., &amp; Mata, R. (2025). Semantic embeddings reveal and address taxonomic incommensurability in psychological measurement. <em>Nature Human Behaviour, 9</em>, 944-954. https://doi.org/10.1038/s41562-024-02089-y',
]

def secici(**kosul):
    return lambda r: all(r.get(k) == v for k, v in kosul.items())

ASAMA = {'ham': 'Arşivdeki kayıt', 'yas_18_80': 'Yaşı 18-80', 'anadil_ingilizce': 'Ana dili İngilizce', 'eksiksiz_gecerli': '42 madde eksiksiz (uygun havuz)'}
def asama_ad(rows):
    for r in rows: r['asama'] = ASAMA.get(r['asama'], r['asama'])
    return rows
def grup_ad(rows):
    m = {'toplam': 'Toplam (4.000)', 'kalibrasyon': 'Kalibrasyon', 'degerlendirme': 'Değerlendirme'}
    for r in rows: r['grup'] = m.get(r['grup'], r['grup'])
    return rows
def top3_yuzde(rows):
    for r in rows:
        r['top3p'] = str(100 * float(r['top3'])); r['loop'] = str(100 * float(r['loo_dogruluk']))
    return rows

BOLUMLER[:] = [
 dict(id='amac', no='1', kisa='Amaç ve göstergeler', baslik='Amaç ve göstergeler',
      yapilan=('<p>Çalışmanın temel sorusu şudur: madde metinlerinden farklı hedeflerle yapılan seçimler, psikometrik açıdan nasıl kısa formlar ortaya çıkarır? Bu soru, Depresyon Anksiyete Stres Ölçeği\'nin 42 maddelik sürümünde (DASS-42) üç düzeyde yanıtlanır: madde düzeyi (AS1), form düzeyi (AS2, AS3, AS4) ve bir alt boyuttan seçilebilecek bütün yedili formlar düzeyi (AS5).</p>'
               '<p>Anlamsal seçim, maddelerin yanıt verisine bakılmadan yalnız metinlerinden seçilmesidir. Metinler bir gömme modeliyle sayısal vektörlere çevrilir; iki maddenin anlamca ne kadar benzediği bu vektörler arasındaki kosinüs benzerliğiyle ölçülür. Kısa formlar bu sayfada hazır verilmez: hangi maddelerin seçileceği, H4 adımında kodun kendisi tarafından belirlenir.</p>' + TANIMLAR),
      kisa_not='Göstergelerin tanımları 1. ve 3. sayfadadır.'),
 dict(id='h1', no='H1', kisa='Paketler ve tanımlar', baslik='H1. Paketler, ayarlar ve tanım fonksiyonları', sayfalar=(1, 3),
      yapilan='<p>Paketleri denetler, ayarları (tohumlar, örneklem büyüklükleri, toleranslar) ve bütün göstergelerin tanım fonksiyonlarını yükler: ISI, SB, CL, CL_b, alfa, RMSE, orta sıra yüzdeliği, GRM ve DFA kurulumu. Bu adım tablo üretmez.</p>',
      kodlar=[dict(dosya='H1', ad='H1 · Paketler, ayarlar ve tanım fonksiyonları')]),
 dict(id='h2', no='H2', kisa='Veri ve örneklem', baslik='H2. Veri ve örneklem',
      yapilan='<p>Arşivin SHA-256 özetini denetler; yaşı 18-80, ana dili İngilizce olan ve 42 maddeyi 1-4 aralığında eksiksiz yanıtlayan kayıtları seçer. Uygun havuzdan 4.000 kayıt rastgele seçilir (tohum 20260905) ve 2.000 kalibrasyon ile 2.000 değerlendirme grubuna ayrılır (tohum 260905). Bölmenin başvuru bölmesiyle aynı olduğu denetlenir.</p>',
      kodlar=[dict(dosya='H2', ad='H2 · Veri, örneklem ve gruplar')],
      ogeler=[t('orneklem_akisi.csv', 'Tablo H2.1. Örneklem akışı', [('asama', 'Aşama', None), ('n', 'Kayıt sayısı', 'int')], donustur=asama_ad),
              t('orneklem_betimleme.csv', 'Tablo H2.2. Çalışma grubunun betimlemesi', [('grup', 'Grup', None), ('n', 'n', 'int'), ('yas_ort', 'Yaş ort.', 2), ('yas_ss', 'Yaş SS', 2), ('kadin_yzd', 'Kadın %', 1), ('erkek_yzd', 'Erkek %', 1), ('diger_yzd', 'Diğer %', 1), ('yanitsiz_yzd', 'Yanıtsız %', 1)], donustur=grup_ad)],
      bulgu=('<p>Arşivdeki 39.775 kayıttan 10.362\'si uygun havuzu oluşturmuştur. Çalışma grubunun yaş ortalaması 28,13 (SS = 11,82) olup katılımcıların %71,2\'si kadın, %26,3\'ü erkek, %2,4\'ü diğer seçeneğini işaretlemiş, %0,2\'si yanıtsızdır. Kalibrasyon ve değerlendirme grupları betimsel olarak birbirine çok yakındır.</p>'
             '<p>Yorum sınırı: kayıtlar ayrık satırlardır ve aynı kişinin birden fazla kayıt vermediği doğrulanamaz; örneklem çevrimiçi ve gönüllüdür. Tasarım ilk sonuçlardan sonra genişletildiği için değerlendirme grubu hiç bakılmamış bir doğrulama örneklemi olarak sunulmaz.</p>')),
 dict(id='h3', no='H3', kisa='Gömme modelinin seçimi', baslik='H3. Gömme modelinin seçimi',
      yapilan=('<p>Altı gömme modeli, sonuçlara bakılmadan belirlenen bir ölçütle karşılaştırılır. Ana ölçüt, alt boyut içindeki 273 madde çiftinde kosinüs benzerliği ile polikorik korelasyon arasındaki Spearman ilişkisidir; çünkü ISI, SB ve CL göstergelerinin hepsi alt boyut içi benzerliklere dayanır. Ölçüt, analize hiç girmeyen 6.362 uygun kayıtta hesaplanır; böylece model seçimi kalibrasyon ve değerlendirme gruplarına dokunmaz.</p>'
               '<p>Karşılaştırılan modeller: text-embedding-3-large (OpenAI, 3.072 boyut; vektörler Ravenda vd., 2025 yayın arşivinden), multilingual-e5-large, bge-base-en-v1.5, bge-base-en, bge-small-en ve all-MiniLM-L6-v2. Açık modellerin vektörleri aynı madde metinlerinden ONNX sürümleriyle yerel olarak üretilmiştir.</p>'),
      kodlar=[dict(dosya='H3', ad='H3 · Gömme modelinin seçimi (analiz dışı 6.362 kayıt)')],
      ogeler=[t('tablo_H3_model_secimi.csv', 'Tablo H3.1. Gömme modellerinin karşılaştırılması (model seçim grubu, n = 6.362)',
                [('model', 'Model', None), ('boyut', 'Boyut', 'int'), ('rho_alt_boyut_ici', 'Alt boyut içi ρ (ana ölçüt)', 3), ('rho_D', 'ρ D', 3), ('rho_A', 'ρ A', 3), ('rho_S', 'ρ S', 3), ('rho_861_cift', '861 çift ρ', 3), ('top3p', 'Top-3 %', 1), ('ic_eksi_dis', 'İç eksi dış kosinüs', 3), ('loop', 'Alt boyut doğruluğu %', 1)],
                donustur=top3_yuzde, not_='')],
      okuma='<p>Ana ölçüt sütununda en yüksek değeri veren model seçilir. Kod, seçilen modelin arşivdeki vektörlerle aynı olduğunu denetler; değilse durur ve analizin yeni vektörlerle yeniden çalıştırılması gerektiğini bildirir.</p>',
      bulgu=('<p><strong>Seçilen model: text-embedding-3-large.</strong> Önceden belirlenen ana ölçütte en yüksek değeri vermiştir (ρ = 0,685; ikinci sıradaki multilingual-e5-large 0,671). Üstünlük yan ölçütlerin hepsinde de görülür: bütün 861 çiftte ρ = 0,760, Top-3 doğruluğu %95,2 (en yakın ikinci model %81), yanıt verisi kullanmayan alt boyut doğruluğu %97,6. Alt boyutlara göre fark depresyon ve streste küçük (ör. bge-small-en D\'de 0,812, bge-base-en-v1.5 S\'de 0,725), kaygıda belirgindir (0,706; açık modellerde en yüksek 0,659).</p>'
             '<p><strong>Alanyazınla tutarlılık.</strong> Ravenda vd. (2025) aynı DASS-42 arşivi ve aynı text-embedding-3-large vektörleriyle kosinüs ile ampirik korelasyonlar arasında r = 0,77 ve %95 Top-3 doğruluğu bildirmiştir; bu değerler onların deposundaki veriden bağımsız olarak yeniden üretilmiştir ve buradaki analiz dışı grupta da benzer değerler bulunmuştur (ρ = 0,76, %95,2). Klinik maddelerde OpenAI modellerinin SBERT türü modellerden yanıt matrisine daha iyi uyduğu Kojima vd. (2025) tarafından da bildirilmiştir; genel amaçlı SBERT ile McElroy vd. (2024) klinik maddelerde r = 0,48 bulmuştur. Hazır (ince ayarsız) modeller arasında büyük API modellerinin üstünlüğü tutarlı ama sınırlı bir kanıta dayanır; en büyük kazançlar alana özgü ince ayarlı modellerden gelir (Hommel ve Arslan, 2025; Wulff ve Mata, 2025).</p>'
             '<p><strong>Neden ince ayarlı bir model seçilmedi?</strong> SurveyBot3000 (Hommel ve Arslan, 2025) eğitim verisine bu DASS arşivini de almıştır; bu veride kullanılırsa sonuç yanıt verisinden sızmış olur ve "yanıt verisi kullanmadan seçim" öncülü bozulur. Kilmen ve Bulut (2025) BERT türü 768 boyutlu gömmeler kullanmıştır; bu çalışmadaki karşılaştırma bu sınıftaki açık modellerin DASS\'ta daha zayıf kaldığını göstermektedir.</p>'
             '<p><strong>Merkezleme.</strong> Pellert vd. (2025) anket maddelerinde ortalama gömmenin çıkarılmasını (anizotropiyi azaltmak için) önermiştir. DASS\'ta bütün maddeler aynı yönde belirti ifadeleri olduğundan merkezleme uyumu bütün modellerde düşürmüştür (text-embedding-3-large için 861 çiftte 0,760\'tan 0,587\'ye); bu nedenle ham kosinüs kullanılır.</p>'
             '<p><strong>Sınırlar.</strong> Ağ kısıtları nedeniyle text-embedding-3-small, Gemini, Cohere, Voyage ve Qwen3-Embedding gibi modeller denenemedi; bu modellerle psikometrik madde ilişkisi karşılaştıran yayımlanmış bir çalışma da bulunamadı. text-embedding-3-large vektörleri yeni bir API çağrısıyla değil, yayın arşivinden alınmıştır; bu, sonuçların yeniden üretilebilirliğini artırır (API modelleri zamanla değişebilir), ancak arşive giren metnin bayt düzeyinde aynı olduğu doğrulanamamıştır. Seçim, analiz dışı kayıtların yanıtlarını kullanır; bu yüzden "hiç yanıt verisi kullanılmadı" yerine "model seçimi analize girmeyen kayıtlarla yapıldı" denmelidir. Seçilen model tezin önceki kararıyla aynı olduğu için formlar ve başvuru değerleri değişmemiştir.</p>')),
 dict(id='h4', no='H4', kisa='Anlamsal göstergeler ve formlar', baslik='H4. Anlamsal göstergeler ve dört form',
      yapilan='<p>Seçilen modelin vektörlerinden 42 × 42 kosinüs matrisi hesaplanır. Her alt boyutta ISI değerleri bulunur; MIN21 ve MAX21 en düşük ve en yüksek ISI\'ye sahip yedi maddeden oluşur. Her alt boyutun 3.432 yedili kümesi için SB, CL ve CL_b hesaplanır; COV21 en küçük CL\'yi veren kümedir (eşitlikte madde numarası sırasıyla ilki). PUB21 yayımlanmış DASS-21\'dir.</p>',
      kodlar=[dict(dosya='H4', ad='H4 · Kosinüs matrisi, ISI, bütün yedili kümeler ve dört form')],
      ogeler=[t('tablo_formlar.csv', 'Tablo H4.1. Dört kısa formun maddeleri (DASS-42 madde numaraları)', [('form', 'Form', None), ('D', 'Depresyon', None), ('A', 'Kaygı', None), ('S', 'Stres', None)])],
      bulgu=('<p>Formlar kodun içinde yalnız madde metinlerinden oluşmuştur. MIN21 ile MAX21 her alt boyutta birbirinin tümleyenidir. COV21\'in en küçük CL\'yi veren tek küme olmadığı görülmüştür: depresyonda 16, kaygıda 2, streste 8 eşit küme vardır (Ekler bölümü). Formlar, tezin önceki kararındaki üyeliklerle birebir aynıdır.</p>')),
 dict(id='h5', no='H5', kisa='Alt küme tablosu', baslik='H5. Alt küme tablosu: bütün yedili kümeler',
      yapilan='<p>Her alt boyutta 3.432 yedili kümenin tamamı için iki grupta alfa, yanlılık, s_d, RMSE ve kısa-tam r hesaplanır (tamsayı toplamlarıyla; eşit değerler eşit kalır). Dört formun her göstergedeki orta sıra yüzdeliği değerlendirme grubunda bulunur. Bu tablo AS2, AS3 ve AS4\'te formların konumunu, AS5\'te bütün kümeler üzerindeki ilişkileri verir.</p>',
      kodlar=[dict(dosya='H5', ad='H5 · Bütün yedili kümelerin psikometrik değerleri ve form yüzdelikleri')],
      okuma='<p>Yüzdelik orta sıra yöntemiyle hesaplanır. Alfa ve SB\'de yüksek yüzdelik daha yüksek değeri; RMSE ve CL\'de düşük yüzdelik daha küçük sapmayı ya da daha az temsil kaybını gösterir. Örneğin 90. yüzdelikteki bir alfa, formun olası yedili seçimlerin yaklaşık %90\'ından daha iç tutarlı olduğunu gösterir.</p>',
      bulgu='<p>Bu adımın tabloları (<code>tum_alt_kumeler.csv</code>, 20.592 satır; <code>tablo_form_yuzdelikleri.csv</code>) ilgili soruların bölümlerinde kullanılır. Yüzdelikler betimseldir; kümeler ortak maddeler içerdiği için bağımsız gözlem sayılmaz ve p değeri verilmez.</p>'),
]

def ad_ve_grup(rows):
    for r in rows:
        if r.get('subscale') in AD: r['subscale'] = AD[r['subscale']]
        if r.get('grup') == 'kal': r['grup'] = 'Kalibrasyon'
        if r.get('grup') == 'deg': r['grup'] = 'Değerlendirme'
    return rows
AG = [('subscale', 'Alt boyut', None), ('grup', 'Grup', None)]
FA = [('form', 'Form', None), ('subscale', 'Alt boyut', None)]

BOLUMLER += [
 dict(id='as1', no='AS1', kisa='Madde düzeyi', soru="DASS-42'nin her alt boyutunda, maddelerin aynı alt boyuttaki diğer maddelerle ortalama anlamsal benzerliği ile GRM altında kestirilen ayırt edicilik parametreleri arasında nasıl bir ilişki vardır?",
      yapilan='<ul><li>Her alt boyutun 14 maddesine tek boyutlu dereceli tepki modeli (GRM; Samejima, 1969) kalibrasyon grubunda kestirilir; aynı analiz değerlendirme grubunda tekrarlanır.</li><li>14 ISI değeri ile 14 ayırt edicilik (a) parametresi arasındaki Spearman korelasyonu hesaplanır. Modelden bağımsız destek olarak ISI ile düzeltilmiş madde-toplam korelasyonu (CITC) arasındaki ilişki verilir.</li><li>Model tanısı için C2 temelli uyum (Cai ve Monroe, 2014) ve ortalaması çıkarılmış Q3 incelenir; 91 madde çiftinde kosinüs ile Q3 arasındaki ilişki ve en yüksek üç Q3 çifti raporlanır. Madde düzeyinde güven aralığı hesaplanmaz.</li></ul>',
      kodlar=[dict(dosya='AS1', ad='AS1 · GRM, ISI-a ilişkisi ve tanılar'), dict(dosya='SEKIL1', ad='AS1 · Şekil: ISI ve a')],
      ogeler=[t('tablo_AS1_ISI_a.csv', 'Tablo AS1.1. ISI ile ayırt edicilik arasındaki Spearman ilişkileri', AG + [('rho_ISI_a', 'ρ(ISI, a)', 2), ('rho_ISI_CITC', 'ρ(ISI, CITC)', 2), ('rho_a_CITC', 'ρ(a, CITC)', 3)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_AS1_GRM_tani.csv', 'Tablo AS1.2. GRM tanıları', AG + [('C2', 'C2', 1), ('df', 'sd', 'int'), ('RMSEA', 'C2 RMSEA', 3), ('SRMSR', 'SRMSR', 3), ('maks_Q3', 'En büyük düzeltilmiş Q3', 2), ('q3_esik_ustu_cift', 'Düzeltilmiş Q3 > 0,20 çift', 'int')], donustur=ad_ve_grup, anahtar=2, **{'not': 'Bütün C2 testlerinde p < 0,001.'}),
              t('tablo_AS1_kosinus_Q3.csv', 'Tablo AS1.3. Kosinüs-Q3 ilişkisi ve en yüksek üç düzeltilmiş Q3 çifti', AG + [('rho_cos_Q3', 'ρ(kosinüs, Q3)', 2), ('sira', 'Sıra', 'int'), ('cift', 'Çift', None), ('Q3', 'Q3', 2), ('kosinus', 'Kosinüs', 2), ('birlikte_formlar', 'Birlikte olduğu formlar', None)], donustur=ad_ve_grup, anahtar=2),
              dict(tur='sekil', dosya='sekil_AS1_ISI_a.png', baslik='Şekil AS1. ISI ve GRM ayırt ediciliği (kalibrasyon grubu)', alt='Üç panelde 14 maddenin ISI ve a değerleri; noktalar sağa doğru yükseliyor.', aciklama='Her nokta bir maddedir; panel başlığında Spearman rho.')],
      okuma='<ul><li><code>rho_ISI_a</code> pozitifse diğer maddelere anlamca daha benzer maddelerin a değeri daha yüksek olma eğilimindedir; negatifse tersi. |ρ| &lt; 0,30 zayıf, 0,30-0,50 orta, 0,50 ve üstü güçlü diye adlandırılır (başarı eşiği değildir).</li><li>Kalibrasyon, değerlendirme ve CITC aynı yönü gösterirse ilişki tutarlı sayılır.</li><li>GRM uyumu zayıfsa a, "bu model altında kestirilen ayırt edicilik" diye adlandırılır.</li></ul>',
      bulgu=('<p>Üç alt boyutta ve iki grupta ISI ile a arasındaki ilişki pozitif ve güçlüdür: kalibrasyonda 0,63, 0,63 ve 0,79; değerlendirmede 0,73, 0,70 ve 0,69. Bu 14 maddelik havuzlarda, diğer maddelere anlamca daha benzer maddelerin bu model altında kestirilen ayırt ediciliği daha yüksek olma eğilimindedir. ISI ile CITC arasındaki ilişki aynı yöndedir (0,60 ile 0,75), dolayısıyla ilişki rehberin tanımıyla tutarlıdır. a ile CITC maddeleri hemen hemen aynı sırayla dizer (0,89 ile 0,99); CITC\'nin desteği sonucun model seçimine karşı sağlam olduğunu gösterir, bağımsız ikinci bir kanıt değildir. Şekilde en düşük ISI\'ye sahip maddelerin (D\'de Q42 ve Q05, A\'da Q02) a değerlerinin de düşük olduğu görülür.</p>'
             '<p><strong>Model tanıları.</strong> C2 temelli RMSEA D\'de 0,122 ve 0,133, S\'de 0,115 ve 0,116, A\'da 0,080 ve 0,093\'tür. Maydeu-Olivares ve Joe\'nun (2014) M2 temelli RMSEA2 için önerdiği ölçütlerle (0,05 yakın, 0,089 kabul edilebilir) yaklaşık bir okuma yapılırsa uyum D ve S\'de zayıf, A\'da sınırdadır; bu ölçütler C2 için doğrudan geçerli değildir. SRMSR 0,045 ile 0,061 arasındadır ve yakın uyum için önerilen 0,05\'e yakındır (Maydeu-Olivares, 2013). Bu örüntü, uyumsuzluğun birkaç madde çiftinde toplanmış olabileceğini düşündürür: düzeltilmiş Q3 tarama eşiğini (0,20; Christensen vd., 2017) D\'de 7 ve 10, S\'de 6, A\'da 3 çift aşar. Bu nedenle a değerleri tezde "bu model altında kestirilen ayırt edicilik" diye adlandırılmalı ve tanılar bulgunun yanında verilmelidir.</p>'
             '<p><strong>Kosinüs ve Q3.</strong> İlişki altı durumda da pozitif ve orta büyüklüktedir (0,33 ile 0,45). Anlamca daha yakın çiftlerde ortak faktörün açıklamadığı ilişki daha yüksek olma eğilimindedir. Örnekler: Q07-Q41 ("shakiness" ve "trembling", kosinüs 0,71), Q17-Q34 (değersizlik duygusu, 0,82). D\'nin kalibrasyondaki en yüksek çifti Q05-Q42\'nin kosinüsü daha düşüktür (0,55), oysa iki metin birbirine çok yakındır; bu, kosinüsün içerik örtüşmesinin hepsini yansıtmayabileceğini düşündürür. 91 çift ortak maddeler içerdiği için bağımsız gözlem değildir.</p>'
             '<p><strong>Önceki çalışma.</strong> Kilmen ve Bulut (2025) ECR kaygı alt boyutunda negatif bir ilişki (r = −0,55) bildirmiş, ters puanlanan maddeler içeren kaçınma alt boyutunda ilişki gözlememiştir. Buradaki yön pozitiftir; bu, yanlışlama olarak değil, ilişkinin ölçeğe ve koşullara bağlı olabileceği biçiminde yazılır.</p>'),
      soylenmez=['Anlamsal benzerliğin ayırt ediciliği artırdığı gibi nedensel bir sonuç.', '14 maddenin ötesine, madde evrenine genelleme.', 'Kosinüs-Q3 ilişkisinin a veya güvenirlikteki olası şişmenin miktarını gösterdiği.', 'Kilmen ve Bulut (2025) ile yön farkının yanlışlama sayılması.']),
 dict(id='as2', no='AS2', kisa='Yapı ve güvenirlik', soru='Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21, faktör yapısı ve alt boyut puanlarının güvenirliği bakımından nasıl farklılaşmaktadır?',
      yapilan='<ul><li>Değerlendirme grubunda beş forma (FULL42 başvuru noktası) üç ilişkili faktörlü sıralı DFA (WLSMV) kurulur: ölçeklenmiş χ², CFI, TLI, RMSEA ve %90 aralığı, SRMR, standartlaştırılmış yükler, faktör korelasyonları.</li><li>Güvenirliğin ana göstergesi kategorik omegadır; ham alfa yardımcıdır ve 3.432 kümedeki yüzdeliğiyle konumlandırılır.</li></ul>',
      kodlar=[dict(dosya='AS2', ad='AS2 · Sıralı DFA, yükler, faktör korelasyonları, omega ve alfa')],
      ogeler=[t('tablo_AS2_DFA_uyum.csv', 'Tablo AS2.1. Üç faktörlü sıralı DFA uyumu (değerlendirme grubu)', [('form', 'Form', None), ('n_madde', 'Madde', 'int'), ('chisq.scaled', 'χ² (ölçekl.)', 1), ('df.scaled', 'sd', 'int'), ('cfi.scaled', 'CFI', 3), ('tli.scaled', 'TLI', 3), ('rmsea.scaled', 'RMSEA', 3), ('rmsea.ci.lower.scaled', 'RMSEA alt', 3), ('rmsea.ci.upper.scaled', 'RMSEA üst', 3), ('srmr', 'SRMR', 3)], **{'not': 'Bütün χ² testlerinde p < 0,001.'}),
              t('tablo_AS2_guvenirlik.csv', 'Tablo AS2.2. Alt boyut güvenirliği', FA + [('omega', 'Omega', 3), ('alfa', 'Alfa', 3), ('omega_obsvar_true', 'Omega (obs.var = TRUE, ek)', 3)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_form_yuzdelikleri.csv', 'Tablo AS2.3. Alfanın 3.432 yedili küme içindeki yüzdeliği (değerlendirme grubu)', FA + [('alfa', 'Alfa', 3), ('alfa_yzd', 'Alfa yüzdeliği', 1)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_AS2_faktor_korelasyonlari.csv', 'Tablo AS2.4. Faktörler arası korelasyonlar', [('form', 'Form', None), ('cift', 'Çift', None), ('r', 'r', 2)], anahtar=2)],
      okuma='<p>Uyum değerleri yan yana betimlenir; formlar uyum indekslerine göre sıralanmaz. Omega farklarının büyüklüğü yazılır; anlamca dar bir formun yüksek güvenirliği "daha homojen puan" demektir.</p>',
      bulgu=('<p><strong>Yapı.</strong> Beş formda da model yakınsamış ve kabul edilebilir çözüm vermiştir. Kısa formlarda CFI 0,959 ile 0,968, TLI 0,954 ile 0,964, RMSEA 0,063 ile 0,079, SRMR 0,041 ile 0,047 arasındadır. Farklı madde kümeleri iç içe model olmadığı ve yükler yükseldikçe aynı yanlış belirlemede RMSEA kötüleşebildiği için formlar sıralanmaz (McNeish vd., 2018). Bu veride bunun somut bir örneği vardır: en yüksek yüklere sahip MAX21 (ortalama 0,87, 0,78 ve 0,79) en yüksek RMSEA\'yı (0,079) verir.</p>'
             '<p><strong>Güvenirlik.</strong> Omega örüntüsü üç alt boyutta aynıdır: en yüksek MAX21 (0,936, 0,889, 0,901), en düşük MIN21 (0,914, 0,830, 0,845); PUB21 ve COV21 arada ve birbirine çok yakındır (D\'de 0,916 ve 0,916). MAX21\'in alfası bütün yedili kümelerin 92,3., 99,4. ve 98,8. yüzdeliğinde, MIN21\'inki 5,8., 1,3. ve 0,1. yüzdeliğindedir. Anlamca birbirine en benzer maddelerden oluşan MAX21\'in yüksek güvenirliği "daha homojen puan" olarak okunur, "daha iyi ölçme" olarak değil. PUB21\'e göre alfa farklarının bootstrap aralıkları Ekler bölümündedir.</p>'
             '<p><strong>Faktör korelasyonları.</strong> En çok değişen kaygı-stres korelasyonudur: MIN21\'de 0,89, PUB21\'de 0,84, MAX21\'de 0,76. Daha düşük korelasyon tek başına daha iyi form anlamına gelmez.</p>'),
      soylenmez=['Formların uyum indekslerine göre sıralanması veya ΔCFI ve ΔRMSEA eşikleriyle kazanan seçilmesi.', 'Daha düşük faktör korelasyonunun tek başına daha iyi form anlamına geldiği.', 'Yüksek güvenirliğin "daha iyi ölçme" olduğu.', 'Alfa için hesaplanan aralıkların omega aralığı olduğu.']),
 dict(id='as3', no='AS3', kisa='Tam form uyumu', soru="Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21'in alt boyut puanları, DASS-42'nin ilgili alt boyut puanlarıyla ne ölçüde uyumludur?",
      yapilan='<ul><li>Değerlendirme grubundaki 2.000 kişi için kısa (7 madde) ve tam (14 madde) madde ortalamaları (0-3) hesaplanır.</li><li>Her form ve alt boyut için Pearson r, yanlılık (kısa eksi tam), s_d ve ham RMSE bulunur; RMSE² = yanlılık² + s_d² eşitliğiyle sapmanın kaynağı ayrılır.</li><li>RMSE\'nin 3.432 kümedeki yüzdeliği ve r\'nin bütün kümelerdeki medyanı verilir. Anlamsal formların PUB21\'den RMSE farkı, aynı kişilerin yeniden çekildiği eşleştirilmiş bootstrap ile (B = 2.000, tohum 20260913 + tekrar no) değerlendirilir.</li></ul>',
      kodlar=[dict(dosya='AS3', ad='AS3 · Kısa ve tam puan uyumu'), dict(dosya='BOOT', ad='AS3 · Eşleştirilmiş bootstrap (RMSE ve alfa farkları)')],
      ogeler=[t('tablo_AS3_uyum.csv', 'Tablo AS3.1. Kısa ve tam alt boyut puanlarının uyumu (değerlendirme grubu)', FA + [('r', 'r', 3), ('bias', 'Yanlılık', 3), ('sd_d', 's_d', 3), ('rmse', 'RMSE', 3), ('rmse_0_42', 'RMSE (0-42)', 2)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_form_yuzdelikleri.csv', 'Tablo AS3.2. RMSE yüzdeliği ve r\'nin bütün kümelerdeki medyanla karşılaştırılması', FA + [('rmse_yzd', 'RMSE yüzdeliği', 1), ('r', 'Formun r değeri', 3), ('r_medyan', 'r medyanı (3.432 küme)', 3)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_bootstrap_farklar.csv', 'Tablo AS3.3. RMSE farkları: anlamsal form eksi PUB21, %95 bootstrap aralığı', FA + [('tahmin', 'Fark', 4), ('alt', 'Alt sınır', 4), ('ust', 'Üst sınır', 4)], filtre=secici(olcu='rmse'), donustur=ad_ve_grup, anahtar=2)],
      okuma='<p>Ana gösterge ham RMSE\'dir; kaynağı (yanlılık mı, kişi düzeyindeki dağılım mı) her zaman yazılır. Pozitif RMSE farkı, anlamsal formun tam puandan PUB21\'e göre daha çok saptığını gösterir; sıfırı dışlayan aralık "bu örneklemde tutarlı fark" diye okunur, sıfırı içeren aralık eşdeğerlik kanıtı değildir.</p>',
      bulgu=('<p><strong>RMSE.</strong> RMSE 0,151 ile 0,236 arasındadır (0-42 biriminde 2,11 ile 3,30). D\'de en küçük PUB21 (0,151; olası seçimlerin 3,5. yüzdeliği), sonra COV21 (0,178); A\'da PUB21 (0,210), COV21 (0,221); S\'de COV21 (0,180; 8,1. yüzdelik). MIN21 ile MAX21 aynı bölünmenin iki yarısı olduğu için RMSE\'leri tanım gereği aynıdır (D 0,223, A 0,236, S 0,208) ve bu bağımsız bir kanıt değildir. Düşük RMSE, seçilen yarı ile kalan yarının kişi düzeyinde birbirine daha yakın olduğu anlamına gelir.</p>'
             '<p><strong>Kaynağı.</strong> On iki satırın hepsinde sapmanın büyük bölümü kişi düzeyindeki dağılımdan (s_d) gelir; yanlılığın RMSE² içindeki payı %0,1 ile %26,2 arasındadır. En belirgin yanlılık D\'de MIN21 (+0,114) ve MAX21\'dedir (−0,114).</p>'
             '<p><strong>PUB21\'e göre farklar.</strong> MIN21 ve MAX21, D (0,0724) ve A\'da (0,0262) PUB21\'den tutarlı biçimde daha çok sapar; S\'de aralık sıfırı içerir. COV21, D\'de daha çok (0,0276), S\'de daha az sapar (−0,0251); A\'daki fark (0,0112) sınırdadır, çünkü alt sınır sıfıra çok yakındır (0,00026).</p>'
             '<p><strong>Korelasyon.</strong> r değerleri 0,950 ile 0,985 arasındadır ve bütün kümelerin medyanına çok yakındır (en büyük fark 0,012). Kısa ve tam puan ortak maddeler içerdiği için yüksek r beklenir ve tek başına başarı göstergesi değildir.</p>'),
      soylenmez=['RMSE\'nin "ölçme hatası" olduğu; tam form gerçek puan değildir ve kısa formla ortak maddeler içerir.', 'Yüksek kısa-tam korelasyonunun geçerlik veya puan eşdeğerliği kanıtı olduğu.', 'Küçük RMSE\'nin klinik eşdeğerlik gösterdiği; 0-42 birimindeki değerler klinik önem eşiği değildir.', 'MIN21 ile MAX21\'in aynı RMSE\'sinin iki ayrı bulgu olduğu.']),
]

def vcl_ad(rows):
    m = {'rho_ISI_a': 'ρ(ISI, a)', 'cfi.scaled': 'CFI', 'rmsea.scaled': 'RMSEA', 'srmr': 'SRMR', 'omega': 'Omega', 'alfa': 'Alfa',
         'bias': 'Yanlılık', 'rmse': 'RMSE', 'rho_SB_alfa': 'ρ(SB, alfa)', 'rho_CLb_rmse': 'ρ(CL_b, RMSE)'}
    for r in rows:
        r['olcu'] = m.get(r['olcu'], r['olcu'])
        if r.get('subscale') in AD: r['subscale'] = AD[r['subscale']]
    return rows

BOLUMLER += [
 dict(id='as4', no='AS4', kisa='Çeşitlilik ve temsil', soru='Üç anlamsal seçim kuralıyla oluşturulan kısa formlar (MIN21, MAX21 ve COV21) ile yayımlanmış DASS-21, seçilen maddelerin anlamsal çeşitliliği ve ilgili alt boyuttaki madde havuzunun anlamsal temsili bakımından nasıl farklılaşmaktadır?',
      yapilan='<ul><li>Yalnız madde metinleri kullanılır. Dört formun SB ve CL değerleri ve 3.432 kümedeki yüzdelikleri verilir.</li><li>Bütün kümelerde SB ile CL arasındaki Spearman ilişkisi hesaplanır.</li><li>Madde temsil tablosu, her elenen maddeyi ona en yakın seçili maddeyle ve kosinüs uzaklığıyla eşleştirir; en zayıf temsil edilen madde işaretlenir.</li></ul>',
      kodlar=[dict(dosya='AS4', ad='AS4 · SB, CL, SB-CL ilişkisi ve madde temsil tablosu')],
      ogeler=[t('tablo_form_yuzdelikleri.csv', 'Tablo AS4.1. Anlamsal genişlik (SB) ve temsil kaybı (CL) ile yüzdelikleri', FA + [('SB', 'SB', 3), ('SB_yzd', 'SB yüzdeliği', 1), ('CL', 'CL', 3), ('CL_yzd', 'CL yüzdeliği', 1)], donustur=ad_ve_grup, anahtar=2),
              t('tablo_AS4_SB_CL.csv', 'Tablo AS4.2. Bütün kümelerde SB ile CL arasındaki Spearman ilişkisi', [('subscale', 'Alt boyut', None), ('rho_SB_CL', 'ρ(SB, CL)', 2)], donustur=ad_ve_grup),
              t('tablo_AS4_madde_temsil.csv', 'Tablo AS4.3. Her formda en zayıf temsil edilen madde', FA + [('elenen', 'Elenen madde', None), ('en_yakin', 'En yakın seçili madde', None), ('uzaklik', 'Uzaklık', 3), ('elenen_metin', 'Elenen maddenin metni', None)], filtre=secici(en_zayif='TRUE'), donustur=ad_ve_grup, anahtar=2)],
      okuma='<p>Asıl bulgular üçtür: PUB21\'in konumu, her formun kendi seçim hedefi dışındaki göstergedeki konumu (MIN21\'in CL\'si, COV21\'in SB\'si) ve SB ile CL\'nin bütün kümelerde birlikte değişip değişmediği. MIN21\'in yüksek, MAX21\'in düşük SB\'si ve COV21\'in en düşük CL\'si tanım gereğidir ve bulgu sayılmaz.</p>',
      bulgu=('<p><strong>PUB21.</strong> Yayımlanmış form temsil bakımından olası seçimlerin iyi dilimlerindedir: CL yüzdeliği D\'de 2,9, A\'da 12,7, S\'de 21,1. Çeşitliliği D\'de 70,9., A\'da 51,9., S\'de 96,5. yüzdeliktedir.</p>'
             '<p><strong>Kendi hedefi dışındaki konum.</strong> MIN21\'in çeşitliliği en üst dilimdedir (99,5 ile 100,0), ama temsili D\'de ortada (41,1), S\'de ortanın altında (69,1), A\'da olası seçimlerin en kötü %2\'si arasındadır (98,4): bu veride çeşitlilik temsil anlamına gelmemektedir. Temsil kaybını en aza indiren COV21 çeşitlilikte de ortalamanın üstündedir (79,5 ile 84,3). MAX21\'in temsili zayıftır (85,6 ile 98,3); yüksek alfasıyla birlikte okunduğunda puanı daha homojendir ama elenen maddelerin anlam alanını daha az kapsar.</p>'
             '<p><strong>SB ile CL.</strong> Bütün kümelerde ilişki negatiftir (D −0,45, A −0,45, S −0,55): daha çeşitli kümeler ortalamada daha az temsil kaybı verir. İlişki mükemmel olmadığı için en çeşitli seçim en iyi temsili vermez. Örnek: PUB21\'in kaygı alt boyutunda en zayıf temsil edilen madde Q23\'tür ("difficulty in swallowing"); en yakın karşılığı Q04\'tür ("breathing difficulty"), uzaklık 0,525.</p>'),
      soylenmez=['Tanım gereği veya seçim kuralından beklenen sonuçların bulgu olarak sunulması.', 'Yüksek SB\'nin tek başına iyi temsil olduğu.', '"Temsil"in kapsam geçerliği olduğu; yalnız bu gömme uzayındaki anlamsal temsildir ve uzman içerik yargısının yerine geçmez.']),
 dict(id='as5', no='AS5', kisa='Alt küme testi', soru="DASS-42'nin her alt boyutundan seçilebilecek bütün yedili madde kümelerinde, anlamsal çeşitlilik ve temsil ile puan güvenirliği ve tam form puanlarıyla uyum arasında nasıl bir ilişki vardır?",
      yapilan='<ul><li>İlk sonuçlardan sonra eklenmiş keşfedici bir sorudur; bulguları betimseldir. "Alt küme testi" bir hipotez testi değil, bütün olası kümelerin karşılaştırmasıdır.</li><li>3.432 kümede SB ile alfa ve 1.716 bölünmede CL_b ile RMSE arasındaki Spearman ilişkisi hesaplanır (değerlendirme; tekrar kalibrasyon). Açıklayıcı olarak CL_b\'nin s_d ve mutlak yanlılıkla ilişkisi verilir.</li></ul>',
      kodlar=[dict(dosya='AS5', ad='AS5 · Bütün kümelerde ilişkiler'), dict(dosya='SEKIL2', ad='AS5 · Şekil: alt küme testi')],
      ogeler=[t('tablo_AS5_iliskiler.csv', 'Tablo AS5.1. Bütün kümelerde Spearman ilişkileri', AG + [('n_kume', 'Küme', 'int'), ('n_bolunme', 'Bölünme', 'int'), ('rho_SB_alfa', 'ρ(SB, alfa)', 2), ('rho_CLb_rmse', 'ρ(CL_b, RMSE)', 2), ('rho_CLb_sd', 'ρ(CL_b, s_d)', 2), ('rho_CLb_bias', 'ρ(CL_b, |yanlılık|)', 2)], donustur=ad_ve_grup, anahtar=2),
              dict(tur='sekil', dosya='sekil_AS5_alt_kume_testi.png', baslik='Şekil AS5. Alt küme testi (değerlendirme grubu)', alt='Üst satırda SB ile alfa aşağı eğimli bulut, alt satırda CL_b ile RMSE yukarı eğimli bulut; dört form işaretli.', aciklama='Gri noktalar bütün kümeler (üstte 3.432, altta 1.716 bölünme); dört form kendi değerleriyle işaretlidir. MIN21 ile MAX21 aynı bölünme olduğu için alt satırda üst üste düşer.')],
      okuma='<p>SB-alfa ilişkisi negatifse bu havuzda çeşitlilik arttıkça iç tutarlılık düşme eğilimindedir. CL_b-RMSE ilişkisi pozitifse iki yarının birbirini anlamca temsil etmesi zayıfladıkça tam puandan sapma artma eğilimindedir. İki grupta ve yanıt kalitesi taramasından sonra aynı yön görülürse ilişki tutarlı sayılır.</p>',
      bulgu=('<p><strong>SB ile alfa.</strong> Değerlendirme grubunda ilişki negatif ve güçlüdür (D −0,81, A −0,63, S −0,78; kalibrasyonda −0,79, −0,60, −0,74). Dört formda görülen örüntü (MAX21 yüksek alfa ve düşük SB, MIN21 tersi) yalnız bu formlara özgü değildir; bu havuzdaki kümeler boyunca görülür. Bu sonuç AS1\'deki güçlü ISI-a ilişkisinden kısmen beklenebilir.</p>'
             '<p><strong>CL_b ile RMSE.</strong> İlişki pozitif ve güçlüdür (0,69, 0,53, 0,76; kalibrasyonda 0,67, 0,53, 0,75). CL_b\'nin s_d ile ilişkisi (0,66 ile 0,76) mutlak yanlılıkla ilişkisinden (0,15 ile 0,20) belirgin biçimde güçlüdür: anlamsal temsil, kişi düzeyindeki dağılımla daha çok, madde ortalamalarından doğan yanlılıkla daha az ilişkilidir. Madde metinlerinin madde güçlüğünü yansıtmaması olası bir açıklamadır; bu çalışmada sınanmamıştır.</p>'
             '<p><strong>Tutarlılık.</strong> Yön iki grupta ve uydurma sözcük işaretleyen kayıtlar çıkarıldığında korunmuştur (en büyük değişim 0,018; Ekler). Bu nedenle ilişkiler rehberin tanımıyla tutarlıdır.</p>'),
      soylenmez=['"Metin psikometrik sonucu öngörüyor" gibi bir yordama iddiası ya da başarı eşiği.', 'Yeni madde havuzlarına genelleme ya da nedensellik; p değeri ya da kümeleri bağımsız sayan aralık.', 'CL_b\'nin hangi yarının tutulacağını söylediği.', 'Dağılımdan en iyi görünen küme seçilerek beşinci bir form önerilmesi.']),
 dict(id='ekler', no='E', kisa='Ekler', baslik='Ekler: COV21 eşit çözümleri, yanıt kalitesi ve alfa farkları',
      yapilan='<ul><li>COV21 için en küçük CL\'yi veren bütün kümelerin değerlendirme grubundaki alfa ve RMSE aralığı verilir.</li><li>VCL6, VCL9 ve VCL12 uydurma sözcüklerinden en az birini işaretleyen kayıtlar çıkarılır; AS1, AS2, AS3 ve AS5\'in ana değerleri yeniden hesaplanır.</li><li>Anlamsal formların alfa değerlerinin PUB21\'den farkına ilişkin bootstrap aralıkları verilir (AS3 bölümündeki bootstrap koduyla üretilir).</li></ul>',
      kodlar=[dict(dosya='EK', ad='Ekler · COV21 eşit çözümleri ve VCL duyarlılığı')],
      ogeler=[t('ek_COV21_esit_cozumler.csv', 'Tablo E.1. COV21 eşit çözümleri (değerlendirme grubu)', [('subscale', 'Alt boyut', None), ('n_kume', 'Eşit küme', 'int'), ('alfa_min', 'Alfa en küçük', 3), ('alfa_max', 'Alfa en büyük', 3), ('COV21_alfa', 'COV21 alfa', 3), ('rmse_min', 'RMSE en küçük', 3), ('rmse_max', 'RMSE en büyük', 3), ('COV21_rmse', 'COV21 RMSE', 3)], donustur=ad_ve_grup),
              t('ek_VCL_orneklem.csv', 'Tablo E.2. Yanıt kalitesi (VCL) dışlaması', [('grup', 'Grup', None), ('n_ana', 'Ana örneklem', 'int'), ('n_dislanan', 'Dışlanan', 'int'), ('n_kalan', 'Kalan', 'int')], donustur=ad_ve_grup),
              t('ek_VCL_duyarlilik.csv', 'Tablo E.3. VCL sonrası değerler (fark = dışlanmış veriyle değer eksi ana değer)', [('soru', 'Soru', None), ('form', 'Form', None), ('subscale', 'Alt boyut', None), ('olcu', 'Ölçü', None), ('deger', 'VCL sonrası', 4), ('ana_deger', 'Ana değer', 4), ('fark', 'Fark', 4)], donustur=vcl_ad, anahtar=4),
              t('tablo_bootstrap_farklar.csv', 'Tablo E.4. Alfa farkları: anlamsal form eksi PUB21, %95 bootstrap aralığı', FA + [('tahmin', 'Fark', 4), ('alt', 'Alt sınır', 4), ('ust', 'Üst sınır', 4)], filtre=secici(olcu='alfa'), donustur=ad_ve_grup, anahtar=2)],
      bulgu=('<p><strong>COV21 eşit çözümleri.</strong> Eşit küme sayısı D\'de 16, A\'da 2, S\'de 8\'dir. COV21\'in alfası üç alt boyutta da eşit çözümler arasında en yüksektir; RMSE\'si A\'da en yüksek, D ve S\'de aralığın üst yarısındadır. Aralıklar dardır (alfada en fazla 0,009, RMSE\'de en fazla 0,016), ancak bu genişlik COV21\'in sınırdaki bazı bootstrap farklarıyla aynı büyüklüktedir.</p>'
             '<p><strong>Yanıt kalitesi.</strong> Kalibrasyonda 366, değerlendirmede 384 kayıt dışlanmıştır (yaklaşık beşte bir; kural tek bir uydurma sözcüğü yeterli sayar). Alfa, omega, RMSE ve uyum indekslerindeki değişimler binde birler düzeyindedir (en büyük: alfa 0,0037, omega 0,0038, RMSE 0,0026). En büyük değişim AS1\'dedir (S\'de 0,793\'ten 0,750\'ye); yön ve adlandırma korunmuştur. Alfa, RMSE ve yanlılık sıraları korunmuş; omega sırası D\'de değişmiştir: PUB21 (0,9160 → 0,9156) ile COV21 (0,9164 → 0,9152) yer değiştirmiştir. Fark 0,0005\'in altında olduğu için sıra değil değerler raporlanır.</p>'
             '<p><strong>Alfa farkları.</strong> MAX21\'in alfası üç alt boyutta PUB21\'den tutarlı biçimde yüksektir (0,020 ile 0,041); MIN21\'inki A ve S\'de, COV21\'inki yalnız A\'da tutarlı biçimde düşüktür. Bu aralıklar yalnız alfa içindir.</p>'),
      soylenmez=['İşaretlenen her kaydın geçersiz olduğu.', 'Değerleri çok yakın iki form arasındaki sıra değişiminin önemli bir fark olduğu.', 'Denetlenmemiş "bütün sıralamalar korundu" gibi genellemeler.']),
 dict(id='sonuc', no='S', kisa='Sonuç', baslik='Bulguların birlikte değerlendirilmesi',
      yapilan='<p>Formların alt küme tablosundaki alfa ve RMSE değerlerinin AS2 ve AS3\'te ayrı yoldan hesaplanan değerlerle aynı olduğu denetlenir. Omega ile dört yüzdelik tek tabloda yan yana verilir; göstergeler tek bir başarı puanında birleştirilmez ve kazanan form ilan edilmez.</p>',
      kodlar=[dict(dosya='SONUC', ad='Sonuç · Denetimler ve bütünleşik tablo')],
      ogeler=[t('tablo_butunlesik.csv', 'Tablo S.1. Bütünleşik tablo (değerlendirme grubu)', FA + [('omega', 'Omega', 3), ('alfa_yzd', 'Alfa yzd.', 1), ('rmse_yzd', 'RMSE yzd.', 1), ('SB_yzd', 'SB yzd.', 1), ('CL_yzd', 'CL yzd.', 1)], donustur=ad_ve_grup, anahtar=2)],
      bulgu=('<p>Bu madde havuzunda birbirine benzeyen maddeleri seçmek (MAX21), iç tutarlılığı en üst dilimde ama temsili zayıf bir formla; birbirine benzemeyen maddeleri seçmek (MIN21), çeşitliliği yüksek, iç tutarlılığı en alt dilimde ve temsili her alt boyutta iyi olmayan bir formla; temsil kaybını en aza indirmek (COV21) ise çeşitliliği ortalamanın üstünde, alfası alt dilimde ve tam puan uyumu alt boyuta göre değişen bir formla sonuçlanmıştır. Yayımlanmış DASS-21, depresyonda hem temsil hem tam puan uyumu bakımından olası seçimlerin en iyi dilimlerinde, kaygı ve streste orta düzeydedir. Bütün yedili kümeler üzerindeki ilişkiler (AS5), bu örüntünün seçilmiş dört formla sınırlı olmadığını göstermektedir.</p>'
             '<p>Sonuçlar tek ölçek, tek dil, tek gömme matrisi ve çevrimiçi gönüllü bir örneklemle sınırlıdır; seçim hedefinin bu özellikleri "neden olduğu" anlamına gelmez.</p>')),
]
