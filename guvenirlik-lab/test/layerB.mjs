// Katman B (ve L): Playwright ile tarayıcı testleri. Sonuçlar test/out/browser-results.json'a yazılır.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
let pw; try { pw = require('playwright'); } catch (e) { pw = require('/opt/node22/lib/node_modules/playwright'); }
const C = require(path.join(ROOT, 'src/core.js'));
const K = require(path.join(ROOT, 'src/content.tr.js'));
const OUT = path.join(ROOT, 'test/out'); fs.mkdirSync(path.join(OUT, 'shots'), { recursive: true });
const KATEX_URL = 'https://cdn.jsdelivr.net/npm/katex@0.18.9/dist/katex.min.js';
const KATEX_LOCAL = path.join(ROOT, 'node_modules/katex/dist/katex.min.js');
const AXE = fs.readFileSync(path.join(ROOT, 'node_modules/axe-core/axe.min.js'), 'utf8');
const MODS = ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9'];
const WIDTHS = [360, 390, 1280];
const results = [];
const rec = (id, pass, detail) => results.push({ id, pass: !!pass, detail: String(detail == null ? '' : detail).slice(0, 600) });

// artifact-design sayfa sözleşmesindeki iskelet ve sıfırlama + izin listesine uyan CSP
function wrap(fragment) {
  return '<!doctype html><html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">' +
    '<meta http-equiv="Content-Security-Policy" content="script-src \'unsafe-inline\' https://cdnjs.cloudflare.com https://cdn.jsdelivr.net/npm/; style-src \'unsafe-inline\' https://fonts.googleapis.com; font-src data: https://fonts.gstatic.com; img-src data: blob:; connect-src \'none\'">' +
    '<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;font:14px system-ui,sans-serif;background:#fafaf9}img{max-width:100%}[hidden]{display:none!important}</style>' +
    '</head><body>' + fragment + '</body></html>';
}
const RES = path.join(ROOT, 'test/out/research/index.html');
const pages = { index: wrap(fs.readFileSync(path.join(ROOT, 'dist/index.html'), 'utf8')), static: wrap(fs.readFileSync(path.join(ROOT, 'dist/static.html'), 'utf8')), research: fs.existsSync(RES) ? wrap(fs.readFileSync(RES, 'utf8')) : null };
let katexRouteHits = 0;

const browser = await pw.chromium.launch({ executablePath: fs.existsSync('/opt/pw-browsers/chromium') ? undefined : undefined });
async function open(which, opts) {
  const o = opts || {};
  const ctx = await browser.newContext({ viewport: { width: o.width || 1280, height: 900 }, colorScheme: o.theme || 'light', reducedMotion: o.reduced ? 'reduce' : 'no-preference' });
  const page = await ctx.newPage();
  const logs = { errors: [], warnings: [], pageErrors: [] };
  page.on('console', m => { if (m.type() === 'error') logs.errors.push(m.text()); if (m.type() === 'warning') logs.warnings.push(m.text()); });
  page.on('pageerror', e => logs.pageErrors.push(String(e)));
  await page.route('**/*', async route => {
    const url = route.request().url();
    if (url === KATEX_URL) { katexRouteHits++; return route.fulfill({ status: 200, contentType: 'application/javascript', body: fs.readFileSync(KATEX_LOCAL) }); }
    if (url.startsWith('https://fonts.googleapis.com/') || url.startsWith('https://fonts.gstatic.com/')) return route.fulfill({ status: 200, contentType: 'text/css', body: '' });
    if (url.startsWith('https://lab.test/')) return route.fulfill({ status: 200, contentType: 'text/html; charset=utf-8', body: pages[url.includes('static') ? 'static' : url.includes('research') ? 'research' : 'index'] });
    return route.abort();
  });
  await page.addInitScript(() => { try { localStorage.clear(); } catch (e) { /* yok */ } });
  await page.goto('https://lab.test/' + (which === 'static' ? 'static.html' : which === 'research' ? 'research.html' : 'index.html'));
  await page.waitForFunction(() => window.RelLab && document.querySelector('#modul'));
  return { page, ctx, logs };
}
const trNum = s => { const t = String(s).replace(/\s/g, '').replace('−', '-').replace(/\./g, '').replace(',', '.'); return parseFloat(t); };
async function gotoMod(page, m, extra) { await page.evaluate(([m, e]) => { window.RelLab.setState(Object.assign({ module: m }, e || {})); }, [m, extra || {}]); }

try {
  // --- B1, B2, B4, B5, B6, B10, B16.4 : her modül, genişlik, tema ---------------
  const b1 = { e: [], w: [], p: [] }; let katexErr = 0, rawFrac = 0, rawDollar = 0, emInText = 0;
  const b5role = [], b5q = [], b6 = { 360: [], 390: [], 1280: [] }, shots = [];
  for (const theme of ['light', 'dark']) for (const width of WIDTHS) {
    const { page, ctx, logs } = await open('index', { width, theme });
    for (const m of MODS.concat(['m10'])) {
      await gotoMod(page, m, { view: 'real' });
      const info = await page.evaluate(() => ({
        kerr: document.querySelectorAll('.katex-error').length, text: document.body.innerText,
        roles: [...document.querySelectorAll('[data-role]')].map(n => n.getAttribute('data-role')).filter(r => ['T', 'E', 'eta', 'B', 'g'].includes(r)).length,
        hq: [...document.querySelectorAll('[data-q]')].map(n => n.getAttribute('data-q')).filter(k => k.startsWith('gizli.')).length,
        sw: document.documentElement.scrollWidth, iw: window.innerWidth,
      }));
      katexErr += info.kerr; if (/\\frac/.test(info.text)) rawFrac++; if (/\$\$/.test(info.text)) rawDollar++; if (/—/.test(info.text)) emInText++;
      if (info.roles) b5role.push(m + '@' + width); if (info.hq) b5q.push(m + '@' + width);
      if (info.sw > info.iw) b6[width].push(m + ' (' + info.sw + ' > ' + info.iw + ', ' + theme + ')');
      const shot = path.join(OUT, 'shots', `${m}-${width}-${theme}.png`); await page.screenshot({ path: shot, fullPage: false }); shots.push(shot);
      // perde arkası da hatasız açılmalı
      await gotoMod(page, m, { view: 'backstage' });
      await gotoMod(page, m, { view: 'real' });
    }
    for (const pg of ['etki', 'sozluk', 'kaynaklar', 'hakkinda']) { await page.evaluate(p => window.RelLab.go(p), pg); const sw = await page.evaluate(() => [document.documentElement.scrollWidth, window.innerWidth]); if (sw[0] > sw[1]) b6[width].push(pg); }
    b1.e.push(...logs.errors); b1.w.push(...logs.warnings); b1.p.push(...logs.pageErrors);
    await ctx.close();
  }
  rec('B1.1', b1.e.length === 0, b1.e.length + ' hata ' + b1.e.slice(0, 3).join(' | '));
  rec('B1.2', b1.w.length === 0, b1.w.length + ' uyarı ' + b1.w.slice(0, 3).join(' | '));
  rec('B1.3', b1.p.length === 0, b1.p.length + ' sayfa hatası ' + b1.p.slice(0, 3).join(' | '));
  rec('B2.1', katexErr === 0, katexErr + ' .katex-error'); rec('B2.2', rawFrac === 0, rawFrac + ' sayfada ham \\frac'); rec('B2.3', rawDollar === 0, rawDollar + ' sayfada $$');
  rec('B5.1', b5role.length === 0, b5role.join(', ') || 'yok'); rec('B5.2', b5q.length === 0, b5q.join(', ') || 'yok');
  rec('B6.1', b6[360].length === 0, b6[360].join('; ') || 'taşma yok'); rec('B6.2', b6[390].length === 0, b6[390].join('; ') || 'taşma yok'); rec('B6.3', b6[1280].length === 0, b6[1280].join('; ') || 'taşma yok');
  rec('B10.1', shots.every(f => fs.existsSync(f)), shots.length + ' ekran görüntüsü test/out/shots/ altında');
  rec('B16.4', emInText === 0, emInText + ' sayfada U+2014');

  // --- B3, B4, B4b, B7, B12, B13, B14, B16.6, B17 (1280 açık tema) ----------------
  const { page, ctx, logs } = await open('index', { width: 1280 });
  const dq = async (key) => trNum(await page.$eval(`[data-q="${key}"]`, n => n.textContent));
  // B3 yön testleri (DOM üzerinden)
  await gotoMod(page, 'm3', { params: { sigmaE: 4, sigmaT: 8 } }); const r0 = await dq('m3.rho');
  await gotoMod(page, 'm3', { params: { sigmaE: 8 } }); const r1 = await dq('m3.rho'); rec('B3.1', r1 < r0, `${r0} → ${r1}`);
  await gotoMod(page, 'm3', { params: { sigmaE: 4, sigmaT: 12 } }); const r2 = await dq('m3.rho'); rec('B3.2', r2 > r0, `${r0} → ${r2}`);
  await gotoMod(page, 'm4', { params: C.defaultState('m4').params }); const m0 = await dq('m4.ortalama_orneklem'), rr0 = await dq('m4.rho'), x0 = await dq('m4.rho_xeta'), s0 = await dq('m4.r12');
  await gotoMod(page, 'm4', { params: { c: 6 } }); const m1 = await dq('m4.ortalama_orneklem'), rr1 = await dq('m4.rho');
  rec('B3.3', Math.abs(m1 - m0) > 1, `${m0} → ${m1}`); rec('B3.4', rr1 === rr0, `${rr0} → ${rr1}`);
  await gotoMod(page, 'm4', { params: { c: 0, sB: Math.sqrt(20) } }); const rr2 = await dq('m4.rho'), x2 = await dq('m4.rho_xeta');
  rec('B3.5', rr2 >= rr0, `${rr0} → ${rr2}`); rec('B3.6', x2 < x0, `${x0} → ${x2}`);
  await gotoMod(page, 'm4', { params: { sB: 0, mu: 95, ceiling: false } }); const cA = await dq('m4.r12');
  await gotoMod(page, 'm4', { params: { ceiling: true } }); const cB = await dq('m4.r12'); rec('B3.7', cA !== cB, `${cA} → ${cB}`);
  await gotoMod(page, 'm4', { params: C.defaultState('m4').params });
  await gotoMod(page, 'm9', { params: { nPrime: 2 } }); const e2 = await dq('m9.erho2'), p2 = await dq('m9.phi');
  await gotoMod(page, 'm9', { params: { nPrime: 8 } }); const e8 = await dq('m9.erho2'), p8 = await dq('m9.phi');
  rec('B3.8', e8 > e2, `${e2} → ${e8}`); rec('B3.9', p8 > p2, `${p2} → ${p8}`);
  void s0;
  // B4: her data-q değeri derive ile eşleşir
  for (const [i, m] of MODS.entries()) {
    await page.evaluate(m => window.RelLab.applyPreset(window.RelLab.listPresets().find(p => p.startsWith(m + '.'))), m);
    const r = await page.evaluate(() => { const d = window.RelLab.derive(); return [...document.querySelectorAll('#modul [data-q]')].map(n => [n.getAttribute('data-q'), n.textContent, d[n.getAttribute('data-q')]]); });
    const bad = r.filter(([k, t, v]) => { const x = parseFloat(String(t).replace(/\s/g, '').replace('−', '-').replace(/\./g, '').replace(',', '.')); const dec = (String(t).split(',')[1] || '').length; return !(typeof v === 'number' && Math.abs(x - v) <= 0.5 * Math.pow(10, -dec) + 1e-12); });
    rec('B4.' + (i + 1), r.length > 0 && bad.length === 0, r.length + ' data-q; uyuşmayan: ' + bad.slice(0, 4).map(b => b.join('=')).join('; '));
  }
  // B4b
  await page.evaluate(() => window.RelLab.applyPreset('m7.alfa')); rec('B4b.1', (await page.$eval('[data-q="m7.alfa"]', n => n.textContent)) === '0,80', await page.$eval('[data-q="m7.alfa"]', n => n.textContent));
  rec('B4b.6', (await page.$eval('[data-q="m7.osh"]', n => n.textContent)) === '2,00', await page.$eval('[data-q="m7.osh"]', n => n.textContent));
  await page.evaluate(() => window.RelLab.applyPreset('m9.varsayilan'));
  const t9 = async k => page.$eval(`[data-q="${k}"]`, n => n.textContent);
  rec('B4b.2', trNum(await t9('m9.KOp')) === 5, await t9('m9.KOp')); rec('B4b.3', trNum(await t9('m9.KOi')) === 2, await t9('m9.KOi')); rec('B4b.4', trNum(await t9('m9.KOart')) === 1, await t9('m9.KOart'));
  rec('B4b.5', (await t9('m9.phi')).startsWith('0,77'), await t9('m9.phi'));
  // B7: klavye ve erişilebilir ad
  const unreach = [], noname = [];
  for (const m of MODS.concat(['m10'])) {
    await gotoMod(page, m, { view: 'real', params: C.defaultState(m).params });
    const r = await page.evaluate(() => {
      const ctl = [...document.querySelectorAll('#uygulama input, #uygulama button, #uygulama select, #uygulama textarea, #uygulama [role="slider"], #uygulama [role="button"]')].filter(n => n.offsetParent !== null || n.closest('svg'));
      const nameOf = n => (n.getAttribute('aria-label') || (n.id && document.querySelector(`label[for="${n.id}"]`)?.textContent) || n.closest('label')?.textContent || n.textContent || n.getAttribute('title') || '').trim();
      return { unreach: ctl.filter(n => n.disabled ? false : (n.tabIndex < 0)).map(n => n.outerHTML.slice(0, 80)), noname: ctl.filter(n => !nameOf(n)).map(n => n.outerHTML.slice(0, 80)) };
    });
    unreach.push(...r.unreach.map(x => m + ': ' + x)); noname.push(...r.noname.map(x => m + ': ' + x));
  }
  rec('B7.1', unreach.length === 0, unreach.slice(0, 3).join(' | ') || 'hepsi odaklanabilir');
  rec('B7.2', noname.length === 0, noname.slice(0, 3).join(' | ') || 'hepsinin adı var');
  await gotoMod(page, 'm3', { params: { sigmaT: 8, sigmaE: 4 } });
  const before = await page.$eval('#k-sigmaE', n => n.value), qb = await dq('m3.rho');
  await page.focus('#k-sigmaE'); await page.keyboard.press('ArrowRight');
  const after = await page.$eval('#k-sigmaE', n => n.value), qa = await dq('m3.rho');
  rec('B7.3', before !== after, `${before} → ${after}`); rec('B7.4', qa !== qb, `${qb} → ${qa}`);
  // B12 geometri
  await gotoMod(page, 'm3', { view: 'backstage', params: { second: true } });
  const geo = await page.evaluate(() => [...document.querySelectorAll('#butce .cubuk')].map(c => { const W = c.getBoundingClientRect().width - 2, tot = Number(c.dataset.total); return [...c.children].map(s => ({ w: s.getBoundingClientRect().width, exp: W * Number(s.dataset.v) / tot })); }));
  await gotoMod(page, 'm9', { view: 'real' });
  const geo9 = await page.evaluate(() => [...document.querySelectorAll('#butce .cubuk')].map(c => { const W = c.getBoundingClientRect().width - 2, tot = Number(c.dataset.total); return [...c.children].map(s => ({ w: s.getBoundingClientRect().width, exp: W * Number(s.dataset.v) / tot })); }));
  const geoBad = geo.concat(geo9).flat().filter(s => Math.abs(s.w - s.exp) > 1);
  rec('B12.1', geo.length + geo9.length > 0 && geoBad.length === 0, (geo.flat().length + geo9.flat().length) + ' bölüt; 1 px dışı: ' + geoBad.length);
  await gotoMod(page, 'm1', { view: 'real', params: C.defaultState('m1').params });
  const sq = await page.evaluate(() => [...document.querySelectorAll('[data-kare]')].map(r => [Number(r.dataset.area), Number(r.dataset.dev2), r.getBoundingClientRect().width * r.getBoundingClientRect().height]));
  const ratios = sq.filter(s => s[1] > 1e-9).map(s => s[0] / s[1]); rec('B12.2', ratios.length === 8 && Math.max(...ratios) - Math.min(...ratios) < 1e-6 * Math.max(...ratios), 'oranlar ' + ratios.map(r => r.toFixed(4)).join(', '));
  await gotoMod(page, 'm8', { params: C.defaultState('m8').params });
  const m8 = await page.evaluate(() => { const d = window.RelLab.derive(); return { txt: document.querySelector('#modul .grafik + p.not').textContent, iz: d['m8.iz'], od: d['m8.kosegen_disi'] }; });
  const f2 = v => new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(v);
  rec('B12.3', m8.txt.includes('iz = ' + f2(m8.iz)) && m8.txt.includes(f2(m8.od)), m8.txt.slice(0, 120));
  // B13: ne değişti
  const b13 = [];
  for (const [m, id, vals] of [['m3', '#k-sigmaE', ['8', '4', '4']], ['m4', '#k-c', ['5', '5', '-3']], ['m9', '#k-nPrime', ['9', '2']]]) {
    await gotoMod(page, m, { view: 'real', params: C.defaultState(m).params });
    for (const v of vals) {
      await page.$eval(id, (n, v) => { n.value = v; n.dispatchEvent(new Event('input', { bubbles: true })); n.dispatchEvent(new Event('change', { bubbles: true })); }, v);
      const words = await page.$$eval('#ne-degisti b[data-yon]', bs => bs.map(b => [b.dataset.yon, Number(b.dataset.delta)]));
      words.forEach(([w, d]) => { const exp = Math.abs(d) < 0.005 ? 'değişmedi' : d > 0 ? 'arttı' : 'azaldı'; if (w !== exp) b13.push(`${m} ${v}: ${w} ≠ ${exp}`); });
      if (!words.length) b13.push(m + ' ' + v + ': satır boş');
    }
  }
  rec('B13.1', b13.length === 0, b13.join('; ') || 'sözcükler işaretle eşleşiyor');
  // B14: her TGA kartının sonucu ve etki haritası
  const b14 = [];
  for (const card of K.tga) {
    await page.evaluate(([m]) => window.RelLab.setState({ module: m, expert: true }), [card.module]);
    const exists = await page.$(`[data-tga="${card.id}"]`); if (!exists) { b14.push(card.id + ' kart yok'); continue; }
    await page.check(`#${card.id.replace(/\./g, '\\.')}-artar`);
    await page.click(`[data-tga="${card.id}"] .dugme.birincil`);
    const got = await page.$eval(`[data-tga="${card.id}"] [data-sonuc]`, n => n.dataset.sonuc);
    const a = C.derive(C.presetState(card.onceki))[card.q], b = C.derive(C.presetState(card.preset))[card.q], d = b - a, exp = Math.abs(d) < 0.005 ? 'degismez' : d > 0 ? 'artar' : 'azalir';
    if (got !== exp) b14.push(`${card.id}: ekranda ${got}, RelCore ${exp}`);
    if (exp !== card.dogru) b14.push(`${card.id}: içerikteki doğru yanıt (${card.dogru}) RelCore (${exp}) ile uyuşmuyor`);
  }
  await page.evaluate(() => window.RelLab.go('etki'));
  const filled = await page.$$eval('tr[data-satir] td[data-satir]', ts => ts.map(t => [t.dataset.satir, t.textContent]));
  for (const [row, txt] of filled) { const r = K.effectMap.satirlar.find(x => x.id === row); const card = K.tga.find(t => t.id === r.tga); const a = C.derive(C.presetState(card.onceki))[card.q], b = C.derive(C.presetState(card.preset))[card.q], d = b - a, exp = K.ui.yonler[Math.abs(d) < 0.005 ? 'degismez' : d > 0 ? 'artar' : 'azalir']; if (!txt.includes('Sonuç: ' + exp)) b14.push(row + ': ' + txt); }
  rec('B14.1', b14.length === 0 && filled.length === K.effectMap.satirlar.length, `${filled.length}/${K.effectMap.satirlar.length} satır doldu; ` + (b14.join('; ') || 'yönler eşleşiyor'));
  // B17: belirlenimcilik
  const states = MODS.map(m => { const s = C.defaultState(m); s.seed = 11; if (m === 'm2') s.params.reps = 40; if (m === 'm5') s.params.dataMode = 'sim'; return s; });
  const nodeDig = states.map(s => C.digest(C.derive(s)));
  const brDig = await page.evaluate(st => st.map(s => window.RelCore.digest(window.RelCore.derive(s))), states);
  rec('B17.1', JSON.stringify(nodeDig) === JSON.stringify(brDig), 'Node ' + nodeDig.join(',') + ' / Chromium ' + brDig.join(','));
  const others = fs.existsSync('/opt/pw-browsers') ? fs.readdirSync('/opt/pw-browsers').filter(d => /firefox|webkit/.test(d)) : [];
  rec('B17.2', true, others.length ? 'ek motorlar: ' + others.join(', ') + ' (sınanmadı)' : 'Sınırlılık: /opt/pw-browsers içinde Firefox veya WebKit yok; yalnızca Chromium sınandı.');
  rec('B16.6', katexRouteHits > 0, katexRouteHits + ' kez');
  b1.e.push(...logs.errors); await ctx.close();

  // --- B8 azaltılmış hareket --------------------------------------------------
  { const { page, ctx } = await open('index', { reduced: true }); let anim = 0; for (const m of MODS) { await gotoMod(page, m); anim += await page.evaluate(() => document.getAnimations().length); } rec('B8.1', anim === 0, anim + ' animasyon'); await ctx.close(); }

  // --- B9 durağan sürüm --------------------------------------------------------
  { const st = await open('static'); const it = await open('index'); let ranges = 0, drag = 0; const diffs = [];
    for (const m of MODS) {
      await gotoMod(st.page, m); ranges += await st.page.$$eval('input[type="range"]', n => n.length); drag += await st.page.$$eval('[data-draggable], [draggable="true"]', n => n.length);
      for (const p of C.listPresets().filter(x => x.startsWith(m + '.'))) {
        const get = async pg => { await pg.evaluate(p => window.RelLab.applyPreset(p), p); return pg.$$eval('#modul [data-q]', ns => Object.fromEntries(ns.map(n => [n.getAttribute('data-q'), n.textContent]))); };
        const a = await get(st.page), b = await get(it.page);
        for (const k of Object.keys(a)) if (k in b && a[k] !== b[k]) diffs.push(`${p} ${k}: ${a[k]} ≠ ${b[k]}`);
      }
    }
    rec('B9.1', ranges === 0, ranges + ' range'); rec('B9.2', drag === 0, drag + ' sürüklenebilir'); rec('B9.3', diffs.length === 0, diffs.slice(0, 4).join('; ') || 'aynı');
    await st.ctx.close(); await it.ctx.close(); }

  // --- B15 axe-core -------------------------------------------------------------
  { const viol = { 'color-contrast': [], 'aria-hidden-focus': [], label: [], 'button-name': [] };
    for (const theme of ['light', 'dark']) { const { page, ctx } = await open('index', { theme }); await page.addScriptTag({ content: AXE });
      for (const m of MODS.concat(['m10'])) for (const view of ['real', 'backstage']) {
        await gotoMod(page, m, { view });
        const r = await page.evaluate(async () => (await window.axe.run(document, { runOnly: { type: 'rule', values: ['color-contrast', 'aria-hidden-focus', 'label', 'button-name'] } })).violations.map(v => [v.id, v.nodes.length, v.nodes.slice(0, 2).map(n => n.target.join(' ') + ' ' + (n.failureSummary || '').slice(0, 90)).join(' || ')]));
        r.forEach(([id, n, t]) => viol[id].push(`${theme}/${m}/${view}: ${n} (${t})`));
      }
      await ctx.close(); }
    rec('B15.1', viol['color-contrast'].length === 0, viol['color-contrast'].slice(0, 3).join(' | ') || '0 ihlal'); rec('B15.2', viol['aria-hidden-focus'].length === 0, viol['aria-hidden-focus'].slice(0, 3).join(' | ') || '0 ihlal');
    rec('B15.3', viol.label.length === 0, viol.label.slice(0, 3).join(' | ') || '0 ihlal'); rec('B15.4', viol['button-name'].length === 0, viol['button-name'].slice(0, 3).join(' | ') || '0 ihlal'); }

  // --- Katman L: olay kaydı (RESEARCH=1 derlemesi) ---------------------------------
  if (pages.research) {
    const { page, ctx } = await open('research');
    const drag = async () => page.$eval('#k-sigmaE', n => { for (const v of ['5', '6', '7']) { n.value = v; n.dispatchEvent(new Event('input', { bubbles: true })); } n.dispatchEvent(new Event('change', { bubbles: true })); });
    await page.evaluate(() => { document.querySelector('[role="dialog"] #onam-hayir').click(); });
    await gotoMod(page, 'm3'); await drag();
    rec('L1.1', (await page.evaluate(() => window.RelLog.rows().length)) === 0, 'onamsız satır: ' + await page.evaluate(() => window.RelLog.rows().length));
    await page.reload(); await page.waitForFunction(() => window.RelLog && document.querySelector('#onam-kod'));
    const code = await page.evaluate(() => { const s = '482915'; return s + window.RelLog.dammDigit(s); });
    await page.fill('#onam-kod', '1234567'); await page.click('#onam-evet'); const rejected = await page.evaluate(() => !!document.querySelector('#onam-kod'));
    await page.fill('#onam-kod', code); await page.click('#onam-evet');
    await gotoMod(page, 'm3'); const n0 = await page.evaluate(() => window.RelLog.rows().filter(r => r.event === 'degisim').length);
    await drag(); const n1 = await page.evaluate(() => window.RelLog.rows().filter(r => r.event === 'degisim').length);
    rec('L3.1', n1 - n0 === 1, 'sürükleme başına satır: ' + (n1 - n0) + '; geçersiz kod reddedildi: ' + rejected);
    const rows = await page.evaluate(() => window.RelLog.rows()), F = await page.evaluate(() => window.RelLog.FIELDS);
    rec('L2.1', rows.length > 0 && rows.every(r => F.every(f => f in r) && /^\d{7}$/.test(r.pid)), rows.length + ' satır');
    rec('L2.2', rows.every(r => Object.keys(r).every(k => F.includes(k))), 'alanlar: ' + (rows[0] ? Object.keys(rows[0]).join(',') : '-'));
    const csv = await page.evaluate(() => window.RelLog.toCSV());
    const parse = t => { const out = []; let row = [], cur = '', q = false; t = t.replace(/^\ufeff/, ''); for (let i = 0; i < t.length; i++) { const c = t[i]; if (q) { if (c === '"' && t[i + 1] === '"') { cur += '"'; i++; } else if (c === '"') q = false; else cur += c; } else if (c === '"') q = true; else if (c === ',') { row.push(cur); cur = ''; } else if (c === '\r') { } else if (c === '\n') { row.push(cur); out.push(row); row = []; cur = ''; } else cur += c; } return out; };
    const back = parse(csv), head = back[0], body = back.slice(1);
    const same = body.length === rows.length && body.every((r, i) => head.every((h, j) => String(rows[i][h]) === r[j]));
    rec('L4.1', same, body.length + ' satır geri okundu');
    await ctx.close();
    const n = await open('index'); await gotoMod(n.page, 'm3'); await n.page.$eval('#k-sigmaE', x => { x.value = '6'; x.dispatchEvent(new Event('change', { bubbles: true })); });
    rec('L5.1', await n.page.evaluate(() => typeof window.RelLog === 'undefined'), 'RelLog tanımsız'); await n.ctx.close();
    const bundle = fs.readFileSync(path.join(ROOT, 'dist/index.html'), 'utf8');
    rec('L5.2', !/window\.RelLog\s*=|guvlab\.kayit|onam-baslik/.test(bundle), 'kayıt imzası taraması');
  }
} finally { await browser.close(); }

// --- Dosya düzeyi denetimler: B11, B16 -------------------------------------------
{ const exp = JSON.parse(fs.readFileSync(path.join(ROOT, 'formulas.expected.json'), 'utf8')), cat = new Map(exp.formulas.map(f => [f.id, f.tex]));
  const strip = t => { let s = t; for (;;) { const i = s.indexOf('\\htmlClass{'); if (i < 0) return s; const j = s.indexOf('}{', i); let depth = 1, k = j + 2; while (k < s.length && depth) { if (s[k] === '{') depth++; else if (s[k] === '}') depth--; k++; } s = s.slice(0, i) + s.slice(j + 2, k - 1) + s.slice(k); } };
  const bad = Object.entries(K.formulas).filter(([id, f]) => cat.get(id) !== strip(f.tex)).map(([id, f]) => id + (cat.has(id) ? ': ' + strip(f.tex) + ' ≠ ' + cat.get(id) : ': katalogda yok'));
  rec('B11.1', bad.length === 0, Object.keys(K.formulas).length + ' formül; uyuşmayan: ' + bad.slice(0, 4).join(' | ')); }
{ const pat = /download=|fetch\(|XMLHttpRequest|alert\(|confirm\(|prompt\(|window\.print/g;
  for (const [id, f] of [['B16.1', 'dist/index.html'], ['B16.2', 'dist/static.html']]) { const m = fs.readFileSync(path.join(ROOT, f), 'utf8').match(pat) || []; rec(id, m.length === 0, m.length + ' eşleşme ' + [...new Set(m)].join(', ')); }
  rec('B16.3', !/—/.test(fs.readFileSync(path.join(ROOT, 'src/content.tr.js'), 'utf8')), 'U+2014 taraması');
  rec('B16.5', fs.readFileSync(path.join(ROOT, 'dist/index.html'), 'utf8').slice(0, 8192).includes('<title>Güvenirlik Laboratuvarı</title>'), 'ilk 8 KB'); }

fs.writeFileSync(path.join(OUT, 'browser-results.json'), JSON.stringify({ date: new Date().toISOString(), results }, null, 2));
const fails = results.filter(r => !r.pass);
console.log(`Katman B: ${results.length - fails.length}/${results.length} geçti`);
fails.forEach(f => console.log('KALDI ' + f.id + ': ' + f.detail));
