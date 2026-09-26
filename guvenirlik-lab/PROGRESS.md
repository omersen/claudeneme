# PROGRESS

Bu dosya SPEC.md `<devam_protokolu>` gereği tutulan denetim izidir. Düzeltmeler ve başarısız yaklaşımlar gizlenmez.

## Oturum bilgisi

- Model kimliği: Bu oturumun ortam kuralı, depoya gönderilen hiçbir dosyaya model tanımlayıcısı yazılmasına izin vermiyor. Bu yüzden kimlik burada kayıtlı değil. Denetim için kimlik, oturum kaydından (claude.ai/code oturum bağlantısı, commit iletilerindeki `Claude-Session` satırı) alınabilir. Ayrıntı: SPEC_SORULARI.md.
- Çalışma dalı: `claude/lucid-pasteur-reqzhm` (oturumun verdiği dal; SPEC'teki `guvenirlik-lab` dalı yedek seçenektir ve kullanılmadı).
- Proje kökü: `guvenirlik-lab/`. SPEC'teki `src/`, `dist/`, `build.mjs` gibi yollar bu köke göredir.

## Ortam (2026-09-26, 23:07 UTC denetimi)

- Node v22.22.2 (`/opt/node22/bin`), genel Playwright kurulu (`/opt/node22/lib/node_modules/playwright`).
- `/opt/pw-browsers` içinde yalnızca Chromium var. Firefox ve WebKit yok; B17'nin çapraz motor kısmı sınırlılık olarak raporlanacak.
- npm kayıt deposu erişilebilir: katex 0.18.9, axe-core 4.13.0 (en son sürümler).
- `cdn.jsdelivr.net` ve `cdnjs.cloudflare.com` bu kapsayıcıdan erişilemiyor (vekil sunucu reddediyor). SPEC'in öngördüğü gibi testlerde KaTeX npm'den kurulup Playwright `page.route` ile yerel dosyaya yönlendirilecek. Yayımlanan Artifact izleyicinin tarayıcısında KaTeX'i CDN'den yükleyecek; bu, kapsayıcıdan doğrulanamaz ve kullanıcı tarafından ilk yayında kontrol edilmelidir.
- `fonts.googleapis.com` erişilebilir.

## Aşama 0 (plan, kod yok)

Durum: sürüyor.
