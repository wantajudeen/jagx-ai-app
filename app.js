(function(){
  var API='https://jagx-ai-v2.onrender.com';
  var API_KEY='jagx-984199d487c01240f4515157a11cd6b4';
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
  function openSide(){side.classList.add('open');scrim.classList.add('open');}
  function closeSide(){side.classList.remove('open');scrim.classList.remove('open');}
  var ROUTES=['chat','build','bot','projects','github','settings','conn','vault','skills'];
  function currentRoute(){var h=(location.hash||'#/chat').replace(/^#\/?/,'').split('?')[0];if(h==='ask')h='chat';if(ROUTES.indexOf(h)<0)h='chat';return h;}
  function go(route){if(ROUTES.indexOf(route)<0)route='chat';if(location.hash!=='#/'+route)location.hash='#/'+route;else applyRoute();}
  function applyRoute(){
    var r=currentRoute();
    document.querySelectorAll('.nav a[data-route]').forEach(function(a){var dr=a.getAttribute('data-route');a.classList.toggle('on', dr===r || (r==='build'&&dr==='chat'));});
    if(r==='build'){mode='build';botOn=false;document.getElementById('modeChip').textContent='Build · Fast';input.placeholder=session?'Describe the full app to build…':'Sign in';document.getElementById('topTitle').textContent='Build';}
    else if(r==='chat'){mode='chat';botOn=false;document.getElementById('modeChip').textContent='Chat · Fast';input.placeholder=session?'Ask anything':'Sign in to chat';document.getElementById('topTitle').textContent='Chat';}
    else if(r==='bot'){document.getElementById('topTitle').textContent='Bot';renderBots();}
    else document.getElementById('topTitle').textContent=r.charAt(0).toUpperCase()+r.slice(1);
    document.querySelectorAll('.page').forEach(function(p){p.classList.remove('on');p.style.display='none';});
    if(r==='chat'||r==='build'){var pc=document.getElementById('page-chat');pc.classList.add('on');pc.style.display='flex';}
    else {var map={bot:'page-bot',projects:'page-projects',github:'page-github',settings:'page-settings',conn:'page-conn',vault:'page-vault',skills:'page-skills'};var id=map[r];if(id){var el=document.getElementById(id);if(el){el.classList.add('on');el.style.display='flex';}}}
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
    if(s){main.classList.remove('locked');authModal.classList.remove('open');
      var u=s.user||{},label=(u.user_metadata&&(u.user_metadata.full_name||u.user_metadata.name))||u.email||'Signed in';
      window.__jagxUserId=(u.id||'guest');
      document.getElementById('userChip').textContent=label;document.getElementById('av').textContent=(label[0]||'J').toUpperCase();
      loadLocal();renderHist();renderAll();renderConns();renderVault();renderProjects();renderBots();applyRoute();
    }else{main.classList.add('locked');authModal.classList.add('open');input.placeholder='Sign in to chat';
      document.getElementById('userChip').textContent='Guest';document.getElementById('av').textContent='J';}
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
  document.getElementById('btnAuth').onclick=async function(){closeSide();if(session&&supabase){await supabase.auth.signOut();setSession(null);history=[];renderAll();}else authModal.classList.add('open');};
  var so=document.getElementById('btnSignOut');if(so)so.onclick=async function(){if(session&&supabase){await supabase.auth.signOut();setSession(null);}};
  document.getElementById('btnPlus').onclick=function(){document.getElementById('filePick').click();};
  document.getElementById('filePick').onchange=function(e){var files=e.target.files;if(!files)return;Array.prototype.forEach.call(files,function(f){if(pendingAtts.length>=4)return;var reader=new FileReader();reader.onload=function(){pendingAtts.push({name:f.name,type:f.type||'',data:reader.result});renderAttach();};if((f.type||'').indexOf('image/')===0)reader.readAsDataURL(f);else reader.readAsText(f.slice(0,Math.min(f.size,80000)));});e.target.value='';};
  function renderAttach(){var el=document.getElementById('attachPrev');if(!el)return;if(!pendingAtts.length){el.style.display='none';el.innerHTML='';return;}el.style.display='flex';el.innerHTML='';pendingAtts.forEach(function(a,i){var chip=document.createElement('div');chip.className='att-chip';if((a.type||'').indexOf('image/')===0){var img=document.createElement('img');img.src=a.data;chip.appendChild(img);}var sp=document.createElement('span');sp.textContent=a.name||'file';chip.appendChild(sp);var x=document.createElement('button');x.type='button';x.textContent='\u00d7';x.onclick=function(){pendingAtts.splice(i,1);renderAttach();};chip.appendChild(x);el.appendChild(chip);});}
  document.getElementById('clearHist').onclick=function(){if(!confirm('Clear all chats?'))return;chats=[{id:uid(),title:'New conversation',msgs:[],updated:Date.now()}];chatId=chats[0].id;history=[];saveLocal();renderAll();};
  function renderConns(){var el=document.getElementById('connList');if(!el)return;el.innerHTML='';if(!conns.length){el.innerHTML='<div class="box"><div class="tiny">Nothing connected yet.</div></div>';return;}conns.forEach(function(c){var d=document.createElement('button');d.className='srow';d.type='button';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><span class="tog"></span>';d.querySelector('b').textContent=c.name;d.querySelector('.sub').textContent=c.type+(c.end?' · '+c.end:'');var t=d.querySelector('.tog');t.textContent=c.on?'On':'Off';if(c.on)t.classList.add('on');d.onclick=function(){c.on=!c.on;saveLocal();renderConns();};el.appendChild(d);});}
  document.getElementById('cAdd').onclick=function(){var name=(document.getElementById('cName').value||'').trim(),type=document.getElementById('cType').value,end=(document.getElementById('cEnd').value||'').trim();if(!name)return;conns.push({id:uid(),name:name,type:type,end:end,on:true});document.getElementById('cName').value='';document.getElementById('cEnd').value='';saveLocal();renderConns();};
  function renderVault(){var el=document.getElementById('vaultList');if(!el)return;el.innerHTML='';if(!vault.length){el.innerHTML='<div class="box"><div class="tiny">Empty — save GitHub PAT with label GitHub.</div></div>';return;}vault.forEach(function(v,i){var d=document.createElement('div');d.className='srow';d.innerHTML='<div class="grow"><b></b><div class="sub">••••••••</div></div><button class="tog" type="button">Remove</button>';d.querySelector('b').textContent=v.label;d.querySelector('.tog').onclick=function(){vault.splice(i,1);saveLocal();renderVault();};el.appendChild(d);});}
  document.getElementById('vAdd').onclick=function(){var label=(document.getElementById('vLabel').value||'').trim(),secret=document.getElementById('vSecret').value||'';if(!label||!secret)return;vault.push({id:uid(),label:label,secret:btoa(unescape(encodeURIComponent(secret)))});document.getElementById('vLabel').value='';document.getElementById('vSecret').value='';saveLocal();renderVault();};
  function renderProjects(){var el=document.getElementById('projList');if(!el)return;el.innerHTML='';if(!projects.length){el.innerHTML='<div class="box"><div class="tiny">No projects yet.</div></div>';return;}projects.forEach(function(p){var d=document.createElement('button');d.className='srow';d.type='button';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div>';d.querySelector('b').textContent=p.name;d.querySelector('.sub').textContent=p.goal||'Open';d.onclick=function(){activeProject=p;chatId=p.chatId||uid();if(!p.chatId){p.chatId=chatId;saveLocal();}var cur=chats.find(function(c){return c.id===chatId;});if(!cur){chats.unshift({id:chatId,title:p.name,msgs:[],updated:Date.now(),projectId:p.id});cur=chats[0];}history=cur.msgs||[];go('chat');renderAll();};el.appendChild(d);});}
  function renderBots(){var el=document.getElementById('botRoster');if(!el)return;el.innerHTML='';bots.forEach(function(b){var d=document.createElement('div');d.className='srow';d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">On</button>';d.querySelector('b').textContent=b.name;d.querySelector('.sub').textContent=(b.job||'').slice(0,90);var t=d.querySelector('.tog');t.textContent=b.on!==false?'On':'Off';if(b.on!==false)t.classList.add('on');t.onclick=function(){b.on=!(b.on!==false);saveLocal();renderBots();};el.appendChild(d);});}
  document.getElementById('projCreate').onclick=function(){var name=(document.getElementById('projName').value||'').trim();var goal=(document.getElementById('projGoal').value||'').trim();if(!name)return;var id=uid(),cid=uid();projects.unshift({id:id,name:name,goal:goal,chatId:cid,created:Date.now()});chats.unshift({id:cid,title:name,msgs:[],updated:Date.now(),projectId:id});document.getElementById('projName').value='';document.getElementById('projGoal').value='';saveLocal();renderProjects();};
  document.getElementById('botAdd').onclick=function(){var name=(document.getElementById('botName').value||'').trim();var job=(document.getElementById('botJob').value||'').trim();if(!name)return;bots.push({id:uid(),name:name,job:job||'Custom',on:true});document.getElementById('botName').value='';document.getElementById('botJob').value='';saveLocal();renderBots();};
  document.getElementById('ghPush').onclick=async function(){
    var st=document.getElementById('ghStatus');
    var repo=(document.getElementById('ghRepo').value||'').trim();
    var path=(document.getElementById('ghPath').value||'').trim();
    var msg=(document.getElementById('ghMsg').value||'').trim()||'Update via JagX';
    var body=document.getElementById('ghBody').value||'';
    if(!repo||!path){st.textContent='Need owner/repo and path.';return;}
    var tok=null;
    for(var i=0;i<vault.length;i++){if(String(vault[i].label).toLowerCase()==='github'){try{tok=decodeURIComponent(escape(atob(vault[i].secret)));}catch(e){tok=null;}break;}}
    if(!tok){st.textContent='Save GitHub PAT in Vault (label: GitHub).';return;}
    st.textContent='Pushing…';
    try{
      var parts=repo.split('/');if(parts.length<2){st.textContent='Use owner/repo.';return;}
      var api='https://api.github.com/repos/'+parts[0]+'/'+parts[1]+'/contents/'+path.replace(/^\/+/,'');
      var sha=null;var get=await fetch(api,{headers:{'Authorization':'Bearer '+tok,'Accept':'application/vnd.github+json'}});
      if(get.status===200){var gd=await get.json();sha=gd.sha;}
      var payload={message:msg,content:btoa(unescape(encodeURIComponent(body)))};if(sha)payload.sha=sha;
      var put=await fetch(api,{method:'PUT',headers:{'Authorization':'Bearer '+tok,'Accept':'application/vnd.github+json','Content-Type':'application/json'},body:JSON.stringify(payload)});
      var pd=await put.json().catch(function(){return {};});
      if(put.ok)st.textContent='Pushed OK';else st.textContent='Error: '+(pd.message||put.status);
    }catch(e){st.textContent='Failed: '+String(e.message||e);}
  };
  function newChat(){chatId=uid();chats.unshift({id:chatId,title:'New conversation',msgs:[],updated:Date.now()});history=[];activeProject=null;saveLocal();renderAll();}
  function escapeHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
  function formatBot(text){var raw=String(text||'');raw=raw.replace(/\*\*([^*]+)\*\*/g,'$1');var lines=raw.split('\n'),out=[],i=0;while(i<lines.length){var line=lines[i];if(/^\s*```/.test(line)){var code=[];i++;while(i<lines.length&&!/^\s*```/.test(lines[i])){code.push(lines[i]);i++;}if(i<lines.length)i++;out.push('<pre class="code"><button type="button" class="copy-btn">Copy</button><code>'+escapeHtml(code.join('\n'))+'</code></pre>');continue;}if(line.trim()===''){out.push('<div style="height:8px"></div>');i++;continue;}out.push('<p>'+escapeHtml(line)+'</p>');i++;}return out.join('');}
  function renderAll(){
    thread.innerHTML='';
    if(!history.length){thread.appendChild(empty);empty.style.display='';return;}
    empty.style.display='none';
    history.forEach(function(m,idx){
      var row=document.createElement('div');row.className='msg '+(m.role==='user'?'user':'bot');
      var bub=document.createElement('div');bub.className='bubble';
      if(m.role==='user'){
        if(m.atts){m.atts.forEach(function(a){if(a.data){var im=document.createElement('img');im.src=a.data;im.style.cssText='max-width:200px;border-radius:12px;margin-bottom:8px;display:block';bub.appendChild(im);}});}
        var tx=document.createElement('div');tx.textContent=m.content;bub.appendChild(tx);
        var act=document.createElement('div');act.className='msg-actions';
        var ed=document.createElement('button');ed.type='button';ed.className='edit-btn';ed.textContent='Edit';
        ed.onclick=(function(i){return function(){input.value=history[i].content||'';history=history.slice(0,i);saveLocal();renderAll();input.focus();};})(idx);
        act.appendChild(ed);bub.appendChild(act);
      } else {
        if(m.agent){var ag=document.createElement('div');ag.className='agent';ag.textContent=m.agent;bub.appendChild(ag);}
        var body=document.createElement('div');body.innerHTML=formatBot(m.content);bub.appendChild(body);
        body.querySelectorAll('.copy-btn').forEach(function(btn){btn.onclick=function(){var code=btn.parentNode.querySelector('code');if(code)navigator.clipboard.writeText(code.textContent||'');btn.textContent='Copied';setTimeout(function(){btn.textContent='Copy';},1200);};});
        var act2=document.createElement('div');act2.className='msg-actions';
        ['Helpful','Bad','Copy'].forEach(function(lab){
          var b=document.createElement('button');b.type='button';b.className='fb-btn'+(lab==='Bad'?' bad':'')+(m.fb==='up'&&lab==='Helpful'?' on':'')+(m.fb==='down'&&lab==='Bad'?' on':'');
          b.textContent=lab;
          b.onclick=function(){if(lab==='Copy'){navigator.clipboard.writeText(m.content||'');b.textContent='Copied';setTimeout(function(){b.textContent='Copy';},800);}else{m.fb=lab==='Helpful'?'up':'down';saveLocal();renderAll();}};
          act2.appendChild(b);
        });
        bub.appendChild(act2);
      }
      row.appendChild(bub);thread.appendChild(row);
    });
    thread.scrollTop=thread.scrollHeight;
  }
  function startThinking(){stopThinking();thinkStart=Date.now();thinkEl=document.createElement('div');thinkEl.className='thinking';thinkEl.textContent='Thinking…';thread.appendChild(thinkEl);thinkTimer=setInterval(function(){var s=Math.floor((Date.now()-thinkStart)/1000);if(thinkEl)thinkEl.textContent='Thinking · '+s+'s';},400);}
  function stopThinking(){if(thinkTimer)clearInterval(thinkTimer);thinkTimer=null;if(thinkEl&&thinkEl.parentNode)thinkEl.parentNode.removeChild(thinkEl);thinkEl=null;}
  function sleep(ms){return new Promise(function(r){setTimeout(r,ms);});}
  async function showAgentSteps(){if(!botOn)return;var onB=bots.filter(function(b){return b.on!==false;});if(!onB.length)onB=[{name:'Nimbus'},{name:'Atlas'},{name:'Nova'},{name:'Mira'}];stopThinking();var box=document.createElement('div');box.className='thinking';thread.appendChild(box);for(var i=0;i<onB.length;i++){box.textContent=(onB[i].name||'Bot')+' working…';thread.scrollTop=thread.scrollHeight;await sleep(450);}box.textContent='Team synthesizing…';await sleep(300);if(box.parentNode)box.parentNode.removeChild(box);}
  function contextPrefix(text){var bits=[];bits.push('You are JagX AI. Clear human writing. No ** bold.');bits.push('Never promise guaranteed profit.');if(mode==='build')bits.push('BUILD MODE: Full production-ready code. Complete files in fences.');if(botOn)bits.push('BOT TEAM MODE: thorough.');if(activeProject)bits.push('Project: '+activeProject.name);return bits.join('\n')+'\n\nUser: '+text;}
  function cleanReply(s){return String(s||'').replace(/[\u200B-\u200D\uFEFF]/g,'').replace(/\*\*([^*]+)\*\*/g,'$1').trim();}
  async function send(){
    if(!session){authModal.classList.add('open');return;}
    var text=(input.value||'').trim();
    if((!text&&!pendingAtts.length&&!pendingFile)||sendBtn.disabled)return;
    var attsMeta=[];
    if(pendingAtts.length){
      var notes=[];
      pendingAtts.forEach(function(a){
        if((a.type||'').indexOf('image/')===0){notes.push('[Image: '+a.name+']');attsMeta.push({name:a.name,type:a.type,data:a.data});}
        else {notes.push('[Doc: '+a.name+']\n'+String(a.data||'').slice(0,6000));attsMeta.push({name:a.name,type:a.type});}
      });
      text=(text?text+'\n\n':'')+notes.join('\n\n');
      pendingAtts=[];renderAttach();
    } else if(pendingFile){text=text||('[File: '+pendingFile.name+']');pendingFile=null;}
    input.value='';
    history.push({role:'user',content:text,atts:attsMeta.length?attsMeta:undefined});
    renderAll();saveLocal();sendBtn.disabled=true;startThinking();
    try{
      if(botOn){await showAgentSteps();startThinking();}
      var r=await fetch(API+'/chat',{method:'POST',headers:{'Content-Type':'application/json','x-api-key':API_KEY},body:JSON.stringify({message:contextPrefix(text),history:history.slice(0,-1).slice(-12)})});
      var data=await r.json().catch(function(){return {};});
      stopThinking();
      var reply=r.ok?cleanReply(data.response||''):(data.detail||('Error '+r.status));
      if(!reply)reply='Empty reply.';
      history.push({role:'assistant',agent:botOn?'Bot team':(mode==='build'?'Build':''),content:reply});
      renderAll();saveLocal();
    }catch(e){stopThinking();history.push({role:'assistant',content:'Network issue — try again.');renderAll();}
    finally{sendBtn.disabled=false;input.focus();}
  }
  window.JagXSend=send;window.JagXGo=go;sendBtn.onclick=send;
  input.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();send();}});
  boot();
})();
