# Formül kataloğu: onay sayfası

Bu sayfa `formulas.expected.json` dosyasından otomatik üretilmiştir ve yalnızca okumayı kolaylaştırmak içindir; onaylanacak olan JSON dosyasıdır. Her formül SPEC.md'den harfiyen kopyalanmıştır (TeX, KaTeX 0.18.9 ile hatasız işlendi). Uygulamadaki her formül, test B11 gereği buradaki TeX ile karakter düzeyinde aynı olmak zorundadır.

Onay için bakılacak üç şey: (1) listede eksik veya fazla formül var mı, (2) bir formülün hangi modülde ve kartta gösterileceği doğru mu, (3) en altta "Öneriler" bölümündeki, SPEC'te TeX'i verilmemiş 17 formülden hangileri kataloğa alınmalı.

## ortak (7)

- `ortak.payda_n_eksi_1` (Gösterim: payda kuralı, satır 47): $s^2=\frac{1}{n-1}\sum(\cdot)^2$
- `ortak.payda_n` (Gösterim: payda kuralı, satır 47): $\hat\sigma^2=\frac{1}{n}\sum(\cdot)^2$
- `ortak.toplam_puan` (Gösterim: toplam puan, satır 48): $Y_p=\sum_i X_{pi}$
- `ortak.butce_hata_kestirimi` (Varyans bütçesi (gerçek dünya, kestirilen hata varyansı), satır 112): $s^2_{X_1}-s_{X_1X_2}$
- `ortak.butce_toplam_gercek_varyans` (Varyans bütçesi (M7-M8 bölütü), satır 114): $k^2\bar s_{ij}$
- `ortak.butce_madde_m9` (Varyans bütçesi (M9 bölütü), satır 114): $\sigma_i^2/n_i'$
- `ortak.butce_artik_m9` (Varyans bütçesi (M9 bölütü), satır 114): $\sigma^2_{pi,e}/n_i'$

## M1 (3)

- `m1.varyans` (Formüller, satır 132): $s_X^2=\frac{1}{n-1}\sum_p (X_p-\bar X)^2$
- `m1.kovaryans` (Formüller, satır 132): $s_{X_1X_2}=\frac{1}{n-1}\sum_p (X_{1p}-\bar X_1)(X_{2p}-\bar X_2)$
- `m1.korelasyon` (Formüller, satır 132): $r=\dfrac{s_{X_1X_2}}{s_{X_1}s_{X_2}}=\dfrac{1}{n-1}\sum_p z_{1p}z_{2p}$

## M2 (12)

- `m2.baslik` (Modül başlığı, satır 137): $X=T+E$
- `m2.sembol_toplam` (Semboller kartı, satır 139): $\sum$
- `m2.sembol_ortalama` (Semboller kartı, satır 139): $\bar X$
- `m2.sembol_olcme` (Semboller kartı, satır 139): $X_{pj}$
- `m2.sembol_madde` (Semboller kartı, satır 139): $X_{pi}$
- `m2.sembol_beklenen_deger` (Semboller kartı, satır 139): $\mathbb E$
- `m2.sembol_tanim_geregi` (Semboller kartı, satır 139): $\equiv$
- `m2.sembol_kisi_icin` (Semboller kartı, satır 139): $\mid p$
- `m2.model` (Formül, satır 141): $X_{pj}=T_p+E_{pj}$
- `m2.gercek_puan` (Formül, satır 141): $T_p\equiv\mathbb E_j(X_{pj})$
- `m2.hata_ortalamasi` (Formül, satır 141): $\mathbb E(E_{pj}\mid p)=0$
- `m2.artik` (Kontrol sorusu yanıtı (kestirilmiş artık), satır 143): $\hat E_j=X_j-\hat T$

## M3 (4)

- `m3.varyans_ayrisimi` (Formüller, satır 149): $\sigma_X^2=\sigma_T^2+\sigma_E^2+2\sigma_{TE}$
- `m3.rho_oran` (Formüller, satır 149): $\rho_{XX'}=\dfrac{\sigma_T^2}{\sigma_X^2}=1-\dfrac{\sigma_E^2}{\sigma_X^2}=\rho_{XT}^2$
- `m3.osh` (Formüller, satır 149): $\text{ÖSH}=\sigma_E=\sigma_X\sqrt{1-\rho_{XX'}}$
- `m3.grup_turdesligi` (Formüller (grup türdeşliği), satır 149): $\rho_{\text{yeni}}=1-\dfrac{\sigma_X^2(1-\rho_{XX'})}{\sigma_{X,\text{yeni}}^2}$

## M4 (13)

- `m4.model` (Model, satır 158): $X_{pj}=\eta_p+c+B_p+\gamma g_p+E_{pj}$
- `m4.sistematik_bilesen` (Model, satır 158): $U_p=c+B_p+\gamma g_p$
- `m4.ktk_gercek_puan` (Model, satır 158): $T_p=\eta_p+U_p$
- `m4.tavan` (Göstergeler (yapıyla korelasyon göstergesindeki tavan), satır 160): $\sqrt{\rho_{XX'}}$
- `m4.rho` (Formüller, satır 161): $\rho_{XX'}=\dfrac{\sigma_\eta^2+\sigma_U^2+2\sigma_{\eta U}}{\sigma_\eta^2+\sigma_U^2+2\sigma_{\eta U}+\sigma_E^2}$
- `m4.rho_x_eta` (Formüller, satır 161): $\rho_{X\eta}=\dfrac{\sigma_\eta^2+\sigma_{\eta U}}{\sigma_X\,\sigma_\eta}$
- `m4.sabit_cebir` (Sabit için cebir kartı, satır 161): $(X_p+c)-(\bar X+c)=X_p-\bar X$
- `m4.dogrusal_donusum` (Formüller (doğrusal dönüşüm), satır 161): $X^*=a+wX$
- `m4.osh_dogrusal` (Formüller (doğrusal dönüşüm), satır 161): $\text{ÖSH}^*=|w|\,\text{ÖSH}$
- `m4.tavan_esitsizligi` (Formüller (uzman), satır 161): $\rho_{XY}\le\sqrt{\rho_{XX'}\rho_{YY'}}$
- `m4.zayiflama_duzeltmesi` (Formüller (uzman), satır 161): $\rho_{T_XT_Y}=\rho_{XY}/\sqrt{\rho_{XX'}\rho_{YY'}}$
- `m4.orantili_hata_ornegi` (TGA senaryosu 2, satır 164): $X^*=1{,}1X$
- `m4.yanlilik_dusurme_kosulu` (TGA senaryosu 7 (uzman), satır 169): $\sigma_U^2+2\sigma_{\eta U}<0$

## M5 (12)

- `m5.esit_olmayan_hata_r` (Etkileşim (d): eşit olmayan hata varyansları, satır 185): $r=\sqrt{\rho_1\rho_2}$
- `m5.osh_bandi` (Etkileşim (e): ÖSH bandı, satır 186): $X\pm1{,}96\,\text{ÖSH}$
- `m5.fark` (Formüller, satır 188): $D_p=X_{1p}-X_{2p}=(T_{1p}-T_{2p})+(E_{1p}-E_{2p})$
- `m5.fark_varyansi_tau` (Formüller, satır 189): $\sigma_D^2=\sigma^2_{E_1}+\sigma^2_{E_2}$
- `m5.fark_varyansi_paralel` (Formüller, satır 189): $\sigma_D^2=2\sigma_E^2$
- `m5.hata_fark_yolu` (Formüller, satır 189): $\hat\sigma_E^2=\tfrac12 s_D^2$
- `m5.kovaryans` (Formüller, satır 190): $\sigma_{X_1X_2}=\sigma_T^2+\sigma_{TE_2}+\sigma_{E_1T}+\sigma_{E_1E_2}=\sigma_T^2$
- `m5.hata_kovaryans_yolu` (Formüller, satır 190): $\hat\sigma_E^2=s_X^2(1-r_{12})$
- `m5.kelley` (Formüller (uzman: Kelley kestirimi), satır 191): $\hat T=\rho X+(1-\rho)\mu_X$
- `m5.uc_standart_hata` (Formüller (uzman: üç standart hata), satır 191): $\text{ölçme: }\sigma_X\sqrt{1-\rho},\ \ \text{kestirim: }\sigma_X\sqrt{\rho(1-\rho)},\ \ \text{yordama: }\sigma_X\sqrt{1-\rho^2}$
- `m5.kosullu_osh` (Formüller (uzman: koşullu ÖSH), satır 192): $\text{ÖSH}(x)=\sqrt{x(k-x)/(k-1)}$
- `m5.binom_hata_varyansi` (Koşullu ÖSH kartının notu, satır 192): $k\zeta(1-\zeta)$

## M6 (3)

- `m6.rho_tekrar` (Formüller (uzman katmanı), satır 202): $\rho_{\text{tekrar}}=\frac{\sigma_p^2+\sigma_{pi}^2/k}{\sigma_p^2+\sigma_{pi}^2/k+\sigma_{po}^2+\sigma_e^2/k}$
- `m6.rho_esdeger` (Formüller (uzman katmanı), satır 202): $\rho_{\text{eşdeğer}}=\frac{\sigma_p^2+\sigma_{po}^2}{\sigma_p^2+\sigma_{po}^2+(\sigma_{pi}^2+\sigma_e^2)/k}$
- `m6.rho_gecikmeli_esdeger` (Formüller (uzman katmanı), satır 203): $\rho_{\text{gecikmeli eşdeğer}}=\frac{\sigma_p^2}{\sigma_p^2+\sigma_{po}^2+(\sigma_{pi}^2+\sigma_e^2)/k}$

## M7 (18)

- `m7.kr20_pq_duzeltmesi` (KR-20 kartı (payda anahtarı n-1 konumunda), satır 73): $p_iq_i\cdot n/(n-1)$
- `m7.r_sapma` (Sekme 1: r (test-tekrar test / eşdeğer formlar), satır 212): $r=\dfrac{\sum x_1x_2}{\sqrt{\sum x_1^2\sum x_2^2}}$
- `m7.sapma` (Sekme 1: r (test-tekrar test / eşdeğer formlar), satır 212): $x=X-\bar X$
- `m7.fr_ortalama_k_tek` (Yarıya bölme gezgini (uzman notu, k tek), satır 218): $\alpha\,(k^2-1)/k^2$
- `m7.madde_varyansi_egrisi` (Madde güçlüğü paneli, satır 218): $p(1-p)$
- `m7.sb` (Formüller, satır 220): $\rho_m=\dfrac{m\rho}{1+(m-1)\rho}$
- `m7.sb_carpan` (Formüller, satır 220): $m=\dfrac{\rho^*(1-\rho)}{\rho(1-\rho^*)}$
- `m7.sb_yarilar` (Formüller (yarılar), satır 221): $\rho_{SB}=\dfrac{2r_{hh}}{1+r_{hh}}$
- `m7.flanagan_rulon` (Formüller (yarılar), satır 221): $2\left(1-\dfrac{s_A^2+s_B^2}{s_Y^2}\right)$
- `m7.rulon` (Formüller (yarılar), satır 221): $1-\dfrac{s_D^2}{s_Y^2}$
- `m7.rulon_fark` (Formüller (yarılar), satır 221): $D=A-B$
- `m7.alpha` (Formüller, satır 222): $\hat\alpha=\dfrac{k}{k-1}\left(1-\dfrac{\sum_i s_i^2}{s_Y^2}\right)$
- `m7.toplam_varyans_n` (Formüller (KR-20 paydası), satır 222): $\hat\sigma_Y^2=\frac1n\sum_p(Y_p-\bar Y)^2$
- `m7.kr20` (Formüller, satır 222): $\text{KR-20}=\dfrac{k}{k-1}\left(1-\dfrac{\sum_i p_iq_i}{\hat\sigma_Y^2}\right)$
- `m7.kr21` (Formüller (uzman), satır 222): $\text{KR-21}=\dfrac{k}{k-1}\left(1-\dfrac{M(k-M)}{k\,\hat\sigma_Y^2}\right)$
- `m7.osh_orneklem` (Formüller, satır 222): $s_Y\sqrt{1-\hat\alpha}$
- `m7.max_rphi` (Formüller (uzman), satır 223): $\max r_\varphi=\sqrt{\dfrac{p_i(1-p_j)}{p_j(1-p_i)}}$
- `m7.max_rphi_kosulu` (Formüller (uzman), satır 223): $p_i\le p_j$

## M8 (17)

- `m8.iki_blok_orani` (Uzman katmanı (iki blok modu), satır 230): $\mathbf 1^{\mathsf T}\Sigma_T\mathbf 1/\mathbf 1^{\mathsf T}\Sigma\mathbf 1$
- `m8.psi_varsayilan` (Uzman katmanı, satır 230): $\psi_i=1-\lambda_i^2$
- `m8.psi_siniri` (Uzman katmanı (Cholesky denetimi), satır 230): $|\psi_{ij}|\le0{,}9\sqrt{\psi_i\psi_j}$
- `m8.toplam_varyans` (Formüller, satır 232): $\sigma_Y^2=\mathbf 1^{\mathsf T}\Sigma\mathbf 1=\operatorname{tr}(\Sigma)+\sum_{i\neq j}\sigma_{ij}$
- `m8.alpha` (Formüller, satır 232): $\alpha=\frac{k}{k-1}\left(1-\frac{\operatorname{tr}\Sigma}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}\right)=\frac{k^2\bar\sigma_{ij}}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}$
- `m8.turetme_ortalama_kovaryans` (Üç satırlık türetme kartı, satır 233): $\bar\sigma_{ij}=\sum_{i\neq j}\sigma_{ij}/[k(k-1)]$
- `m8.turetme_gercek_varyans` (Üç satırlık türetme kartı, satır 233): $\approx k^2\bar\sigma_{ij}$
- `m8.turetme_alpha` (Üç satırlık türetme kartı, satır 233): $\alpha=k^2\bar\sigma_{ij}/\sigma_Y^2$
- `m8.sigma_ayrisimi` (Formüller, satır 234): $\Sigma=\Sigma_T+\Sigma_E$
- `m8.hata_matrisi` (Formüller, satır 234): $\Sigma_E=\Psi$
- `m8.tek_faktor` (Formüller, satır 234): $\Sigma=\lambda\lambda^{\mathsf T}+\Psi$
- `m8.omega` (Formüller, satır 234): $\omega=\dfrac{(\sum_i\lambda_i)^2}{\mathbf 1^{\mathsf T}\Sigma\mathbf 1}$
- `m8.omega_paydasi_iliskisiz` (Formüller, satır 234): $(\sum\lambda_i)^2+\sum\psi_i$
- `m8.alpha_yukler` (Formüller, satır 234): $\alpha=\dfrac{k}{k-1}\cdot\dfrac{(\sum\lambda)^2-\sum\lambda^2}{\sigma_Y^2}\le\omega$
- `m8.yuk_esitsizligi` (Formüller, satır 234): $(\sum\lambda)^2\le k\sum\lambda^2$
- `m8.alpha_std` (Formüller (standart α), satır 235): $\alpha_{std}=\dfrac{k\bar r}{1+(k-1)\bar r}$
- `m8.l2` (Formüller (Guttman), satır 235): $L_2=\dfrac{\sum_{i\neq j}\sigma_{ij}+\sqrt{\frac{k}{k-1}\sum_{i\neq j}\sigma_{ij}^2}}{\sigma_Y^2}\ge\alpha$

## M9 (31)

- `m9.model` (Formüller, satır 244): $X_{pi}=\mu+\nu_p+\nu_i+\nu_{pi,e}$
- `m9.kt_ayrisimi` (Formüller, satır 244): $KT_T=KT_p+KT_i+KT_{art}$
- `m9.kt_kisi` (Formüller, satır 244): $KT_p=k\sum_p(\bar X_{p\cdot}-\bar X)^2$
- `m9.kt_madde` (Formüller, satır 244): $KT_i=n\sum_i(\bar X_{\cdot i}-\bar X)^2$
- `m9.kt_artik` (Formüller, satır 244): $KT_{art}=\sum_p\sum_i(X_{pi}-\bar X_{p\cdot}-\bar X_{\cdot i}+\bar X)^2$
- `m9.sd_kisi` (Formüller (sd sütunu), satır 244): $n-1$
- `m9.sd_madde` (Formüller (sd sütunu), satır 244): $k-1$
- `m9.sd_artik` (Formüller (sd sütunu), satır 244): $(n-1)(k-1)$
- `m9.hoyt` (Formüller, satır 245): $r_H=1-\dfrac{KO_{art}}{KO_p}$
- `m9.kanit_toplam_varyans` (Eşdeğerlik kanıtı kartı, satır 245): $s_Y^2=k\,KO_p$
- `m9.kanit_madde_varyanslari` (Eşdeğerlik kanıtı kartı, satır 245): $\sum_i s_i^2=\dfrac{KT_p+KT_{art}}{n-1}$
- `m9.kanit_alpha_hoyt` (Eşdeğerlik kanıtı kartı, satır 245): $\hat\alpha=\dfrac{k}{k-1}\left(1-\dfrac{KT_p+KT_{art}}{k\,KT_p}\right)=1-\dfrac{KO_{art}}{KO_p}$
- `m9.beklenen_ko_kisi` (Formüller (uzman: beklenen KO), satır 246): $\mathbb E(KO_p)=\sigma^2_{pi,e}+n_i\sigma_p^2$
- `m9.beklenen_ko_madde` (Formüller (uzman: beklenen KO), satır 246): $\mathbb E(KO_i)=\sigma^2_{pi,e}+n_p\sigma_i^2$
- `m9.beklenen_ko_artik` (Formüller (uzman: beklenen KO), satır 246): $\mathbb E(KO_{art})=\sigma^2_{pi,e}$
- `m9.bilesen_kisi` (Formüller (uzman: varyans bileşenleri), satır 246): $\hat\sigma_p^2=(KO_p-KO_{art})/n_i$
- `m9.bilesen_madde` (Formüller (uzman: varyans bileşenleri), satır 246): $\hat\sigma_i^2=(KO_i-KO_{art})/n_p$
- `m9.bilesen_artik` (Formüller (uzman: varyans bileşenleri), satır 246): $\hat\sigma^2_{pi,e}=KO_{art}$
- `m9.erho2` (Formüller, satır 247): $\mathbb E\rho^2=\dfrac{\sigma_p^2}{\sigma_p^2+\sigma^2_{pi,e}/n_i'}$
- `m9.phi` (Formüller, satır 247): $\Phi=\dfrac{\sigma_p^2}{\sigma_p^2+(\sigma_i^2+\sigma^2_{pi,e})/n_i'}$
- `m9.phi_lambda` (Formüller (uzman: kesme puanı), satır 247): $\Phi(\lambda)=\dfrac{\sigma_p^2+(\mu-\lambda)^2}{\sigma_p^2+(\mu-\lambda)^2+\sigma^2_\Delta}$
- `m9.capraz_bagil_hata` (Formüller (puanlayıcılar, çaprazlanmış desen), satır 248): $\sigma^2_\delta=\sigma^2_{pr,e}/n_r'$
- `m9.capraz_mutlak_hata` (Formüller (puanlayıcılar, çaprazlanmış desen), satır 248): $\sigma^2_\Delta=(\sigma^2_r+\sigma^2_{pr,e})/n_r'$
- `m9.icice_hata` (Formüller (puanlayıcılar, iç içe desen), satır 248): $\sigma^2_\delta=\sigma^2_\Delta=\sigma^2_{r,pr,e}/n_r'$
- `m9.icice_bilesen` (Formüller (puanlayıcılar, iç içe desen), satır 248): $\sigma^2_{r,pr,e}=\sigma_r^2+\sigma^2_{pr,e}$
- `m9.icc_a_k` (Uzman ICC bağlantıları, satır 249): $=\dfrac{KO_p-KO_{art}}{KO_p+(KO_i-KO_{art})/n}$
- `m9.icc_c_1` (Uzman ICC bağlantıları, satır 249): $=\dfrac{KO_p-KO_{art}}{KO_p+(k-1)KO_{art}}$
- `m9.uc_yol_matris` (Üç yol, tek hata varyansı kartı (Sabit Veri A), satır 250): $s_Y^2-k^2\bar s_{ij}=20-16=4$
- `m9.uc_yol_anova` (Üç yol, tek hata varyansı kartı (Sabit Veri A), satır 250): $k\cdot KO_{art}=4\cdot1=4$
- `m9.uc_yol_katsayi` (Üç yol, tek hata varyansı kartı (Sabit Veri A), satır 250): $s_Y^2(1-\hat\alpha)=20\cdot0{,}2=4$
- `m9.uc_yol_kosegen` (Üç yol, tek hata varyansı kartı (Sabit Veri A), satır 250): $0{,}5+0{,}5+2{,}1+0{,}9=4$

## icerik (18)

- `icerik.a1_kosullu_hata_ortalamasi` (A.1, satır 263): $\mathbb E(E\mid p)=0$
- `icerik.a1_hata_ortalamasi` (A.1, satır 263): $\mathbb E(E)=0$
- `icerik.a1_te_kovaryansi` (A.1, satır 263): $\sigma_{TE}=0$
- `icerik.a1_varyans` (A.1, satır 263): $\sigma_X^2=\sigma_T^2+\sigma_E^2$
- `icerik.a4_ozdeslik` (A.4, satır 266): $\rho_{XX'}=\sigma_T^2/\sigma_X^2=\rho_{XT}^2$
- `icerik.a5_paralel` (A.5 (ölçme modelleri tablosu), satır 267): $T_i=\tau$
- `icerik.a5_tau_esdeger` (A.5 (ölçme modelleri tablosu), satır 267): $T_i=\tau$
- `icerik.a5_ozunde_tau_esdeger` (A.5 (ölçme modelleri tablosu), satır 267): $T_i=\tau+\beta_i$
- `icerik.a5_konjenerik` (A.5 (ölçme modelleri tablosu), satır 267): $T_i=\beta_i+\lambda_i\tau$
- `icerik.b1_yukselme_kosulu` (B.1, satır 271): $\sigma_U^2+2\sigma_{\eta U}>0$
- `icerik.c1_hata_puani` (C.1, satır 286): $E_p=X_p-T_p$
- `icerik.c1_kovaryans` (C.1, satır 286): $\sigma_{XX'}=\sigma_T^2$
- `icerik.c1_hata_varyansi` (C.1, satır 286): $\sigma_E^2=\sigma_X^2-\sigma_{XX'}$
- `icerik.c1_fark_varyansi` (C.1, satır 286): $\sigma^2_{X-X'}=2\sigma_E^2$
- `icerik.c1_artik` (C.1, satır 286): $X_j-\hat T$
- `icerik.d4_phi_erho2` (D.4, satır 294): $\Phi\le\mathbb E\rho^2$
- `icerik.d7_esitsizlik` (D.7, satır 297): $\rho_{XY}\le\sqrt{\rho_{XX'}\rho_{YY'}}\le\sqrt{\rho_{XX'}}$
- `icerik.g4_orantili_hata` (G.4 (etki haritası satırı), satır 325): $X^*=wX$

## Öneriler (SPEC'te TeX'i yok; onayınızı bekliyor)

- `m1.varyans_n` (M1, satır 132): $\hat\sigma_X^2=\frac{1}{n}\sum_p (X_p-\bar X)^2$  
  SPEC bu sürümün TeX yazımını M1 için vermez. Öneri, satır 47'deki genel biçimi (\hat\sigma^2=\frac{1}{n}\sum(\cdot)^2) m1.varyans biçimine uyarlar.
- `m1.kovaryans_n` (M1, satır 73): $\hat\sigma_{X_1X_2}=\frac{1}{n}\sum_p (X_{1p}-\bar X_1)(X_{2p}-\bar X_2)$  
  Anahtar kovaryansı da etkilediği için n paydalı kovaryansın bir yazımı gerekir; SPEC vermez.
- `m1.z_puani` (M1, satır 131): $z_{1p}=\dfrac{X_{1p}-\bar X_1}{s_{X_1}}$  
  m1.korelasyon z_{1p} kullanır, fakat z puanının tanımı SPEC'te TeX olarak yoktur. İsteğe bağlı.
- `m2.sembol_sapka` (M2, satır 139): $\hat T$  
  Semboller kartındaki yedi öğe TeX ile, şapka ise yalnızca sözle verilmiştir. Öneri M2 kontrol sorusundaki \hat T yazımını kullanır; sesli okuma "kestirim".
- `m3.rho_xt_karekok` (M3, satır 148): $\rho_{XT}=\sqrt{\rho_{XX'}}$  
  İsteğe bağlı. m3.rho_oran zinciri \rho_{XT}^2 ile aynı ilişkiyi zaten gösterir.
- `m3.hata_varyansi_egilim` (M3, satır 148): $\sigma_E^2=\mathbb E_p\left(\sigma^2_{E\mid p}\right)$  
  SPEC burada yalnızca sesli okuma verir. Öneri, gösterim tablosunda bulunmayan yeni bir sembol (\sigma^2_{E\mid p}) gerektirir; formülsüz bırakmak da mümkündür (C.2 aynı fikri sözle verir).
- `m4.icc_a_1` (M4, satır 160): $\text{ICC}(A,1)=\dfrac{KO_p-KO_{art}}{KO_p+(k-1)KO_{art}+k(KO_i-KO_{art})/n}$  
  ICC(A,1) formülü SPEC'te yoktur (McGraw ve Wong, 1996 biçimi önerildi). M5 verisinde X_2'ye +5 için 408/803 verdiği kesir aritmetiğiyle doğrulandı. Negatif bileşen 0'a çekildiğinde (KO_i<KO_{art}) (KO_i-KO_{art}) terimi 0 alınır; M5 verisinin kaydırılmamış hâlinde ICC(A,1)=17/18 sonucu ancak bu kuralla elde edilir. ICC(C,1) için m9.icc_c_1 kullanılabilir.
- `m5.ortalama_varyans` (M5, satır 181): $\bar s_X^2=(s^2_{X_1}+s^2_{X_2})/2$  
  SPEC yalnızca sayısal satırı verir; sembolik satır için öneri.
- `m5.fark_yolu_orani` (M5, satır 181): $1-\hat\sigma_E^2/\bar s_X^2$  
  Bu sembolik yazım SPEC'te yalnızca <sabit_veri> içinde (satır 404: $1-\hat\sigma_E^2/\bar s_X^2=17/18$) geçer; modül metninde yalnızca sayısal satır vardır.
- `m5.kelley_bandi` (M5, satır 295): $\hat T\pm1{,}96\,\sigma_X\sqrt{\rho(1-\rho)}$  
  Kelley bandı SPEC'te yalnızca sayısal olarak (satır 396: [13,29; 20,31]) geçer. Öneri m5.uc_standart_hata içindeki kestirimin standart hatasını kullanır; 16,8 ± 1,96·√3,2 ile sabit veriyi verir.
- `m7.alpha_madde_silinirse` (M7, satır 223): $\hat\alpha_{(-i)}=\dfrac{k-1}{k-2}\left(1-\dfrac{\sum_{j\neq i}s_j^2}{s^2_{Y-X_i}}\right)$  
  Formüller satırında adı geçer ama TeX verilmez. Öneri Sabit Veri A'da 93/127, 99/131, 9/13, 105/131 değerlerini verir (doğrulandı).
- `m7.duzeltilmis_madde_toplam_r` (M7, satır 223): $r_{X_i(Y-X_i)}=\dfrac{s_{X_iY}-s_i^2}{s_i\sqrt{s_Y^2+s_i^2-2s_{X_iY}}}$  
  Formüller satırında adı geçer ama TeX verilmez. Öneri Sabit Veri A'da 0,664; 0,609; 0,734; 0,501 değerlerini verir (doğrulandı).
- `m9.icc_c_k` (M9, satır 249): $\alpha=\text{ICC}(C,k)=\text{ICC}(3,k)$  
  Bu eşitlik SPEC'te tamamen düz metindir.
- `m9.icc_a_k_tam` (M9, satır 249): $\Phi=\text{ICC}(A,k)=\text{ICC}(2,k)=\dfrac{KO_p-KO_{art}}{KO_p+(KO_i-KO_{art})/n}$  
  SPEC'te sol taraf düz metin, sağ taraf "=" ile başlayan TeX'tir; katalogda sağ taraf m9.icc_a_k olarak aynen durur. Bu öneri tam denklemi tek TeX olarak verir. Kullanıcı hangisinin ekranda kullanılacağını seçmelidir.
- `m9.icc_c_1_tam` (M9, satır 249): $\mathbb E\rho^2(n_i'=1)=\text{ICC}(C,1)=\dfrac{KO_p-KO_{art}}{KO_p+(k-1)KO_{art}}$  
  m9.icc_a_k_tam ile aynı durum; katalogda sağ taraf m9.icc_c_1 olarak aynen durur. \mathbb E\rho^2(n_i') yazımı D.4'ten alınmıştır.
- `m9.phi_en_kucuk` (M9, satır 247): $\Phi=\min_\lambda\Phi(\lambda)=\Phi(\mu)$  
  İsteğe bağlı; SPEC'te düz metindir.
- `m9.icice_tek_yonlu_not` (M9, satır 248): $KO_{\text{içi}}=7/6,\quad \hat\sigma_p^2=23/24,\quad \mathbb E\rho^2=\Phi=\text{ICC}(1,k)=23/30\approx0{,}7667$  
  Tırnak içindeki uzman notunda TeX düz metinle parçalanmıştır ve iki biçim sorunu taşır: (1) KO_{içi} matematik kipinde Türkçe harf içerir; KaTeX 0.18.9 bunu strict uyarısıyla (unicodeTextInMathMode) konsola yazar (bu oturumda denendi), bu da B1'i bozar; öneri \text{içi} kullanır. (2) .7667 noktalı ondalıktır; arayüz kuralı (satır 74) 0{,}7667 ister. Bunlar sayısal değer ifadeleri olduğu için formül listesine alınmadı.

## Çıkarıcının notları

- Kapsam: M1-M9 Formüller satırları, modüllerde adı geçen kartlar (Semboller, Model, cebir, türetme, eşdeğerlik kanıtı, Üç yol), uzman notlarındaki formüller, gösterim bölümündeki eşitlikler (ortak.*), varyans bütçesi bölüt ifadeleri (ortak.*) ve <icerik_dogrulugu> içindeki denklem ve eşitsizlikler (icerik.*). M10 için SPEC formül vermez. <sabit_veri> ve <dogrulama> bölümlerindeki sayısal ifadeler, kontrol sorusu yanıtlarındaki değer atamaları (ör. \sigma_T^2=64, r=.84, \hat T=60) ve tek başına semboller alınmadı.
- Bölme: Tek bir $$...$$ içinde virgül ve \qquad (veya noktalı virgül ve \quad) ile ayrılmış iki ayrı formül, ayırıcı atılarak iki kayda bölündü; her parça SPEC satırının birebir alt dizesidir. Bölünenler: satır 190 (m5.kovaryans ile m5.hata_kovaryans_yolu, ayırıcı ",\qquad "), satır 191 (m5.kelley ile m5.uc_standart_hata, ayırıcı ";\quad "), satır 202 (m6.rho_tekrar ile m6.rho_esdeger, ayırıcı ",\qquad "), satır 232 (m8.toplam_varyans ile m8.alpha, ayırıcı ",\qquad "). Eşitlik zincirleri bölünmedi. Kullanıcı bölünmemiş satırı isterse bu dört kayıt birleştirilebilir.
- Sol tarafı düz metin olan kayıtlar: m9.icc_a_k ve m9.icc_c_1 "=" ile, m8.turetme_gercek_varyans "\approx" ile başlar; m7.flanagan_rulon ve m7.rulon sol taraf taşımaz (ad düz metindedir). TeX SPEC'ten aynen alındı; tam denklem önerileri _uncatalogued içindedir.
- Yinelenen TeX tek kayıtta tutuldu: X^*=a+wX (satır 57, 88, 161, 270) m4.dogrusal_donusum; U_p=c+B_p+\gamma g_p (satır 60, 158) m4.sistematik_bilesen; k\zeta(1-\zeta) (satır 192, 265) m5.binom_hata_varyansi; X\pm1{,}96\,\text{ÖSH} (satır 186, 295) m5.osh_bandi; \alpha\,(k^2-1)/k^2 (satır 218, 292) m7.fr_ortalama_k_tek; \sqrt{\rho_{XX'}} (satır 160, 297) m4.tavan. A.5'teki paralel ve tau eşdeğer satırlarının ikisi de T_i=\tau yazdığı için iki ayrı kimlikle aynı TeX'i taşır.
- Y9 (satır 310) ÖSH bandını "$X\pm1{,}96\,$ÖSH" biçiminde, ÖSH'yi TeX dışında yazar. M10 metninde m5.osh_bandi kullanılması önerilir.
- Hata türleri tablosu (M4 açılış kartı) ve etki haritası satır adlarındaki satır içi matematik ($c$, $B_p$, $\gamma g_p$, $\lvert w\rvert$, $c>0$, $w>1$, $B\perp\eta$, $\gamma>0$, $g\perp\eta$) koşul veya tek sembol olduğu için alınmadı; yalnızca denklem olan X^*=wX (G.4) icerik.g4_orantili_hata olarak alındı. Tablo ÖSH için $\lvert w\rvert$, M4 formülü (m4.osh_dogrusal) $|w|$ yazar; ikisi farklı TeX'tir.
- M3 formülündeki $2\sigma_{TE}$ terimi "üstü çizili gösterilir". B11 yalnızca \htmlClass sarmalayıcılarını indirger; üstü çizme \cancel veya \sout ile yapılırsa TeX m3.varyans_ayrisimi ile eşleşmez. Öneri: çizgiyi \htmlClass{t-...}{2\sigma_{TE}} ve CSS ile vermek. Kullanıcı onayı gerekir.
- Sesli okumalar: SPEC yalnızca M2 Semboller kartındaki yedi sembol ve ortak öğe 3'teki örnek ("Güvenirlik, gerçek puan varyansının gözlenen puan varyansına oranıdır", satır 116) için okuma verir. Bu örnek m3.rho_oran'a bağlandı; yalnızca zincirin ilk eşitliğini okur. Gösterim tablosu (satır 65) \mathbb E\rho^2 sembolü için "G katsayısı" okumasını verir; m9.erho2'nin okuması boş bırakıldı. Ortak öğe 3'e göre her formülün bir Türkçe sesli okuması olmalıdır; boş olanlar Aşama 1 veya sonrasında yazılıp CLAIMS.md'ye bağlanacaktır.
- M2 Semboller kartındaki yedi öğe tek başına sembol olduğu hâlde, SPEC bunları bir modül kartında sesli okumalarıyla birlikte verdiği için bilerek kataloğa alındı (m2.sembol_*).
- Gösterim bölümündeki eşitlikler (satır 47 payda kuralı, satır 48 toplam puan) ortak.* önekiyle alındı; bunlar ayrı bir kart değildir, n / n-1 anahtarı ve Hesap Tezgâhı etiketleri için adaydır.
- Gösterim çelişkileri (spec soruları): (1) λ hem faktör yükü (M8, \lambda_i) hem kesme puanı (M9, \Phi(\lambda)) için kullanılır; gösterim kuralı "Bir sembol arayüzde tek anlam taşır" der. (2) r hem korelasyon hem puanlayıcı (p\times r, n_r', \sigma^2_{pr,e}) için kullanılır. (3) M9 KT formüllerinde kişi ve madde sayısı n ve k iken beklenen KO ve bileşen formüllerinde n_p ve n_i'dir. (4) m9.icc_a_k ve m4 ICC(A,1) için negatif bileşenin 0'a çekilmesi formülün kendisinde görünmez.
- Noktalı ondalık: SPEC in bazı TeX parçaları nokta kullanır (ör. satır 165 \sqrt{.75}\approx.87, satır 195 r=.84, satır 223 p=.2, .8 ve .25, satır 224 p=.5 (M7 uzman madde güçlüğü notunun tırnak içindeki metni), satır 248 .7667; liste SPEC satır 44-335 için taranmıştır ve eksiksizdir). Katalogdaki formüllerde noktalı ondalık yoktur (betikle denetlendi); bu parçalar ekranda gösterilecekse satır 74'e göre 0{,}75 biçimine çevrilmelidir.
- L_1 (Guttman) değeri yalnızca <sabit_veri> ve A3'te geçer; hiçbir modül onu gösterilecek bir formül olarak anmaz. Bu yüzden kataloğa ve _uncatalogued'a alınmadı.
- Ortak öğe 5'teki $E=\sigma_E z$ ve ortak öğe 4'teki $|\Delta|<0{,}005$ uygulama kuralıdır; öğrenciye gösterilen formül sayılmadı.
- display alanı: $$...$$ parçaları ve modüllerin Formüller satırlarındaki ya da adlandırılmış kartlardaki ana formüller true; cümle içi ifadeler, koşullar, semboller ve <icerik_dogrulugu> kayıtları false. Bu alan yalnızca KaTeX displayMode denetimi içindir.
- Çapraz denetim (2026-09-26): Kataloğa m2.artik eklendi. \hat E_j=X_j-\hat T, M2 kontrol yanıtındaki zincirin (satır 143) sembolik başıdır ve birebir alt dizedir; artık tanımı M2 kazanımının (Y4) merkezinde olduğu hâlde başka bir M2 formülünde geçmez. m9.icice_bilesen ikiye ayrıldı: katalogda sembolik kısım (\sigma^2_{r,pr,e}=\sigma_r^2+\sigma^2_{pr,e}) kalır; Sabit Veri A değerini taşıyan tam yazım (=7/6) m9.icice_bilesen_sayisal olarak _sayisal_satir_adaylari içine taşındı, çünkü M9 simülasyon modunda veya başka veriyle bu değer 7/6 olmaz. Bir betik SPEC satır 44-335 arasındaki her $...$ ve $$...$$ parçasını kataloğa karşı taradı; kalan kapsanmayan parçalar tek sembol, koşul, uygulama kuralı, kontrol sorusu değeri veya not edilmiş noktalı ondalıklı sayı satırıdır.
- Üç yol kartı (m9.uc_yol_*): dört kayıt Sabit Veri A sayılarını TeX içinde taşır; m9.uc_yol_kosegen (0{,}5+0{,}5+2{,}1+0{,}9=4) hiç sembol içermez. Kart SPEC'te Sabit Veri A'ya bağlı durağan bir kart olduğu için katalogda bırakıldı. Kart Sözle / Sembolle / Sayılarla düzeninde kurulursa sembolik satırlar birebir önek olarak şunlardır: s_Y^2-k^2\bar s_{ij}, k\cdot KO_{art}, s_Y^2(1-\hat\alpha); köşegen yolunun SPEC'te sembolik yazımı yoktur. Ayrıca A1 (satır 445) ANOVA yolunu k\,KO_{art} diye, satır 250 ise k\cdot KO_{art} diye yazar; ikisi farklı TeX'tir. Kullanıcı kartın biçimini onaylamalıdır.
- Aynı sembolün farklı TeX sırası: \sigma^2_D (satır 49) ile \sigma_D^2 (satır 189), \hat\sigma^2_Y (satır 73) ile \hat\sigma_Y^2 (satır 222), \hat\sigma^2_E (satır 73) ile \hat\sigma_E^2 (satır 189-190). Görüntü aynıdır, ancak B11 karakter düzeyinde karşılaştırdığı için content.tr.js bu kataloğun yazımını kopyalamalıdır, gösterim bölümündeki yazımı değil.
- m2.artiklar_sayisal sabit Ayşe verisine dayanan bir kontrol yanıtıdır ve payda anahtarıyla değişmez; yanıt TeX olarak gösterilecekse değişmeden formulas listesine taşınabilir.
