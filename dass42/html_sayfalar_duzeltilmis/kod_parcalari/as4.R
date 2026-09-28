# ---- AS4: anlamsal çeşitlilik (SB) ve temsil (CL) -------------------------------------
as4_tablo <- yuzdelik[, c("form", "subscale", "SB", "SB_yzd", "CL", "CL_yzd")]
sb_cl <- data.frame(subscale = alt_boyutlar,
                    rho_SB_CL = sapply(alt_boyutlar, function(f) spearman(alt_kume[[f]]$SB, alt_kume[[f]]$CL)))
temsil <- do.call(rbind, lapply(kisa_formlar, function(form) do.call(rbind, lapply(alt_boyutlar, function(f) {
  S <- formlar[[form]][[f]]; elenen <- setdiff(formlar$FULL42[[f]], S)
  en_yakin <- sapply(elenen, function(e) S[which.max(C[e, S])])          # elenen maddeye en yakın seçili madde
  uzaklik <- 1 - C[cbind(elenen, en_yakin)]
  data.frame(form = form, subscale = f, elenen = elenen, en_yakin = unname(en_yakin), uzaklik = uzaklik,
             en_zayif = uzaklik == max(uzaklik),
             elenen_metin = maddeler$text[match(elenen, maddeler$item_id)],
             en_yakin_metin = maddeler$text[match(en_yakin, maddeler$item_id)])
}))))
rownames(temsil) <- NULL
# Denetim: CL = elenen yedi maddenin uzaklıklarının toplamı / 14 (seçili maddeler sıfırla katılır)
stopifnot(all(abs(tapply(temsil$uzaklik, paste(temsil$form, temsil$subscale), sum)[paste(as4_tablo$form, as4_tablo$subscale)] / 14 -
                  as4_tablo$CL) < 1e-12))
print(as4_tablo, digits = 3); print(sb_cl, digits = 3)
print(temsil[temsil$en_zayif, c("form", "subscale", "elenen", "en_yakin", "uzaklik")], digits = 3)
write.csv(as4_tablo, "html_ciktilari/AS4_anlamsal.csv", row.names = FALSE)
write.csv(sb_cl, "html_ciktilari/AS4_SB_CL.csv", row.names = FALSE)
write.csv(temsil, "html_ciktilari/AS4_madde_temsil.csv", row.names = FALSE)
