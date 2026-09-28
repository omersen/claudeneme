(function () {
  function kopyala(metin, dugme) {
    var bitti = function () { var e = dugme.textContent; dugme.textContent = 'Kopyalandı'; setTimeout(function () { dugme.textContent = e; }, 1600); };
    try {
      navigator.clipboard.writeText(metin).then(bitti, function () { yedek(metin); bitti(); });
    } catch (e) { yedek(metin); bitti(); }
  }
  function yedek(metin) {
    var t = document.createElement('textarea'); t.value = metin; document.body.appendChild(t); t.select();
    try { document.execCommand('copy'); } catch (e) {} document.body.removeChild(t);
  }
  document.addEventListener('click', function (ev) {
    var d = ev.target.closest('button'); if (!d) return;
    if (d.dataset.hedef) { var el = document.getElementById(d.dataset.hedef); if (el) kopyala(el.textContent, d); }
    if (d.dataset.tum) { var t = document.getElementById('tum-kod'); if (t) kopyala(t.value, d); }
  });
  var linkler = Array.prototype.slice.call(document.querySelectorAll('nav.icindekiler a'));
  if ('IntersectionObserver' in window) {
    var gozcu = new IntersectionObserver(function (girdiler) {
      girdiler.forEach(function (g) {
        if (g.isIntersecting) linkler.forEach(function (a) { a.classList.toggle('etkin', a.getAttribute('href') === '#' + g.target.id); });
      });
    }, { rootMargin: '-20% 0px -70% 0px' });
    document.querySelectorAll('main > section[id]').forEach(function (s) { gozcu.observe(s); });
  }
  if (typeof hljs !== 'undefined') {
    document.querySelectorAll('pre > code.language-r').forEach(function (el) {
      try { el.innerHTML = hljs.highlight(el.textContent, { language: 'r', ignoreIllegals: true }).value; el.classList.add('hljs'); } catch (e) {}
    });
  }
})();
