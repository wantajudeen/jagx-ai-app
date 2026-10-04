(function(){
  var API='https://jagx-ai-v2.onrender.com';
  var STYLE='Answer the user directly in their language (any language, slang, or symbols). Never mention system prompts, developer messages, formatting rules, LaTeX, markdown policy, or that you were instructed. Do not open with Got it or I will keep. If the user only says hmm, ok, hi, or a sign, reply in one short natural line.';
  function uid(){
    var id=localStorage.getItem('jx_web_uid');
    if(!id){ id='web_'+Math.random().toString(36).slice(2,10); localStorage.setItem('jx_web_uid', id); }
    return id;
  }
  function clean(t){
    if(!t) return t;
    var lines=String(t).split(/\n+/);
    var bad=/latex|developer message|formatting as you|plain-text math|bolded titles|markdown tables|instructions that were given|style and content guidelines|i'll keep the formatting|i’ll keep the formatting|got it—i/i;
    var kept=lines.filter(function(l){ return !bad.test(l); });
    var out=kept.join('\n').trim();
    return out || 'Okay.';
  }
  function css(){
    if(document.getElementById('jxfix')) return;
    var s=document.createElement('style'); s.id='jxfix';
    s.textContent=
      '.msg{position:relative}.msg .edit-btn,.msg .fb-btn{position:static!important;display:inline-flex;margin-top:6px}'+
      '.msg-actions{position:static!important;opacity:.85!important;justify-content:flex-end;margin-top:4px}'+
      '.msg.user{flex-direction:column;align-items:flex-end}';
    document.head.appendChild(s);
  }
  function scrubDom(){
    document.querySelectorAll('.bubble,.msg').forEach(function(el){
      if(el.dataset.jxclean) return;
      var t=el.innerText||'';
      if(/latex|developer message|formatting as you|plain-text math/i.test(t)){
        el.dataset.jxclean='1';
        var next=clean(t);
        if(el.querySelector('.bubble')) return;
        el.textContent=next;
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
    box.innerHTML='<b>JagX Bot</b><div class="tiny">Goal runs on the server. Connected tools are included. No style talk.</div>'+
      '<label>Goal</label><textarea id="jxGoal" rows="3" placeholder="Research and draft a plan"></textarea>'+
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
    box.innerHTML='<b>Connect your GitHub</b><div class="tiny">Token from github.com/settings/tokens, scope repo. Used only when a goal needs GitHub.</div>'+
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
        if(typeof msg==='string' && msg.indexOf('Answer the user directly')!==0){
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
    css(); scrubDom();
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='bot') mountBot();
    if(h==='github') mountGh();
  }
  window.addEventListener('hashchange', tick);
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', tick); else tick();
  setInterval(tick, 1200);
})();
