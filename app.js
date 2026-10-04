(function(){
  // Temporary multi-part loader while restoring full script
  var parts = ['app_part0.js.txt','app_part1.js.txt','app_part2.js.txt'];
  var base = (document.currentScript && document.currentScript.src) ? document.currentScript.src.replace(/[^\/]+$/, '') : './';
  var code = '';
  var i = 0;
  function next(){
    if(i >= parts.length){
      try { (0, eval)(code); } catch(e){ console.error('JagX app load error', e); }
      return;
    }
    var x = new XMLHttpRequest();
    x.open('GET', base + parts[i] + '?v=' + Date.now(), true);
    x.onload = function(){
      if(x.status >= 200 && x.status < 300){ code += x.responseText; i++; next(); }
      else { console.error('Failed to load', parts[i], x.status); }
    };
    x.onerror = function(){ console.error('Network error loading', parts[i]); };
    x.send();
  }
  next();
})();
