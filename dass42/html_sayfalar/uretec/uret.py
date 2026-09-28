# Üç HTML sayfasını (1: kod ve boş tablolar, 2: sonuçlar, 3: bulgular) aynı içerik tanımından üretir.
import csv, html, base64, io, json, re, sys
from PIL import Image

S = '/tmp/claude-0/-home-user-claudeneme/022df1d8-9131-59ea-9a02-70da74926edf/scratchpad/html'
O = S + '/paket/berkcan_dass42/html_ciktilari'
K = S + '/kod'
sys.path.insert(0, S)
from icerik import BOLUMLER, GENEL, KAYNAKLAR  # metin içeriği ayrı dosyada

def oku(ad):
    return list(csv.DictReader(open(f'{O}/{ad}', encoding='utf-8')))

def sayi(x, d):
    if x in ('', 'NA', None): return ''
    v = float(x)
    if d == 'int': return f'{int(round(v)):,}'.replace(',', '.')
    s = f'{v:.{d}f}'.replace('-', '−').replace('.', ',')
    return s

ESC = html.escape

def tablo(t, mod):
    """t: {'dosya', 'sutunlar': [(sutun, baslik, basamak|None)], 'filtre': fn, 'baslik', 'not'}"""
    rows = oku(t['dosya'])
    if t.get('filtre'): rows = [r for r in rows if t['filtre'](r)]
    if t.get('donustur'): rows = t['donustur'](rows)
    sut = t['sutunlar']
    bas = ''.join(f'<th scope="col">{ESC(b)}</th>' for _, b, _ in sut)
    govde = []
    for r in rows:
        hucre = []
        for j, (c, _, d) in enumerate(sut):
            val = r.get(c, '')
            if mod == 1 and j >= t.get('anahtar', 1): metin = '<span class="bos">·</span>'
            elif d is None: metin = ESC(str(val))
            else: metin = sayi(val, d)
            etiket = 'th' if j == 0 else 'td'
            sinif = ' class="sayi"' if (d is not None and not (mod == 1 and j >= t.get('anahtar', 1))) else ''
            kapsam = ' scope="row"' if j == 0 else ''
            hucre.append(f'<{etiket}{kapsam}{sinif}>{metin}</{etiket}>')
        govde.append('<tr>' + ''.join(hucre) + '</tr>')
    alt = f'<p class="tablo-alt">{t.get("not", "")}{" " if t.get("not") else ""}Kaynak dosya: <code>{ESC(t["dosya"])}</code>.</p>'
    if mod == 1:
        alt = f'<p class="tablo-alt">Tablo iskeleti: kod çalıştırıldığında <code>html_ciktilari/{ESC(t["dosya"])}</code> dosyasına yazılır; noktalı hücreler sonuçlarla dolar.</p>'
    return (f'<figure class="tablo"><figcaption>{t["baslik"]}</figcaption><div class="tablo-kap"><table>'
            f'<thead><tr>{bas}</tr></thead><tbody>{"".join(govde)}</tbody></table></div>{alt}</figure>')

_sekil_onbellek = {}
def sekil(s, mod):
    if mod == 1:
        return (f'<figure class="sekil bos-sekil"><div class="sekil-yer"><span>{ESC(s["baslik"])}</span>'
                f'<span class="not">Kod çalıştırıldığında <code>html_ciktilari/{ESC(s["dosya"])}</code> olarak yazılır.</span></div></figure>')
    if s['dosya'] not in _sekil_onbellek:
        im = Image.open(f'{O}/{s["dosya"]}').convert('RGB')
        im.thumbnail((2200, 2200))
        b = io.BytesIO(); im.save(b, 'WEBP', quality=88)
        _sekil_onbellek[s['dosya']] = base64.b64encode(b.getvalue()).decode()
    return (f'<figure class="sekil"><div class="sekil-kap"><img alt="{ESC(s["alt"])}" src="data:image/webp;base64,{_sekil_onbellek[s["dosya"]]}"></div>'
            f'<figcaption><strong>{ESC(s["baslik"])}.</strong> {s["aciklama"]} Kaynak dosya: <code>{ESC(s["dosya"])}</code>.</figcaption></figure>')

def kod_blogu(k, kid, acik=True):
    src = open(f'{K}/{k["dosya"]}.R', encoding='utf-8').read().rstrip()
    ic = (f'<div class="kod-bas"><span class="kod-ad">{ESC(k["ad"])}</span>'
          f'<button type="button" class="kopya" data-hedef="{kid}">Kopyala</button></div>'
          f'<pre tabindex="0"><code id="{kid}" class="language-r">{ESC(src)}</code></pre>')
    if acik:
        return f'<figure class="kod">{ic}</figure>'
    return (f'<details class="kod-ac"><summary>R kodunu göster: {ESC(k["ad"])}</summary>'
            f'<figure class="kod">{ic}</figure></details>')

def tum_kod():
    parca = []
    for b in BOLUMLER:
        for k in b.get('kodlar', []):
            parca.append(open(f'{K}/{k["dosya"]}.R', encoding='utf-8').read().rstrip())
    return '\n\n'.join(parca) + '\n'

CSS = open(S + '/stil.css', encoding='utf-8').read()

def sayfa(mod):
    g = GENEL[mod]
    nav, govde = [], []
    kid = 0
    for b in BOLUMLER:
        if mod not in b.get('sayfalar', (1, 2, 3)): continue
        nav.append(f'<li><a href="#{b["id"]}"><span class="n">{ESC(b["no"])}</span>{ESC(b["kisa"])}</a></li>')
        p = []
        if b.get('soru'):
            p.append(f'<section id="{b["id"]}" class="soru"><p class="soru-etiket"><span class="as-no">{ESC(b["no"])}</span>{ESC(b["kisa"])}</p>'
                     f'<h2 class="soru-metni">{b["soru"]}</h2>')
        else:
            p.append(f'<section id="{b["id"]}"><h2>{ESC(b["baslik"])}</h2>')
        if mod in (1, 3) and b.get('yapilan'): p.append(f'<h3>Ne yapılır</h3>{b["yapilan"]}')
        if mod == 2 and b.get('kisa_not'): p.append(f'<p class="not">{b["kisa_not"]}</p>')
        if mod == 1:
            for k in b.get('kodlar', []):
                kid += 1; p.append(kod_blogu(k, f'k{kid}', acik=True))
        for oge in b.get('ogeler', []):
            if oge.get('tur') == 'tablo' and mod in oge.get('sayfalar', (1, 2, 3)): p.append(tablo(oge, mod))
            if oge.get('tur') == 'sekil' and mod in oge.get('sayfalar', (1, 2, 3)): p.append(sekil(oge, mod))
            if oge.get('tur') == 'metin' and mod in oge.get('sayfalar', (3,)): p.append(oge['html'])
        if mod == 1 and b.get('okuma'): p.append(f'<h3>Çıktı nasıl okunur</h3>{b["okuma"]}')
        if mod == 3:
            if b.get('bulgu'): p.append(f'<h3>Bulgu ve yorum</h3>{b["bulgu"]}')
            for k in b.get('kodlar', []):
                kid += 1; p.append(kod_blogu(k, f'k{kid}', acik=False))
        if mod in (1, 3) and b.get('soylenmez'):
            p.append('<div class="soylenmez"><p class="etiket">Yorumda söylenmez</p><ul>' + ''.join(f'<li>{x}</li>' for x in b['soylenmez']) + '</ul></div>')
        p.append('</section>')
        govde.append(''.join(p))
    kaynak = '<section id="kaynaklar"><h2>Kaynaklar</h2><ul class="kaynak">' + ''.join(f'<li>{x}</li>' for x in KAYNAKLAR) + '</ul></section>'
    nav.append('<li><a href="#kaynaklar"><span class="n">K</span>Kaynaklar</a></li>')
    kopya = ''
    if mod in (1, 3):
        kopya = ('<button type="button" class="tumu" data-tum="1">Bütün kodu kopyala</button>'
                 f'<textarea id="tum-kod" class="tum-kod-alani" hidden readonly aria-label="Bütün R kodu">{ESC(tum_kod())}</textarea>')
    js = open(S + '/betik.js', encoding='utf-8').read()
    return f'''<title>{g["title"]}</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;1,400&family=IBM+Plex+Serif:ital,wght@0,500;0,600;1,500&display=swap">
<style>{CSS}</style>
<header class="bas"><p class="ust">{g["ust"]}</p><h1>{g["h1"]}</h1><p class="giris">{g["giris"]}</p>
<nav class="sayfalar" aria-label="Üç sayfa">{g["sayfalar"]}</nav>
<dl class="kunye">{GENEL["kunye"]}</dl></header>
<div class="duzen"><nav class="icindekiler" aria-label="İçindekiler"><p class="nav-bas">İçindekiler</p><ol>{"".join(nav)}</ol>{kopya}</nav>
<main>{g.get("ust_metin", "")}{"".join(govde)}{kaynak}<p class="son-not">{g["son_not"]}</p></main></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/r.min.js"></script>
<script>{js}</script>
'''

if __name__ == '__main__':
    for mod, ad in [(1, 'dass42_kod_ve_tablolar.html'), (2, 'dass42_sonuclar.html'), (3, 'dass42_bulgular.html')]:
        s = sayfa(mod)
        open(f'{S}/{ad}', 'w', encoding='utf-8').write(s)
        print(ad, f'{len(s.encode()) / 1e6:.2f} MB', 'em dash:', s.count('—'))
