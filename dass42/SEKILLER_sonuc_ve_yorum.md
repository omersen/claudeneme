# ŞEKİLLER: Kod, çalıştırma sonucu ve yorum kılavuzu

Hazırlayan: Claude Code (yapay zekâ kodlama aracı), 28 Eylül 2026. Okur: danışman. Önceki belgelerde olduğu gibi bu belge `blok_notlari.md` yerine geçmez; son ifade Berkcan'a aittir.

**Bu blok neye hizmet eder?** Yeni bir hesap yapmaz. AS1 ve AS5'in sonuçlarını iki şekille gösterir:

- `sekil_AS1_ISI_a.png`: her alt boyutta 14 maddenin ISI ve a değerleri.
- `sekil_AS5_alt_kume_testi.png`: bütün kümeler ve dört formun konumu.

## Ne yapıldı ve nasıl denetlendi

Yalnız `TODO ŞEKİLLER` bloğu dolduruldu (78 satır eklendi). Kod yalnız ggplot2 kullanır ve yeni paket eklemez. Şekiller 300 dpi, beyaz zeminli PNG olarak yazılır. Bloğun başındaki okuma kılavuzu, iki şeklin nasıl okunacağını ve hangi amaçla kullanılamayacağını açıklar.

Tasarımda üç tercih yapıldı:

- Panel başlıklarındaki rho değerleri `sonuc` listesinden alınır, yani elle yazılmaz.
- Eksenlerde Türkçe ondalık virgülü kullanılır.
- Dört form, rengin yanında ayrı şekillerle de ayırt edilir. Böylece siyah-beyaz baskıda da okunabilir.

Bu adımda iki düzeltme de yapıldı:

1. **Karşılaştırma betiği `ek_*` tablolarını kapsamıyordu.** Bu yüzden EK ANALİZLER belgesindeki "21 tablo aynı" iddiası denetlenmemişti. Betik düzeltildi. `ek_VCL_duyarlilik.csv` tablosunun değerleri başvuruyla aynıydı, ama satırları önce soruya göre diziliyordu; bu da form sırasının tabloda iki kez baştan başlamasına yol açıyordu (YÖNERGE Kural 7). EK ANALİZLER bloğuna bir sıralama satırı eklendi. EK ANALİZLER belgesine de düzeltme notu yazıldı.
2. **Eksen etiketlerinde basamak sayısı eşitlendi.** Örneğin "0,5" yerine "0,50" yazılır.

| Denetim | Sonuç (son çalıştırma `sekil_04`) |
| --- | --- |
| Kabul durumu | **KABUL, 279/279** (0 eksik, 0 farklı) |
| Dört bütünlük satırı | Dördü de `gecti`; çıktı dosyaları satırı da artık geçiyor (21 tablo, 2 şekil) |
| İç denetimler | 182'nin hepsi geçti |
| Sürümler | R 4.5.3, lavaan 0.7.2, semTools 0.5.9, mirt 1.47 (önerilenle aynı) |
| Sabit bölüm özeti | `9bef53a2…` (beklenenle aynı) |
| Girdi dosyalarının SHA-256 özetleri (`dosya_ozetleri.csv`) | DASS arşivi, vektör dosyası ve örneklem bölmesi başvuru çalıştırmasıyla aynı |
| `ref06` ile karşılaştırma (başvuru kodu okunmadan) | 21 tablonun hepsi aynı, satır sırası dahil |
| TODO kodunun taraması (son denetim istemi) | `referans_degerler.csv` okuması yok; `sonuc`'a sabit sayı ataması yok; `library()` çağrısı yok; rastgele sayı yalnız bootstrap bloğunda ve tanımlanan biçimde |

Şekiller başvuru şekilleriyle piksel düzeyinde karşılaştırılmadı. Rehber şekiller için bir biçim tanımı vermez; kabul denetimi yalnız şekillerin var olduğunu denetler.

## Şekiller nasıl okunur

**AS1 şekli (`sekil_AS1_ISI_a.png`).** Üç panel vardır: depresyon, kaygı, stres. x ekseni ISI'dir, yani maddenin alt boyuttaki diğer maddelerle ortalama kosinüs benzerliği. y ekseni kalibrasyon grubundaki GRM ayırt ediciliğidir (a). Panel başlıklarında Spearman rho vardır: 0,63, 0,63 ve 0,79. Noktaların sağa doğru yükselmesi, AS1'deki pozitif ilişkinin görsel karşılığıdır. Tek tek maddeler yorumu somutlaştırır:

- D'de sol altta kalan Q42 ve Q05, en düşük ISI'ye ve düşük a değerine sahip maddelerdir.
- A'da en altta kalan Q02 ("dryness of my mouth") hem en düşük ISI'ye hem en düşük a değerine sahiptir.

Bu şekil 14 noktaya dayanan betimsel bir gösterimdir ve nedensellik göstermez. GRM tanıları (AS1 belgesi) nedeniyle y ekseni "bu model altında kestirilen ayırt edicilik" olarak okunmalıdır.

**AS5 şekli (`sekil_AS5_alt_kume_testi.png`).** Şekil değerlendirme grubundandır ve iki satırdan oluşur:

- Üst satırda 3.432 kümenin SB ve alfa değerleri vardır. Bulutun aşağı eğimi, çeşitlilik arttıkça alfanın düşme eğilimini gösterir (rho −0,81, −0,63, −0,78).
- Alt satırda 1.716 bölünmenin CL_b ve RMSE değerleri vardır. Bulutun yukarı eğimi, iki yarı birbirini daha az temsil ettikçe RMSE'nin artma eğilimini gösterir (rho 0,69, 0,53, 0,76).

Dört formun bulut içindeki yeri, ALT KÜME TABLOSU'ndaki yüzdeliklerin görsel karşılığıdır:

- Üst satırda MAX21 (kare) sol üstte, yani düşük çeşitlilik ve yüksek alfa bölgesindedir. MIN21 (üçgen) sağ alttadır.
- Alt satırda COV21 (çarpı) ve PUB21 (daire) sol altta, yani düşük temsil kaybı ve düşük RMSE bölgesindedir. D alt boyutunda PUB21, bulutun en alt uçlarından birindedir.
- MIN21 ile MAX21 aynı bölünmenin iki yarısı olduğu için alt satırda üst üste düşer. Bu bir hata değildir; şeklin alt yazısında belirtilmiştir.

Şekil yordama iddiası, başarı eşiği ya da "en iyi küme" seçimi için kullanılmaz (rehber, AS5).

## Danışmanın dikkatine

1. AS1 şeklinde üç yerde madde etiketleri kısmen üst üste biner: D'de Q17 ve Q03, A'da Q20 ve Q04, S'de Q12 ve Q33. Bunu çözecek etiket paketleri (ör. ggrepel) yönerge gereği kullanılmadı. Tezde gerekirse bu maddeler şekil altı notunda belirtilebilir.
2. Bütün bloklar tamamlandı ve betik KABUL verdi. Rehberin öngördüğü son adım, Berkcan'ın kendi bilgisayarında, sabit ortamda ve temiz bir oturumda `tez_nihai` kimliğiyle yapacağı son çalıştırmadır. Bu oturumdaki `sekil_04` çalıştırması, aynı sabit ortamda yapılmış tam bir KABUL çalıştırmasıdır, ama bir yapay zekâ aracının geçici bulut ortamında yapılmıştır.
3. Bu blokta da bağımsız ajan gözden geçirmesi yapmadım. Bağımsız gözden geçirme yalnız AS1 bloğu için yapıldı.

## Dosyalar

- `berkcan_dass42_analiz.R`: dokuz bloğun hepsi doldurulmuş şablon (KABUL, 279/279).
- `ciktilar_sekil_04/`: son tam çalıştırmanın bütün çıktıları. İçinde 21 tablo, 2 şekil, `kabul_raporu.csv`, `calistirma_durumu.json`, `dosya_ozetleri.csv`, `oturum_bilgisi.txt` ve `karsilastirma_ref06.txt` vardır.
- `karsilastir_ref06.R`: `tablo_*`, `ek_*` ve `tum_alt_kumeler.csv` dosyalarını başvuru çıktısıyla karşılaştıran betik.
- Blok belgeleri: `AS1_...`, `AS2_...`, `AS3_...`, `ALT_KUME_...`, `BOOTSTRAP_...`, `AS4_...`, `AS5_...`, `EK_ANALIZLER_...` ve bu belge.
