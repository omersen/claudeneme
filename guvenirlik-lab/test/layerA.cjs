/* Katman A: core.js üzerinde Node testleri. Her kimlik tek bir iddiadır.
 * Beklenen değerler SPEC'teki biçimiyle yazılır. */
'use strict';
const C = require('../src/core.js');
const A = C.FIXTURES.A, B = C.FIXTURES.B, M5 = C.FIXTURES.M5;

module.exports = function defineTests(t) {
  const { eq, ok, same } = t;

  // --- A1 Sabit Veri A -------------------------------------------------------
  const an = C.anova(A), ms = C.matrixSummary(C.covMatrix(A)), cols = C.columns(A), y = C.rowSums(A);
  const aV = C.alphaVariance(A), aM = C.alphaMatrix(A), aH = C.alphaAnova(A);
  eq('A1.1', aV, 4 / 5); eq('A1.2', ms.alphaAlt, 4 / 5); eq('A1.3', aH, 4 / 5);
  ok('A1.4', Math.max(Math.abs(aV - aM), Math.abs(aV - aH), Math.abs(aM - aH)) <= 1e-10);
  eq('A1.5', an.SSp, 25); eq('A1.6', an.SSi, 6); eq('A1.7', an.SSres, 15); eq('A1.8', an.SSt, 46);
  eq('A1.9', an.SSp + an.SSi + an.SSres, an.SSt); eq('A1.10', an.MSp, 5); eq('A1.11', an.MSi, 2); eq('A1.12', an.MSres, 1);
  eq('A1.13', an.comps.p, 1); eq('A1.14', an.comps.i, 1 / 6); eq('A1.15', an.comps.pie, 1);
  const g4 = C.gCoefficients(an.comps, 4); eq('A1.16', g4.Erho2, 4 / 5); eq('A1.17', g4.Phi, 24 / 31);
  const sY = Math.sqrt(C.variance(y)); eq('A1.18', C.sem(sY, aV), 2);
  eq('A1.19', ms.total - ms.trueVarTotal, 4); eq('A1.20', 4 * an.MSres, 4); eq('A1.21', C.variance(y) * (1 - aV), 4);
  eq('A1.22', C.sum(ms.itemResiduals), 4); eq('A1.23', ms.trueVarTotal, 16);
  eq('A1.24', an.dfp, 5); eq('A1.25', an.dfi, 3); eq('A1.26', an.dfres, 15);
  [2.5, 2.5, 3.5, 3.5].forEach((v, i) => eq('A1.' + (27 + i), C.mean(cols[i]), v));
  eq('A1.31', an.grand, 3); eq('A1.32', C.mean(y), 12);
  [3 / 2, 3 / 2, 31 / 10, 19 / 10].forEach((v, i) => eq('A1.' + (33 + i), C.variance(cols[i]), v));
  eq('A1.37', C.sum(cols.map(c => C.variance(c))), 8); eq('A1.38', C.variance(y), 20);
  eq('A1.39', C.sum(cols.map(c => C.variance(c, 'n'))), 20 / 3); eq('A1.40', C.variance(y, 'n'), 50 / 3); eq('A1.41', C.alphaVariance(A, 'n'), 4 / 5);
  const S = C.covMatrix(A);
  eq('A1.42', S[0][1], 0.7); eq('A1.43', S[0][2], 1.5); eq('A1.44', S[0][3], 0.7); eq('A1.45', S[1][2], 1.3); eq('A1.46', S[1][3], 0.7); eq('A1.47', S[2][3], 1.1);
  eq('A1.48', ms.trace, 8); eq('A1.49', ms.offDiag, 12); eq('A1.50', ms.total, 20); eq('A1.51', ms.meanOffDiag, 1); eq('A1.52', ms.trueVarTotal / ms.total, 16 / 20);
  [0.5, 0.5, 2.1, 0.9].forEach((v, i) => eq('A1.' + (53 + i), ms.itemResiduals[i], v));
  [-1, 1.25, -1.25, 0.75, -0.75, 1].forEach((v, i) => eq('A1.' + (57 + i), an.personEffects[i], v));
  [-0.5, -0.5, 0.5, 0.5].forEach((v, i) => eq('A1.' + (63 + i), an.itemEffects[i], v));
  eq('A1.67', C.seEstimate(sY, aV), Math.sqrt(3.2));
  const b18 = C.band(18, C.sem(sY, aV)); eq('A1.68', b18[0], 14.08); eq('A1.69', b18[1], 21.92);
  const kel = C.kelley(18, aV, 12); eq('A1.70', kel, 16.8);
  const kb = C.band(kel, C.seEstimate(sY, aV)); eq('A1.71', kb[0], 13.29); eq('A1.72', kb[1], 20.31);

  // --- A2 Yarıya bölme ------------------------------------------------------
  const sp13 = C.splitStats(A, [0, 2], [1, 3]), sp12 = C.splitStats(A, [0, 1], [2, 3]), sp14 = C.splitStats(A, [0, 3], [1, 2]);
  eq('A2.1', sp13.flanaganRulon, 19 / 25); eq('A2.2', sp12.flanaganRulon, 21 / 25); eq('A2.3', sp14.flanaganRulon, 4 / 5);
  eq('A2.4', sp13.rulon, 19 / 25); eq('A2.5', sp12.rulon, 21 / 25); eq('A2.6', sp14.rulon, 4 / 5);
  const sumA = C.splitSummary(A);
  eq('A2.7', sumA.meanFR, 4 / 5);
  eq('A2.8', sp13.rhh2, 19 / 48); eq('A2.9', sp12.rhh2, 49 / 88); eq('A2.10', sp14.rhh2, 25 / 54);
  eq('A2.11', sumA.meanSB, 0.8123); ok('A2.11', Math.abs(sumA.meanSB - 4 / 5) > 1e-6);
  eq('A2.12', sp13.rhh, 0.6292); eq('A2.13', sp12.rhh, 0.7462); eq('A2.14', sp14.rhh, 0.6804);
  eq('A2.15', sp13.sb, 0.7724); eq('A2.16', sp12.sb, 0.8547); eq('A2.17', sp14.sb, 0.8098);
  eq('A2.18', sp13.varA, 38 / 5); eq('A2.19', sp13.varB, 24 / 5); eq('A2.20', sp13.covAB, 19 / 5);
  const sumB = C.splitSummary(B);
  eq('A2.21', sumB.meanFR, 184 / 265); eq('A2.22', sumB.meanFR, 115 / 159 * 24 / 25); eq('A2.23', sumB.count, 10);
  eq('A2.24', C.allSplits(4).length, 3); eq('A2.25', C.allSplits(6).length, 10);

  // --- A3 Guttman, standart α, madde analizi ----------------------------------
  const gt = C.guttman(A);
  eq('A3.1', gt.L1, 3 / 5); eq('A3.2', gt.L2, 0.8101); ok('A3.3', gt.L2 >= aV);
  const st = C.alphaStd(A); eq('A3.4', st.alphaStd, 0.8050);
  const del = C.alphaIfDeleted(A); eq('A3.5', del[0], 93 / 127); eq('A3.6', del[1], 99 / 131); eq('A3.7', del[2], 9 / 13); eq('A3.8', del[3], 105 / 131);
  const cit = C.correctedItemTotal(A); eq('A3.9', cit[0], 0.664); eq('A3.10', cit[1], 0.609); eq('A3.11', cit[2], 0.734); eq('A3.12', cit[3], 0.501);
  const A5 = C.fixtureA5();
  eq('A3.13', C.alphaVariance(A5), 15 / 22); eq('A3.14', C.alphaIfDeleted(A5)[4], 4 / 5); eq('A3.15', C.correctedItemTotal(A5)[4], 0);
  const rr = st.correlations.map(x => x.r);
  eq('A3.16', rr[0], 0.4667); eq('A3.17', rr[1], 0.6956); eq('A3.18', rr[2], 0.4146); eq('A3.19', rr[3], 0.6029); eq('A3.20', rr[4], 0.4146); eq('A3.21', rr[5], 0.4532);
  eq('A3.22', st.rbar, 0.5079);
  const it5 = C.FIXTURES.A5item; eq('A3.23', C.mean(it5), 3); eq('A3.24', C.variance(it5), 2); eq('A3.25', C.covariance(it5, y), 0);

  // --- A4 K çalışması, ICC, iç içe --------------------------------------------
  const dvals = { 1: [1 / 2, 6 / 13], 2: [2 / 3, 12 / 19], 4: [4 / 5, 24 / 31], 8: [8 / 9, 48 / 55], 12: [12 / 13, 72 / 79] };
  let idx = 1;
  for (const nP of [1, 2, 4, 8, 12]) { const g = C.gCoefficients(an.comps, nP); eq('A4.' + idx++, g.Erho2, dvals[nP][0]); eq('A4.' + idx++, g.Phi, dvals[nP][1]); }
  let maxd = 0, phiOk = true;
  for (let nP = 1; nP <= 50; nP++) { const g = C.gCoefficients(an.comps, nP); maxd = Math.max(maxd, Math.abs(g.Erho2 - C.spearmanBrown(1 / 2, nP))); if (g.Phi > g.Erho2) phiOk = false; }
  ok('A4.11', maxd <= 1e-12); ok('A4.12', phiOk);
  eq('A4.13', C.iccC1(an), 1 / 2); eq('A4.14', C.iccAk(an), 24 / 31);
  const nest = C.dStudyRaters(an.comps, 4, 'nested'); eq('A4.15', nest.Erho2, 24 / 31); ok('A4.15', Math.abs(nest.Phi - 24 / 31) < 1e-9);
  const ow = C.oneWay(A); eq('A4.16', ow.MSw, 7 / 6); eq('A4.17', ow.sigmaP, 23 / 24); eq('A4.18', ow.icc1k, 23 / 30); eq('A4.19', ow.SSw, 21);
  eq('A4.20', an.comps.i + an.comps.pie, 7 / 6);
  const rc = C.dStudyRaters(an.comps, 4, 'crossed'); eq('A4.21', rc.Erho2, 4 / 5); eq('A4.22', rc.Phi, 24 / 31);
  const r1 = C.dStudyRaters(an.comps, 1, 'crossed'); eq('A4.23', r1.Erho2, 1 / 2); eq('A4.24', r1.Phi, 6 / 13);
  eq('A4.25', ow.MSw, 1 / 6 + 1); ok('A4.25', Math.abs(ow.MSw - (an.comps.i + an.MSres)) < 1e-12);
  eq('A4.26', C.iccCk(an), 4 / 5); ok('A4.26', Math.abs(C.iccCk(an) - aV) < 1e-12);

  // --- A5 Değişmezlik ---------------------------------------------------------
  const tr = f => A.map(r => r.map(f)), item3 = c => A.map(r => r.map((x, j) => j === 2 ? x + c : x));
  const Ap2 = tr(x => x + 2), A21 = tr(x => 2 * x + 1), A11 = tr(x => 1.1 * x), A3p1 = item3(1), A3p2 = item3(2), Abig = tr(x => x + 1e6);
  eq('A5.1', C.alphaVariance(Ap2), 4 / 5); eq('A5.2', C.alphaVariance(A21), 4 / 5); eq('A5.3', C.alphaVariance(A11), 4 / 5);
  eq('A5.4', C.alphaVariance(A3p1), 4 / 5); eq('A5.5', C.alphaVariance(Abig), 4 / 5); eq('A5.6', C.alphaVariance(A3p2), 4 / 5);
  const phi = d => C.gCoefficients(C.anova(d).comps, 4).Phi;
  eq('A5.7', phi(Ap2), 24 / 31); eq('A5.8', phi(A21), 24 / 31); eq('A5.9', phi(A3p1), 16 / 23); eq('A5.10', phi(A3p2), 24 / 41);
  eq('A5.11', C.anova(A3p1).comps.i, 3 / 4);
  const y21 = C.rowSums(A21); eq('A5.12', C.variance(y21), 80); eq('A5.13', C.sem(Math.sqrt(C.variance(y21)), C.alphaVariance(A21)), 4);
  const y11 = C.rowSums(A11); eq('A5.14', C.sem(Math.sqrt(C.variance(y11)), C.alphaVariance(A11)), 2.2); eq('A5.15', C.mean(y11), 13.2);
  const t0 = C.twoForms(M5.x1, M5.x2), tp2 = C.twoForms(M5.x1.map(x => x + 2), M5.x2);
  eq('A5.16', tp2.meanD, 2); eq('A5.17', tp2.r, 68 / Math.sqrt(5180));
  const m5sh = C.anova(M5.x1.map((x, i) => [x, M5.x2[i] + 5]));
  eq('A5.18', C.iccC1(m5sh), 17 / 18); eq('A5.19', C.iccA1(m5sh), 408 / 803); eq('A5.20', t0.meanD, 0);

  // --- A6 Negatif kontrol -------------------------------------------------------
  const Acap = tr(x => Math.min(x + 1, 5)); eq('A6.1', C.alphaVariance(Acap), 280 / 377); ok('A6.2', Math.abs(C.alphaVariance(Acap) - 4 / 5) > 1e-9);

  // --- A7 Kişiye özgü yanlılık -------------------------------------------------
  const bias = ps => A.map((r, p) => r.map(x => ps.includes(p) ? x + 1 : x));
  eq('A7.1', C.alphaVariance(bias([1, 2])), 76 / 91); eq('A7.2', phi(bias([1, 2])), 152 / 187);
  eq('A7.3', C.alphaVariance(bias([1, 3, 5])), 10 / 11); eq('A7.4', C.alphaVariance(bias([0, 2, 4])), 2 / 7);

  // --- A8 Sabit Veri B -------------------------------------------------------
  const kr = C.krStats(B, 'n'), krm = C.krStats(B, 'n-1');
  eq('A8.1', kr.kr20, 115 / 159); eq('A8.2', krm.kr20Shown, 115 / 159); eq('A8.3', kr.kr21, 33 / 53); ok('A8.4', kr.kr21 <= kr.kr20);
  eq('A8.5', C.alphaAnova(B), 115 / 159); eq('A8.6', kr.mixed, 4015 / 5088);
  ok('A8.7', C.detectMixedDenominator(B, 4015 / 5088) === true && C.detectMixedDenominator(B, 115 / 159) === false);
  eq('A8.8', kr.semSq, 11 / 16);
  [0, 1, Math.sqrt(3 / 2), Math.sqrt(3 / 2), 1, 0].forEach((v, x) => eq('A8.' + (9 + x), C.lordCSEM(x, 5), v));
  [0.75, 0.75, 0.50, 0.375, 0.25].forEach((v, i) => eq('A8.' + (15 + i), kr.p[i], v));
  eq('A8.20', kr.sumPQ, 67 / 64); eq('A8.21', kr.M, 21 / 8); eq('A8.22', kr.varN, 159 / 64);

  // --- A9 Popülasyon tablosu -------------------------------------------------
  const rows = [
    [[.625, .625, .625, .625], null, [.7194, .7194, .7194]],
    [[.5, .5, .5, .5, .5, .5], null, [.6667, .6667, .6667]],
    [[.8, .7, .6, .4], null, [.7132, .7267, .7208]],
    [[.9, .8, .3, .2], null, [.5987, .6667, .6386]],
    [[.9, .8, .3], null, [.6758, .7326, .7061]],
    [[.625, .625, .625, .625], [{ i: 0, j: 1, v: .2 }, { i: 2, j: 3, v: .2 }], [.7712, .6588, .7752]],
    [[.9, .8, .3, .2], [{ i: 2, j: 3, v: .05 }], [.6087, .6576, .6447]],
    [[.625, .625, .625, .625], [{ i: 0, j: 1, v: -.15 }], [.6975, .7452, .6995]],
  ];
  idx = 1;
  for (const [lam, off, exp] of rows) { const m = C.factorModel(lam, null, off); eq('A9.' + idx++, m.alpha, exp[0]); eq('A9.' + idx++, m.omega, exp[1]); eq('A9.' + idx++, m.L2, exp[2]); }
  for (const [k, rf, ea, er] of [[6, 0, .5939, .7424], [6, .3, .7043, .7893], [6, .5, .7580, .8122], [6, 1, .8522, .8522], [12, 0, .7747, .8522]]) {
    const m = C.twoBlockModel(k, .7, rf); eq('A9.' + idx++, m.alpha, ea); eq('A9.' + idx++, m.trueRatio, er);
  }
  let wOk = true, lOk = true;
  for (let sd = 1; sd <= 200; sd++) {
    const rng = C.uniformStream(sd, 'A9', 0), k = 4 + Math.floor(rng() * 5), lam = [];
    for (let i = 0; i < k; i++) lam.push(0.2 + 0.7 * rng());
    const m = C.factorModel(lam); if (!(m.omega - m.alpha > 0)) wOk = false; if (!(m.L2 >= m.alpha)) lOk = false;
  }
  ok('A9.35', wOk); ok('A9.36', lOk);
  const e1 = C.factorModel([.625, .625, .625, .625]), e2 = C.factorModel([.5, .5, .5, .5, .5, .5]);
  ok('A9.37', Math.abs(e1.omega - e1.alpha) < 1e-12); ok('A9.38', Math.abs(e2.omega - e2.alpha) < 1e-12);

  // --- A10 Rastgele veri matrisleri -------------------------------------------
  let a10 = { paths: true, ss: true, clampSeen: false, clampOk: true, flagOk: true, even: true, odd: true, skipped: 0 };
  for (let sd = 1; sd <= 200; sd++) {
    const rng = C.uniformStream(sd, 'A10', 0), n = 5 + Math.floor(rng() * 56), k = 2 + Math.floor(rng() * 9);
    const z = C.latentZ(sd, 'A10f', n, k + 1);
    const data = z.map(r => r.slice(1).map(e => Math.min(5, Math.max(0, Math.round(2.5 + 1.2 * r[0] + 1.1 * e)))));
    if (C.variance(C.rowSums(data)) === 0) { a10.skipped++; continue; }
    const v = C.alphaVariance(data), m = C.alphaMatrix(data), h = C.alphaAnova(data), sc = Math.max(1, Math.abs(v));
    if (Math.max(Math.abs(v - m), Math.abs(v - h)) / sc > 1e-10) a10.paths = false;
    const q = C.anova(data); if (Math.abs(q.SSp + q.SSi + q.SSres - q.SSt) / Math.max(1, q.SSt) > 1e-9) a10.ss = false;
    if (q.rawComps.i < 0 || q.rawComps.p < 0) { a10.clampSeen = true; if (q.comps.i < 0 || q.comps.p < 0) a10.clampOk = false; if (!q.clamped) a10.flagOk = false; }
    if (k >= 2) {
      const s = C.splitSummary(data);
      if (k % 2 === 0 && Math.abs(s.meanFR - v) / sc > 1e-9) a10.even = false;
      if (k % 2 === 1 && Math.abs(s.meanFR - v * (k * k - 1) / (k * k)) / sc > 1e-9) a10.odd = false;
    }
  }
  ok('A10.1', a10.paths); ok('A10.2', a10.ss); ok('A10.3', a10.clampSeen && a10.clampOk); ok('A10.4', a10.even); ok('A10.5', a10.odd);
  ok('A10.6', true, 's_Y² = 0 olan ' + a10.skipped + ' matris atlandı'); ok('A10.7', a10.clampSeen && a10.flagOk);

  // --- A11 Simülasyon kehanetleri ----------------------------------------------
  eq('A11.1', 25 / 30, 5 / 6); eq('A11.6', C.spearmanBrown(5 / 6, 2), 10 / 11); ok('A11.6', Math.abs(100 / 110 - 10 / 11) < 1e-12);
  eq('A11.7', (25 * 1.49) / (25 * 1.49 + 5), 149 / 169); eq('A11.8', 25 / (25 * 1.49 + 5), 100 / 169);
  const s11 = [], s11b = [];
  for (let sd = 1; sd <= 5; sd++) { s11.push(C.simParallelItems({ N: 20000, k: 5, seed: sd })); s11b.push(C.simParallelItems({ N: 20000, k: 5, seed: sd, sB: 0.7 })); }
  t.all('A11.2', s11.map(s => s.alpha), 5 / 6); t.all('A11.3', s11.map(s => s.rParallel), 5 / 6); t.all('A11.4', s11.map(s => s.r2XT), 5 / 6);
  t.all('A11.5', s11.map(s => s.sdError), Math.sqrt(5));
  t.all('A11.9', s11b.map(s => s.alpha), 149 / 169); t.all('A11.10', s11b.map(s => s.r2XEta), 100 / 169);

  // --- A12 Hata Laboratuvarı ve tekrar tasarımcısı -----------------------------
  const pops = [
    [{ sEta2: 1, sE2: 0.5 }, 2 / 3, Math.sqrt(2 / 3)],
    [{ sEta2: 1, sE2: 0.5, sB2: 0.5 }, 3 / 4, Math.sqrt(1 / 2)],
    [{ sEta2: 1, sE2: 0.5, pi: 0.5, gamma: 1 }, 5 / 7, 2 / Math.sqrt(7), 2 / 3],
    [{ sEta2: 60, sE2: 20 }, 3 / 4, Math.sqrt(3 / 4)],
    [{ sEta2: 60, sE2: 20, sB2: 20 }, 4 / 5, Math.sqrt(3 / 5)],
  ];
  idx = 1;
  for (const [o, rho, rx, within] of pops) { const p = C.errorLabPopulation(o); eq('A12.' + idx++, p.rho, rho); if (within != null) eq('A12.' + idx++, p.withinRho, within); eq('A12.' + idx++, p.rhoXEta, rx); }
  // Not: A12.5-7 sırası ρ, grup içi ρ, ρ_Xη'dir (tests.json ile aynı).
  for (const [o, rho, rx, within] of pops) {
    const sims = [1, 2, 3, 4, 5].map(sd => C.simErrorLab(Object.assign({ N: 20000, seed: sd }, o)));
    t.all('A12.' + idx++, sims.map(s => s.rho), rho);
    if (within != null) { t.all('A12.' + idx++, sims.map(s => s.withinRho), within); }
    t.all('A12.' + idx++, sims.map(s => s.rhoXEta), rx);
  }
  const rdp = C.repeatDesignerPopulation({ sp: 1, spo: .3, spi: .8, se: .6, k: 10 });
  eq('A12.23', rdp.retest, 3 / 4); eq('A12.24', rdp.equiv, 65 / 72); eq('A12.25', rdp.alpha, 65 / 72); eq('A12.26', rdp.delayed, 25 / 36);
  eq('A12.27', rdp.halfDiff.retest, 9 / 25); eq('A12.28', rdp.halfDiff.equiv, 7 / 50); eq('A12.29', rdp.halfDiff.delayed, 11 / 25);
  const rds = [1, 2, 3, 4, 5].map(sd => C.simRepeatDesigner({ N: 20000, k: 10, seed: sd, sp: 1, spo: .3, spi: .8, se: .6 }));
  t.all('A12.30', rds.map(s => s.retest), 3 / 4); t.all('A12.31', rds.map(s => s.equiv), 65 / 72); t.all('A12.32', rds.map(s => s.alpha), 65 / 72); t.all('A12.33', rds.map(s => s.delayed), 25 / 36);
  t.all('A12.34', rds.map(s => s.halfDiff.retest), 9 / 25); t.all('A12.35', rds.map(s => s.halfDiff.equiv), 7 / 50); t.all('A12.36', rds.map(s => s.halfDiff.delayed), 11 / 25);

  // --- A13 Belirlenimcilik ------------------------------------------------------
  const dg = (st) => C.digest(C.derive(st));
  const mods = ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9'];
  const mk = (m, seed) => { const s = C.defaultState(m); s.seed = seed; if (m === 'm2') s.params.reps = 50; if (m === 'm5') s.params.dataMode = 'sim'; if (m === 'm7') s.params.dataset = 'uret'; return s; };
  ok('A13.1', mods.every(m => dg(mk(m, 7)) === dg(mk(m, 7))));
  ok('A13.2', ['m1', 'm2', 'm3', 'm4', 'm5', 'm7'].every(m => dg(mk(m, 7)) !== dg(mk(m, 8))));
  const zE0 = C.latentZ(3, 'E', 30, 2), zE1 = C.latentZ(3, 'E', 30, 2);
  C.latentZ(3, 'B', 30, 1);
  const s4a = C.defaultState('m4'), s4b = C.defaultState('m4'); s4b.params.sB = 3;
  const xa = C.derive(s4a)._series, xb = C.derive(s4b)._series;
  const eA = xa.X1.map((x, i) => x - xa.X2[i]), eB = xb.X1.map((x, i) => x - xb.X2[i]);
  ok('A13.3', JSON.stringify(zE0) === JSON.stringify(zE1) && eA.every((v, i) => Math.abs(v - eB[i]) < 1e-5), 'B açıkken E₁ − E₂ farkları aynı (yuvarlama 1e-6)');
  const z1 = C.latentZ(5, 'm3', 30, 3), z2 = C.latentZ(5, 'm3', 30, 3);
  const s3a = C.defaultState('m3'), s3b = C.defaultState('m3'); s3a.seed = 5; s3b.seed = 5; s3b.params.sigmaE = 9;
  const XA = C.derive(s3a)._series, XB = C.derive(s3b)._series;
  const zA = XA.X.map((x, i) => (x - XA.T[i]) / 4), zB = XB.X.map((x, i) => (x - XB.T[i]) / 9);
  ok('A13.4', JSON.stringify(z1) === JSON.stringify(z2) && zA.every((v, i) => Math.abs(v - zB[i]) < 1e-5));
  const n10 = C.latentZ(9, 'm3', 10, 3), n30 = C.latentZ(9, 'm3', 30, 3);
  ok('A13.5', JSON.stringify(n10) === JSON.stringify(n30.slice(0, 10)));

  // --- A14 Diğer ----------------------------------------------------------------
  eq('A14.1', C.lengthFactor(.6, .8), 8 / 3); eq('A14.2', C.reliabilityFromSEM(4, 10), 3 / 5); eq('A14.3', C.reliabilityFromSEM(4, 40), 9 / 10);
  eq('A14.4', C.attenuationCorrect(.42, .8, .7), 0.42 / Math.sqrt(0.56));
  eq('A14.5', 16, 16); eq('A14.6', 20 - 16, 4); eq('A14.7', 20 + 20 - 2 * 16, 8);
  eq('A14.8', Math.sqrt(.8 * .5), Math.sqrt(0.4));
  eq('A14.9', t0.mean1, 15); eq('A14.10', t0.mean2, 15); eq('A14.11', t0.sumSq1, 70); eq('A14.12', t0.sumSq2, 74); eq('A14.13', t0.sumCross, 68);
  eq('A14.14', t0.r, 68 / Math.sqrt(5180)); eq('A14.15', t0.s1, 14); eq('A14.16', t0.s2, 74 / 5); eq('A14.17', t0.s12, 68 / 5); eq('A14.18', t0.sD, 8 / 5);
  eq('A14.19', t0.errVar, 4 / 5); eq('A14.20', t0.meanVar, 72 / 5); eq('A14.21', t0.rel, 17 / 18);
  const tn = C.twoForms(M5.x1, M5.x2, 'n'); eq('A14.22', tn.sD, 4 / 3); eq('A14.23', tn.errVar, 2 / 3); eq('A14.24', tn.meanVar, 12); eq('A14.25', tn.rel, 17 / 18);
  same('A14.26', t0.S, [[14, 68 / 5], [68 / 5, 74 / 5]]);
  eq('A14.27', t0.residuals[0], 2 / 5); eq('A14.28', t0.residuals[1], 6 / 5); eq('A14.29', t0.residualMean, 4 / 5);
  eq('A14.30', t0.zIdentity, 68 / Math.sqrt(5180)); eq('A14.31', t0.zWrong, 0.7873);
  const m5an = C.anova(M5.x1.map((x, i) => [x, M5.x2[i]])); eq('A14.32', C.iccC1(m5an), 17 / 18); eq('A14.33', C.iccA1(m5an), 17 / 18);
  eq('A14.34', C.binomialCoverage(20, .5, 2), 115957 / 131072); eq('A14.35', C.binomialCoverage(20, .95, 2), 0.9974);
  eq('A14.36', t0.semDiff, 0.894); eq('A14.37', tn.semDiff, 0.816); eq('A14.38', C.maxPhi(.2, .8), 0.25);

  // --- A15 Yanıt anahtarları: content.tr.js'den okunur, core.js ile yeniden hesaplanır
  const K = t.content ? t.content.answerKeys : null;
  const key = (id) => { if (!K || !(id in K)) throw new Error('content.tr.js yanıt anahtarı yok: ' + id); return K[id]; };
  const val = (id, actual) => eq(id, actual, key(id));
  const cat = (id, actual) => ok(id, actual === key(id), 'hesap: ' + actual + ', anahtar: ' + key(id));
  const clsA = [40, 50, 60], clsB = [70, 80, 90];
  cat('A15.1', C.variance(clsA) === C.variance(clsB) ? 'esit' : 'farkli');
  cat('A15.2', C.variance(clsA.map(x => x + 5)) === C.variance(clsA) ? 'degismez' : 'degisir');
  val('A15.3', C.correlation(clsA.concat([45, 70]), clsA.concat([45, 70]).map(x => x + 5)));
  const pts = C.FIXTURES.m1Points, rngH = C.uniformStream(1, 'yari', 0), half = pts.map(x => x + (rngH() < .5 ? 5 : 0));
  cat('A15.4', C.correlation(pts, half) < 1 ? 'r<1' : 'r=1');
  // A15.5 ve A15.6: gürültü ekleme, 200 sınıf üzerinden ortalama
  let covDiff = 0, rDown = 0;
  for (let sd = 1; sd <= 200; sd++) {
    const a = C.defaultState('m1'); a.seed = sd; const b = C.defaultState('m1'); b.seed = sd; b.params.noise = 12;
    const qa = C.derive(a), qb = C.derive(b); covDiff += (qb['m1.kovaryans'] - qa['m1.kovaryans']) / 200; if (qb['m1.r'] < qa['m1.r']) rDown++;
  }
  cat('A15.5', Math.abs(covDiff) < 2 ? 'degismez' : 'degisir');
  cat('A15.6', rDown === 200 ? 'duser' : 'karisik');
  const ay = C.FIXTURES.ayse, ayT = C.mean(ay);
  val('A15.7', ayT); same('A15.8', ay.map(x => x - ayT), key('A15.8'));
  const ay3 = ay.map(x => x + 3), ay3T = C.mean(ay3); val('A15.9', ay3T); same('A15.10', ay3.map(x => x - ay3T), key('A15.10'));
  val('A15.11', 64 / (64 + 16)); val('A15.12', 16 / 32); val('A15.13', Math.sqrt(16)); val('A15.14', Math.sqrt(16));
  const p3a = C.derive(C.presetState('m3.varsayilan')), p3b = C.derive(C.presetState('m3.turdes'));
  cat('A15.15', p3b['m3.rho'] < p3a['m3.rho'] ? 'duser' : 'duser_degil'); cat('A15.16', p3b['m3.osh'] === p3a['m3.osh'] ? 'degismez' : 'degisir');
  const m4d = C.derive(C.presetState('m4.varsayilan')), m4c = C.derive(C.presetState('m4.sabit'));
  const m4c4 = (() => { const s = C.defaultState('m4'); s.params.c = -4; return C.derive(s); })();
  cat('A15.17', Math.abs(m4c['m4.r12'] - m4d['m4.r12']) < 1e-9 ? 'degismez' : 'degisir');
  const vA = C.variance(m4d._series.X1), vC = C.variance(m4c._series.X1);
  cat('A15.18', Math.abs(vA - vC) < 1e-6 ? 'degismez' : 'degisir');
  cat('A15.19', m4c['m4.osh'] === m4d['m4.osh'] ? 'degismez' : 'degisir');
  cat('A15.20', Math.abs(m4c['m4.ortalama_orneklem'] - m4d['m4.ortalama_orneklem'] - 5) < 1e-6 ? 'ortalama+c' : 'baska');
  cat('A15.21', m4c['m4.gecme_orani'] !== m4d['m4.gecme_orani'] ? 'degisir' : 'degismez');
  val('A15.22', C.alphaVariance(A11));
  const m4w = C.derive(C.presetState('m4.orantili'));
  cat('A15.23', Math.abs(m4w['m4.r12'] - m4d['m4.r12']) < 1e-9 ? 'degismez' : 'degisir');
  val('A15.24', C.sem(Math.sqrt(C.variance(y11)), C.alphaVariance(A11))); val('A15.25', C.mean(y11));
  const e3a = C.errorLabPopulation({ sEta2: 60, sE2: 20 }), e3b = C.errorLabPopulation({ sEta2: 60, sE2: 20, sB2: 20 });
  val('A15.26', e3a.rho); val('A15.27', e3a.rhoXEta); val('A15.28', e3b.rho); val('A15.29', e3b.rhoXEta); val('A15.30', e3b.ceiling);
  const m4k = C.derive(C.presetState('m4.kararli')), m4v = C.derive(C.presetState('m4.degisen')), m4t = C.derive(C.presetState('m4.tesadufi'));
  cat('A15.31', m4v['m4.rho'] < m4d['m4.rho'] && m4v['m4.r12'] < m4d['m4.r12'] ? 'duser' : 'duser_degil');
  cat('A15.32', m4t['m4.rho'] < m4d['m4.rho'] ? 'duser' : 'duser_degil');
  cat('A15.33', m4t['m4.rho_xeta'] < m4d['m4.rho_xeta'] ? 'duser' : 'duser_degil');
  val('A15.34', C.iccC1(m5sh)); val('A15.35', C.iccA1(m5sh));
  val('A15.36', C.twoForms(M5.x1, M5.x2.map(x => x + 5)).r);
  cat('A15.37', C.twoForms(M5.x1, M5.x2.map(x => x + 5)).meanD !== 0 ? 'sifir_degil' : 'sifir');
  val('A15.38', C.alphaVariance(bias([0, 2, 4])));
  // Toplam puan düzeyinde U = 4 (P1, P3, P5), η yerine özgün Y: σ_U² + 2σ_ηU
  const U = [0, 1, 2, 3, 4, 5].map(p => [0, 2, 4].includes(p) ? 4 : 0);
  cat('A15.39', C.variance(U) + 2 * C.covariance(y, U) < 0 ? 'negatif' : 'negatif_degil');
  const sg = C.errorLabPopulation({ sEta2: 1, sE2: .5, pi: .5, gamma: 1 });
  val('A15.40', sg.rho); val('A15.41', sg.withinRho); cat('A15.42', sg.groupBias === 1 ? 'gamma' : 'baska');
  val('A15.43', C.alphaVariance(Acap)); cat('A15.44', C.variance(C.rowSums(Acap)) !== 20 ? 'degisir' : 'degismez');
  val('A15.45', C.alphaVariance(bias([1, 2]))); val('A15.46', C.alphaVariance(bias([1, 3, 5]))); val('A15.47', C.alphaVariance(bias([0, 2, 4])));
  cat('A15.48', Math.abs(m4c4['m4.r12'] - m4d['m4.r12']) < 1e-9 ? 'degismez' : 'degisir');
  cat('A15.49', m4c4['m4.osh'] === m4d['m4.osh'] ? 'degismez' : 'degisir');
  val('A15.50', m4c4['m4.ortalama_orneklem'] - m4d['m4.ortalama_orneklem']);
  cat('A15.51', m4c4['m4.gecme_orani'] !== m4d['m4.gecme_orani'] ? 'degisir' : 'degismez');
  cat('A15.52', m4k['m4.rho'] > m4d['m4.rho'] ? 'yukselir' : 'yukselmez');
  cat('A15.53', m4k['m4.rho_xeta'] < m4d['m4.rho_xeta'] ? 'duser' : 'duser_degil');
  const e5 = 100 * (1 - .84); val('A15.54', e5); val('A15.55', Math.sqrt(e5)); same('A15.56', [70 - Math.sqrt(e5), 70 + Math.sqrt(e5)], key('A15.56'));
  const roleTable = t.content.sourceRoles;
  cat('A15.57', roleTable.gecici.tekrar); cat('A15.58', roleTable.gecici.alfa);
  cat('A15.59', rdp.alpha > rdp.retest ? 'fazla' : 'az');
  val('A15.60', C.spearmanBrown(.6, 2)); val('A15.61', C.spearmanBrown(.75, 3)); val('A15.62', C.lengthFactor(.6, .8));
  const S8 = [[4, 2, 2], [2, 5, 2], [2, 2, 6]]; val('A15.63', C.sumAll(S8)); val('A15.64', C.alphaFromMatrix(S8));
  val('A15.65', 1 - 2 / 10);
  cat('A15.66', 'phi');
  let minPhi = Infinity; for (let l = 0; l <= 600; l++) { const lam = 0 + l * 0.01; minPhi = Math.min(minPhi, C.phiLambda(an.comps, an.grand, lam, 4)); }
  val('A15.67', minPhi);

  // --- A16 El hesabı dostu üretici -----------------------------------------------
  const G = [], R = [];
  for (let sd = 1; sd <= 100; sd++) { G.push(C.genAlphaData(sd)); R.push(C.genRData(sd)); }
  ok('A16.1', G.every(d => d.length === 6)); ok('A16.2', G.every(d => d[0].length === 3 || d[0].length === 4));
  ok('A16.3', G.every(d => d.every(r => r.every(x => Number.isInteger(x) && x >= 1 && x <= 5))));
  ok('A16.4', G.every(d => C.columns(d).every(c => Math.abs(C.mean(c) - Math.round(C.mean(c))) < 1e-9)));
  ok('A16.5', G.every(d => Math.abs(C.mean(C.rowSums(d)) - Math.round(C.mean(C.rowSums(d)))) < 1e-9));
  ok('A16.6', G.every(d => C.columns(d).every(c => C.variance(c) > 0)));
  ok('A16.7', G.every(d => C.columns(d).every(c => new Set(c).size >= 3)));
  ok('A16.8', G.every(d => { const a = C.alphaVariance(d); return a >= .5 && a <= .9; }));
  ok('A16.9', G.every(d => C.columns(d).concat([C.rowSums(d)]).every(c => Math.abs(10 * C.variance(c) - Math.round(10 * C.variance(c))) < 1e-9)));
  ok('A16.10', G.every(d => { const v = C.alphaVariance(d); return Math.abs(v - C.alphaMatrix(d)) <= 1e-10 && Math.abs(v - C.alphaAnova(d)) <= 1e-10; }));
  ok('A16.11', R.every(([a, b]) => a.length === 6 && b.length === 6));
  ok('A16.12', R.every(([a, b]) => a.concat(b).every(x => Number.isInteger(x) && x >= 1 && x <= 20)));
  ok('A16.13', R.every(([a, b]) => Number.isInteger(C.mean(a)) && Number.isInteger(C.mean(b))));
  ok('A16.14', R.every(([a, b]) => C.correlation(a, b) > .5));

  // --- A17 Gizli küme -------------------------------------------------------------
  const hiddenIn = (obj) => Object.keys(obj).filter(k => k.startsWith(C.HIDDEN_PREFIX));
  mods.forEach((m, i) => ok('A17.' + (i + 1), hiddenIn(C.project(C.defaultState(m), 'real')).length === 0 && hiddenIn(C.project(C.defaultState(m), 'backstage')).length >= 0));
  ok('A17.10', C.listPresets().every(id => hiddenIn(C.project(C.presetState(id), 'real')).length === 0));
};
