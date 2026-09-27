// Bloklu ve tohumlu atama listesi: katılımcı kodu (6 rakam + Damm kontrol basamağı) ve koşul adresi.
// Kullanım: node tools/assign.mjs --n 120 --blok 4 --tohum 2026 --etkilesimli <adres> --duragan <adres> [--tga0-etkilesimli <adres> --tga0-duragan <adres>] > atama.csv
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const C = require('../src/core.js');
const args = Object.fromEntries(process.argv.slice(2).reduce((a, v, i, arr) => (v.startsWith('--') ? a.concat([[v.slice(2), arr[i + 1]]]) : a), []));
const n = Number(args.n || 60), blok = Number(args.blok || 4), tohum = args.tohum || '1';
const kosullar = [['etkilesimli', args.etkilesimli], ['duragan', args.duragan], ['tga0-etkilesimli', args['tga0-etkilesimli']], ['tga0-duragan', args['tga0-duragan']]].filter(([, u]) => u);
if (kosullar.length < 2) { console.error('En az iki koşul adresi gerekir (--etkilesimli ve --duragan).'); process.exit(1); }
if (blok % kosullar.length) { console.error('Blok büyüklüğü koşul sayısının katı olmalı.'); process.exit(1); }
const DAMM = [[0, 3, 1, 7, 5, 9, 8, 6, 4, 2], [7, 0, 9, 2, 1, 5, 4, 8, 6, 3], [4, 2, 0, 6, 8, 7, 1, 3, 5, 9], [1, 7, 5, 0, 9, 8, 3, 4, 2, 6], [6, 1, 2, 3, 0, 4, 5, 9, 7, 8], [3, 6, 7, 4, 2, 0, 9, 5, 8, 1], [5, 8, 6, 9, 7, 2, 0, 1, 3, 4], [8, 9, 4, 5, 3, 6, 2, 0, 1, 7], [9, 4, 3, 8, 6, 1, 7, 2, 0, 5], [2, 5, 8, 1, 4, 3, 6, 7, 9, 0]];
const damm = s => { let i = 0; for (const ch of s) i = DAMM[i][Number(ch)]; return i; };
const rng = C.uniformStream(tohum, 'atama', 0), used = new Set(), out = ['katilimci_kodu,kosul,adres'];
let count = 0;
while (count < n) {
  const block = []; for (let b = 0; b < blok; b++) block.push(kosullar[b % kosullar.length]);
  for (let i = block.length - 1; i > 0; i--) { const j = Math.floor(rng() * (i + 1)); [block[i], block[j]] = [block[j], block[i]]; }
  for (const [ad, url] of block) {
    if (count >= n) break;
    let kod; do { kod = String(Math.floor(rng() * 1e6)).padStart(6, '0'); } while (used.has(kod)); used.add(kod);
    out.push(`${kod}${damm(kod)},${ad},${url}`); count++;
  }
}
console.log(out.join('\n'));
