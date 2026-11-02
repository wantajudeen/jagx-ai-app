/* Compatibility loader for older pages. The application core now lives in core.js. */
(function () {
  function loadEnhancements() {
    if (document.querySelector('script[src*="enhancements.js"]')) return;
    var extra = document.createElement('script');
    extra.src = './enhancements.js?v=2';
    extra.onerror = function () { console.error('JagX AI enhancements failed to load.'); };
    document.body.appendChild(extra);
  }
  if (window.__jagxCoreLoading || document.querySelector('script[src*="core.js"]')) {
    loadEnhancements();
    return;
  }
  window.__jagxCoreLoading = true;
  var script = document.createElement('script');
  script.src = './core.js?v=2';
  script.onload = function () {
    window.__jagxCoreLoading = false;
    loadEnhancements();
  };
  script.onerror = function () {
    window.__jagxCoreLoading = false;
    console.error('JagX AI core failed to load.');
  };
  document.body.appendChild(script);
})();
