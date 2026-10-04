(function(){
  /* ---- Skills (existing) ---- */
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

  /* ---- MCP catalog (shown on Connectors) ---- */
  var MCPS=[
    {id:'web-search',name:'Web Search',cat:'Core',url:'builtin://search',desc:'Live web search via JagX server'},
    {id:'news',name:'News',cat:'Core',url:'builtin://news',desc:'Current headlines'},
    {id:'weather',name:'Weather',cat:'Core',url:'builtin://weather',desc:'Local weather'},
    {id:'maps',name:'Maps / Geo',cat:'Core',url:'builtin://geo',desc:'Places and coordinates'},
    {id:'calc',name:'Calculator',cat:'Core',url:'builtin://calc',desc:'Math and units'},
    {id:'sandbox',name:'Code Sandbox',cat:'Programming',url:'builtin://sandbox',desc:'Run Python on server'},
    {id:'github',name:'GitHub',cat:'Programming',url:'https://github.com',desc:'Repos, import/export code',auth:'token'},
    {id:'filesystem',name:'Files',cat:'Programming',url:'builtin://files',desc:'Read/write workspace files'},
    {id:'memory',name:'Memory',cat:'Core',url:'builtin://memory',desc:'Long-term user memory'},
    {id:'jobs',name:'Bot Jobs',cat:'Core',url:'builtin://jobs',desc:'Background goals after app close'},
    {id:'vault',name:'Vault',cat:'Core',url:'builtin://vault',desc:'Secret tokens (never returned)'},
    {id:'brave',name:'Brave Search',cat:'Research',url:'https://search.brave.com',desc:'Privacy web search'},
    {id:'duckduckgo',name:'DuckDuckGo',cat:'Research',url:'https://duckduckgo.com',desc:'Web search'},
    {id:'wikipedia',name:'Wikipedia',cat:'Research',url:'https://wikipedia.org',desc:'Encyclopedia'},
    {id:'arxiv',name:'arXiv',cat:'Research',url:'https://arxiv.org',desc:'Research papers'},
    {id:'pubmed',name:'PubMed',cat:'Research',url:'https://pubmed.ncbi.nlm.nih.gov',desc:'Medical research'},
    {id:'stackoverflow',name:'Stack Overflow',cat:'Programming',url:'https://stackoverflow.com',desc:'Dev Q&A'},
    {id:'npm',name:'npm',cat:'Programming',url:'https://www.npmjs.com',desc:'JS packages'},
    {id:'pypi',name:'PyPI',cat:'Programming',url:'https://pypi.org',desc:'Python packages'},
    {id:'dockerhub',name:'Docker Hub',cat:'Cloud',url:'https://hub.docker.com',desc:'Containers'},
    {id:'aws',name:'AWS',cat:'Cloud',url:'https://aws.amazon.com',desc:'Amazon Web Services',auth:'oauth'},
    {id:'gcp',name:'Google Cloud',cat:'Cloud',url:'https://cloud.google.com',desc:'GCP',auth:'oauth'},
    {id:'azure',name:'Azure',cat:'Cloud',url:'https://azure.microsoft.com',desc:'Microsoft Azure',auth:'oauth'},
    {id:'vercel',name:'Vercel',cat:'Cloud',url:'https://vercel.com',desc:'Deploy frontends',auth:'token'},
    {id:'netlify',name:'Netlify',cat:'Cloud',url:'https://netlify.com',desc:'Static hosting',auth:'token'},
    {id:'render',name:'Render',cat:'Cloud',url:'https://render.com',desc:'Backend hosting'},
    {id:'supabase',name:'Supabase',cat:'Cloud',url:'https://supabase.com',desc:'Auth + Postgres',auth:'token'},
    {id:'firebase',name:'Firebase',cat:'Cloud',url:'https://firebase.google.com',desc:'Google backend'},
    {id:'stripe',name:'Stripe',cat:'Payments',url:'https://stripe.com',desc:'Payments',auth:'token'},
    {id:'paypal',name:'PayPal',cat:'Payments',url:'https://paypal.com',desc:'Payments'},
    {id:'gmail',name:'Gmail',cat:'Communication',url:'https://mail.google.com',desc:'Email',auth:'oauth'},
    {id:'outlook',name:'Outlook',cat:'Communication',url:'https://outlook.com',desc:'Email'},
    {id:'slack',name:'Slack',cat:'Communication',url:'https://slack.com',desc:'Team chat',auth:'oauth'},
    {id:'discord',name:'Discord',cat:'Communication',url:'https://discord.com',desc:'Communities',auth:'oauth'},
    {id:'telegram',name:'Telegram',cat:'Communication',url:'https://telegram.org',desc:'Messaging'},
    {id:'whatsapp',name:'WhatsApp',cat:'Communication',url:'https://whatsapp.com',desc:'Messaging'},
    {id:'x',name:'X (Twitter)',cat:'Social',url:'https://x.com',desc:'Posts and search',auth:'oauth'},
    {id:'linkedin',name:'LinkedIn',cat:'Social',url:'https://linkedin.com',desc:'Professional network'},
    {id:'youtube',name:'YouTube',cat:'Social',url:'https://youtube.com',desc:'Video'},
    {id:'reddit',name:'Reddit',cat:'Social',url:'https://reddit.com',desc:'Communities'},
    {id:'notion',name:'Notion',cat:'Creative',url:'https://notion.so',desc:'Docs and wikis',auth:'oauth'},
    {id:'figma',name:'Figma',cat:'Creative',url:'https://figma.com',desc:'Design',auth:'oauth'},
    {id:'canva',name:'Canva',cat:'Creative',url:'https://canva.com',desc:'Design'},
    {id:'drive',name:'Google Drive',cat:'Cloud',url:'https://drive.google.com',desc:'Files',auth:'oauth'},
    {id:'dropbox',name:'Dropbox',cat:'Cloud',url:'https://dropbox.com',desc:'Files',auth:'oauth'},
    {id:'trello',name:'Trello',cat:'Creative',url:'https://trello.com',desc:'Boards'},
    {id:'linear',name:'Linear',cat:'Programming',url:'https://linear.app',desc:'Issue tracking'},
    {id:'jira',name:'Jira',cat:'Programming',url:'https://atlassian.com/software/jira',desc:'Issues'},
    {id:'sentry',name:'Sentry',cat:'Programming',url:'https://sentry.io',desc:'Error monitoring'},
    {id:'openai',name:'OpenAI',cat:'Core',url:'https://platform.openai.com',desc:'Models API',auth:'token'},
    {id:'anthropic',name:'Anthropic',cat:'Core',url:'https://anthropic.com',desc:'Claude API',auth:'token'},
    {id:'groq',name:'Groq',cat:'Core',url:'https://groq.com',desc:'Fast inference',auth:'token'},
    {id:'openrouter',name:'OpenRouter',cat:'Core',url:'https://openrouter.ai',desc:'Multi-model router',auth:'token'},
    {id:'hf',name:'Hugging Face',cat:'Core',url:'https://huggingface.co',desc:'Models and datasets',auth:'token'},
    {id:'replicate',name:'Replicate',cat:'Creative',url:'https://replicate.com',desc:'Run models',auth:'token'},
    {id:'elevenlabs',name:'ElevenLabs',cat:'Creative',url:'https://elevenlabs.io',desc:'Voice'},
    {id:'spotify',name:'Spotify',cat:'Creative',url:'https://spotify.com',desc:'Music'},
    {id:'maps-google',name:'Google Maps',cat:'Core',url:'https://maps.google.com',desc:'Maps and places'},
    {id:'openstreetmap',name:'OpenStreetMap',cat:'Core',url:'https://openstreetmap.org',desc:'Open maps'},
    {id:'wolfram',name:'Wolfram Alpha',cat:'Research',url:'https://wolframalpha.com',desc:'Computation'},
    {id:'chrome',name:'Browser',cat:'Core',url:'builtin://browser',desc:'Fetch pages via server'}
  ];

  var connected=[];
  function ck(){ return (window.__jagxUserId||'guest')+'_mcp'; }
  function loadConn(){ try{ connected=JSON.parse(localStorage.getItem(ck())||'[]'); }catch(e){ connected=[]; } }
  function saveConn(){ try{ localStorage.setItem(ck(), JSON.stringify(connected)); }catch(e){} }

  function isOn(id){ return connected.indexOf(id)>=0; }

  function renderMcps(){
    var el=document.getElementById('mcpCatalog');
    var mine=document.getElementById('connList');
    if(!el) return;
    loadConn();
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
        d.innerHTML='<div class="grow"><b></b><div class="sub"></div></div><button class="tog" type="button"></button>';
        d.querySelector('b').textContent=m.name;
        d.querySelector('.sub').textContent=m.desc+(m.auth?' · needs '+m.auth:'');
        var btn=d.querySelector('.tog');
        btn.textContent=on?'Connected':'Connect';
        if(on) btn.classList.add('on');
        btn.onclick=function(){
          if(isOn(m.id)){
            connected=connected.filter(function(x){ return x!==m.id; });
          } else {
            connected.push(m.id);
            if(m.url && m.url.indexOf('http')===0){
              try{ window.open(m.url,'_blank'); }catch(e){}
            }
          }
          saveConn(); renderMcps();
        };
        el.appendChild(d);
      });
    });
    if(mine){
      mine.innerHTML='';
      if(!connected.length){
        mine.innerHTML='<div class="box"><div class="tiny">Nothing connected yet. Pick from the catalog below.</div></div>';
      } else {
        connected.forEach(function(id){
          var m=MCPS.find(function(x){ return x.id===id; })||{name:id,desc:''};
          var d=document.createElement('div'); d.className='srow';
          d.innerHTML='<div class="grow"><b></b><div class="sub">Active</div></div>';
          d.querySelector('b').textContent=m.name;
          mine.appendChild(d);
        });
      }
    }
  }

  /* ---- Force show Terms / Privacy when CDN router skips them ---- */
  function showLegal(){
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h!=='terms' && h!=='privacy') return;
    document.querySelectorAll('.page').forEach(function(p){ p.classList.remove('on'); p.style.display='none'; });
    var page=document.getElementById('page-'+h);
    if(page){
      page.classList.add('on');
      page.style.display='flex';
    }
    var tt=document.getElementById('topTitle');
    if(tt) tt.textContent=h==='terms'?'Terms':'Privacy';
  }

  function showConn(){
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='conn' || h==='connectors'){
      setTimeout(renderMcps, 50);
    }
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
