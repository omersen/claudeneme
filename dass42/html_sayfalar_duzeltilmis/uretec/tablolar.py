# Tablo ve şekil tanımları: her fonksiyon sayfa kipini (1 boş, 2 ve 3 dolu) alır.
from yardim import *

def T_akis(mod):
    r = oku('orneklem_akisi.csv')
    return tablo('1', 'Örneklem akışı', ['Aşama', 'n'], [(x['asama'], [ts(x['n'])]) for x in r],
                 'Ölçütler sırayla uygulanır; her satır önceki ölçütleri de karşılayan kayıt sayısıdır.', mod, 'orneklem_akisi.csv')

def T_betim(mod):
    ad = {'toplam': 'Toplam', 'kalibrasyon': 'Kalibrasyon', 'degerlendirme': 'Değerlendirme'}
    r = oku('orneklem_betimleme.csv')
    return tablo('2', 'Grupların betimsel özellikleri', ['Grup', 'n', 'Yaş ort. (SS)', 'Kadın %', 'Erkek %', 'Diğer %', 'Yanıtsız %'],
                 [(ad[x['grup']], [ts(x['n']), f"{s(x['yas_ort'])} ({s(x['yas_ss'])})", s(x['kadin_yzd'], 1), s(x['erkek_yzd'], 1),
                                   s(x['diger_yzd'], 1), s(x['yanitsiz_yzd'], 1)]) for x in r],
                 'Cinsiyet kodları arşivin kod kitabına göredir (1 erkek, 2 kadın, 3 diğer).', mod, 'orneklem_betimleme.csv')

KURAL = {'PUB21': 'Yayımlanmış DASS-21', 'MIN21': 'ISI en düşük yedi madde', 'MAX21': 'ISI en yüksek yedi madde',
         'COV21': 'CL en küçük yedili küme'}
def T_formlar(mod):
    r = oku('formlar.csv'); d = {(x['form'], x['subscale']): x for x in r}
    num = lambda m: ', '.join(str(int(q[1:])) for q in m.split())
    satir = []
    for f in FORMLAR:
        hucre = [KURAL[f]] + [num(d[(f, a)]['maddeler']) for a in 'DAS']
        if mod == 1: hucre = [KURAL[f]] + ['…'] * 3
        satir.append((fh(f), hucre))
    cov = [d[('COV21', a)]['cov_esit_cozum'] for a in 'DAS']
    notu = ('Madde numaraları DASS-42 sırasıdır. MIN21 ile MAX21 her alt boyutta birbirinin tümleyenidir. '
            + (f'COV21\'de aynı en küçük CL\'yi veren küme sayısı: depresyon {cov[0]}, kaygı {cov[1]}, stres {cov[2]}; kural sıralamada ilk kümeyi alır (Ek B).'
               if mod != 1 else 'COV21\'de aynı en küçük CL\'yi veren küme sayısı tablonun notuna yazılır (Ek B).'))
    # Seçim kuralı sütunu boş sayfada da görünür; yalnız maddeler boştur
    t = tablo('3', 'Dört kısa formun maddeleri', ['Form', 'Seçim kuralı', 'Depresyon', 'Kaygı', 'Stres'], satir, notu, 2, 'formlar.csv', 'formlar')
    return t.replace('<td>…</td>', '<td><span class="bos">…</span></td>')

def T_dagilim(mod):
    r = oku('alt_kume_dagilimi.csv')
    return tablo('4', 'Bütün yedili kümelerde alfa, RMSE ve kısa-tam r dağılımı',
                 ['Alt boyut', 'Alfa · en düşük / medyan / en yüksek', 'RMSE (0-42) · en düşük / medyan / en yüksek',
                  'Kısa-tam r · en düşük / medyan / en yüksek'],
                 [(ALT[x['subscale']], [' / '.join(s(x[k], 3) for k in ('alfa_min', 'alfa_medyan', 'alfa_maks')),
                                        ' / '.join(s(14 * float(x[k]), 2) for k in ('rmse_min', 'rmse_medyan', 'rmse_maks')),
                                        ' / '.join(s(x[k], 3) for k in ('r_min', 'r_medyan', 'r_maks'))]) for x in r],
                 'Değerlendirme grubu (n = 2.000); her alt boyutta 3.432 küme. RMSE (0-42), 0-3 madde ortalaması birimindeki RMSE\'nin 14 katıdır.',
                 mod, 'alt_kume_dagilimi.csv')

def T_as1(mod):
    a = {(x['subscale'], x['grup']): x for x in oku('AS1_ISI_a.csv')}
    t = {(x['subscale'], x['grup']): x for x in oku('AS1_GRM_tani.csv')}
    sat = []
    for f in 'DAS':
        k, d = t[(f, 'kal')], t[(f, 'deg')]
        sat.append((ALT[f], [s(a[(f, 'kal')]['rho_ISI_a']), s(a[(f, 'deg')]['rho_ISI_a']), s(a[(f, 'kal')]['rho_ISI_CITC']),
                             s(a[(f, 'kal')]['rho_a_CITC']),
                             f"{s(k['C2'], 1)} ({k['df']}) <span class=\"ara\">({s(d['C2'], 1)})</span>",
                             f"{s(k['RMSEA'], 3)} <span class=\"ara\">({s(d['RMSEA'], 3)})</span>",
                             f"{s(k['SRMSR'], 3)} <span class=\"ara\">({s(d['SRMSR'], 3)})</span>",
                             s(k['maks_Q3']), f"{s(k['rho_cos_Q3'])} <span class=\"ara\">({s(d['rho_cos_Q3'])})</span>"]))
    return tablo('5', 'ISI ile ayırt edicilik ilişkisi ve GRM tanısı',
                 ['Alt boyut', 'ρ(ISI, a) kal.', 'ρ(ISI, a) değ.', 'ρ(ISI, CITC) kal.', 'ρ(a, CITC) kal.', 'C2 (sd) kal. (değ.)',
                  'C2 RMSEA kal. (değ.)', 'SRMSR kal. (değ.)', 'En büyük Q3 kal.', 'ρ(kosinüs, Q3) kal. (değ.)'], sat,
                 'Her alt boyutta 14 madde; kal.: kalibrasyon, değ.: değerlendirme grubu (n = 2.000). Parantez içindeki değerler değerlendirme grubundandır. ρ(kosinüs, Q3) 91 madde çiftindedir.',
                 mod, 'AS1_ISI_a.csv ve AS1_GRM_tani.csv')

def T_q3(mod):
    r = [x for x in oku('AS1_Q3_ciftleri.csv') if x['grup'] == 'kal']
    return tablo('6', 'Her alt boyutta en yüksek üç Q3 çifti', ['Alt boyut', 'Madde çifti', 'Düzeltilmiş Q3', 'Kosinüs'],
                 [(ALT[x['subscale']], [x['cift'].replace('-', ' ile '), s(x['Q3']), s(x['kosinus'])]) for x in r],
                 'Kalibrasyon grubu. Düzeltilmiş Q3: bütün çiftlerin ortalaması çıkarılmış artık korelasyon (Christensen vd., 2017).',
                 mod, 'AS1_Q3_ciftleri.csv')

def T_kategori(mod):
    r = {(x['subscale'], x['grup']): x for x in oku('AS1_kategori_kullanimi.csv')}
    sat = []
    for f in 'DAS':
        k, d = r[(f, 'kal')], r[(f, 'deg')]
        sat.append((ALT[f], [f"{s(100 * float(k['en_az_kullanilan']), 1)} ({k['madde']})", f"{s(100 * float(d['en_az_kullanilan']), 1)} ({d['madde']})",
                             f"{s(100 * float(k['kategori_0_ort']), 1)} / {s(100 * float(k['kategori_3_ort']), 1)}"]))
    return tablo('7', 'Yanıt kategorilerinin kullanımı', ['Alt boyut', 'En az kullanılan kategori % (madde) kal.', 'Aynı ölçüt değ.',
                 'Ortalama % · 0 / 3 kategorisi, kal.'], sat,
                 'Her maddede dört yanıt kategorisinin (0-3) oranı hesaplanmış; tabloda 14 madde içinde en düşük oran ve ait olduğu madde verilmiştir.',
                 mod, 'AS1_kategori_kullanimi.csv')

def T_param(mod):
    r = [x for x in oku('AS1_madde_parametreleri.csv') if x['grup'] == 'kal']
    sat = []
    for f in 'DAS':
        sat.append(('grup', ALT[f]))
        for x in sorted([y for y in r if y['subscale'] == f], key=lambda y: -float(y['ISI'])):
            sat.append((x['item_id'], [s(x['ISI'], 3), s(x['a']), s(x['b1']), s(x['b2']), s(x['b3']), s(x['CITC']), x['formlar'] or 'yok']))
    t = tablo('8', 'Madde parametreleri ve maddelerin yer aldığı formlar',
              ['Madde', 'ISI', 'a', 'b1', 'b2', 'b3', 'CITC', 'Yer aldığı kısa formlar'], sat,
              'Kalibrasyon grubu; maddeler her alt boyutta ISI\'ye göre büyükten küçüğe sıralıdır. a ve b parametreleri IRT gösterimindedir (GRM). Değerlendirme grubunun değerleri kaynak dosyadadır.',
              mod, 'AS1_madde_parametreleri.csv')
    return t

def S_as1(mod):
    return sekil('1', 'ISI ve GRM ayırt edicilik parametresi', 'sekil_AS1_ISI_a.png',
                 'Üç panelde ISI ile kalibrasyon grubundaki GRM ayırt edicilik parametresi a arasındaki saçılım; panel başlıklarında Spearman rho.',
                 'Kalibrasyon grubu. Her nokta bir DASS-42 maddesidir; panel başlığında Spearman ρ.', mod)

def T_uyum(mod):
    r = oku('AS2_DFA_uyum.csv')
    return tablo('9', 'Doğrulayıcı faktör analizi uyumu', ['Form', 'χ² (sd)', 'CFI', 'TLI', 'RMSEA [%90 GA]', 'SRMR'],
                 [(fh(x['form']), [f"{s(x['chisq.scaled'], 1)} ({ts(x['df.scaled'])})", s(x['cfi.scaled'], 3), s(x['tli.scaled'], 3),
                                   f"{s(x['rmsea.scaled'], 3)} <span class=\"ara\">[{s(x['rmsea.ci.lower.scaled'], 3)}; {s(x['rmsea.ci.upper.scaled'], 3)}]</span>",
                                   s(x['srmr'], 3)]) for x in r],
                 'Değerlendirme grubu (n = 2.000); sıralı DFA, WLSMV, ölçeklenmiş değerler. FULL42, 42 maddelik tam formdur. Formlar farklı madde kümeleri olduğundan modeller iç içe değildir; değerler yan yana betimlenir.',
                 mod, 'AS2_DFA_uyum.csv')

def T_guv(mod):
    g = oku('AS2_guvenirlik.csv'); y = {x['form']: x for x in oku('AS2_ortalama_yukler.csv')}
    sat = []
    for f in ['FULL42'] + FORMLAR:
        z = {x['subscale']: x for x in g if x['form'] == f}
        sat.append((fh(f), [' / '.join(s(z[a]['omega'], 3) for a in 'DAS'), ' / '.join(s(z[a]['alfa'], 3) for a in 'DAS'),
                            'yok' if f == 'FULL42' else ' / '.join(yzd(z[a]['alfa_yzd']) for a in 'DAS'),
                            ' / '.join(s(y[f][a]) for a in 'DAS')]))
    return tablo('10', 'Güvenirlik ve ortalama standartlaştırılmış yük', ['Form', 'ω · D / A / S', 'Alfa · D / A / S',
                 'Alfa yüzdeliği · D / A / S', 'Ortalama yük · D / A / S'], sat,
                 'Değerlendirme grubu. ω: kategorik omega (obs.var = FALSE; diğer hesaplama biçimi Ek D\'de). Alfa yüzdeliği, formun alfasının 3.432 kümenin alfa dağılımındaki orta sıra yüzdeliğidir.',
                 mod, 'AS2_guvenirlik.csv ve AS2_ortalama_yukler.csv')

def T_kor(mod):
    r = oku('AS2_faktor_korelasyonlari.csv')
    return tablo('11', 'Faktörler arası korelasyonlar', ['Form', 'Depresyon-Kaygı', 'Depresyon-Stres', 'Kaygı-Stres'],
                 [(fh(x['form']), [s(x['D_A']), s(x['D_S']), s(x['A_S'])]) for x in r],
                 'Değerlendirme grubu; DFA\'daki örtük değişken korelasyonları.', mod, 'AS2_faktor_korelasyonlari.csv')

def T_tbf(mod):
    r = oku('AS2_test_bilgisi.csv'); sat = []
    for f in ['FULL42'] + FORMLAR:
        for a in 'DAS':
            z = sorted([x for x in r if x['form'] == f and x['subscale'] == a], key=lambda x: float(x['theta']))
            ad = fh(f, 'Tam alt boyut') if f == 'FULL42' else fh(f)
            sat.append((f'{ad} <span class="ara">{ALT[a]}</span>',
                        [f"{s(x['bilgi'], 1)} <span class=\"ara\">({s(x['SH'])})</span>" for x in z]))
    return tablo('12', 'Test bilgisi ve standart hata', ['Form ve alt boyut', 'θ = −2', 'θ = −1', 'θ = 0', 'θ = 1', 'θ = 2'], sat,
                 'Değerlendirme grubunda her alt boyutun 14 maddesine kestirilen GRM\'den. Hücrede test bilgisi, parantez içinde standart hata (SH = 1 / √bilgi). θ, değerlendirme grubunda ortalaması 0, standart sapması 1 olan örtük özelliktir. Tam alt boyut satırı 14 maddenin toplam bilgisidir.',
                 mod, 'AS2_test_bilgisi.csv (bütün θ ızgarası: AS2_test_bilgisi_egri.csv)')

def S_tbf(mod):
    return sekil('2', 'Test bilgi fonksiyonları', 'sekil_AS2_test_bilgisi.png',
                 'Üç panelde depresyon, kaygı ve stres için tam alt boyutun ve dört kısa formun test bilgi eğrileri; yatay eksen theta, dikey eksen test bilgisi.',
                 'Değerlendirme grubu. Kesikli gri çizgi 14 maddelik tam alt boyuttur; renkli çizgiler dört kısa formdur (siyah PUB21, mavi MIN21, turuncu MAX21, yeşil COV21).', mod)

def T_as3(mod):
    r = oku('AS3_uyum.csv')
    med = {x['subscale']: x['r_medyan'] for x in r}
    return tablo('13', 'Kısa ve tam form puanlarının uyumu', ['Form', 'Alt boyut', 'r', 'Yanlılık', 's<sub>d</sub>', 'RMSE (0-3)', 'RMSE (0-42)', 'RMSE yüzdeliği'],
                 [(fh(x['form']), [ALT[x['subscale']], s(x['r'], 3), s(x['bias'], 3, True), s(x['sd_d'], 3), s(x['rmse'], 3), s(x['rmse_0_42']), yzd(x['rmse_yzd'])])
                  for x in r],
                 f"Değerlendirme grubu. Yanlılık: kısa ortalama eksi tam ortalama (0-3). RMSE² = yanlılık² + s<sub>d</sub>². Bütün kümelerde medyan kısa-tam r: {s(med['D'], 3)} / {s(med['A'], 3)} / {s(med['S'], 3)} (D / A / S).",
                 mod, 'AS3_uyum.csv')

def T_boot(mod, olcu='rmse', no='14', ad='RMSE farkı: anlamsal form eksi PUB21', d=4, dosya='bootstrap_farklar.csv'):
    r = [x for x in oku('bootstrap_farklar.csv') if x['olcu'] == olcu]
    sat = []
    for f in ['MIN21', 'MAX21', 'COV21']:
        z = {x['subscale']: x for x in r if x['form'] == f}
        sat.append((f'{fh(f)} eksi PUB21', [f"{s(z[a]['tahmin'], d, True)} <span class=\"ara\">[{s(z[a]['alt'], d)}; {s(z[a]['ust'], d)}]</span>" for a in 'DAS']))
    yon = ('Pozitif fark, anlamsal formun tam puandan daha çok saptığını gösterir.' if olcu == 'rmse'
           else 'Pozitif fark, anlamsal formun alfasının PUB21\'inkinden yüksek olduğunu gösterir.')
    return tablo(no, ad, ['Karşılaştırma', 'Depresyon', 'Kaygı', 'Stres'], sat,
                 f'Değerlendirme grubu; fark ve %95 yüzdelik bootstrap aralığı; 2.000 eşleştirilmiş tekrar, set.seed(20260913 + b). {yon}',
                 mod, dosya)

def T_as4(mod):
    r = oku('AS4_anlamsal.csv'); sb = {x['subscale']: x['rho_SB_CL'] for x in oku('AS4_SB_CL.csv')}
    sat = []
    for f in FORMLAR:
        z = {x['subscale']: x for x in r if x['form'] == f}
        sat.append((fh(f), [' / '.join(s(z[a]['SB'], 3) for a in 'DAS'), ' / '.join(yzd(z[a]['SB_yzd']) for a in 'DAS'),
                            ' / '.join(s(z[a]['CL'], 3) for a in 'DAS'), ' / '.join(yzd(z[a]['CL_yzd']) for a in 'DAS')]))
    return tablo('15', 'Anlamsal çeşitlilik (SB) ve temsil kaybı (CL)', ['Form', 'SB · D / A / S', 'SB yüzdeliği', 'CL · D / A / S', 'CL yüzdeliği'], sat,
                 f"Yüzdelikler her alt boyutta 3.432 küme içindedir. Bütün kümelerde ρ(SB, CL): {s(sb['D'])} / {s(sb['A'])} / {s(sb['S'])} (D / A / S).",
                 mod, 'AS4_anlamsal.csv ve AS4_SB_CL.csv')

def T_temsil(mod):
    r = [x for x in oku('AS4_madde_temsil.csv') if x['en_zayif'] == 'TRUE']
    return tablo('16', 'Her formda en zayıf temsil edilen madde', ['Form', 'Alt boyut', 'Elenen madde', 'En yakın seçili madde', 'Kosinüs uzaklığı'],
                 [(fh(x['form']), [ALT[x['subscale']], x['elenen'], x['en_yakin'], s(x['uzaklik'], 3)]) for x in r],
                 'Uzaklık 1 eksi kosinüs benzerliğidir. Tablo, her form ve alt boyutta en yakın seçili maddeye uzaklığı en büyük olan elenen maddeyi verir; bütün eşleşmeler ve madde metinleri kaynak dosyadadır.',
                 mod, 'AS4_madde_temsil.csv')

def T_as5(mod):
    r = {(x['subscale'], x['grup']): x for x in oku('AS5_iliskiler.csv')}
    return tablo('17', 'Bütün olası kümelerde anlamsal ve psikometrik göstergelerin ilişkisi',
                 ['Alt boyut', 'ρ(SB, alfa)', 'ρ(CL<sub>b</sub>, RMSE)', 'ρ(CL<sub>b</sub>, s<sub>d</sub>)', 'ρ(CL<sub>b</sub>, |yanlılık|)'],
                 [(ALT[f], [f"{s(r[(f, 'deg')]['rho_SB_alfa'])} <span class=\"ara\">({s(r[(f, 'kal')]['rho_SB_alfa'])})</span>",
                            f"{s(r[(f, 'deg')]['rho_CLb_rmse'])} <span class=\"ara\">({s(r[(f, 'kal')]['rho_CLb_rmse'])})</span>",
                            s(r[(f, 'deg')]['rho_CLb_sd']), s(r[(f, 'deg')]['rho_CLb_bias'])]) for f in 'DAS'],
                 'Değerlendirme grubu; parantez içinde kalibrasyon grubu. SB ile alfa 3.432 kümede, CL<sub>b</sub> ile diğerleri 1.716 benzersiz bölünmede hesaplanmıştır. Kümeler ortak maddeler içerdiğinden p değeri verilmez.',
                 mod, 'AS5_iliskiler.csv')

def S_as5(mod):
    return sekil('3', 'Alt küme testi: bütün kümeler ve dört form', 'sekil_AS5_alt_kume_testi.png',
                 'Altı panelli saçılım: üst sırada SB ile alfa, alt sırada CL_b ile RMSE; gri noktalar bütün kümeler, renkli işaretler dört form.',
                 'Değerlendirme grubu. Üst sıra 3.432 küme, alt sıra 1.716 bölünme. Siyah kare PUB21, mavi daire MIN21, turuncu üçgen MAX21, yeşil karo COV21; MIN21 ile MAX21 alt sırada üst üste düşer.', mod)

def T_butunlesik(mod):
    r = oku('butunlesik_tablo.csv')
    return tablo('18', 'Bütünleşik tablo: dört formun göstergeleri bir arada',
                 ['Form', 'Alt boyut', 'ω', 'Alfa yüzdeliği', 'RMSE (0-42)', 'RMSE yüzdeliği', 'SB yüzdeliği', 'CL yüzdeliği'],
                 [(fh(x['form']), [ALT[x['subscale']], s(x['omega'], 3), yzd(x['alfa_yzd']), s(x['rmse_0_42']), yzd(x['rmse_yzd']),
                                   yzd(x['SB_yzd']), yzd(x['CL_yzd'])]) for x in r],
                 'Değerlendirme grubu; yeni hesap içermez (Tablo 10, 13 ve 15\'ten). Yüzdelikler 3.432 küme içindedir. Yüksek alfa ve SB yüzdeliği, düşük RMSE ve CL yüzdeliği, o göstergede kümelerin çoğundan daha yüksek güvenirlik, daha çok çeşitlilik, daha az sapma ve daha iyi temsil demektir; göstergeler tek bir puanda birleştirilmez.',
                 mod, 'butunlesik_tablo.csv')

MODEL_AD = {'3072': '3.072 boyut (ana)', '1536': '1.536 boyut', '1024': '1.024 boyut', '512': '512 boyut', '256': '256 boyut',
            'TF-IDF': 'TF-IDF (sözcüksel)'}
def T_ekA(mod):
    r = oku('ekA_model_denetimi.csv'); sat = [('grup', 'Ana model ve kısaltılmış boyutları')]
    for i, x in enumerate(r):
        if x['temsil'] == 'TF-IDF': sat.append(('grup', 'Karşılaştırma temsilleri'))
        sat.append((MODEL_AD.get(x['temsil'], x['temsil']),
                    [f"{s(x['r_tum'])} <span class=\"ara\">({s(x['rho_tum'])})</span>", f"{s(x['r_ic'])} <span class=\"ara\">({s(x['rho_ic'])})</span>",
                     ' / '.join(s(100 * float(x[k]), 1) for k in ('ilk1', 'ilk2', 'ilk3')), s(100 * float(x['alt_olcek']), 1)]))
    return tablo('A1', 'Gömme temsillerinin betimsel denetimi (analiz dışı 6.362 kayıt)',
                 ['Temsil', 'Ö1 · 861 çift, r (ρ)', 'Ö2 · 273 alt ölçek içi çift, r (ρ)', 'Ö3 · ilk-1 / ilk-2 / ilk-3 %', 'Ö4 · alt ölçek sınıflaması %'], sat,
                 'Görgül korelasyonlar, uygunluk ölçütlerini karşılayıp 4.000 kişilik örnekleme seçilmeyen 6.362 kayıttan hesaplanmıştır. Ö3 için şans düzeyi k/41, Ö4 için yaklaşık %33\'tür. Açık ağırlıklı model satırları <code>girdiler/modeller/</code> klasöründeki vektörlerdendir (bu vektörler ONNX Runtime ile, bu denetim için üretilmiştir; üretim betiği depodadır).',
                 mod, 'ekA_model_denetimi.csv')

def T_ekA2(mod):
    r = oku('ekA_form_duyarliligi.csv'); sat = []
    for m in dict.fromkeys(x['temsil'] for x in r):
        z = {x['form']: x for x in r if x['temsil'] == m}
        sat.append((MODEL_AD.get(m, m), [' / '.join(z[f][a] for a in 'DAS') for f in ('MIN21', 'MAX21', 'COV21')]))
    return tablo('A2', 'Formların temsile duyarlılığı: ana formla ortak madde sayısı',
                 ['Temsil', 'MIN21 · D / A / S', 'MAX21 · D / A / S', 'COV21 · D / A / S'], sat,
                 'Her hücre, o temsille kurulan formun 3.072 boyutlu vektörlerle kurulan formla ortak madde sayısıdır (en çok 7).',
                 mod, 'ekA_form_duyarliligi.csv')

def S_ekA(mod):
    return sekil('A1', 'Kosinüs benzerliği ve görgül madde korelasyonu', 'sekil_ekA_kosinus_r.png',
                 'Saçılım: 861 madde çiftinde kosinüs benzerliği ile analiz dışı kayıtlardaki görgül korelasyon; alt ölçek içi çiftler mavi.',
                 'Analiz dışı 6.362 kayıt, 861 madde çifti. Mavi noktalar aynı alt ölçekteki 273 çifttir.', mod)

def T_ekB(mod):
    r = oku('ekB_COV21_esit_cozumler.csv')
    return tablo('B1', 'COV21 eşit çözümleri', ['Alt boyut', 'Eşit çözüm', 'En az ortak madde', 'Alfa aralığı (COV21)', 'RMSE aralığı, 0-3 (COV21)', 'Sonraki CL ile boşluk'],
                 [(ALT[x['subscale']], [x['n_esit'], x['ortak_min'], f"{s(x['alfa_min'], 3)}-{s(x['alfa_maks'], 3)} <span class=\"ara\">({s(x['alfa_COV21'], 3)})</span>",
                                        f"{s(x['rmse_min'], 3)}-{s(x['rmse_maks'], 3)} <span class=\"ara\">({s(x['rmse_COV21'], 3)})</span>",
                                        s(x['CL_bosluk'], 5)]) for x in r],
                 'Değerlendirme grubu. Eşit çözüm: CL\'si en küçük CL\'ye eşit (tolerans 10<sup>−12</sup>) kümeler. En az ortak madde: bu kümelerin kuralın seçtiği COV21 ile en az ortak madde sayısı. Son sütun, en küçük CL ile ondan büyük ilk CL değeri arasındaki farktır.',
                 mod, 'ekB_COV21_esit_cozumler.csv')

def T_ekC(mod):
    o = {x['grup']: x for x in oku('ekC_VCL_orneklem.csv')}
    r = oku('ekC_VCL_duyarlilik.csv')
    tanim = [('AS1', 'rho_ISI_a', 'ρ(ISI, a), kalibrasyon'), ('AS2', 'omega', 'Kategorik omega'), ('AS2', 'alfa', 'Alfa'),
             ('AS3', 'rmse', 'RMSE (0-3)'), ('AS5', 'rho_SB_alfa', 'ρ(SB, alfa)'), ('AS5', 'rho_CLb_rmse', 'ρ(CL<sub>b</sub>, RMSE)')]
    sat = []
    for so, ol, ad in tanim:
        z = [x for x in r if x['soru'] == so and x['olcu'] == ol]
        sat.append((f'{so} · {ad}', [str(len(z)), f"{s(min(float(x['deger']) for x in z), 3)}-{s(max(float(x['deger']) for x in z), 3)}",
                                     s(max(abs(float(x['fark'])) for x in z), 4)]))
    return tablo('C1', 'Yanıt kalitesi (VCL) duyarlılığı', ['Soru ve gösterge', 'Değer sayısı', 'Dışlama sonrası aralık', 'En büyük mutlak fark'], sat,
                 (f"Dışlanan kayıt: kalibrasyonda {o['kal']['n_dislanan']} (kalan {ts(o['kal']['n_kalan'])}), değerlendirmede {o['deg']['n_dislanan']} (kalan {ts(o['deg']['n_kalan'])}). "
                  if mod != 1 else 'Dışlanan kayıt sayıları tablonun notuna yazılır. ') +
                 'Fark = dışlama sonrası değer eksi ana değer. Her satır ilgili form ve alt boyutların tamamını özetler; satır satır değerler kaynak dosyadadır.',
                 mod, 'ekC_VCL_duyarlilik.csv ve ekC_VCL_orneklem.csv')

def T_ekD(mod):
    r = oku('ekD_omega_obsvar.csv'); sat = []
    for f in ['FULL42'] + FORMLAR:
        z = {x['subscale']: x for x in r if x['form'] == f}
        sat.append((fh(f), [' / '.join(s(z[a]['omega_model'], 3) for a in 'DAS'), ' / '.join(s(z[a]['omega_gozlenen'], 3) for a in 'DAS'),
                            ' / '.join(s(z[a]['fark'], 3, True) for a in 'DAS')]))
    return tablo('D1', 'Kategorik omeganın iki hesaplama biçimi', ['Form', 'obs.var = FALSE · D / A / S', 'obs.var = TRUE · D / A / S', 'Fark · D / A / S'], sat,
                 'Değerlendirme grubu; AS2\'deki DFA modelleri. obs.var = FALSE ana analizdeki değerdir (Tablo 10). Fark = TRUE eksi FALSE.',
                 mod, 'ekD_omega_obsvar.csv')

def T_ekE(mod):
    return T_boot(mod, 'alfa', 'E1', 'Alfa farkı: anlamsal form eksi PUB21', 4, 'ekE_alfa_bootstrap.csv')
