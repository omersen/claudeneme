// Derleme: dist/index.html (Artifact parçası), dist/static.html (durağan sürüm),
// dist/standalone/ (doctype'lı tam belgeler; üçüncü taraf isteği yok).
// Bayraklar: COND=etkilesimli|duragan (index/static için ikisi de üretilir), RESEARCH=1, LOG_ENDPOINT=..., TGA=0
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(fileURLToPath(import.meta.url));
const rd = p => fs.readFileSync(path.join(ROOT, p), 'utf8');
const pkg = JSON.parse(rd('package.json'));
const KATEX_VERSION = '0.18.9';
const KATEX_URL = `https://cdn.jsdelivr.net/npm/katex@${KATEX_VERSION}/dist/katex.min.js`;
const FONTS = 'https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:ital,wght@0,400;0,700;1,400&family=JetBrains+Mono:wght@400;600&family=Source+Serif+4:opsz,wght@8..60,600;8..60,700&display=swap';
const RESEARCH = process.env.RESEARCH === '1';
const LOG_ENDPOINT = process.env.LOG_ENDPOINT || '';
const TGA = process.env.TGA !== '0';
const HASH_PLACEHOLDER = '__CONTENT_HASH__';

// KaTeX CSS: yazı tipleri yalnızca woff2 data URI
function katexCss() {
  const dir = path.join(ROOT, 'node_modules/katex/dist');
  let css = fs.readFileSync(path.join(dir, 'katex.min.css'), 'utf8');
  css = css.replace(/,url\(fonts\/[^)]+\.woff\) format\("woff"\)/g, '').replace(/,url\(fonts\/[^)]+\.ttf\) format\("truetype"\)/g, '');
  css = css.replace(/url\(fonts\/([^)]+\.woff2)\)/g, (_, f) => `url(data:font/woff2;base64,${fs.readFileSync(path.join(dir, 'fonts', f)).toString('base64')})`);
  if (/url\(fonts\//.test(css)) throw new Error('KaTeX CSS içinde gömülmemiş yazı tipi kaldı');
  return css;
}
const SRC_FILES = ['src/core.js', 'src/content.tr.js', 'src/app.js', 'src/styles.css', 'src/research.js'].filter(f => fs.existsSync(path.join(ROOT, f)));
const srcHash = crypto.createHash('sha256').update(SRC_FILES.map(rd).join('\n')).digest('hex').slice(0, 12);
const date = new Date().toISOString().slice(0, 10);

function page({ cond, standalone }) {
  const build = { version: 'v' + pkg.version, date, content_hash: HASH_PLACEHOLDER, src_hash: srcHash, cond, standalone: !!standalone, research: RESEARCH, log_endpoint: LOG_ENDPOINT, tga: TGA };
  const css = rd('src/styles.css') + '\n' + katexCss();
  const head = [
    '<title>Güvenirlik Laboratuvarı</title>',
    '<style>' + rd('src/styles.css') + '</style>',
  ];
  const fonts = standalone ? '' : `<link rel="stylesheet" href="${FONTS}">`;
  const katexScript = standalone
    ? '<script>' + fs.readFileSync(path.join(ROOT, 'node_modules/katex/dist/katex.min.js'), 'utf8').replace(/<\/script/gi, '<\\/script') + '</script>'
    : `<script src="${KATEX_URL}"></script>`;
  const scripts = [
    `<script>window.REL_BUILD=${JSON.stringify(build)};</script>`,
    '<script>' + rd('src/core.js') + '</script>',
    '<script>' + rd('src/content.tr.js') + '</script>',
    RESEARCH ? '<script>' + rd('src/research.js') + '</script>' : '',
    '<script>' + rd('src/app.js') + '</script>',
  ].join('\n');
  const body = [
    fonts,
    '<style>' + katexCss() + '</style>',
    katexScript,
    '<div id="uygulama"></div>',
    scripts,
  ].join('\n');
  let html = head.join('\n') + '\n' + body + '\n';
  if (standalone) html = '<!doctype html>\n<html lang="tr">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n' + head.join('\n') + '\n</head>\n<body>\n' + body + '</body>\n</html>\n';
  const h = crypto.createHash('sha256').update(html.replace(HASH_PLACEHOLDER, '')).digest('hex').slice(0, 12);
  void css;
  return html.replace(HASH_PLACEHOLDER, h);
}

const OUTDIR = process.env.OUTDIR ? path.resolve(ROOT, process.env.OUTDIR) : path.join(ROOT, 'dist');
fs.mkdirSync(path.join(OUTDIR, 'standalone'), { recursive: true });
const out = {
  'index.html': page({ cond: 'etkilesimli' }),
  'static.html': page({ cond: 'duragan' }),
  'standalone/index.html': page({ cond: 'etkilesimli', standalone: true }),
  'standalone/static.html': page({ cond: 'duragan', standalone: true }),
};
for (const [f, html] of Object.entries(out)) fs.writeFileSync(path.join(OUTDIR, f), html);
const first8k = out['index.html'].slice(0, 8192);
if (!first8k.includes('<title>Güvenirlik Laboratuvarı</title>')) throw new Error('<title> ilk 8 KB içinde değil');
console.log(Object.entries(out).map(([f, h]) => `${path.relative(ROOT, path.join(OUTDIR, f))} ${(h.length / 1024).toFixed(0)} KB`).join('\n') + `\nsrc_hash ${srcHash}${RESEARCH ? ' (RESEARCH=1)' : ''}`);
