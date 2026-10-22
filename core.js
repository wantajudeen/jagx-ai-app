(function(){
  var API='https://jagx-ai-v2.onrender.com';
  var SUPABASE_URL='https://xxxyqzuwvavqsccnlkxa.supabase.co';
  var SUPABASE_ANON_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHlxenV3dmF2cXNjY25sa3hhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NjY4MDcsImV4cCI6MjEwNTE0MjgwN30.pd3D3ULeR90gM7HB8xAlERr8swUyc_aJaIxDqc-vH2Y';
  var supabase=null,session=null,modeSignUp=false,mode='chat',botOn=false,pendingFile=null;var pendingAtts=[];
  var chats=[],chatId=null,history=[],vault=[],conns=[],projects=[],bots=[],activeProject=null;
  var thinkEl=null,thinkTimer=null,thinkStart=0;
  var thread=document.getElementById('thread'),empty=document.getElementById('empty');
  var input=document.getElementById('input'),sendBtn=document.getElementById('send'),main=document.getElementById('main');
  var authModal=document.getElementById('authModal'),authErr=document.getElementById('authErr'),authOk=document.getElementById('authOk');
  var side=document.getElementById('side'),scrim=document.getElementById('scrim');
  function uid(){return 'c_'+Date.now().toString(36)+Math.random().toString(36).slice(2,6);}
  function sk(k){var id=session&&session.user&&session.user.id;return (id||'guest')+'_'+k;}
  function showErr(m){authErr.style.display='block';authErr.textContent=m;authOk.style.display='none';}
  function showOk(m){authOk.style.display='block';authOk.textContent=m;authErr.style.display='none';}
  function openSide(){side.classList.add('open');scrim.classList.add('show');}
  function closeSide(){side.classList.remove('open');scrim.classList.remove('show');}
  var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills','terms','privacy'];
  function currentRoute(){var h=(location.hash||'#/chat').replace(/^#\/?/,'').split('?')[0];if(h==='ask')h='chat';if(ROUTES.indexOf(h)<0)h='chat';return h;}
  function go(route){if(ROUTES.indexOf(route)<0)route='chat';if(location.hash!=='#/'+route)location.hash='#/'+route;else applyRoute();}
  function applyRoute(){
    var r=currentRoute();
    document.querySelectorAll('.nav a[data-route]').forEach(function(a){var dr=a.getAttribute('data-route');a.classList.toggle('on', dr===r || (r==='build'&&dr==='chat'));});
    if(r==='build'){mode='build';botOn=false;document.getElementById('modeChip').textContent='Build · Fast';input.placeholder='Describe the outcome you want to build…';document.getElementById('topTitle').textContent='WORKSPACE / BUILD';}
    else if(r==='chat'){mode='chat';botOn=false;document.getElementById('modeChip').textContent='Chat · Fast';input.placeholder='Tell JagX what you’re working on…';document.getElementById('topTitle').textContent='WORKSPACE / CHAT';}
    else if(r==='bot'){document.getElementById('topTitle').textContent='Bot';renderBots();}
    else document.getElementById('topTitle').textContent=r.charAt(0).toUpperCase()+r.slice(1);
    document.querySelectorAll('.page').forEach(function(p){p.classList.remove('on');p.style.display='none';});
    if(r==='chat'||r==='build'){var pc=document.getElementById('page-chat');pc.classList.add('on');pc.style.display='flex';}
    else {var map={bot:'page-bot',projects:'page-projects',github:'page-github',settings:'page-settings',conn:'page-conn',vault:'page-vault',skills:'page-skills',terms:'page-terms',privacy:'page-privacy'};var id=map[r];if(id){var el=document.getElementById(id);if(el){el.classList.add('on');el.style.display='flex';}}}
    closeSide();
  }
  window.addEventListener('hashchange', applyRoute);
  function loadLocal(){
    try{chats=JSON.parse(localStorage.getItem(sk('chats'))||'[]');}catch(e){chats=[];}
    try{vault=JSON.parse(localStorage.getItem(sk('vault'))||'[]');}catch(e){vault=[];}
    try{conns=JSON.parse(localStorage.getItem(sk('conns'))||'[]');}catch(e){conns=[];}
    try{projects=JSON.parse(localStorage.getItem(sk('projects'))||'[]');}catch(e){projects=[];}
    try{bots=JSON.parse(localStorage.getItem(sk('bots'))||'[]');}catch(e){bots=[];}
    if(!bots.length){bots=[{id:'b_nimbus',name:'Nimbus',job:'Coordinator',on:true},{id:'b_atlas',name:'Atlas',job:'Research',on:true},{id:'b_nova',name:'Nova',job:'Code',on:true},{id:'b_mira',name:'Mira',job:'Writing',on:true}];}
    if(!chats.length){chatId=uid();chats=[{id:chatId,title:'New conversation',msgs:[],updated:Date.now()}];}
    if(!chatId)chatId=chats[0].id;
    var cur=chats.find(function(c){return c.id===chatId;})||chats[0];chatId=cur.id;history=cur.msgs||[];
  }
  function saveLocal(){
    var cur=chats.find(function(c){return c.id===chatId;});
    if(cur){cur.msgs=history;cur.updated=Date.now();if((!cur.title||cur.title==='New conversation')&&history.length){var first=history.find(function(m){return m.role==='user';});if(first)cur.title=String(first.content).slice(0,48);}}
    try{localStorage.setItem(sk('chats'),JSON.stringify(chats));localStorage.setItem(sk('vault'),JSON.stringify(vault));localStorage.setItem(sk('conns'),JSON.stringify(conns));localStorage.setItem(sk('projects'),JSON.stringify(projects));localStorage.setItem(sk('bots'),JSON.stringify(bots));}catch(e){}
    renderHist();
  }
  function renderHist(){
    var el=document.getElementById('histList');if(!el)return;el.innerHTML='';
    chats.slice().sort(function(a,b){return (b.updated||0)-(a.updated||0);}).forEach(function(c){
      var row=document.createElement('div');row.className='hitem';
      var t=document.createElement('button');t.type='button';t.className='t';t.textContent=c.title||'Conversation';
      t.onclick=function(){chatId=c.id;history=c.msgs||[];activeProject=null;go('chat');renderAll();};
      var del=document.createElement('button');del.type='button';del.className='del';del.textContent='X';
      del.onclick=function(e){e.stopPropagation();if(!confirm('Delete this chat?'))return;chats=chats.filter(function(x){return x.id!==c.id;});if(!chats.length){chatId=uid();chats=[{id:chatId,title:'New conversation',msgs:[],updated:Date.now()}];}if(chatId===c.id){chatId=chats[0].id;history=chats[0].msgs||[];}saveLocal();renderAll();};
      row.appendChild(t);row.appendChild(del);el.appendChild(row);
    });
  }
  function setSession(s){
    session=s;
    var topBtn=document.getElementById('btnTopSignIn');
    if(s){
      main.classList.remove('locked');authModal.classList.remove('open');
      var u=s.user||{},label=(u.user_metadata&&(u.user_metadata.full_name||u.user_metadata.name))||u.email||'Signed in';
      window.__jagxUserId=(u.id||'guest');
      document.getElementById('userChip').textContent=label;document.getElementById('av').textContent=(label[0]||'J').toUpperCase();
      if(topBtn)topBtn.style.display='none';
      if(input&&!input.value)input.placeholder=(mode==='build'?'Describe the outcome you want to build…':(botOn?'Give the bot one clear task…':'Tell JagX what you’re working on…'));
      loadLocal();renderHist();renderAll();renderConns();renderVault();renderProjects();renderBots();applyRoute();
    }else{
      main.classList.remove('locked');authModal.classList.remove('open');
      window.__jagxUserId='guest';
      document.getElementById('userChip').textContent='Guest';document.getElementById('av').textContent='J';
      if(topBtn){topBtn.style.display='';topBtn.textContent='Sign in';}
      if(input&&!input.value)input.placeholder='Tell JagX what you’re working on…';
      loadLocal();renderHist();renderAll();
    }
  }
  function loadScript(src){return new Promise(function(res,rej){var s=document.createElement('script');s.src=src;s.onload=res;s.onerror=rej;document.head.appendChild(s);});}
  async function boot(){
    try{await loadScript('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2');}catch(e){try{await loadScript('https://unpkg.com/@supabase/supabase-js@2');}catch(e2){return showErr('Auth library failed');}}
    if(!window.supabase)return showErr('Auth missing');
    try{supabase=window.supabase.createClient(SUPABASE_URL,SUPABASE_ANON_KEY);var r=await supabase.auth.getSession();setSession(r.data&&r.data.session);supabase.auth.onAuthStateChange(function(_e,s){setSession(s);});}catch(e){showErr(String(e.message||e));}
    if(!location.hash)location.hash='#/chat';applyRoute();
  }
  document.getElementById('btnMenu').onclick=openSide;scrim.onclick=closeSide;
  document.getElementById('btnNew').onclick=function(){newChat();go('chat');};
  document.getElementById('botLive').onclick=function(){botOn=true;mode='bot';document.getElementById('modeChip').textContent='Bot · Live';input.placeholder='Give the bot one clear task…';go('chat');};
  document.getElementById('goConn').onclick=function(){go('conn');};
  document.getElementById('goVault').onclick=function(){go('vault');};
  document.getElementById('goSkills').onclick=function(){go('skills');};
  document.getElementById('dDl').onclick=function(){document.getElementById('dlModal').classList.add('open');};
  document.getElementById('dlClose').onclick=function(){document.getElementById('dlModal').classList.remove('open');};
  var ad=document.getElementById('authDl');if(ad)ad.onclick=function(){document.getElementById('dlModal').classList.add('open');};
  document.getElementById('authToggle').onclick=function(){modeSignUp=!modeSignUp;document.getElementById('authTitle').textContent=modeSignUp?'Create account':'Sign in';document.getElementById('authSubmit').textContent=modeSignUp?'Create account':'Sign in with password';document.getElementById('authToggle').textContent=modeSignUp?'Already have an account? Sign in':'New here? Create an account';document.getElementById('nameWrap').style.display=modeSignUp?'block':'none';};
  document.getElementById('authSubmit').onclick=async function(){
    if(!supabase)return showErr('Auth loading…');
    var email=(document.getElementById('authEmail').value||'').trim(),password=document.getElementById('authPass').value||'',name=(document.getElementById('authName').value||'').trim();
    if(!email||!password)return showErr('Email and password required');
    try{if(modeSignUp){if(!name)return showErr('Enter your name');var up=await supabase.auth.signUp({email:email,password:password,options:{data:{full_name:name}}});if(up.error)return showErr(up.error.message);if(!up.data.session)return showOk('Check email to confirm, then sign in.');setSession(up.data.session);}else{var inn=await supabase.auth.signInWithPassword({email:email,password:password});if(inn.error)return showErr(inn.error.message);setSession(inn.data.session);}}catch(e){showErr(String(e.message||e));}
  };
  document.getElementById('btnGoogle').onclick=async function(){if(!supabase)return showErr('Auth loading…');var r=await supabase.auth.signInWithOAuth({provider:'google',options:{redirectTo:location.origin+location.pathname}});if(r.error)showErr(r.error.message);};
  document.getElementById('btnSendOtp').onclick=async function(){if(!supabase)return showErr('Auth loading…');var email=(document.getElementById('authEmail').value||'').trim();if(!email)return showErr('Enter your email first');try{var r=await supabase.auth.signInWithOtp({email:email,options:{shouldCreateUser:true}});if(r.error)return showErr(r.error.message);document.getElementById('otpWrap').style.display='block';showOk('OTP sent (often 8 digits).');}catch(e){showErr(String(e.message||e));}};
  document.getElementById('btnVerifyOtp').onclick=async function(){if(!supabase)return showErr('Auth loading…');var email=(document.getElementById('authEmail').value||'').trim();var token=(document.getElementById('authOtp').value||'').trim();if(!email||!token)return showErr('Email and OTP required');try{var r=await supabase.auth.verifyOtp({email:email,token:token,type:'email'});if(r.error)return showErr(r.error.message);setSession(r.data&&r.data.session);showOk('Signed in.');}catch(e){showErr(String(e.message||e));}};
  document.getElementById('btnAuth').onclick=function(){closeSide();if(session){go('settings');}else authModal.classList.add('open');};
  var so=document.getElementById('btnSignOut');if(so)so.onclick=async function(){if(session&&supabase){await supabase.auth.signOut();setSession(null);}};
  document.getElementById('btnPlus').onclick=function(){document.getElementById('filePick').click();};
  document.getElementById('filePick').onchange=function(e){var files=e.target.files;if(!files)return;Array.prototype.forEach.call(files,function(f){if(pendingAtts.length>=4)return;if(f.size>8*1024*1024){alert('Each attachment must be 8 MB or smaller.');return;}var type=f.type||'',ext=(f.name.split('.').pop()||'').toLowerCase(),isImage=type.indexOf('image/')===0,isText=type.indexOf('text/')===0||['txt','md','csv','json','yaml','yml','xml','html','css','js','ts','dart','py','java','kt','sql','sh','log','toml','ini','env'].indexOf(ext)>=0||type==='application/json';var reader=new FileReader();reader.onload=function(){pendingAtts.push({name:f.name,type:type,data:reader.result||'',size:f.size,unsupported:!isImage&&!isText});renderAttach();};if(isImage)reader.readAsDataURL(f);else if(isText)reader.readAsText(f.slice(0,Math.min(f.size,80000)));else{pendingAtts.push({name:f.name,type:type,data:'',size:f.size,unsupported:true});renderAttach();}});e.target.value='';};
  function renderAttach(){var el=document.getElementById('attachPrev');if(!el)return;if(!pendingAtts.length){el.style.display='none';el.innerHTML='';return;}el.style.display='flex';el.innerHTML='';pendingAtts.forEach(function(a,i){var chip=document.createElement('div');chip.className='att-chip'+(((a.type||'').indexOf('image/')===0)?' att-image':'');if((a.type||'').indexOf('image/')===0){var preview=document.createElement('button');preview.type='button';preview.className='att-image-open';preview.setAttribute('aria-label','View '+(a.name||'attached image'));var img=document.createElement('img');img.src=a.data;img.alt=a.name||'Attached image';img.loading='lazy';preview.appendChild(img);preview.onclick=function(){if(window.JagXOpenImage)window.JagXOpenImage(a.data,a.name||'Image attachment');};chip.appendChild(preview);}else{var glyph=document.createElement('span');glyph.className='att-file-icon';glyph.textContent='▤';chip.appendChild(glyph);}var meta=document.createElement('span');meta.className='att-name';meta.textContent=a.name||'file';meta.title=a.name||'file';chip.appendChild(meta);var x=document.createElement('button');x.type='button';x.className='att-remove';x.setAttribute('aria-label','Remove '+(a.name||'attachment'));x.textContent='×';x.onclick=function(){pendingAtts.splice(i,1);renderAttach();};chip.appendChild(x);el.appendChild(chip);});}
  document.getElementById('clearHist').onclick=function(){if(!confirm('Clear all chats?'))return;chats=[{id:uid(),title:'New conversation',msgs:[],updated:Date.now()}];chatId=chats[0].id;history=[];saveLocal();renderAll();};
  function renderConns(){var el=document.getElementById('connList');if(!el)return;el.innerHTML='';if(!conns.length){el.innerHTML='<div class="box"><div class="tiny">Nothing connected yet.</div></div>';return;}conns.forEach(function(c){var d=document.createElement('button');d.className='srow';d.type='button';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><span class="tog"></span>';d.querySelector('b').textContent=c.name;d.querySelector('.sub').textContent=c.type+(c.end?' · '+c.end:'');var t=d.querySelector('.tog');t.textContent=c.on?'On':'Off';if(c.on)t.classList.add('on');d.onclick=function(){c.on=!c.on;saveLocal();renderConns();};el.appendChild(d);});}
  document.getElementById('cAdd').onclick=function(){var name=(document.getElementById('cName').value||'').trim(),type=document.getElementById('cType').value,end=(document.getElementById('cEnd').value||'').trim();if(!name)return;conns.push({id:uid(),name:name,type:type,end:end,on:true});document.getElementById('cName').value='';document.getElementById('cEnd').value='';saveLocal();renderConns();};
  function renderVault(){var el=document.getElementById('vaultList');if(!el)return;el.innerHTML='';if(!vault.length){el.innerHTML='<div class="box"><div class="tiny">Empty — save GitHub PAT with label GitHub.</div></div>';return;}vault.forEach(function(v,i){var d=document.createElement('div');d.className='srow';d.innerHTML='<div class="grow"><b></b><div class="sub">••••••••</div></div><button class="tog" type="button">Remove</button>';d.querySelector('b').textContent=v.label;d.querySelector('.tog').onclick=function(){vault.splice(i,1);saveLocal();renderVault();};el.appendChild(d);});}
  document.getElementById('vAdd').onclick=function(){var label=(document.getElementById('vLabel').value||'').trim(),secret=document.getElementById('vSecret').value||'';if(!label||!secret)return;vault.push({id:uid(),label:label,secret:btoa(unescape(encodeURIComponent(secret)))});document.getElementById('vLabel').value='';document.getElementById('vSecret').value='';saveLocal();renderVault();};
  function renderProjects(){var el=document.getElementById('projList');if(!el)return;el.innerHTML='';if(!projects.length){el.innerHTML='<div class="box"><div class="tiny">No projects yet.</div></div>';return;}projects.forEach(function(p){var d=document.createElement('button');d.className='srow';d.type='button';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div>';d.querySelector('b').textContent=p.name;d.querySelector('.sub').textContent=p.goal||'Open';d.onclick=function(){activeProject=p;chatId=p.chatId||uid();if(!p.chatId){p.chatId=chatId;saveLocal();}var cur=chats.find(function(c){return c.id===chatId;});if(!cur){chats.unshift({id:chatId,title:p.name,msgs:[],updated:Date.now(),projectId:p.id});cur=chats[0];}history=cur.msgs||[];go('chat');renderAll();};el.appendChild(d);});}
  function renderBots(){var el=document.getElementById('botRoster');if(!el)return;el.innerHTML='';bots.forEach(function(b){var d=document.createElement('div');d.className='srow';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">On</button>';d.querySelector('b').textContent=b.name;d.querySelector('.sub').textContent=(b.job||'').slice(0,90);var t=d.querySelector('.tog');t.textContent=b.on!==false?'On':'Off';if(b.on!==false)t.classList.add('on');t.onclick=function(){b.on=!(b.on!==false);saveLocal();renderBots();};el.appendChild(d);});}
  document.getElementById('projCreate').onclick=function(){var name=(document.getElementById('projName').value||'').trim();var goal=(document.getElementById('projGoal').value||'').trim();if(!name)return;var id=uid(),cid=uid();projects.unshift({id:id,name:name,goal:goal,chatId:cid,created:Date.now()});chats.unshift({id:cid,title:name,msgs:[],updated:Date.now(),projectId:id});document.getElementById('projName').value='';document.getElementById('projGoal').value='';saveLocal();renderProjects();};
  document.getElementById('botAdd').onclick=function(){var name=(document.getElementById('botName').value||'').trim();var job=(document.getElementById('botJob').value||'').trim();if(!name)return;bots.push({id:uid(),name:name,job:job||'Custom',on:true});document.getElementById('botName').value='';document.getElementById('botJob').value='';saveLocal();renderBots();};
  // GitHub repository access: token is deliberately kept in memory only.
  var ghToken=null,ghRepoMeta=null,ghCurrentDir='',ghFileSha=null,ghLoadedPath='',ghOriginalContent=null;
  function ghStatus(message){var el=document.getElementById('ghStatus');if(el)el.textContent=message;}
  function ghApiHeaders(){return {'Authorization':'Bearer '+ghToken,'Accept':'application/vnd.github+json','X-GitHub-Api-Version':'2022-11-28'};}
  function ghParts(){var v=(document.getElementById('ghRepo').value||'').trim().replace(/^https?:\/\/github\.com\//,'').replace(/\.git$/,'').replace(/^\/+|\/+$/g,'').split('/');if(v.length!==2||!v[0]||!v[1])throw new Error('Enter the repository as owner/name.');return v;}
  async function ghRequest(url,options){var res=await fetch(url,options||{headers:ghApiHeaders()});var data=await res.json().catch(function(){return {};});if(!res.ok)throw new Error(data.message||('GitHub returned HTTP '+res.status));return data;}
  async function ghLoadRepository(){if(!ghToken){ghStatus('Paste your token and select Connect repository first.');return;}try{ghStatus('Checking GitHub access…');var p=ghParts();var meta=await ghRequest('https://api.github.com/repos/'+encodeURIComponent(p[0])+'/'+encodeURIComponent(p[1]),{headers:ghApiHeaders()});ghRepoMeta=meta;var branch=document.getElementById('ghBranch');if(!branch.value.trim())branch.value=meta.default_branch||'main';document.getElementById('ghRepoMeta').textContent=(meta.full_name||p.join('/'))+' · '+(meta.private?'Private':'Public')+' · default '+(meta.default_branch||'main');ghCurrentDir='';ghStatus('Connected. Loading repository files…');await ghBrowse();}catch(e){ghStatus('Could not connect: '+e.message);}}
  async function ghBrowse(){if(!ghToken)return ghStatus('Connect GitHub first.');try{var p=ghParts(),branch=(document.getElementById('ghBranch').value||'main').trim(),path=ghCurrentDir;var url='https://api.github.com/repos/'+encodeURIComponent(p[0])+'/'+encodeURIComponent(p[1])+'/contents/'+path.split('/').filter(Boolean).map(encodeURIComponent).join('/')+'?ref='+encodeURIComponent(branch);var data=await ghRequest(url,{headers:ghApiHeaders()});if(!Array.isArray(data))data=[data];var list=document.getElementById('ghFiles');list.innerHTML='';data.sort(function(a,b){return (a.type==='dir'?-1:1)-(b.type==='dir'?-1:1)||a.name.localeCompare(b.name);}).forEach(function(item){var b=document.createElement('button');b.type='button';b.className='gh-file';var ico=document.createElement('span');ico.textContent=item.type==='dir'?'▸':'‹›';var name=document.createElement('span');name.className='gh-name';name.textContent=item.name;var kind=document.createElement('span');kind.className='gh-kind';kind.textContent=item.type==='dir'?'FOLDER':(item.size||0)+' B';b.appendChild(ico);b.appendChild(name);b.appendChild(kind);b.onclick=function(){if(item.type==='dir'){ghCurrentDir=[ghCurrentDir,item.name].filter(Boolean).join('/');ghBrowse();}else ghOpenFile(item.path);};list.appendChild(b);});ghStatus('Live repository view · '+data.length+' item(s) in '+(path||'root')+'.');}catch(e){ghStatus('Could not list files: '+e.message);}}
  async function ghOpenFile(path){try{var p=ghParts(),branch=(document.getElementById('ghBranch').value||'main').trim();ghStatus('Loading '+path+'…');var d=await ghRequest('https://api.github.com/repos/'+encodeURIComponent(p[0])+'/'+encodeURIComponent(p[1])+'/contents/'+path.split('/').map(encodeURIComponent).join('/')+'?ref='+encodeURIComponent(branch),{headers:ghApiHeaders()});if(d.type!=='file'||!d.content)throw new Error('This file is too large or is not a text file. Open it in GitHub for binary/large files.');var raw=atob(d.content.replace(/\s/g,''));var bytes=Uint8Array.from(raw,function(c){return c.charCodeAt(0);});var content=new TextDecoder('utf-8').decode(bytes);document.getElementById('ghPath').value=d.path;document.getElementById('ghBody').value=content;ghFileSha=d.sha;ghLoadedPath=d.path;ghOriginalContent=content;document.getElementById('ghMsg').value='Update '+d.path;ghStatus('Loaded '+d.path+' from branch '+branch+'. Review before committing.');}catch(e){ghStatus('Could not open file: '+e.message);}}
  document.getElementById('ghConnect').onclick=function(){var token=(document.getElementById('ghToken').value||'').trim();if(!token){ghStatus('Paste a fine-grained GitHub token.');return;}ghToken=token;ghStatus('Token accepted for this page session. Checking permissions…');ghLoadRepository();};
  document.getElementById('ghDisconnect').onclick=function(){ghToken=null;ghRepoMeta=null;ghCurrentDir='';ghFileSha=null;ghLoadedPath='';ghOriginalContent=null;document.getElementById('ghToken').value='';document.getElementById('ghFiles').innerHTML='<div class="tiny">Disconnected. Your token was cleared from memory.</div>';document.getElementById('ghRepoMeta').textContent='Not connected';ghStatus('Disconnected. Token cleared from this page session.');};
  document.getElementById('ghLoadRepo').onclick=ghLoadRepository;
  document.getElementById('ghBrowse').onclick=ghBrowse;
  document.getElementById('ghUp').onclick=function(){if(!ghCurrentDir)return;ghCurrentDir=ghCurrentDir.split('/').slice(0,-1).join('/');ghBrowse();};
  document.getElementById('ghReloadFile').onclick=function(){var path=(document.getElementById('ghPath').value||'').trim();if(path&&ghToken)ghOpenFile(path);else{document.getElementById('ghBody').value=ghOriginalContent||'';ghStatus('Restored the last loaded version.');}};
  document.getElementById('ghAsk').onclick=function(){var repo=(document.getElementById('ghRepo').value||'').trim(),path=(document.getElementById('ghPath').value||'').trim(),branch=(document.getElementById('ghBranch').value||'main').trim(),body=document.getElementById('ghBody').value||'';if(!repo||!path){ghStatus('Load a repository file before asking JagX to review it.');return;}if(body.length>18000){ghStatus('This file is too large to send in one review. Select a smaller file or review a focused section.');return;}var fence=String.fromCharCode(96,96,96);input.value='Review and improve this real GitHub file as a senior software engineer. Repository: '+repo+'. Branch: '+branch+'. Path: '+path+'. Explain any important risks briefly, then return the complete revised file in exactly one fenced code block. Do not claim to have committed anything; I will review and commit it separately.\n\nCurrent file content:\n'+fence+'\n'+body+'\n'+fence;go('build');input.focus();ghStatus('File context prepared in Build Studio. Review the prompt and press Send; commits remain a separate confirmed action.');};
  document.getElementById('ghPush').onclick=async function(){try{if(!ghToken)throw new Error('Connect GitHub first.');var p=ghParts(),path=(document.getElementById('ghPath').value||'').trim().replace(/^\/+/,''),branch=(document.getElementById('ghBranch').value||'').trim(),msg=(document.getElementById('ghMsg').value||'').trim(),body=document.getElementById('ghBody').value||'';if(!path)throw new Error('Enter a file path.');if(!branch)throw new Error('Enter a branch name.');if(!msg)throw new Error('Enter a clear commit message.');if(!confirm('Commit '+path+' directly to '+p.join('/')+' on branch '+branch+'? This writes to the live repository.'))return;ghStatus('Checking latest file version…');var url='https://api.github.com/repos/'+encodeURIComponent(p[0])+'/'+encodeURIComponent(p[1])+'/contents/'+path.split('/').map(encodeURIComponent).join('/');var get=await fetch(url+'?ref='+encodeURIComponent(branch),{headers:ghApiHeaders()});var sha=null;if(get.ok){var current=await get.json();sha=current.sha;if(path===ghLoadedPath&&ghFileSha&&current.sha!==ghFileSha)throw new Error('This file changed on GitHub after you loaded it. Reload the latest version and merge your edits before committing.');}else if(get.status!==404){var err=await get.json().catch(function(){return {};});throw new Error(err.message||'Could not check the current file.');}var bytes=new TextEncoder().encode(body);var binary='';for(var i=0;i<bytes.length;i+=0x8000)binary+=String.fromCharCode.apply(null,bytes.subarray(i,i+0x8000));var payload={message:msg,content:btoa(binary),branch:branch};if(sha)payload.sha=sha;ghStatus('Sending commit to GitHub…');var result=await ghRequest(url,{method:'PUT',headers:Object.assign({},ghApiHeaders(),{'Content-Type':'application/json'}),body:JSON.stringify(payload)});ghFileSha=result.content&&result.content.sha;ghOriginalContent=body;ghStatus('Committed successfully: '+(result.commit&&result.commit.sha?result.commit.sha.slice(0,10):'commit created')+'. Refreshing live files…');await ghBrowse();}catch(e){ghStatus('Commit failed: '+e.message);}};
  
  // Accessible attachment lightbox with fit, zoom and download controls.
  (function(){var modal=document.getElementById('jxImageViewer'),image=document.getElementById('jxViewImage'),name=document.getElementById('jxViewName'),download=document.getElementById('jxViewDownload');if(!modal||!image)return;var zoom=1,lastTap=0;function applyZoom(){image.style.setProperty('--jx-zoom',String(zoom));image.classList.toggle('zoomed',zoom>1);image.style.maxWidth='100%';image.style.maxHeight='100%';}function close(){modal.classList.remove('open');image.src='';zoom=1;applyZoom();}function open(src,label){if(!src)return;image.src=src;name.textContent=label||'Image attachment';download.href=src;download.download=(label||'jagx-attachment').replace(/[^a-z0-9._-]+/gi,'-');zoom=1;applyZoom();modal.classList.add('open');}window.JagXOpenImage=open;document.addEventListener('click',function(e){var img=e.target.closest('#attachPrev img,.thread .bubble img,.thread .bubble picture img');if(img&&img.src){e.preventDefault();e.stopPropagation();open(img.currentSrc||img.src,img.alt||img.closest('.att-chip')?.querySelector('span')?.textContent||'Image attachment');}});document.getElementById('jxViewClose').onclick=close;document.getElementById('jxZoomIn').onclick=function(){zoom=Math.min(5,zoom+.25);applyZoom();};document.getElementById('jxZoomOut').onclick=function(){zoom=Math.max(1,zoom-.25);applyZoom();};document.getElementById('jxZoomReset').onclick=function(){zoom=1;applyZoom();};modal.addEventListener('click',function(e){if(e.target===modal)close();});image.addEventListener('dblclick',function(){zoom=zoom>1?1:2;applyZoom();});image.addEventListener('wheel',function(e){e.preventDefault();zoom=Math.max(1,Math.min(5,zoom+(e.deltaY<0?.15:-.15)));applyZoom();},{passive:false});document.addEventListener('keydown',function(e){if(e.key==='Escape'&&modal.classList.contains('open'))close();if(modal.classList.contains('open')&&e.key==='+'){zoom=Math.min(5,zoom+.25);applyZoom();}if(modal.classList.contains('open')&&e.key==='-'){zoom=Math.max(1,zoom-.25);applyZoom();}});var pinchStart=0,pinchZoom=1;image.addEventListener('touchstart',function(e){if(e.touches&&e.touches.length===2){pinchStart=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);pinchZoom=zoom;}},{passive:true});image.addEventListener('touchmove',function(e){if(e.touches&&e.touches.length===2&&pinchStart>0){e.preventDefault();var distance=Math.hypot(e.touches[0].clientX-e.touches[1].clientX,e.touches[0].clientY-e.touches[1].clientY);zoom=Math.max(1,Math.min(5,pinchZoom*distance/pinchStart));applyZoom();}},{passive:false});image.addEventListener('touchend',function(e){if(!e.touches||e.touches.length<2)pinchStart=0;var now=Date.now();if(now-lastTap<300){zoom=zoom>1?1:2;applyZoom();}lastTap=now;});})();
  function newChat(){chatId=uid();chats.unshift({id:chatId,title:'New conversation',msgs:[],updated:Date.now()});history=[];activeProject=null;saveLocal();renderAll();}
  function escapeHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
  function formatBot(text){
    var src=String(text||'').replace(/\r\n/g,'\n');
    src=src.replace(/\\\[/g,'\n').replace(/\\\]/g,'\n');
    src=src.replace(/\\\(/g,'').replace(/\\\)/g,'');
    src=src.replace(/\$\$([\s\S]*?)\$\$/g,function(_,m){return '\n'+m.trim()+'\n';});
    src=src.replace(/\$([^$\n]+)\$/g,'$1');
    src=src.replace(/\\times/g,'×').replace(/\\div/g,'÷').replace(/\\pm/g,'±');
    src=src.replace(/\\cdot/g,'·').replace(/\\leq/g,'≤').replace(/\\geq/g,'≥');
    src=src.replace(/\\neq/g,'≠').replace(/\\approx/g,'≈').replace(/\\infty/g,'∞');
    src=src.replace(/\\sqrt\{([^}]+)\}/g,'√($1)');
    src=src.replace(/\\frac\{([^}]+)\}\{([^}]+)\}/g,'($1)/($2)');
    src=src.replace(/\\left\(|\\right\)|\\left\[|\\right\]/g,'');
    src=src.replace(/\\text\{([^}]*)\}/g,'$1');
    src=src.replace(/\\,/g,' ').replace(/\\;/g,' ').replace(/\\!/g,'');
    src=src.replace(/\\\\/g,'\n');
    src=src.replace(/\n{3,}/g,'\n\n');
    var codes=[];
    src=src.replace(/```([\w+-]*)\n?([\s\S]*?)```/g,function(_,lang,code){
      codes.push('<pre class="code"><button type="button" class="copy-btn">Copy</button><code>'+escapeHtml(String(code).trim())+'</code></pre>');
      return '\n%%CODE'+(codes.length-1)+'%%\n';
    });
    var tables=[];
    src=src.replace(/(?:^|\n)((?:\|[^\n]*\|(?:\n|$))+)/g,function(_,block){
      var lines=block.trim().split('\n').filter(function(l){return /\|/.test(l);});
      if(lines.length<2)return '\n'+block;
      var rows=lines.map(function(l){return l.replace(/^\|/,'').replace(/\|$/,'').split('|').map(function(c){return c.trim();});});
      var start=1;
      if(rows[1]&&rows[1].every(function(c){return /^:?-+:?$/.test(c);}))start=2;
      var html='<div class="md-table-wrap"><table class="md-table"><thead><tr>';
      rows[0].forEach(function(c){html+='<th>'+escapeHtml(c)+'</th>';});
      html+='</tr></thead><tbody>';
      for(var i=start;i<rows.length;i++){html+='<tr>';rows[i].forEach(function(c){html+='<td>'+escapeHtml(c)+'</td>';});html+='</tr>';}
      html+='</tbody></table></div>';
      tables.push(html);
      return '\n%%TABLE'+(tables.length-1)+'%%\n';
    });
    function inlineMd(s){
      s=escapeHtml(s);
      s=s.replace(/!\[([^\]]*)\]\((https?:[^)\s]+)\)/g,'<img src="$2" alt="$1" loading="lazy" decoding="async"/>');
      s=s.replace(/\[([^\]]+)\]\((https?:[^)\s]+)\)/g,'<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');
      s=s.replace(/\*\*([^*]+)\*\*/g,'<b>$1</b>');
      s=s.replace(/__([^_]+)__/g,'<b>$1</b>');
      s=s.replace(/\*([^*]+)\*/g,'<i>$1</i>');
      s=s.replace(/`([^`]+)`/g,'<code class="inline">$1</code>');
      return s;
    }
    var lines=src.split('\n');
    var out=[];
    for(var i=0;i<lines.length;i++){
      var line=lines[i];
      if(/^%%CODE\d+%%$/.test(line.trim())||/^%%TABLE\d+%%$/.test(line.trim())){out.push(line.trim());continue;}
      var h=line.match(/^(#{1,6})\s+(.+)$/);
      if(h){var n=h[1].length;out.push('<h'+n+' class="md-h">'+inlineMd(h[2])+'</h'+n+'>');continue;}
      if(/^---+$/.test(line.trim())){out.push('<hr class="md-hr"/>');continue;}
      if(/^[-*]\s+(.+)$/.test(line)){
        var items=[];
        while(i<lines.length&&/^[-*]\s+(.+)$/.test(lines[i])){items.push('<li>'+inlineMd(lines[i].replace(/^[-*]\s+/,''))+'</li>');i++;}
        i--;out.push('<ul class="md-ul">'+items.join('')+'</ul>');continue;
      }
      if(/^\d+\.\s+/.test(line)){
        var oitems=[];
        while(i<lines.length&&/^\d+\.\s+/.test(lines[i])){oitems.push('<li>'+inlineMd(lines[i].replace(/^\d+\.\s+/,''))+'</li>');i++;}
        i--;out.push('<ol class="md-ul">'+oitems.join('')+'</ol>');continue;
      }
      if(line.trim()===''){out.push('');continue;}
      var t=line.trim();
      if(/^(Solution|Answer|Step\s*\d+|Final answer|Result|Explanation|Given|Find|Proof)[:.]?\s*$/i.test(t)||/^(Solution|Answer|Final answer)\s*:/i.test(t)){
        out.push('<p class="md-p md-title"><b>'+inlineMd(t)+'</b></p>');continue;
      }
      if(/^[0-9a-zA-Z\(\)\s\+\-\*\/=×÷·√≤≥≠≈∞\.]+$/.test(t)&&/[=+\-×÷√]/.test(t)&&t.length<80){
        out.push('<p class="md-math">'+escapeHtml(t)+'</p>');continue;
      }
      out.push('<p class="md-p">'+inlineMd(line)+'</p>');
    }
    var html=out.join('\n');
    html=html.replace(/%%CODE(\d+)%%/g,function(_,n){return codes[+n]||'';});
    html=html.replace(/%%TABLE(\d+)%%/g,function(_,n){return tables[+n]||'';});
    return html;
  }
  function renderAll(){
    if(!history.length){empty.style.display='flex';thread.querySelectorAll('.msg,.thinking').forEach(function(n){n.remove();});return;}
    empty.style.display='none';
    thread.querySelectorAll('.msg').forEach(function(n){n.remove();});
    history.forEach(function(m){
      var div=document.createElement('div');div.className='msg '+(m.role==='user'?'user':'bot');
      var b=document.createElement('div');b.className='bubble';
      if(m.role==='assistant'){
        var act=document.createElement('div');act.className='msg-actions';
        function smallAction(symbol,label,fn,extra){var btn=document.createElement('button');btn.type='button';btn.className='msg-icon '+(extra||'');btn.textContent=symbol;btn.title=label;btn.setAttribute('aria-label',label);btn.onclick=fn;act.appendChild(btn);return btn;}
        smallAction('⧉','Copy response',async function(){var self=this;try{await navigator.clipboard.writeText(m.content||'');}catch(e){var ta=document.createElement('textarea');ta.value=m.content||'';document.body.appendChild(ta);ta.select();document.execCommand('copy');ta.remove();}self.textContent='✓';setTimeout(function(){self.textContent='⧉';},1000);});
        smallAction('＋','Good response',function(){this.classList.toggle('on');},'good');
        smallAction('−','Bad response',function(){this.classList.toggle('on');},'bad');
        div.appendChild(act);
      }
      if(m.role==='user'){
        var act2=document.createElement('div');act2.className='msg-actions user-msg-actions';
        var ed=document.createElement('button');ed.type='button';ed.className='msg-icon edit-btn';ed.textContent='✎';ed.title='Edit message';ed.setAttribute('aria-label','Edit message');
        ed.onclick=function(){input.value=m.content;input.focus();input.style.height='auto';input.style.height=Math.min(input.scrollHeight,160)+'px';input.setSelectionRange(input.value.length,input.value.length);};
        act2.appendChild(ed);div.appendChild(act2);
      }
      thread.appendChild(div);
    });
    thread.scrollTop=thread.scrollHeight;
  }
  function startThinking(){stopThinking();thinkStart=Date.now();thinkEl=document.createElement('div');thinkEl.className='thinking';thinkEl.textContent='Thinking…';thread.appendChild(thinkEl);empty.style.display='none';thinkTimer=setInterval(function(){if(!thinkEl)return;var s=Math.floor((Date.now()-thinkStart)/1000);thinkEl.textContent='Thinking · '+s+'s';},400);}
  function stopThinking(){if(thinkTimer){clearInterval(thinkTimer);thinkTimer=null;}if(thinkEl&&thinkEl.parentNode)thinkEl.parentNode.removeChild(thinkEl);thinkEl=null;}
  function contextPrefix(text,attachments){
    var extra='';
    attachments=attachments||pendingAtts;
    if(mode==='build')extra+='[BUILD MODE] Work like a senior software engineer: inspect the requested outcome, state assumptions, produce complete practical changes, include tests and verification, and never claim a tool or deployment succeeded unless verified.\\n';
    extra+='[FORMAT] Never use LaTeX. Be direct, accurate and structured; distinguish verified facts from assumptions.\\n';
    if(botOn)extra+='[AGENT MODE] Act like a careful senior engineer and project lead. Break complex work into steps, use available tools honestly, explain risks, preserve user data, and ask before irreversible or external actions. Never invent repository access, file contents, tool results, tests or deployments.\\n';
    if(attachments.length){extra+='[ATTACHMENTS]\n';attachments.forEach(function(a){if((a.type||'').indexOf('image/')===0){extra+='Image attached in the interface: '+a.name+' ('+a.type+'). The current public-chat API does not receive image bytes, so do not claim to have visually inspected this image. Explain the limitation and ask for a supported image upload if visual analysis is needed.\n';}else if(a.data){extra+='Text file '+a.name+':\n'+String(a.data).slice(0,4000)+'\n';}else{extra+='Binary attachment '+a.name+' ('+a.type+', '+a.size+' bytes). The current public-chat API does not receive binary file bytes, so do not claim to have read it.\n';}});}
    return extra+text;
  }
  (function mountVoiceButton(){var bar=document.querySelector('.bar');if(!bar||document.getElementById('voice'))return;var btn=document.createElement('button');btn.type='button';btn.id='voice';btn.textContent='🎙';btn.title='Start voice chat';btn.setAttribute('aria-label','Start voice chat');var send=document.getElementById('send');bar.insertBefore(btn,send||null);var st=document.createElement('style');st.textContent='#voice{display:inline-flex;align-items:center;justify-content:center;width:38px;height:38px;border-radius:50%;border:1px solid var(--line);background:var(--card);color:var(--text);font-size:17px;cursor:pointer}#voice.voice-on{border-color:#b5d77a;color:#c9e9a5;background:#222b1d}#voice.listening{animation:jx-listen 1s infinite;border-color:#e9a0a0;color:#f1aaaa}@keyframes jx-listen{50%{box-shadow:0 0 0 5px rgba(235,120,120,.15)}}.msg-actions{display:flex;align-items:center;gap:5px;margin:4px 0 10px 4px;opacity:.72}.msg:hover .msg-actions,.msg-actions:focus-within{opacity:1}.msg-icon{display:inline-flex!important;align-items:center;justify-content:center;width:28px;height:28px;min-width:28px;padding:0!important;margin:0!important;border:1px solid transparent!important;border-radius:7px!important;background:transparent!important;color:#aab2a8!important;font-size:15px!important;line-height:1;box-shadow:none!important;cursor:pointer}.msg-icon:hover{background:#242a24!important;border-color:#353d35!important;color:#eef4eb!important}.msg-icon.good.on{color:#b7dc87!important;background:#26321f!important}.msg-icon.bad.on{color:#f1a6a6!important;background:#382525!important}.user-msg-actions{justify-content:flex-end;margin-top:2px;margin-bottom:6px}';document.head.appendChild(st);})();
  var voiceMode=false,recognition=null;
  function speakReply(text){if(!voiceMode||!('speechSynthesis' in window))return;try{window.speechSynthesis.cancel();var u=new SpeechSynthesisUtterance(String(text||'').slice(0,7000));u.rate=1;u.pitch=1;window.speechSynthesis.speak(u);}catch(e){}}
  function startVoice(){var SR=window.SpeechRecognition||window.webkitSpeechRecognition;if(!SR){alert('Voice input is not supported in this browser. Try Chrome and allow microphone access.');return;}try{if(recognition){recognition.stop();recognition=null;}recognition=new SR();recognition.lang='en-NG';recognition.interimResults=true;recognition.continuous=false;var v=document.getElementById('voice');v.classList.add('listening');v.title='Listening… tap to stop';recognition.onresult=function(e){var finalText='';for(var i=e.resultIndex;i<e.results.length;i++)finalText+=e.results[i][0].transcript;if(finalText){input.value=finalText;input.style.height='auto';input.style.height=Math.min(input.scrollHeight,160)+'px';}};recognition.onerror=function(){v.classList.remove('listening');v.title='Start voice input';};recognition.onend=function(){v.classList.remove('listening');v.title='Start voice input';recognition=null;};recognition.start();}catch(e){var v=document.getElementById('voice');if(v)v.classList.remove('listening');}}
  var voiceBtn=document.getElementById('voice');if(voiceBtn)voiceBtn.onclick=function(){if(recognition){recognition.stop();return;}voiceMode=!voiceMode;voiceBtn.classList.toggle('voice-on',voiceMode);voiceBtn.title=voiceMode?'Voice chat on · tap mic to speak':'Start voice input';startVoice();};
  var voiceMode=false,recognition=null;
  function speakReply(text){if(!voiceMode||!('speechSynthesis' in window))return;try{window.speechSynthesis.cancel();var utterance=new SpeechSynthesisUtterance(String(text||'').slice(0,7000));utterance.rate=1;window.speechSynthesis.speak(utterance);}catch(e){}}
  function startVoice(){var Speech=window.SpeechRecognition||window.webkitSpeechRecognition;if(!Speech){alert('Voice input is not supported here. Try Chrome and allow microphone access.');return;}try{recognition=new Speech();recognition.lang='en-NG';recognition.interimResults=true;recognition.continuous=false;var button=document.getElementById('voice');button.classList.add('listening');recognition.onresult=function(e){var transcript='';for(var i=e.resultIndex;i<e.results.length;i++)transcript+=e.results[i][0].transcript;if(transcript){input.value=transcript;input.style.height='auto';input.style.height=Math.min(input.scrollHeight,160)+'px';}};recognition.onerror=function(){button.classList.remove('listening');};recognition.onend=function(){button.classList.remove('listening');recognition=null;};recognition.start();}catch(e){recognition=null;}}
  var voiceButton=document.getElementById('voice');if(voiceButton)voiceButton.onclick=function(){voiceMode=!voiceMode;voiceButton.classList.toggle('voice-on',voiceMode);voiceButton.title=voiceMode?'Voice replies on · tap to dictate':'Start voice chat';if(recognition){recognition.stop();recognition=null;}else startVoice();};
  async function send(){
    var text=(input.value||'').trim();
    if((!text&&!pendingAtts.length&&!pendingFile)||sendBtn.disabled)return;
    var attachments=pendingAtts.slice();
    var prompt=contextPrefix(text||'Please help with the attached files.',attachments);
    var names=attachments.map(function(a){return a.name||'attachment';});
    input.value='';
    var show=text||(names.length?'Attached: '+names.join(', '):'(attachment)');
    if(names.length&&text)show+='\\n\\nAttached: '+names.join(', ');
    history.push({role:'user',content:show});
    pendingAtts=[];renderAttach();
    renderAll();saveLocal();sendBtn.disabled=true;startThinking();
    try{
      var r=await fetch(API+'/public-chat',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message:prompt,history:history.slice(0,-1).slice(-12)})});
      var data=await r.json().catch(function(){return {};});
      stopThinking();
      if(!r.ok){var why=data.detail||('HTTP '+r.status);if(r.status===404)why='JagX backend route not found (404). The deployed Render service may be outdated or using a different URL. Please retry after the backend redeploy.';else if(r.status===502||r.status===503)why='JagX AI provider is temporarily unavailable ('+r.status+'). Check the backend provider keys, model name and quota. Details: '+why;history.push({role:'assistant',content:why});}
      else{
        var ans=data.response||data.message||'';
        if(data.attachment&&data.attachment.url)ans+='\\n\\n![image]('+data.attachment.url+')';
        history.push({role:'assistant',content:ans});
        speakReply(ans);
        speakReply(ans);
      }
      renderAll();saveLocal();
    }catch(e){stopThinking();history.push({role:'assistant',content:'Network issue — try again.'});renderAll();}
    finally{sendBtn.disabled=false;input.focus();}
  }
  window.JagXSend=send;window.JagXGo=go;sendBtn.onclick=send;
  input.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();send();}});
  var ac=document.getElementById('authClose');if(ac)ac.onclick=function(){authModal.classList.remove('open');};
  var topSi=document.getElementById('btnTopSignIn');
  if(topSi)topSi.onclick=function(){authModal.classList.add('open');};
  function mountJagxBotWorkspace(){
    var page=document.getElementById('page-bot');
    if(!page||page.dataset.jxWorkspace)return;
    page.dataset.jxWorkspace='1';page.dataset.jx='1';
    var old=document.getElementById('jxBotBox');if(old)old.remove();
    var box=document.createElement('div');box.id='jxBotBox';box.className='box';
    box.innerHTML='<div class="jxbot-head"><div><b>JagX Assistant</b><div class="tiny">Chat · Research · Coding · Multi-step tasks</div></div><span class="tiny">● Ready</span></div><div class="jxbot-modes"><button type="button" data-mode="chat" class="active">Chat</button><button type="button" data-mode="research">Research</button><button type="button" data-mode="code">Coding</button><button type="button" data-mode="plan">Plan task</button></div><div id="jxBotThread" class="jxbot-thread"><div class="tiny">What are we working on? Ask questions, debug code, research a topic, or plan a bigger task.</div></div><textarea id="jxGoal" rows="2" placeholder="Message JagX…"></textarea><div class="jxbot-actions"><button type="button" id="jxBotVoice" title="Dictate">🎙</button><span id="jxBotProgress" class="tiny">Ready</span><button type="button" id="jxRun">↑</button></div><div class="jxbot-quick"><button type="button" data-goal="Help me debug this code and explain the fix.">Debug code</button><button type="button" data-goal="Research this topic and summarise reliable sources.">Research</button><button type="button" data-goal="Break my goal into steps and start with the first useful action.">Plan a task</button></div>';
    page.insertBefore(box,page.firstChild.nextSibling);
    var css=document.createElement('style');css.textContent='#jxBotBox{padding:16px;border-radius:18px}.jxbot-head,.jxbot-actions{display:flex;align-items:center;justify-content:space-between;gap:8px}.jxbot-modes,.jxbot-quick{display:flex;gap:6px;overflow:auto;padding:12px 0}.jxbot-modes button,.jxbot-quick button{white-space:nowrap;border:1px solid #343b34;border-radius:18px;padding:7px 10px;background:transparent;color:#cbd2c7;font-size:12px}.jxbot-modes button.active{background:#d1e9ae;color:#17200f}.jxbot-thread{min-height:190px;max-height:48vh;overflow:auto;padding:12px 0;border-top:1px solid #303631;border-bottom:1px solid #303631;margin:6px 0}.jxbot-msg{white-space:pre-wrap;overflow-wrap:anywhere;line-height:1.55;font-size:14px;padding:10px 12px;border-radius:12px;margin:8px 0}.jxbot-msg.user{background:#293228;margin-left:18%;color:#f0f4ed}.jxbot-msg.assistant{background:#1a1f1b;color:#e4e9e1}.jxbot-actions #jxRun{width:36px;height:36px;border:0;border-radius:50%;background:#d1e9ae;color:#17200f;font-size:20px}.jxbot-actions #jxBotVoice{border:1px solid #343b34;border-radius:50%;width:34px;height:34px;background:#252b25;color:#eee}#jxGoal{width:100%;margin-top:10px;background:transparent;color:var(--text);border:1px solid #343b34;border-radius:12px;padding:12px}';document.head.appendChild(css);
    var thread=document.getElementById('jxBotThread'),goal=document.getElementById('jxGoal'),run=document.getElementById('jxRun'),status=document.getElementById('jxBotProgress'),mode='chat',history=[];
    function add(role,text){var d=document.createElement('div');d.className='jxbot-msg '+role;d.textContent=text;thread.appendChild(d);thread.scrollTop=thread.scrollHeight;history.push({role:role,content:text});}
    page.querySelectorAll('[data-mode]').forEach(function(btn){btn.onclick=function(){mode=btn.getAttribute('data-mode');page.querySelectorAll('[data-mode]').forEach(function(x){x.classList.toggle('active',x===btn)});goal.placeholder=mode==='code'?'Paste code or describe the bug…':'Message JagX…';};});
    page.querySelectorAll('[data-goal]').forEach(function(btn){btn.onclick=function(){goal.value=btn.getAttribute('data-goal');goal.focus();};});
    async function submit(){var value=(goal.value||'').trim();if(!value||run.disabled)return;goal.value='';var prompt=mode==='chat'?value:'['+mode.toUpperCase()+' MODE] '+value;add('user',value);run.disabled=true;status.textContent='Working…';try{var res=await fetch(API+'/public-chat',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message:prompt,history:history.slice(0,-1).slice(-12)})});var data=await res.json().catch(function(){return {}});if(!res.ok)throw new Error(data.detail||('HTTP '+res.status));var answer=data.response||data.reply||data.text||'The backend returned an empty response.';add('assistant',answer);status.textContent='Complete';}catch(e){add('assistant','Request failed: '+e.message+'. Check the live backend deployment and provider settings.');status.textContent='Failed';}finally{run.disabled=false;}}
    run.onclick=submit;goal.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();submit();}});
    document.getElementById('jxBotVoice').onclick=function(){var Speech=window.SpeechRecognition||window.webkitSpeechRecognition;if(!Speech){status.textContent='Voice input needs a supported browser and microphone permission.';return;}var rec=new Speech();rec.lang='en-NG';rec.onresult=function(e){goal.value=e.results[0][0].transcript;};rec.onerror=function(){status.textContent='Microphone or speech recognition failed.';};rec.start();status.textContent='Listening…';};
  }
  window.addEventListener('hashchange',mountJagxBotWorkspace);
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',mountJagxBotWorkspace);else mountJagxBotWorkspace();
  boot();
})();
