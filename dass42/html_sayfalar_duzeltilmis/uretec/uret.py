# Üç sayfayı kullanıcının biçimiyle üretir: 1 kod ve boş tablolar, 2 bulgular, 3 kod ve bulgular.
import sys
sys.path.insert(0, '/tmp/claude-0/-home-user-claudeneme/022df1d8-9131-59ea-9a02-70da74926edf/scratchpad/yeni')
from icerik import *

DOSYA = {1: 'DASS42_1_Kod_ve_Bos_Tablolar.html', 2: 'DASS42_2_Bulgular.html', 3: 'DASS42_3_Kod_ve_Bulgular.html'}
BASLIK = {1: 'DASS-42 Analiz Kodu', 2: 'DASS-42 Analiz Bulguları', 3: 'DASS-42 Kod ve Bulgular'}
UST = {1: 'Yüksek lisans tezi · Dosya 1 / 3 · Kod ve boş tablolar', 2: 'Yüksek lisans tezi · Dosya 2 / 3 · Bulgular',
       3: 'Yüksek lisans tezi · Dosya 3 / 3 · Kod ve bulgular'}
GIRIS = {1: "Analizin baştan sona R kodu ve kod çalıştırıldığında dolacak boş tablolar. Akış hazırlıktan araştırma sorularına, oradan eklere ilerler; her parçanın altında çıktının nasıl okunacağı ve yorumda nelerin söylenmeyeceği yazılıdır.",
         2: "Dosya 1'deki kodun çalıştırılmasıyla elde edilen tablolar ve şekiller. Tablo ve şekil numaraları Dosya 1 ve Dosya 3 ile aynıdır; yorumlar Dosya 3'tedir.",
         3: "Dosya 1'deki kod ile Dosya 2'deki sonuçlar bir arada. Her kodun altındaki bulgular bölümü tıklanınca açılır; yapılan işlemi betimler, tabloları ve şekilleri verir ve yorumlar."}
ADLAR = {1: 'Kod ve boş tablolar', 2: 'Bulgular', 3: 'Kod ve bulgular'}

def baslik(mod):
    serit = ''.join(f'<li><span class="bu" aria-current="page"><b>{m}</b>{ADLAR[m]}</span></li>' if m == mod
                    else f'<li><a href="{DOSYA[m]}"><b>{m}</b>{ADLAR[m]}</a></li>' for m in (1, 2, 3))
    formlar = ''.join(f'<li>{ISARET[f]}{f} {a}</li>' for f, a in
                      [('PUB21', 'yayımlanmış'), ('MIN21', 'en az benzer'), ('MAX21', 'en çok benzer'), ('COV21', 'en düşük temsil kaybı')])
    son = ('<div><dt>Çalıştırma</dt><dd>28 Eylül 2026, R 4.5.3, 2 dk 28 sn; referans değerlerle aynı</dd></div>' if mod == 2
           else '<div><dt>Sürüm</dt><dd>28 Eylül 2026, düzeltilmiş</dd></div>')
    return (f'<header class="bas" lang="tr"><p class="ust">{UST[mod]}</p><h1>DASS-42 Anlamsal Kısa Formlar</h1><p class="giris">{GIRIS[mod]}</p>'
            f'<ul class="dosya-seridi" aria-label="Üç dosya">{serit}</ul><ul class="formlar-serit" aria-label="Karşılaştırılan dört kısa form">{formlar}</ul>'
            '<dl class="kunye"><div><dt>Veri</dt><dd>Open-Source Psychometrics Project DASS arşivi, 39.775 kayıt</dd></div>'
            '<div><dt>Çalışma grubu</dt><dd>4.000 kişi: 2.000 kalibrasyon, 2.000 değerlendirme</dd></div>'
            '<div><dt>Gömme modeli</dt><dd>text-embedding-3-large, 3.072 boyut; Ravenda vd. (2025) arşivi; API seçeneği yer tutucu</dd></div>'
            f'{son}</dl></header>')

def bolum(b, mod):
    ogeler = ''.join(o(mod) for o in b.get('ogeler', []))
    if mod == 2 and not ogeler: return None
    p = [f'<section id="{b["id"]}" class="soru"><p class="soru-etiket"><span class="as-no">{b["no"]}</span>{b["etiket"]}</p>']
    p.append(f'<h2 class="soru-metni">{b["soru"]}</h2>' if b.get('soru') else f'<h2>{b["baslik"]}</h2>')
    if b.get('alt_soru'): p.append(f'<p class="soru-metni">{b["alt_soru"]}</p>')
    if mod == 2:
        p.append(ogeler + '</section>'); return ''.join(p)
    p.append('<h3>Ne yapılır</h3>' + b['ne'])
    p.append(kod(*b['kod']))
    if mod == 1:
        p.append(ogeler)
        if b.get('okuma'): p.append('<h3>Nasıl okunur</h3>' + liste(b['okuma']))
        if b.get('soylenmez'): p.append(soylenmez(b['soylenmez']))
    else:
        g = f'<h4>Yapılan işlem</h4>{b["yapilan"]}' + ogeler
        if b.get('okuma'): g += '<h4>Nasıl okunur</h4>' + liste(b['okuma'])
        if b.get('yorum'): g += '<h4>Yorum</h4>' + b['yorum']
        if b.get('soylenmez'): g += soylenmez(b['soylenmez'])
        p.append(bulgu(b['ozet'], g))
    p.append('</section>')
    return ''.join(p)

def sonuc(mod):
    p = ['<section id="sonuc" class="soru"><h2>Sonuç</h2>']
    if mod == 3: p.append(SONUC_METIN)
    if mod == 1: p.append('<h3>Ne yapılır</h3><p>AS2, AS3 ve AS4\'te üretilen değerleri form ve alt boyut satırlarında tek bir tabloda toplar; yeni hesap yapmaz.</p>')
    if mod in (1, 3): p.append(kod('sonuc', 'Sonuç · Bütünleşik tablo', 'sonuc'))
    p.append(T_butunlesik(mod))
    if mod == 1: p.append('<h3>Nasıl okunur</h3>' + liste(['Her sütun ayrı bir göstergedir; göstergeler tek bir puanda birleştirilmez ve formlar tek bir sıralamaya dönüştürülmez.']))
    p.append('</section>')
    return ''.join(p)

def sayfa(mod):
    nav, govde = [], []
    def ekle(kimlik, no, ad, html_):
        if html_: nav.append(f'<li><a href="#{kimlik}"><span class="n">{no}</span>{ad}</a></li>'); govde.append(html_)
    tekrar_html, kayit = TEKRAR(mod)
    if mod == 2:
        ekle('kayit', '1', 'Çalıştırma kaydı', '<section id="kayit"><h2>Çalıştırma kaydı</h2><p>Tablolar ve şekiller, Dosya 1\'deki kodun öğrenci paketi klasöründe baştan sona bir kez çalıştırılmasıyla üretilmiştir. Kod aynı tohumlarla her çalıştırıldığında aynı sayıları verir.</p>' + kayit + '</section>')
    else:
        ekle('onem', '1', 'Önem ve amaç', ONEM)
        ekle('tekrar', '2', 'Tekrarlanabilirlik', tekrar_html)
    for b in BOLUMLER:
        ekle(b['id'], b['no'], b['nav'], bolum(b, mod))
    ekle('sonuc', '5', 'Sonuç', sonuc(mod))
    if mod == 3: ekle('oneriler', '6', 'Öneriler', ONERILER)
    if mod in (1, 3):
        ekle('kaynaklar', '7', 'Kaynaklar', '<section id="kaynaklar" class="soru"><h2>Kaynaklar</h2><ul class="kaynak">' + ''.join(f'<li>{k}</li>' for k in KAYNAKLAR) + '</ul></section>')
    for b in EKLER:
        ekle(b['id'], b['no'].replace('Ek ', 'Ek '), b['nav'], bolum(b, mod))
    dugme = {1: '<div class="dugmeler"><button type="button" class="tumu">Bütün kodu kopyala</button></div>',
             2: '', 3: '<div class="dugmeler"><button type="button" class="tumu">Bütün kodu kopyala</button><button type="button" class="acma">Bütün bulguları aç</button></div>'}[mod]
    son_not = ('Tablolardaki sayılar bu sayfadaki kodun tek bir çalıştırmasından alınmıştır ve aynı tohumlarla aynen yeniden üretilir. Tezde kullanılacak değerler Berkcan\'ın kabul denetiminden geçmiş son çalıştırmasından alınır.'
               if mod != 1 else 'Boş tablolar kod çalıştırıldığında <code>html_ciktilari/</code> klasörüne yazılan CSV dosyalarıyla dolar; her tablonun notunda kaynak dosya adı verilmiştir.')
    bas = BAS.replace('<title>DASS-42 Anlamsal Kısa Formlar</title>', f'<title>{BASLIK[mod]}</title>')
    return (bas + '<body>\n' + baslik(mod) + '\n<div class="duzen" lang="tr"><nav class="icindekiler" aria-label="İçindekiler"><p class="nav-bas">İçindekiler</p><ol>'
            + ''.join(nav) + '</ol>' + dugme + '</nav><main>' + '\n'.join(govde) + f'<p class="son-not">{son_not}</p></main></div>\n' + JS + '</body>\n</html>\n')

if __name__ == '__main__':
    import os
    cik = S + '/yeni/sayfalar'; os.makedirs(cik, exist_ok=True)
    for m in (1, 2, 3):
        h = sayfa(m)
        open(f'{cik}/{DOSYA[m]}', 'w', encoding='utf-8').write(h)
        print(DOSYA[m], f'{len(h.encode()) / 1e6:.2f} MB', 'uzun tire:', h.count('—'), 'Kılmen:', h.count('Kılmen'))
