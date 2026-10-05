(function(){
  var API='https://jagx-ai-v2.onrender.com';

  /* ---- Skills ---- */
  var skills=[];
  function sk(){ try{ return (window.__jagxUserId||'guest')+'_skills'; }catch(e){ return 'guest_skills'; } }
  function loadSk(){ try{ skills=JSON.parse(localStorage.getItem(sk())||'[]'); }catch(e){ skills=[]; } }
  function saveSk(){ try{ localStorage.setItem(sk(), JSON.stringify(skills)); }catch(e){} }
  window.JagXSkills=function(){ loadSk(); return skills; };
  function renderSkills(){
    var el=document.getElementById('skillList'); if(!el) return;
    loadSk(); el.innerHTML='';
    if(!skills.length){ el.innerHTML='<div class="box"><div class="tiny">No skills yet. Add one below.</div></div>'; return; }
    skills.forEach(function(s,i){
      var d=document.createElement('div'); d.className='srow';
      d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">Remove</button>';
      d.querySelector('b').textContent=s.name;
      d.querySelector('.sub').textContent=(s.body||'').slice(0,80);
      d.querySelector('.tog').onclick=function(){ skills.splice(i,1); saveSk(); renderSkills(); };
      el.appendChild(d);
    });
  }

  /* ---- MCP catalog ---- */
  var MCPS=[
    {id:'web-search',name:'Web Search',cat:'Core',url:'builtin://search',desc:'Live web search on the JagX server. No key needed.',auth:null},
    {id:'news',name:'News',cat:'Core',url:'builtin://news',desc:'Current headlines. No key needed.',auth:null},
    {id:'weather',name:'Weather',cat:'Core',url:'builtin://weather',desc:'Weather by city. No key needed.',auth:null},
    {id:'maps',name:'Maps / Geo',cat:'Core',url:'builtin://geo',desc:'Places and coordinates. No key needed.',auth:null},
    {id:'calc',name:'Calculator',cat:'Core',url:'builtin://calc',desc:'Math, units, formulas. No key needed.',auth:null},
    {id:'sandbox',name:'Code Sandbox',cat:'Programming',url:'builtin://sandbox',desc:'Run Python to test code. No key needed.',auth:null},
    {id:'github',name:'GitHub',cat:'Programming',url:'https://github.com/settings/tokens',desc:'Read/write your repos. Needs a Personal Access Token.',auth:'token',how:'1) Open github.com/settings/tokens\n2) Generate new token (classic) with scope: repo\n3) Copy the token (starts with ghp_)\n4) Paste it below and Save'},
    {id:'filesystem',name:'Files',cat:'Programming',url:'builtin://files',desc:'Workspace files on server. No key needed.',auth:null},
    {id:'memory',name:'Memory',cat:'Core',url:'builtin://memory',desc:'Remember facts about you across chats. No key needed.',auth:null},
    {id:'jobs',name:'Bot Jobs',cat:'Core',url:'builtin://jobs',desc:'Long goals keep running after you close the app. No key needed.',auth:null},
    {id:'vault',name:'Vault',cat:'Core',url:'builtin://vault',desc:'Store secrets for tools. No key needed to enable.',auth:null},
    {id:'browser',name:'Browser fetch',cat:'Core',url:'builtin://browser',desc:'Fetch a public webpage for the bot. No key needed.',auth:null},
    {id:'translate',name:'Translate',cat:'Core',url:'builtin://translate',desc:'Any language in, any language out. No key needed.',auth:null},
    {id:'pdf',name:'PDF tools',cat:'Programming',url:'builtin://pdf',desc:'Read and summarize PDFs you upload. No key needed.',auth:null},
    {id:'image-read',name:'Image / screenshot read',cat:'Core',url:'builtin://vision',desc:'Describe screenshots and pictures. No key needed.',auth:null},
    {id:'wikipedia',name:'Wikipedia',cat:'Research',url:'https://wikipedia.org',desc:'Encyclopedia lookup. No key needed.',auth:null},
    {id:'arxiv',name:'arXiv',cat:'Research',url:'https://arxiv.org',desc:'Science papers. No key needed.',auth:null},
    {id:'stackoverflow',name:'Stack Overflow',cat:'Programming',url:'https://stackoverflow.com',desc:'Dev Q&A search. No key needed.',auth:null},
    {id:'supabase',name:'Supabase',cat:'Cloud',url:'https://supabase.com/dashboard/account/tokens',desc:'Your Supabase project. Needs access token.',auth:'token',how:'1) Open supabase.com dashboard\n2) Account → Access Tokens\n3) Generate token\n4) Paste below'},
    {id:'openrouter',name:'OpenRouter',cat:'Core',url:'https://openrouter.ai/keys',desc:'Extra AI models. Needs API key.',auth:'token',how:'1) Sign in at openrouter.ai\n2) Keys → Create key\n3) Paste below'},
    {id:'hf',name:'Hugging Face',cat:'Core',url:'https://huggingface.co/settings/tokens',desc:'Models and datasets. Needs token.',auth:'token',how:'1) huggingface.co/settings/tokens\n2) New token\n3) Paste below'},
    {id:'vercel',name:'Vercel',cat:'Cloud',url:'https://vercel.com/account/tokens',desc:'Deploy sites. Needs token.',auth:'token',how:'1) vercel.com/account/tokens\n2) Create\n3) Paste below'},
    {id:'stripe',name:'Stripe',cat:'Payments',url:'https://dashboard.stripe.com/apikeys',desc:'Payments (test mode OK). Needs secret key.',auth:'token',how:'1) dashboard.stripe.com/apikeys\n2) Reveal secret key\n3) Paste below'},
    {id:'notion',name:'Notion',cat:'Creative',url:'https://www.notion.so/my-integrations',desc:'Read/write Notion pages. Needs integration token.',auth:'token',how:'1) notion.so/my-integrations\n2) New integration → copy Internal Integration Token\n3) Share your pages with the integration\n4) Paste token below'},
    {id:'x',name:'X (Twitter)',cat:'Social',url:'https://developer.x.com',desc:'Posts and search. Needs Bearer token.',auth:'token',how:'1) developer.x.com → your app\n2) Keys and tokens → Bearer Token\n3) Paste below'},
    {id:'gmail',name:'Gmail',cat:'Communication',url:'https://myaccount.google.com',desc:'Email (OAuth later). For now store an app password if you use one.',auth:'token',how:'Optional: Google App Password. Full OAuth coming soon.'},
    {id:'drive',name:'Google Drive',cat:'Cloud',url:'https://drive.google.com',desc:'Files. Token optional until OAuth is live.',auth:'token',how:'Full Google OAuth coming soon. You can still enable the connector.'},
    {id:'slack',name:'Slack',cat:'Communication',url:'https://api.slack.com/apps',desc:'Team chat. Needs Bot token.',auth:'token',how:'1) api.slack.com/apps → your app\n2) OAuth → Bot User OAuth Token\n3) Paste below'},
    {id:'discord',name:'Discord',cat:'Communication',url:'https://discord.com/developers/applications',desc:'Bot token for a server.',auth:'token',how:'1) discord.com/developers → Bot → Reset Token\n2) Paste below'},
    {id:'brave',name:'Brave Search',cat:'Research',url:'https://brave.com/search/api',desc:'Privacy search. Optional API key.',auth:'token',how:'Optional key from brave.com/search/api'},
    {id:'npm',name:'npm',cat:'Programming',url:'https://www.npmjs.com',desc:'JS packages lookup. No key needed.',auth:null},
    {id:'pypi',name:'PyPI',cat:'Programming',url:'https://pypi.org',desc:'Python packages. No key needed.',auth:null},
    {id:'youtube',name:'YouTube',cat:'Social',url:'https://youtube.com',desc:'Video search info. No key needed for basic.',auth:null},
    {id:'reddit',name:'Reddit',cat:'Social',url:'https://reddit.com',desc:'Public posts. No key needed for basic.',auth:null},
    {id:'wolfram',name:'Wolfram Alpha',cat:'Research',url:'https://products.wolframalpha.com/api',desc:'Computation. Needs App ID.',auth:'token',how:'1) products.wolframalpha.com/api\n2) Get App ID\n3) Paste below'}
  ];

  var connected=[];
  var secrets={};
  function ck(){ return (window.__jagxUserId||'guest')+'_mcp'; }
  function skk(){ return (window.__jagxUserId||'guest')+'_mcp_secrets'; }
  function loadConn(){
    try{ connected=JSON.parse(localStorage.getItem(ck())||'[]'); }catch(e){ connected=[]; }
    try{ secrets=JSON.parse(localStorage.getItem(skk())||'{}'); }catch(e){ secrets={}; }
  }
  function saveConn(){
    try{ localStorage.setItem(ck(), JSON.stringify(connected)); }catch(e){}
    try{ localStorage.setItem(skk(), JSON.stringify(secrets)); }catch(e){}
  }
  function isOn(id){ return connected.indexOf(id)>=0; }
  function uid(){
    var id=localStorage.getItem('jx_web_uid');
    if(!id){ id='web_'+Math.random().toString(36).slice(2,10); localStorage.setItem('jx_web_uid', id); }
    return id;
  }

  function ensureModal(){
    if(document.getElementById('jxConnModal')) return;
    var m=document.createElement('div');
    m.id='jxConnModal';
    m.style.cssText='display:none;position:fixed;inset:0;background:rgba(0,0,0,.82);z-index:60;align-items:center;justify-content:center;padding:16px';
    m.innerHTML=
      '<div style="width:100%;max-width:420px;background:#111;border:1px solid #27272a;border-radius:16px;padding:20px 18px;max-height:88vh;overflow:auto">'+
      '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">'+
      '<b id="jxConnTitle" style="font-size:16px">Connect</b>'+
      '<button type="button" id="jxConnClose" style="font-size:20px;color:#a1a1aa;background:none;border:none;cursor:pointer">×</button></div>'+
      '<p id="jxConnDesc" style="color:#a1a1aa;font-size:13px;margin-bottom:10px;line-height:1.5"></p>'+
      '<pre id="jxConnHow" style="white-space:pre-wrap;background:#0c0c0e;border:1px solid #27272a;border-radius:10px;padding:12px;font-size:12px;color:#d4d4d8;margin-bottom:12px;font-family:Inter,system-ui,sans-serif"></pre>'+
      '<label style="font-size:12px;color:#71717a">Token / API key (kept on this device + vault)</label>'+
      '<input id="jxConnToken" type="password" placeholder="Paste here…" style="width:100%;margin-top:4px;padding:11px 12px;border-radius:10px;border:1px solid #27272a;background:#0c0c0e;color:#fafafa"/>'+
      '<label style="font-size:12px;color:#71717a;display:block;margin-top:10px">Optional note (e.g. owner/repo)</label>'+
      '<input id="jxConnNote" type="text" placeholder="you/repo or project id" style="width:100%;margin-top:4px;padding:11px 12px;border-radius:10px;border:1px solid #27272a;background:#0c0c0e;color:#fafafa"/>'+
      '<div id="jxConnErr" style="color:#f87171;font-size:13px;margin-top:8px;display:none"></div>'+
      '<button type="button" id="jxConnSave" class="full solid" style="width:100%;margin-top:14px;height:42px;border-radius:11px;font-weight:600;background:#fafafa;color:#0a0a0a;border:none;cursor:pointer">Save & connect</button>'+
      '<button type="button" id="jxConnSkip" style="width:100%;margin-top:8px;height:40px;border-radius:11px;border:1px solid #27272a;background:none;color:#a1a1aa;cursor:pointer">Connect without key (limited)</button>'+
      '<p style="font-size:11px;color:#71717a;margin-top:12px;line-height:1.4">Your token is stored in browser local storage and sent to JagX vault so the bot can use it. Never share tokens in chat.</p>'+
      '</div>';
    document.body.appendChild(m);
    document.getElementById('jxConnClose').onclick=function(){ m.style.display='none'; };
    m.onclick=function(e){ if(e.target===m) m.style.display='none'; };
  }

  var pendingMcp=null;
  function openConnectForm(m){
    ensureModal();
    pendingMcp=m;
    document.getElementById('jxConnTitle').textContent='Connect '+m.name;
    document.getElementById('jxConnDesc').textContent=m.desc||'';
    document.getElementById('jxConnHow').textContent=m.how||'Paste your token below, then Save.';
    document.getElementById('jxConnToken').value=secrets[m.id]||'';
    document.getElementById('jxConnNote').value=localStorage.getItem('jx_note_'+m.id)||'';
    document.getElementById('jxConnErr').style.display='none';
    document.getElementById('jxConnModal').style.display='flex';
    if(m.url && m.url.indexOf('http')===0){
      try{ /* don't auto-open every time — user can follow how steps */ }catch(e){}
    }
  }

  function finishConnect(m, token, note){
    if(connected.indexOf(m.id)<0) connected.push(m.id);
    if(token) secrets[m.id]=token;
    if(note) localStorage.setItem('jx_note_'+m.id, note);
    saveConn();
    if(token){
      fetch(API+'/vault',{
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({user_id:uid(), key:m.id, value:token})
      }).catch(function(){});
      if(m.id==='github'){
        localStorage.setItem('jx_gh_token', token);
        if(note) localStorage.setItem('jx_gh_repo', note);
      }
    }
    document.getElementById('jxConnModal').style.display='none';
    renderMcps();
  }

  function bindModalButtons(){
    ensureModal();
    document.getElementById('jxConnSave').onclick=function(){
      var m=pendingMcp; if(!m) return;
      var token=(document.getElementById('jxConnToken').value||'').trim();
      var note=(document.getElementById('jxConnNote').value||'').trim();
      var err=document.getElementById('jxConnErr');
      if(m.auth==='token' && !token){
        err.textContent='Paste a token first, or use Connect without key.';
        err.style.display='block';
        return;
      }
      finishConnect(m, token, note);
    };
    document.getElementById('jxConnSkip').onclick=function(){
      var m=pendingMcp; if(!m) return;
      finishConnect(m, '', (document.getElementById('jxConnNote').value||'').trim());
    };
  }

  function renderMcps(){
    var el=document.getElementById('mcpCatalog');
    var mine=document.getElementById('connList');
    if(!el) return;
    loadConn();
    ensureModal();
    bindModalButtons();

    /* Help banner */
    var help=document.getElementById('jxConnHelp');
    if(!help){
      help=document.createElement('div');
      help.id='jxConnHelp';
      help.className='box';
      help.style.marginBottom='12px';
      help.innerHTML=
        '<b style="color:#D4AF37">How connectors work (simple)</b>'+
        '<ol style="margin:10px 0 0 18px;color:#a1a1aa;font-size:13px;line-height:1.55">'+
        '<li><b style="color:#fafafa">No key needed</b> (Search, News, Weather, Sandbox…) → tap <b>Connect</b> once. Bot can use it immediately.</li>'+
        '<li><b style="color:#fafafa">Needs token</b> (GitHub, Supabase, OpenRouter…) → tap <b>Connect</b> → a form opens → follow the steps → paste token → <b>Save & connect</b>.</li>'+
        '<li>Connected tools show under <b>Active</b> at the top. Tell the bot in chat, e.g. “use GitHub to list my repos”.</li>'+
        '<li>Tokens stay on this phone/browser and in JagX vault. Do not paste them in the chat box.</li>'+
        '</ol>';
      var page=document.getElementById('page-conn');
      if(page){
        var lead=page.querySelector('.lead');
        if(lead && lead.nextSibling) page.insertBefore(help, lead.nextSibling);
        else page.insertBefore(help, page.firstChild);
      }
    }

    var q=((document.getElementById('mcpSearch')||{}).value||'').toLowerCase().trim();
    var cat=((document.getElementById('mcpCat')||{}).value||'');
    el.innerHTML='';
    var groups={};
    MCPS.forEach(function(m){
      if(q && (m.name+' '+m.desc+' '+m.cat).toLowerCase().indexOf(q)<0) return;
      if(cat && m.cat!==cat) return;
      if(!groups[m.cat]) groups[m.cat]=[];
      groups[m.cat].push(m);
    });
    Object.keys(groups).sort().forEach(function(c){
      var h=document.createElement('div');
      h.className='lbl'; h.textContent=c; el.appendChild(h);
      groups[c].forEach(function(m){
        var on=isOn(m.id);
        var d=document.createElement('div'); d.className='srow';
        var need=m.auth?' · needs token':' · free';
        d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button"></button>';
        d.querySelector('b').textContent=m.name;
        d.querySelector('.sub').textContent=(m.desc||'')+need;
        var btn=d.querySelector('.tog');
        if(on){
          btn.textContent='Connected';
          btn.classList.add('on');
        } else {
          btn.textContent='Connect';
        }
        btn.onclick=function(){
          if(isOn(m.id)){
            connected=connected.filter(function(x){ return x!==m.id; });
            saveConn(); renderMcps();
            return;
          }
          if(m.auth){
            openConnectForm(m);
          } else {
            connected.push(m.id);
            saveConn();
            renderMcps();
          }
        };
        el.appendChild(d);
      });
    });
    if(mine){
      mine.innerHTML='';
      if(!connected.length){
        mine.innerHTML='<div class="box"><div class="tiny">Nothing connected yet. Use the list below — free tools need one tap; token tools open a form.</div></div>';
      } else {
        connected.forEach(function(id){
          var m=MCPS.find(function(x){ return x.id===id; })||{name:id,desc:''};
          var has=!!secrets[id];
          var d=document.createElement('div'); d.className='srow';
          d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button">Disconnect</button>';
          d.querySelector('b').textContent=m.name;
          d.querySelector('.sub').textContent=has?'Active · token saved':'Active'+(m.auth?' · no token yet':'');
          d.querySelector('.tog').onclick=function(){
            connected=connected.filter(function(x){ return x!==id; });
            saveConn(); renderMcps();
          };
          mine.appendChild(d);
        });
      }
    }
  }

  function showLegal(){
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h!=='terms' && h!=='privacy') return;
    document.querySelectorAll('.page').forEach(function(p){ p.classList.remove('on'); p.style.display='none'; });
    var page=document.getElementById('page-'+h);
    if(page){ page.classList.add('on'); page.style.display='flex'; }
    var tt=document.getElementById('topTitle');
    if(tt) tt.textContent=h==='terms'?'Terms':'Privacy';
  }
  function showConn(){
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='conn' || h==='connectors') setTimeout(renderMcps, 40);
  }

  function bind(){
    var add=document.getElementById('skAdd');
    if(add) add.onclick=function(){
      var n=(document.getElementById('skName').value||'').trim();
      var b=(document.getElementById('skBody').value||'').trim();
      if(!n||!b) return;
      skills.push({name:n,body:b}); saveSk();
      document.getElementById('skName').value=''; document.getElementById('skBody').value='';
      renderSkills();
    };
    var ms=document.getElementById('mcpSearch');
    if(ms) ms.oninput=function(){ renderMcps(); };
    var mc=document.getElementById('mcpCat');
    if(mc) mc.onchange=function(){ renderMcps(); };
    window.addEventListener('hashchange', function(){
      showLegal(); showConn();
      if((location.hash||'').indexOf('skills')>=0) renderSkills();
    });
    loadSk(); renderSkills();
    renderMcps();
    showLegal();
    showConn();
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', bind);
  else bind();
})();
