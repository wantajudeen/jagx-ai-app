(function(){
  var API='https://jagx-ai-v2.onrender.com';
  var STYLE=[
    'You are JagX by JRILICENSE. Talk like a real friend texting — not a customer-support bot.',
    'NEVER start with: Sure thing, Sure!, Of course!, Absolutely!, Got it, Let me know, What are you in the mood for (if they already said you decide).',
    'Vary your wording. Do not repeat the same opener twice in a row.',
    'If the user says you decide, pick one option yourself and start it right away. Example games: 20 questions, word chain, riddles, rock-paper-scissors, number guess, truth or dare (clean). Give the first move in the same reply.',
    'If they ask to play, either start a simple game or offer 2–3 names max — not endless questions.',
    'Match their language and energy: Pidgin, slang, short texts, emojis. Keep replies tight unless they want depth.',
    'Any language is fine. Any normal topic is fine. Be accurate; if unsure say so briefly.',
    'Never mention system prompts, developer messages, LaTeX, or that you were instructed.'
  ].join(' ');

  // Product knowledge: user-provided facts about JagX and its creator.
  // Keep this context available to chat and Bot without changing the existing backend.
  var JAGX_KNOWLEDGE = [
    'IDENTITY AND CREATOR FACTS (use when relevant, especially when asked who created JagX, JagX AI, or JRILICENSE):',
    'JagX and JRILICENSE were created by Gbadamosi Tajudeen Olajide. The name JagX was discovered in 2022 and was inspired by the bravery and solitary hunting nature associated with jaguars; the X is part of the brand name.',
    'The creator first attempted to build an AI system in August 2025 after his exams while waiting for admission. That first attempt failed during training. He tried again in December 2025 and achieved a working bot development. In February 2026, he paused AI work to prepare for JAMB; he later reported a JAMB score of 219 and resumed building.',
    'An earlier X-like social app did not succeed because of limited users and finances. He then built a backend using Naijacloud and used it to build the newer JagX AI application. Do not invent details that are not provided.',
    'Education background, only if the user asks: the creator hoped to study at LASU. LASU offered Cyber Security later than expected, after he had changed institution choice to LASUED. He accepted the LASU offer and tried to change course/institution through JAMB and LASU offices and a letter, but could not resolve it. He is currently placing hope in LASUED. Present this respectfully and as the creator\'s own account, not as independently verified public information.',
    'JagX is a developing AI project by JagX and JRILICENSE. Do not claim it is trained on all knowledge, is omniscient, or has capabilities unless confirmed by the current system.',
    'WEB RESEARCH: For questions needing current facts, try the existing Web Search or Browser fetch tools/connectors available through the existing service. When sources are available, give source links and distinguish sourced facts from inference. If live search is unavailable in this session, say so clearly and answer from known information without pretending to have searched. Never fabricate citations, URLs, or search results.',
    'CREATOR PRIVACY: Share the supplied creator biography only when relevant to a direct question about JagX, JRILICENSE, its creator, origin, or background. Do not expose unrelated personal details in ordinary answers.'
  ].join(' ');
  
  function uid(){
    var id=localStorage.getItem('jx_web_uid');
    if(!id){ id='web_'+Math.random().toString(36).slice(2,10); localStorage.setItem('jx_web_uid', id); }
    return id;
  }
  function clean(t){
    if(!t) return t;
    var s=String(t).trim();
    s=s.replace(/^(sure thing!?\s*)+/i,'');
    s=s.replace(/^sure[,!]\s*/i,'');
    s=s.replace(/^(of course!?|absolutely!?|got it!?|certainly!?)\s*/i,'');
    var lines=s.split(/\n+/);
    var bad=/latex|developer message|formatting as you|plain-text math|bolded titles|markdown tables|instructions that were given|style and content guidelines|i'll keep the formatting|i\u2019ll keep the formatting|got it\u2014i|^solution$/i;
    var kept=lines.filter(function(l){ return !bad.test(l.trim()); });
    var out=kept.join('\n').trim();
    return out || 'Okay — your move.';
  }
  function injectAds(){
    if(document.querySelector('meta[name="google-adsense-account"]')) return;
    var m=document.createElement('meta');
    m.name='google-adsense-account';
    m.content='ca-pub-6037723607677223';
    document.head.appendChild(m);
    if(!document.getElementById('jx-adsense')){
      var s=document.createElement('script');
      s.id='jx-adsense';
      s.async=true;
      s.src='https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6037723607677223';
      s.crossOrigin='anonymous';
      document.head.appendChild(s);
    }
  }
  function css(){
    if(document.getElementById('jxfix')) return;
    var s=document.createElement('style'); s.id='jxfix';
    s.textContent=
      '.msg{position:relative}.msg .edit-btn,.msg .fb-btn{position:static!important;display:inline-flex;margin-top:6px}'+
      '.msg-actions{position:static!important;opacity:.85!important;justify-content:flex-end;margin-top:4px}'+
      '.msg.user{flex-direction:column;align-items:flex-end}'+
      '#jxAdSlot{min-height:0;margin:8px 16px;text-align:center}';
    document.head.appendChild(s);
  }
  function scrubDom(){
    document.querySelectorAll('.bubble,.msg').forEach(function(el){
      if(el.dataset.jxclean) return;
      var t=el.innerText||'';
      if(/latex|developer message|formatting as you|plain-text math|sure thing/i.test(t)){
        el.dataset.jxclean='1';
        if(el.querySelector('.bubble')) return;
        el.textContent=clean(t);
      }
    });
  }
  function connected(){
    try{ return JSON.parse(localStorage.getItem((window.__jagxUserId||'guest')+'_mcp')||'[]'); }catch(e){ return []; }
  }
  async function chat(text){
    var tools=connected().join(', ');
    var prompt=STYLE+'\n\n'+JAGX_KNOWLEDGE+'\n\nUser: '+text;
    if(tools) prompt+='\nConnected tools: '+tools;
    var res=await fetch(API+'/public-chat',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({message:prompt, user_id:uid(), mode:'bot'})
    });
    var data={};
    try{ data=await res.json(); }catch(e){}
    if(!res.ok) throw new Error((data&&data.detail)||('HTTP '+res.status));
    return clean(data.response||data.reply||data.text||data.answer||'');
  }
  function mountBot(){
    var page=document.getElementById('page-bot'); if(!page||page.dataset.jx) return;
    page.dataset.jx='1';
    var box=document.createElement('div'); box.id='jxBotBox'; box.className='box';
    box.innerHTML='<b>JagX Bot</b><div class="tiny">Any language · any topic. Goal runs on the server.</div>'+
      '<label>Goal</label><textarea id="jxGoal" rows="3" placeholder="Ask in any language..."></textarea>'+
      '<button class="full solid" type="button" id="jxRun">Run bot</button>'+
      '<div id="jxBotLog" style="margin-top:12px;white-space:pre-wrap"></div>';
    page.insertBefore(box, page.firstChild.nextSibling);
    document.getElementById('jxRun').onclick=async function(){
      var g=(document.getElementById('jxGoal').value||'').trim();
      var log=document.getElementById('jxBotLog');
      if(!g){ log.textContent='Type a goal first.'; return; }
      log.textContent='Running...';
      try{ var reply=await chat(g); localStorage.setItem('jx_last_bot', reply); log.textContent=reply; }
      catch(e){ log.textContent='Bot failed: '+e.message; }
    };
    var last=localStorage.getItem('jx_last_bot');
    if(last) document.getElementById('jxBotLog').textContent=last;
  }
  function mountGh(){
    var page=document.getElementById('page-github'); if(!page||page.dataset.jx) return;
    page.dataset.jx='1';
    var box=document.createElement('div'); box.id='jxGhBox'; box.className='box';
    box.innerHTML='<b>Connect your GitHub</b><div class="tiny">Token from github.com/settings/tokens, scope repo.</div>'+
      '<label>Personal access token</label><input id="jxGhToken" type="password" placeholder="ghp_..."/>'+
      '<label>owner/repo</label><input id="jxGhRepo" placeholder="you/repo"/>'+
      '<button class="full solid" type="button" id="jxGhSave">Save GitHub connection</button>'+
      '<div class="tiny" id="jxGhMsg"></div>';
    page.insertBefore(box, page.firstChild.nextSibling);
    var saved=localStorage.getItem('jx_gh_repo')||'';
    if(saved) document.getElementById('jxGhRepo').value=saved;
    document.getElementById('jxGhSave').onclick=async function(){
      var token=(document.getElementById('jxGhToken').value||'').trim();
      var repo=(document.getElementById('jxGhRepo').value||'').trim();
      var msg=document.getElementById('jxGhMsg');
      if(!token){ msg.textContent='Paste a GitHub token.'; return; }
      localStorage.setItem('jx_gh_token', token);
      localStorage.setItem('jx_gh_repo', repo);
      try{
        var res=await fetch(API+'/vault',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({user_id:uid(), key:'github', value:token})});
        msg.textContent=res.ok?('Connected'+(repo?' to '+repo:'')+'.'):'Saved on this device. Vault returned '+res.status+'.';
      }catch(e){ msg.textContent='Saved on this device. Server unreachable.'; }
      document.getElementById('jxGhToken').value='';
    };
  }
  var orig=window.fetch;
  window.fetch=function(url, opts){
    try{
      if(opts && opts.body && typeof opts.body==='string' && /chat/i.test(String(url))){
        var body=JSON.parse(opts.body);
        var msg=body.message||body.prompt||body.content||'';
        if(typeof msg==='string' && msg.indexOf('You are JagX')!==0){
          body.message=STYLE+'\n\n'+JAGX_KNOWLEDGE+'\n\nFor questions that need current information, use available Web Search/Browser tools when supported; cite real source URLs only when actually retrieved. Never claim a live search occurred if it did not.\n\nUser: '+msg;
          opts=Object.assign({}, opts, {body:JSON.stringify(body)});
        }
      }
    }catch(e){}
    return orig.apply(this, arguments).then(function(res){
      try{
        if(/chat/i.test(String(url))){
          return res.clone().json().then(function(data){
            if(data && (data.reply||data.text)){
              data.reply=clean(data.reply||data.text);
              data.text=data.reply;
              return new Response(JSON.stringify(data), {status:res.status, headers:{'Content-Type':'application/json'}});
            }
            return res;
          }).catch(function(){ return res; });
        }
      }catch(e){}
      return res;
    });
  };
  function mountQuickPrompts(){
    var wrap=document.getElementById('jxQuickPrompts');
    var input=document.getElementById('input');
    if(!wrap||!input||wrap.dataset.jxBound) return;
    wrap.dataset.jxBound='1';
    wrap.addEventListener('click',function(e){
      var btn=e.target.closest('button[data-prompt]');
      if(!btn) return;
      var prompt=btn.getAttribute('data-prompt')||'';
      input.value=prompt;
      input.focus();
      input.style.height='auto';
      input.style.height=Math.min(input.scrollHeight,160)+'px';
      input.setSelectionRange(input.value.length,input.value.length);
    });
  }
  function studioStyles(){if(document.getElementById('jxStudioCss'))return;var s=document.createElement('style');s.id='jxStudioCss';s.textContent='.jx-studio-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,280px),1fr));gap:14px}.jx-studio-card{background:#141416;border:1px solid #303036;border-radius:18px;padding:18px;margin-bottom:14px}.jx-studio-card h3{margin-bottom:6px}.jx-studio-card p,.jx-status{font-size:13px;color:#a1a1aa;line-height:1.55}.jx-studio-card textarea{width:100%;min-height:100px;margin:12px 0;padding:12px;border-radius:12px;background:#09090b;border:1px solid #303036;color:#fafafa;resize:vertical}.jx-studio-card select{width:100%;padding:10px;border-radius:10px;background:#09090b;border:1px solid #303036;color:#fafafa;margin-top:8px}.jx-studio-output{margin-top:14px;padding:12px;border:1px dashed #3f3f46;border-radius:12px;white-space:pre-wrap;overflow-wrap:anywhere;color:#d4d4d8;font-size:13px}.jx-studio-output img,.jx-studio-output video{display:block;max-width:100%;max-height:440px;border-radius:12px;margin:10px auto}.jx-studio-btn{display:inline-block;padding:10px 14px;border-radius:10px;background:#fafafa;color:#09090b;font-weight:600;margin-top:8px}.jx-studio-btn:disabled{opacity:.45}.jx-activity{padding:10px 0;border-bottom:1px solid #27272a;font-size:13px}@media(max-width:600px){.jx-studio-card{padding:14px}.jx-studio-output img,.jx-studio-output video{max-height:300px}}';document.head.appendChild(s)}
  function mountStudio(){
    var main=document.getElementById('main'),nav=document.querySelector('.nav');if(!main||!nav||document.getElementById('page-image-studio'))return;studioStyles();
    [['image-studio','Image Studio','✦'],['video-studio','Video Studio','▶'],['connectors','Connector status','⌘'],['agents','Agents & activity','◷']].forEach(function(it){if(document.querySelector('[data-route="'+it[0]+'"]'))return;var a=document.createElement('a');a.href='#/'+it[0];a.dataset.route=it[0];a.innerHTML='<span>'+it[2]+'</span><span>'+it[1]+'</span>';nav.appendChild(a)});
    function mediaPage(id,title,desc,kind){var el=document.createElement('section');el.className='page';el.id='page-'+id;el.innerHTML='<div class="ph">'+title+'</div><p class="lead">'+desc+'</p><div class="jx-studio-grid"><div class="jx-studio-card"><h3>Describe your '+kind+'</h3><p>Use a detailed prompt. Results depend on the capabilities of the existing service.</p><textarea id="jx-'+kind+'Prompt" placeholder="'+(kind==='image'?'A cinematic night city with warm neon reflections…':'An aerial cinematic shot over a green valley…')+'"></textarea><label>Style</label><select id="jx-'+kind+'Style"><option>Cinematic</option><option>Photorealistic</option><option>Illustration</option><option>Anime</option><option>3D render</option></select><button class="jx-studio-btn" id="jx-'+kind+'Run" type="button">Create '+kind+'</button><div class="jx-status" id="jx-'+kind+'Status">Ready · capability not yet verified</div></div><div class="jx-studio-card"><h3>Result preview</h3><p>Media appears here only when a usable URL is returned.</p><div class="jx-studio-output" id="jx-'+kind+'Output">Your result will appear here.</div></div></div>';main.appendChild(el)}
    mediaPage('image-studio','Image Studio','Dedicated image prompt, preview and save area.','image');mediaPage('video-studio','Video Studio','Request video creation; progress and playback require backend support.','video');
    var cp=document.createElement('section');cp.className='page';cp.id='page-connectors';cp.innerHTML='<div class="ph">Connector directory</div><p class="lead">A selected connector is not necessarily authenticated or live.</p><div class="jx-studio-card" id="jxConnectorStatus"></div><button class="jx-studio-btn" id="jxOpenConnectors" type="button">Open connector settings</button>';main.appendChild(cp);
    var ap=document.createElement('section');ap.className='page';ap.id='page-agents';ap.innerHTML='<div class="ph">JagX Bot & agents</div><p class="lead">Run tasks through the existing service and review local activity.</p><div class="jx-studio-card"><h3>New task</h3><textarea id="jx-agent-goal" placeholder="Describe the task…"></textarea><button class="jx-studio-btn" id="jx-agent-run" type="button">Run task</button><div class="jx-status" id="jx-agent-status">Idle</div><div class="jx-studio-output" id="jx-agent-result">No task result yet.</div></div><div class="jx-studio-card"><h3>Recent activity</h3><div id="jx-agent-activity"></div><button class="ghost" id="jx-agent-clear" type="button">Clear local activity</button></div>';main.appendChild(ap);
    function items(){try{return JSON.parse(localStorage.getItem('jx_agent_activity')||'[]')}catch(e){return []}}function render(){var h=document.getElementById('jx-agent-activity');if(!h)return;h.innerHTML='';var a=items();if(!a.length){h.textContent='No task activity yet.';return}a.slice(0,12).forEach(function(x){var d=document.createElement('div');d.className='jx-activity';d.textContent=x.time+' · '+x.goal+' — '+x.status;h.appendChild(d)})}function record(g,s){var a=items();a.unshift({time:new Date().toLocaleString(),goal:g.slice(0,100),status:s});try{localStorage.setItem('jx_agent_activity',JSON.stringify(a.slice(0,30)))}catch(e){}render()}
    async function runMedia(kind){var p=document.getElementById('jx-'+kind+'Prompt'),status=document.getElementById('jx-'+kind+'Status'),out=document.getElementById('jx-'+kind+'Output'),btn=document.getElementById('jx-'+kind+'Run'),goal=(p.value||'').trim();if(!goal){status.textContent='Add a description first.';p.focus();return}btn.disabled=true;status.textContent='Checking the current integration…';out.textContent='';var note=document.createElement('p');note.textContent='This screen currently has no confirmed image/video generation endpoint wired to the existing JagX service. Sending a prompt to /chat only produces a text reply; it cannot create a real media file. No '+kind+' has been generated.';out.appendChild(note);var detail=document.createElement('p');detail.className='jx-status';detail.textContent='To make this work, the existing backend must expose its actual generation route and return a job/result or media URL. This frontend will not invent an endpoint or show a fake preview.';out.appendChild(detail);status.textContent='Not connected · generation route not confirmed';btn.disabled=false}
    document.getElementById('jx-imageRun').onclick=function(){runMedia('image')};document.getElementById('jx-videoRun').onclick=function(){runMedia('video')};document.getElementById('jxOpenConnectors').onclick=function(){location.hash='#/conn'};
    document.getElementById('jx-agent-run').onclick=async function(){var p=document.getElementById('jx-agent-goal'),g=(p.value||'').trim(),st=document.getElementById('jx-agent-status'),out=document.getElementById('jx-agent-result'),btn=this;if(!g){st.textContent='Enter a task first.';return}btn.disabled=true;st.textContent='Running through existing service…';out.textContent='In progress…';record(g,'started');try{var r=await fetch(API+'/chat',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message:'Act as JagX Bot. Complete this task within your current capabilities. Be honest about unsupported actions; report steps, blockers and result. Task: '+g,user_id:uid(),mode:'bot'})});var d=await r.json();if(!r.ok)throw new Error(d.detail||('HTTP '+r.status));out.textContent=clean(d.reply||d.text||d.answer||'No result returned.');st.textContent='Result received';record(g,'finished')}catch(e){out.textContent='Task failed: '+e.message;st.textContent='Failed';record(g,'failed')}finally{btn.disabled=false}};document.getElementById('jx-agent-clear').onclick=function(){localStorage.removeItem('jx_agent_activity');render()};render()
  }
  function routeStudio(){var r=(location.hash||'').replace(/^#\/?/,'').split('?')[0],names={'image-studio':'Image Studio','video-studio':'Video Studio','connectors':'Connector status','agents':'Agents & activity'};if(!names[r])return;document.querySelectorAll('.page').forEach(function(p){p.classList.remove('on');p.style.display='none'});var pg=document.getElementById('page-'+r);if(pg){pg.classList.add('on');pg.style.display='flex'}document.querySelectorAll('[data-route]').forEach(function(a){a.classList.toggle('on',a.dataset.route===r)});var t=document.getElementById('topTitle');if(t)t.textContent=names[r];var side=document.getElementById('side'),scrim=document.getElementById('scrim');if(side)side.classList.remove('open');if(scrim)scrim.classList.remove('open');if(r==='connectors'){var h=document.getElementById('jxConnectorStatus');if(h){h.innerHTML='';var a=[];try{a=JSON.parse(localStorage.getItem((window.__jagxUserId||'guest')+'_mcp')||'[]')}catch(e){}var p=document.createElement('p');p.textContent=a.length+' connector(s) selected locally; this does not confirm authentication or server availability.';h.appendChild(p);a.forEach(function(x){var d=document.createElement('div');d.className='jx-activity';d.textContent='Selected · '+x;h.appendChild(d)});if(!a.length)h.appendChild(document.createTextNode('No connectors selected. Browse connector settings for the available directory.'))}}}
\n  function tick(){
    injectAds(); css(); scrubDom(); mountQuickPrompts(); mountStudio(); routeStudio();
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='bot') mountBot();
    if(h==='github') mountGh();
  }
  window.addEventListener('hashchange', tick);
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', tick); else tick();
  setInterval(tick, 1200);
})();
