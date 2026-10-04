fetch('https://cdn.jsdelivr.net/gh/wantajudeen/jagx-ai-app@420dee549ffb7ebfa6efd098382018dcc4905a81/app.js')
  .then(function(r){ return r.text(); })
  .then(function(code){
    code = code.replace(
      "var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills'];",
      "var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills','terms','privacy'];"
    );
    code = code.replace(
      "settings:'Settings'",
      "settings:'Settings',terms:'Terms',privacy:'Privacy'"
    );
    (0, eval)(code);
    setTimeout(function(){
      var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
      if(h==='terms'||h==='privacy'){
        document.querySelectorAll('.page').forEach(function(p){
          p.classList.remove('on');
          p.style.display='none';
        });
        var page=document.getElementById('page-'+h);
        if(page){ page.classList.add('on'); page.style.display='flex'; }
        var tt=document.getElementById('topTitle');
        if(tt) tt.textContent=h==='terms'?'Terms':'Privacy';
      }
    }, 200);
  })
  .catch(function(e){ console.error('JagX failed to load core app.js', e); });

if(!document.getElementById('jxbotfix')){
  var s=document.createElement('script');
  s.id='jxbotfix';
  s.src='./botfix.js?v=39';
  document.body.appendChild(s);
}
