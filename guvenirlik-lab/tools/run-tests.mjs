// Test çalıştırıcısı: Katman A (Node) ve varsa Katman B/L sonuçlarını toplar,
// tests.json'u yazar. tests.json'daki her kimliğin test kodunda karşılığı olmalıdır.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const TESTS = path.join(ROOT, 'tests.json');
const doc = JSON.parse(fs.readFileSync(TESTS, 'utf8'));
const byId = new Map(doc.tests.map(t => [t.id, t]));
const results = new Map();
const layers = (process.argv.find(a => a.startsWith('--layers=')) || '--layers=A,B,L,C').slice(9).split(',');

function record(id, pass, detail) {
  if (!byId.has(id)) { console.error('tests.json içinde olmayan kimlik: ' + id); process.exitCode = 1; return; }
  const prev = results.get(id);
  const d = detail == null ? '' : String(detail);
  if (prev) results.set(id, { pass: prev.pass && pass, detail: prev.detail + (d ? ' | ' + d : '') });
  else results.set(id, { pass, detail: d });
}
function tolerance(id) {
  const s = String(byId.get(id)?.tolerance || '1e-9');
  const pct = s.match(/%\s*([\d.]+)/);
  if (pct) return { rel: true, v: parseFloat(pct[1]) / 100 };
  const num = s.match(/[\d.]+e-?\d+|\d*\.\d+|\d+/i);
  const v = num ? parseFloat(num[0]) : 1e-9;
  return { rel: /göreli/.test(s), v };
}
function close(id, actual, expected) {
  const t = tolerance(id);
  const diff = Math.abs(actual - expected);
  return t.rel ? diff <= t.v * Math.abs(expected) : diff <= t.v + 1e-15;
}
const fmt = x => (typeof x === 'number' ? Number(x.toPrecision(10)) : JSON.stringify(x));
const harness = {
  eq(id, actual, expected) {
    const pass = typeof actual === 'number' && Number.isFinite(actual) && close(id, actual, expected);
    record(id, pass, `hesap ${fmt(actual)}, beklenen ${fmt(expected)}`);
  },
  ok(id, cond, detail) { record(id, !!cond, detail || (cond ? 'doğru' : 'yanlış')); },
  same(id, actual, expected) {
    const flat = a => (Array.isArray(a) ? a.flat(Infinity) : [a]);
    const A = flat(actual), E = flat(expected);
    const pass = A.length === E.length && A.every((x, i) => close(id, x, E[i]));
    record(id, pass, `hesap ${fmt(A)}, beklenen ${fmt(E)}`);
  },
  all(id, arr, expected) {
    const bad = arr.map((x, i) => [i + 1, x]).filter(([, x]) => !close(id, x, expected));
    record(id, bad.length === 0, `tohum 1-${arr.length}: ${arr.map(x => x.toFixed(4)).join(', ')}; beklenen ${fmt(expected)}` + (bad.length ? `; kalan tohumlar ${bad.map(b => b[0]).join(',')}` : ''));
  },
};

if (layers.includes('A')) {
  harness.content = require(path.join(ROOT, 'src/content.tr.js'));
  try { require(path.join(ROOT, 'test/layerA.cjs'))(harness); }
  catch (e) { console.error('Katman A çalışırken hata: ' + (e.stack || e)); process.exitCode = 1; }
}
// Katman B ve L: Playwright betiği test/out/browser-results.json yazar
const browserOut = path.join(ROOT, 'test/out/browser-results.json');
if ((layers.includes('B') || layers.includes('L')) && fs.existsSync(browserOut)) {
  const br = JSON.parse(fs.readFileSync(browserOut, 'utf8'));
  for (const r of br.results) if (layers.includes(r.id[0])) record(r.id, r.pass, r.detail);
}

// Katman C: gözden geçirici kararları test/review/layerC.json'dan okunur
const reviewOut = path.join(ROOT, 'test/review/layerC.json');
if (layers.includes('C') && fs.existsSync(reviewOut)) for (const r of JSON.parse(fs.readFileSync(reviewOut, 'utf8')).results) record(r.id, r.pass, r.detail);
let pass = 0, fail = 0, pending = 0;
for (const t of doc.tests) {
  const r = results.get(t.id);
  if (!r) {
    if (layers.includes(t.layer)) { t.status = 'kaldı'; t.detail = 'test kodunda karşılığı yok'; fail++; process.exitCode = 1; }
    else pending++;
    continue;
  }
  t.status = r.pass ? 'geçti' : 'kaldı'; t.detail = r.detail; r.pass ? pass++ : fail++;
}
doc._meta.last_run = { layers, pass, fail, pending };
fs.writeFileSync(TESTS, JSON.stringify(doc, null, 2) + '\n');
console.log(`geçti ${pass}, kaldı ${fail}, bekliyor ${pending}`);
for (const t of doc.tests) if (t.status === 'kaldı') console.log(`KALDI ${t.id}: ${t.claim_tr} :: ${t.detail}`);
if (fail) process.exitCode = 1;
