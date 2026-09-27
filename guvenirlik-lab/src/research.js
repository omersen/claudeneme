/* Güvenirlik Laboratuvarı: anonim olay kaydı. Yalnızca RESEARCH=1 derlemesine girer.
 * Onam olmadan hiçbir şey kaydedilmez. Ad, numara, e-posta, IP, user-agent veya serbest metin kaydedilmez. */
(function () {
  'use strict';
  const BUILD = window.REL_BUILD || {};
  const FIELDS = ['pid', 'cond', 'version', 'content_hash', 'src_hash', 'seed', 'session_id', 'ts_iso', 't_rel_ms', 'event', 'module', 'param', 'old', 'new', 'value', 'device_class'];
  // Damm algoritması (ondalık); kod 6 rakam + 1 kontrol basamağı
  const DAMM = [[0, 3, 1, 7, 5, 9, 8, 6, 4, 2], [7, 0, 9, 2, 1, 5, 4, 8, 6, 3], [4, 2, 0, 6, 8, 7, 1, 3, 5, 9], [1, 7, 5, 0, 9, 8, 3, 4, 2, 6], [6, 1, 2, 3, 0, 4, 5, 9, 7, 8], [3, 6, 7, 4, 2, 0, 9, 5, 8, 1], [5, 8, 6, 9, 7, 2, 0, 1, 3, 4], [8, 9, 4, 5, 3, 6, 2, 0, 1, 7], [9, 4, 3, 8, 6, 1, 7, 2, 0, 5], [2, 5, 8, 1, 4, 3, 6, 7, 9, 0]];
  function dammDigit(s) { let i = 0; for (const ch of s) i = DAMM[i][Number(ch)]; return i; }
  function validCode(code) { return /^\d{7}$/.test(code) && dammDigit(code) === 0; }
  const t0 = performance.now();
  const session = (window.crypto && crypto.randomUUID) ? crypto.randomUUID() : 'oturum-yok';
  let consent = false, pid = null, rows = [];
  try { const b = JSON.parse(localStorage.getItem('guvlab.kayit') || 'null'); if (b && b.pid) { rows = b.rows || []; pid = b.pid; consent = !!b.consent; } } catch (e) { /* depolama yok */ }
  function deviceClass() { const w = window.innerWidth; return w < 600 ? 'telefon' : w <= 1024 ? 'tablet' : 'masaustu'; }
  function persist() { try { localStorage.setItem('guvlab.kayit', JSON.stringify({ pid, consent, rows })); } catch (e) { /* yalnızca bellekte */ } }
  function sanitize(v) { return v == null ? '' : typeof v === 'number' ? v : String(v).slice(0, 64); }
  function log(event, data) {
    if (!consent || !pid) return;
    const d = data || {};
    const row = { pid, cond: BUILD.cond || '', version: BUILD.version || '', content_hash: BUILD.content_hash || '', src_hash: BUILD.src_hash || '', seed: sanitize(d.seed), session_id: session, ts_iso: new Date().toISOString(), t_rel_ms: Math.round(performance.now() - t0), event: sanitize(event), module: sanitize(d.module), param: sanitize(d.param), old: sanitize(d.old), new: sanitize(d.new), value: sanitize(d.value), device_class: deviceClass() };
    rows.push(row); persist(); send([row]);
  }
  function send(batch) {
    if (!BUILD.log_endpoint) return;
    try { fetch(BUILD.log_endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(batch), keepalive: true }).catch(() => {}); } catch (e) { /* yedek: dışa aktarma */ }
  }
  function toCSV() { const esc = v => { const s = String(v); return /[",\r\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s; }; return '﻿' + [FIELDS.join(',')].concat(rows.map(r => FIELDS.map(f => esc(r[f])).join(','))).join('\r\n') + '\r\n'; }
  // 60 sn boşta kalma
  let idle = null; const reset = () => { clearTimeout(idle); idle = setTimeout(() => log('bosta', {}), 60000); };
  ['pointerdown', 'keydown'].forEach(e => window.addEventListener(e, reset, { passive: true }));
  document.addEventListener('visibilitychange', () => log(document.hidden ? 'modul_cikis' : 'modul_giris', {}));

  function consentScreen() {
    if (consent) return;
    const wrap = document.createElement('div');
    wrap.setAttribute('role', 'dialog'); wrap.setAttribute('aria-modal', 'true'); wrap.setAttribute('aria-labelledby', 'onam-baslik');
    wrap.style.cssText = 'position:fixed;inset:0;background:var(--zemin);z-index:50;overflow:auto;padding:24px 16px';
    wrap.innerHTML = '<div style="max-width:640px;margin:0 auto;display:flex;flex-direction:column;gap:12px">' +
      '<h2 id="onam-baslik">Araştırmaya katılım onamı</h2>' +
      '<p>[Etik kurul onaylı onam metni buraya gelecek. Bu metin bir yer tutucudur.]</p>' +
      '<p>Kaydedilenler: katılımcı kodun, sayfadaki etkileşimlerin (hangi denetimi ne zaman değiştirdiğin, TGA tahminlerin) ve cihaz türü. Adın, öğrenci numaran, e-postan, IP adresin veya yazdığın serbest metin kaydedilmez.</p>' +
      '<label for="onam-kod">Katılımcı kodu (kâğıttaki 7 rakam)</label><input id="onam-kod" inputmode="numeric" autocomplete="off" class="dugme" style="max-width:12em">' +
      '<p id="onam-hata" aria-live="polite" style="color:var(--kotu)"></p>' +
      '<div class="satir"><button type="button" class="dugme birincil" id="onam-evet">Onaylıyorum, başla</button><button type="button" class="dugme" id="onam-hayir">Katılmadan devam et</button><button type="button" class="dugme" id="onam-sil">Yerel arabelleği sil</button></div></div>';
    document.body.appendChild(wrap);
    wrap.querySelector('#onam-evet').addEventListener('click', () => {
      const c = wrap.querySelector('#onam-kod').value.trim();
      if (!validCode(c)) { wrap.querySelector('#onam-hata').textContent = 'Kod geçersiz. Kâğıttaki 7 rakamı kontrol et.'; return; }
      pid = c; consent = true; persist(); wrap.remove(); log('onam', {});
    });
    wrap.querySelector('#onam-hayir').addEventListener('click', () => { consent = false; wrap.remove(); });
    wrap.querySelector('#onam-sil').addEventListener('click', () => { rows = []; pid = null; consent = false; try { localStorage.removeItem('guvlab.kayit'); } catch (e) { /* yok */ } wrap.querySelector('#onam-hata').textContent = 'Yerel arabellek silindi.'; });
  }
  window.RelLog = { log, rows: () => rows.slice(), toCSV, FIELDS, validCode, dammDigit, get consent() { return consent; } };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', consentScreen); else setTimeout(consentScreen, 0);
})();
