/* Güvenirlik Laboratuvarı: arayüz. Tek bir durum nesnesi; ekrandaki her sayı RelCore'dan gelir. */
(function () {
  'use strict';
  const C = window.RelCore, K = window.RelContent, BUILD = window.REL_BUILD || {};
  const STATIC = BUILD.cond === 'duragan';
  const SHOW_TGA = BUILD.tga !== false;

  // ---------------------------------------------------------------------------
  // Durum
  // ---------------------------------------------------------------------------
  const MODS = K.modules.map(m => m.id);
  const S = {
    module: 'm1', page: 'modul', view: 'real', seed: 1, denom: 'n-1', expert: false, digits: 2,
    params: {}, tga: {}, effect: {}, m7tab: 'alpha', m7round: 1, m1screen: 1, fillDiag: false, m10: {},
  };
  MODS.forEach(m => { S.params[m] = C.defaultState(m).params; });
  function store(key, val) { try { localStorage.setItem('guvlab.' + key, JSON.stringify(val)); } catch (e) { /* depolama yok */ } }
  function load(key, def) { try { const v = localStorage.getItem('guvlab.' + key); return v ? JSON.parse(v) : def; } catch (e) { return def; } }
  S.tga = load('tga', {}); S.effect = load('etki', {}); S.m10 = load('m10', {});
  const startMod = load('modul', 'm1'); if (MODS.includes(startMod)) S.module = startMod;
  if (/^#m(10|[1-9])$/.test(location.hash)) S.module = location.hash.slice(1);
  S.view = { m2: 'backstage', m3: 'backstage', m4: 'backstage' }[S.module] || 'real';

  function coreState(mod) {
    const m = mod || S.module;
    return { module: m, view: S.view, seed: S.seed, denom: S.denom, expert: S.expert, digits: S.digits, params: S.params[m] };
  }
  function Q() { return C.project(coreState(), S.view); }

  // ---------------------------------------------------------------------------
  // Yardımcılar
  // ---------------------------------------------------------------------------
  const nf = {};
  function fmt(v, d) {
    if (v == null || Number.isNaN(v)) return '–';
    if (!Number.isFinite(v)) return '∞';
    const dd = d == null ? S.digits : d, key = dd;
    if (!nf[key]) nf[key] = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: dd, maximumFractionDigits: dd });
    const s = nf[key].format(Math.abs(v) < 0.5 * Math.pow(10, -dd) ? 0 : v);
    return s.replace('-', '−');
  }
  function el(tag, attrs, ...kids) {
    const e = document.createElement(tag);
    for (const k in (attrs || {})) {
      const v = attrs[k]; if (v == null || v === false) continue;
      if (k === 'class') e.className = v; else if (k === 'html') e.innerHTML = v; else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
      else e.setAttribute(k, v === true ? '' : v);
    }
    for (const c of kids.flat()) if (c != null && c !== false) e.append(c.nodeType ? c : document.createTextNode(c));
    return e;
  }
  // Yerel append null değerini "null" metnine çevirir; put boş değerleri atlar
  function put(parent, ...kids) { parent.append(...kids.flat().filter(k => k != null && k !== false)); return parent; }
  const NS = 'http://www.w3.org/2000/svg';
  function sv(tag, attrs, ...kids) {
    const e = document.createElementNS(NS, tag);
    for (const k in (attrs || {})) { const v = attrs[k]; if (v == null || v === false) continue; if (k.startsWith('on')) e.addEventListener(k.slice(2), v); else e.setAttribute(k, v); }
    for (const c of kids.flat()) if (c != null) e.append(c.nodeType ? c : document.createTextNode(c));
    return e;
  }
  function scale(d0, d1, r0, r1) { const f = x => r0 + (x - d0) * (r1 - r0) / ((d1 - d0) || 1); f.inv = y => d0 + (y - r0) * (d1 - d0) / ((r1 - r0) || 1); return f; }
  function qspan(key, d) { return el('span', { 'data-q': key, 'data-d': d == null ? '' : d }, '–'); }
  function gosterge(ad, key, opt) {
    const o = opt || {};
    return el('div', { class: 'gosterge' + (o.gizli ? ' gizli' : '') }, el('span', { class: 'ad' }, ad), el('span', { class: 'deger' }, qspan(key, o.d)), o.ek ? el('span', { class: 'ek' }, o.ek) : null, o.gizli ? el('span', { class: 'etiket-gizli' }, 'perde arkası') : null);
  }
  function tex(t, display) {
    if (window.katex) {
      try {
        return window.katex.renderToString(t, { displayMode: display !== false, output: 'htmlAndMathml', throwOnError: false, trust: c => c.command === '\\htmlClass', strict: c => (c === 'htmlExtension' ? 'ignore' : 'warn') });
      } catch (e) { /* aşağıdaki yedeğe düş */ }
    }
    const pre = document.createElement('code'); pre.className = 'katex-yedek'; pre.textContent = t; return pre.outerHTML;
  }
  const live = () => document.getElementById('canli');
  let announceTimer = null;
  function announce(text) { clearTimeout(announceTimer); announceTimer = setTimeout(() => { const l = live(); if (l) l.textContent = text; }, 400); }

  // Kaydırıcı: yerel range + düzenlenebilir sayı kutusu
  function slider(o) {
    const id = 'k-' + o.key.replace(/\W/g, '-');
    const P = S.params[S.module];
    const val = o.get ? o.get() : P[o.key];
    const vt = v => o.label + ': ' + fmt(v, o.d == null ? 1 : o.d) + (o.unit ? ' ' + o.unit : '');
    const range = el('input', { type: 'range', id, min: o.min, max: o.max, step: o.step, value: val, 'aria-valuetext': vt(val), disabled: o.locked });
    const num = el('input', { type: 'number', id: id + '-s', min: o.min, max: o.max, step: o.step, value: Number(val).toFixed(o.d == null ? 1 : o.d), 'aria-label': o.label + ' (sayı)', disabled: o.locked });
    let before = null;
    const setv = (v, final) => {
      v = Math.min(o.max, Math.max(o.min, Number(v))); if (!Number.isFinite(v)) return;
      if (before == null) before = snapshot();
      if (o.set) o.set(v); else P[o.key] = v;
      range.value = v; num.value = v.toFixed(o.d == null ? 1 : o.d); range.setAttribute('aria-valuetext', vt(v));
      update();
      if (final) { neDegisti(before, o.label, o.primary); before = null; }
    };
    range.addEventListener('input', () => setv(range.value, false));
    range.addEventListener('change', () => setv(range.value, true));
    num.addEventListener('change', () => setv(num.value.replace(',', '.'), true));
    return el('div', { class: 'kaydirici' + (o.locked ? ' kilitli' : '') },
      el('label', { for: id }, el('span', null, o.label), o.locked ? el('span', { class: 'kilit' }, 'kilitli: uzman modunda açılır') : el('span', { class: 'not' }, o.hint || '')), range, num);
  }
  function check(label, get, set, id) {
    const inp = el('input', { type: 'checkbox', id: 'o-' + id }); inp.checked = !!get();
    inp.addEventListener('change', () => { const b = snapshot(); set(inp.checked); update(); neDegisti(b, label); });
    return el('label', { class: 'onay', for: 'o-' + id }, inp, label);
  }
  function button(label, fn, cls) { return el('button', { type: 'button', class: 'dugme' + (cls ? ' ' + cls : ''), onclick: fn }, label); }

  // ---------------------------------------------------------------------------
  // "Ne değişti, neden?" satırı
  // ---------------------------------------------------------------------------
  const PRIMARY = {
    m1: [['m1.varyans', 'Varyans'], ['m1.r', 'r']], m2: [['m2.ortalama', 'Ölçmelerin ortalaması']], m3: [['m3.rho', 'Güvenirlik (evren)'], ['m3.osh', 'ÖSH']],
    m4: [['m4.rho', 'Güvenirlik (evren)'], ['m4.rho_xeta', 'Yapıyla korelasyon'], ['m4.ortalama', 'Ortalama']], m5: [['m5.hata', 'Kestirilen hata varyansı'], ['m5.r', 'r']],
    m6: [['m6.alfa', 'Tek oturum α'], ['m6.tekrar', 'Test-tekrar test']], m7: [['m7.alfa', 'α']], m8: [['m8.alfa', 'α'], ['m8.omega', 'ω']], m9: [['m9.erho2', 'G katsayısı'], ['m9.phi', 'Φ']],
  };
  function snapshot() { return Q(); }
  function yon(d) { return Math.abs(d) < 0.005 ? 'değişmedi' : d > 0 ? 'arttı' : 'azaldı'; }
  function neDegisti(before, what) {
    const box = document.getElementById('ne-degisti'); if (!box) return;
    const after = Q(), parts = [];
    let first = null;
    for (const [key, ad] of (PRIMARY[S.module] || [])) {
      if (!(key in after) || !(key in before)) continue;
      const d = after[key] - before[key], w = yon(d);
      if (!first) first = { key, d, w };
      parts.push(`${ad} ${fmt(before[key])} → ${fmt(after[key])}: <b data-yon="${w}" data-delta="${d}">${w}</b>`);
    }
    let extra = '';
    const pair = { m3: ['m3.rho', 'm3.r12'], m4: ['m4.rho', 'm4.r12'] }[S.module];
    if (pair && pair[1] in after && pair[1] in before) {
      const dp = after[pair[0]] - before[pair[0]], ds = after[pair[1]] - before[pair[1]];
      if (Math.abs(dp) >= 0.005 && Math.sign(dp) !== Math.sign(ds) && Math.abs(ds) >= 0.005) extra = ' Evren değeri ' + (dp < 0 ? 'düştü' : 'yükseldi') + '; bu sınıftaki kestirim örnekleme dalgalanması nedeniyle biraz ' + (ds > 0 ? 'yükseldi' : 'düştü') + '. Yeni sınıf çekerek dene.';
    }
    box.innerHTML = `<span>${what} değişti.</span> ` + parts.join('; ') + '.' + extra;
    announce(box.textContent);
    logEvent('degisim', { param: what });
  }

  // ---------------------------------------------------------------------------
  // Formül kartı
  // ---------------------------------------------------------------------------
  function formulaCard(id, sayilar) {
    const f = K.formulas[id]; if (!f) return el('div', null, 'Eksik formül: ' + id);
    const classes = [...new Set([...f.tex.matchAll(/\\htmlClass\{(t-[a-z-]+)\}/g)].map(m => m[1]))];
    const sembol = el('div', { class: 'sembol', html: tex(f.tex) });
    const card = el('div', { class: 'formul-kart', 'data-formul': id },
      f.okuma ? el('div', null, el('div', { class: 'katman-ad' }, 'Sözle'), el('p', { class: 'sozle' }, f.okuma)) : null,
      el('div', null, el('div', { class: 'katman-ad' }, 'Sembolle'), sembol),
      sayilar ? el('div', null, el('div', { class: 'katman-ad' }, 'Sayılarla'), el('div', { class: 'sayilar' }, sayilar)) : null);
    if (classes.length) {
      const row = el('div', { class: 'terimler', role: 'group', 'aria-label': 'Terimler' });
      for (const cls of classes) {
        const b = el('button', { type: 'button', class: 'terim', 'aria-pressed': 'false', 'data-term': cls }, K.terms[cls] || cls);
        b.addEventListener('click', () => toggleTerm(card, cls, b));
        b.addEventListener('focus', () => highlight(card, cls, true));
        b.addEventListener('blur', () => { if (b.getAttribute('aria-pressed') !== 'true') highlight(card, cls, false); });
        put(row, b);
      }
      put(card, el('div', null, el('div', { class: 'katman-ad' }, 'Terimler'), row));
    }
    return card;
  }
  document.addEventListener('click', e => {
    const n = e.target.closest && e.target.closest('#modul [data-term]'); if (!n || n.classList.contains('terim')) return;
    n.getAttribute('data-term').split(/\s+/).forEach(cls => document.querySelectorAll(`#modul .terim[data-term="${cls}"]`).forEach(b => b.click()));
  });
  function highlight(card, cls, on) {
    card.querySelectorAll('.' + cls).forEach(n => n.classList.toggle('vurgulu', on));
    document.querySelectorAll(`#modul [data-term~="${cls}"]`).forEach(n => { if (!n.classList.contains('terim')) n.classList.toggle('vurgulu', on); });
  }
  function toggleTerm(card, cls, b) { const on = b.getAttribute('aria-pressed') !== 'true'; b.setAttribute('aria-pressed', on ? 'true' : 'false'); highlight(card, cls, on); }
  function formulas(ids, nums) { return el('div', { class: 'formuller' }, ids.map(id => formulaCard(id, nums && nums[id]))); }
  // Sayılarla satırı: "{q:anahtar}" belirteçlerini canlı sayılara çevirir
  function N(template) {
    const out = el('span');
    template.split(/(\{[^}]+\})/).forEach(part => { const m = part.match(/^\{(.+)\}$/); put(out, m ? qspan(m[1]) : part); });
    return out;
  }

  // ---------------------------------------------------------------------------
  // TGA kartları ve kontrol soruları
  // ---------------------------------------------------------------------------
  function directionOf(card) {
    const a = C.derive(C.presetState(card.onceki))[card.q], b = C.derive(C.presetState(card.preset))[card.q];
    const d = b - a; return { a, b, yon: Math.abs(d) < 0.005 ? 'degismez' : d > 0 ? 'artar' : 'azalir' };
  }
  function tgaCard(card) {
    const saved = S.tga[card.id] || {};
    const box = el('div', { class: 'tga', 'data-tga': card.id, 'data-preset': card.preset });
    put(box, el('div', { class: 'ust-etiket' }, 'Tahmin et, gözle, açıkla'), el('p', { class: 'soru' }, card.soru));
    const fs = el('fieldset', null, el('legend', null, 'Tahminin'));
    for (const y of ['artar', 'azalir', 'degismez']) {
      const inp = el('input', { type: 'radio', name: card.id + '-yon', id: card.id + '-' + y, value: y }); if (saved.tahmin === y) inp.checked = true;
      put(fs, el('label', { class: 'onay', for: card.id + '-' + y }, inp, K.ui.yonler[y]));
    }
    const gs = el('fieldset', null, el('legend', null, 'Ne kadar eminsin?'));
    K.ui.guven.forEach((g, i) => { const inp = el('input', { type: 'radio', name: card.id + '-guven', id: card.id + '-g' + i, value: i }); if (saved.guven === i) inp.checked = true; put(gs, el('label', { class: 'onay', for: card.id + '-g' + i }, inp, g)); });
    const sonuc = el('div', { class: 'sonuc', hidden: !saved.goster });
    const show = () => {
      const t = box.querySelector(`input[name="${card.id}-yon"]:checked`), g = box.querySelector(`input[name="${card.id}-guven"]:checked`);
      const st = S.tga[card.id] = Object.assign(S.tga[card.id] || {}, { tahmin: t ? t.value : null, guven: g ? Number(g.value) : null, goster: true });
      renderResult(card, sonuc, st); sonuc.hidden = false; store('tga', S.tga);
      logEvent('tga_sonuc', { module: card.module, param: card.id, value: st.tahmin, new: directionOf(card).yon, old: st.guven });
    };
    put(box, fs, gs, el('div', { class: 'satir' }, button(K.ui.sonucuGoster, show, 'birincil'), STATIC ? null : button('Bu durumu laboratuvarda aç', () => applyPreset(card.preset))), sonuc);
    if (saved.goster) renderResult(card, sonuc, saved);
    return box;
  }
  function renderResult(card, box, st) {
    const r = directionOf(card), dogru = st.tahmin === r.yon;
    box.innerHTML = '';
    put(box, el('p', null, `${K.ui.tahminin}: ${st.tahmin ? K.ui.yonler[st.tahmin] : 'seçilmedi'}. ${K.ui.sonuc}: `, el('b', { 'data-sonuc': r.yon }, K.ui.yonler[r.yon]), ` (${fmt(r.a)} → ${fmt(r.b)}). `, el('span', { class: dogru ? 'dogru' : 'yanlis' }, dogru ? 'Tahminin doğru.' : 'Tahminin sonuçla uyuşmuyor.')));
    const rs = el('fieldset', null, el('legend', null, 'Açıkla: hangi gerekçe sonucu en iyi açıklıyor?'));
    for (const g of card.gerekceler) {
      const inp = el('input', { type: 'radio', name: card.id + '-ger', id: card.id + '-' + g.id, value: g.id }); if (st.gerekce === g.id) inp.checked = true;
      inp.addEventListener('change', () => { st.gerekce = g.id; store('tga', S.tga); fb.textContent = g.dogru ? 'Doğru gerekçe (' + g.c + ').' : 'Bu gerekçe bir yanılgıya dayanıyor (' + g.c + '). Doğru gerekçe: ' + card.gerekceler.find(x => x.dogru).t; fb.className = g.dogru ? 'dogru' : 'yanlis'; logEvent('tga_gerekce', { module: card.module, param: card.id, value: g.id }); });
      put(rs, el('label', { class: 'onay', for: card.id + '-' + g.id }, inp, g.t));
    }
    const fb = el('p', { 'aria-live': 'polite' });
    put(box, rs, fb);
    const row = K.effectMap.satirlar.find(x => x.tga === card.id);
    if (row) { S.effect[row.id] = { tahmin: st.tahmin, sonuc: r.yon }; store('etki', S.effect); }
  }
  function controlQs(list) {
    return el('div', { class: 'bolum' }, el('h3', null, 'Kontrol soruları'), list.map((c, i) => {
      const d = el('details', { class: 'kontrol', 'data-anahtar': c.anahtar });
      const ans = el('p', { hidden: true }, c.yanit);
      const inp = c.sayi != null ? el('input', { type: 'text', inputmode: 'decimal', id: 'kt-' + c.anahtar, 'aria-label': 'Yanıtın', class: 'dugme', style: 'width:8em' }) : null;
      const fb = el('span', { 'aria-live': 'polite' });
      put(d, el('summary', null, c.soru), el('div', { class: 'satir' }, inp, inp ? button('Kontrol et', () => {
        const v = parseFloat(inp.value.replace(',', '.')); const okk = Math.abs(v - c.sayi) <= Math.max(0.006, Math.abs(c.sayi) * 0.005);
        fb.textContent = Number.isFinite(v) ? (okk ? 'Doğru.' : 'Tekrar dene; yanıtı göstererek hesabı karşılaştırabilirsin.') : 'Bir sayı yaz (ondalık için virgül veya nokta).';
      }) : null, button(K.ui.yanitiGoster, () => { ans.hidden = false; }), fb), ans);
      return d;
    }));
  }

  // ---------------------------------------------------------------------------
  // Varyans bütçesi
  // ---------------------------------------------------------------------------
  function budgetSegments(q) {
    const m = S.module, P = S.params[m], back = S.view === 'backstage';
    const out = { bars: [], note: '', konum: null };
    const bar = (label, segs) => out.bars.push({ label, segs: segs.map(s => Object.assign({}, s, { v: Math.max(0, s.v) })) });
    if (m === 'm3') {
      if (P.second) bar('Gerçek dünya (' + K.ui.butceKestirim + ')', [{ seg: 'kestT', ad: 'kestirilen gerçek s₁₂', v: q['m3.s12'] }, { seg: 'kestE', ad: 'kestirilen hata s̄²_X − s₁₂', v: q['m3.tahmini_hata'] }]);
      else { bar('Gerçek dünya', [{ seg: 'X', ad: 'toplam s²_X', v: q['m3.sX2'] }]); out.note = K.ui.ikinciGerek; }
      if (back) bar('Perde arkası (evren)', [{ seg: 'T', ad: 'σ²_T', v: q['m3.sigmaT2'] }, { seg: 'E', ad: 'σ²_E', v: q['m3.sigmaE2'] }]);
    } else if (m === 'm4') {
      bar('Gerçek dünya (' + K.ui.butceKestirim + ')', [{ seg: 'kestT', ad: 'kestirilen gerçek s₁₂', v: q['m4.s12'] }, { seg: 'kestE', ad: 'kestirilen hata s̄²_X − s₁₂', v: q['m4.hata_kestirim'] }]);
      if (back && P.ceiling) out.note = 'Tavan açık: kesmeli modelin kapalı biçimli ayrıştırması yok; evren çubuğu gösterilmiyor, güvenirlik 20000 kişilik simülasyondan gelir.';
      else if (back) {
        const pop = C.errorLabPopulation({ sEta2: P.sEta ** 2, sE2: P.sE ** 2, sB2: P.sB ** 2, pi: P.pi, gamma: P.gamma, rhoBEta: P.rhoBEta, biasVaries: P.biasVaries, w: P.w });
        const w2 = P.w * P.w;
        const contrib = pop.sTrue2 - P.sEta ** 2, segs = [];
        // Kararlı yanlılığın katkısı (σ²_U + 2σ_ηU) negatifse ayrı bölüt çizilemez: gerçek puan bölütünden düşülür
        if (contrib >= 0) segs.push({ seg: 'eta', ad: 'yapı varyansı (η)', v: w2 * P.sEta ** 2 }, { seg: 'B', ad: P.biasVaries ? 'alt grup kayması' : 'kararlı yanlılık', v: w2 * contrib });
        else segs.push({ seg: 'eta', ad: 'KTK gerçek varyansı (η ' + fmt(w2 * P.sEta ** 2) + ' − negatif yanlılık katkısı ' + fmt(-w2 * contrib) + ') =', v: w2 * pop.sTrue2 });
        segs.push({ seg: 'c', ad: 'sabit c: sabit bir sayının varyansı yoktur', v: 0 });
        segs.push({ seg: 'E', ad: P.biasVaries ? 'tesadüfi hata (değişen yanlılık dahil)' : 'tesadüfi hata', v: w2 * pop.sE2 });
        bar('Perde arkası (evren): KTK gerçek puan varyansı = η + kararlı yanlılık', segs);
      }
      out.konum = { v: q['m4.ortalama'], min: 0, max: 100, ad: 'Konum: ortalama ' + fmt(q['m4.ortalama'], 1) + ' (sabit hata ve orantılı hata burada kayma olarak görünür; sabit bir sayının varyansı yoktur)' };
    } else if (m === 'm5') {
      bar('Gerçek dünya (' + K.ui.butceKestirim + ', iki formun ortalaması)', [{ seg: 'kestT', ad: 'kestirilen gerçek s₁₂', v: q['m5.s12'] }, { seg: 'kestE', ad: 'kestirilen hata s²_D/2', v: q['m5.hata'] }]);
    } else if (m === 'm6') {
      const k = P.k; bar('Evren: tek formun madde ortalaması puanı', [{ seg: 'T', ad: 'kişi σ²_p', v: P.sp }, { seg: 'madde', ad: 'kişi×madde σ²_pi/k', v: P.spi / k }, { seg: 'B', ad: 'kişi×gün σ²_po', v: P.spo }, { seg: 'E', ad: 'artık σ²_e/k', v: P.se / k }]);
    } else if (m === 'm7') {
      const tot = q['m7.toplam_var'], a = q['m7.alfa'];
      bar('Toplam puan (' + K.ui.butceKestirim + ')', [{ seg: 'kestT', ad: 'kestirilen gerçek k²s̄ᵢⱼ', v: a * tot }, { seg: 'kestE', ad: 'kestirilen hata', v: (1 - a) * tot }]);
    } else if (m === 'm8') {
      const tot = q['m8.toplam'], k = C.derive(coreState())._matrix.length, tv = k * k * q['m8.ort_kov'];
      bar('Toplam puan', [{ seg: 'kestT', ad: 'k²σ̄ᵢⱼ', v: tv }, { seg: 'kestE', ad: 'kalan', v: tot - tv }]);
      if (back) { const st = q['gizli.m8.SigmaT_toplam']; bar('Perde arkası: 1ᵀΣ_T1 ve hata', [{ seg: 'T', ad: 'gerçek', v: st }, { seg: 'E', ad: 'hata', v: tot - st }]); }
    } else if (m === 'm9') {
      const n = P.nPrime; bar('K çalışması (n\' = ' + n + '): mutlak hata bütçesi', [{ seg: 'T', ad: 'σ²_p', v: q['m9.sp'] }, { seg: 'madde', ad: 'σ²_i/n\'', v: q['m9.si'] / n }, { seg: 'E', ad: 'σ²_pi,e/n\'', v: q['m9.se'] / n }]);
    } else return null;
    return out;
  }
  function renderBudget(q) {
    const b = document.getElementById('butce');
    const data = budgetSegments(q);
    if (!data) { b.hidden = true; return; }
    b.hidden = false; b.innerHTML = '';
    put(b, el('div', { class: 'baslik' }, el('strong', null, K.ui.butce), data.note ? el('span', { class: 'not-uzun' }, data.note, ' ', S.module === 'm3' ? button(K.ui.ikinciOlcme, () => { S.params.m3.second = true; renderModule(); }) : null) : null));
    for (const bar of data.bars) {
      const tot = bar.segs.reduce((a, s) => a + s.v, 0) || 1;
      const cub = el('div', { class: 'cubuk', role: 'img', 'aria-label': bar.label + ': ' + bar.segs.map(s => s.ad + ' ' + fmt(s.v)).join(', '), 'data-bar': bar.label, 'data-total': tot });
      bar.segs.forEach(s => cub.append(el('div', { class: 'bolut', 'data-seg': s.seg, 'data-v': s.v, style: `flex: 0 0 ${(100 * s.v / tot).toFixed(4)}%`, title: s.ad + ': ' + fmt(s.v) })));
      put(b, el('div', { class: 'etiketler' }, el('span', null, bar.label + ':'), bar.segs.map(s => el('span', null, s.ad + ' ' + fmt(s.v)))), cub);
      put(b, el('div', { class: 'etiketler kisa', 'aria-hidden': 'true', hidden: window.innerWidth > 600 }, bar.segs.map(s => el('span', null, s.ad.split(' ')[0] + ' ' + fmt(s.v)))));
    }
    if (data.konum) { const p = Math.max(0, Math.min(100, 100 * (data.konum.v - data.konum.min) / (data.konum.max - data.konum.min))); put(b, el('div', { class: 'etiketler' }, data.konum.ad), el('div', { class: 'konum', role: 'img', 'aria-label': data.konum.ad }, el('i', { style: `left:${p}%` }))); }
  }

  // ---------------------------------------------------------------------------
  // Güncelleme
  // ---------------------------------------------------------------------------
  let current = null;
  function update() {
    const q = Q();
    if (current && current.update) current.update(q);
    // Değeri olmayan nicelik data-q taşımaz (B4); değer gelince öznitelik geri konur
    document.querySelectorAll('#modul [data-q], #modul [data-qk]').forEach(n => {
      const k = n.getAttribute('data-q') || n.getAttribute('data-qk'); const v = q[k];
      const d = n.getAttribute('data-d');
      if (typeof v === 'number') { n.setAttribute('data-q', k); n.removeAttribute('data-qk'); n.textContent = fmt(v, d === '' || d == null ? undefined : Number(d)); }
      else { n.removeAttribute('data-q'); n.setAttribute('data-qk', k); n.textContent = '–'; }
    });
    renderBudget(q);
  }

  // ---------------------------------------------------------------------------
  // Grafik yardımcıları
  // ---------------------------------------------------------------------------
  function axes(g, x, y, W, H, pad, xt, yt, xlab, ylab) {
    g.append(sv('line', { class: 'eksen', x1: pad.l, y1: H - pad.b, x2: W - pad.r, y2: H - pad.b }), sv('line', { class: 'eksen', x1: pad.l, y1: pad.t, x2: pad.l, y2: H - pad.b }));
    (xt || []).forEach(v => g.append(sv('text', { x: x(v), y: H - pad.b + 16, 'text-anchor': 'middle' }, fmt(v, 0))));
    (yt || []).forEach(v => g.append(sv('text', { x: pad.l - 6, y: y(v) + 4, 'text-anchor': 'end' }, fmt(v, 0))));
    if (xlab) g.append(sv('text', { x: (pad.l + W - pad.r) / 2, y: H - 4, 'text-anchor': 'middle' }, xlab));
    if (ylab) g.append(sv('text', { x: 12, y: (pad.t + H - pad.b) / 2, transform: `rotate(-90 12 ${(pad.t + H - pad.b) / 2})`, 'text-anchor': 'middle' }, ylab));
  }
  function ticks(a, b, n) { const step = niceStep((b - a) / (n || 5)); const out = []; for (let v = Math.ceil(a / step) * step; v <= b + 1e-9; v += step) out.push(Math.round(v * 1e6) / 1e6); return out; }
  function niceStep(r) { const p = Math.pow(10, Math.floor(Math.log10(r || 1))); const f = r / p; return (f < 1.5 ? 1 : f < 3 ? 2 : f < 7 ? 5 : 10) * p; }
  function scatter(xs, ys, o) {
    const W = 360, H = 320, pad = { l: 44, r: 12, t: 12, b: 38 };
    const all = xs.concat(ys), lo = o.lo != null ? o.lo : Math.min(...all), hi = o.hi != null ? o.hi : Math.max(...all), m = (hi - lo) * 0.06 || 1;
    const x = scale(lo - m, hi + m, pad.l, W - pad.r), y = scale(lo - m, hi + m, H - pad.b, pad.t);
    const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': o.aria });
    const g = sv('g'); svg.append(g);
    axes(g, x, y, W, H, pad, ticks(lo, hi, 5), ticks(lo, hi, 5), o.xlab, o.ylab);
    if (o.line) g.append(sv('line', { x1: x(lo - m), y1: y(o.line.a + o.line.b * (lo - m)), x2: x(hi + m), y2: y(o.line.a + o.line.b * (hi + m)), stroke: 'var(--vurgu)', 'stroke-width': 2 }));
    if (o.diag) g.append(sv('line', { x1: x(lo - m), y1: y(lo - m), x2: x(hi + m), y2: y(hi + m), stroke: 'var(--cizgi)', 'stroke-dasharray': '4 4' }));
    if (o.rects) {
      const mx = C.mean(xs), my = C.mean(ys);
      xs.forEach((v, i) => { const pos = (v - mx) * (ys[i] - my) >= 0; g.append(sv('rect', { x: Math.min(x(v), x(mx)), y: Math.min(y(ys[i]), y(my)), width: Math.abs(x(v) - x(mx)), height: Math.abs(y(ys[i]) - y(my)), fill: pos ? 'var(--rol-T)' : 'none', 'fill-opacity': pos ? 0.07 : 0, stroke: pos ? 'none' : 'var(--rol-E)', 'stroke-opacity': 0.4, 'stroke-dasharray': pos ? null : '2 2', 'data-term': 't-dikdortgen' })); });
      g.append(sv('line', { x1: x(mx), y1: pad.t, x2: x(mx), y2: H - pad.b, stroke: 'var(--soluk)', 'stroke-dasharray': '3 3' }), sv('line', { x1: pad.l, y1: y(my), x2: W - pad.r, y2: y(my), stroke: 'var(--soluk)', 'stroke-dasharray': '3 3' }));
    }
    xs.forEach((v, i) => g.append(sv('circle', { cx: x(v), cy: y(ys[i]), r: o.r || 3.2, fill: o.fill || 'none', stroke: o.stroke || 'var(--rol-X)', 'stroke-width': 1.3, 'data-role': o.role || 'X' })));
    return el('div', { class: 'grafik' }, svg);
  }
  function tableOf(headers, rows, opts) {
    const t = el('table', { class: 'tablo' + (opts && opts.textCols ? ' metin' : '') }, el('thead', null, el('tr', null, headers.map((h, i) => el('th', { class: i && !(opts && opts.textCols && opts.textCols.includes(i)) ? 'n' : '' , scope: 'col' }, h)))), el('tbody', null, rows.map(r => el('tr', { class: r.cls || '' }, (r.cells || r).map((c, i) => el('td', { class: i && !(opts && opts.textCols && opts.textCols.includes(i)) ? 'n' : '' }, c && c.nodeType ? c : String(c)))))));
    return el('div', { class: 'tablo-kutu' }, t);
  }
  function showTable(btnLabel, make) {
    const holder = el('div', { hidden: true });
    const b = button(btnLabel || K.ui.tabloyuGoster, () => { holder.hidden = !holder.hidden; if (!holder.hidden) { holder.innerHTML = ''; put(holder, make()); } });
    return el('div', { class: 'denetimler' }, b, holder);
  }

  // ---------------------------------------------------------------------------
  // Modül kurucuları
  // ---------------------------------------------------------------------------
  const BUILDERS = {};

  BUILDERS.m1 = function (root) {
    const P = S.params.m1;
    const scr1 = el('div', { class: 'panel' });
    const svg1 = sv('svg', { viewBox: '0 0 640 330', role: 'img', 'aria-label': 'Sekiz puan ve sapma kareleri' });
    const tbl1 = el('div');
    const draw1 = () => {
      svg1.innerHTML = '';
      const pts = P.points, m = C.mean(pts), lo = Math.min(0, Math.min(...pts) - 5), hi = Math.max(100, Math.max(...pts) + 5);
      const x = scale(lo, hi, 30, 610), axY = 90;
      svg1.append(sv('line', { class: 'eksen', x1: 30, y1: axY, x2: 610, y2: axY, stroke: 'var(--cizgi)' }));
      ticks(lo, hi, 8).forEach(v => svg1.append(sv('text', { x: x(v), y: axY + 18, 'text-anchor': 'middle' }, fmt(v, 0))));
      svg1.append(sv('line', { x1: x(m), y1: 22, x2: x(m), y2: axY + 4, stroke: 'var(--vurgu)', 'stroke-dasharray': '4 3' }), sv('text', { x: x(m), y: 16, 'text-anchor': 'middle' }, 'ortalama ' + fmt(m, 1)));
      const devs = pts.map(p => p - m), maxd = Math.max(...devs.map(Math.abs), 1), side = 90 / maxd;
      let cx = 34;
      pts.forEach((p, i) => {
        svg1.append(sv('line', { x1: x(p), y1: 52, x2: x(m), y2: 52, stroke: 'var(--rol-E)', 'stroke-width': 1.5, 'data-term': 't-sapma', opacity: .7 }));
        const s = Math.abs(devs[i]) * side;
        svg1.append(sv('rect', { x: cx, y: 118, width: s, height: s, fill: 'var(--rol-E)', 'fill-opacity': .18, stroke: 'var(--rol-E)', 'data-term': 't-kare t-toplam', 'data-kare': i, 'data-area': s * s, 'data-dev2': devs[i] * devs[i] }));
        svg1.append(sv('text', { x: cx + 2, y: 114 }, 'P' + (i + 1)));
        cx += Math.max(s, 18) + 6;
        const c = sv('circle', { class: STATIC ? '' : 'surukle', cx: x(p), cy: 52, r: 11, fill: 'var(--yuzey)', stroke: 'var(--rol-X)', 'stroke-width': 2.2, 'data-role': 'X', tabindex: STATIC ? null : 0, role: STATIC ? null : 'slider', 'aria-label': 'Öğrenci ' + (i + 1) + ' puanı', 'aria-valuenow': p, 'aria-valuemin': 0, 'aria-valuemax': 150, 'aria-valuetext': 'Öğrenci ' + (i + 1) + ' puanı: ' + fmt(p, 0) });
        if (!STATIC) {
          c.setAttribute('data-draggable', 'true');
          c.addEventListener('keydown', e => { const st = e.shiftKey ? 5 : 1; let v = null; if (e.key === 'ArrowRight' || e.key === 'ArrowUp') v = p + st; if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') v = p - st; if (v != null) { e.preventDefault(); const b = snapshot(); P.points[i] = Math.max(0, Math.min(150, v)); update(); neDegisti(b, 'Öğrenci ' + (i + 1) + ' puanı'); setTimeout(() => { const n = svg1.querySelectorAll('circle[role="slider"]')[i]; if (n) n.focus(); }, 0); } });
          c.addEventListener('pointerdown', e => {
            c.setPointerCapture(e.pointerId); const b = snapshot();
            const mv = ev => { const pt = svg1.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY; const loc = pt.matrixTransform(svg1.getScreenCTM().inverse()); P.points[i] = Math.round(Math.max(0, Math.min(150, x.inv(loc.x)))); update(); };
            const up = () => { c.removeEventListener('pointermove', mv); c.removeEventListener('pointerup', up); neDegisti(b, 'Öğrenci ' + (i + 1) + ' puanı'); };
            c.addEventListener('pointermove', mv); c.addEventListener('pointerup', up);
          });
        }
        svg1.append(c);
      });
      tbl1.innerHTML = '';
    };
    scr1.append(el('h3', null, 'Ekran 1: varyans'), el('div', { class: 'grafik' }, svg1),
      el('p', { class: 'not' }, 'Noktaları sürükle ya da seçip ok tuşlarıyla (Shift ile 5) taşı. Her karenin kenarı bir sapmadır; alanı sapmanın karesidir.'),
      STATIC ? null : el('div', { class: 'satir' }, button('Herkese +10', () => { const b = snapshot(); P.points = P.points.map(v => v + 10); update(); neDegisti(b, 'Herkese +10'); }), button('Herkesi ×2', () => { const b = snapshot(); const m = C.mean(P.points); P.points = P.points.map(v => Math.round((m + 2 * (v - m)) * 100) / 100); update(); neDegisti(b, 'Herkesi ×2'); }), button('Sıfırla', () => { const b = snapshot(); P.points = C.FIXTURES.m1Points.slice(); update(); neDegisti(b, 'Puanlar'); })),
      el('div', { class: 'gostergeler' }, gosterge('Ortalama', 'm1.ortalama', { d: 2 }), gosterge('Kareler toplamı', 'm1.ss'), gosterge('Varyans s²', 'm1.varyans'), gosterge('Standart sapma', 'm1.sd')),
      showTable(null, () => { const q = Q(), m = q['m1.ortalama']; return tableOf(['Öğrenci', 'X', 'X − X̄', '(X − X̄)²'], P.points.map((p, i) => ['P' + (i + 1), fmt(p, 1), fmt(p - m), fmt((p - m) ** 2)]).concat([{ cls: 'toplam', cells: ['Toplam', fmt(C.sum(P.points), 1), fmt(0), fmt(q['m1.ss'])] }])); }),
      el('p', { class: 'not' }, 'Serbestlik derecesi: sekiz noktadan yedisini sürüklersen sekizincinin sapması kendiliğinden belirlenir, çünkü sapmaların toplamı sıfırdır. Bu yüzden serbestçe değişebilen sapma sayısı n − 1\'dir (sd = ', qspan('m1.sd_derece', 0), ').'));
    const scr2 = el('div', { class: 'panel' });
    const plot2 = el('div');
    scr2.append(el('h3', null, 'Ekran 2: kovaryans ve korelasyon'), plot2,
      el('div', { class: 'lejant' }, el('span', null, 'Dolu dikdörtgen: aynı yönde sapmalar (+)'), el('span', null, 'Kesikli dikdörtgen: ters yönde sapmalar (−)')),
      STATIC ? null : el('div', { class: 'denetimler' }, slider({ key: 'noise', label: 'Test 2\'de gürültü', min: 0, max: 20, step: 1, d: 0, unit: 'puan' }), check('Test 2\'de herkese +10', () => P.shift2 === 10, v => { P.shift2 = v ? 10 : 0; }, 'kaydir2'), check('z puanı birimleri', () => P.zMode, v => { P.zMode = v; }, 'zmod'), button(K.ui.yeniSinif, () => newClass())),
      el('div', { class: 'gostergeler' }, gosterge('Kovaryans s₁₂', 'm1.kovaryans'), gosterge('Korelasyon r', 'm1.r'), gosterge('Test 1 varyansı', 'm1.varyans1'), gosterge('Test 2 varyansı', 'm1.varyans2')));
    put(root, el('div', { class: 'izgara' }, scr1, scr2));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(K.modules[0].formuller, { 'm1.varyans': N('s² = {m1.ss} / ' + (S.denom === 'n' ? P.points.length : P.points.length - 1) + ' = {m1.varyans}'), 'm1.korelasyon': N('r = {m1.kovaryans} / √({m1.varyans1} × {m1.varyans2}) = {m1.r}') })));
    return { update() { draw1(); const q = C.derive(coreState()); let { t1, t2 } = q._series; if (P.zMode) { t1 = C.zScores(t1); t2 = C.zScores(t2); } plot2.innerHTML = ''; plot2.append(scatter(t1, t2, { rects: true, aria: 'Test 1 ve Test 2 saçılım grafiği', xlab: P.zMode ? 'Test 1 (z)' : 'Test 1', ylab: P.zMode ? 'Test 2 (z)' : 'Test 2' })); } };
  };

  BUILDERS.m2 = function (root) {
    const P = S.params.m2, back = S.view === 'backstage';
    const plot = el('div', { class: 'grafik' });
    const panel = el('div', { class: 'panel' }, el('h3', null, 'Ayşe\'nin ölçmeleri'), plot,
      el('div', { class: 'lejant' }, el('span', null, 'Çubuklar: biriken ölçmeler X'), back ? el('span', null, 'Kesikli çizgi: gerçek puan T; oklar: son ölçmelerin hataları E') : null),
      STATIC ? null : el('div', { class: 'satir' }, button('1 kez ölç', () => measure(1), 'birincil'), button('10 kez ölç', () => measure(10)), button('1000 kez ölç', () => measure(1000)), button('Sıfırla', () => { P.reps = 0; update(); })),
      STATIC ? null : slider({ key: 'sigmaE', label: 'Ölçme ne kadar gürültülü? σ_E', min: 1, max: 10, step: 0.5, d: 1, unit: 'puan' }),
      el('div', { class: 'gostergeler' }, gosterge('Ölçme sayısı', 'm2.tekrar', { d: 0 }), gosterge('Ölçmelerin ortalaması', 'm2.ortalama'), gosterge('Ölçmelerin standart sapması', 'm2.sd'), back ? gostergeHidden('Gerçek puan T', () => P.T) : null));
    function measure(n) { const b = snapshot(); P.reps = Math.min(5000, (P.reps || 0) + n); update(); neDegisti(b, n + ' ölçme eklendi; ölçme sayısı'); logEvent('olc', { module: 'm2', value: n }); }
    const sym = S.expert ? null : el('div', { class: 'kart' }, el('h3', null, 'Semboller'), el('div', { class: 'formuller' }, K.modules[1].semboller.map(id => el('div', { class: 'formul-kart' }, el('div', { html: tex(K.formulas[id].tex, false) }), el('p', { class: 'sozle' }, K.formulas[id].okuma)))));
    put(root, sym, panel, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(K.modules[1].formuller, { 'm2.gercek_puan': N('Şimdiye kadarki ortalama: {m2.ortalama}') })));
    return {
      update() {
        const q = C.derive(coreState()), X = q._series.X; plot.innerHTML = '';
        const W = 640, H = 240, pad = { l: 40, r: 12, t: 14, b: 36 }, lo = P.T - 4 * P.sigmaE, hi = P.T + 4 * P.sigmaE;
        const x = scale(lo, hi, pad.l, W - pad.r); const nb = 32, bw = (hi - lo) / nb, counts = new Array(nb).fill(0);
        X.forEach(v => { const b = Math.floor((v - lo) / bw); if (b >= 0 && b < nb) counts[b]++; });
        const mc = Math.max(1, ...counts), y = scale(0, mc, H - pad.b, pad.t);
        const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Biriken ölçmelerin histogramı' }); const g = sv('g'); svg.append(g);
        axes(g, x, y, W, H, pad, ticks(lo, hi, 8), ticks(0, mc, 4), 'Puan', 'Sayı');
        counts.forEach((c, i) => c && g.append(sv('rect', { x: x(lo + i * bw) + 1, y: y(c), width: Math.max(1, x(lo + (i + 1) * bw) - x(lo + i * bw) - 2), height: y(0) - y(c), fill: 'var(--rol-X)', 'fill-opacity': .35, 'data-role': 'X', 'data-term': 't-gozlenen' })));
        if (X.length) g.append(sv('line', { x1: x(C.mean(X)), y1: pad.t, x2: x(C.mean(X)), y2: H - pad.b, stroke: 'var(--vurgu)', 'stroke-width': 2 }));
        if (back) {
          g.append(sv('line', { x1: x(P.T), y1: pad.t, x2: x(P.T), y2: H - pad.b, stroke: 'var(--rol-T)', 'stroke-width': 2, 'stroke-dasharray': '6 4', 'data-role': 'T', 'data-term': 't-gercek' }));
          X.slice(-8).forEach((v, i) => { const yy = pad.t + 10 + i * 10; g.append(sv('line', { x1: x(P.T), y1: yy, x2: x(v), y2: yy, stroke: 'var(--rol-E)', 'stroke-width': 2, 'marker-end': 'url(#ok)', 'data-role': 'E', 'data-term': 't-hata' })); });
          svg.prepend(sv('defs', null, sv('marker', { id: 'ok', viewBox: '0 0 8 8', refX: 7, refY: 4, markerWidth: 6, markerHeight: 6, orient: 'auto-start-reverse' }, sv('path', { d: 'M0,0 L8,4 L0,8 z', fill: 'var(--rol-E)' }))));
        }
        put(plot, svg);
      },
    };
  };
  function gostergeHidden(ad, fn) { const s = el('span', { class: 'deger' }, fmt(fn())); return el('div', { class: 'gosterge gizli' }, el('span', { class: 'ad' }, ad), s, el('span', { class: 'etiket-gizli' }, 'perde arkası')); }

  BUILDERS.m3 = function (root) {
    const P = S.params.m3, back = S.view === 'backstage';
    const plot = el('div', { class: 'grafik' }), sc = el('div');
    const ctr = STATIC ? null : el('div', { class: 'denetimler' },
      slider({ key: 'sigmaT', label: 'Öğrenciler gerçekte ne kadar farklı? σ_T', min: 1, max: 16, step: 0.5, d: 1, unit: 'puan' }),
      slider({ key: 'sigmaE', label: 'Ölçme ne kadar gürültülü? σ_E', min: 1, max: 12, step: 0.5, d: 1, unit: 'puan' }),
      el('div', { class: 'satir' }, button(K.ui.yeniSinif, () => newClass()), check(K.ui.ikinciOlcme, () => P.second, v => { P.second = v; }, 'ikinci3')));
    put(root, el('div', { class: 'izgara' },
      el('div', { class: 'panel' }, el('h3', null, '30 kişilik sınıf'), plot, el('div', { class: 'lejant' }, el('span', null, 'Halka: gözlenen puan X'), back ? el('span', null, 'Dolu daire: gerçek puan T; soluk çubuk: öğrencinin eğilim aralığı T ± ÖSH (hata varyansı bu genişliklerin ortalamasıdır); çizgi: hata E') : null), sc),
      el('div', { class: 'panel' }, ctr,
        el('div', { class: 'gostergeler' }, gosterge('Güvenirlik ρ (model ayarı)', 'm3.rho'), gosterge('ÖSH (model ayarı)', 'm3.osh'), gosterge('Bu sınıfta s²_X', 'm3.sX2'), P.second ? gosterge('İki ölçme r₁₂', 'm3.r12') : null, P.second ? gosterge('Kestirilen hata s̄²_X − s₁₂', 'm3.tahmini_hata') : null,
          back ? gosterge('Bu sınıfta s²_T', 'gizli.m3.sT2', { gizli: true }) : null, back ? gosterge('Bu sınıfta s²_E', 'gizli.m3.sE2', { gizli: true }) : null, back ? gosterge('Bu sınıfta s_TE (model: 0)', 'gizli.m3.sTE', { gizli: true }) : null, back ? gosterge('Bu sınıfta r_XT', 'gizli.m3.rXT', { gizli: true }) : null),
        el('p', { class: 'not' }, 'Gözlenen puanın gerçek puanla korelasyonu güvenirliğin kareköküdür: ', qspan('m3.rho_xt'), '. ', K.ui.dilNotu))));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(K.modules[2].formuller, { 'm3.rho_oran': N('ρ = {m3.sigmaT2} / {m3.sigmaX2} = {m3.rho}'), 'm3.osh': N('ÖSH = {m3.osh}'), 'm3.varyans_ayrisimi': N('σ²_X = {m3.sigmaT2} + {m3.sigmaE2} = {m3.sigmaX2}') })));
    return {
      update() {
        const q = C.derive(coreState()), { X, T } = q._series; plot.innerHTML = '';
        const W = 640, H = back ? 200 : 130, lo = Math.min(...X, ...(back ? T : [])) - 3, hi = Math.max(...X, ...(back ? T : [])) + 3, x = scale(lo, hi, 30, 610);
        const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Sınıfın puanları' });
        const yX = back ? 150 : 60, yT = 50;
        svg.append(sv('line', { class: 'eksen', x1: 30, y1: yX + 22, x2: 610, y2: yX + 22, stroke: 'var(--cizgi)' }));
        ticks(lo, hi, 8).forEach(v => svg.append(sv('text', { x: x(v), y: yX + 38, 'text-anchor': 'middle' }, fmt(v, 0))));
        X.forEach((v, i) => {
          const jit = ((i * 37) % 11) - 5;
          if (back) { svg.append(sv('line', { x1: x(T[i] - P.sigmaE), y1: yT + jit, x2: x(T[i] + P.sigmaE), y2: yT + jit, stroke: 'var(--rol-T)', 'stroke-opacity': .3, 'stroke-width': 3, 'data-term': 't-hata' })); svg.append(sv('line', { x1: x(T[i]), y1: yT + jit, x2: x(v), y2: yX + jit, stroke: 'var(--rol-E)', 'stroke-opacity': .5, 'data-role': 'E', 'data-term': 't-hata' })); svg.append(sv('circle', { cx: x(T[i]), cy: yT + jit, r: 4, fill: 'var(--rol-T)', 'data-role': 'T', 'data-term': 't-gercek' })); }
          svg.append(sv('circle', { cx: x(v), cy: yX + jit, r: 4.5, fill: 'none', stroke: 'var(--rol-X)', 'stroke-width': 1.5, 'data-role': 'X', 'data-term': 't-gozlenen' }));
        });
        svg.append(sv('text', { x: 30, y: yX - 14 }, 'Gözlenen X'));
        if (back) svg.append(sv('text', { x: 30, y: yT - 16 }, 'Gerçek T (perde arkası)'));
        put(plot, svg);
        sc.innerHTML = '';
        if (back) {
          const b = C.covariance(T, X) / C.variance(T), line = S.expert ? { a: C.mean(X) - b * C.mean(T), b } : null;
          put(sc, el('h4', null, 'Gerçek ve gözlenen puan (perde arkası)'), scatter(T, X, { aria: 'T ve X saçılımı', xlab: 'Gerçek puan T', ylab: 'Gözlenen puan X', diag: true, line, role: 'T', stroke: 'var(--rol-T)' }),
            el('p', { class: 'not' }, 'Gözlenen puanın gerçek puanla korelasyonu güvenirliğin kareköküdür.' + (S.expert ? ' Uzman: düz çizgi X\'in T\'ye regresyonu, kesikli çizgi X = T.' : '')));
        }
      },
    };
  };

  BUILDERS.m4 = function (root) {
    const P = S.params.m4, back = S.view === 'backstage', mod = K.modules[3];
    const ht = K.errorTable;
    put(root, el('div', { class: 'kart' }, el('h3', null, 'Ders notlarından laboratuvara: hata türleri'), tableOf(ht.basliklar, ht.satirlar, { textCols: [1, 2, 3, 4] }), el('p', { class: 'not' }, ht.alt)));
    const plot = el('div');
    const lock = !S.expert;
    const p1 = el('div', { class: 'panel' }, el('h4', null, 'Sabit ve kurala bağlı hata'), STATIC ? null : slider({ key: 'c', label: 'Sabit hata c (herkese, her tekrarda)', min: -10, max: 10, step: 1, d: 0, unit: 'puan' }), STATIC ? null : slider({ key: 'w', label: 'Orantılı hata w (X* = wX)', min: 0.5, max: 2, step: 0.05, d: 2 }));
    const p2 = el('div', { class: 'panel' }, el('h4', null, 'Kararlı ve tesadüfi hata'), STATIC ? null : slider({ key: 'sB', label: 'Kişiye özgü kararlı yanlılık σ_B', min: 0, max: 8, step: 0.25, d: 2, unit: 'puan' }), STATIC ? null : check('Yanlılık tekrarlarda değişiyor', () => P.biasVaries, v => { P.biasVaries = v; }, 'degisen'), STATIC ? null : slider({ key: 'sE', label: 'Tesadüfi hata σ_E', min: 1, max: 10, step: 0.25, d: 2, unit: 'puan' }));
    const p3 = S.expert && !STATIC ? el('div', { class: 'panel' }, el('h4', null, 'Uzman denetimleri'),
      slider({ key: 'pi', label: 'Alt grup oranı π', min: 0, max: 0.5, step: 0.05, d: 2 }), slider({ key: 'gamma', label: 'Alt gruba özgü kayma γ', min: 0, max: 10, step: 0.5, d: 1, unit: 'puan' }),
      slider({ key: 'rhoBEta', label: 'Yanlılığın yapıyla korelasyonu ρ_Bη', min: -0.9, max: 0.9, step: 0.05, d: 2 }), slider({ key: 'shift2only', label: 'Sabit kayma yalnızca ikinci ölçmede', min: 0, max: 10, step: 1, d: 0, unit: 'puan' }),
      slider({ key: 'mu', label: 'Sınıf ortalaması (tavan için)', min: 30, max: 95, step: 1, d: 0 }), check('Puanlar 0-100 aralığında kesilir (tavan ve taban)', () => P.ceiling, v => { P.ceiling = v; }, 'tavan')) : null;
    put(root, el('div', { class: 'izgara' },
      el('div', { class: 'panel' }, el('h3', null, 'Birinci ve ikinci ölçme'), plot,
        el('div', { class: 'gostergeler' }, gosterge('İki ölçme r₁₂ (bu sınıf)', 'm4.r12'), gosterge('Güvenirlik ρ (model ayarı)', 'm4.rho'), gosterge('ÖSH (model ayarı)', 'm4.osh'), gosterge('Ortalama (bu sınıf)', 'm4.ortalama_orneklem'), gosterge('50 kesme puanında geçme oranı', 'm4.gecme_orani'),
          gosterge('Yapıyla korelasyon ρ_Xη (yalnızca simülasyonda)', 'm4.rho_xeta', { ek: 'tavan √ρ' }), gosterge('Tavan √ρ', 'm4.tavan'),
          S.expert ? gosterge('ICC(C,1)', 'm4.icc_c1') : null, S.expert ? gosterge('ICC(A,1), mutlak uyum', 'm4.icc_a1') : null, S.expert ? gosterge('Farkların ortalaması', 'm4.ortalama_fark') : null, S.expert ? gosterge('Grup içi güvenirlik', 'm4.grup_ici_rho') : null,
          back ? gosterge('Bu sınıfta r_Xη', 'gizli.m4.r_xeta_orneklem', { gizli: true }) : null),
        el('p', { class: 'bayrak', id: 'm4-bayrak' }),
        el('p', { class: 'not' }, K.ui.geçerlikNotu)),
      el('div', { class: 'denetimler' }, p1, p2, p3)));
    put(root, el('div', { class: 'kart vurgu' }, el('h3', null, 'Ders kitaplarıyla uzlaştırma'), el('p', null, mod.uzlastirma.t), el('p', { class: 'not' }, 'İddialar: ' + mod.uzlastirma.c + '. ' + mod.uzlastirma.not)));
    put(root, el('div', { class: 'kart' }, el('h3', null, 'Özet'), el('p', null, mod.ozet.t)));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(mod.formuller, { 'm4.rho': N('ρ = {m4.rho}; ÖSH = {m4.osh}'), 'm4.rho_x_eta': N('ρ_Xη = {m4.rho_xeta}; tavan √ρ = {m4.tavan}') })));
    return {
      update() {
        const q = C.derive(coreState()), { X1, X2 } = q._series; plot.innerHTML = '';
        const fl = document.getElementById('m4-bayrak'); if (fl) { fl.textContent = [q['m4.model_simulasyon'] ? 'Tavan açık: 0-100 kesmesinin kapalı biçimli çözümü olmadığı için model değerleri sabit tohumlu 20000 kişilik simülasyondan hesaplanır.' : '', S.expert && q['m4.icc_kirpildi'] ? 'Negatif varyans bileşeni 0\'a çekildi; SPSS ve jamovi bu durumda farklı bir ICC(A,1) verir.' : ''].filter(Boolean).join(' '); }
        put(plot, scatter(X1, X2, { aria: 'Birinci ve ikinci ölçme saçılımı', xlab: 'Birinci ölçme X₁', ylab: 'İkinci ölçme X₂', diag: true, r: 2.6 }));
        if (back) {
          const h = q['gizli.m4.eta'], g = q['gizli.m4.g'];
          const t = tableOf(['Öğrenci', 'η (yapı)', 'B (yanlılık)', 'g', 'X₁', 'X₂'], X1.slice(0, 8).map((x, i) => ['P' + (i + 1), fmt(h[i]), fmt(q['gizli.m4.B'][i]), String(g[i]), fmt(x), fmt(X2[i])]));
          put(plot, el('p', { class: 'etiket-gizli' }, 'Perde arkası: ilk 8 öğrencinin bileşenleri'), t);
        }
      },
    };
  };

  BUILDERS.m5 = function (root) {
    const P = S.params.m5, back = S.view === 'backstage', mod = K.modules[4];
    const plot = el('div'), matrix = el('div'), conv = el('div'), band = el('div');
    const modeCtr = STATIC ? null : el('div', { class: 'anahtar', role: 'group', 'aria-label': 'Veri' },
      el('button', { type: 'button', 'aria-pressed': P.dataMode === 'fixed' ? 'true' : 'false', onclick: () => { P.dataMode = 'fixed'; renderModule(); } }, 'Çalışılmış veri (6 öğrenci)'),
      el('button', { type: 'button', 'aria-pressed': P.dataMode !== 'fixed' ? 'true' : 'false', onclick: () => { P.dataMode = 'sim'; if (P.n < 10) P.n = 30; renderModule(); } }, 'Simülasyon sınıfı'));
    const simCtr = (P.dataMode !== 'fixed' && !STATIC) ? el('div', { class: 'denetimler' },
      el('div', { class: 'satir' }, el('span', null, 'Sınıf büyüklüğü n:'), [10, 30, 100, 1000].map(n => el('button', { type: 'button', class: 'dugme', 'aria-pressed': P.n === n ? 'true' : 'false', onclick: () => { P.n = n; renderModule(); } }, String(n))), button(K.ui.yeniSinif, () => newClass())),
      slider({ key: 'memory', label: 'Bellek etkisi (hatalar ilişkili)', min: 0, max: 0.9, step: 0.05, d: 2 }),
      slider({ key: 'change', label: 'Farklı gerçek değişim', min: 0, max: 6, step: 0.5, d: 1, unit: 'puan' }),
      check('Eşit olmayan hata varyansları (ikinci formda 2 kat)', () => P.unequal, v => { P.unequal = v; }, 'esitdegil'),
      slider({ key: 'shift', label: 'Sabit kayma (ikinci formda)', min: 0, max: 5, step: 0.5, d: 1, unit: 'puan', locked: !S.expert })) : null;
    put(root, el('div', { class: 'satir' }, modeCtr));
    put(root, el('div', { class: 'izgara' },
      el('div', { class: 'panel' }, el('h3', null, '(a) Fark yolu'), plot,
        el('div', { class: 'gostergeler' }, gosterge('Farkların ortalaması D̄', 'm5.ortD'), gosterge('Farkların varyansı s²_D', 'm5.sD'), gosterge('Hata varyansı s²_D/2', 'm5.hata'), gosterge('Ortalama varyans', 'm5.ort_var'), gosterge('Güvenirlik 1 − hata/ortalama', 'm5.oran'), gosterge('ÖSH', 'm5.osh'), gosterge('Doğrudan r', 'm5.r')),
        P.dataMode === 'fixed' ? el('p', { class: 'not' }, 'İki değer, formların varyansları (14 ve 14,8) tam eşit olmadığı için biraz farklıdır; paralel formlarda aynıdır.') : null),
      el('div', { class: 'panel' }, el('h3', null, '(b) Kovaryans ve köşegen yolu'), matrix, simCtr)));
    put(root, el('div', { class: 'izgara' }, el('div', { class: 'panel' }, el('h3', null, '(c) Yakınsama: 100 sınıf'), conv), el('div', { class: 'panel' }, el('h3', null, '(e) ÖSH bandı'),
      STATIC ? null : slider({ key: 'bandX', label: 'Öğrencinin puanı X', min: 0, max: 40, step: 1, d: 0 }), el('p', null, 'X ± 1,96 ÖSH bandı: [', qspan('m5.bant_alt'), '; ', qspan('m5.bant_ust'), ']'),
      el('p', { class: 'not' }, 'Varsayılan simülasyonda hata varyansı herkes için aynıdır. %95, tekrarlanan ölçmelerde bu aralıkların yaklaşık %95\'inin gerçek puanı kapsaması demektir; tek bir aralık için "%95 olasılıkla içerir" denmez.'), band)));
    put(root, el('div', { class: 'kart' }, el('h3', null, 'Epistemik not'), el('p', null, 'Hatayı hiçbir zaman gözlemeyiz; tekrarlar arasındaki uyumsuzluğu gözler ve bir model altında hatayı çıkarsarız. Anahtarlar o modelin varsayımlarını görünür kılar.')));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(mod.formuller, { 'm5.hata_fark_yolu': N('σ̂²_E = {m5.sD} / 2 = {m5.hata}'), 'm5.hata_kovaryans_yolu': N('r = {m5.r}'), 'm5.osh_bandi': N('[{m5.bant_alt}; {m5.bant_ust}]') })));
    let filled = false;
    return {
      update(qq) {
        const q = C.derive(coreState()), { x1, x2 } = q._series; plot.innerHTML = '';
        const W = 640, n = Math.min(x1.length, 30), H = 26 + n * 14, lo = Math.min(...x1.slice(0, n), ...x2.slice(0, n)) - 1, hi = Math.max(...x1.slice(0, n), ...x2.slice(0, n)) + 1, x = scale(lo, hi, 60, 620);
        const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Her öğrenci için iki ölçme arasındaki fark' });
        for (let i = 0; i < n; i++) { const y = 16 + i * 14; svg.append(sv('text', { x: 4, y: y + 4 }, 'P' + (i + 1)), sv('line', { x1: x(x1[i]), y1: y, x2: x(x2[i]), y2: y, stroke: 'var(--rol-E)', 'stroke-width': 3, 'data-term': 't-fark t-hata' }), sv('circle', { cx: x(x1[i]), cy: y, r: 4, fill: 'var(--rol-X)' }), sv('circle', { cx: x(x2[i]), cy: y, r: 4, fill: 'none', stroke: 'var(--rol-X)', 'stroke-width': 1.5 })); }
        put(plot, el('div', { class: 'grafik' }, svg), el('div', { class: 'lejant' }, el('span', null, '● X₁'), el('span', null, '○ X₂'), el('span', null, 'Çizgi: fark D')));
        if (P.dataMode === 'fixed') put(plot, showTable(null, () => tableOf(['Öğrenci', 'X₁', 'X₂', 'D = X₁ − X₂'], x1.map((v, i) => ['P' + (i + 1), v, x2[i], v - x2[i]]))));
        matrix.innerHTML = '';
        const s1 = qq['m5.s1'], s2 = qq['m5.s2'], s12 = qq['m5.s12'];
        const cell = (v, extra) => el('td', { class: 'n' }, fmt(v), extra ? el('div', { class: 'not' }, extra) : null);
        put(matrix, el('p', null, 'Kovaryans matrisi S. Köşegen dışı değer iki formun paylaştığıdır; gerçek varyansın kestirimidir.'),
          el('div', { class: 'tablo-kutu' }, el('table', { class: 'tablo' }, el('tbody', null, el('tr', null, filled ? cell(s12, 'kalan ' + fmt(qq['m5.kalan1'])) : cell(s1), cell(s12)), el('tr', null, cell(s12), filled ? cell(s12, 'kalan ' + fmt(qq['m5.kalan2'])) : cell(s2))))),
          back && P.dataMode !== 'fixed' ? el('div', { class: 'kart' }, el('p', { class: 'etiket-gizli' }, 'Perde arkası: kovaryans yolunun çapraz terimleri (model gereği 0; bu sınıftaki örneklem değerleri)'), tableOf(['Terim', 'Bu sınıfta'], [['s²_T', fmt(qq['gizli.m5.sT2'])], ['s_TE₂', fmt(qq['gizli.m5.sTE2'])], ['s_E₁T', fmt(qq['gizli.m5.sE1T'])], ['s_E₁E₂', fmt(qq['gizli.m5.sE1E2'])], ['Toplam = s₁₂', fmt(qq['gizli.m5.sT2'] + qq['gizli.m5.sTE2'] + qq['gizli.m5.sE1T'] + qq['gizli.m5.sE1E2'])]])) : null,
          STATIC ? null : button(filled ? 'Köşegeni geri al' : 'Köşegeni doldur', () => { filled = !filled; update(); }),
          filled ? el('p', null, 'Kalanların ortalaması ', el('b', null, fmt((qq['m5.kalan1'] + qq['m5.kalan2']) / 2)), ' = fark yolundaki s²_D/2. Fark yolu ile köşegen yolu aynı sayıyı verir.') : null);
        conv.innerHTML = '';
        if (P.dataMode === 'fixed') put(conv, el('p', { class: 'not' }, 'Yakınsamayı görmek için "Simülasyon sınıfı" verisine geç.'));
        else {
          const ests = []; for (let s = 0; s < 100; s++) { const st = coreState(); st.seed = S.seed + s; ests.push(C.derive(st)['m5.r']); }
          const W2 = 360, H2 = 90, xx = scale(0, 1, 20, 340); const svg2 = sv('svg', { viewBox: `0 0 ${W2} ${H2}`, role: 'img', 'aria-label': '100 sınıftan güvenirlik kestirimleri' });
          svg2.append(sv('line', { class: 'eksen', x1: 20, y1: 60, x2: 340, y2: 60, stroke: 'var(--cizgi)' })); [0, .25, .5, .75, 1].forEach(v => svg2.append(sv('text', { x: xx(v), y: 78, 'text-anchor': 'middle' }, fmt(v, 2))));
          ests.forEach((e, i) => svg2.append(sv('circle', { cx: xx(Math.max(0, Math.min(1, e))), cy: 50 - (i % 8) * 5, r: 2.4, fill: 'var(--rol-X)', 'fill-opacity': .6 })));
          if (back) { const rho = qq['gizli.m5.rho']; svg2.append(sv('line', { x1: xx(rho), y1: 6, x2: xx(rho), y2: 62, stroke: 'var(--rol-T)', 'stroke-width': 2, 'data-role': 'T' })); }
          put(conv, el('div', { class: 'grafik' }, svg2), el('p', { class: 'not' }, 'n = ' + P.n + ' ile 100 sınıftan r kestirimleri. Küçük sınıflar kararsız güvenirlik kestirimleri verir.' + (back ? ' Mavi çizgi: evren değeri (perde arkası).' : '')));
        }
        band.innerHTML = '';
        if (back) { const semv = Math.sqrt(qq['m5.ort_var']) * Math.sqrt(1 - qq['m5.r']); const cov = C.coverageSim(P.bandX, semv, semv, 1000, S.seed); put(band, el('p', { class: 'etiket-gizli' }, 'Perde arkası: bu öğrenci 1000 kez ölçülünce bantların gerçek puanı kapsama oranı %' + fmt(100 * cov, 1))); }
        if (S.expert) {
          put(band, el('h4', null, 'Uzman: binom hata modeli (k = 20, ÖSH = 2, bant ±3,92)'), tableOf(['Gerçek oran ζ', 'Kapsama'], [0.05, 0.25, 0.5, 0.75, 0.95].map(z => [fmt(z, 2), '%' + fmt(100 * C.binomialCoverage(20, z, 2), 1)])), el('p', { class: 'not' }, 'Kapsama puan düzeyine göre %95\'ten görünür biçimde ayrılır. Lord kestiricisi gözlenen 0 ve k puanında 0 verir; bu, tam puan alan öğrencinin hatasız ölçüldüğü anlamına gelmez (tavan etkisi).'));
          put(band, el('h4', null, 'Uzman: Kelley kestirimi (Sabit Veri A, X = 18)'), el('p', null, 'T̂ = 0,8 × 18 + 0,2 × 12 = ' + fmt(C.kelley(18, .8, 12)) + '; bant [' + C.band(C.kelley(18, .8, 12), C.seEstimate(Math.sqrt(20), .8)).map(v => fmt(v)).join('; ') + ']. Kelley aralığı grubun ortalamasına doğru çeker ve başvuru grubuna bağlıdır.'));
        }
      },
    };
  };

  BUILDERS.m6 = function (root) {
    const P = S.params.m6, back = S.view === 'backstage', mod = K.modules[5];
    const choice = S.m6choice || 'zaman';
    const cols = { zaman: 'tekrar', form: 'esdeger', ikisi: 'gecikmeli' };
    const roleTable = el('div');
    const draw = () => {
      roleTable.innerHTML = '';
      const col = cols[S.m6choice || 'zaman'];
      put(roleTable, tableOf(['Kaynak', 'Seçilen tasarımda', 'Tek oturum α\'da'], Object.values(K.sourceRoles).map(r => [r.ad, el('span', { class: r[col] === 'hata' ? 'hata' : 'gercek' }, r[col] === 'hata' ? 'hata' : 'gerçek puan'), el('span', null, r.alfa === 'hata' ? 'hata' : 'gerçek puan')]), { textCols: [1, 2] }));
    };
    const pick = el('div', { class: 'anahtar', role: 'group', 'aria-label': 'İki ölçme arasında ne değişiyor?' }, [['zaman', 'Zaman (test-tekrar test)'], ['form', 'Form (eşdeğer formlar)'], ['ikisi', 'İkisi (gecikmeli eşdeğer)']].map(([k, l]) => el('button', { type: 'button', 'aria-pressed': choice === k ? 'true' : 'false', onclick: () => { S.m6choice = k; renderModule(); } }, l)));
    const bars = el('div');
    put(root, el('div', { class: 'izgara' },
      el('div', { class: 'panel' }, el('h3', null, 'Neyi tekrarlıyoruz?'), pick, roleTable, STATIC ? null : slider({ key: 'k', label: 'Formdaki madde sayısı k', min: 2, max: 40, step: 1, d: 0, hint: 'Madde sayısı arttıkça maddeye özgü sapmalar ortalamada küçülür; nedenini M7\'de göreceksin.' }),
        STATIC ? null : check('Bellek etkisi (öğrenciler ilk yanıtlarını hatırlıyor)', () => (P.memory || 0) > 0, v => { P.memory = v ? 0.5 : 0; }, 'bellek6'),
        STATIC ? null : check('Farklı öğrenme (iki gün arasında kişiden kişiye değişen kazanç)', () => (P.learning || 0) > 0, v => { P.learning = v ? 0.5 : 0; }, 'ogrenme6')),
      el('div', { class: 'panel' }, el('h3', null, 'Aynı veri, dört yöntem'), bars, el('p', { class: 'not' }, 'α sütununu M7\'de elle hesaplayacaksın.'))));
    if (S.expert && !STATIC) put(root, el('details', { class: 'uzman-blok', open: true }, el('summary', null, 'Uzman: varyans kaynakları'), el('div', { class: 'denetimler' }, slider({ key: 'sp', label: 'Kişi σ²_p', min: 0.2, max: 2, step: 0.1, d: 1 }), slider({ key: 'spo', label: 'Kişi × gün σ²_po', min: 0, max: 1, step: 0.05, d: 2 }), slider({ key: 'spi', label: 'Kişi × madde σ²_pi', min: 0, max: 2, step: 0.1, d: 1 }), slider({ key: 'se', label: 'Artık σ²_e', min: 0.1, max: 2, step: 0.1, d: 1 }))));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Yöntem kartları'), el('div', { class: 'formuller' }, mod.yontemler.map(y => el('div', { class: 'kart' }, el('h4', null, y.ad), el('p', null, el('b', null, 'Veri tasarımı: '), y.veri), el('p', null, el('b', null, 'Hesap: '), y.hesap), el('p', null, el('b', null, 'Hata sayılan kaynaklar: '), y.hata), el('p', null, el('b', null, 'Varsayım: '), y.varsayim), el('p', null, el('b', null, 'Tipik tuzak: '), y.tuzak))))));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller (uzman katmanı)'), formulas(mod.formuller, back ? { 'm6.rho_tekrar': N('= {m6.tekrar} (kuramsal hedef; bellek ve öğrenme varken beklenen r = {m6.tekrar_gozlenen})'), 'm6.rho_esdeger': N('= {m6.esdeger}'), 'm6.rho_gecikmeli_esdeger': N('= {m6.gecikmeli} (bozucularla beklenen r = {m6.gecikmeli_gozlenen})') } : null)));
    return {
      update(q) {
        draw(); bars.innerHTML = '';
        const rows = [['Test-tekrar test', 'm6.tekrar', 'm6.s_tekrar'], ['Eşdeğer formlar', 'm6.esdeger', 'm6.s_esdeger'], ['Gecikmeli eşdeğer formlar', 'm6.gecikmeli', 'm6.s_gecikmeli'], ['Tek oturum α', 'm6.alfa', 'm6.s_alfa']];
        put(bars, back ? tableOf(['Yöntem', 'Bu sınıfta (400 kişi)', 'Kuramsal hedef (perde arkası)'], rows.map(([ad, key, sk]) => [ad, qspan(sk), qspan(key)])) : tableOf(['Yöntem', 'Bu sınıfta (400 kişi)'], rows.map(([ad, , sk]) => [ad, qspan(sk)])));
      },
    };
  };

  BUILDERS.m7 = function (root) {
    const P = S.params.m7, mod = K.modules[6];
    const tabs = el('div', { class: 'anahtar', role: 'tablist', 'aria-label': 'Hesap Tezgâhı sekmeleri' }, [['r', 'r (test-tekrar test / eşdeğer formlar)'], ['bolme', 'Yarıya bölme'], ['alpha', 'α ve KR-20']].map(([k, l]) => el('button', { type: 'button', role: 'tab', 'aria-selected': S.m7tab === k ? 'true' : 'false', 'aria-pressed': S.m7tab === k ? 'true' : 'false', onclick: () => { S.m7tab = k; renderModule(); } }, l)));
    const body = el('div', { class: 'bolum' });
    put(root, tabs, body);
    const rounds = STATIC ? null : el('div', { class: 'satir' }, el('span', null, 'Çözümlü örnek turu:'), [1, 2, 3, 4].map(r => el('button', { type: 'button', class: 'dugme', 'aria-pressed': S.m7round === r ? 'true' : 'false', onclick: () => { S.m7round = r; renderModule(); } }, r + '. tur')));
    if (S.m7tab === 'r') {
      const data = S.m7round === 1 ? [C.FIXTURES.M5.x1, C.FIXTURES.M5.x2] : C.genRData(S.seed * 10 + S.m7round);
      const [x1, x2] = data, t = C.twoForms(x1, x2), d1 = C.deviations(x1), d2 = C.deviations(x2), hideMid = S.m7round >= 3, hideAll = S.m7round === 4;
      const inputCell = (id, v) => el('input', { type: 'text', inputmode: 'decimal', id, 'aria-label': id, 'data-cevap': v });
      const rows = x1.map((v, i) => [ 'P' + (i + 1), v, x2[i], hideAll ? '' : fmt(d1[i], 0), hideAll ? '' : fmt(d2[i], 0), hideMid ? '' : fmt(d1[i] ** 2, 0), hideMid ? '' : fmt(d2[i] ** 2, 0), hideMid ? '' : fmt(d1[i] * d2[i], 0)]);
      rows.push({ cls: 'toplam', cells: ['Toplam', C.sum(x1), C.sum(x2), '0', '0', hideMid ? inputCell('Σx₁²', t.sumSq1) : fmt(t.sumSq1, 0), hideMid ? inputCell('Σx₂²', t.sumSq2) : fmt(t.sumSq2, 0), hideMid ? inputCell('Σx₁x₂', t.sumCross) : fmt(t.sumCross, 0)] });
      const rin = inputCell('r', t.r), fb = el('p', { 'aria-live': 'polite' });
      put(body, rounds, el('p', null, S.m7round === 1 ? 'Tur 1: M5 verisi, tamamen çözülmüş. Soru: neden bazı çarpımlar negatif? (Bir öğrenci bir testte ortalamanın üstünde, ötekinde altındaysa sapmaların işaretleri farklıdır.)' : 'Tur ' + S.m7round + ': tohumlu yeni veri. Boş hücreleri doldur ve r\'yi hesapla.'),
        tableOf(['Öğrenci', 'X₁', 'X₂', 'x₁', 'x₂', 'x₁²', 'x₂²', 'x₁x₂'], rows),
        S.m7round === 1 ? el('p', null, 'r = 68 / √(70 × 74) = ', el('b', null, fmt(t.r, 3))) : el('div', { class: 'satir' }, el('label', { for: 'r' }, 'r = '), rin, button('Kontrol et', () => {
          const inputs = [...body.querySelectorAll('input[data-cevap]')]; let allOk = true;
          inputs.forEach(inp => { const v = parseFloat(inp.value.replace(',', '.')), ok = Math.abs(v - Number(inp.dataset.cevap)) < 0.006; inp.parentElement.className = 'n ' + (ok ? 'hucre-dogru' : 'hucre-yanlis'); if (!ok) allOk = false; });
          const v = parseFloat(rin.value.replace(',', '.')), code = C.diagnoseR(x1, x2, v);
          const msg = { dogru: 'Doğru.', ham_puan: 'Sapma yerine ham puanlarla hesaplamışsın. Önce her puandan ortalamayı çıkar.', kok_unutuldu: 'Paydadaki karekökü unutmuş olabilirsin.', toplamlarin_carpimi: 'Çarpımların toplamı yerine toplamların çarpımını almışsın; sapmaların toplamı her zaman 0\'dır.', bilinmiyor: 'Sonuç beklenen değerle uyuşmuyor; sütun toplamlarını kontrol et.' }[code];
          fb.textContent = msg + (allOk ? '' : ' İşaretli hücreleri gözden geçir.') + ' Bu r ancak formlar paralelse güvenirliktir (Y14).';
          logEvent('m7_cevap', { module: 'm7', param: 'r', value: v, new: code });
        })), fb,
        formulas(['m7.r_sapma']));
    } else if (S.m7tab === 'bolme') {
      const data = P.splitK === 6 ? C.genSixItem(S.seed) : C.FIXTURES.A, k = data[0].length;
      const A = P.splitA.filter(i => i < k), B = [...Array(k).keys()].filter(i => !A.includes(i));
      const chips = el('div', { class: 'satir' }, [...Array(k).keys()].map(i => STATIC ? el('span', { class: 'terim' }, 'Madde ' + (i + 1) + ': ' + (A.includes(i) ? 'A' : 'B')) : el('button', { type: 'button', class: 'terim', 'aria-pressed': A.includes(i) ? 'true' : 'false', onclick: () => { P.splitA = A.includes(i) ? A.filter(x => x !== i) : A.concat(i).sort(); renderModule(); } }, 'Madde ' + (i + 1) + ': ' + (A.includes(i) ? 'A' : 'B'))));
      const sum = C.splitSummary(data), st = A.length && B.length ? C.splitStats(data, A, B, S.denom) : null;
      const W = 600, H = 110, x = scale(0, 1, 20, 580), svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Bütün bölmelerin Flanagan-Rulon değerleri' });
      svg.append(sv('line', { class: 'eksen', x1: 20, y1: 70, x2: 580, y2: 70, stroke: 'var(--cizgi)' })); [0, .2, .4, .6, .8, 1].forEach(v => svg.append(sv('text', { x: x(v), y: 88, 'text-anchor': 'middle' }, fmt(v, 1))));
      sum.splits.forEach((s, i) => svg.append(sv('circle', { cx: x(Math.max(0, Math.min(1, s.flanaganRulon))), cy: 60 - (i % 5) * 9, r: 5, fill: 'var(--rol-X)', 'fill-opacity': .55 })));
      if (k % 2 === 0) svg.append(sv('line', { x1: x(sum.meanFR), y1: 8, x2: x(sum.meanFR), y2: 72, stroke: 'var(--vurgu)', 'stroke-width': 2 }), sv('text', { x: x(sum.meanFR) + 4, y: 16 }, 'ortalama = α = ' + fmt(sum.alpha)));
      put(body, el('p', null, (P.splitK === 6 ? '10 kişi, 6 madde (tohumlu üretici). ' : 'Sabit Veri A, 4 madde. ') + 'Maddeleri A veya B yarısına koy.'), STATIC ? null : el('div', { class: 'satir' }, button('4 madde (Sabit Veri A)', () => { P.splitK = 4; P.splitA = [0, 2]; renderModule(); }), button('6 madde', () => { P.splitK = 6; P.splitA = [0, 2, 4]; renderModule(); })), chips,
        st ? el('div', { class: 'gostergeler' }, gostergeStatic('r_hh', st.rhh), gostergeStatic('Spearman-Brown', st.sb), gostergeStatic('Flanagan-Rulon', st.flanaganRulon), gostergeStatic('Rulon', st.rulon)) : el('p', { class: 'bayrak' }, 'İki yarıda da en az bir madde olmalı.'),
        el('div', { class: 'grafik' }, svg), el('p', { class: 'not' }, sum.count + ' bölme. Farklı bölmeler farklı sonuç verir; tek-çift bölme yalnızca bir bölmedir. ' + (k % 2 === 0 ? 'k çiftken tüm eşit bölmelerin Flanagan-Rulon ortalaması α\'ya eşittir (' + fmt(sum.meanFR) + '); Spearman-Brown ortalaması (' + fmt(sum.meanSB) + ') eşit değildir.' : 'k tek olduğu için "ortalama = α" işareti gizlendi: bu durumda ortalama α(k² − 1)/k²\'dir.')),
        el('h4', null, 'Test uzunluğu'), STATIC ? null : slider({ key: 'lengthRho', label: 'Başlangıç güvenirliği ρ', min: 0.1, max: 0.95, step: 0.05, d: 2 }), STATIC ? null : slider({ key: 'lengthM', label: 'Uzunluk çarpanı m', min: 0.5, max: 6, step: 0.5, d: 1 }), el('p', null, 'Spearman-Brown ρ_m = ', qspan('m7.sb'), ' (eklenen parçalar paralelse). Uzatmanın getirisi azalır.'),
        formulas(['m7.sb_yarilar', 'm7.flanagan_rulon', 'm7.rulon', 'm7.sb']));
    } else {
      const data = P.dataset === 'B' ? C.FIXTURES.B : P.dataset === 'A5' ? C.fixtureA5() : S.m7round > 1 ? C.genAlphaData(S.seed * 10 + S.m7round) : C.FIXTURES.A;
      const k = data[0].length, cols = C.columns(data), y = C.rowSums(data), iv = cols.map(c => C.variance(c, S.denom)), tv = C.variance(y, S.denom), a = C.alphaVariance(data, S.denom);
      const kr = P.dataset === 'B' ? C.krStats(data, S.denom) : null, hideMid = S.m7round >= 3, hideAll = S.m7round >= 2;
      const inputCell = (id, v) => el('input', { type: 'text', inputmode: 'decimal', id: 'a-' + id, 'aria-label': id, 'data-cevap': v });
      const rows = data.map((r, i) => ['P' + (i + 1)].concat(r.map(String), [String(y[i])]));
      rows.push({ cls: 'toplam', cells: ['Ortalama'].concat(cols.map(c => fmt(C.mean(c))), [fmt(C.mean(y))]) });
      if (kr) rows.push({ cls: 'toplam', cells: ['p_i q_i' + (S.denom === 'n' ? '' : ' · n/(n−1)')].concat(kr.itemVarShown.map(v => hideMid ? '' : fmt(v, 4)), ['']) });
      else rows.push({ cls: 'toplam', cells: ['Varyans (' + (S.denom === 'n' ? 'n' : 'n − 1') + ')'].concat(iv.map(v => hideMid ? '' : fmt(v)), [hideMid ? inputCell('s²_Y', tv) : fmt(tv)]) });
      const sumIv = kr ? C.sum(kr.itemVarShown) : C.sum(iv), totShown = kr ? kr.totShown : tv, aShown = kr ? kr.kr20Shown : a;
      const ain = inputCell('alfa', aShown), fb = el('p', { 'aria-live': 'polite' });
      const dsel = STATIC ? null : el('div', { class: 'satir' }, el('span', null, 'Veri:'), [['A', 'Sabit Veri A (açık uçlu, 1-5)'], ['B', 'Sabit Veri B (0/1)'], ['A5', 'A + zayıf 5. madde']].map(([v, l]) => el('button', { type: 'button', class: 'dugme', 'aria-pressed': P.dataset === v ? 'true' : 'false', onclick: () => { P.dataset = v; renderModule(); } }, l)));
      put(body, dsel, P.dataset === 'A' ? rounds : null, tableOf(['Öğrenci'].concat(cols.map((_, i) => 'Madde ' + (i + 1)), ['Y']), rows),
        el('p', null, (kr ? 'Σ p_i q_i = ' : 'Σ s²_i = '), hideAll ? inputCell('Σ', sumIv) : el('b', null, fmt(sumIv, 4)), '; ', kr ? 'toplam varyans = ' : 's²_Y = ', hideMid && !kr ? '(tabloda)' : el('b', null, fmt(totShown, 4)), '; k = ' + k + '.'),
        S.m7round === 1 || P.dataset !== 'A' ? el('p', null, (kr ? 'KR-20' : 'α') + ' = ' + k + '/' + (k - 1) + ' × (1 − ' + fmt(sumIv, 4) + ' / ' + fmt(totShown, 4) + ') = ', el('b', null, fmt(aShown, 4)), kr && S.denom !== 'n' ? ' (n − 1 paydasında p_iq_i · n/(n−1) ve s²_Y; sonuç aynıdır)' : '') : el('div', { class: 'satir' }, el('label', { for: 'a-alfa' }, 'α = '), ain, button('Kontrol et', () => {
          [...body.querySelectorAll('input[data-cevap]')].forEach(inp => { const v = parseFloat(inp.value.replace(',', '.')); inp.parentElement.classList.toggle('hucre-dogru', Math.abs(v - Number(inp.dataset.cevap)) < 0.006); inp.parentElement.classList.toggle('hucre-yanlis', !(Math.abs(v - Number(inp.dataset.cevap)) < 0.006)); });
          const v = parseFloat(ain.value.replace(',', '.')), code = C.diagnoseAlpha(data, v);
          fb.textContent = { dogru: 'Doğru.', sd_kullanildi: 'Varyans yerine standart sapma kullanmışsın.', carpan_unutuldu: 'k/(k−1) çarpanını unutmuşsun.', karisik_payda: 'Madde varyanslarında n, toplam varyansta n − 1 kullanmışsın; aynı oranda payda tutarlı olmalı.', sb_uygulandi: 'Zaten tam uzunluktaki bir katsayıya Spearman-Brown uygulamışsın.', toplam_yerine_madde: 'Toplam puan varyansı yerine madde varyansları toplamını kullanmışsın.', bilinmiyor: 'Sonuç beklenen değerle uyuşmuyor; varyansları kontrol et.' }[code];
          logEvent('m7_cevap', { module: 'm7', param: 'alfa', value: v, new: code });
        })), fb,
        P.dataset === 'A5' ? el('p', { class: 'kart' }, 'Zayıf madde: 5. madde ilk dört maddenin toplamıyla ilişkisiz (kovaryans 0). Beş maddeyle α = ' + fmt(a) + '; 5. madde silinince 0,80\'e döner.') : null,
        el('h4', null, 'Madde analizi'), tableOf(['Madde', 'Madde silinirse α', '', 'Düzeltilmiş madde-toplam r'], C.itemAnalysis(data).map(r => ['Madde ' + (r.item + 1), fmt(r.alphaIfDeleted, 4), r.direction, fmt(r.correctedR, 3)]), { textCols: [2] }),
        P.dataset === 'A' ? el('p', { class: 'not' }, '4. madde silinince α 0,8015\'e çıkar; n = 6\'da bu fark örnekleme hatasının çok altındadır.') : null,
        kr ? pqPanel(kr) : null,
        S.expert ? el('p', { class: 'not' }, 'Madde güçlüğü notu: "p = 0,5" evrensel bir kural değildir; çoktan seçmeli maddelerde en uygun ortalama güçlük, şans düzeyi ile %100\'ün ortasından biraz daha kolay taraftadır (Lord, 1952). Bu seçim, yetenek aralığının farklı bölgelerindeki ölçme kesinliğiyle bir ödünleşim içerir.') : null,
        S.expert ? el('p', { class: 'not' }, 'Aynı etki popülasyon modunda: λ = 0,9, 0,8, 0,3, 0,2 iken λ = 0,2 maddesi silinince α ' + fmt(C.factorModel([.9, .8, .3, .2]).alpha, 4) + '\'ten ' + fmt(C.factorModel([.9, .8, .3]).alpha, 4) + '\'e, ω ' + fmt(C.factorModel([.9, .8, .3, .2]).omega, 4) + '\'ten ' + fmt(C.factorModel([.9, .8, .3]).omega, 4) + '\'e çıkar.') : null,
        S.expert && kr ? el('p', null, 'KR-21 = ' + fmt(kr.kr21, 4) + ' ≤ KR-20 (eşit madde güçlüğü varsayar). Payda karışımı yanlış olarak ' + fmt(kr.mixed, 4) + ' verir.') : null,
        STATIC ? null : pasteBox(),
        formulas(kr ? ['m7.kr20', 'm7.toplam_varyans_n'] : ['m7.alpha', 'm7.osh_orneklem'], { 'm7.alpha': N('α̂ = {m7.alfa}'), 'm7.osh_orneklem': N('ÖSH = {m7.osh}') }));
    }
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Görülmesi gereken'), el('ul', { class: 'duz gorulmesi' }, mod.gorulmesi.map(g => el('li', { 'data-iddia': g.c }, g.t)))));
    return { update() {} };
  };
  function pqPanel(kr) {
    const W = 360, H = 170, pad = { l: 40, r: 12, t: 10, b: 34 }, x = scale(0, 1, pad.l, W - pad.r), y = scale(0, 0.25, H - pad.b, pad.t);
    const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Madde güçlüğüne göre madde varyansı p(1 − p)' }), g = sv('g'); svg.append(g);
    axes(g, x, y, W, H, pad, [], [], 'Madde güçlüğü p', 'p(1 − p)');
    [0, .25, .5, .75, 1].forEach(v => g.append(sv('text', { x: x(v), y: H - pad.b + 16, 'text-anchor': 'middle' }, fmt(v, 2))));
    [0, .125, .25].forEach(v => g.append(sv('text', { x: pad.l - 6, y: y(v) + 4, 'text-anchor': 'end' }, fmt(v, 3))));
    let d = ''; for (let i = 0; i <= 50; i++) { const p = i / 50; d += (i ? 'L' : 'M') + x(p) + ',' + y(p * (1 - p)); }
    g.append(sv('path', { d, fill: 'none', stroke: 'var(--rol-X)', 'stroke-width': 1.6 }));
    kr.p.forEach((p, i) => g.append(sv('circle', { cx: x(p), cy: y(p * (1 - p)), r: 5, fill: 'var(--rol-madde)' }), sv('text', { x: x(p) + 6, y: y(p * (1 - p)) - 6 }, 'M' + (i + 1))));
    return el('div', { class: 'panel' }, el('h4', null, 'Madde güçlüğü ve madde varyansı'), el('div', { class: 'grafik' }, svg), el('p', { class: 'not' }, 'Doğru-yanlış maddenin varyansı p(1 − p)\'dir ve p = 0,5\'te en büyüktür.'));
  }
  function gostergeStatic(ad, v) { return el('div', { class: 'gosterge' }, el('span', { class: 'ad' }, ad), el('span', { class: 'deger' }, fmt(v))); }
  function pasteBox() {
    const ta = el('textarea', { id: 'yapistir', rows: 4, style: 'width:100%', 'aria-label': 'Sekmeyle ayrılmış veri' }), out = el('div', { 'aria-live': 'polite' });
    return el('details', { class: 'kontrol' }, el('summary', null, 'Kendi verini yapıştır'), el('p', { class: 'not' }, 'Satırlar kişi, sütunlar madde; sekme veya boşlukla ayır (en fazla 50 × 20). Veriler tarayıcından çıkmaz.'), ta, button('Hesapla', () => {
      let rows = ta.value.trim().split(/\n+/).map(l => l.trim().split(/[\t;]+|\s+/).map(v => parseFloat(v.replace(',', '.'))));
      const k = Math.max(...rows.map(r => r.length)); const before = rows.length; rows = rows.filter(r => r.length === k && r.every(Number.isFinite)).slice(0, 50).map(r => r.slice(0, 20));
      out.innerHTML = '';
      if (rows.length < 3 || k < 2) { out.textContent = 'En az 3 kişi ve 2 madde gerekir.'; return; }
      put(out, el('p', null, 'Çıkarılan eksik satır: ' + (before - rows.length) + '. α = ' + fmt(C.alphaVariance(rows, S.denom), 4) + '; Hoyt = ' + fmt(C.alphaAnova(rows), 4) + '; L₂ = ' + fmt(C.guttman(rows).L2, 4) + '.'));
    }), out);
  }

  BUILDERS.m8 = function (root) {
    const P = S.params.m8, back = S.view === 'backstage', mod = K.modules[7];
    const heat = el('div'), pair = el('div');
    const presets = STATIC ? null : el('div', { class: 'satir', role: 'group', 'aria-label': 'Ön ayar modeller' }, [['tau', 'Tau eşdeğer'], ['konjenerik', 'Konjenerik'], ['iliskili', 'İlişkili hata (madde demeti)'], ['bloklar', 'İki blok']].map(([k, l]) => el('button', { type: 'button', class: 'dugme', 'aria-pressed': P.preset === k ? 'true' : 'false', onclick: () => { applyPreset('m8.' + k); } }, l)));
    const ctr = STATIC ? null : P.preset === 'bloklar' ? el('div', { class: 'denetimler' }, slider({ key: 'rf', label: 'Faktörler arası korelasyon', min: 0, max: 1, step: 0.05, d: 2 }), el('div', { class: 'satir' }, button('6 madde', () => { P.blocksK = 6; update(); }), button('12 madde', () => { P.blocksK = 12; update(); })))
      : el('div', { class: 'denetimler' }, P.lambda ? null : slider({ key: 'meanLambda', label: 'Ortalama yük', min: 0.2, max: 0.9, step: 0.025, d: 3 }), P.lambda ? null : slider({ key: 'spread', label: 'Yük yayılımı', min: 0, max: 0.4, step: 0.05, d: 2 }), P.lambda ? null : slider({ key: 'k', label: 'Madde sayısı k', min: 3, max: 8, step: 1, d: 0, locked: !S.expert }),
        S.expert && P.lambda ? el('div', null, P.lambda.map((l, i) => slider({ key: 'lam' + i, label: 'λ' + (i + 1), min: 0.05, max: 0.95, step: 0.05, d: 2, get: () => P.lambda[i], set: v => { P.lambda[i] = v; } }))) : null,
        button(S.fillDiag ? 'Köşegeni geri al' : 'Köşegeni doldur', () => { S.fillDiag = !S.fillDiag; renderModule(); }));
    put(root, presets, el('div', { class: 'izgara' }, el('div', { class: 'panel' }, el('h3', null, 'Kovaryans matrisi Σ (popülasyon modu)'), heat, pair),
      el('div', { class: 'panel' }, ctr, el('div', { class: 'gostergeler' }, gosterge('α', 'm8.alfa', { d: 4 }), P.preset === 'bloklar' ? gosterge('1ᵀΣ_T1 / 1ᵀΣ1', 'm8.oran_gercek', { d: 4 }) : gosterge('ω', 'm8.omega', { d: 4 }), P.preset === 'bloklar' ? null : gosterge('L₂', 'm8.L2', { d: 4 }), gosterge('İz tr Σ', 'm8.iz'), gosterge('Köşegen dışı toplam', 'm8.kosegen_disi'), gosterge('1ᵀΣ1', 'm8.toplam'), gosterge('Ortalama kovaryans', 'm8.ort_kov', { d: 4 })))));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(mod.formuller, { 'm8.alpha': N('α = {m8.alfa}'), 'm8.toplam_varyans': N('{m8.toplam} = {m8.iz} + {m8.kosegen_disi}') })));
    return {
      update(q) {
        const d = C.derive(coreState()), Sg = d._matrix, k = Sg.length, ms = C.matrixSummary(Sg); heat.innerHTML = '';
        const cellPx = Math.min(56, Math.floor(360 / k)), W = k * cellPx + 40, H = k * cellPx + 30;
        const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'Kovaryans matrisi ısı haritası' });
        const mx = Math.max(...Sg.flat().map(Math.abs));
        for (let i = 0; i < k; i++) for (let j = 0; j < k; j++) {
          const v = Sg[i][j], diag = i === j, fillv = diag && S.fillDiag ? ms.meanOffDiag : v;
          const r = sv('rect', { x: 30 + j * cellPx, y: 20 + i * cellPx, width: cellPx - 2, height: cellPx - 2, fill: diag ? 'var(--rol-E)' : 'var(--rol-T)', 'fill-opacity': 0.15 + 0.7 * Math.abs(fillv) / mx, 'data-term': diag ? 't-kosegen' : 't-kosegen-disi', tabindex: STATIC ? null : 0, role: STATIC ? null : 'button', 'aria-label': `Hücre ${i + 1},${j + 1}: ${fmt(v)}` });
          if (!STATIC) { const open = () => showPair(i, j); r.addEventListener('click', open); r.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(); } }); }
          svg.append(r);
          if (cellPx >= 34) svg.append(sv('text', { x: 30 + j * cellPx + cellPx / 2 - 1, y: 20 + i * cellPx + cellPx / 2 + 4, 'text-anchor': 'middle', 'font-size': 11 }, fmt(diag && S.fillDiag ? ms.meanOffDiag : v)));
          if (diag && S.fillDiag && cellPx >= 34) svg.append(sv('text', { x: 30 + j * cellPx + cellPx / 2, y: 20 + i * cellPx + cellPx - 6, 'text-anchor': 'middle', 'font-size': 9, fill: ms.itemResiduals[i] < 0 ? 'var(--kotu)' : 'var(--rol-E)' }, 'kalan ' + fmt(ms.itemResiduals[i])));
        }
        put(heat, el('div', { class: 'grafik' }, svg), el('p', { class: 'not' }, 'Köşegen: ', el('span', { 'data-term': 't-kosegen' }, 'iz = ' + fmt(ms.trace)), '; köşegen dışı toplam ', el('span', { 'data-term': 't-kosegen-disi' }, fmt(ms.offDiag)), '. ', S.fillDiag ? 'Köşegeni doldur: her köşegen hücresi kestirilen gerçek kısım (ortalama köşegen dışı değer ' + fmt(ms.meanOffDiag) + ') ile hata kalanına bölündü. Bu, M5\'teki işlemin k(k − 1) çiftle yapılmış hâlidir.' : ''),
          ms.negativeResidual.some(Boolean) && S.fillDiag ? el('p', { class: 'bayrak' }, 'Bir madde için kalan negatif: örneklem dalgalanması ya da α\'nın varsayımının (özünde tau eşdeğerlik) bozulması.') : null,
          back ? el('p', { class: 'etiket-gizli' }, 'Perde arkası: 1ᵀΣ_T1 = ' + fmt(q['gizli.m8.SigmaT_toplam']) + '; gerçek puan payı ' + fmt(q['gizli.m8.SigmaT_toplam'] / q['m8.toplam'], 4)) : null);
      },
    };
    function showPair(i, j) {
      const Sg = C.derive(coreState())._matrix, dat = C.simulateFromSigma(Sg, 200, S.seed); pair.innerHTML = '';
      if (!dat) { put(pair, el('p', { class: 'bayrak' }, 'Matris pozitif tanımlı değil.')); return; }
      put(pair, el('h4', null, 'Madde ' + (i + 1) + ' ve madde ' + (j + 1) + ' (200 kişilik örnek)'), scatter(dat.map(r => r[j]), dat.map(r => r[i]), { aria: 'Madde çifti saçılımı', xlab: 'Madde ' + (j + 1), ylab: 'Madde ' + (i + 1), r: 2.4 }));
    }
  };

  BUILDERS.m9 = function (root) {
    const P = S.params.m9, mod = K.modules[8], A = C.FIXTURES.A, an = C.anova(A);
    const fac = P.facet === 'puanlayici' ? 'Puanlayıcı' : 'Madde', facl = P.facet === 'puanlayici' ? 'kompozisyon' : 'öğrenci';
    const layer = (title, f, cls) => el('div', { class: 'panel' }, el('h4', { 'data-term': cls }, title), tableOf([''].concat(A[0].map((_, i) => fac[0] + (i + 1))), A.map((r, p) => ['P' + (p + 1)].concat(r.map((_, i) => fmt(f(p, i)))))));
    const g = an.grand;
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Katman soyma (Sabit Veri A: 6 ' + facl + ' × 4 ' + fac.toLocaleLowerCase('tr-TR') + ')'),
      el('div', { class: 'formuller' }, layer('Genel ortalama', () => g, ''), layer('Kişi etkisi', p => an.personEffects[p], 't-kisi'), layer(fac + ' etkisi', (p, i) => an.itemEffects[i], 't-madde'), layer('Artık', (p, i) => A[p][i] - an.personMeans[p] - an.itemMeans[i] + g, 't-artik')),
      el('p', { class: 'not' }, 'Dört tabloyu hücre hücre topla: aslı çıkar. Her tablonun karelerini (M1) topla: KT.')));
    put(root, el('div', { class: 'izgara' }, el('div', { class: 'panel' }, el('h3', null, 'ANOVA tablosu'),
      tableOf(['Kaynak', 'KT', 'sd', 'KO'], [['Kişi (p)', qspan('m9.KTp'), '5', qspan('m9.KOp')], [fac + ' (' + (P.facet === 'puanlayici' ? 'r' : 'i') + ')', qspan('m9.KTi'), '3', qspan('m9.KOi')], ['Artık', qspan('m9.KTart'), '15', qspan('m9.KOart')], { cls: 'toplam', cells: ['Toplam', qspan('m9.KTT'), '23', ''] }]),
      el('p', { class: 'not' }, 'sd, M1\'deki serbestlik derecesi etkileşiminin aynısıdır. ANOVA nicelikleri sd ile tanımlıdır; payda anahtarından etkilenmez.'),
      el('div', { class: 'kart vurgu' }, el('h4', null, 'Hoyt = α'), el('p', null, 'Hoyt = 1 − ', qspan('m9.KOart'), ' / ', qspan('m9.KOp'), ' = ', el('b', null, qspan('m9.hoyt')), '. M7\'de aynı veriden α = 0,80 bulmuştun.'))),
      el('div', { class: 'panel' }, el('h3', null, 'Üç yol, tek hata varyansı'), el('p', null, 'Toplam puanın hata varyansı dört ayrı hesapla aynı sayıya varır; hepsinde ÖSH = 2. Bu, görmediğimiz hatayı nasıl kestirdiğimizin toplu yanıtıdır.'), el('div', { class: 'formuller' }, mod.ucYol.map(id => formulaCard(id))))));
    const curve = el('div');
    put(root, el('div', { class: 'izgara' }, el('div', { class: 'panel' }, el('h3', null, 'Bağıl ve mutlak karar: K çalışması'), curve,
      el('div', { class: 'gostergeler' }, gosterge('G katsayısı 𝔼ρ² (bağıl)', 'm9.erho2', { d: 4 }), gosterge('Φ (mutlak)', 'm9.phi', { d: 4 }), gosterge('σ̂²_p', 'm9.sp', { d: 4 }), gosterge('σ̂²_i', 'm9.si', { d: 4 }), gosterge('σ̂²_pi,e', 'm9.se', { d: 4 }))),
      el('div', { class: 'panel' }, STATIC ? null : slider({ key: 'nPrime', label: 'K çalışmasında ' + fac.toLocaleLowerCase('tr-TR') + ' sayısı n\'', min: 1, max: 20, step: 1, d: 0 }),
        STATIC ? null : el('div', { class: 'satir' }, el('div', { class: 'anahtar', role: 'group', 'aria-label': 'Yön' }, el('button', { type: 'button', 'aria-pressed': P.facet !== 'puanlayici' ? 'true' : 'false', onclick: () => { P.facet = 'madde'; P.design = 'crossed'; renderModule(); } }, 'Madde'), el('button', { type: 'button', 'aria-pressed': P.facet === 'puanlayici' ? 'true' : 'false', onclick: () => { P.facet = 'puanlayici'; renderModule(); } }, 'Puanlayıcı'))),
        P.facet === 'puanlayici' && !STATIC ? el('div', { class: 'anahtar', role: 'group', 'aria-label': 'K çalışması deseni' }, el('button', { type: 'button', 'aria-pressed': P.design !== 'nested' ? 'true' : 'false', onclick: () => { P.design = 'crossed'; renderModule(); } }, 'Çaprazlanmış p × r'), el('button', { type: 'button', 'aria-pressed': P.design === 'nested' ? 'true' : 'false', onclick: () => { P.design = 'nested'; renderModule(); } }, 'İç içe r:p')) : null,
        el('p', null, 'Madde (veya puanlayıcı) güçlük farkları her öğrenci için aynıdır; öğrencileri sıralarken sabit hata gibi davranır ve 𝔼ρ²\'ye girmez; sabit bir kesme puanında önemli olan Φ\'ye girer.'),
        P.design === 'nested' ? el('p', { class: 'kart' }, 'İç içe desende her kompozisyonu farklı puanlayıcılar okur: puanlayıcı katılık farkları bağıl hataya da girer ve 𝔼ρ² = Φ olur. Anahtar G çalışmasını değil K çalışması desenini değiştirir; bileşenler çaprazlanmış G çalışmasından gelir (σ²_r,pr,e = 7/6).') : null)));
    put(root, el('div', { class: 'bolum' }, el('h3', null, 'Formüller'), formulas(mod.formuller, { 'm9.hoyt': N('1 − {m9.KOart} / {m9.KOp} = {m9.hoyt}'), 'm9.erho2': N('= {m9.erho2}'), 'm9.phi': N('= {m9.phi}'), 'm9.kt_ayrisimi': N('{m9.KTT} = {m9.KTp} + {m9.KTi} + {m9.KTart}') })));
    return {
      update() {
        curve.innerHTML = '';
        const W = 420, H = 230, pad = { l: 44, r: 12, t: 12, b: 38 }, x = scale(1, 20, pad.l, W - pad.r), y = scale(0, 1, H - pad.b, pad.t);
        const svg = sv('svg', { viewBox: `0 0 ${W} ${H}`, role: 'img', 'aria-label': 'n\' sayısına göre G katsayısı ve Φ eğrileri' }); const gg = sv('g'); svg.append(gg);
        axes(gg, x, y, W, H, pad, [1, 5, 10, 15, 20], [0, .25, .5, .75, 1].map(v => v), 'n\'', '');
        [0, .25, .5, .75, 1].forEach(v => gg.append(sv('text', { x: pad.l - 6, y: y(v) + 4, 'text-anchor': 'end' }, fmt(v, 2))));
        const pts = f => { let d = ''; for (let n = 1; n <= 20; n++) { const gc = P.design === 'nested' ? C.dStudyRaters(an.comps, n, 'nested') : C.gCoefficients(an.comps, n); d += (n === 1 ? 'M' : 'L') + x(n) + ',' + y(gc[f]); } return d; };
        gg.append(sv('path', { d: pts('Erho2'), fill: 'none', stroke: 'var(--rol-T)', 'stroke-width': 2.2, 'data-term': 't-kisi' }), sv('path', { d: pts('Phi'), fill: 'none', stroke: 'var(--rol-E)', 'stroke-width': 2.2, 'stroke-dasharray': '6 3', 'data-term': 't-madde' }));
        gg.append(sv('line', { x1: x(P.nPrime), y1: pad.t, x2: x(P.nPrime), y2: H - pad.b, stroke: 'var(--soluk)', 'stroke-dasharray': '2 3' }));
        put(curve, el('div', { class: 'grafik' }, svg), el('div', { class: 'lejant' }, el('span', null, 'Düz: 𝔼ρ² (Spearman-Brown eğrisinin aynısı)'), el('span', null, 'Kesikli: Φ')));
      },
    };
  };

  BUILDERS.m10 = function (root) {
    const items = K.misconceptions;
    put(root, el('div', { class: 'bolum' }, items.map((it, idx) => {
      const order = (C.fnv1a('m10|' + it.id) % 2) === 0, opts = order ? [['dogru', it.dogru], ['yanlis', it.yanlis]] : [['yanlis', it.yanlis], ['dogru', it.dogru]];
      const fb = el('p', { 'aria-live': 'polite' });
      const fs = el('fieldset', { class: 'tga' }, el('legend', null, (idx + 1) + '. Hangisi doğru?'), opts.map(([v, t]) => { const inp = el('input', { type: 'radio', name: 'm10-' + it.id, id: 'm10-' + it.id + '-' + v, value: v }); if (S.m10[it.id] === v) inp.checked = true; inp.addEventListener('change', () => { S.m10[it.id] = v; store('m10', S.m10); show(); logEvent('m10', { module: 'm10', param: it.id, value: v }); }); return el('label', { class: 'onay', for: 'm10-' + it.id + '-' + v }, inp, t); }), fb);
      function show() { const v = S.m10[it.id]; if (!v) return; fb.innerHTML = ''; fb.append(el('span', { class: v === 'dogru' ? 'dogru' : 'yanlis' }, v === 'dogru' ? 'Doğru. ' : 'Bu bir yanılgı (' + it.id + '). '), 'Doğru ifade: ' + it.dogru + ' ', el('a', { href: '#' + it.modul, onclick: e => { e.preventDefault(); go(it.modul); } }, 'İlgili modüle git')); }
      show(); return fs;
    })));
    return { update() {} };
  };

  // ---------------------------------------------------------------------------
  // Sayfalar
  // ---------------------------------------------------------------------------
  function renderModule() {
    const main = document.getElementById('modul'); main.innerHTML = '';
    const mod = K.modules.find(m => m.id === S.module);
    document.querySelectorAll('.nav button').forEach(b => b.setAttribute('aria-current', b.dataset.go === (S.page === 'modul' ? S.module : S.page) ? 'page' : 'false'));
    if (S.page !== 'modul') { renderPage(main); document.getElementById('butce').hidden = true; current = null; return; }
    syncStrip();
    put(main, el('header', { class: 'baslik-blok' }, el('div', { class: 'ust-etiket' }, mod.id.toUpperCase() + ' · yaklaşık ' + mod.dakika + ' dakika'), el('h2', null, mod.baslik), el('ul', { class: 'kazanim' }, mod.kazanimlar.map(k => el('li', null, k))), el('p', { class: 'giris' }, mod.giris)));
    put(main, el('div', { class: 'ne-degisti', id: 'ne-degisti', 'aria-live': 'off' }, S.module === 'm10' ? 'Yanılgı denetimi: her ifadeyi değerlendir.' : 'Bir denetimi değiştir; burada ne değiştiğini ve nedenini göreceksin.'));
    const box = el('div', { class: 'bolum' }); put(main, box);
    current = BUILDERS[S.module](box);
    const tgas = K.tga.filter(t => t.module === S.module && (!t.uzman || S.expert));
    if (tgas.length && SHOW_TGA) put(main, el('div', { class: 'bolum' }, el('h3', null, 'Tahmin et, gözle, açıkla'), tgas.map(tgaCard)));
    if (['m2', 'm3', 'm4'].includes(S.module)) put(main, el('div', { class: 'kart' }, el('p', null, el('b', null, 'TGA: '), K.ui.perdeTGA)));
    if (mod.gorulmesi && mod.gorulmesi.length && S.module !== 'm7') put(main, el('div', { class: 'bolum' }, el('h3', null, K.ui.gorulmesi), el('ul', { class: 'duz gorulmesi' }, mod.gorulmesi.map(g => el('li', { 'data-iddia': g.c }, g.t)))));
    if (mod.uzmanFormuller && S.expert) put(main, el('details', { class: 'uzman-blok', open: true }, el('summary', null, K.ui.uzman + ': ek formüller'), formulas(mod.uzmanFormuller)));
    else if (mod.uzmanFormuller) put(main, el('p', { class: 'not' }, 'Uzman katmanı ' + mod.uzmanFormuller.length + ' ek formül içeriyor. Üst şeritten "Uzman modu"nu aç.'));
    if (mod.kontrol && mod.kontrol.length) put(main, controlQs(mod.kontrol));
    update();
  }
  function renderPage(main) {
    if (S.page === 'etki') {
      put(main, el('h2', null, K.ui.etkiHaritasi), el('p', null, 'Her satır bir değişikliktir; diğer her şey sabittir (popülasyon düzeyinde). Bir hücre, ilgili TGA kartını bitirince dolar. "~" koşula bağlı demektir.'));
      const rows = K.effectMap.satirlar.map(r => {
        const f = STATIC ? { tahmin: null, sonuc: null, tam: true } : S.effect[r.id];
        const cells = r.hucre.map(h => f ? el('td', { class: 'dolu' }, h) : el('td', { class: 'bos' }, '?'));
        const pred = f && !f.tam ? el('td', { 'data-satir': r.id }, 'Tahminin: ' + (f.tahmin ? K.ui.yonler[f.tahmin] : '–') + ' / Sonuç: ' + K.ui.yonler[f.sonuc]) : el('td', { class: 'bos' }, f ? 'tam tablo' : 'TGA bekliyor');
        return el('tr', { 'data-satir': r.id }, el('th', { scope: 'row' }, r.id + ' ' + r.ad), cells, pred, el('td', null, el('a', { href: '#' + r.modul, onclick: e => { e.preventDefault(); go(r.modul); } }, r.modul.toUpperCase())));
      });
      put(main, el('div', { class: 'tablo-kutu' }, el('table', { class: 'tablo etki' }, el('thead', null, el('tr', null, el('th', null, 'Değişiklik'), K.effectMap.sutunlar.map(s => el('th', null, s)), el('th', null, 'TGA'), el('th', null, 'Modül'))), el('tbody', null, rows))));
    } else if (S.page === 'sozluk') {
      put(main, el('h2', null, K.ui.sozluk), tableOf(['Terim', 'İngilizcesi', 'Açıklama'], K.glossary, { textCols: [1, 2] }));
    } else if (S.page === 'kaynaklar') {
      put(main, el('h2', null, K.ui.kaynaklar), el('p', { class: 'not' }, K.ui.kaynakNotu), el('ul', { class: 'duz' }, K.references.map(r => el('li', null, r))));
    } else if (S.page === 'hakkinda') {
      put(main, el('h2', null, 'Bu laboratuvar hakkında'), el('p', null, 'Bu sayfa, Eğitimde Ölçme ve Değerlendirme dersi alan ve istatistik altyapısı olmayan öğrenciler için Klasik Test Kuramında güvenirliği etkileşimli olarak gösterir. Her sayı sayfanın içindeki hesaplama çekirdeğinden gelir; öğrenci veri girdileri tarayıcıdan çıkmaz.'),
        el('p', null, 'Sınırlılıklar: laboratuvardaki α ve GK sonuçları idealleştirilmiş modellerden gelir; yalnızca p × i ve p × r desenleri vardır; Türkçe metinler ve hata türleri tablosu kullanılan ders kitabıyla karşılaştırılarak gözden geçirilmelidir.'),
        exportBlock());
    }
  }
  function exportBlock() {
    const out = el('div', { 'aria-live': 'polite' });
    return el('div', { class: 'kart' }, el('h3', null, 'Veriyi dışa aktar'), el('p', null, 'Geçerli sınıf kodundaki simülasyon verisini (M4: iki ölçme) CSV olarak al; jamovi, SPSS veya R ile doğrulayabilirsin.'),
      el('p', { class: 'not' }, 'Kod kitabı. Biçim: UTF-8, alan ayırıcı virgül, ondalık nokta. ogrenci: öğrenci sırası (1-200). olcme1: birinci ölçmenin gözlenen puanı. olcme2: ikinci ölçmenin gözlenen puanı. Değerler M4\'teki geçerli ayarlarla ve sınıf koduyla üretilir; aynı kod aynı veriyi verir.'), button('CSV olarak al', () => exportCSV(out)), out);
  }
  function csvData() {
    const st = coreState('m4'); st.params = S.params.m4; const d = C.derive(st)._series;
    const lines = ['ogrenci,olcme1,olcme2'].concat(d.X1.map((x, i) => (i + 1) + ',' + x + ',' + d.X2[i]));
    return '﻿' + lines.join('\r\n') + '\r\n';
  }
  async function exportCSV(out) {
    const text = csvData(), name = 'guvenirlik-lab-m4-sinif-' + S.seed + '.csv';
    try {
      if (window.claude && typeof window.claude.use === 'function') {
        const dl = await window.claude.use('downloads');
        if (dl && typeof dl.save === 'function') {
          try { await dl.save({ filename: name, data: text }); out.textContent = 'Dosya kaydedildi: ' + name; return; }
          catch (err) { if (err && err.code === 'declined') { out.textContent = 'Kaydetme iptal edildi.'; return; } if (err && err.code === 'rate_limited') { out.textContent = 'Başka bir kaydetme penceresi açık; biraz sonra yeniden dene.'; return; } }
        }
      } else if (BUILD.standalone) {
        const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([text], { type: 'text/csv' })); a.setAttribute('download', name); a.click(); out.textContent = 'İndirme başlatıldı.'; return;
      }
    } catch (e) { /* panoya düş */ }
    try { await navigator.clipboard.writeText(text); out.textContent = 'CSV panoya kopyalandı.'; }
    catch (e) { out.innerHTML = ''; put(out, el('p', null, 'Metni seçip kopyala:'), el('textarea', { rows: 6, style: 'width:100%', readonly: true, 'aria-label': 'CSV metni' }, text)); }
  }

  const DEFAULT_VIEW = { m2: 'backstage', m3: 'backstage', m4: 'backstage' };
  function go(id) {
    if (MODS.includes(id)) { S.page = 'modul'; S.module = id; S.view = DEFAULT_VIEW[id] || 'real'; syncStrip(); store('modul', id); logEvent('modul_giris', { module: id }); }
    else S.page = id;
    renderModule(); window.scrollTo(0, 0);
  }
  function newClass() { const b = snapshot(); S.seed += 1; document.getElementById('sinif-kodu').value = S.seed; update(); neDegisti(b, 'Sınıf kodu'); }
  function applyPreset(id) {
    const st = C.presetState(id); S.page = 'modul'; S.module = st.module; S.params[st.module] = st.params;
    const p = C.PRESETS.find(x => x.id === id); if (p && p.params.expert) S.expert = true;
    syncStrip(); renderModule();
  }

  // ---------------------------------------------------------------------------
  // Kabuk
  // ---------------------------------------------------------------------------
  function syncStrip() {
    const vg = document.querySelector('.serit [aria-label="Görünüm"]'); if (vg) vg.hidden = S.page === 'modul' && S.module === 'm1';
    document.querySelectorAll('[data-gorunum]').forEach(b => b.setAttribute('aria-pressed', b.dataset.gorunum === S.view ? 'true' : 'false'));
    const e = document.getElementById('o-uzman'); if (e) e.checked = S.expert;
    const pd = document.getElementById('payda'); if (pd) pd.value = S.denom;
  }
  function shell() {
    const app = document.getElementById('uygulama');
    const nav = el('ul', { class: 'nav' });
    const lessons = { m1: '1. ders', m4: '2. ders', m7: '3. ders', m10: 'Ders dışı' };
    K.modules.forEach(m => { if (lessons[m.id]) put(nav, el('li', { class: 'ders', role: 'presentation' }, lessons[m.id])); put(nav, el('li', null, el('button', { type: 'button', 'data-go': m.id, onclick: () => go(m.id) }, el('span', { class: 'kod' }, m.id.toUpperCase()), m.kisa))); });
    put(nav, el('li', { class: 'ayrac', role: 'presentation' }));
    [['etki', K.ui.etkiHaritasi], ['sozluk', K.ui.sozluk], ['kaynaklar', K.ui.kaynaklar], ['hakkinda', 'Hakkında ve dışa aktarma']].forEach(([k, l]) => put(nav, el('li', null, el('button', { type: 'button', 'data-go': k, onclick: () => go(k) }, el('span', { class: 'kod' }, '·'), l))));
    const strip = el('div', { class: 'serit', role: 'region', 'aria-label': 'Görünüm ve sınıf ayarları' },
      el('div', { class: 'anahtar', role: 'group', 'aria-label': 'Görünüm' }, ['real', 'backstage'].map(v => el('button', { type: 'button', 'data-gorunum': v, 'aria-pressed': S.view === v ? 'true' : 'false', onclick: () => { S.view = v; syncStrip(); renderModule(); logEvent('gorunum', { value: v }); } }, K.ui.gorunum[v]))),
      STATIC ? null : el('label', { class: 'kod-kutu', for: 'sinif-kodu' }, K.ui.sinifKodu, el('input', { id: 'sinif-kodu', type: 'number', min: 1, max: 99999, value: S.seed, onchange: e => { const b = snapshot(); S.seed = Math.max(1, parseInt(e.target.value, 10) || 1); update(); neDegisti(b, 'Sınıf kodu'); } })),
      STATIC ? null : button(K.ui.yeniSinif, () => newClass()),
      STATIC ? null : el('label', { class: 'onay', for: 'o-uzman' }, el('input', { type: 'checkbox', id: 'o-uzman', onchange: e => { S.expert = e.target.checked; renderModule(); } }), K.ui.uzmanModu),
      el('label', { class: 'kod-kutu', for: 'payda' }, K.ui.payda, el('select', { id: 'payda', class: 'dugme', onchange: e => { S.denom = e.target.value; renderModule(); } }, el('option', { value: 'n-1' }, 'n − 1 (yazılımlarla aynı)'), el('option', { value: 'n' }, 'n'))),
      el('label', { class: 'onay', for: 'o-basamak' }, el('input', { type: 'checkbox', id: 'o-basamak', onchange: e => { S.digits = e.target.checked ? 4 : 2; update(); } }), K.ui.dahaFazla),
      el('p', { class: 'not', style: 'flex-basis:100%' }, K.ui.gorunumAciklama));
    const ver = BUILD.version || 'geliştirme';
    put(app, el('div', { class: 'kabuk' },
      el('aside', { class: 'yan', 'aria-label': 'Modüller' }, el('div', { class: 'marka' }, el('span', { class: 'ad' }, K.ui.baslik), el('span', { class: 'alt' }, 'Klasik Test Kuramı · güvenirlik')), el('nav', { 'aria-label': 'Modül listesi' }, nav)),
      el('main', { class: 'ana', id: 'ana' }, el('h1', { class: 'gorunmez' }, K.ui.baslik), strip, el('div', { id: 'modul', class: 'bolum' }),
        el('footer', { class: 'altbilgi' }, el('span', null, K.ui.baslik + ' ' + ver), el('span', null, 'derleme ' + (BUILD.date || '–')), el('span', null, 'içerik ' + (BUILD.content_hash || '–')), el('span', null, 'kaynak ' + (BUILD.src_hash || '–')), el('span', null, STATIC ? 'durağan sürüm' : 'etkileşimli sürüm')))),
      el('section', { id: 'butce', class: 'butce', 'aria-label': K.ui.butce, hidden: true }),
      el('div', { id: 'canli', class: 'canli', 'aria-live': 'polite' }));
    syncStrip();
  }

  // ---------------------------------------------------------------------------
  // Olay kaydı (yalnızca RESEARCH=1 derlemesinde etkin; aksi hâlde boş işlev)
  // ---------------------------------------------------------------------------
  function logEvent(event, data) { if (window.RelLog && typeof window.RelLog.log === 'function') window.RelLog.log(event, Object.assign({ module: S.module, seed: S.seed }, data || {})); }

  // Test kancası
  window.RelLab = {
    getState: () => JSON.parse(JSON.stringify({ module: S.module, page: S.page, view: S.view, seed: S.seed, denom: S.denom, expert: S.expert, digits: S.digits, params: S.params[S.module] })),
    setState(patch) { const p = patch || {}; if (p.params) Object.assign(S.params[p.module || S.module], p.params); ['view', 'seed', 'denom', 'expert', 'digits'].forEach(k => { if (k in p) S[k] = p[k]; }); if (p.module) { S.module = p.module; S.page = 'modul'; } syncStrip(); renderModule(); },
    applyPreset, listPresets: () => C.listPresets(), setView(v) { S.view = v; syncStrip(); renderModule(); }, go, derive: () => C.derive(coreState()),
  };

  shell(); renderModule();
})();
