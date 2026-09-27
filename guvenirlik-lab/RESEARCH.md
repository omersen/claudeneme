# Araştırmada kullanım

Bu belge, laboratuvarın etkileşimli ve durağan sürümlerini karşılaştıran bir çalışmada nasıl kullanılacağını ve hangi verinin nereye gittiğini açıklar. Etik kurul onayı ve KVKK uyumu araştırmacının sorumluluğundadır.

## Koşullar ve yayınlar

İki koşul aynı içerik dosyasından (`src/content.tr.js`) üretilir. Metin, formüller, sayılar, TGA tahmin girişi ve "Sonucu göster" düğmesi, kontrol soruları, M10, etki haritası (durağanda tamamlanmış olarak), sözlük ve kaynaklar iki koşulda aynıdır. Kaydırıcılar, sürükleme, veri düzenleme ve yapıştırma, yarıya bölme gezgini, uzman modu, "Yeni sınıf çek" ve toplu çekimler yalnızca etkileşimli sürümdedir. Formül ile görsel arasındaki terim vurgusu iki sürümde de vardır, çünkü karşılaştırılan etken manipülasyondur, bağlantılı gösterim değildir.

Artifact sayfasına sorgu dizesi ulaşmadığı için her koşul ayrı ve dondurulmuş bir Artifact olarak yayımlanır. Veri toplama sırasında bir yayın güncellenmez. `tools/assign.mjs` bloklu ve tohumlu bir atama listesi üretir:

```
node tools/assign.mjs --n 120 --blok 4 --tohum 2026 --etkilesimli <adres> --duragan <adres> > atama.csv
```

2×2 desen (sunum × TGA) için `TGA=0 node build.mjs` TGA kartlarını gizleyen bir derleme üretir; `--tga0-etkilesimli` ve `--tga0-duragan` adresleri atamaya eklenir.

Durağan sürüm bu oturumda ayrı bir Artifact olarak yayımlanmadı. SPEC gereği kullanıcı onayından sonra yayımlanacaktır.

## Olay kaydı

Kayıt kodu yalnızca `RESEARCH=1` derlemesine girer ve varsayılan olarak kapalıdır. Artifact derlemesinde kayıt kodu yoktur (test L5). Artifact veritabanı kayıt için kullanılmaz, çünkü izleyiciler ve dış bağlantı ziyaretçileri ona yazamaz.

Gerçek veri toplama için bağımsız sürüm (`dist/standalone/`) araştırmacının denetlediği bir sunucuda barındırılır:

```
RESEARCH=1 LOG_ENDPOINT=https://sunucunuz/kayit node build.mjs
```

Sayfa kayıtları bu adrese JSON olarak POST eder. `LOG_ENDPOINT` boşsa hiçbir istek gönderilmez; katılımcı kayıtlarını dışa aktarabilir. Bağımsız sürüm üçüncü taraf isteği yapmaz: KaTeX satır içidir, Google Fonts yoktur. Böylece katılımcının IP adresi başka bir sunucuya gitmez.

Kurallar:

- Önce sayfa içinde bir onam ekranı gelir. Metin yer tutucudur; etik kurul onaylı metni araştırmacı koyar. Onam olmadan hiçbir şey kaydedilmez (test L1). Onam ekranında "Yerel arabelleği sil" seçeneği vardır.
- Katılımcı kodu kâğıt üzerinde dağıtılan 7 rakamdır: 6 rastgele rakam ve 1 Damm kontrol basamağı. Geçersiz kod reddedilir. Ad, öğrenci numarası, e-posta, IP adresi, user-agent veya serbest metin kaydedilmez.
- Şema: `pid, cond, version, content_hash, src_hash, seed, session_id, ts_iso, t_rel_ms, event, module, param, old, new, value, device_class`. `session_id` `crypto.randomUUID()` ile üretilir. `device_class` yalnızca görünüm genişliğinden türetilir (<600 telefon, 600-1024 tablet, >1024 masaüstü).
- Olaylar: kaydırıcı bırakma anında tek satır (test L3), TGA yön, güven ve gerekçe seçimleri, modül girişi, görünüm değişimi, M7 yanıt tanıları, M10 yanıtları, 60 saniyelik boşta kalma.

## Kim neyi okuyabilir

| Veri | Nerede durur | Kim okuyabilir |
|---|---|---|
| Kayıt satırları | Katılımcının tarayıcısında (`localStorage`) ve `LOG_ENDPOINT` sunucusunda | Katılımcı (kendi tarayıcısında), sunucu yöneticisi |
| Dışa aktarılan CSV/JSON | Katılımcının cihazı, sonra araştırmacıya verdiği dosya | Katılımcı, araştırmacı |
| TGA tahminleri, M10 yanıtları (kayıt kapalıyken) | Yalnızca izleyicinin tarayıcısında | Yalnızca izleyici |

## Kullanıcı tarafından doğrulanacaklar

- Artifact'taki `downloads` yeteneğinin herkese açık bağlantıyla gelen izleyicide çalışıp çalışmadığı. Çalışmazsa sayfa panoya kopyalamaya, o da olmazsa seçilebilir metin kutusuna düşer.
- Artifact bağlantısının hesap gerektirmeden açılıp açılmadığı.
- KaTeX'in izleyicinin tarayıcısında jsDelivr'den yüklendiği (bu oturumun kapsayıcısı CDN'lere erişemediği için yalnızca yerel yönlendirmeyle sınandı).
- Olay kaydı gerçek öğrencilerle ve etik onayla test edilmemiştir.
