# Kullanıcının üç HTML sayfasının biçimini (CSS, JS, işaretleme) koruyarak içerik üreten yardımcılar.
import csv, html, base64, io, re
from PIL import Image

S = '/tmp/claude-0/-home-user-claudeneme/022df1d8-9131-59ea-9a02-70da74926edf/scratchpad'
U = '/root/.claude/uploads/022df1d8-9131-59ea-9a02-70da74926edf'
O = S + '/yeni/calis/html_ciktilari'
K = S + '/yeni/kod'
ESC = html.escape

_kaynak = open(U + '/5b1eab64-DASS42_3_Kod_ve_Bulgular.html', encoding='utf-8').read()
BAS = _kaynak[:_kaynak.index('<body>')]                      # doctype, meta, CSS (kullanıcının)
JS = _kaynak[_kaynak.index('<script src="https://cdnjs'):_kaynak.index('</body>')]   # hljs ve sayfa betiği

def oku(ad):
    return list(csv.DictReader(open(f'{O}/{ad}', encoding='utf-8')))

def s(x, d=2, isaret=False):
    """Türkçe ondalık: virgül, eksi işareti U+2212."""
    if x in ('', 'NA', None): return 'yok'
    v = float(x)
    t = f'{v:+.{d}f}' if isaret else f'{v:.{d}f}'
    return t.replace('-', '−').replace('.', ',')

def ts(x):
    """Binlik ayırıcılı tamsayı."""
    return f'{int(round(float(x))):,}'.replace(',', '.')

def yzd(x):
    v = float(x)
    if v < 0.05: return '&lt;0,1'
    if v > 99.95: return '&gt;99,9'
    return s(v, 1)

ISARET = {
    'PUB21': '<svg class="isaret" viewBox="0 0 12 12" aria-hidden="true"><rect x="1" y="1" width="10" height="10" fill="var(--pub)"/></svg>',
    'MIN21': '<svg class="isaret" viewBox="0 0 12 12" aria-hidden="true"><circle cx="6" cy="6" r="5" fill="var(--min)"/></svg>',
    'MAX21': '<svg class="isaret" viewBox="0 0 12 12" aria-hidden="true"><polygon points="6,1 11.5,11 0.5,11" fill="var(--max)"/></svg>',
    'COV21': '<svg class="isaret" viewBox="0 0 12 12" aria-hidden="true"><polygon points="6,0.5 11.5,6 6,11.5 0.5,6" fill="var(--cov)"/></svg>',
}
def fh(form, ad=None):
    """Form hücresi (satır başlığı)."""
    isr = ISARET.get(form, '<span class="isaret" aria-hidden="true"></span>')
    return f'<span class="form-hucre">{isr}{ad or form}</span>'

ALT = {'D': 'Depresyon', 'A': 'Kaygı', 'S': 'Stres'}
FORMLAR = ['PUB21', 'MIN21', 'MAX21', 'COV21']

def tablo(no, ad, basliklar, satirlar, not_, mod, dosya=None, sinif=''):
    """satirlar: [(satır başlığı html, [hücre html, ...]) veya ('grup', metin)]"""
    kimlik = 'tablo-' + no.lower().replace(' ', '-')
    bas = ''.join(f'<th scope="col">{b}</th>' for b in basliklar)
    govde = []
    for r in satirlar:
        if r[0] == 'grup':
            govde.append(f'<tr class="grup-satiri"><th scope="colgroup" colspan="{len(basliklar)}">{r[1]}</th></tr>')
            continue
        th, tds = r
        hucre = ''.join('<td><span class="bos">…</span></td>' if mod == 1 else f'<td>{t}</td>' for t in tds)
        govde.append(f'<tr><th scope="row">{th}</th>{hucre}</tr>')
    kay = ''
    if dosya:
        on, _, ek = dosya.partition(' (')
        parca = [f'<code>html_ciktilari/{x}</code>' for x in on.split(' ve ')]
        kay = ' Kaynak dosya: ' + ' ve '.join(parca) + (f' ({ek.replace("bütün θ ızgarası: ", "bütün θ ızgarası: <code>").rstrip(")")}</code>)' if ek else '') + '.'
    return (f'<figure class="tablo" id="{kimlik}"><figcaption class="tablo-bas"><span class="tablo-no">Tablo {no}</span>'
            f'<span class="tablo-ad">{ad}</span></figcaption><div class="tablo-kap"><table class="{sinif}"><thead><tr>{bas}</tr></thead>'
            f'<tbody>{"".join(govde)}</tbody></table></div><p class="not">{not_}{kay}</p></figure>')

_onbellek = {}
def sekil(no, ad, dosya, alt, not_, mod):
    kimlik = 'sekil-' + no.lower().replace(' ', '-')
    bas = (f'<figure class="sekil" id="{kimlik}"><figcaption class="tablo-bas"><span class="tablo-no">Şekil {no}</span>'
           f'<span class="tablo-ad">{ad}</span></figcaption>')
    if mod == 1:
        return bas + f'<div class="sekil-yer">Kod çalıştırıldığında şekil <code>html_ciktilari/{dosya}</code> dosyasına yazılır.</div></figure>'
    if dosya not in _onbellek:
        im = Image.open(f'{O}/{dosya}').convert('RGB')
        im.thumbnail((1800, 1800), Image.LANCZOS)
        b = io.BytesIO(); im.save(b, 'WEBP', quality=86)
        _onbellek[dosya] = (base64.b64encode(b.getvalue()).decode(), im.size)
    veri, (w, h) = _onbellek[dosya]
    return (bas + f'<div class="sekil-kap"><img src="data:image/webp;base64,{veri}" alt="{ESC(alt)}" width="{w}" height="{h}"></div>'
            f'<p class="not">{not_} Kaynak dosya: <code>html_ciktilari/{dosya}</code>.</p></figure>')

def kod_metni(dosya):
    return open(f'{K}/{dosya}.R', encoding='utf-8').read().rstrip('\n')

def kod(kid, ad, dosya):
    a = ESC(ad, quote=True)
    return (f"<h3>R kodu</h3><figure class='kod'><div class='kod-bas'><span class='kod-ad'>{a}</span>"
            f"<button type='button' class='kopya' data-hedef='k-{kid}' aria-label='{a} kodunu kopyala'>Kopyala</button></div>"
            f"<pre tabindex='0'><code id='k-{kid}' class='language-r'>{ESC(kod_metni(dosya))}</code></pre></figure>")

def liste(ogeler):
    return '<ul>' + ''.join(f'<li>{x}</li>' for x in ogeler) + '</ul>'

def soylenmez(ogeler):
    return '<div class="soylenmez"><p class="etiket">Yorumda söylenmez</p>' + liste(ogeler) + '</div>'

def bulgu(ozet, govde):
    return (f'<details class="bulgu"><summary><span class="bulgu-ad">Bulgular</span><span class="bulgu-ozet">{ozet}</span></summary>'
            f'<div class="bulgu-govde">{govde}</div></details>')
