# Cognitive offloading, metacognition/SRL, academic help seeking and learning outcomes with GenAI: reference check and more sources for a Turkish qualitative article on "dependent use"

How sources were checked, and the limits of that checking. Please read this first.
- The egress proxy blocked `api.crossref.org`, `doi.org`, `search.trdizin.gov.tr` and every publisher host from Bash and from WebFetch (HTTP 403 "EGRESS_BLOCKED"). Because of this, **no DOI was resolved directly.** I checked metadata in two ways: (a) web-search result listings that come from publisher, PubMed, DBLP or ACM pages and show the title, venue and DOI, and (b) Wiley Scholar Gateway records, which include the full citation line and DOI and, for Wiley journals, full-text passages.
- Consensus hit its monthly limit (0 searches were available). The session-wide WebSearch budget (200) ran out while I was on the Turkish-source searches. The Turkish part (B5) is therefore incomplete.
- Labels used below. **[V-pub]**: metadata seen on a publisher, PubMed or ACM listing in search results. **[V-SG]**: Wiley Scholar Gateway record, with full text read. **[V-sec]**: known only from secondary coverage. **UNVERIFIED**: not confirmed.

---

## Part A: Are the references in the drafts correct, and do the drafts describe them accurately?

### Takeaway
All 14 Part A sources exist and their core metadata matches the drafts. **Sentences that need fixing:**
1. Cash et al.: "seçici dikkat" is not supported (sources say "working memory, attention, executive control"). v39 line 186 also changes what the distinction is between.
2. Yan et al.: v39 line 190 credits Yan et al. with a three-domain split that includes "öznel yetkinlik algısı". Subjective competence is not a domain in their framing.
3. Bastani et al.: v39 line 190 says "araçsız sınav performansının düştüğünü". The result is lower than control, not a decline over time.
4. Viberg et al.: the "four phases" were **not verifiable** from any accessible text. The phases look like a paraphrase of classic help-seeking process models. The author-name spelling ("Feldman Maggor" vs "Feldman-Maggor") is also inconsistent across the drafts.
5. Karabenick (2004): citing it is acceptable, but the instrumental/executive distinction comes from Nelson-Le Gall (1981, 1985). Karabenick (2004) itself used the terms "autonomous" vs "expedient" help seeking.

### Cited Findings

**A1. Risko, E. F., & Gilbert, S. J. (2016). Cognitive offloading. *Trends in Cognitive Sciences, 20*(9), 676–688. https://doi.org/10.1016/j.tics.2016.07.002**
- Status: metadata is the standard citation and matches all three drafts. It was **not re-checked in this session** (no search budget left). This is low risk because it is a heavily cited canonical paper. Other papers cite it as the source of "cognitive offloading theory", e.g. Farhat (2026) in *Applied Cognitive Psychology* — [Scholar Gateway record](https://onlinelibrary.wiley.com/ai/10.1002/acp.70205).
- Summary: a review article. It defines cognitive offloading as using physical action to change the information-processing demands of a task so that cognitive demand falls. It covers offloading onto the body (for example, rotating the head) and onto external artefacts (for example, reminders). It treats the decision to offload as metacognitively driven, partly by confidence in one's internal abilities.
- Draft check (minor): v39 line 14 says "bilgi işleme gerekliliklerini **dış araçlar yoluyla** değiştirerek". The original wording is "physical action", which includes but is not limited to external tools. Suggested wording: "fiziksel eylem veya dış araçlar yoluyla".

**A2. Cash, T. N., Kelly, M. O., Macnamara, B. N., & Risko, E. F. (2026). Is AI making us stupid? *Trends in Cognitive Sciences, 30*(8), 673–675. https://doi.org/10.1016/j.tics.2026.06.004** [V-pub]
- Existence, authors and 30(8) 673–675 are confirmed by the [Cell Press listing](https://www.cell.com/trends/cognitive-sciences/abstract/S1364-6613(26)00131-2), the [ScienceDirect listing ("Science & Society")](https://www.sciencedirect.com/science/article/abs/pii/S1364661326001312) and the [Cell Press announcement on X](https://x.com/CellPressNews/status/2075611001798467678). Published July 2026. It is a short **Science & Society forum piece**, not an empirical study or a full review. The DOI string itself was not resolved.
- Summary, from secondary coverage [V-sec]: the authors argue AI is unlikely to cause a general decline in intelligence. They separate **specific learned skills** (solving equations, writing essays, navigation, diagnosis) from **basic cognitive abilities** ("working memory, attention and wider aspects of executive control"). Offloading can block skill acquisition and speed up skill decay when practice stops. Basic abilities appear resistant to change — [phys.org](https://phys.org/news/2026-07-ai-stupid-weaken-skills-built.html); [Dynamic Learning substack](https://dynamiclearning.substack.com/p/delegating-our-thinking-to-ai); [PsyPost](https://www.psypost.org/is-ai-making-us-stupid-through-cognitive-offloading-new-review-explores-the-evidence/).
- Draft checks:
  - v39 line 14: "alıştırmayla edinilen becerilerin korunması ile temel bilişsel yetilerdeki değişimi aynı iddia olarak ele almaz" — **consistent.**
  - v35 ("Akademik Yardım Arama ve Bilişsel Dışa Aktarma" section): "çalışma belleği ve **seçici dikkat** gibi temel yetilerdeki değişimi" — **"seçici" is not supported.** The coverage I could access says "working memory, attention". Suggested wording: "çalışma belleği ve dikkat gibi".
  - v39 line 186: "Cash vd. (2026), **aracın kullanımı ile bilişsel yetilerdeki değişimi** aynı iddia olarak ele almaz." — **imprecise.** Their distinction is between skill decay or skill non-acquisition and change in basic cognitive abilities. It is not a distinction between tool use and ability change. Suggested wording: "beceri kaybı ile temel bilişsel yetilerdeki değişimi".

**A3. Yan, L., Greiff, S., Lodge, J. M., & Gašević, D. (2025). Distinguishing performance gains from learning when using generative AI. *Nature Reviews Psychology, 4*, 435–436. https://doi.org/10.1038/s44159-025-00467-5** [V-pub]
- Confirmed via the [Nature listing](https://www.nature.com/articles/s44159-025-00467-5), [Monash portal](https://research.monash.edu/en/publications/distinguishing-performance-gains-from-learning-when-using-generat/) and [UQ eSpace](https://espace.library.uq.edu.au/view/UQ:277da26). Published July 2025, vol. 4, pp. 435–436. It is a two-page Comment. An author version was posted as [arXiv:2605.13731](https://arxiv.org/abs/2605.13731) in May 2026; cite the journal version.
- Summary: GenAI can raise learners' performance while they use it, but these uses may not produce the deep cognitive and metacognitive processing that learning needs. Assisted task performance should therefore not be read as evidence of learning. I could not read the full text in this session. The drafts' specific list (independent/unassisted performance, retention, transfer) fits the title and abstract but was **not checked word for word.**
- Draft check: v39 line 190 says "Yan vd.'nin (2025) ayrımına göre araçla ortaya çıkan ürün, araçsız performans ve **öznel yetkinlik algısı** ayrı kanıt alanlarıdır." This is **probably over-attributed.** Yan et al. separate performance with the tool from learning. Adding self-perceived competence as a third evidence domain is the authors' own extension. Suggested wording: "Yan vd. (2025) destekli performansı öğrenmeden ayırır; öznel yetkinlik algısı bu çalışmada üçüncü bir kanıt alanı olarak ele alınmıştır."
- Companion source for a multi-citation parenthesis: the BJET special-section editorial by Yan, Pammer-Schindler et al. (2025) (Part B).

**A4. Bastani, H., Bastani, O., Sungu, A., Ge, H., Kabakcı, Ö., & Mariman, R. (2025). Generative AI without guardrails can harm learning: Evidence from high school mathematics. *Proceedings of the National Academy of Sciences, 122*(26), Article e2422633122. https://doi.org/10.1073/pnas.2422633122** [V-pub]
- Confirmed via the [PNAS listing](https://www.pnas.org/doi/10.1073/pnas.2422633122), [PubMed 40560616](https://pubmed.ncbi.nlm.nih.gov/40560616/) and [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4895486).
- **Correction notice:** [Correction for Bastani et al., PNAS 122(34), 10.1073/pnas.2518204122](https://www.pnas.org/doi/10.1073/pnas.2518204122) ([PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12403119/)). It only fixes Osbert Bastani's affiliation, so the findings are unaffected. It does not need to be cited.
- **Exact figures from the abstract** ([PNAS](https://www.pnas.org/doi/10.1073/pnas.2422633122)):
  - During assisted practice, grades improved by **48% for GPT Base** and **127% for GPT Tutor**.
  - When access was removed, GPT Base students scored **17% lower** than students who never had access.
  - "These negative learning effects are largely mitigated by the safeguards" in GPT Tutor. GPT Tutor was prompted to give teacher-designed hints rather than answers.
  - The field experiment took place in a Turkish high school with nearly 1,000 students. It was cluster-randomized at class level.
- A secondary summary reports the unassisted-exam effects in SD units (GPT Base about −0.19 SD vs. control; GPT Tutor about −0.01 SD). That is consistent with "GPT Tutor not significantly different from control", but **I could not check it against the primary text.** Do not quote the SD values unless you check them in the paper.
- Draft checks:
  - v35 and Giriş ("standart GPT-4 arayüzü … alıştırmalarda daha iyi … araç kaldırıldıktan sonraki sınavda kontrol grubunun gerisinde … ipuçlarıyla sınırlandırılmış koşulda olumsuz sonuç büyük ölçüde giderildi … kontrol grubuna anlamlı üstünlük sağlamadı") — **consistent.**
  - v39 line 14: "Sınırlandırılmış arayüz koşulunda bu fark gözlenmedi." — somewhat strong. Suggested: "büyük ölçüde azaldı; kontrol grubundan anlamlı biçimde farklılaşmadı".
  - v39 line 190: "Bastani vd. (2025) standart arayüz koşulunda araçsız sınav performansının **düştüğünü** gösterdi." — **imprecise.** It was lower than control (−17%), not a within-person drop over time. Suggested: "kontrol grubuna göre daha düşük kaldığını".
  - v39 line 195: "sınırlandırılmış arayüz koşulunda araçsız performansın kontrol grubundan farklılaşmaması" — acceptable.

**A5. Fan, Y., Tang, L., Le, H., Shen, K., Tan, S., Zhao, Y., Shen, Y., Li, X., & Gašević, D. (2025). Beware of metacognitive laziness: Effects of generative artificial intelligence on learning motivation, processes, and performance. *British Journal of Educational Technology, 56*(2), 489–530. https://doi.org/10.1111/bjet.13544** [V-SG]
- The 9-author list, 56(2) and 489–530 are confirmed by the Scholar Gateway citation line ([Wiley](https://bera-journals.onlinelibrary.wiley.com/doi/10.1111/bjet.13544)). It was online on 10 Dec 2024 and in the 2025 issue, so (2025) is correct for APA. A preprint also exists as [arXiv:2412.09315](https://arxiv.org/abs/2412.09315).
- Design ([Scholar Gateway full text](https://onlinelibrary.wiley.com/ai/10.1111/bjet.13544)): a randomised lab study with 117 university students in four groups: ChatGPT (AI), human expert (HE), writing-analytics checklist tools (CL) and control (CN). Participants read, wrote and revised an essay.
- Results, quoted from the Discussion and Conclusion:
  - "the AI group significantly improved the essay scores compared to other groups, but no significant differences were found among the groups in terms of knowledge gain or knowledge transfer."
  - There were no significant differences in intrinsic motivation.
  - SRL process maps suggested that GenAI "may also take over (offload) regulation from learners."
- **Important caveat to add to the drafts:** in their Limitations the authors state "the lack of targeted and matured measures for assessing metacognitive laziness". Metacognitive laziness was **inferred from process patterns, not measured directly.**
- Draft checks:
  - v39 line 15: "ÜYZ desteğinin yazı puanını artırırken bilgi kazanımında fark oluşturmadığını" — correct but incomplete. Add "ve transferde". Also note that the comparison is between groups.
  - v35 ("bilgi kazanımı ve transferde anlamlı farkın eşlik etmediğini … üstbilişsel tembellik olarak tartıştığı olasılık") — **consistent.**
  - Giriş line 11 — **consistent.**

**A6. Zimmerman, B. J. (2002). Becoming a self-regulated learner: An overview. *Theory Into Practice, 41*(2), 64–70. https://doi.org/10.1207/s15430421tip4102_2**
- Status: standard metadata, **not re-checked in this session** (no search budget). Low risk.
- The drafts' use (goal setting, monitoring, evaluation, adjustment within SRL phases) fits Zimmerman's cyclical forethought, performance and self-reflection model.

**A7. Karabenick, S. A. (2004). Perceived achievement goal structure and college student help seeking. *Journal of Educational Psychology, 96*(3), 569–581. https://doi.org/10.1037/0022-0663.96.3.569** [V-pub]
- Confirmed via [ResearchGate](https://www.researchgate.net/publication/232499086_Perceived_Achievement_Goal_Structure_and_College_Student_Help_Seeking) and the [SSRL SIG PDF](https://ssrlsig.org/wp-content/uploads/2018/01/karabenick-2004-perceived-achievement-goal-structure-and-college-student-help-seeking.pdf).
- Content: Study 1 (N = 883, 6 chemistry classes) found that help seeking is best described by an **approach pattern** ("intentions to seek autonomous help from teachers") and an **avoidance pattern** (help-seeking threat, avoidance intentions and **seeking expedient help**). Study 2 (N = 852, 13 psychology classes) found that perceived mastery goal structure predicted approach, and perceived performance-avoid structure predicted avoidance.
- **Answer to the attribution question:** Karabenick (2004) does operationalise the adaptive/autonomous vs expedient contrast. It groups expedient help seeking with avoidance, and it uses "autonomous/expedient" rather than "instrumental/executive". The **origin** of the instrumental (adaptive) vs executive (expedient) distinction is Nelson-Le Gall (1981, 1985). Later work cites the distinction as Butler (1998), Butler & Neuman (1995) and Karabenick (2004) — [Inbar-Furst & Gumpel, 2015, *Psychology in the Schools*](https://onlinelibrary.wiley.com/ai/10.1002/pits.21868); [Kell et al., 2018, ETS RR](https://onlinelibrary.wiley.com/ai/10.1002/ets2.12218); [Rutherford et al., 2023](https://onlinelibrary.wiley.com/ai/10.1002/pits.23008). Recommended parenthesis: **(Karabenick, 2004; Karabenick & Dembo, 2011; Nelson-Le Gall, 1981, 1985)**. The references are listed below.
- Verified help-seeking theory references:
  - Nelson-Le Gall, S. (1981). Help-seeking: An understudied problem-solving skill in children. *Developmental Review, 1*(3), 224–246. https://doi.org/10.1016/0273-2297(81)90019-8 — the [ScienceDirect listing](https://www.sciencedirect.com/science/article/abs/pii/0273229781900198) confirms title, journal and year. The DOI is derived from the listing's PII. The page range 224–246 is from my knowledge; one secondary summary misprinted it as "224–226". Check before use.
  - Nelson-Le Gall, S. (1985). Help-seeking behavior in learning. *Review of Research in Education, 12*, 55–90. https://doi.org/10.3102/0091732X012001055 — [SAGE listing](https://journals.sagepub.com/doi/10.3102/0091732X012001055).
  - Karabenick, S. A., & Dembo, M. H. (2011). Understanding and facilitating self-regulated help seeking. *New Directions for Teaching and Learning, 2011*(126), 33–43. https://doi.org/10.1002/tl.442 — [Wiley](https://onlinelibrary.wiley.com/doi/10.1002/tl.442); [ERIC EJ932254](https://eric.ed.gov/?id=EJ932254). It presents help seeking as an **eight-step self-regulated process**: (1) determine whether there is a problem; (2) determine whether help is needed or wanted; (3) decide whether to seek help; (4) decide on the type of help (goal); (5) decide whom to ask; (6) solicit help; (7) obtain help; (8) process the help received — [SSRL SIG PDF](https://ssrlsig.org/wp-content/uploads/2018/01/karabenick-dembo-2011-understanding-and-facilitating-self-reg-help-seeking.pdf).
  - Karabenick & Knapp (1991), *J. Educ. Psychol.* 83(2), 221–230 — **UNVERIFIED in this session.** Secondary sources cite it for the curvilinear need–help-seeking relation ([Davison et al., 2022, BJEP](https://onlinelibrary.wiley.com/ai/10.1111/bjep.12538)), not for the instrumental/executive distinction.

**A8. Viberg, O., Feldman Maggor, Y., & Wong, J. (2026). Efficiency vs. effectiveness: Self-regulated learning with LLM-mediated help-seeking. *Learning Letters, 8*, Article 60. https://doi.org/10.20851/ll.v8.60** [V-pub, partial]
- Existence, title, venue and article number are confirmed via the [Learning Letters article page](https://learningletters.org/index.php/learn/article/view/60) ([PDF](https://learningletters.org/index.php/learn/article/download/60/63/736)). It appears in the special issue "Self-regulated Learning in the Age of Generative AI: Finding the Balance" (guest editors Lim & Wong). The DOI string follows the journal's pattern but was not resolved.
- **Author-name spelling:** search listings show both "Feldman Maggor" and "Feldman-Maggor". The drafts are inconsistent: v39 has no hyphen, and the reference in another draft has a hyphen. Harmonise to the form in the article header after checking the PDF.
- Content, from search-indexed abstract text:
  - A qualitative interview study with **20 STEM students at a large Swedish university** who used commercial LLM chatbots.
  - Thematic analysis was guided by **Zimmerman's SRL model and the OSLQ subscales (help-seeking, task strategies).**
  - Help seeking was "layered and context-dependent". LLMs were preferred for simple, well-defined tasks (debugging, syntax checking). Peers and instructors were sought for other purposes.
  - Some students admitted the temptation to let LLMs solve whole tasks but were cautious, because they saw this as undermining learning goals.
- Draft checks:
  - "İsveç'teki yükseköğretim öğrencileriyle yaptıkları görüşmelerde" — **consistent.** Consider adding "STEM".
  - "yardım kaynağı seçimini … göreve göre değişen bir düzenleme olarak tanımladı" — **consistent** with "layered and context-dependent".
  - **"dört aşama: gereksinimi belirleme, kaynak seçme, yardım türünü belirleme, yardımı değerlendirme" — UNVERIFIED.** No accessible text confirmed a four-phase model in this paper. The phases closely match the classic help-seeking process models: Nelson-Le Gall (1981) and Karabenick & Dembo's (2011) eight steps, which include determining need, deciding type of help, deciding whom to ask and processing help. Check the PDF. If the four phases are not in the paper, attribute the process view to Nelson-Le Gall (1981) and Karabenick & Dembo (2011), and cite Viberg et al. only for the empirical finding.

**A9. Tankelevitch, L., Kewenig, V., Simkute, A., Scott, A. E., Sarkar, A., Sellen, A., & Rintel, S. (2024). The metacognitive demands and opportunities of generative AI. In *Proceedings of the 2024 CHI Conference on Human Factors in Computing Systems* (Article 680, pp. 1–24). ACM. https://doi.org/10.1145/3613904.3642902** [V-pub]
- Confirmed via the [ACM DL](https://dl.acm.org/doi/10.1145/3613904.3642902), [Microsoft Research](https://www.microsoft.com/en-us/research/publication/the-metacognitive-demands-and-opportunities-of-generative-ai/) and [arXiv:2312.10893](https://arxiv.org/abs/2312.10893). It won the CHI 2024 Best Paper award. The article number (680) and page count were not independently seen.
- Summary: a conceptual paper grounded in psychology. It argues that GenAI imposes metacognitive demands at three points:
  - **prompting**: self-awareness of task goals, task decomposition, well-adjusted confidence, and metacognitive flexibility to change prompting strategy;
  - **evaluating and relying on output**: well-adjusted confidence in judging validity;
  - **workflow or automation strategy**: deciding whether and how to use GenAI.
  It proposes metacognitive support in the interface, plus explainability and customizability, to reduce these demands.
- Draft checks: the v39 wording "istem oluşturma, çıktıyı değerlendirme ve otomasyon stratejisini düzenleme" and the v35 wording "hedefi tanımlama, çıktıyı değerlendirme ve … etkileşim stratejisini değiştirme" are both **acceptable paraphrases.** Note that two reference-list variants exist across the drafts (one without "2024" and without the article number). Harmonise them.

**A10. Kreijkes, P., Kewenig, V., Kuvalja, M., Lee, M., Hofman, J. M., Vitello, S., Sellen, A., Rintel, S., Goldstein, D. G., Rothschild, D., Tankelevitch, L., & Oates, T. (2026). Effects of LLM use and note-taking on reading comprehension and memory: A randomised experiment in secondary schools. *Computers & Education, 243*, Article 105514. https://doi.org/10.1016/j.compedu.2025.105514** [V-pub]
- Confirmed via [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0360131525002829), [ACM DL mirror (vol. 243)](https://dl.acm.org/doi/10.1016/j.compedu.2025.105514) and [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5095149).
- Summary ([EurekAlert](https://www.eurekalert.org/news-releases/1108126); [phys.org](https://phys.org/news/2025-12-traditional-ai-chatbots-comprehension-combined.html)):
  - A randomised classroom experiment with **405 students aged 14–15**. Students studied two passages and were tested on comprehension and retention **three days later**.
  - **Note-taking alone and note-taking combined with the LLM** both had significant positive effects on comprehension and retention compared with **LLM alone**.
  - Most students still preferred the LLM and saw it as more helpful.
- Draft check (v35): "not alma koşullarının yalnız model kullanımına göre üç gün sonraki anlama ve **sözel bilgi hatırlamayı** desteklediğini" — consistent in substance. "sözel bilgi hatırlama" is a specific label I could not verify. "hatırlama/kalıcılık" is safer.

**A11. Wong, S. S. H., & Qiu, S. X. (2026). Think first, ChatGPT later: Guiding human–AI collaboration for learning gains in independent human creativity. *Educational Psychology Review, 38*, Article 45. https://doi.org/10.1007/s10648-026-10118-7** [V-pub]
- Confirmed via [Springer](https://link.springer.com/article/10.1007/s10648-026-10118-7) and [SMU InK](https://ink.library.smu.edu.sg/soss_research/4441/). Volume and article number are taken from the draft and were not independently seen.
- Summary:
  - **196 university students** did a creative product-improvement task in one of three conditions: alone (human-only), with free ChatGPT use (general-AI), or with guided use (regulated-AI: generate your own ideas first, then use ChatGPT to improve, develop and evaluate them).
  - All groups then did a **creative invention task independently**.
  - The regulated-AI group more often used ChatGPT to improve self-generated ideas. This mediated their later advantage **over the general-AI group in independent originality.**
- Draft check (v35) — **consistent.** The advantage is specifically over the unguided AI group and specifically in originality. If space allows, say so.

**A12. Li, C., Cui, H., & Hagedorn, L. S. (2026). The cognitive impact of ChatGPT in higher education: A systematic review of critical and creative thinking outcomes. *Computers and Education: Artificial Intelligence, 10*, Article 100571. https://doi.org/10.1016/j.caeai.2026.100571** [V-pub]
- Confirmed via [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2666920X26000330) and [ResearchGate](https://www.researchgate.net/publication/402142693_The_Cognitive_Impact_of_ChatGPT_in_Higher_Education_A_Systematic_Review_of_Critical_and_Creative_Thinking_Outcomes). Volume and article number are from the draft; the DOI is shown in the listing.
- Summary:
  - A PRISMA review of **67 empirical studies (2022–2025)** with a convergent (critical) vs divergent (creative) thinking lens.
  - ChatGPT supported cognitive development when used within **inquiry-oriented, scaffolded designs**, through metacognitive regulation, argumentative reasoning and idea generation.
  - In **unstructured contexts** there were asymmetric patterns favouring creativity over critical thinking, or joint declines, "both of which often triggered cognitive offloading".
  - The authors recommend reflective prompts, rubric-guided evaluation and AI-literacy training.
- Draft check (v35) — **consistent.** The v35 caution about not pooling designs is appropriate.

**A13. Liu, D., Fan, G., & Pan, L. (2026). Tool, tutor, or crutch? A grounded theory of cognitive scaffolding and offloading in AI-assisted programming education. *International Journal of STEM Education, 13*, Article 10. https://doi.org/10.1186/s40594-025-00592-w** [V-pub]
- Confirmed via [Springer](https://link.springer.com/article/10.1186/s40594-025-00592-w).
- **A correction has been published:** [10.1186/s40594-026-00611-4](https://link.springer.com/article/10.1186/s40594-026-00611-4). I could not see what it corrects; check before citing specific details.
- Summary:
  - A constructivist grounded-theory study comparing an **AI-enabled** section with a **human pair-programming** section of an undergraduate Java course.
  - Data: interaction logs, pre/post concept maps and dyadic interviews.
  - It produces a process-level tension model with two recurrent loops, **Scaffolding** and **Offloading**, interpreted through Cognitive Load Theory and Self-Determination Theory.
  - It separates immediate task performance from durable, transferable learning.
- Draft use (v35: the function of help varies with task and interaction conditions) — **consistent.**

**A14. Melumad, S., & Yun, J. H. (2025). Experimental evidence of the effects of large language models versus web search on depth of learning. *PNAS Nexus, 4*(10), Article pgaf316. https://doi.org/10.1093/pnasnexus/pgaf316** [V-pub]
- Confirmed via [Oxford Academic](https://academic.oup.com/pnasnexus/article/4/10/pgaf316/8303888) and [PubMed 41163786](https://pubmed.ncbi.nlm.nih.gov/41163786/). October 2025.
- Summary:
  - **Seven experiments** with online participants, randomly assigned to learn a topic (for example, planting a vegetable garden) from an LLM (ChatGPT) or from Google web links.
  - LLM learners reported shallower learning, invested less effort, and later wrote advice that was shorter and less original.
  - Web-search learners reported greater **felt ownership** of the knowledge ([techxplore](https://techxplore.com/news/2025-10-ai-shallower-knowledge-web.html)).
- Draft check (v35): "ÜYZ özetlerinden öğrenenler daha yüzeysel öğrendiklerini bildirdi … daha kısa ve daha az özgün öneriler metin analizleriyle belirlendi" — **consistent.** "**İlk deneydeki** daha düşük bilgi sahipliği ise öz bildirimle belirlendi" — I **could not verify** that ownership was measured only in Experiment 1. Secondary coverage presents ownership as a general finding. Check the paper.

### Inferences
- The drafts are mostly careful. The recurring risk is **over-attribution**: giving a source a finer distinction than it makes (Cash: "seçici dikkat"; Yan: "öznel yetkinlik algısı"; Viberg: "four phases").
- For the Karabenick passages, the most defensible parenthesis is **(Karabenick, 2004; Karabenick & Dembo, 2011; Nelson-Le Gall, 1981, 1985)**. It credits the origin of the distinction, the college operationalisation and the SRL process model.

### Gaps
- DOIs could not be resolved directly because doi.org and Crossref were blocked. Every DOI above should be spot-checked with `curl https://api.crossref.org/works/<DOI>` from an unrestricted machine before submission.
- The Viberg et al. full text, Yan et al. full text, Bastani GPT Tutor exam statistics, Cash et al. exact wording on "attention" and the Melumad & Yun ownership experiments could not be read in the primary text.
- Risko & Gilbert (2016) and Zimmerman (2002) were not re-checked in this session. Both are canonical and low risk.

---

## Part B1: Cognitive offloading to GenAI, critical thinking and learning

### Takeaway
There is consistent but mostly short-term or correlational evidence that offloading to LLMs lowers effort and cognitive load and weakens depth, reasoning and memory for the offloaded content. The strongest causal evidence is lab or field experiments (Stadler et al.; Grinschgl et al. for non-AI offloading; Bastani et al.). The widely reported brain-imaging evidence (Kosmyna et al.) is a **preprint** and has been criticised.

### Cited Findings
- **Stadler, M., Bannert, M., & Sailer, M. (2024). Cognitive ease at a cost: LLMs reduce mental effort but compromise depth in student scientific inquiry. *Computers in Human Behavior, 160*, Article 108386. https://doi.org/10.1016/j.chb.2024.108386** [V-pub]
  - 91 university students were randomly assigned to ChatGPT-3.5 or Google to research nanoparticles in sunscreen.
  - LLM users had **lower extraneous, intrinsic and germane cognitive load** but gave **weaker reasoning and justifications** for their final recommendations.
  - Sources: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0747563224002541); [TUM portal](https://portal.fis.tum.de/en/publications/cognitive-ease-at-a-cost-llms-reduce-mental-effort-but-compromise/).
- **Gerlich, M. (2025). AI tools in society: Impacts on cognitive offloading and the future of critical thinking. *Societies, 15*(1), Article 6. https://doi.org/10.3390/soc15010006** [V-pub]
  - Mixed methods (survey plus interviews), **666 participants**.
  - Found a significant negative correlation between frequent AI-tool use and critical thinking, **mediated by cognitive offloading**. Younger participants were more dependent and scored lower. Higher education level buffered the effect.
  - **A correction was published** ([Correction: Gerlich … Societies 2025, 15, 6](https://www.researchgate.net/publication/395511406_Correction_Gerlich_M_AI_Tools_in_Society_Impacts_on_Cognitive_Offloading_and_the_Future_of_Critical_Thinking_Societies_2025_15_6)); its content was not seen.
  - The design is cross-sectional and correlational. Cite for association only, not causation.
  - Sources: [MDPI](https://www.mdpi.com/2075-4698/15/1/6); [phys.org](https://phys.org/news/2025-01-ai-linked-eroding-critical-skills.html). The DOI is derived from the MDPI URL (15/1/6) and was not resolved.
- **Grinschgl, S., Papenmeier, F., & Meyerhoff, H. S. (2021). Consequences of cognitive offloading: Boosting performance but diminishing memory. *Quarterly Journal of Experimental Psychology, 74*(9), 1477–1496. https://doi.org/10.1177/17470218211008060** [V-pub]
  - A non-AI experimental precedent: offloading raised immediate task performance but lowered later memory for the offloaded information.
  - Sources: [SAGE](https://journals.sagepub.com/doi/10.1177/17470218211008060); [PubMed 33752519](https://pubmed.ncbi.nlm.nih.gov/33752519/).
  - This is a close analogue for the "performance up, learning down" pattern in dimension 1.
- **Kosmyna, N., Hauptmann, E., Yuan, Y. T., Situ, J., Liao, X.-H., Beresnitzky, A. V., Braunstein, I., & Maes, P. (2025). *Your brain on ChatGPT: Accumulation of cognitive debt when using an AI assistant for essay writing task* [Preprint]. arXiv. https://doi.org/10.48550/arXiv.2506.08872** — **PREPRINT, not peer-reviewed.** [V-pub: [arXiv abs](https://arxiv.org/abs/2506.08872)]
  - The first five author names are confirmed by the title of a published commentary. The last three are from memory; check them on arXiv.
  - Design: 54 participants in LLM, search-engine or brain-only groups over three sessions; 18 completed a fourth crossover session. EEG was recorded.
  - The LLM group showed the weakest brain connectivity and a reduced ability to quote from essays they had just written. Participants reported lower ownership of their essays.
  - A critical **commentary** exists ([arXiv:2601.00856](https://arxiv.org/pdf/2601.00856)). If cited, use Kosmyna et al. only as supporting preprint evidence, labelled "(ön baskı)".
- **Zhai, C., Wibowo, S., & Li, L. D. (2024). The effects of over-reliance on AI dialogue systems on students' cognitive abilities: A systematic review. *Smart Learning Environments, 11*, Article 28. https://doi.org/10.1186/s40561-024-00316-7** [V-pub; article number 28 from memory, unverified]
  - A review of 14 articles. It concludes that over-reliance, fed by ethical issues such as hallucination, bias and opacity, affects decision-making, critical thinking and analytical reasoning.
  - Sources: [ERIC EJ1428486](https://eric.ed.gov/?q=ieee&ff1=subTechnology+Uses+in+Education&id=EJ1428486); [Crossmark](https://crossmark.crossref.org/dialog/?doi=10.1186%2Fs40561-024-00316-7).
- **Farhat, Z. (2026). When AI thinks for us: Unveiling the cognitive and social toll of ChatGPT over-reliance. *Applied Cognitive Psychology, 40*(3). https://doi.org/10.1002/acp.70205** [V-SG]
  - A qualitative interview study framed by Cognitive Load Theory, Risko & Gilbert's offloading account and SDT.
  - Participants reported declining memory retention ("I don't retain much"), reduced critical thinking with over-reliance, and adaptive strategies such as putting in deliberate effort before consulting AI.
  - Self-report only. Useful as a qualitative parallel to the present study — [Wiley](https://onlinelibrary.wiley.com/ai/10.1002/acp.70205).
- **Patrick, P. M., Yip, S. Y., & Campbell, C. (2025). Artificial intelligence and higher-order thinking: A systematic review of educator and student experiences and perspectives in higher education. *Higher Education Quarterly, 79*(4). https://doi.org/10.1111/hequ.70069** [V-SG]
  - "Overreliance emerged as a consistent theme" across the reviewed studies. Educators feared it would hinder higher-order thinking — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/hequ.70069).
- Already in the drafts, not re-checked here: Lee et al. (2025, CHI), Macnamara et al. (2024), Fisher et al. (2015).

### Inferences
- Suggested cluster for dimension 1 (offloading lowers effort or depth): **(Gerlich, 2025; Grinschgl vd., 2021; Risko & Gilbert, 2016; Stadler vd., 2024)**. Add Melumad & Yun (2025) for depth of learning, and Kosmyna vd. (2025, ön baskı) only if labelled.
- For "offloading is not intrinsically harmful": **(Cash vd., 2026; Li vd., 2026; Risko & Gilbert, 2016)**. Li et al. show that scaffolded designs give gains, while unstructured ones trigger offloading.

### Gaps
- There are few longitudinal studies of university students' offloading to GenAI. Most evidence is single-session or cross-sectional.

---

## Part B2: Metacognition, SRL and student agency with GenAI

### Takeaway
Experimental and trace-data studies suggest that AI assistance can take over regulation (monitoring, evaluation) from students. Explicit metacognitive scaffolds can reverse this. This is direct support for dimension 2 (metacognitive laxity).

### Cited Findings
- **Darvishi, A., Khosravi, H., Sadiq, S., Gašević, D., & Siemens, G. (2024). Impact of AI assistance on student agency. *Computers & Education, 210*, Article 104967. https://doi.org/10.1016/j.compedu.2023.104967** [V-pub]
  - Students "tend to rely on, rather than learn from, AI assistance". Self-regulation strategies can partly replace AI assistance but are not as effective.
  - Sources: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0360131523002440); [Monash](https://research.monash.edu/en/publications/impact-of-ai-assistance-on-student-agency/).
  - Note: this study concerns AI assistance in a peer-feedback platform, not a general chatbot. Say so if cited.
- **Iqbal, S., Jovanović, J., Fan, Y., Raković, M., Li, X., Chen, G., & Gašević, D. (2026). Human or GenAI support? Conditions impacting students' strategy choices in an essay revision task. *Journal of Computer Assisted Learning, 42*(5). https://doi.org/10.1002/jcal.70300** [V-SG]
  - Trace data from 87 participants, modelled with Mixture Markov Models.
  - The type of support (GenAI, human expert or none) was strongly associated with the SRL strategies students used during revision.
  - Discussion: "constant availability of external support may prevent students from relying on and developing their own internal metacognitive judgement" — [Wiley](https://onlinelibrary.wiley.com/ai/10.1002/jcal.70300). The article number was not shown.
- **Xu, X., Qiao, L., Cheng, N., Liu, H., & Zhao, W. (2025). Enhancing self-regulated learning and learning experience in generative AI environments: The critical role of metacognitive support. *British Journal of Educational Technology, 56*(5), 1842–1863. https://doi.org/10.1111/bjet.13599** [V-SG]
  - The group that received metacognitive support improved on all six SRL dimensions, most in task strategy, help seeking and self-evaluation.
  - The control group, using GenAI without support, **declined in five SRL dimensions** (goal setting, environment structuring, task strategy, time management, self-evaluation) — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.13599).
- **Yan, L., Pammer-Schindler, V., Mills, C., Nguyen, A., & Gašević, D. (2025). Beyond efficiency: Empirical insights on generative AI's impact on cognition, metacognition and epistemic agency in learning. *British Journal of Educational Technology, 56*(5), 1675–1685. https://doi.org/10.1111/bjet.70000** [V-SG]
  - An editorial for a special section. It says the evidence shows benefits (personalised guidance, self-reflection) and also risks: "diminished epistemic vigilance, superficial learning and emotional dependence on AI interlocutors".
  - It notes that meta-analyses have "predominantly focused on performance-related outcomes" (Deng et al., 2025; Wang & Fan, 2025) — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.70000).
- **Molenaar, I. (2022a). Towards hybrid human-AI learning technologies. *European Journal of Education, 57*(4), 632–645. https://doi.org/10.1111/ejed.12527** [V-pub: [Wiley](https://onlinelibrary.wiley.com/doi/10.1111/ejed.12527); [ERIC EJ1355004](https://eric.ed.gov/?id=EJ1355004)]
- **Molenaar, I. (2022b). The concept of hybrid human-AI regulation: Exemplifying how to support young learners' self-regulated learning. *Computers and Education: Artificial Intelligence, 3*, Article 100070. https://doi.org/10.1016/j.caeai.2022.100070** [V-sec; the DOI is from the journal pattern and was not seen in a listing]
  - This is the hybrid human–AI regulation idea: control over regulation should move gradually between AI and learner. Fan et al. (2025) cite it in arguing that offloading metacognition to AI can harm transfer.
- **Lodge, J. M., de Barba, P., & Broadbent, J. (2023). Learning with generative artificial intelligence within a network of co-regulation. *Journal of University Teaching and Learning Practice, 20*(7). https://doi.org/10.53761/1.20.7.02** [V-pub: [Monash](https://research.monash.edu/en/publications/learning-with-generative-artificial-intelligence-within-a-network/)]
  - A commentary that places GenAI within learners' network of co-regulation (with teachers and peers) and argues against focusing only on misconduct.
- **Wang, T., Li, S., Li, S., Zhang, J., & Gao, J. (2026). Students' use patterns of generative artificial intelligence during problem-solving in an intelligent learning system: Achievement goal orientation matters. *British Journal of Educational Technology, 57*(4), 1163–1188. https://doi.org/10.1111/bjet.70059** [V-SG]
  - The study looks at *when* students request GenAI assistance within their SRL processes, across achievement-goal-orientation profiles. Mastery-oriented learners linked GenAI use more strongly to their SRL — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.70059).
  - This ties help-seeking goals (the Karabenick tradition) to GenAI use.

### Inferences
- Suggested cluster for dimension 2 (regulation delegated to the tool): **(Darvishi vd., 2024; Fan vd., 2025; Iqbal vd., 2026; Tankelevitch vd., 2024; Xu vd., 2025)**.
- Suggested cluster for the view that regulation can be shared or scaffolded rather than simply lost: **(Lodge vd., 2023; Molenaar, 2022a; Xu vd., 2025)**.

### Gaps
- I found no systematic review that focuses only on SRL and GenAI and that I could verify in this session.

---

## Part B3: Help seeking from GenAI vs humans (instructors, peers) among university students

### Takeaway
University students increasingly go to GenAI first for help, especially for quick, well-defined problems, because of speed and low social cost. Qualitative evidence shows this can crowd out peer help. Humans remain preferred for some purposes. This supports treating "first-resort use" as distinct from dependence, which is what the drafts already do.

### Cited Findings
- **Hou, I., Mettille, S., Man, O., Li, Z., Zastudil, C., & MacNeil, S. (2024). The effects of generative AI on computing students' help-seeking preferences. In *Proceedings of the 26th Australasian Computing Education Conference* (pp. 39–48). ACM. https://doi.org/10.1145/3636243.3636248** [V-pub; the page range is from memory, unverified]
  - Compares ChatGPT with existing help resources (instructors, TAs, peers, online resources) on perceived quality, latency and trustworthiness.
  - Sources: [ACM DL](https://dl.acm.org/doi/fullHtml/10.1145/3636243.3636248); [DBLP](https://dblp.org/rec/journals/corr/abs-2401-02262.html).
- **Hou, I., Man, O., Hamilton, K., Muthusekaran, S., Johnykutty, J., Zadeh, L., & MacNeil, S. (2025). "All roads lead to ChatGPT": How generative AI is eroding social interactions and student learning communities. In *Proceedings of the 30th ACM Conference on Innovation and Technology in Computer Science Education V. 1*. ACM. https://doi.org/10.1145/3724363.3729024** [V-pub]
  - 17 semi-structured interviews with undergraduate computing students at seven North American R1 universities.
  - Help-seeking requests are increasingly mediated by GenAI. Peers redirect questions to ChatGPT instead of helping. Students reported feeling isolated and demotivated.
  - Sources: [ACM DL](https://dl.acm.org/doi/10.1145/3724363.3729024); [arXiv](https://arxiv.org/abs/2504.09779).
- **Le, H., Shen, Y., Li, Z., Xia, M., Tang, L., Li, X., Jia, J., Wang, Q., Gašević, D., & Fan, Y. (2025). Breaking human dominance: Investigating learners' preferences for learning feedback from generative AI and human tutors. *British Journal of Educational Technology, 56*(5), 1758–1783. https://doi.org/10.1111/bjet.13614** [V-SG]
  - An experiment with 114 university students. Before the task there was a strong preference for human tutors.
  - After exposure, preference for the free-dialogue ChatGPT interface rose, while a structured AI tool reinforced the preference for humans.
  - The authors warn this "may potentially lead to over-reliance and metacognitive laziness" — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.13614).
- **Viberg et al. (2026)** (Part A8): LLMs are preferred for simple, well-defined tasks, and peers and instructors for other purposes. Help seeking is layered and context-dependent.
- **Help-seeking theory** (Part A7): Nelson-Le Gall (1981, 1985); Karabenick (2004); Karabenick & Dembo (2011).
  - Monitoring accuracy (knowing that you need help) is the "linchpin" of the help-seeking process ([Davison, Malmberg & Sylva, 2022, *BJEP* 93(1), 33–55, https://doi.org/10.1111/bjep.12538](https://onlinelibrary.wiley.com/ai/10.1111/bjep.12538), citing Karabenick & Berger, 2013).
  - Low performers are the least likely to seek needed help from people (Karabenick & Knapp, 1991, as cited in Davison et al., 2022). The low social threat of a chatbot may change this, which is an inference and not tested.

### Inferences
- Suggested cluster for "GenAI is reshaping help-seeking source choice": **(Hou vd., 2024; Hou vd., 2025; Le vd., 2025; Viberg vd., 2026)**.
- Suggested cluster for "the function of help depends on goals, not source": **(Karabenick, 2004; Karabenick & Dembo, 2011; Nelson-Le Gall, 1985; Wang vd., 2026)**.
- The drafts' decision not to count "shift from human to tool" as an indicator is supported by this literature. The shift is often explained by access and latency (Hou et al., 2024), not by regulatory abdication.

### Gaps
- Both Hou et al. studies are in computing education (US). I found no verified study of Turkish university students' help seeking from GenAI vs humans (see B5).

---

## Part B4: GenAI improves task performance but not necessarily learning

### Takeaway
Across randomised experiments, GenAI support raises output quality or practice performance during use. Unassisted or delayed learning outcomes are unchanged or lower unless the design protects the learner's own effort. Meta-analyses that report positive "performance" effects mostly measure performance, not retention or transfer, so they should be cited as a counterpoint with that caveat.

### Cited Findings
- **Bastani et al. (2025)**: +48% (GPT Base) and +127% (GPT Tutor) on assisted practice; −17% for GPT Base on the unassisted exam vs control; harm "largely mitigated" in GPT Tutor — [PNAS](https://www.pnas.org/doi/10.1073/pnas.2422633122).
- **Fan et al. (2025)**: the ChatGPT group improved essay scores significantly more than the other groups; no group differences in knowledge gain or transfer — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.13544).
- **Kreijkes et al. (2026)**: LLM alone was worse than note-taking, alone or with the LLM, for comprehension and retention at three days — [EurekAlert](https://www.eurekalert.org/news-releases/1108126).
- **Melanou, C., Beege, M., & Kimmig, M. (2026). Generative AI and learning dynamics in higher education: A longitudinal empirical study. *Journal of Computer Assisted Learning, 42*(5). https://doi.org/10.1002/jcal.70322** [V-SG, open access]
  - A semester-long quasi-experiment with three business-informatics classes (N = 87): tutor-AI, unguided AI, and a no-AI control.
  - "Students showed significant knowledge gains across all groups, but **no additional benefits of AI integration**." Critical thinking stayed stable. Reflective use was higher in the AI condition and positively associated with critical thinking — [Wiley](https://onlinelibrary.wiley.com/ai/10.1002/jcal.70322).
- **Tang, Q., Deng, W., Huang, Y., Wang, S., & Zhang, H. (2025). Can generative artificial intelligence be a good teaching assistant?—An empirical analysis based on generative AI-assisted teaching. *Journal of Computer Assisted Learning, 41*(3). https://doi.org/10.1111/jcal.70027** [V-SG]
  - A middle-school quasi-experiment with three classes (45/41/45).
  - GenAI-assisted teaching raised satisfaction but **did not improve engagement or knowledge mastery** compared with traditional computer-assisted teaching. Teacher supervision improved both — [Wiley](https://onlinelibrary.wiley.com/ai/10.1111/jcal.70027). This is secondary-level evidence.
- **Wong & Qiu (2026)**: unguided ChatGPT use gave a smaller later independent-originality benefit than the "think first" approach — [Springer](https://link.springer.com/article/10.1007/s10648-026-10118-7).
- **Stadler et al. (2024)**: lower load and weaker justifications — [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0747563224002541).
- **Counterpoint — Deng, R., Jiang, M., Yu, X., Lu, Y., & Liu, S. (2025). Does ChatGPT enhance student learning? A systematic review and meta-analysis of experimental studies. *Computers & Education, 227*, Article 105224. https://doi.org/10.1016/j.compedu.2024.105224** [V-pub; surnames confirmed, initials from memory]
  - 69 experimental studies (2022–2024). Positive effects on academic performance, affective-motivational states and higher-order-thinking propensities. Reduced mental effort. No effect on self-efficacy.
  - Sources: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0360131524002380); [ACM mirror](https://dl.acm.org/doi/10.1016/j.compedu.2024.105224).
  - The Yan, Pammer-Schindler et al. (2025) editorial explicitly notes that such meta-analyses focus on performance outcomes ([Wiley](https://onlinelibrary.wiley.com/ai/10.1111/bjet.70000)).

### Inferences
- Suggested cluster for "assisted performance ≠ learning": **(Bastani vd., 2025; Fan vd., 2025; Kreijkes vd., 2026; Melanou vd., 2026; Yan vd., 2025)**.
- Suggested cluster for "designs that protect learner effort reduce harm": **(Bastani vd., 2025; Kreijkes vd., 2026; Li vd., 2026; Wong & Qiu, 2026; Xu vd., 2025)**.
- For balance, one sentence citing Deng et al. (2025) as evidence of positive performance effects, with the measurement caveat, would pre-empt reviewer objections.

### Gaps
- No verified study measured *delayed transfer* after sustained (more than one semester) GenAI use in higher education.

---

## Part B5: Turkish studies (TR Dizin) on ChatGPT and learning, critical thinking, SRL, dependence or offloading

### Takeaway
**This part is incomplete.** The TR Dizin API (`search.trdizin.gov.tr`) was blocked by the network proxy, and the web-search budget ran out mid-task. I confirmed one Turkish teacher-candidate article with full metadata and DOI, and one AI-dependence scale adaptation with DOI but no author names. Other candidates are listed as UNVERIFIED. None of the confirmed items has been checked for TR Dizin indexing.

### Cited Findings
- **Eroğlu, A., & Ateş, A. (2025). Türkçe öğretmeni adaylarının ChatGPT kullanım deneyimleri. *Sakarya Üniversitesi Eğitim Fakültesi Dergisi, 25*(2), 194–223. https://doi.org/10.53629/sakaefd.1797431** [V-pub: [DergiPark](https://dergipark.org.tr/tr/pub/sakaefd/article/1797431)]
  - Turkish-language teacher candidates used ChatGPT mostly for educational purposes such as lesson planning and homework preparation.
  - Relevant to the pre-service-teacher context of the present study. TR Dizin indexing of this journal was not confirmed in this session.
- **[Authors UNVERIFIED] (2024). Yapay zekâya bağımlılık ölçeğinin Türkçe'ye uyarlanması: Geçerlik ve güvenirlik çalışması. *Journal of Sport for All and Recreation, 6*(3), 306–315. https://doi.org/10.56639/jsar.1509301** [V-pub partial: [DergiPark](https://dergipark.org.tr/en/pub/jsar/article/1509301?issue_id=86557)]
  - A Turkish adaptation of Morales-García et al.'s (2024) Scale for Dependence on Artificial Intelligence, with **584 university students**; the scale was reported valid and reliable.
  - Directly relevant to how "dependent use" is conceptualised, but the author names must be added before citing.
- **UNVERIFIED (metadata incomplete):**
  - "Yapay zekâ tabanlı ChatGPT'ye dayalı etkinliklerin 7. sınıf öğrencilerin metin yazma, eleştirel ve yaratıcı düşünme becerilerine etkisi", *Bingöl Üniversitesi Sosyal Bilimler Enstitüsü Dergisi* (2025) — [DergiPark](https://dergipark.org.tr/en/pub/busbed/article/1621042). Reported that the experimental group scored higher in critical and creative thinking and in writing. This is secondary school, not university; authors and DOI not seen.
  - "Yapay Zekâ Sohbet Botu Bağımlılık Ölçeğinin Türkçeye Uyarlanması" — only a [ResearchGate listing](https://www.researchgate.net/publication/390810952_Yapay_Zeka_Sohbet_Botu_Bagimlilik_Olceginin_Turkceye_Uyarlanmasi); journal, authors and DOI not seen.
  - "Türkçe Öğretimi ve Üretken Yapay Zekâ: Öğretmen Adayları ile Bir Çalışma", *NEÜ Ereğli Eğitim Fakültesi Dergisi* — [DergiPark](https://dergipark.org.tr/tr/pub/neueefd/article/1750191); metadata not seen.
  - "Examination of Pre-Service Teachers' Use of Artificial Intelligence", *Adıyaman University Journal of Educational Sciences* — [DergiPark](https://dergipark.org.tr/en/pub/adyuebd/article/1754343); metadata not seen.
- Turkish studies already in the drafts (Dulkadir Yaman, 2025; Karataş & Yüce, 2024; Şat vd., 2026; Özüdoğru & Delen, 2026) were outside the scope of this check.

### Inferences
- The AI-dependence scale adaptation (JSAR, 2024) is worth citing when positioning the four candidate dimensions against existing *quantitative* operationalisations of dependence in Turkey. It frames dependence as a single scale score, whereas the present study proposes content dimensions.

### Gaps
- Run the TR Dizin queries from an unrestricted machine: "ChatGPT eleştirel düşünme", "yapay zeka öz düzenleme", "yapay zeka bilişsel yük", "yapay zeka yardım arama", "ChatGPT akademik başarı". Then complete the authors and DOIs for the UNVERIFIED items above.
- I could not find or verify Turkish university-level experimental studies on unassisted learning outcomes after ChatGPT use.
