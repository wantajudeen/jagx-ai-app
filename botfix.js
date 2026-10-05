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
    var prompt=STYLE+'\n\nUser: '+text;
    if(tools) prompt+='\nConnected tools: '+tools;
    var res=await fetch(API+'/chat',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({message:prompt, user_id:uid(), mode:'bot'})
    });
    var data={};
    try{ data=await res.json(); }catch(e){}
    if(!res.ok) throw new Error((data&&data.detail)||('HTTP '+res.status));
    return clean(data.reply||data.text||data.answer||'');
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
          body.message=STYLE+'\n\nUser: '+msg;
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
  function tick(){
    injectAds(); css(); scrubDom();
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='bot') mountBot();
    if(h==='github') mountGh();
  }
  window.addEventListener('hashchange', tick);
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', tick); else tick();
  setInterval(tick, 1200);
})();
