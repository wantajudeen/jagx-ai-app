(function(){
  var API='https://jagx-ai-v2.onrender.com';
  var SUPABASE_URL='https://xxxyqzuwvavqsccnlkxa.supabase.co';
  var SUPABASE_ANON_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHlxenV3dmF2cXNjY25sa3hhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NjY4MDcsImV4cCI6MjEwNTE0MjgwN30.pd3D3ULeR90gM7HB8xAlERr8swUyc_aJaIxDqc-vH2Y';
  var supabase=null,session=null,modeSignUp=false,mode='ask',botOn=false,pendingFile=null;
  var chats=[],chatId=null,history=[],vault=[],conns=[];
  var thinkEl=null,thinkTimer=null,thinkStart=0;
  var PANELS=['panelBot','panelConn','panelVault','panelSet','panelAuto','panelLib','panelProj','panelTools','panelSkills','panelPlug','panelBox','panelGh'];
  var thread=document.getElementById('thread'),empty=document.getElementById('empty');
  var input=document.getElementById('input'),sendBtn=document.getElementById('send'),main=document.getElementById('main');
  var authModal=document.getElementById('authModal'),authErr=document.getElementById('authErr'),authOk=document.getElementById('authOk');
  var drawer=document.getElementById('drawer'),scrim=document.getElementById('scrim');
  function uid(){return 'c_'+Date.now().toString(36)+Math.random().toString(36).slice(2,6);}
  function sk(k){var id=session&&session.user&&session.user.id;return (id||'guest')+'_'+k;}
  function showErr(m){authErr.style.display='block';authErr.textContent=m;authOk.style.display='none';}
  function showOk(m){authOk.style.display='block';authOk.textContent=m;authErr.style.display='none';}
  function openDrawer(){drawer.classList.add('open');scrim.classList.add('open');}
  function closeDrawer(){drawer.classList.remove('open');scrim.classList.remove('open');}
  function when(d){var n=Date.now()-(d||0);if(n<6e4)return 'Now';if(n<864e5)return 'Today';if(n<1728e5)return 'Yesterday';return new Date(d||Date.now()).toLocaleDateString();}
  function loadLocal(){
    try{chats=JSON.parse(localStorage.getItem(sk('chats'))||'[]');}catch(e){chats=[];}
    try{vault=JSON.parse(localStorage.getItem(sk('vault'))||'[]');}catch(e){vault=[];}
    try{conns=JSON.parse(localStorage.getItem(sk('conns'))||'[]');}catch(e){conns=[];}
    if(!chats.length){chatId=uid();chats=[{id:chatId,title:'New conversation',msgs:[],updated:Date.now()}];}
    if(!chatId)chatId=chats[0].id;
    var cur=chats.find(function(c){return c.id===chatId;})||chats[0];chatId=cur.id;history=cur.msgs||[];
  }
  function saveLocal(){
    var cur=chats.find(function(c){return c.id===chatId;});
    if(cur){cur.msgs=history;cur.updated=Date.now();if((!cur.title||cur.title==='New conversation')&&history.length){var first=history.find(function(m){return m.role==='user';});if(first)cur.title=String(first.content).slice(0,48);}}
    try{localStorage.setItem(sk('chats'),JSON.stringify(chats));localStorage.setItem(sk('vault'),JSON.stringify(vault));localStorage.setItem(sk('conns'),JSON.stringify(conns));}catch(e){}
    if(supabase&&session&&session.user){supabase.from('messages').upsert({user_id:session.user.id,chat_id:'all',payload:{chats:chats,conns:conns},updated_at:new Date().toISOString()}).then(function(){}).catch(function(){});}
    renderHist();
  }
  function renderHist(){
    var el=document.getElementById('histList');el.innerHTML='';
    var q=(document.getElementById('drawerSearch').value||'').toLowerCase();
    chats.slice().sort(function(a,b){return (b.updated||0)-(a.updated||0);}).forEach(function(c){
      if(q&&String(c.title||'').toLowerCase().indexOf(q)<0)return;
      var b=document.createElement('button');b.className='hitem';b.type='button';
      b.innerHTML='<div class="ht"></div><div class="hs"></div>';
      b.querySelector('.ht').textContent=c.title||'Conversation';b.querySelector('.hs').textContent=when(c.updated);
      b.onclick=function(){chatId=c.id;history=c.msgs||[];closeDrawer();showChat();renderAll();};
      el.appendChild(b);
    });
  }
  function setSession(s){
    session=s;
    if(s){main.classList.remove('locked');authModal.classList.remove('open');
      input.placeholder=botOn?'Give the bot a task…':(mode==='build'?'Describe what to build…':'Ask anything');
      var u=s.user||{},label=(u.user_metadata&&(u.user_metadata.full_name||u.user_metadata.name))||u.email||'Signed in';
      window.__jagxUserId=(u.id||'guest');
      document.getElementById('userChip').textContent=label;document.getElementById('av').textContent=(label[0]||'J').toUpperCase();
      loadLocal();renderHist();renderAll();renderConns();renderVault();
    }else{main.classList.add('locked');authModal.classList.add('open');input.placeholder='Sign in to chat';
      document.getElementById('userChip').textContent='Guest';document.getElementById('av').textContent='J';}
  }
  function loadScript(src){return new Promise(function(res,rej){var s=document.createElement('script');s.src=src;s.onload=res;s.onerror=rej;document.head.appendChild(s);});}
  async function boot(){
    try{await loadScript('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2');}catch(e){try{await loadScript('https://unpkg.com/@supabase/supabase-js@2');}catch(e2){return showErr('Auth library failed');}}
    if(!window.supabase)return showErr('Auth missing');
    try{supabase=window.supabase.createClient(SUPABASE_URL,SUPABASE_ANON_KEY);var r=await supabase.auth.getSession();setSession(r.data&&r.data.session);supabase.auth.onAuthStateChange(function(_e,s){setSession(s);});}catch(e){showErr(String(e.message||e));}
  }
  document.getElementById('btnMenu').onclick=openDrawer;scrim.onclick=closeDrawer;
  function showPanel(id){main.classList.add('panel-mode');document.getElementById('thread').style.display='none';PANELS.forEach(function(p){var el=document.getElementById(p);if(!el)return;if(p===id){el.classList.add('open');el.style.display='flex';}else{el.classList.remove('open');el.style.display='none';}});}
  function showChat(){main.classList.remove('panel-mode');document.getElementById('thread').style.display='';PANELS.forEach(function(p){var el=document.getElementById(p);if(el){el.classList.remove('open');el.style.display='none';}});}
  document.querySelectorAll('[data-back]').forEach(function(b){b.onclick=showChat;});
  document.getElementById('dNew').onclick=function(){closeDrawer();newChat();};
  document.getElementById('btnNew').onclick=newChat;
  document.getElementById('dBot').onclick=function(){closeDrawer();showPanel('panelBot');};
  var dTools=document.getElementById('dTools');if(dTools)dTools.onclick=function(){closeDrawer();showPanel('panelTools');};
  document.querySelectorAll('[data-prompt]').forEach(function(btn){btn.onclick=function(){var p=btn.getAttribute('data-prompt')||'';showChat();input.value=p;input.focus();};});
  document.getElementById('dSet').onclick=function(){closeDrawer();showPanel('panelSet');};
  document.getElementById('dAuto').onclick=function(){closeDrawer();showPanel('panelAuto');};
  document.getElementById('dLib').onclick=function(){closeDrawer();showPanel('panelLib');};
  document.getElementById('dProj').onclick=function(){closeDrawer();showPanel('panelProj');};
  document.getElementById('dDl').onclick=function(){document.getElementById('dlModal').classList.add('open');};
  document.getElementById('dlClose').onclick=function(){document.getElementById('dlModal').classList.remove('open');};
  document.getElementById('drawerSearch').oninput=renderHist;
  document.getElementById('tabAsk').onclick=function(){mode='ask';botOn=false;this.classList.add('on');document.getElementById('tabBuild').classList.remove('on');document.getElementById('modeChip').textContent='Ask · Fast';input.placeholder=session?'Ask anything':'Sign in to chat';showChat();};
  document.getElementById('tabBuild').onclick=function(){mode='build';botOn=false;this.classList.add('on');document.getElementById('tabAsk').classList.remove('on');document.getElementById('modeChip').textContent='Build · Fast';input.placeholder=session?'Describe what to build…':'Sign in to chat';showChat();};
  document.getElementById('botLive').onclick=function(){botOn=true;mode='bot';showChat();document.getElementById('modeChip').textContent='Bot · Live';input.placeholder='Give the bot a task…';document.getElementById('tabAsk').classList.remove('on');document.getElementById('tabBuild').classList.remove('on');};
  document.getElementById('browseGo').onclick=function(){var u=(document.getElementById('browseUrl').value||'').trim();if(!u)return;if(!/^https?:\/\//i.test(u))u='https://'+u;document.getElementById('browseFrame').src=u;};
  document.getElementById('authToggle').onclick=function(){modeSignUp=!modeSignUp;document.getElementById('authTitle').textContent=modeSignUp?'Create account':'Sign in';document.getElementById('authSubmit').textContent=modeSignUp?'Create account':'Sign in with password';document.getElementById('authToggle').textContent=modeSignUp?'Already have an account? Sign in':'New here? Create an account';document.getElementById('nameWrap').style.display=modeSignUp?'block':'none';};
  document.getElementById('authSubmit').onclick=async function(){
    if(!supabase)return showErr('Auth loading…');
    var email=(document.getElementById('authEmail').value||'').trim(),password=document.getElementById('authPass').value||'',name=(document.getElementById('authName').value||'').trim();
    if(!email||!password)return showErr('Email and password required');
    try{if(modeSignUp){if(!name)return showErr('Enter your name');var up=await supabase.auth.signUp({email:email,password:password,options:{data:{full_name:name}}});if(up.error)return showErr(up.error.message);if(!up.data.session)return showOk('Check email to confirm, then sign in.');setSession(up.data.session);}else{var inn=await supabase.auth.signInWithPassword({email:email,password:password});if(inn.error)return showErr(inn.error.message);setSession(inn.data.session);}}catch(e){showErr(String(e.message||e));}
  };
  document.getElementById('btnGoogle').onclick=async function(){if(!supabase)return showErr('Auth loading…');var r=await supabase.auth.signInWithOAuth({provider:'google',options:{redirectTo:location.origin}});if(r.error)showErr(r.error.message);};
  document.getElementById('btnSendOtp').onclick=async function(){if(!supabase)return showErr('Auth loading…');var email=(document.getElementById('authEmail').value||'').trim();if(!email)return showErr('Enter your email first');try{var r=await supabase.auth.signInWithOtp({email:email,options:{shouldCreateUser:true}});if(r.error)return showErr(r.error.message);document.getElementById('otpWrap').style.display='block';showOk('OTP sent to your email. Enter the 6-digit code.');}catch(e){showErr(String(e.message||e));}};
  document.getElementById('btnVerifyOtp').onclick=async function(){if(!supabase)return showErr('Auth loading…');var email=(document.getElementById('authEmail').value||'').trim();var token=(document.getElementById('authOtp').value||'').trim();if(!email||!token)return showErr('Email and OTP required');try{var r=await supabase.auth.verifyOtp({email:email,token:token,type:'email'});if(r.error)return showErr(r.error.message);setSession(r.data&&r.data.session);showOk('Signed in.');}catch(e){showErr(String(e.message||e));}};
  document.getElementById('btnAuth').onclick=async function(){closeDrawer();if(session&&supabase){await supabase.auth.signOut();setSession(null);history=[];renderAll();}else authModal.classList.add('open');};
  document.getElementById('btnPlus').onclick=function(){document.getElementById('filePick').click();};
  document.getElementById('filePick').onchange=function(e){var f=e.target.files&&e.target.files[0];if(f)pendingFile=f;};
  document.getElementById('clearHist').onclick=function(){chats=[{id:uid(),title:'New conversation',msgs:[],updated:Date.now()}];chatId=chats[0].id;history=[];saveLocal();renderAll();};
  function renderConns(){var el=document.getElementById('connList');if(!el)return;el.innerHTML='';if(!conns.length){el.innerHTML='<div class="box"><div class="tiny">Nothing connected yet.</div></div>';return;}conns.forEach(function(c){var d=document.createElement('button');d.className='srow';d.type='button';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><span class="tog"></span>';d.querySelector('b').textContent=c.name;d.querySelector('.sub').textContent=c.type+(c.end?' · '+c.end:'');var t=d.querySelector('.tog');t.textContent=c.on?'On':'Off';if(c.on)t.classList.add('on');d.onclick=function(){c.on=!c.on;saveLocal();renderConns();};el.appendChild(d);});}
  document.getElementById('cAdd').onclick=function(){var name=(document.getElementById('cName').value||'').trim(),type=document.getElementById('cType').value,end=(document.getElementById('cEnd').value||'').trim();if(!name)return;conns.push({id:uid(),name:name,type:type,end:end,on:true});document.getElementById('cName').value='';document.getElementById('cEnd').value='';saveLocal();renderConns();};
  function renderVault(){var el=document.getElementById('vaultList');if(!el)return;el.innerHTML='';if(!vault.length){el.innerHTML='<div class="box"><div class="tiny">Vault empty — save GitHub PAT here with label GitHub.</div></div>';return;}vault.forEach(function(v,i){var d=document.createElement('div');d.className='srow';d.innerHTML='<div class="grow"><b></b><div class="sub">••••••••</div></div><button class="tog" type="button">Remove</button>';d.querySelector('b').textContent=v.label;d.querySelector('.tog').onclick=function(){vault.splice(i,1);saveLocal();renderVault();};el.appendChild(d);});}
  document.getElementById('vAdd').onclick=function(){var label=(document.getElementById('vLabel').value||'').trim(),secret=document.getElementById('vSecret').value||'';if(!label||!secret)return;vault.push({id:uid(),label:label,secret:btoa(unescape(encodeURIComponent(secret)))});document.getElementById('vLabel').value='';document.getElementById('vSecret').value='';saveLocal();renderVault();};
  function newChat(){chatId=uid();chats.unshift({id:chatId,title:'New conversation',msgs:[],updated:Date.now()});history=[];saveLocal();showChat();renderAll();}
  function escapeHtml(s){return String(s).replace(/&/g,'&').replace(/</g,'<').replace(/>/g,'>');}
  function formatBot(text){var raw=String(text||'');raw=raw.replace(/<br\s*\/?>/gi,'\n').replace(/<\/?[^>]+>/g,'');raw=raw.replace(/\*\*([^*]+)\*\*/g,'$1');var lines=raw.split('\n'),out=[],i=0;while(i<lines.length){var line=lines[i];if(/^\s*\|.+\|\s*$/.test(line)){var rows=[];while(i<lines.length&&/^\s*\|.+\|\s*$/.test(lines[i])){var cells=lines[i].trim().replace(/^\|/,'').replace(/\|$/,'').split('|').map(function(c){return c.trim();});if(!cells.every(function(c){return /^:?-+:?$/.test(c)||c==='';}))rows.push(cells);i++;}if(rows.length){var h='<table><thead><tr>'+rows[0].map(function(c){return '<th>'+escapeHtml(c)+'</th>';}).join('')+'</tr></thead><tbody>';for(var r=1;r<rows.length;r++)h+='<tr>'+rows[r].map(function(c){return '<td>'+escapeHtml(c)+'</td>';}).join('')+'</tr>';h+='</tbody></table>';out.push(h);}continue;}if(/^\s*```/.test(line)){var code=[];i++;while(i<lines.length&&!/^\s*```/.test(lines[i])){code.push(lines[i]);i++;}if(i<lines.length)i++;out.push('<pre class="code"><code>'+escapeHtml(code.join('\n'))+'</code></pre>');continue;}if(/^\s*[-*•]\s+/.test(line)){var items=[];while(i<lines.length&&/^\s*[-*•]\s+/.test(lines[i])){items.push('<li>'+escapeHtml(lines[i].replace(/^\s*[-*•]\s+/,''))+'</li>');i++;}out.push('<ul>'+items.join('')+'</ul>');continue;}if(line.trim()===''){out.push('<div style="height:8px"></div>');i++;continue;}out.push('<p>'+escapeHtml(line)+'</p>');i++;}return out.join('');}
  function renderAll(){thread.innerHTML='';if(!history.length){thread.appendChild(empty);empty.style.display='';return;}empty.style.display='none';history.forEach(function(m){var row=document.createElement('div');row.className='msg '+(m.role==='user'?'user':'bot');var bub=document.createElement('div');bub.className='bubble';if(m.role==='user')bub.textContent=m.content;else{if(m.agent){var ag=document.createElement('div');ag.className='agent';ag.textContent=m.agent;bub.appendChild(ag);}var body=document.createElement('div');body.innerHTML=formatBot(m.content);bub.appendChild(body);}row.appendChild(bub);thread.appendChild(row);});thread.scrollTop=thread.scrollHeight;}
  function startThinking(){stopThinking();thinkStart=Date.now();thinkEl=document.createElement('div');thinkEl.className='thinking';thinkEl.textContent='Thinking…';thread.appendChild(thinkEl);thinkTimer=setInterval(function(){var s=Math.floor((Date.now()-thinkStart)/1000);if(thinkEl)thinkEl.textContent='Thinking · '+s+'s';},400);}
  function stopThinking(){if(thinkTimer)clearInterval(thinkTimer);thinkTimer=null;if(thinkEl&&thinkEl.parentNode)thinkEl.parentNode.removeChild(thinkEl);thinkEl=null;}
  function contextPrefix(text){var bits=[];bits.push('You are a helpful assistant. Do not keep repeating the product name. Help with work, coding, assignments, and careful market analysis.');bits.push('RULES: Never promise guaranteed profit. Prefer capital preservation.');bits.push('Tone: clear, mature, no hype.');bits.push('School: explain first, then a complete answer. Full-stack code as files when asked.');if(window.JagXSkills){var sks=window.JagXSkills();if(sks&&sks.length)bits.push('Active skills:\n'+sks.map(function(s){return '- '+s.name+': '+s.body;}).join('\n'));}if(botOn)bits.push('Multi-agent mode.');var on=conns.filter(function(c){return c.on;});if(on.length)bits.push('Connected: '+on.map(function(c){return c.name+' ('+c.type+')';}).join('; ')+'.');if(vault.length)bits.push('Vault labels only: '+vault.map(function(v){return v.label;}).join(', ')+'.');bits.push('Today: '+new Date().toISOString());return bits.join('\n')+'\n\nUser: '+text;}
  async function send(){if(!session){authModal.classList.add('open');return;}var text=(input.value||'').trim();if((!text&&!pendingFile)||sendBtn.disabled)return;if(pendingFile){text=text||('[File: '+pendingFile.name+']');pendingFile=null;}input.value='';history.push({role:'user',content:text});renderAll();saveLocal();sendBtn.disabled=true;startThinking();try{var payload={message:contextPrefix(text),history:history.filter(function(x){return !x.image;}).slice(0,-1).slice(-12)};var r=await fetch(API+'/chat',{method:'POST',headers:{'Content-Type':'application/json','x-api-key':'jagx-984199d487c01240f4515157a11cd6b4'},body:JSON.stringify(payload)});var data=await r.json().catch(function(){return {};});stopThinking();history.push({role:'assistant',agent:botOn?'Bot':'',content:r.ok?(data.response||''):(data.detail||data.message||('Error '+r.status))});renderAll();saveLocal();}catch(e){stopThinking();history.push({role:'assistant',content:'Network issue — try again.'});renderAll();}finally{sendBtn.disabled=false;input.focus();}}
  window.JagXSend=send;sendBtn.onclick=send;input.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();send();}});boot();
})();
