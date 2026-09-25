# D6_uc_tur_davranis_etiketleri.R | 25 Eylül 2026 | UTF-8 | AIGENIE 2.1.2
#
# Kılavuzdaki Örnek 1'in YAPISI: orada üç kişilik özelliği üç madde türü (type),
# her birinin dört yönü de attribute'tur (ör. neuroticism: anxious, depressed...).
# Burada üç içerik alanınız üç madde türü, dokuz göstergeniz dokuz attribute olur.
# Etiketler kod adı yerine kısa davranış adlarıdır ve eksiklik bildirmez
# ("without" gibi sözcük içermez). Paket bu etiketleri isteme aynen yazar.
#
# İki önemli fark:
#   - Paket her çağrıda her attribute için 2 madde ister; model her göstergeye
#     ayrı ayrı madde yazmak zorunda kalır.
#   - GENIE her tür için AYRI çalışır. NMI, dokuz gösterge etiketine göre hesaplanır.
#     Bu, v4'teki "tek tür, üç alan" analizinden farklı bir analiz birimidir.
#
# Soru: Göstergeleri doğrudan ve davranış adıyla vermek maddeleri somutlaştırıyor mu?
#
# Maliyet: target.N tür başınadır; 3 tür x 30 = 90 madde (öteki denemelerin üç katı).
#
# Çalıştırma: çalışma dizini deneme_betikleri klasörü olmalı.
#   source("D6_uc_tur_davranis_etiketleri.R", encoding = "UTF-8")

CALISTIR <- FALSE  # TRUE: maddeler üretilir (ücretli API çağrısı)
GENIE <- FALSE     # TRUE: gömme alınır (ücretli) ve GENIE elemesi yapılır

source("00_ortak_calistirici.R", encoding = "UTF-8")

uretim <- list(
  item.attributes = list(
    thinking_handed_to_ai = c(          # 1a, 1b, 1c
      "copying-ai-solutions",
      "adopting-ai-arguments",
      "letting-ai-do-practice-tasks"),
    monitoring_handed_to_ai = c(        # 2a, 2b, 2c
      "following-ai-study-plans",
      "moving-on-after-ai-explanations",
      "judging-work-by-ai-feedback"),
    output_taken_as_is = c(             # 3a, 3b, 3c
      "using-ai-information-directly",
      "citing-ai-suggested-sources",
      "keeping-ai-answers-despite-doubts")),
  item.type.definitions = list(
    thinking_handed_to_ai = paste(
      "Öğrencinin, öğrenmek için kendisinin yapması gereken düşünme işini (çözüm,",
      "gerekçe, argüman, alıştırma) yapay zekâya bırakıp çıktıyı çalışmasında kullanması."),
    monitoring_handed_to_ai = paste(
      "Öğrencinin, ne kadar öğrendiğine ve çalışmasının yeterli olup olmadığına",
      "yapay zekâ çıktısına bakarak karar vermesi."),
    output_taken_as_is = paste(
      "Öğrencinin, yapay zekânın verdiği bilgi, kaynak ve yanıtları olduğu gibi",
      "çalışmasına katması.")),
  domain = "educational psychology",
  scale.title = "Akademik Görevlerde Üretken Yapay Zekâya Aşırı Dayanma Ölçeği",
  audience = "Türkiye'deki eğitim fakültelerinde okuyan öğretmen adayları",
  prompt.notes = "Bütün maddeleri Türkiye Türkçesiyle, birinci tekil kişi ve geniş zamanda yaz.",
  target.N = 30L)  # Tür başına 30 (her göstergeden yaklaşık 10)

deney_calistir("D6", uretim, calistir = CALISTIR, genie = GENIE)
