# GenAI use among students and pre-service teachers (Türkiye focus): reference verification and additional sources

**How verification was done, and its limits (read first).** In this session the egress proxy blocked `api.crossref.org`, `doi.org`, `data.tuik.gov.tr`, `oecd.org`, `hepi.ac.uk`, `dergipark.org.tr`, `mdpi.com` and `search.trdizin.gov.tr`, both from Bash and from WebFetch. As a result, **no DOI was resolved directly through doi.org or Crossref**, and **the TR Dizin script could not run** (it returned a "network error"). Existence and metadata were confirmed in two other ways instead:
- **(W)** Web-search index listings of the publisher or official landing page, with metadata and abstract text taken from the indexed page. For recent items this is good evidence that the item exists. It is weaker than resolving the DOI, and the search tool's summaries sometimes conflate details. Where two snippets disagreed, both are reported.
- **(SG)** Wiley Scholar Gateway records. These are Wiley's own metadata and full-text passages, so they are strong evidence for Wiley/Hindawi journals.

Before submission, run `curl -s https://api.crossref.org/works/<DOI>` on an unrestricted machine for every DOI below. All quotas were used up during this session: WebSearch (200/200), Consensus (monthly limit) and Scholar Gateway (free tier).

---

## Part A1 — National/international statistics cited in the drafts (TÜİK, OECD PISA 2025, HEPI 2026, Pew 2026)

### Takeaway
All four sources exist and most of the numbers are correct: 19.2%, 39.4%, 31.4%, 52%, 46%, 29%, 95%, 94%. Four problems need fixing:
- **High priority.** The drafts give the TÜİK base as "son üç ayda internet kullanan bireyler". Coverage of the bulletin describes 19.2% as the share of *individuals aged 16–74*.
- The page locators cannot be verified: "OECD, 2026, s. 9", "s. 239/240/276" and "TÜİK, 2026, s. 167".
- Some index snippets attach Türkiye's 44% to "preliminary research" rather than to drafting homework. It needs a manual check.
- The Pew author list and the use-purpose details attributed to Pew were not verified.

### Cited Findings

**TÜİK (2025), *Yapay Zeka İstatistikleri, 2025*, bulletin no. 57945**
- It exists. TÜİK published "Yapay Zeka İstatistikleri, 2025" for the first time. The individual-level data come from the Household ICT Usage Survey, where a GenAI item was asked of 16–74-year-olds for the first time in 2025 — [AA](https://www.aa.com.tr/tr/bilim-teknoloji/turkiyede-uretken-yapay-zeka-kullandigini-beyan-edenlerin-orani-yuzde-19-2/3703970); [Rapor Bülteni](https://raporbulteni.substack.com/p/118-tuik-yapay-zeka-istatistikleri)
- It was released on 1 October 2025, which matches the draft's "(2025, 1 Ekim)". This is inferred from same-day reposts of the bulletin — [Alomaliye, 2025/10/01](https://www.alomaliye.com/2025/10/01/yapay-zeka-istatistikleri-2025/)
- **19.2%** of individuals (16–74) reported using GenAI in 2025 (men 19.4%, women 18.8%). By age: **16–24 = 39.4%**, 25–34 = 30%, 35–44 = 15.5%. Higher-education graduates = 36.1% — [TRT Haber](https://www.trthaber.com/haber/gundem/turkiyede-uretken-yapay-zeka-kullandigini-beyan-edenlerin-orani-yuzde-192-921422.html); [AA](https://www.aa.com.tr/tr/bilim-teknoloji/turkiyede-uretken-yapay-zeka-kullandigini-beyan-edenlerin-orani-yuzde-19-2/3703970)
- Among GenAI users, 79.7% used it for private purposes, 33.8% for professional purposes and **31.4% for formal education (örgün eğitim)**. For formal-education use, women were at 36.6% and men at 26.7% — [Branding Türkiye](https://www.brandingturkiye.com/yapay-zeka-istatistikleri-2025/); [Forbes Türkiye](https://www.forbes.com.tr/teknoloji/tuik-ilk-kez-acikladi-yapay-zekada-turkiye-nin-karnesi)
- **Denominator problem.** None of the coverage found says the 19.2% is a share of *"son üç ayda internet kullanan"* individuals. All of it phrases the figure as a share of individuals aged 16–74 — [AA](https://www.aa.com.tr/tr/bilim-teknoloji/turkiyede-uretken-yapay-zeka-kullandigini-beyan-edenlerin-orani-yuzde-19-2/3703970). The drafts that use the internet-user phrasing are:
  - Giriş_ve_Amac, ¶1: "son üç ayda internet kullanan bireyler arasında ÜYZ kullanımı %19,2"
  - v35, ¶1: "son üç ayda internet kullanan 16-74 yaş grubundaki bireylerin %19,2'si"
  - ITALL_düzenleme, "Gerekçe" ¶1: the same wording
  The bulletin's table and footnote must be checked. If the base is all individuals aged 16–74, remove "son üç ayda internet kullanan".
- Do not mix these figures with a different, OECD-based series reported in Sept 2026 news: 16–74 = **17.2%**, 16–24 = **38.5%**, 55–74 = 1.8%. That series probably uses a different base or reference period — [AA, Sept 2026](https://www.aa.com.tr/tr/bilim-teknoloji/turkiyede-genclerin-uretken-yapay-zeka-kullanimi-genel-oranin-2-katini-asti/4051722)
- v39 ("16-74 yaş grubundaki bireylerin %19,2'sinin 2025 yılında ÜYZ kullandığını… %31,4'ü… örgün eğitim amacıyla") **matches** the coverage — [Branding Türkiye](https://www.brandingturkiye.com/yapay-zeka-istatistikleri-2025/)

**TÜİK (2026), *İstatistiklerle Türkiye 2025* (Yayın No. 4826), p. 167**
- A search summary describes an "İstatistiklerle Türkiye 2025" compendium published in July 2026 with 23 chapters. That description came only from a search-tool summary and could not be opened. **Publication no. 4826 and p. 167 are UNVERIFIED** — [search listing incl. TÜİK site](https://www.tuik.gov.tr/). A "Rakamlarla Türkiye 2025" also exists (Aug 2026), so check the exact title — [Alomaliye](https://www.alomaliye.com/2026/08/07/rakamlarla-turkiye-2025/)
- The v35 reference entry has no URL. The Giriş draft uses a long veriportali download URL. Recommendation: cite the primary bulletin 57945 for 19.2%, 39.4% and 31.4%, and use the compendium only if p. 167 is checked by hand.

**OECD (2026), PISA 2025 Results (Volume I), and the Türkiye country note**
- Both exist, published September 2026:
  - Main report: "PISA 2025 Results (Volume I)" (product ID 73451bc5-en, consistent with DOI 10.1787/73451bc5-en), subtitled "Future-Ready Students" — [OECD](https://www.oecd.org/en/publications/pisa-2025-results-volume-i_73451bc5-en.html); [Education GPS](https://gpseducation.oecd.org/IndicatorExplorer?plotter=h5&query=2)
  - Country note: "PISA 2025 Results (Volume I): Türkiye" — [OECD country note](https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/turkiye_3f140b0d-en.html)
  - OECD press release — [OECD press release 2026/09](https://www.oecd.org/en/about/news/press-releases/2026/09/pisa-2025-students-reading-and-mathematics-performance-declined-sharply-across-the-oecd.html)
- **52%** of Türkiye's 15-year-olds use AI chatbots to help them learn at least once a week. The OECD average is **46%** — [OECD country note (index snippet)](https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/turkiye_3f140b0d-en.html)
- Drafting text for written assignments: two index snippets give **Türkiye 44%, OECD 29%**. The OECD 29% is independently corroborated in coverage of the main report, e.g. Singapore 45% against 29% — [OECD country note](https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/turkiye_3f140b0d-en.html); [OECD "Student school life and beyond"](https://www.oecd.org/en/publications/pisa-2025-results-volume-i_73451bc5-en/full-report/student-school-life-and-beyond_861e5904.html)
- **Conflicting snippet.** Two other index snippets of the same country note attach **44% to "conduct preliminary research on a new topic" (OECD 31%)**. One snippet gives both at 44%, plus 34% for "summarise a text" (OECD 30%) and 8% "never/almost never" (OECD 14%) — [OECD country note](https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/turkiye_3f140b0d-en.html). **Check the country note by hand to confirm that 44% applies to drafting.** Also check whether PISA's wording supports the draft's "sık kullanım" (frequent use) qualifier.
- On performance, main-report text says that after accounting for socio-economic profile, weekly AI-for-learning users have science performance similar to non-users. Students who use AI for specific tasks (summarising texts, drafting, research) score lower than non-users. "Around 20 points" is quoted, but the snippet does not show whether that gap is before or after SES adjustment — [OECD "Student school life and beyond"](https://www.oecd.org/en/publications/pisa-2025-results-volume-i_73451bc5-en/full-report/student-school-life-and-beyond_861e5904.html). This **supports v35's substance**. The page numbers (s. 239, 240, 276) and "Raporun 15. notu" are **UNVERIFIED**.
- v39 cites "(OECD, 2026, **s. 9**)" but its reference is the **HTML** country note, so a page number cannot be verified against that source. Cite the PDF version of the country note with its page, or drop the page locator. OECD also publishes the country notes as PDFs; one for another country is linked here — [example PDF](https://www.oecd.org/content/dam/oecd/en/publications/reports/2026/09/pisa-2025-results-volume-i-country-notes_88d1164e/mexico_40016e3e/85702d30-en.pdf)

**Stephenson & Armstrong (2026), HEPI Report 199**
- It exists. The report is by Rose Stephenson and Charlotte Armstrong and sponsored by Kortext. Savanta ran the survey in **December 2025** with **1,054 full-time UK undergraduates**. **95%** use AI in some form and **94%** use GenAI to support assessed work. This is the third edition of the survey — [HEPI report page](https://www.hepi.ac.uk/reports/student-generative-ai-survey-2026/); [HEPI PDF](https://www.hepi.ac.uk/wp-content/uploads/2026/03/HEPI-Report-199-Gen-AI-Survey-2026.pdf); [Advance HE](https://www.advance-he.ac.uk/knowledge-hub/governance-news-alert/higher-education-policy-institute-hepi-student-generative-ai)
- The draft claims are **accurate**. Wording caution: "support assessed work" covers help such as explaining concepts, so "yararlandı/destek aldı" is right, while "wrote their assessments with GenAI" would not be. The HEPI web page calls it "Student Generative *Artificial Intelligence* Survey 2026" and the PDF says "Student Generative AI Survey 2026". The drafts (v39/Giriş) are inconsistent on the URL: one uses the report page, the other the PDF.

**Gottfried et al. (2026), Pew Research Center, "Americans and AI 2026"**
- It exists and was published 17 June 2026. It surveyed **5,119 U.S. adults** on 17–23 Feb 2026 through the American Trends Panel. **49%** of U.S. adults use AI chatbots (33% in 2024, 23% in 2023) and 24% use them daily — [Pew report](https://www.pewresearch.org/internet/2026/06/17/americans-and-ai-2026-chatbots-smart-devices-and-views-on-impact/); [Pew PDF](https://www.pewresearch.org/wp-content/uploads/sites/20/2026/06/PI_2026.06.17_Americans-and-AI_REPORT.pdf)
- **UNVERIFIED:** the author list (Gottfried, Bishop, Anderson, Faverio, Park, McClain) and the draft's list of use purposes ("bilgi arama ve iş görevleri öne çıkmış; eğlence, görsel üretimi ve duygusal destek…"). Neither appeared in the retrieved snippets. Check the PDF's byline and the purposes chart.

### Inferences
- The most important fix is the TÜİK base. If it is wrong, the drafts understate the population the 19.2% refers to, and reviewers who know TÜİK tables may flag it.
- The PISA 2025 figures are real and very recent (Sept 2026). They add strong Türkiye-specific context: Turkish 15-year-olds are above the OECD average on weekly AI-for-learning use and on drafting use. They concern 15-year-olds, though, so they should be framed as describing the incoming cohort, not university students.

### Gaps
- The TÜİK bulletin, the OECD country note, the HEPI PDF and the Pew PDF could not be opened (egress blocked). Every page number and exact wording needs a manual check.
- *İstatistiklerle Türkiye 2025* (No. 4826, p. 167) is not verified.

---

## Part A2 — Journal articles cited in the drafts: metadata, content, and flagged draft sentences

### Takeaway
Of the 22 articles checked, 20 are confirmed with metadata matching the drafts. **Kokoç (2026, UEFAD 39[2]) could not be found anywhere and is UNVERIFIED.** **Şat, Başaran & Özer (2026)** exists, but index records disagree on who the authors are. Several draft sentences go slightly beyond what the sources report:
- Johnston et al. (2024): the 54.1% item was about Grammarly-type tools.
- Chan & Hu (2023): "aşırı dayanma" does not appear in the abstract.
- Özüdoğru & Delen (2026): the analysis unit is pair-authored reflections.

### Cited Findings

**Verified (existence and metadata as in the drafts, unless noted)**

**Ravšelj et al. (2025).** *PLOS ONE*, 20(2), e0315011, published 5 Feb 2025.
- Global survey of **23,218 higher-education students from 109 countries and territories**, collected in early 2024.
- Main uses were brainstorming, summarising texts and finding research articles. Students found it useful for simplifying complex information and less reliable for providing information. They called for regulation because of concerns about cheating and plagiarism.
- **A published Correction exists** (doi:10.1371/journal.pone.0349691). Check whether it affects the cited figures.
- The v39 and düzenleme sentences are **accurate**.
- Sources: [PLOS ONE](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0315011); [PMC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11798494/); [Correction](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0349691)

**von Garrel & Mayer (2023).** *Humanities and Social Sciences Communications*, 10, Article 799, published 9 Nov 2023.
- Nationwide German survey of more than 6,300 students. Almost two-thirds use or have used AI-based tools in their studies, and almost half named ChatGPT/GPT-4. The main reasons were clarifying questions of understanding and explaining subject concepts.
- The draft's "6.311" was not visible in the snippets, which say "more than 6,300". The "yaklaşık üçte ikisi" claim and the "broader than GenAI" caveat are **accurate**.
- Source: [Nature HSSC](https://www.nature.com/articles/s41599-023-02304-7)

**Chan & Hu (2023).** *IJETHE*, 20, Article 43.
- Survey of **399** students (177 undergraduate, 222 postgraduate) from 10 faculties at **six Hong Kong universities**. Attitudes were generally positive. Students saw benefits in personalised learning support, writing and brainstorming help, and research and analysis.
- The concerns in the abstract are **accuracy, privacy, ethics, and impact on personal development, career prospects and societal values**.
- **Flag:** v39 ("…doğruluk ve aşırı dayanma kaygılarıyla…") and Giriş ¶3 ("doğruluk, mahremiyet ve aşırı dayanma kaygıları") include "aşırı dayanma", which is not in the abstract. Confirm it in the full text or rephrase as "kişisel gelişim üzerindeki olası etkiler".
- Source: [ResearchGate/record](https://www.researchgate.net/publication/372411790_Students'_voices_on_generative_AI_perceptions_benefits_and_challenges_in_higher_education); [arXiv](https://arxiv.org/abs/2305.00290)

**Johnston, Wells, Shanks, Boey & Parsons (2024).** *International Journal for Educational Integrity*, 20, Article 2.
- Survey of **2,555** University of Liverpool students, run to inform the university's academic-integrity code. **54.1%** were supportive or somewhat supportive of using *tools such as Grammarly*. **70.4%** were unsupportive or somewhat unsupportive of students using tools such as ChatGPT to write a whole essay. Students more confident in their academic writing were less likely to use GAI.
- **Flag:** the düzenleme sentence ("…araçtan akademik yardım almasını, örneğin dilbilgisi desteği almasını, destekleyen… %54,1") broadens the item. Suggested wording: "Grammarly gibi dil düzeltme araçlarının kullanımını destekleyen veya kısmen destekleyen %54,1".
- Source: [Springer](https://link.springer.com/article/10.1007/s40979-024-00149-4); [Liverpool repository](https://livrepository.liverpool.ac.uk/3178553/)

**Bae, Hur, Park, Choi & Moon (2024).** *Online Learning*, 28(3), 131–156.
- Examines pre-service teachers' views of GenAI, mainly ChatGPT, both for their own learning and for teaching. This is the "dual perspectives" framing.
- Claim is **accurate**. Sample size was not retrieved.
- Source: [OLJ](https://olj.onlinelearningconsortium.org/index.php/olj/article/view/4543); [ERIC PDF](https://files.eric.ed.gov/fulltext/EJ1446841.pdf)

**Celik (2023).** *Computers in Human Behavior*, 138, Article 107468.
- Proposes the Intelligent-TPACK framework: AI-specific technological, pedagogical and content knowledge, plus the ethical assessment of AI-based decisions. It is an empirical study with **in-service teachers**.
- Using it for the pre-service "dual role" point (v39 "(Bae vd., 2024; Celik, 2023)") works as conceptual support only.
- Source: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0747563222002886)

**Ng, Leung, Su, Ng & Chu (2023).** *ETR&D*, 71(1), 137–161.
- Argues that teachers need AI digital competencies to use and teach AI in post-pandemic online and blended settings. It concerns teachers generally, not pre-service teachers specifically.
- Source: [PubMed](https://pubmed.ncbi.nlm.nih.gov/36844361/); [ERIC](https://eric.ed.gov/?id=EJ1372059)

**Karataş & Yüce (2024).** *IRRODL*, 25(3), 304–325.
- Qualitative narrative inquiry with **141 preservice teachers** who used AI, mainly ChatGPT, over a 3-week Zoom implementation. It examines how AI shaped their professional identities and teaching approaches.
- "141 adayla" is **accurate**. The detailed themes cited in the drafts (translation, fast access, academic integrity, human interaction) were not visible in the snippets.
- Source: [IRRODL](https://www.irrodl.org/index.php/irrodl/article/view/7785)

**Dulkadir Yaman (2025a).** "Pre-service teachers' views on an artificial intelligence based text generator," *Eğitim Teknolojisi Kuram ve Uygulama*, 15(1), 1–21, doi:10.17943/etku.1485828.
- Metadata **confirmed** on the DergiPark listing. The indexed text discusses chatbot limitations: the risk of false information, ethical issues, and limited personalisation.
- The v39 claim of "aşırı dayanma" concerns was not visible.
- **Do not confuse** it with Dulkadir Yaman (2025b), *European Journal of Education*, 60(4) (see Part B2).
- Source: [DergiPark](https://dergipark.org.tr/en/pub/etku/article/1485828)

**Özüdoğru & Delen (2026).** "Beyond acceptance…," *Education Sciences*, 16(9), Article 1420.
- 50 early-childhood preservice teachers, working in **25 pairs**, wrote two lesson plans, received GenAI feedback and revised. **50 pair-authored reflections** were analysed. They "seldom accepted GenAI recommendations outright".
- **Flag:** the v39 sentence "…çoğunlukla uyarladığını veya reddettiğini…" is plausible, but "çoğunlukla" goes beyond the abstract. Also say that the unit was pair reflections.
- Source: [MDPI](https://www.mdpi.com/2227-7102/16/9/1420)

**Şat, Başaran & Özer (2026)?** "Special education teacher candidates' experiences and views regarding artificial intelligence use," *Pedagogical Perspective*, 5(1), 224–236, doi:10.29329/pedper.2026.167.
- The article exists: phenomenology, semi-structured interviews with **8** pre-service special-education teachers, 10 themes and 25 sub-themes. AI was seen as a pragmatic resource for saving time, creating materials and making accommodations.
- **AUTHORSHIP UNRESOLVED.** Index snippets list the authors as "Başaran, Y. İ., & Özer, E." with "M. Şat" as *translator*. Another snippet attributes the DOI to "Çağrı Demirtaş". Check the byline on the article page before citing it as "Şat vd."
- The draft's claims about Turkish terminology and data privacy were not visible.
- Source: [Pedagogical Perspective](https://pedagogicalperspective.com/index.php/pub/article/view/167)

**Lindkvist, Curbo & Hultgren (2026).** *Frontiers in Education*, Article 1813306.
- Mixed methods with Swedish biomedical laboratory science students on a take-home exam followed by a viva. Of the 46 who completed the exam, most used GAI, and **two deliberate non-users were interviewed**.
- The drafts **accurately** stress the small n. The volume number (11) was not shown in the snippet.
- Source: [Frontiers](https://www.frontiersin.org/journals/education/articles/10.3389/feduc.2026.1813306/full)

**Cheah, Lu & Kim (2025).** *Computers and Education: AI*, 8, Article 100363.
- Mixed-methods study of K-12 teachers (University of Idaho IRB). Themes included GenAI as a tool for efficiency and workload relief, and academic integrity. Many teachers felt unprepared, and barriers were lack of PD, ethics and infrastructure.
- The "ders hazırlama, ölçme ve yönetim" specifics (v35) were not visible.
- Source: [ResearchGate record](https://www.researchgate.net/publication/387770296_Integrating_generative_artificial_intelligence_in_K-12_education_Examining_teachers'_preparedness_practices_and_barriers)

**Pei, Lu & Jing (2025).** *Computers and Education: AI*, 8, Article 100406.
- AI-literacy survey with **200 valid responses** from preservice teachers in an introductory instructional-technology course.
- The düzenleme claim that mechanism knowledge was lower than basic-concept knowledge was **not visible** in the snippets. Check the full text.
- Source: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2666920X25000463)

**Ayanwale, Adelana, Molefi, Adeeko & Ishola (2024).** *Computers and Education Open*, 6, Article 100179.
- SEM study of **529 pre-service teachers at a Nigerian university**. Understanding AI predicted AI use, detection, ethics, creation and problem-solving.
- Source: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S266655732400020X)

**Du, Sun, Jiang, Islam & Gu (2024).** *HSSC*, 11, Article 559.
- 318 Chinese **K-12 in-service teachers**. AI literacy affected intention to learn AI indirectly, through self-efficacy, perceived social good and ethics awareness. The drafts label this correctly as "öğretmenlerle".
- Source: [Nature HSSC](https://www.nature.com/articles/s41599-024-03101-6)

**Abbas, Jam & Khan (2024).** *IJETHE*, 21, Article 10.
- Study 1 validated a scale (N = 165). Study 2 used a three-wave time-lagged design (N = 494). Workload and time pressure → more ChatGPT use; reward sensitivity → less. ChatGPT use → procrastination, memory loss and lower academic performance.
- Claims are **accurate**. The consequences finding is also directly relevant to the overreliance framing.
- Source: [Springer](https://link.springer.com/article/10.1186/s41239-024-00444-7)

**Johri, Hingle & Schleiss (2024).** "Misconceptions, pragmatism, and value tensions: Evaluating students' understanding and perception of generative AI for education," 2024 IEEE FIE.
- The DOI 10.1109/FIE61694.2024.10893017 maps to this title in the index. Open-ended survey of undergraduates in IT degrees; students defined GenAI in many different ways and held misconceptions about it.
- Pages "1–9" and the draft's specific concerns (fast access vs accuracy and independent learning) were **not verified**.
- Source: [arXiv/record](https://www.emergentmind.com/papers/2410.22289); [FIE 2024 TOC](https://www.computer.org/csdl/proceedings/fie/2024/24EmR4huzra)

**Barbieri & Nguyen (2025).** *Australasian Journal of Educational Technology*, 41(2), 34–49.
- UTAUT-framed study of **126 PSTs** on work-integrated-learning placements, using surveys and focus groups. GenAI improved efficiency and stress management and gave timely support in managing professional relationships.
- The v35 claim is **accurate**.
- Source: [AJET](https://ajet.org.au/index.php/AJET/article/view/10035)

**Perkins, Furze, Roe & MacVaugh (2024).** *Journal of University Teaching and Learning Practice*, 21(6), doi:10.53761/q3azde36.
- Proposes the AIAS, which sets permitted levels of GenAI use in assessment according to learning outcomes. The v35 characterisation, "not a psychometric instrument", is **accurate**.
- Source: [JCU repository](https://researchonline.jcu.edu.au/87283/)

**UNVERIFIED**

**Kokoç, M. (2026).** "Generative AI as a learning partner or pedagogical challenge? Insights from pre-service teachers," *Journal of Uludag University Faculty of Education*, 39(2), 463–477, doi:10.19171/uefad.1799876.
- Searches by exact title, by author + journal + year, and by volume/issue found **nothing**. The only Kokoç 2026 GenAI paper found is a co-authored eTwinning study in the *European Journal of Teacher Education* — [T&F](https://www.tandfonline.com/doi/full/10.1080/02619768.2026.2662594)
- It is cited in v39 and in düzenleme, where it is credited with specific findings ("fikir geliştirme ve dil desteğine ilişkin yarar algılarına, yanlış bilgi ve aşırı dayanma kaygıları"). **Confirm it on DergiPark/UEFAD before keeping it.** If it cannot be confirmed, remove it or replace it with the verified Turkish sources in Part B2.

### Inferences
- The draft sentence "Türkiye'de öğretmen adaylarıyla yürütülen araştırmalar… araca aşırı dayanma olasılığına ilişkin kaygılar bildirir (Dulkadir Yaman, 2025; Karataş & Yüce, 2024; Kokoç, 2026)" currently rests on one unverified source, and "overreliance" is not visible in the other two. It can be supported with verified Turkish evidence:
  - Gökçearslan et al. (2026): GenAI dependency among Turkish university students
  - Barış Horzum et al. (2026): excessive GenAI time linked to poorer academic outcomes
  - Merzifonluoglu & Gunes (2025) and Dulkadir Yaman (2025b): PSTs reported unethical or advisor-type use
- Celik (2023), Ng et al. (2023) and Du et al. (2024) concern **in-service** teachers. They support the professional-competence argument, not empirical claims about pre-service teachers.

### Gaps
- Full texts could not be opened, so detailed thematic claims were checked only against abstracts. This affects Karataş & Yüce, Cheah, Pei, Johri, Şat et al. and Dulkadir Yaman (2025a).
- No DOI was resolved via doi.org or Crossref (egress blocked).

---

## Part B1 — Additional sources: GenAI use is widespread among university students internationally (2023–2026)

### Takeaway
Besides HEPI 2026, Ravšelj et al. (2025) and von Garrel & Mayer (2023), the following verified sources can carry the "widespread use" claim:
- single-country surveys: Italy, South Africa, Canada, Türkiye
- two 2026 evidence syntheses: a systematic review of 82 studies and a scoping review of 44 studies
- PISA 2025 for the incoming 15-year-old cohort

### Cited Findings
- **Farinosi & Melchior (2025), EJED.** 531 University of Udine students (Italy) answered questionnaires and 60 were interviewed. More than two-thirds use ChatGPT for personal purposes and **40.9% for academic tasks**, mainly summarising, clarifying and generating content. 70% were aware of ethical concerns — [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70094) (SG)
- **Jooste, Wolff & Joubert (2025), CAEE 33(4).** Engineering students at a South African university showed "widespread adoption" of GAI. Only **1%** supported a complete ban, and students raised concerns about its use in formal assessment — [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/cae.70064) (SG)
- **Dhaliwal, Czegledi & Dafoe (2026), *Accounting Perspectives*, advance online.** Commentary based on survey and open-ended data from **846** accounting students at a Canadian university. Users valued efficiency and conceptual help but noted limits in accuracy, **overreliance** and academic integrity. Verification practices varied widely — [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/1911-3838.70031) (SG)
- **Apata, Kwok & Ajose (2026), JCAL 42(5).** Systematic review of **82** empirical studies (2022–Oct 2025) on ChatGPT in higher education. Its lay summary states that "ChatGPT is widely used by students and faculty members in higher education", and opinions on accuracy and ethics differ — [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/jcal.70309) (SG)
- **Vziatysheva (2026), *Human Behavior and Emerging Technologies*, 2026(1).** Scoping review of 44 studies on how GenAI is used. Information seeking is among the most common motivations, alongside editing and brainstorming. It also finds concerning practices such as excessive copy-pasting. The research base leans on cross-sectional surveys and student samples — [Wiley](https://onlinelibrary.wiley.com/doi/10.1155/hbe2/1733863) (SG). *Metadata anomaly:* Wiley lists "Vziatysheva, V., & S., M." but the abstract is written in the first-person singular. Check the author list.
- **Duran, Ersanlı & Çelik (2025), BERJ, advance online.** **540 Turkish university students**. Mixed methods: GPT-4 sentiment scoring, Monte Carlo simulation, decision trees and grounded theory. Views were "dual-edged": enthusiasm for personalised, efficient learning alongside concerns about ethics, social isolation and less teacher–student interaction — [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/berj.4188) (SG)
- For context on the incoming cohort: PISA 2025 found 46% of 15-year-olds across the OECD, and 52% in Türkiye, use AI chatbots weekly to help them learn — [OECD country note](https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/turkiye_3f140b0d-en.html)

**APA 7 (verified via SG metadata; article numbers follow the DOI suffix per Wiley/Hindawi convention and should be confirmed)**
- Apata, O. E., Kwok, O., & Ajose, S. T. (2026). The impact of ChatGPT on higher education: A systematic review of global opportunities, perceptions, and challenges. *Journal of Computer Assisted Learning, 42*(5). https://doi.org/10.1002/jcal.70309
- Dhaliwal, S., Czegledi, A., & Dafoe, K. (2026). A commentary on accounting education in transition: Reflections on what 800+ students taught us about ChatGPT. *Accounting Perspectives*. Advance online publication. https://doi.org/10.1111/1911-3838.70031
- Duran, V., Ersanlı, E., & Çelik, H. (2025). Unveiling student sentiment dynamics toward AI-based education through statistical analysis and Monte Carlo simulation. *British Educational Research Journal*. Advance online publication. https://doi.org/10.1002/berj.4188
- Farinosi, M., & Melchior, C. (2025). 'I use ChatGPT, but should I?' A multi-method analysis of students' practices and attitudes towards AI in higher education. *European Journal of Education*. https://doi.org/10.1111/ejed.70094 *(volume/issue not returned; confirm)*
- Jooste, J. L., Wolff, K. E., & Joubert, J. G. (2025). Engineering students' perceptions and use of generative artificial intelligence. *Computer Applications in Engineering Education, 33*(4). https://doi.org/10.1002/cae.70064
- Vziatysheva, V. (2026). How we use generative AI: A scoping review of research on purposes, prompts, and interaction patterns. *Human Behavior and Emerging Technologies, 2026*(1), Article 1733863. https://doi.org/10.1155/hbe2/1733863 *(check whether there is a second author)*

### Inferences
- A parenthesis such as "(Farinosi & Melchior, 2025; Jooste vd., 2025; Ravšelj vd., 2025; Stephenson & Armstrong, 2026; von Garrel & Mayer, 2023)" supports "widespread across national contexts". Adding Apata et al. (2026) and Vziatysheva (2026) supplies synthesis-level support.
- The rates are not comparable across these studies: 40.9% for academic tasks in Italy versus 94% for assessed work in the UK. Samples and definitions differ. This is consistent with the drafts' caution in v35 ("doğrudan ülkeler arası yaygınlık karşılaştırmasına elverişli değildir").

### Gaps
- Some widely cited prevalence sources could not be verified because the search budget ran out: Stöhr, Ou & Malmström (2024, *Computers and Education: AI*, Sweden), HEPI 2025 (Freeman), and the Digital Education Council Global AI Student Survey 2024. Do not cite them without checking.

---

## Part B2 — Turkish studies (2023–2026): university students and pre-service teachers — use, perceptions, accuracy, ethics, overreliance/dependence

### Takeaway
TR Dizin could not be queried (network blocked), but Wiley records confirm several Turkish studies from 2024–2026 that bear directly on dependence and overreliance:
- Gökçearslan et al. (2026): a GenAI dependency scale with 276 Turkish university students
- Barış Horzum et al. (2026): 754 Turkish EMI students; excessive GenAI time was associated with poorer outcomes
- Duran et al. (2025): 540 Turkish students

There are also several pre-service teacher studies in EJED. Together with the verified Karataş & Yüce (2024), Dulkadir Yaman (2025a) and Özüdoğru & Delen (2026), these can replace or supplement the unverified Kokoç (2026).

### Cited Findings (most relevant, with APA 7 and summary)
1. **Gökçearslan, Ş., Aktan, M. C., Yılmaz, B., Gökçearslan, E., & Kaura, N. (2026). GenAI dependency risk: Insights through the lens of mindset, GenAI literacy, and academic stress. *New Directions for Child and Adolescent Development, 2026*(1), Article 2647537. https://doi.org/10.1155/cad/2647537**
   - SEM survey of **276 Turkish university students** (83% undergraduates) who actively use GenAI.
   - Findings: GenAI literacy correlated positively with GenAI dependency (r = .31). Academic stress also contributed to dependency. Men, public-university students and more frequent users reported greater dependency. All correlations were weak.
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1155/cad/2647537) (SG)
2. **Barış Horzum, M., Soruç, A., Yuksel, D., & Pawlak, M. (2026). Generative artificial intelligence as a linguistic crutch or cognitive scaffold: The interplay of self-beliefs and general English proficiency in English medium instruction. *International Journal of Applied Linguistics*. Advance online publication. https://doi.org/10.1111/ijal.70153**
   - **754 EMI students at a major public university in Turkey**, in social sciences and engineering.
   - Findings: GenAI perceptions and competence related to achievement differently by discipline, and **"excessive time spent on GenAI platforms is correlated to poorer academic outcomes"**. The paper includes a Turkish abstract (Öz).
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ijal.70153) (SG)
3. **Merzifonluoglu, A., & Gunes, H. (2025). Shifting dynamics: Who holds the reins in decision-making with artificial intelligence tools? Perspectives of Gen Z pre-service teachers. *European Journal of Education*. https://doi.org/10.1111/ejed.70053** *(volume/issue not returned)*
   - Explanatory sequential mixed methods with **389 Gen Z pre-service teachers at two state universities**.
   - Findings: ChatGPT was used mainly "as an advisor", and PSTs often adapted AI suggestions to their own preferences. AI was preferred for assignments, reports, projects and presentations, and time and effort savings drove acceptance. Participants raised privacy, bias and security concerns.
   - *The Turkish setting is likely (Turkish authors) but was not stated in the retrieved text.*
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70053) (SG)
4. **Dulkadir Yaman, N. (2025b). Pre-service teachers' process of developing and using content with AI. *European Journal of Education, 60*(4). https://doi.org/10.1111/ejed.70277**
   - Case study with PSTs at a state university, using interviews, the Bot Usability Scale and the Individual Innovativeness Scale.
   - Findings: PSTs used chatbots mostly for **educational, informational and *unethical* purposes**, and innovativeness was related to attitudes towards AI. *Setting presumed Türkiye (same author as ETKU 2025a); not stated in the abstract.*
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70277) (SG)
5. **Eğin, F., Onan, A., & Yildiz Durak, H. (2025). Let's talk about EdTech! A topic modelling analysis of AI tools and pre-service teachers' perspectives. *European Journal of Education, 60*(1). https://doi.org/10.1111/ejed.12913**
   - Topic modelling of PSTs' open-ended responses on technology integration, compared with topics generated by ChatGPT, Gemini and Bing AI. Coherence with the PST themes was moderate, highest for ChatGPT.
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.12913) (SG)
6. **Kayaalp, F., Durnali, M., & Gökbulut, B. (2024). Enhancing competence for a sustainable future: Integrating artificial intelligence–supported educational technologies in pre-service teacher training for sustainable development. *European Journal of Education*. https://doi.org/10.1111/ejed.12865** *(volume/issue not returned)*
   - 14-week intervention with **20 PSTs** who used ChatGPT and Pixton to make SDG comics.
   - Findings: sustainability knowledge and awareness improved, but participants were concerned about productivity, **originality and ethics**. PSTs also said ChatGPT increased their enthusiasm for research.
   - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.12865) (SG)
7. **Duran, Ersanlı & Çelik (2025)**, *BERJ*: 540 Turkish university students with a "dual-edged" view (see B1) — [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/berj.4188) (SG)
8. Already cited and verified in Part A2: Karataş & Yüce (2024), Dulkadir Yaman (2025a, ETKU), and Özüdoğru & Delen (2026).

**Leads found in the web index. They exist, but full APA metadata (authors, volume, DOI) could not be retrieved, so each needs checking before use:**
- "An exploration of Turkish EFL pre-service teachers' perceptions on the integration of generative AI in English language teacher education: benefits, challenges, and future directions," *Asian-Pacific Journal of Second and Foreign Language Education* (2026), doi:10.1186/s40862-026-00420-w. According to the index summary, challenges included reliability, **overreliance**, ethics and AI literacy — [Springer](https://link.springer.com/article/10.1186/s40862-026-00420-w)
- "Öğretmen Adaylarının Dijital Yeterlikleri ile Yapay Zekâ Okuryazarlıkları Arasındaki İlişkinin İncelenmesi," *Ege Eğitim Dergisi* — [DergiPark](https://dergipark.org.tr/tr/pub/egeefd/article/1805994)
- "Öğretmen Adaylarının Yapay Zekâ Hazır Bulunuşluk Düzeylerinin Çeşitli Değişkenler Açısından İncelenmesi," *Trakya Eğitim Dergisi* — [DergiPark](https://dergipark.org.tr/tr/pub/tred/article/1746487)
- "Türkçe Öğretmenleri ve Öğretmen Adaylarının Yapay Zekâya Yönelik Tutumları ve Görüşleri: Karma Yöntemli Bir Araştırma," *Ana Dili Eğitimi Dergisi* — [DergiPark](https://dergipark.org.tr/tr/pub/aded/article/1890080)
- "Sosyal Bilgiler Öğretmen Adaylarının Üretken Yapay Zeka Kabul Düzeylerinin Dijital Okuryazarlık Açısından İncelenmesi," *Academia Eğitim Araştırmaları Dergisi* — [DergiPark](https://dergipark.org.tr/tr/pub/egitim/article/1760427)
- "Özel Eğitim Öğretmeni Adaylarının Yapay Zekâya Yönelik Hazırbulunuşlukları ve Tutumları…," *Bayburt Eğitim Fakültesi Dergisi* — [DergiPark](https://dergipark.org.tr/en/pub/befdergi/article/1785903)
- "Physiotherapy students' acceptance of AI-based chatbots (including ChatGPT) in education: a multi-institutional study from Turkey" — [PMC](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12866455/)

### Inferences
- Suggested supported replacement for the v39/düzenleme sentence on Turkish PSTs: "(Dulkadir Yaman, 2025a, 2025b; Karataş & Yüce, 2024; Merzifonluoglu & Gunes, 2025; Özüdoğru & Delen, 2026)" for benefits plus evaluation/adaptation of outputs.
- For the dependence and overreliance angle among Turkish university students, add "(Barış Horzum vd., 2026; Gökçearslan vd., 2026)".
- Gökçearslan et al. (2026) matter for the manuscript's conceptual section. They treat "GenAI dependency" as a scale construct, and their finding that literacy correlates *positively* with dependency supports the drafts' point: heavy or skilled use ≠ dysfunctional dependent use.

### Gaps
- **TR Dizin was not searched** because egress was blocked. Run these commands locally:
  - `python3 …/trdizin.py search --q "öğretmen adayları yapay zeka" --order publicationYear-DESC --limit 20 --no-references`
  - the same with `"ChatGPT öğretmen adayı"`, `"üretken yapay zeka öğretmen adayları"`, `"yapay zeka üniversite öğrencileri görüş"` and `"ChatGPT üniversite öğrencileri"`
- The Turkish setting of Merzifonluoglu & Gunes (2025) and Dulkadir Yaman (2025b) is inferred from authorship and was not confirmed in the text.

---

## Part B3 — Pre-service teachers' dual role (learner and future teacher); teacher education and AI literacy

### Takeaway
The "dual role" framing has direct support from Bae et al. (2024), whose title uses "dual perspectives", and from Le et al. (2026, BJET), whose abstract states that teacher-education students "play double role as present learners and future educators". Recent teacher-education work treats dependency and de-skilling as explicit risks: Kohnke & Moorhouse (2026) on de-skilling and dependency, and Lehtinen et al. (2026) on reliance vs corroboration in PST lesson planning.

### Cited Findings
- **Le, T. H., Huynh, L., Dang, B., Pham, H., Nguyen, N. T., & Nguyen, A. (2026). Development and evaluation of artificial intelligence literacy training for teacher education students. *British Journal of Educational Technology*. Advance online publication. https://doi.org/10.1111/bjet.70047**
  - The abstract states: "Teacher education students play double role as present learners and future educators."
  - Design-based research: a workshop piloted with 14 master's students and evaluated with 29 teacher-education students. Participants showed significant gains in AI-competence self-efficacy, attitudes, and commitment to critical, ethical and pedagogical GenAI engagement.
  - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/bjet.70047) (SG)
- **Kohnke, L., & Moorhouse, B. L. (2026). Avoiding de-skilling and dependency: A practical guide to using generative AI in TESOL teacher education. *TESOL Quarterly*. Advance online publication. https://doi.org/10.1002/tesq.70203**
  - Argues that teachers "may offload professional work onto GenAI before developing evidence-informed pedagogies". Proposes design principles for pre- and in-service teacher education, including low-stakes tool use, scenario-based microteaching and structured reflection.
  - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/tesq.70203) (SG)
- **Lehtinen, A., Channa, F., Näykki, P., Ahlström, E., & Hiljanen, M. (2026). Generative AI for collaborative learning: Fostering critical thinking in teacher education. *Journal of Computer Assisted Learning, 42*(3). https://doi.org/10.1002/jcal.70256**
  - Process mining of video data from **75 PSTs** co-writing lesson plans. High-performing groups iterated on their writing and **corroborated GenAI content with other online sources**. Low-performing groups showed repetitive prompting and **reliance on AI-generated content**.
  - This is directly relevant to the drafts' "doğrulama" dimension.
  - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/jcal.70256) (SG)
- **Khalid, S., Ifran, S., Huang, X., Tadesse, E., & Dainkun, J. (2026). AI-integrated professional development for pre-service teachers: A systematic review of impacts on pedagogical strategies and technological self-efficacy. *European Journal of Education, 61*(2). https://doi.org/10.1111/ejed.70547**
  - PRISMA review of 11 studies (2020–2025). Recommends human-centred, ethically informed AI-literacy frameworks that treat AI as an assistant that does not replace teachers' professional judgement.
  - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70547) (SG)
- **Acquah, B. Y., Arthur, F., Gyedu, F. O., Quayson, E., Boateng, E., Quaye, S. A., & Nortey, S. A. (2026). Preservice teachers' artificial intelligence competence: A network and latent profile analyses. *European Journal of Education*. https://doi.org/10.1111/ejed.70735**
  - Survey of **509 Ghanaian PSTs** across six AI-competence domains, including AI ethics and human-centred education.
  - Source: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70735) (SG)
- Already verified in Part A2: Bae et al. (2024) (dual perspectives), Celik (2023) (Intelligent-TPACK), Ng et al. (2023), Pei et al. (2025), Ayanwale et al. (2024) and Barbieri & Nguyen (2025) (GenAI as a placement "buddy" for PSTs).
- Related, verified: Merzifonluoglu & Gunes (2025) found that PSTs used ChatGPT as an "advisor" and adapted its suggestions — [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.70053) (SG)

### Inferences
- Suggested parenthesis for the dual-role sentence in v39 ¶2 and v35: "(Bae vd., 2024; Celik, 2023; Le vd., 2026; Ng vd., 2023)". Le et al. is the only one besides Bae that states the dual role explicitly.
- Suggested parenthesis for "teacher education should build verification and evaluative judgement": "(Khalid vd., 2026; Kohnke & Moorhouse, 2026; Lehtinen vd., 2026; Özüdoğru & Delen, 2026)".

### Gaps
- UNESCO's *AI competency framework for teachers* (2024) and Sperling et al.'s (2024) scoping review of AI literacy in teacher education are commonly cited but were **not verified** in this session, because the search budget was exhausted.
