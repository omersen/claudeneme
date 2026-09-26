# Güvenirlik Laboratuvarı: kullanım notu

Bu klasör, istatistik altyapısı olmayan ölçme ve değerlendirme öğrencileri için etkileşimli bir güvenirlik öğrenme ortamının yapım şartnamesini içerir. `SPEC.md`, Claude Code'un uygulamayı yaparken tek doğruluk kaynağı olarak kullanacağı metindir. Şartname dört uzman ajanın (psikometri, öğrenme tasarımı, araştırma deseni, prompt mühendisliği) raporlarından üretildi, üç eleştirmen tarafından denetlendi ve revize edildi. `<sabit_veri>` bölümündeki sayılar kesirli aritmetikle ayrıca bağımsız olarak yeniden hesaplandı ve eşleşti.

## Nasıl başlatılır

1. Başlamadan önce `SPEC.md` içindeki `<gosterim_ve_sozluk>` bölümünde yer alan hata türleri tablosunu derste kullandığınız ders kitabının tanımlarıyla karşılaştırın. Türkçe ders notlarında "sabit" ve "sistematik" hata tanımları tutarsız olabiliyor. Farklılık varsa önce `SPEC.md` dosyasını düzeltin.
2. Şartname şu an `claude/lucid-pasteur-reqzhm` dalında. Yeni bir cloud oturumu varsayılan dalı klonlar. Bu yüzden ya bu dalı ana dala birleştirin ya da yeni oturumu başlatırken bu dalı seçin.
3. Yeni oturuma şu mesajı gönderin: "`guvenirlik-lab/SPEC.md` dosyasını oku; bu projenin şartnamesi odur. Aşama 0'ı uygula ve dur."
4. Yapım altı aşamada ilerler (0, 1, 2, 3, 4, 5a, 5b). "DUR" yazan noktalarda ajan onayınızı bekler. Aşama 0'da hiç kod yazılmaz; ajan planı ve `formulas.expected.json` dosyasını onayınıza sunar. İlk görünür sürüm Aşama 2'de Artifact olarak yayınlanır.

Sınırlılıklar: Şartname yaklaşık 12.700 sözcük uzunluğunda. Bu uzunluk içerik doğruluğu için bilinçli bir tercih, ama ajanın her ayrıntıya uyacağının garantisi değil. Bu yüzden aşama sonlarındaki test raporlarını ve `CLAIMS.md` dosyasını kontrol etmeniz gerekir. Toplam süre ve maliyet önceden kestirilemez.

## Makale planı

En güçlü iki tasarım şunlardır.

(1) Güvenirliğe özgü, iki veya üç aşamalı bir kavram envanterinin geliştirilmesi ve geçerlenmesi. Türkiye'de yakın çalışmalar vardır. Gürbüz (2023) ölçme araçlarının nitelikleri üzerine 22 maddelik üç aşamalı bir tanı testi geliştirmiş ve öğretmen adaylarının %70,5'inde "ölçmede hata" yanılgısı bulmuştur. Demirbilek (2015) iki aşamalı bir test kullanmıştır. Bu yüzden katkı şunlarla gösterilmelidir: S1-S3 ve Y1-Y16'ya dayalı bir madde planı, ayrı bir hesaplama alt ölçeği, çok merkezli örneklem, MTK veya DFA ile yapı kanıtı, DMF analizi ve test-tekrar test verisi (EPOD, IJATE, EMIP).

(2) Aynı içerik dosyasından üretilen etkileşimli ve durağan sürümlerin, öğrenci düzeyinde rastgele atamayla karşılaştırılması. Tercihen sunum × TGA 2×2 deseni, ön test kovaryatı, gecikmeli son test ve bilişsel yük ölçümü kullanılır. d = 0,30 için ön testle birlikte yaklaşık 260 katılımcı gerekir. Zhao ve arkadaşları (2023) etkileşimli görsellerin öğrenme üstünlüğü sağladığını bulamamıştır. Bu yüzden ön kayıt, en küçük ilgili etki (d = 0,20) ve TOST veya Bayes faktörü kullanılmalı; böylece sıfır sonuç da bilgi verir (Educational Assessment, EMIP, JSDSE).

Yapım sırasında tutulan PROGRESS.md, LLM ile yapılmış simülasyonun uzman denetimini konu alan hızlı bir üçüncü makaleye veri sağlar; ancak bu katkı çabuk eskir.

Sınırlılıklar: Yenilik iddiası sistematik bir taramayla sınanmadı. Öğretim elemanının aynı zamanda araştırmacı olması ve yenilik etkisi kontrol edilmeli. Olay kaydı için etik kurul onayı ve KVKK uyumu gerekir. Artifact bağlantısının hesap gerektirmeden açıldığı doğrulanmadı.

## Literatür notları

Yakın Türkçe çalışmalar YÖK Ulusal Tez Merkezi'nde doğrulandı: Gürbüz (2023, Kocaeli Üniversitesi, tez no. 805455), Demirbilek (2015, Hacettepe Üniversitesi, tez no. 394820), Alan (2021, Hasan Kalyoncu Üniversitesi, tez no. 673891), Üztemur (2013, Celal Bayar Üniversitesi, tez no. 331698) ve Arık (2006, Ankara Üniversitesi, tez no. 204595). Etkileşimliliğin yararına ilişkin kanıtlar karışık. Zhao ve arkadaşları (2023) etkileşimli görsellerin daha uzun öğrenme süresine yol açtığını ama performansı artırmadığını, birden çok etkileşimli temsilin performansı düşürdüğünü, öğrencilerin ise yine de etkileşimli sürümü tercih ettiğini bildiriyor (https://eric.ed.gov/?id=EJ1374193). Zapata-Rivera, Zwick ve Vezzu (2016), ölçme hatası konulu bir öğretici materyalin, öğretmenlerin puan raporlarını anlamasına yardımcı olduğunu buldu (https://doi.org/10.1080/10627197.2016.1202110). Güvenirlik için gerçek puanı gösteren etkileşimli bir öğretim simülasyonuna genel web aramasında rastlanmadı. Ancak bu arama sistematik değildi. Yenilik iddiasında bulunmadan önce ERIC, PsycINFO, Scopus, WoS, TR Dizin ve DergiPark taranmalıdır.

## Kaynaklar

"(dogrulanmali)" etiketli künyeler yayın öncesi kontrol edilmelidir. Klasik kitaplar bilgiye dayanarak listelendi; bu oturumda tek tek yeniden doğrulanmadı.

- AERA, APA, & NCME. (2014). Standards for educational and psychological testing. American Educational Research Association.
- Baykul, Y. Eğitimde ve psikolojide ölçme: Klasik test teorisi ve uygulaması. Pegem Akademi. (dogrulanmali: baskı yılı)
- Ben-Zion, Y., Carroll, T. K., West, C. G., Wong, J., & Finkelstein, N. D. (2026). Leveraging generative artificial intelligence for simulation-based physics experiments: A new approach to virtual learning about the real world. Physical Review Physics Education Research, 22, 010109. https://doi.org/10.1103/s8dy-kqy5
- Brennan, R. L. (2001a). Generalizability theory. Springer.
- Brennan, R. L. (2001b). An essay on the history and future of reliability from the perspective of replications. Journal of Educational Measurement, 38(4), 295-317.
- Brennan, R. L., & Kane, M. T. (1977). An index of dependability for mastery tests. Journal of Educational Measurement, 14(3), 277-289. https://doi.org/10.1111/j.1745-3984.1977.tb00045.x
- Brown, W. (1910). Some experimental results in the correlation of mental abilities. British Journal of Psychology, 3, 296-322.
- Chernikova, O., Heitzmann, N., Stadler, M., Holzberger, D., Seidel, T., & Fischer, F. (2020). Simulation-based learning in higher education: A meta-analysis. Review of Educational Research, 90(4), 499-541. https://doi.org/10.3102/0034654320933544 (dogrulanmali: cilt ve sayfa)
- Crocker, L., & Algina, J. (1986). Introduction to classical and modern test theory. Holt, Rinehart and Winston.
- Cronbach, L. J. (1951). Coefficient alpha and the internal structure of tests. Psychometrika, 16(3), 297-334.
- Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). The dependability of behavioral measurements. Wiley.
- Demirbilek, S. (2015). Öğretmen adaylarının eğitimde ölçme ve değerlendirme dersindeki kavram yanılgılarının incelenmesi (Tez No. 394820) [Yüksek lisans tezi, Hacettepe Üniversitesi]. Ulusal Tez Merkezi.
- Dudek, F. J. (1979). The continuing misinterpretation of the standard error of measurement. Psychological Bulletin, 86(2), 335-337.
- Gulliksen, H. (1950). Theory of mental tests. Wiley.
- Gürbüz, S. (2023). Öğretmen adaylarının ölçme araçlarının nitelikleri konusuna yönelik kavram yanılgılarının belirlenmesi (Tez No. 805455) [Yüksek lisans tezi, Kocaeli Üniversitesi]. Ulusal Tez Merkezi.
- Guttman, L. (1945). A basis for analyzing test-retest reliability. Psychometrika, 10(4), 255-282.
- Hoyt, C. (1941). Test reliability estimated by analysis of variance. Psychometrika, 6(3), 153-160.
- Kelley, T. L. (1927). Interpretation of educational measurements. World Book. (dogrulanmali: Kelley kestirimi için hangi kaynağın, 1927 mi 1947 mi, gösterileceği)
- Kuder, G. F., & Richardson, M. W. (1937). The theory of the estimation of test reliability. Psychometrika, 2(3), 151-160.
- Lance, C. E., Butts, M. M., & Michels, L. C. (2006). The sources of four commonly reported cutoff criteria: What did they really say? Organizational Research Methods, 9(2), 202-220. https://doi.org/10.1177/1094428105284919
- Loevinger, J. (1954). The attenuation paradox in test theory. Psychological Bulletin, 51, 493-504.
- Lord, F. M. (1952). The relation of the reliability of multiple-choice tests to the distribution of item difficulties. Psychometrika, 17, 181-194.
- Lord, F. M., & Novick, M. R. (1968). Statistical theories of mental test scores. Addison-Wesley.
- McDonald, R. P. (1999). Test theory: A unified treatment. Erlbaum.
- McGraw, K. O., & Wong, S. P. (1996). Forming inferences about some intraclass correlation coefficients. Psychological Methods, 1(1), 30-46. https://doi.org/10.1037/1082-989X.1.1.30
- McNeish, D. (2018). Thanks coefficient alpha, we'll take it from here. Psychological Methods, 23(3), 412-433.
- Messick, S. (1989). Validity. In R. L. Linn (Ed.), Educational measurement (3rd ed., pp. 13-103). American Council on Education/Macmillan.
- Novick, M. R., & Lewis, C. (1967). Coefficient alpha and the reliability of composite measurements. Psychometrika, 32(1), 1-13.
- Nunnally, J. C. (1978). Psychometric theory (2nd ed.). McGraw-Hill.
- Raykov, T. (2001). Bias of coefficient alpha for fixed congeneric measures with correlated errors. Applied Psychological Measurement, 25(1), 69-76.
- Rulon, P. J. (1939). A simplified procedure for determining the reliability of a test by split-halves. Harvard Educational Review, 9, 99-103.
- Schmidt, F. L., Le, H., & Ilies, R. (2003). Beyond alpha: An empirical examination of the effects of different sources of measurement error on reliability estimates for measures of individual-differences constructs. Psychological Methods, 8(2), 206-224.
- Shavelson, R. J., & Webb, N. M. (1991). Generalizability theory: A primer. Sage.
- Shrout, P. E., & Fleiss, J. L. (1979). Intraclass correlations: Uses in assessing rater reliability. Psychological Bulletin, 86(2), 420-428.
- Sijtsma, K. (2009). On the use, the misuse, and the very limited usefulness of Cronbach's alpha. Psychometrika, 74(1), 107-120.
- Spearman, C. (1904). The proof and measurement of association between two things. American Journal of Psychology, 15, 72-101.
- Spearman, C. (1910). Correlation calculated from faulty data. British Journal of Psychology, 3, 271-295.
- Thompson, B., & Vacha-Haase, T. (2000). Psychometrics is datametrics: The test is not reliable. Educational and Psychological Measurement, 60(2), 174-195.
- Zapata-Rivera, D., Zwick, R., & Vezzu, M. (2016). Exploring the effectiveness of a measurement error tutorial in helping teachers understand score report results. Educational Assessment, 21(3), 215-229. https://doi.org/10.1080/10627197.2016.1202110
- Zhao, F., Schützler, L., Christ, O., & Gaschler, R. (2023). Learning statistics with interactive pictures using R Shiny: Generally preferred, but not generally advantageous. Teaching Statistics. https://doi.org/10.1111/test.12324 (dogrulanmali: cilt, sayfa ve çevrimiçi yayın yılı 2022 mi)
