/* Güvenirlik Laboratuvarı: saf hesaplama çekirdeği (RelCore).
 * Ekrandaki her sayı bu modülden gelir. DOM'a dokunmaz.
 * Tarayıcıda globalThis.RelCore, Node'da module.exports. */
(function (root) {
  'use strict';

  // ---------------------------------------------------------------------------
  // Temel betimsel istatistik (iki geçişli; büyük sabit eklemede kararlı)
  // ---------------------------------------------------------------------------
  function sum(a) { let s = 0; for (let i = 0; i < a.length; i++) s += a[i]; return s; }
  function mean(a) { return sum(a) / a.length; }
  function ddofOf(denom) { return denom === 'n' ? 0 : 1; }
  function variance(a, denom) {
    const m = mean(a); let ss = 0;
    for (let i = 0; i < a.length; i++) { const d = a[i] - m; ss += d * d; }
    return ss / (a.length - ddofOf(denom));
  }
  function covariance(a, b, denom) {
    const ma = mean(a), mb = mean(b); let s = 0;
    for (let i = 0; i < a.length; i++) s += (a[i] - ma) * (b[i] - mb);
    return s / (a.length - ddofOf(denom));
  }
  function correlation(a, b) {
    return covariance(a, b) / Math.sqrt(variance(a) * variance(b));
  }
  function deviations(a) { const m = mean(a); return a.map(x => x - m); }
  function zScores(a, denom) {
    const m = mean(a), s = Math.sqrt(variance(a, denom));
    return a.map(x => (x - m) / s);
  }
  function column(data, j) { return data.map(r => r[j]); }
  function columns(data) { return data[0].map((_, j) => column(data, j)); }
  function rowSums(data) { return data.map(r => sum(r)); }

  // ---------------------------------------------------------------------------
  // Matris görünümü
  // ---------------------------------------------------------------------------
  function covMatrix(data, denom) {
    const cols = columns(data), k = cols.length, S = [];
    for (let i = 0; i < k; i++) {
      S.push([]);
      for (let j = 0; j < k; j++) S[i].push(covariance(cols[i], cols[j], denom));
    }
    return S;
  }
  function trace(S) { let t = 0; for (let i = 0; i < S.length; i++) t += S[i][i]; return t; }
  function sumAll(S) { let t = 0; for (const r of S) for (const x of r) t += x; return t; }
  function offDiagSum(S) { return sumAll(S) - trace(S); }
  function offDiagMean(S) { const k = S.length; return offDiagSum(S) / (k * (k - 1)); }
  function matrixSummary(S) {
    const k = S.length, tr = trace(S), tot = sumAll(S), off = tot - tr, sbar = off / (k * (k - 1));
    const trueTotal = k * k * sbar;
    const residuals = S.map((r, i) => r[i] - sbar); // köşegen doldurma kalanları
    return {
      k, trace: tr, total: tot, offDiag: off, meanOffDiag: sbar, trueVarTotal: trueTotal,
      errorVarTotal: tot - trueTotal, itemResiduals: residuals,
      negativeResidual: residuals.map(x => x < 0),
      alpha: (k / (k - 1)) * (1 - tr / tot), alphaAlt: trueTotal / tot,
    };
  }
  function cholesky(S) {
    const n = S.length, L = S.map(() => new Array(n).fill(0));
    for (let i = 0; i < n; i++) {
      for (let j = 0; j <= i; j++) {
        let s = S[i][j];
        for (let m = 0; m < j; m++) s -= L[i][m] * L[j][m];
        if (i === j) { if (s <= 1e-12) return null; L[i][i] = Math.sqrt(s); }
        else L[i][j] = s / L[j][j];
      }
    }
    return L;
  }
  function isPositiveDefinite(S) { return cholesky(S) !== null; }

  // ---------------------------------------------------------------------------
  // α: üç yol
  // ---------------------------------------------------------------------------
  function alphaVariance(data, denom) {
    const cols = columns(data), k = cols.length;
    const itemSum = sum(cols.map(c => variance(c, denom)));
    const tot = variance(rowSums(data), denom);
    return (k / (k - 1)) * (1 - itemSum / tot);
  }
  function alphaMatrix(data, denom) { return matrixSummary(covMatrix(data, denom)).alpha; }
  function alphaFromMatrix(S) { return matrixSummary(S).alpha; }

  // Kişi × madde ANOVA (tekrarsız iki yönlü), G çalışması
  function anova(data) {
    const n = data.length, k = data[0].length, N = n * k;
    let g = 0; for (const r of data) for (const x of r) g += x; g /= N;
    const pm = data.map(r => mean(r));
    const im = columns(data).map(c => mean(c));
    let SSp = 0, SSi = 0, SSt = 0, SSres = 0;
    for (let p = 0; p < n; p++) SSp += (pm[p] - g) * (pm[p] - g);
    SSp *= k;
    for (let i = 0; i < k; i++) SSi += (im[i] - g) * (im[i] - g);
    SSi *= n;
    for (let p = 0; p < n; p++) for (let i = 0; i < k; i++) {
      const d = data[p][i] - g; SSt += d * d;
      const r = data[p][i] - pm[p] - im[i] + g; SSres += r * r;
    }
    const dfp = n - 1, dfi = k - 1, dfres = (n - 1) * (k - 1);
    const MSp = SSp / dfp, MSi = dfi > 0 ? SSi / dfi : 0, MSres = SSres / dfres;
    const rawP = (MSp - MSres) / k, rawI = (MSi - MSres) / n, rawE = MSres;
    const flags = { p: rawP < 0, i: rawI < 0 };
    const comps = { p: Math.max(0, rawP), i: Math.max(0, rawI), pie: rawE };
    return {
      n, k, grand: g, personMeans: pm, itemMeans: im,
      personEffects: pm.map(x => x - g), itemEffects: im.map(x => x - g),
      SSp, SSi, SSres, SSt, dfp, dfi, dfres, MSp, MSi, MSres,
      hoyt: 1 - MSres / MSp, rawComps: { p: rawP, i: rawI, pie: rawE }, comps,
      clamped: flags.p || flags.i, clampFlags: flags,
    };
  }
  function alphaAnova(data) { return anova(data).hoyt; }
  function gCoefficients(comps, nPrime) {
    const Erho2 = comps.p / (comps.p + comps.pie / nPrime);
    const Phi = comps.p / (comps.p + (comps.i + comps.pie) / nPrime);
    return { Erho2, Phi, relErr: comps.pie / nPrime, absErr: (comps.i + comps.pie) / nPrime };
  }
  function phiLambda(comps, mu, lambda, nPrime) {
    const d2 = (mu - lambda) * (mu - lambda), absErr = (comps.i + comps.pie) / nPrime;
    return (comps.p + d2) / (comps.p + d2 + absErr);
  }
  // Puanlayıcı görünümü: K çalışması deseni (çaprazlanmış / iç içe)
  function dStudyRaters(comps, nPrime, design) {
    if (design === 'nested') {
      const e = (comps.i + comps.pie) / nPrime; const v = comps.p / (comps.p + e);
      return { Erho2: v, Phi: v, nestedComp: comps.i + comps.pie };
    }
    return gCoefficients(comps, nPrime);
  }
  function oneWay(data) {
    const n = data.length, k = data[0].length;
    const pm = data.map(r => mean(r)); let g = mean(pm);
    let SSb = 0, SSw = 0;
    for (let p = 0; p < n; p++) {
      SSb += k * (pm[p] - g) * (pm[p] - g);
      for (let i = 0; i < k; i++) SSw += (data[p][i] - pm[p]) * (data[p][i] - pm[p]);
    }
    const MSb = SSb / (n - 1), MSw = SSw / (n * (k - 1));
    const sp = (MSb - MSw) / k;
    return { SSb, SSw, MSb, MSw, sigmaP: sp, icc1k: (MSb - MSw) / MSb, icc11: sp / (sp + MSw) };
  }
  function iccC1(an) { return (an.MSp - an.MSres) / (an.MSp + (an.k - 1) * an.MSres); }
  function iccCk(an) { return (an.MSp - an.MSres) / an.MSp; }
  function iccAk(an) { return (an.MSp - an.MSres) / (an.MSp + (an.MSi - an.MSres) / an.n); }
  // ICC(A,1) bileşen biçiminden, negatif bileşen 0'a çekilerek (SPEC_SORULARI 19b)
  function iccA1(an) { const c = an.comps; return c.p / (c.p + c.i + c.pie); }

  // ---------------------------------------------------------------------------
  // Yarıya bölme
  // ---------------------------------------------------------------------------
  function combinations(arr, r) {
    const out = [];
    (function rec(start, acc) {
      if (acc.length === r) { out.push(acc.slice()); return; }
      for (let i = start; i < arr.length; i++) { acc.push(arr[i]); rec(i + 1, acc); acc.pop(); }
    })(0, []);
    return out;
  }
  // k çiftse eşit bölmeler; k tekse (k-1)/2 ve (k+1)/2 bölmeleri. Her bölme bir kez.
  function allSplits(k) {
    const idx = [...Array(k).keys()];
    if (k % 2 === 0) {
      return combinations(idx, k / 2).filter(A => A[0] === 0).map(A => [A, idx.filter(i => !A.includes(i))]);
    }
    return combinations(idx, (k - 1) / 2).map(A => [A, idx.filter(i => !A.includes(i))]);
  }
  function sampledSplits(k, count, seed) {
    const rng = mulberry32(fnv1a(seed + '|bolme|' + k)); const out = [];
    for (let s = 0; s < count; s++) {
      const idx = [...Array(k).keys()];
      for (let i = k - 1; i > 0; i--) { const j = Math.floor(rng() * (i + 1)); [idx[i], idx[j]] = [idx[j], idx[i]]; }
      const h = Math.floor(k / 2);
      out.push([idx.slice(0, h).sort((a, b) => a - b), idx.slice(h).sort((a, b) => a - b)]);
    }
    return out;
  }
  function halfScores(data, items) { return data.map(r => sum(items.map(i => r[i]))); }
  function splitStats(data, A, B, denom) {
    const a = halfScores(data, A), b = halfScores(data, B), y = rowSums(data);
    const vA = variance(a, denom), vB = variance(b, denom), cAB = covariance(a, b, denom), vY = variance(y, denom);
    const rhh2 = cAB * cAB / (vA * vB), rhh = cAB / Math.sqrt(vA * vB);
    const d = a.map((x, i) => x - b[i]);
    return {
      A, B, varA: vA, varB: vB, covAB: cAB, rhh, rhh2,
      sb: 2 * rhh / (1 + rhh),
      flanaganRulon: 2 * (1 - (vA + vB) / vY),
      rulon: 1 - variance(d, denom) / vY,
    };
  }
  function splitSummary(data, maxExact) {
    const k = data[0].length;
    const splits = k <= (maxExact || 12) ? allSplits(k) : sampledSplits(k, 1000, 1);
    const stats = splits.map(([A, B]) => splitStats(data, A, B));
    return {
      splits: stats, count: stats.length,
      meanFR: mean(stats.map(s => s.flanaganRulon)), meanSB: mean(stats.map(s => s.sb)),
      alpha: alphaVariance(data), oddFactor: k % 2 ? (k * k - 1) / (k * k) : 1,
    };
  }

  // ---------------------------------------------------------------------------
  // Diğer katsayılar
  // ---------------------------------------------------------------------------
  function guttman(data, denom) {
    const S = covMatrix(data, denom), k = S.length, tot = sumAll(S), tr = trace(S);
    let off2 = 0; for (let i = 0; i < k; i++) for (let j = 0; j < k; j++) if (i !== j) off2 += S[i][j] * S[i][j];
    const L1 = 1 - tr / tot;
    return { L1, L2: L1 + Math.sqrt((k / (k - 1)) * off2) / tot };
  }
  function guttmanFromSigma(S) {
    const k = S.length, tot = sumAll(S), tr = trace(S);
    let off2 = 0; for (let i = 0; i < k; i++) for (let j = 0; j < k; j++) if (i !== j) off2 += S[i][j] * S[i][j];
    return 1 - tr / tot + Math.sqrt((k / (k - 1)) * off2) / tot;
  }
  function itemCorrelations(data) {
    const cols = columns(data), k = cols.length, out = [];
    for (let i = 0; i < k; i++) for (let j = i + 1; j < k; j++) out.push({ i, j, r: correlation(cols[i], cols[j]) });
    return out;
  }
  function alphaStd(data) {
    const rs = itemCorrelations(data), k = data[0].length, rbar = mean(rs.map(x => x.r));
    return { rbar, alphaStd: k * rbar / (1 + (k - 1) * rbar), correlations: rs };
  }
  function dropItem(data, j) { return data.map(r => r.filter((_, i) => i !== j)); }
  function alphaIfDeleted(data) { return data[0].map((_, j) => alphaVariance(dropItem(data, j))); }
  function correctedItemTotal(data) {
    return data[0].map((_, j) => correlation(column(data, j), rowSums(dropItem(data, j))));
  }
  function itemAnalysis(data) {
    const a = alphaVariance(data), del = alphaIfDeleted(data), cit = correctedItemTotal(data);
    return data[0].map((_, j) => ({ item: j, alphaIfDeleted: del[j], direction: del[j] > a ? 'yükselir' : 'düşer', correctedR: cit[j] }));
  }

  // KR-20 / KR-21 (0/1 veri). KR-20'de p_i q_i örtük olarak n paydalıdır.
  function krStats(data, denom) {
    const n = data.length, k = data[0].length, cols = columns(data);
    const p = cols.map(c => mean(c)), pq = p.map(x => x * (1 - x));
    const y = rowSums(data), M = mean(y), vN = variance(y, 'n');
    const sumPQ = sum(pq);
    const kr20 = (k / (k - 1)) * (1 - sumPQ / vN);
    const kr21 = (k / (k - 1)) * (1 - M * (k - M) / (k * vN));
    // Anahtar n-1'deyken kart p_i q_i · n/(n-1) ve s_Y^2 yazar; sonuç aynıdır.
    const itemVarShown = denom === 'n' ? pq : pq.map(x => x * n / (n - 1));
    const totShown = denom === 'n' ? vN : variance(y);
    const kr20Shown = (k / (k - 1)) * (1 - sum(itemVarShown) / totShown);
    const mixed = (k / (k - 1)) * (1 - sumPQ / variance(y));
    return { n, k, p, pq, sumPQ, M, varN: vN, kr20, kr21, itemVarShown, totShown, kr20Shown, mixed, semSq: vN * (1 - kr20) };
  }
  // Payda karışımı tanısı: öğrencinin yanıtı karışık payda sonucuyla eşleşiyor mu?
  function detectMixedDenominator(data, answer, tol) {
    const s = krStats(data); const t = tol == null ? 5e-4 : tol;
    return Math.abs(answer - s.mixed) < t && Math.abs(answer - s.kr20) >= t;
  }
  // α sekmesi tanısal geri bildirimi
  function diagnoseAlpha(data, answer, tol) {
    const t = tol == null ? 0.006 : tol, k = data[0].length, cols = columns(data), y = rowSums(data);
    const iv = sum(cols.map(c => variance(c))), tv = variance(y), a = alphaVariance(data);
    const cands = [
      ['dogru', a],
      ['sd_kullanildi', (k / (k - 1)) * (1 - sum(cols.map(c => Math.sqrt(variance(c)))) / Math.sqrt(tv))],
      ['carpan_unutuldu', 1 - iv / tv],
      ['karisik_payda', (k / (k - 1)) * (1 - sum(cols.map(c => variance(c, 'n'))) / tv)],
      ['sb_uygulandi', 2 * a / (1 + a)],
      ['toplam_yerine_madde', (k / (k - 1)) * (1 - iv / iv)],
    ];
    for (const [code, v] of cands) if (Math.abs(answer - v) < t) return code;
    return 'bilinmiyor';
  }
  function diagnoseR(x1, x2, answer, tol) {
    const t = tol == null ? 0.006 : tol, r = correlation(x1, x2);
    const sxy = sum(x1.map((x, i) => x * x2[i])), sx2 = sum(x1.map(x => x * x)), sy2 = sum(x2.map(x => x * x));
    const d1 = deviations(x1), d2 = deviations(x2);
    const cands = [
      ['dogru', r],
      ['ham_puan', sxy / Math.sqrt(sx2 * sy2)],
      ['kok_unutuldu', sum(d1.map((x, i) => x * d2[i])) / (sum(d1.map(x => x * x)) * sum(d2.map(x => x * x)))],
      ['toplamlarin_carpimi', sum(d1) * sum(d2)],
    ];
    for (const [code, v] of cands) if (Math.abs(answer - v) < t) return code;
    return 'bilinmiyor';
  }

  // ÖSH ve bantlar
  function sem(sdX, rho) { return sdX * Math.sqrt(1 - rho); }
  function seEstimate(sdX, rho) { return sdX * Math.sqrt(rho * (1 - rho)); }
  function sePrediction(sdX, rho) { return sdX * Math.sqrt(1 - rho * rho); }
  function kelley(x, rho, mu) { return rho * x + (1 - rho) * mu; }
  function band(center, se, z) { const zz = z == null ? 1.96 : z; return [center - zz * se, center + zz * se]; }
  function lordCSEM(x, k) { return Math.sqrt(x * (k - x) / (k - 1)); }
  function binom(n, r) { let c = 1; for (let i = 1; i <= r; i++) c = c * (n - r + i) / i; return c; }
  // Binom hata modelinde X ± z·ÖSH bandının kapsama olasılığı (gerçek oran ζ)
  function binomialCoverage(k, zeta, semVal, z) {
    const half = (z == null ? 1.96 : z) * semVal, T = k * zeta; let p = 0;
    for (let x = 0; x <= k; x++) if (Math.abs(x - T) <= half + 1e-12) p += binom(k, x) * Math.pow(zeta, x) * Math.pow(1 - zeta, k - x);
    return p;
  }
  function spearmanBrown(rho, m) { return m * rho / (1 + (m - 1) * rho); }
  function lengthFactor(rho, target) { return target * (1 - rho) / (rho * (1 - target)); }
  function reliabilityNewGroup(rho, varX, varNew) { return 1 - varX * (1 - rho) / varNew; }
  function reliabilityFromSEM(semSq, varNew) { return 1 - semSq / varNew; }
  function attenuationCorrect(rxy, rxx, ryy) { return rxy / Math.sqrt(rxx * ryy); }
  function maxPhi(pi, pj) { const a = Math.min(pi, pj), b = Math.max(pi, pj); return Math.sqrt(a * (1 - b) / (b * (1 - a))); }

  // İki form (M5): fark, kovaryans ve köşegen yolları
  function twoForms(x1, x2, denom) {
    const s1 = variance(x1, denom), s2 = variance(x2, denom), s12 = covariance(x1, x2, denom);
    const d = x1.map((x, i) => x - x2[i]), sD = variance(d, denom);
    const errVar = sD / 2, meanVar = (s1 + s2) / 2;
    const dev1 = deviations(x1), dev2 = deviations(x2);
    return {
      mean1: mean(x1), mean2: mean(x2), s1, s2, s12, r: correlation(x1, x2),
      sumSq1: sum(dev1.map(x => x * x)), sumSq2: sum(dev2.map(x => x * x)), sumCross: sum(dev1.map((x, i) => x * dev2[i])),
      D: d, meanD: mean(d), sD, errVar, meanVar, rel: 1 - errVar / meanVar, semDiff: Math.sqrt(errVar),
      S: [[s1, s12], [s12, s2]], residuals: [s1 - s12, s2 - s12], residualMean: (s1 + s2) / 2 - s12,
      zIdentity: sum(zScores(x1).map((z, i) => z * zScores(x2)[i])) / (x1.length - 1),
      zWrong: sum(zScores(x1).map((z, i) => z * zScores(x2)[i])) / x1.length,
    };
  }

  // ---------------------------------------------------------------------------
  // Popülasyon modelleri
  // ---------------------------------------------------------------------------
  // Tek faktör: Σ = λλᵀ + Ψ. psi köşegen dizi veya {i,j,v} listesiyle hata kovaryansları.
  function factorModel(lambda, psiDiag, psiOff) {
    const k = lambda.length, S = [], ST = [];
    const psi = psiDiag || lambda.map(l => 1 - l * l);
    for (let i = 0; i < k; i++) { S.push([]); ST.push([]); for (let j = 0; j < k; j++) { const t = lambda[i] * lambda[j]; ST[i].push(t); S[i].push(t + (i === j ? psi[i] : 0)); } }
    for (const o of (psiOff || [])) { S[o.i][o.j] += o.v; S[o.j][o.i] += o.v; }
    const tot = sumAll(S), sl = sum(lambda);
    return {
      Sigma: S, SigmaT: ST, alpha: alphaFromMatrix(S), omega: sl * sl / tot, L2: guttmanFromSigma(S),
      total: tot, pd: isPositiveDefinite(S),
    };
  }
  function twoBlockModel(k, lam, rf) {
    const h = k / 2, S = [], ST = [];
    for (let i = 0; i < k; i++) { S.push([]); ST.push([]); for (let j = 0; j < k; j++) {
      const same = (i < h) === (j < h), t = lam * lam * (same ? 1 : rf);
      ST[i].push(t); S[i].push(t + (i === j ? 1 - lam * lam : 0));
    } }
    return { Sigma: S, SigmaT: ST, alpha: alphaFromMatrix(S), trueRatio: sumAll(ST) / sumAll(S) };
  }
  // Hata Laboratuvarı popülasyonu. X = η + c + B + γg + E (tek ölçme), X* = a + wX.
  function errorLabPopulation(o) {
    const sEta2 = o.sEta2, sE2 = o.sE2, sB2 = o.sB2 || 0, pi = o.pi || 0, gamma = o.gamma || 0;
    const rhoB = o.rhoBEta || 0, w = o.w == null ? 1 : o.w;
    const covEtaU = rhoB * Math.sqrt(sB2 * sEta2);          // g ⊥ η varsayılır
    const sU2 = sB2 + gamma * gamma * pi * (1 - pi);
    let sE2eff = sE2, sTrue2 = sEta2 + sU2 + 2 * covEtaU;
    if (o.biasVaries) { sE2eff = sE2 + sU2; sTrue2 = sEta2; } // yanlılık tekrarda değişirse hata gibi
    const sX2 = sTrue2 + sE2eff;
    const covXEta = o.biasVaries ? sEta2 : sEta2 + covEtaU;
    const rho = sTrue2 / sX2, rhoXEta = covXEta / Math.sqrt(sX2 * sEta2);
    const within = (sEta2 + sB2 + 2 * covEtaU) / (sEta2 + sB2 + 2 * covEtaU + sE2);
    const mean = (o.mu || 0) + (o.c || 0) + gamma * pi;
    return {
      rho, rhoXEta: rhoXEta * Math.sign(w || 1), ceiling: Math.sqrt(rho), withinRho: within,
      semVal: Math.abs(w) * Math.sqrt(sE2eff), sdX: Math.abs(w) * Math.sqrt(sX2), sX2: w * w * sX2, sTrue2, sE2: sE2eff, sU2, covEtaU,
      mean: (o.a || 0) + w * mean, groupBias: gamma, conditionValue: sU2 + 2 * covEtaU,
    };
  }
  // Tekrar tasarımcısı popülasyonu (k maddelik formun madde ortalaması puanı)
  function repeatDesignerPopulation(o) {
    const { sp, spo, spi, se, k } = o;
    const retest = (sp + spi / k) / (sp + spi / k + spo + se / k);
    const equiv = (sp + spo) / (sp + spo + (spi + se) / k);
    const delayed = sp / (sp + spo + (spi + se) / k);
    return {
      retest, equiv, delayed, alpha: equiv,
      halfDiff: { retest: spo + se / k, equiv: (spi + se) / k, delayed: spo + (spi + se) / k },
    };
  }

  // ---------------------------------------------------------------------------
  // Sözde rastgele sayı üretimi (belirlenimci alt akışlar)
  // ---------------------------------------------------------------------------
  function fnv1a(str) {
    let h = 0x811c9dc5; const s = String(str);
    for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 0x01000193) >>> 0; }
    return h >>> 0;
  }
  function mulberry32(a) {
    let t = a >>> 0;
    return function () {
      t = (t + 0x6D2B79F5) >>> 0; let r = t;
      r = Math.imul(r ^ (r >>> 15), r | 1);
      r ^= r + Math.imul(r ^ (r >>> 7), r | 61);
      return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
    };
  }
  // Box-Muller, yalnızca ilk çıktı; u = 0 koruması
  function normalStream(rng) {
    return function () {
      let u1 = rng(); if (u1 <= 0) u1 = 2.3283064365386963e-10;
      const u2 = rng();
      return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
    };
  }
  function stream(seed, comp, person) { return normalStream(mulberry32(fnv1a(seed + '|' + comp + '|' + person))); }
  function uniformStream(seed, comp, person) { return mulberry32(fnv1a(seed + '|' + comp + '|' + person)); }
  // n kişi × k çekim standart normal; kişinin j. çekimi hep aynıdır (n, k'dan bağımsız)
  function latentZ(seed, comp, n, k) {
    const out = new Array(n);
    for (let p = 0; p < n; p++) { const s = stream(seed, comp, p); const row = new Array(k); for (let j = 0; j < k; j++) row[j] = s(); out[p] = row; }
    return out;
  }
  function round6(x) { return Math.round(x * 1e6) / 1e6; }
  function digest(obj) {
    // Veri özeti: sayıları 1e-6 duyarlıkla dizgeye çevirip FNV-1a
    const s = JSON.stringify(obj, (_, v) => typeof v === 'number' ? Number(v.toFixed(6)) : v);
    return fnv1a(s).toString(16).padStart(8, '0');
  }

  // ---------------------------------------------------------------------------
  // Simülasyonlar
  // ---------------------------------------------------------------------------
  // A11: X = Σ_{i=1..k}(η + B + E_i); iki paralel form
  function simParallelItems(o) {
    const N = o.N, k = o.k || 5, sB = o.sB || 0, seed = o.seed;
    const eta = latentZ(seed, 'eta', N, 1), B = latentZ(seed, 'B', N, 1);
    const E1 = latentZ(seed, 'E1', N, k), E2 = latentZ(seed, 'E2', N, k);
    const items1 = [], X1 = [], X2 = [], T = [], etas = [];
    for (let p = 0; p < N; p++) {
      const t = eta[p][0] + sB * B[p][0];
      const row = []; let x2 = 0;
      for (let i = 0; i < k; i++) { row.push(round6(t + E1[p][i])); x2 += round6(t + E2[p][i]); }
      items1.push(row); X1.push(sum(row)); X2.push(x2); T.push(k * t); etas.push(eta[p][0]);
    }
    const r1 = correlation(X1, T), rEta = correlation(X1, etas);
    return {
      alpha: alphaVariance(items1), rParallel: correlation(X1, X2), r2XT: r1 * r1, r2XEta: rEta * rEta,
      sdError: Math.sqrt(variance(X1.map((x, i) => x - T[i]))),
    };
  }
  // Hata Laboratuvarı simülasyonu (iki ölçme)
  function simErrorLab(o) {
    const N = o.N, seed = o.seed, sEta = Math.sqrt(o.sEta2), sE = Math.sqrt(o.sE2), sB = Math.sqrt(o.sB2 || 0);
    const eta = latentZ(seed, 'eta', N, 1), B = latentZ(seed, 'B', N, 1), E = latentZ(seed, 'E', N, 2);
    const G = []; for (let p = 0; p < N; p++) G.push(uniformStream(seed, 'g', p)() < (o.pi || 0) ? 1 : 0);
    const X1 = [], X2 = [], H = [];
    for (let p = 0; p < N; p++) {
      const h = sEta * eta[p][0], u = (o.c || 0) + sB * B[p][0] + (o.gamma || 0) * G[p];
      X1.push(round6(h + u + sE * E[p][0])); X2.push(round6(h + u + sE * E[p][1])); H.push(h);
    }
    const res = { rho: correlation(X1, X2), rhoXEta: correlation(X1, H) };
    if (o.pi) {
      const w = [0, 1].map(gv => { const idx = G.map((g, i) => g === gv ? i : -1).filter(i => i >= 0); return correlation(idx.map(i => X1[i]), idx.map(i => X2[i])); });
      res.withinRho = (w[0] + w[1]) / 2; res.withinByGroup = w;
    }
    return res;
  }
  // Tekrar tasarımcısı simülasyonu: 2 gün × 2 form, formda k madde, madde ortalaması puanı
  function simRepeatDesigner(o) {
    const N = o.N, k = o.k, seed = o.seed;
    const P = latentZ(seed, 'p', N, 1), PO = latentZ(seed, 'po', N, 2), PI = latentZ(seed, 'pi', N, 2 * k), Ez = latentZ(seed, 'e', N, 4 * k);
    const sp = Math.sqrt(o.sp), spo = Math.sqrt(o.spo), spi = Math.sqrt(o.spi), se = Math.sqrt(o.se);
    const X = { d1f1: [], d2f1: [], d1f2: [], d2f2: [] }, items11 = [];
    for (let q = 0; q < N; q++) {
      const acc = {};
      for (const [key, day, form, off] of [['d1f1', 0, 0, 0], ['d2f1', 1, 0, k], ['d1f2', 0, 1, 2 * k], ['d2f2', 1, 1, 3 * k]]) {
        let s = 0; const row = [];
        for (let i = 0; i < k; i++) {
          const v = round6(sp * P[q][0] + spo * PO[q][day] + spi * PI[q][form * k + i] + se * Ez[q][off + i]);
          s += v; if (key === 'd1f1') row.push(v);
        }
        acc[key] = s / k; if (key === 'd1f1') items11.push(row);
      }
      for (const key in acc) X[key].push(acc[key]);
    }
    const hd = (a, b) => variance(a.map((x, i) => x - b[i])) / 2;
    return {
      retest: correlation(X.d1f1, X.d2f1), equiv: correlation(X.d1f1, X.d1f2), delayed: correlation(X.d1f1, X.d2f2),
      alpha: alphaVariance(items11),
      halfDiff: { retest: hd(X.d1f1, X.d2f1), equiv: hd(X.d1f1, X.d1f2), delayed: hd(X.d1f1, X.d2f2) },
    };
  }

  // M7 el hesabı dostu üreticiler (tohumlu reddetme örneklemesi)
  function genAlphaData(seed) {
    const rng = uniformStream(seed, 'alfa-uretici', 0);
    for (let attempt = 0; attempt < 200000; attempt++) {
      const k = rng() < 0.5 ? 3 : 4, ability = [], data = [];
      for (let p = 0; p < 6; p++) ability.push(Math.floor(rng() * 5) - 2);
      for (let p = 0; p < 6; p++) { const row = []; for (let i = 0; i < k; i++) row.push(Math.min(5, Math.max(1, 3 + ability[p] + Math.floor(rng() * 3) - 1))); data.push(row); }
      if (!alphaDataOk(data)) continue;
      return data;
    }
    throw new Error('Üretici kısıtları sağlayamadı: ' + seed);
  }
  function alphaDataOk(data) {
    const cols = columns(data);
    for (const c of cols) {
      if (sum(c) % 6 !== 0) return false;
      if (variance(c) <= 0) return false;
      if (new Set(c).size < 3) return false;
    }
    if (variance(rowSums(data)) <= 0) return false;
    const a = alphaVariance(data);
    return a >= 0.5 && a <= 0.9;
  }
  function genRData(seed) {
    const rng = uniformStream(seed, 'r-uretici', 0);
    for (let attempt = 0; attempt < 200000; attempt++) {
      const x1 = [], x2 = [];
      for (let p = 0; p < 6; p++) { const t = 4 + Math.floor(rng() * 13); x1.push(Math.min(20, Math.max(1, t + Math.floor(rng() * 5) - 2))); x2.push(Math.min(20, Math.max(1, t + Math.floor(rng() * 5) - 2))); }
      if (sum(x1) % 6 || sum(x2) % 6) continue;
      if (variance(x1) <= 0 || variance(x2) <= 0) continue;
      if (correlation(x1, x2) <= 0.5) continue;
      return [x1, x2];
    }
    throw new Error('r üreticisi kısıtları sağlayamadı: ' + seed);
  }

  // ---------------------------------------------------------------------------
  // Sabit veriler
  // ---------------------------------------------------------------------------
  const FIXTURES = {
    A: [[1, 2, 1, 4], [3, 4, 5, 5], [1, 1, 3, 2], [3, 4, 5, 3], [3, 2, 2, 2], [4, 2, 5, 5]],
    A5item: [3, 3, 4, 1, 2, 5],
    B: [[1, 1, 1, 1, 1], [1, 1, 1, 1, 0], [1, 1, 1, 0, 1], [1, 1, 0, 1, 0], [1, 0, 1, 0, 0], [1, 1, 0, 0, 0], [0, 1, 0, 0, 0], [0, 0, 0, 0, 0]],
    M5: { x1: [10, 12, 14, 16, 18, 20], x2: [11, 11, 15, 14, 19, 20] },
    ayse: [62, 58, 65, 55, 60],
    m1Points: [22, 35, 41, 48, 55, 60, 68, 79],
  };
  function fixtureA5() { return FIXTURES.A.map((r, i) => r.concat([FIXTURES.A5item[i]])); }

  // ---------------------------------------------------------------------------
  // Durum, ön ayarlar, derive ve project
  // ---------------------------------------------------------------------------
  // Gizli küme: bireysel gizil değerler ve onlardan hesaplanan örneklem istatistikleri,
  // ayrıca yalnızca perde arkasında gösterilen parametre türevleri. Hepsi 'gizli.' önekli.
  const HIDDEN_PREFIX = 'gizli.';
  const HIDDEN_ROLES = ['T', 'E', 'eta', 'B', 'g'];

  function defaultState(module) {
    const base = { module: module || 'm1', view: 'real', seed: 1, denom: 'n-1', expert: false, digits: 2 };
    const P = {
      m1: { points: FIXTURES.m1Points.slice(), noise: 0, shift2: 0, zMode: false, n: 30 },
      m2: { sigmaE: 4, T: 60, reps: 0 },
      m3: { sigmaT: 8, sigmaE: 4, n: 30, second: false },
      m4: { sEta: Math.sqrt(60), sE: Math.sqrt(20), c: 0, sB: 0, biasVaries: false, w: 1, pi: 0, gamma: 0, rhoBEta: 0, shift2only: 0, ceiling: false, cut: 50, mu: 50, n: 200 },
      m5: { dataMode: 'fixed', n: 30, sigmaT: 4, sigmaE: 1, memory: 0, change: 0, unequal: false, shift: 0, bandX: 18, binomial: false },
      m6: { sp: 1, spo: 0.3, spi: 0.8, se: 0.6, k: 10, memory: 0, learning: 0, n: 500 },
      m7: { tab: 'alpha', dataset: 'A', round: 1, lengthRho: 0.6, lengthM: 2, splitA: [0, 2] },
      m8: { preset: 'tau', meanLambda: 0.625, spread: 0, k: 4, lambda: null, psiOff: [], rf: 0, blocksK: 6 },
      m9: { nPrime: 4, facet: 'madde', design: 'crossed', cut: 3 },
      m10: {},
    };
    return Object.assign(base, { params: P[base.module] || {} });
  }

  // Modül 1-9 için canlı nicelikler. Anahtarlar data-q kimlikleridir.
  function derive(state) {
    const s = state, P = s.params || {}, q = {}, denom = s.denom || 'n-1';
    switch (s.module) {
      case 'm1': {
        const x = P.points; q['m1.ortalama'] = mean(x); q['m1.varyans'] = variance(x, denom); q['m1.ss'] = sum(deviations(x).map(d => d * d));
        q['m1.sd'] = Math.sqrt(q['m1.varyans']); q['m1.n'] = x.length; q['m1.sd_derece'] = x.length - 1;
        const n = P.n || 30, z = latentZ(s.seed, 'm1', n, 3);
        const t1 = z.map(r => round6(50 + 10 * r[0])), t2 = z.map((r, i) => round6(50 + 10 * r[0] + 4 * r[1] + (P.noise || 0) * r[2] + (P.shift2 || 0)));
        q['m1.kovaryans'] = covariance(t1, t2, denom); q['m1.r'] = correlation(t1, t2);
        q['m1.ortalama1'] = mean(t1); q['m1.ortalama2'] = mean(t2); q['m1.varyans1'] = variance(t1, denom); q['m1.varyans2'] = variance(t2, denom);
        q._series = { t1, t2 };
        break;
      }
      case 'm2': {
        const reps = P.reps || 0, zs = latentZ(s.seed, 'm2', 1, Math.max(reps, 1))[0].slice(0, reps);
        const X = zs.map(z => round6(P.T + P.sigmaE * z));
        q['m2.tekrar'] = reps;
        if (reps) { q['m2.ortalama'] = mean(X); q['m2.sd'] = reps > 1 ? Math.sqrt(variance(X)) : 0; }
        q['m2.sigmaE'] = P.sigmaE;
        q[HIDDEN_PREFIX + 'm2.T'] = P.T;
        q[HIDDEN_PREFIX + 'm2.E'] = X.map(x => x - P.T);
        q._series = { X };
        break;
      }
      case 'm3': {
        const n = P.n || 30, z = latentZ(s.seed, 'm3', n, 3);
        const T = z.map(r => round6(50 + P.sigmaT * r[0])), X = z.map((r, i) => round6(T[i] + P.sigmaE * r[1])), X2 = z.map((r, i) => round6(T[i] + P.sigmaE * r[2]));
        const sT2 = P.sigmaT * P.sigmaT, sE2 = P.sigmaE * P.sigmaE;
        q['m3.sigmaT2'] = sT2; q['m3.sigmaE2'] = sE2; q['m3.sigmaX2'] = sT2 + sE2;
        q['m3.rho'] = sT2 / (sT2 + sE2); q['m3.osh'] = P.sigmaE; q['m3.rho_xt'] = Math.sqrt(q['m3.rho']);
        q['m3.sX2'] = variance(X, denom);
        if (P.second) { q['m3.s12'] = covariance(X, X2, denom); q['m3.tahmini_hata'] = variance(X, denom) - q['m3.s12']; q['m3.r12'] = correlation(X, X2); }
        q[HIDDEN_PREFIX + 'm3.sT2'] = variance(T, denom); q[HIDDEN_PREFIX + 'm3.sE2'] = variance(X.map((x, i) => x - T[i]), denom);
        q[HIDDEN_PREFIX + 'm3.sTE'] = covariance(T, X.map((x, i) => x - T[i]), denom); q[HIDDEN_PREFIX + 'm3.rXT'] = correlation(X, T);
        q._series = { X, X2, T };
        break;
      }
      case 'm4': {
        const pop = errorLabPopulation({ sEta2: P.sEta * P.sEta, sE2: P.sE * P.sE, sB2: P.sB * P.sB, pi: P.pi, gamma: P.gamma, rhoBEta: P.rhoBEta, biasVaries: P.biasVaries, w: P.w, c: P.c, mu: P.mu });
        q['m4.rho'] = pop.rho; q['m4.osh'] = pop.semVal; q['m4.ortalama'] = pop.mean; q['m4.tavan'] = pop.ceiling;
        q['m4.rho_xeta'] = pop.rhoXEta; q['m4.grup_ici_rho'] = pop.withinRho;
        const n = P.n || 200, z = latentZ(s.seed, 'm4', n, 5), gs = uniformStream(s.seed, 'm4g', 0);
        const eta = [], B = [], g = [], X1 = [], X2 = [];
        for (let p = 0; p < n; p++) {
          const e = P.sEta * z[p][0];
          const bz = z[p][1], b2 = z[p][4];
          const Bp = P.sB * (P.rhoBEta * z[p][0] + Math.sqrt(Math.max(0, 1 - P.rhoBEta * P.rhoBEta)) * bz);
          const Bp2 = P.biasVaries ? P.sB * b2 : Bp;
          const gp = gs() < (P.pi || 0) ? 1 : 0;
          let x1 = P.mu + e + P.c + Bp + (P.gamma || 0) * gp + P.sE * z[p][2];
          let x2 = P.mu + e + P.c + Bp2 + (P.gamma || 0) * gp + P.sE * z[p][3] + (P.shift2only || 0);
          x1 = P.w * x1; x2 = P.w * x2;
          if (P.ceiling) { x1 = Math.min(100, Math.max(0, x1)); x2 = Math.min(100, Math.max(0, x2)); }
          eta.push(e); B.push(Bp); g.push(gp); X1.push(round6(x1)); X2.push(round6(x2));
        }
        q['m4.r12'] = correlation(X1, X2); q['m4.ortalama_orneklem'] = mean(X1); q['m4.gecme_orani'] = X1.filter(x => x >= P.cut).length / n;
        q['m4.ortalama_fark'] = mean(X1.map((x, i) => x - X2[i]));
        const an = anova(X1.map((x, i) => [x, X2[i]]));
        q['m4.icc_c1'] = iccC1(an); q['m4.icc_a1'] = iccA1(an);
        q[HIDDEN_PREFIX + 'm4.r_xeta_orneklem'] = correlation(X1, eta);
        q[HIDDEN_PREFIX + 'm4.eta'] = eta; q[HIDDEN_PREFIX + 'm4.B'] = B; q[HIDDEN_PREFIX + 'm4.g'] = g;
        q._series = { X1, X2 };
        break;
      }
      case 'm5': {
        let x1, x2;
        if (P.dataMode === 'fixed') { x1 = FIXTURES.M5.x1.slice(); x2 = FIXTURES.M5.x2.slice(); }
        else {
          const z = latentZ(s.seed, 'm5', P.n, 4);
          const T = z.map(r => 50 + P.sigmaT * r[0]);
          const mem = P.memory || 0;
          x1 = z.map((r, i) => round6(T[i] + P.sigmaE * r[1]));
          // Farklı gerçek değişim: kişiden kişiye değişen, T'den bağımsız bir öğrenme kazancı (r[3])
          x2 = z.map((r, i) => round6(T[i] + (P.change || 0) * r[3] + P.sigmaE * (mem * r[1] + Math.sqrt(1 - mem * mem) * r[2]) * (P.unequal ? 2 : 1)));
          q[HIDDEN_PREFIX + 'm5.T'] = T; q[HIDDEN_PREFIX + 'm5.rho'] = P.sigmaT ** 2 / (P.sigmaT ** 2 + P.sigmaE ** 2);
        }
        x2 = x2.map(v => v + (P.shift || 0));
        const tf = twoForms(x1, x2, denom);
        q['m5.s1'] = tf.s1; q['m5.s2'] = tf.s2; q['m5.s12'] = tf.s12; q['m5.sD'] = tf.sD; q['m5.hata'] = tf.errVar; q['m5.ort_var'] = tf.meanVar;
        q['m5.oran'] = tf.rel; q['m5.osh'] = tf.semDiff; q['m5.r'] = tf.r; q['m5.ortD'] = tf.meanD; q['m5.kalan1'] = tf.residuals[0]; q['m5.kalan2'] = tf.residuals[1];
        const semR = Math.sqrt(tf.meanVar) * Math.sqrt(1 - tf.r);
        q['m5.bant_alt'] = P.bandX - 1.96 * semR; q['m5.bant_ust'] = P.bandX + 1.96 * semR;
        q._series = { x1, x2 };
        break;
      }
      case 'm6': {
        const pop = repeatDesignerPopulation(P);
        q['m6.tekrar'] = pop.retest; q['m6.esdeger'] = pop.equiv; q['m6.gecikmeli'] = pop.delayed; q['m6.alfa'] = pop.alpha;
        q[HIDDEN_PREFIX + 'm6.hd_tekrar'] = pop.halfDiff.retest; q[HIDDEN_PREFIX + 'm6.hd_esdeger'] = pop.halfDiff.equiv; q[HIDDEN_PREFIX + 'm6.hd_gecikmeli'] = pop.halfDiff.delayed;
        break;
      }
      case 'm7': {
        const data = P.dataset === 'B' ? FIXTURES.B : P.dataset === 'A5' ? fixtureA5() : P.dataset === 'uret' ? genAlphaData(s.seed) : FIXTURES.A;
        const cols = columns(data), y = rowSums(data);
        q['m7.k'] = data[0].length; q['m7.n'] = data.length;
        q['m7.madde_var_toplam'] = sum(cols.map(c => variance(c, denom))); q['m7.toplam_var'] = variance(y, denom);
        q['m7.alfa'] = alphaVariance(data, denom);
        q['m7.osh'] = Math.sqrt(variance(y, denom)) * Math.sqrt(1 - q['m7.alfa']);
        if (P.dataset === 'B') { const kr = krStats(data, denom); q['m7.kr20'] = kr.kr20Shown; q['m7.kr21'] = kr.kr21; q['m7.pq_toplam'] = sum(kr.itemVarShown); }
        const tf = twoForms(FIXTURES.M5.x1, FIXTURES.M5.x2); q['m7.r'] = tf.r;
        q['m7.sb'] = spearmanBrown(P.lengthRho, P.lengthM);
        const all = [...Array(data[0].length).keys()], B = all.filter(i => !P.splitA.includes(i));
        if (P.splitA.length && B.length) { const sp = splitStats(data, P.splitA, B, denom); q['m7.rhh'] = sp.rhh; q['m7.bolme_sb'] = sp.sb; q['m7.bolme_fr'] = sp.flanaganRulon; }
        break;
      }
      case 'm8': {
        let model;
        if (P.preset === 'bloklar') { model = twoBlockModel(P.blocksK, 0.7, P.rf); q['m8.oran_gercek'] = model.trueRatio; }
        else {
          const lam = P.lambda || lambdaFromSliders(P.k, P.meanLambda, P.spread);
          model = factorModel(lam, null, P.psiOff);
          q['m8.omega'] = model.omega; q['m8.L2'] = model.L2;
        }
        const ms = matrixSummary(model.Sigma);
        q['m8.alfa'] = model.alpha; q['m8.iz'] = ms.trace; q['m8.kosegen_disi'] = ms.offDiag; q['m8.toplam'] = ms.total; q['m8.ort_kov'] = ms.meanOffDiag;
        q[HIDDEN_PREFIX + 'm8.SigmaT_toplam'] = sumAll(model.SigmaT);
        q._matrix = model.Sigma;
        break;
      }
      case 'm9': {
        const an = anova(FIXTURES.A), g = gCoefficients(an.comps, P.nPrime);
        q['m9.KTp'] = an.SSp; q['m9.KTi'] = an.SSi; q['m9.KTart'] = an.SSres; q['m9.KTT'] = an.SSt;
        q['m9.KOp'] = an.MSp; q['m9.KOi'] = an.MSi; q['m9.KOart'] = an.MSres; q['m9.hoyt'] = an.hoyt;
        q['m9.sp'] = an.comps.p; q['m9.si'] = an.comps.i; q['m9.se'] = an.comps.pie;
        q['m9.erho2'] = g.Erho2; q['m9.phi'] = g.Phi;
        if (P.design === 'nested') { const d = dStudyRaters(an.comps, P.nPrime, 'nested'); q['m9.erho2'] = d.Erho2; q['m9.phi'] = d.Phi; }
        break;
      }
      default: break;
    }
    return q;
  }
  function lambdaFromSliders(k, m, spread) {
    const out = []; for (let i = 0; i < k; i++) out.push(Math.min(0.95, Math.max(0.05, m + spread * ((k - 1) / 2 - i) / Math.max(1, (k - 1) / 2))));
    return out;
  }
  // Görünüme göre gizli kümeyi ayıkla. 'real' çıktısında gizli anahtar bulunmaz.
  function project(state, view) {
    const d = derive(state), out = {};
    for (const key of Object.keys(d)) {
      if (view !== 'backstage' && key.startsWith(HIDDEN_PREFIX)) continue;
      out[key] = d[key];
    }
    return out;
  }

  // Ön ayarlar (TGA kartları ve durağan şekiller bunlara bağlıdır)
  const PRESETS = [
    { id: 'm1.varsayilan', module: 'm1', params: {} },
    { id: 'm1.herkese10', module: 'm1', params: { points: FIXTURES.m1Points.map(x => x + 10) } },
    { id: 'm1.gurultu', module: 'm1', params: { noise: 12 } },
    { id: 'm2.varsayilan', module: 'm2', params: { reps: 0 } },
    { id: 'm2.bin', module: 'm2', params: { reps: 1000 } },
    { id: 'm3.varsayilan', module: 'm3', params: {} },
    { id: 'm3.turdes', module: 'm3', params: { sigmaT: 4 } },
    { id: 'm4.varsayilan', module: 'm4', params: {} },
    { id: 'm4.sabit', module: 'm4', params: { c: 5 } },
    { id: 'm4.orantili', module: 'm4', params: { w: 1.1 } },
    { id: 'm4.kararli', module: 'm4', params: { sB: Math.sqrt(20) } },
    { id: 'm4.degisen', module: 'm4', params: { sB: Math.sqrt(20), biasVaries: true } },
    { id: 'm4.tesadufi', module: 'm4', params: { sE: Math.sqrt(40) } },
    { id: 'm4.ters', module: 'm4', params: { sB: Math.sqrt(20), rhoBEta: -0.9, expert: true } },
    { id: 'm4.altgrup', module: 'm4', params: { pi: 0.5, gamma: Math.sqrt(60) } },
    { id: 'm4.tavan', module: 'm4', params: { mu: 90, ceiling: true } },
    { id: 'm4.ikinci', module: 'm4', params: { shift2only: 5 } },
    { id: 'm3.hata', module: 'm3', params: { sigmaE: 8 } },
    { id: 'm3.gercek', module: 'm3', params: { sigmaT: 12 } },
    { id: 'm4.tavan_once', module: 'm4', params: { mu: 90 } },
    { id: 'm5.varsayilan', module: 'm5', params: {} },
    { id: 'm5.sim', module: 'm5', params: { dataMode: 'sim', n: 1000, sigmaT: 4, sigmaE: 2 } },
    { id: 'm5.bellek', module: 'm5', params: { dataMode: 'sim', n: 1000, sigmaT: 4, sigmaE: 2, memory: 0.6 } },
    { id: 'm5.degisim', module: 'm5', params: { dataMode: 'sim', n: 1000, sigmaT: 4, sigmaE: 2, change: 3 } },
    { id: 'm6.k20', module: 'm6', params: { k: 20 } },
    { id: 'm6.varsayilan', module: 'm6', params: {} },
    { id: 'm7.alfa', module: 'm7', params: { dataset: 'A' } },
    { id: 'm7.kr20', module: 'm7', params: { dataset: 'B', tab: 'alpha' } },
    { id: 'm7.zayif', module: 'm7', params: { dataset: 'A5' } },
    { id: 'm8.tau', module: 'm8', params: { preset: 'tau' } },
    { id: 'm8.konjenerik', module: 'm8', params: { preset: 'konjenerik', lambda: [0.9, 0.8, 0.3, 0.2] } },
    { id: 'm8.iliskili', module: 'm8', params: { preset: 'iliskili', psiOff: [{ i: 0, j: 1, v: 0.2 }, { i: 2, j: 3, v: 0.2 }] } },
    { id: 'm8.bloklar', module: 'm8', params: { preset: 'bloklar', rf: 0 } },
    { id: 'm9.varsayilan', module: 'm9', params: {} },
    { id: 'm9.icice', module: 'm9', params: { design: 'nested', facet: 'puanlayici' } },
  ];
  function presetState(id) {
    const p = PRESETS.find(x => x.id === id); if (!p) throw new Error('Bilinmeyen ön ayar: ' + id);
    const st = defaultState(p.module); Object.assign(st.params, p.params); return st;
  }
  function listPresets() { return PRESETS.map(p => p.id); }

  const RelCore = {
    sum, mean, variance, covariance, correlation, deviations, zScores, columns, column, rowSums,
    covMatrix, trace, sumAll, offDiagSum, offDiagMean, matrixSummary, cholesky, isPositiveDefinite,
    alphaVariance, alphaMatrix, alphaFromMatrix, anova, alphaAnova, gCoefficients, phiLambda, dStudyRaters, oneWay,
    iccC1, iccCk, iccAk, iccA1,
    allSplits, sampledSplits, splitStats, splitSummary,
    guttman, guttmanFromSigma, itemCorrelations, alphaStd, dropItem, alphaIfDeleted, correctedItemTotal, itemAnalysis,
    krStats, detectMixedDenominator, diagnoseAlpha, diagnoseR,
    sem, seEstimate, sePrediction, kelley, band, lordCSEM, binomialCoverage, spearmanBrown, lengthFactor,
    reliabilityNewGroup, reliabilityFromSEM, attenuationCorrect, maxPhi, twoForms,
    factorModel, twoBlockModel, errorLabPopulation, repeatDesignerPopulation, lambdaFromSliders,
    fnv1a, mulberry32, normalStream, stream, uniformStream, latentZ, round6, digest,
    simParallelItems, simErrorLab, simRepeatDesigner, genAlphaData, genRData, alphaDataOk,
    FIXTURES, fixtureA5, HIDDEN_PREFIX, HIDDEN_ROLES, defaultState, derive, project, PRESETS, presetState, listPresets,
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = RelCore;
  root.RelCore = RelCore;
})(typeof globalThis !== 'undefined' ? globalThis : this);
