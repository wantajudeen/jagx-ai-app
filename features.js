(function(){
  var skills=[], plugins=[
    {id:'pdf',name:'PDF export',on:true,note:'Download last answer'},
    {id:'links',name:'Link reader',on:true,note:'Read public URLs'},
    {id:'github',name:'GitHub push',on:false,note:'Needs token in Vault'}
  ];
  function sk(){var id=(window.__jagxUserId)||'guest';return id+'_skills';}
  try{skills=JSON.parse(localStorage.getItem(sk())||'[]');}catch(e){skills=[];}
  try{var p=JSON.parse(localStorage.getItem('jagx_plugins')||'null');if(p)plugins=p;}catch(e){}
  function saveSk(){try{localStorage.setItem(sk(),JSON.stringify(skills));}catch(e){}}
  function savePl(){try{localStorage.setItem('jagx_plugins',JSON.stringify(plugins));}catch(e){}}
  window.JagXSkills=function(){return skills.filter(function(s){return s.on!==false;});};
  function allPanels(){return ['panelBot','panelConn','panelVault','panelSet','panelAuto','panelLib','panelProj','panelTools','panelSkills','panelPlug','panelBox','panelGh'];}
  function openPanel(id){
    document.getElementById('drawer').classList.remove('open');
    document.getElementById('scrim').classList.remove('open');
    document.getElementById('thread').style.display='none';
    allPanels().forEach(function(p){var el=document.getElementById(p); if(el) el.classList.toggle('open',p===id);});
  }
  function renderSkills(){
    var el=document.getElementById('skillList'); if(!el) return;
    el.innerHTML='';
    if(!skills.length){el.innerHTML='<div class="box"><div class="tiny">No skills yet.</div></div>';return;}
    skills.forEach(function(s){
      var d=document.createElement('div'); d.className='srow';
      d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">On</button>';
      d.querySelector('b').textContent=s.name;
      d.querySelector('.sub').textContent=(s.body||'').slice(0,80);
      var t=d.querySelector('.tog'); t.textContent=s.on===false?'Off':'On'; if(s.on!==false)t.classList.add('on');
      t.onclick=function(){s.on=!(s.on!==false); saveSk(); renderSkills();};
      el.appendChild(d);
    });
  }
  function renderPlugs(){
    var el=document.getElementById('plugList'); if(!el) return;
    el.innerHTML='';
    plugins.forEach(function(p){
      var d=document.createElement('button'); d.className='srow'; d.type='button';
      d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><span class="tog"></span>';
      d.querySelector('b').textContent=p.name; d.querySelector('.sub').textContent=p.note||'';
      var t=d.querySelector('.tog'); t.textContent=p.on?'On':'Off'; if(p.on)t.classList.add('on');
      d.onclick=function(){p.on=!p.on; savePl(); renderPlugs();};
      el.appendChild(d);
    });
  }
  function lastBotText(){
    var ps=document.querySelectorAll('.msg.bot .bubble');
    if(!ps.length) return '';
    return ps[ps.length-1].innerText||'';
  }
  function downloadPdf(){
    var text=lastBotText()||'No answer yet.';
    var w=window.open('','_blank');
    w.document.write('<html><head><title>JagX notes</title><style>body{font-family:Georgia,serif;padding:32px;max-width:720px;margin:auto;line-height:1.5}h1{font-size:20px}</style></head><body><h1>JagX AI</h1><pre style="white-space:pre-wrap;font-family:Georgia,serif">'+
      text.replace(/&/g,'&').replace(/</g,'<')+'</pre><script>window.onload=function(){window.print()}<\/script></body></html>');
    w.document.close();
  }
  async function readLink(){
    var u=(document.getElementById('linkUrl').value||'').trim();
    if(!u) return;
    if(!/^https?:\/\//i.test(u)) u='https://'+u;
    var input=document.getElementById('input');
    input.value='Read this link and summarize clearly. If it is TikTok or a blocked page, say what you can infer from the URL only:\n'+u;
    var bu=document.getElementById('browseUrl'); if(bu) bu.value=u;
    try{
      var r=await fetch('https://r.jina.ai/'+u);
      var t=await r.text();
      if(t && t.length>40){
        input.value='Here is extracted text from '+u+' (may be incomplete for TikTok). Summarize and answer based on it:\n\n'+t.slice(0,8000);
      }
    }catch(e){}
    if(typeof window.JagXSend==='function') window.JagXSend();
    else { var b=document.getElementById('send'); if(b) b.click(); }
  }
  function runBox(){
    var code=document.getElementById('boxCode').value||'';
    var frame=document.getElementById('boxFrame');
    var html=code;
    if(!/<\s*html/i.test(code) && !/<\s*body/i.test(code)){
      if(/<\s*(div|p|h1|style|button)/i.test(code)) html='<!DOCTYPE html><html><head></head><body>'+code+'</body></html>';
      else html='<!DOCTYPE html><html><body><script>'+code.replace(/<\/script/gi,'<\\/script')+'<\/script></body></html>';
    }
    frame.srcdoc=html;
  }
  function vaultToken(){
    try{
      var raw=localStorage.getItem(((window.__jagxUserId)||'guest')+'_vault')||'[]';
      var list=JSON.parse(raw);
      var hit=list.find(function(v){return /github/i.test(v.label||'');});
      if(!hit||!hit.secret) return '';
      try{return decodeURIComponent(escape(atob(hit.secret)));}catch(e){return '';}
    }catch(e){return '';}
  }
  async function ghPush(){
    var st=document.getElementById('ghStatus');
    var repo=(document.getElementById('ghRepo').value||'').trim();
    var path=(document.getElementById('ghPath').value||'').trim();
    var msg=(document.getElementById('ghMsg').value||'Update via JagX').trim();
    var body=document.getElementById('ghBody').value||'';
    var tok=vaultToken();
    if(!tok){st.textContent='Add a Vault item labeled GitHub with a PAT first.';return;}
    if(!repo||!path){st.textContent='Need owner/repo and path.';return;}
    st.textContent='Pushing…';
    try{
      var get=await fetch('https://api.github.com/repos/'+repo+'/contents/'+path,{headers:{Authorization:'Bearer '+tok,'Accept':'application/vnd.github+json'}});
      var sha=null;
      if(get.ok){var j=await get.json(); sha=j.sha;}
      var payload={message:msg,content:btoa(unescape(encodeURIComponent(body)))};
      if(sha) payload.sha=sha;
      var put=await fetch('https://api.github.com/repos/'+repo+'/contents/'+path,{method:'PUT',headers:{Authorization:'Bearer '+tok,'Accept':'application/vnd.github+json','Content-Type':'application/json'},body:JSON.stringify(payload)});
      var out=await put.json();
      st.textContent=put.ok?('Pushed '+path): (out.message||('Error '+put.status));
    }catch(e){st.textContent=String(e.message||e);}
  }
  function bind(){
    var map={dSkills:'panelSkills',dPlug:'panelPlug',dGh:'panelGh',dTools:'panelTools'};
    Object.keys(map).forEach(function(id){
      var b=document.getElementById(id); if(!b) return;
      b.onclick=function(){
        openPanel(map[id]);
        if(id==='dSkills') renderSkills();
        if(id==='dPlug') renderPlugs();
      };
    });
    var so=document.getElementById('btnSignOut');
    if(so) so.onclick=function(){ var a=document.getElementById('btnAuth'); if(a) a.click(); };
    var cfs=document.getElementById('dConnFromSet');
    if(cfs) cfs.onclick=function(){ openPanel('panelConn'); };
    var vfs=document.getElementById('dVaultFromSet');
    if(vfs) vfs.onclick=function(){ openPanel('panelVault'); };
    var add=document.getElementById('skAdd');
    if(add) add.onclick=function(){
      var n=(document.getElementById('skName').value||'').trim();
      var b=(document.getElementById('skBody').value||'').trim();
      if(!n||!b) return;
      skills.push({id:'s_'+Date.now(),name:n,body:b,on:true});
      document.getElementById('skName').value=''; document.getElementById('skBody').value='';
      saveSk(); renderSkills();
    };
    var draft=document.getElementById('skDraft');
    if(draft) draft.onclick=function(){
      document.getElementById('thread').style.display='';
      allPanels().forEach(function(p){var el=document.getElementById(p); if(el) el.classList.remove('open');});
      document.getElementById('input').value='Draft a reusable JagX skill. Give a short name and the exact instruction text I should paste into Skills.';
      document.getElementById('send').click();
    };
    var pdf=document.getElementById('btnPdf'); if(pdf) pdf.onclick=downloadPdf;
    var lg=document.getElementById('linkGo'); if(lg) lg.onclick=readLink;
    var br=document.getElementById('boxRun'); if(br) br.onclick=runBox;
    var gp=document.getElementById('ghPush'); if(gp) gp.onclick=ghPush;
    renderSkills(); renderPlugs();
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',bind); else bind();
})();
