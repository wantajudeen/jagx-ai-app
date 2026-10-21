/* Compatibility loader for older pages. The application core now lives in core.js. */
(function () {
  if (window.__jagxCoreLoading || document.querySelector('script[src*="core.js"]')) return;
  window.__jagxCoreLoading = true;
  var script = document.createElement('script');
  script.src = './core.js?v=1';
  script.onload = function () { window.__jagxCoreLoading = false; };
  script.onerror = function () {
    window.__jagxCoreLoading = false;
    console.error('JagX AI core failed to load.');
  };
  document.body.appendChild(script);
})();
