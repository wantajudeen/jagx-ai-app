(function(){
  var skills=[];
  function sk(){ try{ return (window.__jagxUserId||'guest')+'_skills'; }catch(e){ return 'guest_skills'; } }
  function load(){ try{ skills=JSON.parse(localStorage.getItem(sk())||'[]'); }catch(e){ skills=[]; } }
  function save(){ try{ localStorage.setItem(sk(), JSON.stringify(skills)); }catch(e){} }
  window.JagXSkills=function(){ load(); return skills; };
  function renderSkills(){
    var el=document.getElementById('skillList'); if(!el) return;
    load(); el.innerHTML='';
    if(!skills.length){ el.innerHTML='<div class="box"><div class="tiny">No skills yet. Add one below.</div></div>'; return; }
    skills.forEach(function(s,i){
      var d=document.createElement('div'); d.className='srow';
      d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">Remove</button>';
      d.querySelector('b').textContent=s.name;
      d.querySelector('.sub').textContent=(s.body||'').slice(0,80);
      d.querySelector('.tog').onclick=function(){ skills.splice(i,1); save(); renderSkills(); };
      el.appendChild(d);
    });
  }
  function bind(){
    var add=document.getElementById('skAdd');
    if(add) add.onclick=function(){
      var n=(document.getElementById('skName').value||'').trim();
      var b=(document.getElementById('skBody').value||'').trim();
      if(!n||!b) return;
      skills.push({name:n,body:b}); save();
      document.getElementById('skName').value=''; document.getElementById('skBody').value='';
      renderSkills();
    };
    window.addEventListener('hashchange', function(){
      if((location.hash||'').indexOf('skills')>=0) renderSkills();
    });
    load(); renderSkills();
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', bind);
  else bind();
})();
