fetch('https://cdn.jsdelivr.net/gh/wantajudeen/jagx-ai-app@420dee549ffb7ebfa6efd098382018dcc4905a81/app.js')
  .then(function(r){ return r.text(); })
  .then(function(code){
    code = code.replace(
      "var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills'];",
      "var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills','terms','privacy'];"
    );
    (0, eval)(code);
  })
  .catch(function(e){ console.error('JagX failed to load core app.js', e); });
