(function(){
  var API='https://jagx-ai-v2.onrender.com';
  function uid(){
    var id=localStorage.getItem('jx_web_uid');
    if(!id){ id='web_'+Math.random().toString(36).slice(2,10); localStorage.setItem('jx_web_uid', id); }
    return id;
  }
  function css(){
    if(document.getElementById('jxfix')) return;
    var s=document.createElement('style'); s.id='jxfix';
    s.textContent=
      '.msg{position:relative}.msg .edit-btn,.msg .fb-btn{position:static!important;display:inline-flex;margin-top:6px}'+
      '.msg-actions{position:static!important;opacity:1!important;justify-content:flex-end;margin-top:4px}'+
      '.msg.user{flex-direction:column;align-items:flex-end}'+
      '#jxBotBox,#jxGhBox{margin-top:8px}'+
      '#jxBotLog{white-space:pre-wrap;color:#d4d4d8;font-size:14px;line-height:1.5;min-height:40px}';
    document.head.appendChild(s);
  }
  function connected(){
    try{ return JSON.parse(localStorage.getItem((window.__jagxUserId||'guest')+'_mcp')||'[]'); }catch(e){ return []; }
  }
  async function chat(text){
    var tools=connected().join(', ');
    var prompt=text;
    if(tools) prompt+='\n\nUser connected tools: '+tools+'. Use them if relevant.';
    var res=await fetch(API+'/chat',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({message:prompt, user_id:uid(), mode:'bot'})
    });
    var data={};
    try{ data=await res.json(); }catch(e){}
    if(!res.ok) throw new Error((data&&data.detail)||('HTTP '+res.status));
    return data.reply||data.text||data.answer||JSON.stringify(data).slice(0,800);
  }
  function mountBot(){
    var page=document.getElementById('page-bot'); if(!page||page.dataset.jx) return;
    page.dataset.jx='1';
    var box=document.createElement('div'); box.id='jxBotBox'; box.className='box';
    box.innerHTML='<b>JagX Bot</b><div class="tiny">Runs on the server. Close the tab; reopen Bot to see the last result. Connected tools are sent with the goal.</div>'+
      '<label>Goal</label><textarea id="jxGoal" rows="3" placeholder="Research X and draft a plan..."></textarea>'+
      '<button class="full solid" type="button" id="jxRun">Run bot</button>'+
      '<div id="jxBotLog" style="margin-top:12px"></div>';
    page.insertBefore(box, page.firstChild.nextSibling);
    document.getElementById('jxRun').onclick=async function(){
      var g=(document.getElementById('jxGoal').value||'').trim();
      var log=document.getElementById('jxBotLog');
      if(!g){ log.textContent='Type a goal first.'; return; }
      log.textContent='Running\u2026';
      try{
        var reply=await chat(g);
        localStorage.setItem('jx_last_bot', reply);
        log.textContent=reply;
      }catch(e){ log.textContent='Bot failed: '+e.message+' \u2014 wake the Render service, then try again.'; }
    };
    var last=localStorage.getItem('jx_last_bot');
    if(last) document.getElementById('jxBotLog').textContent=last;
  }
  function mountGh(){
    var page=document.getElementById('page-github'); if(!page||page.dataset.jx) return;
    page.dataset.jx='1';
    var box=document.createElement('div'); box.id='jxGhBox'; box.className='box';
    box.innerHTML='<b>Connect your GitHub</b><div class="tiny">Create a token at github.com/settings/tokens (scope: repo). Saved on this browser and sent to the server vault. The bot uses it only when a goal needs GitHub.</div>'+
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
      if(!token||token.indexOf('ghp_')!==0 && token.indexOf('github_pat_')!==0){
        msg.textContent='Paste a GitHub token (ghp_ or github_pat_).'; return;
      }
      localStorage.setItem('jx_gh_token', token);
      localStorage.setItem('jx_gh_repo', repo);
      msg.textContent='Saving to vault\u2026';
      try{
        var res=await fetch(API+'/vault',{method:'POST',headers:{'Content-Type':'application/json'},
          body:JSON.stringify({user_id:uid(), key:'github', value:token})});
        msg.textContent=res.ok?('Connected'+(repo?' to '+repo:'')+'. Bot can use GitHub when the goal needs it.'):'Saved on this device. Server vault returned '+res.status+' \u2014 redeploy backend.';
      }catch(e){ msg.textContent='Saved on this device. Server unreachable.'; }
      document.getElementById('jxGhToken').value='';
    };
  }
  function tick(){
    css();
    var h=(location.hash||'').replace(/^#\/?/,'').split('?')[0];
    if(h==='bot') mountBot();
    if(h==='github') mountGh();
  }
  window.addEventListener('hashchange', tick);
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', tick);
  else tick();
  setInterval(tick, 1500);
})();
