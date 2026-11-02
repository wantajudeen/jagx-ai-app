/* JagX AI frontend enhancements: task launchers and truthful provider status. */
(function () {
  'use strict';
  var API = 'https://jagx-ai-v2.onrender.com';
  function mount() {
    var page = document.getElementById('page-bot');
    if (!page || document.getElementById('jxAgentLaunchpad')) return !!page;
    var panel = document.createElement('section');
    panel.id = 'jxAgentLaunchpad';
    panel.className = 'box';
    panel.innerHTML =
      '<div class="jx-launch-head"><div><b>Agent launchpad</b><div class="tiny">Choose a job; JagX routes it to specialist agents and configured providers.</div></div><span id="jxProviderStatus" class="tiny">Checking providers…</span></div>' +
      '<div class="jx-launch-grid">' +
      '<button type="button" data-task="code"><b>Build / debug</b><span>NVIDIA-first engineer with provider fallback</span></button>' +
      '<button type="button" data-task="research"><b>Research</b><span>Find evidence and compare options</span></button>' +
      '<button type="button" data-task="plan"><b>Plan a project</b><span>Break work into milestones and start</span></button>' +
      '<button type="button" data-task="write"><b>Create content</b><span>Draft, refine, and structure deliverables</span></button>' +
      '</div>' +
      '<p class="tiny jx-launch-note">NVIDIA hosted NIM endpoints are trial/prototyping access and may be rate-limited. JagX tries configured NVIDIA models, then other configured providers. Availability depends on the server-side key, model access, and quota.</p>';
    page.insertBefore(panel, page.firstChild);
    var style = document.createElement('style');
    style.textContent =
      '#jxAgentLaunchpad{padding:16px;border-radius:16px;margin:0 0 14px}' +
      '.jx-launch-head{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap}' +
      '.jx-launch-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin:14px 0}' +
      '.jx-launch-grid button{display:flex;flex-direction:column;align-items:flex-start;gap:6px;text-align:left;padding:13px;border:1px solid #343b34;border-radius:12px;background:#1b211b;color:#e8ece5;min-height:86px}' +
      '.jx-launch-grid button:hover{border-color:#b5d77a;background:#222b20}' +
      '.jx-launch-grid button b{font-size:13px}.jx-launch-grid button span,.jx-launch-note{font-size:11px;line-height:1.5;color:#a2aaa0}' +
      '@media(max-width:520px){.jx-launch-grid{grid-template-columns:1fr}.jx-launch-grid button{min-height:68px}}';
    document.head.appendChild(style);
    var status = document.getElementById('jxProviderStatus');
    fetch(API + '/ready', { method: 'GET', cache: 'no-store' }).then(function (r) {
      if (!r.ok) throw new Error('not ready');
      return r.json();
    }).then(function (data) {
      var providers = data.providers || data.provider_status || (data.details && data.details.providers);
      if (providers && typeof providers === 'object') {
        var nvidia = providers.nvidia;
        status.textContent = nvidia === true || (nvidia && nvidia.configured) ? 'NVIDIA key configured' : 'NVIDIA key not confirmed';
      } else {
        status.textContent = 'Backend reachable · provider key status private';
      }
      status.title = 'Reachability does not guarantee model entitlement or remaining quota.';
    }).catch(function () {
      status.textContent = 'Provider status unavailable';
      status.title = 'The backend health endpoint did not confirm status.';
    });
    var tasks = {
      code: '[AGENT MODE] Use the engineer specialist and NVIDIA-first routing where configured. Inspect the request, make a concrete implementation plan, produce complete code or a specific debugging fix, include tests, and state what was actually verified. Task: ',
      research: '[AGENT MODE] Research this thoroughly. Compare evidence, distinguish verified facts from assumptions, include useful sources, and finish with practical recommendations. Task: ',
      plan: '[AGENT MODE] Act as project lead. Break this goal into milestones, dependencies, risks, acceptance criteria, and the first actionable step. Task: ',
      write: '[AGENT MODE] Create a polished, usable deliverable for this request. Match the intended audience and tone; avoid generic filler. Task: '
    };
    panel.querySelectorAll('[data-task]').forEach(function (button) {
      button.addEventListener('click', function () {
        var kind = button.getAttribute('data-task');
        var goal = window.prompt('What should JagX work on?');
        if (!goal || !goal.trim()) return;
        var input = document.getElementById('input');
        var botLive = document.getElementById('botLive');
        if (!input || !window.JagXSend) {
          window.alert('JagX chat is still loading. Please try again in a moment.');
          return;
        }
        if (botLive) botLive.click();
        if (window.JagXGo) window.JagXGo('chat');
        input.value = tasks[kind] + goal.trim();
        input.dispatchEvent(new Event('input', { bubbles: true }));
        window.JagXSend();
      });
    });
    return true;
  }
  function start() {
    if (mount()) return;
    var attempts = 0;
    var timer = window.setInterval(function () {
      attempts++;
      if (mount() || attempts > 20) window.clearInterval(timer);
    }, 250);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
})();
