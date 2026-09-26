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

Durum: tamamlandı, kullanıcı onayı bekleniyor (DUR). Tarih: 2026-09-26/27 (UTC).

Üretilen dosyalar:
- `PLAN.md`: gösterim kuralları, modül listesi M1-M10, test katmanları ve aşama planı, SPEC'in kendi sözlerimle yeniden yazımı.
- `CLAIMS.md`: `<icerik_dogrulugu>` içindeki 60 iddia kimliği için iskelet defter (durum "planlandı").
- `formulas.expected.json`: SPEC'ten harfiyen çıkarılmış 138 formül, 17 öneri, 2 sayısal satır adayı ve 19 not. Her TeX, SPEC'teki bir matematik parçasının birebir alt dizesi olarak betikle denetlendi ve KaTeX 0.18.9 (npm) ile SPEC'teki `trust`/`strict` ayarlarıyla hatasız ve uyarısız işlendi. Durum: kullanıcı onayı bekliyor.
- `FORMUL_ONAYI.md`: aynı kataloğun okunabilir onay sayfası (JSON'dan üretildi; onaylanan dosya JSON'dur).
- `tests.json`: 493 atomik test kimliği (A 421, B 62, L 7, C 3), hepsi "bekliyor". Katman A'daki her sayısal beklenen değer Python `fractions` ile bağımsız olarak iki kez yeniden hesaplandı; tek uyuşmazlık A3.22 (aşağıda).
- `SPEC_SORULARI.md`: 20 madde.

Nasıl yapıldı: Aşama 0 bir iş akışıyla yürütüldü. Dört alt ajan (formül çıkarma, test ayrıştırma, plan ve iddia defteri, spec soruları) paralel çalıştı; ilk üçünün çıktısını birer bağımsız denetçi alt ajan SPEC ile karşılaştırıp yerinde düzeltti. Lider (bu oturum) r̄ hatasını ve M4 uzlaştırma kartındaki iddiayı ayrıca kendisi yeniden hesapladı.

Spec'ten sapmalar:
- Alt ajan kullanımı: SPEC satır 354 son gözden geçirici dışında alt ajan kullanılmamasını ister. Aşama 0'da 7 alt ajan kullanıldı (oturumda çok ajanlı çalışma açıktı). Aşama 1'den itibaren kullanıcı açıkça izin vermedikçe alt ajan kullanılmayacak (SPEC_SORULARI madde 1).
- `tests.json` Aşama 0'da çalıştırıcı olmadan oluşturuldu; bu tek seferlik başlangıç kaydıdır (madde 5).
- Spec soruları ayrı bir dosyada tutuluyor; izleme aşağıdadır (madde 19c).

Düzeltmeler (denetçi ajanların yaptıkları): formül kataloğuna `m2.artik` eklendi; `m9.icice_bilesen` sembolik ve sayısal parçalara ayrıldı; test listesinde birden çok iddia taşıyan kimlikler bölündü, iki yinelenen kimlik silindi, A15 yeniden numaralandı, SPEC'te olmayan bir ifade ("NaN veya sonsuz yok") kaldırıldı; PLAN.md'de M4, M5 ve M8 paragrafları SPEC'in koşullarına (B.1, D.1, D.5) göre düzeltildi.

## Spec soruları

Ayrıntılar `SPEC_SORULARI.md` içindedir. Durum özeti:

| Madde | Konu | Aşama 1'den önce yanıt | Durum |
|---|---|---|---|
| 1 | Alt ajan kullanımı | Evet | açık |
| 2 | A11 toleransı (yaklaşık %12,6 kalma riski) | Evet | açık |
| 20 | r̄ = .5080 yanlış yuvarlanmış (.5079) | Evet | açık |
| 3 | M4 uzlaştırma kartı B.1 ile çelişiyor | Hayır (Aşama 3'ten önce) | açık |
| 4 | Model kimliği kaydı | Hayır | açık |
| 5-19 | Varsayılan kararla ilerlenecekler | Hayır | varsayılan uygulanacak |
