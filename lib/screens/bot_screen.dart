import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/agents.dart';
import '../core/ai.dart';
import '../core/bot_tasks.dart';
import '../core/browser_tool.dart';
import '../core/theme.dart';

/// Dedicated JagX Bot workspace — multi-agent, browser tools, sandbox preview.
class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen>
    with SingleTickerProviderStateMixin {
  final _goal = TextEditingController();
  late TabController _tabs;
  final List<String> _liveLog = [];
  bool _running = false;
  String? _previewHtml;
  List<BotTask> _tasks = [];
  WebViewController? _web;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _reloadTasks();
    _resumePaused();
  }

  Future<void> _reloadTasks() async {
    final t = await BotTaskStore.all();
    setState(() => _tasks = t);
  }

  Future<void> _resumePaused() async {
    final tasks = await BotTaskStore.all();
    final pending = tasks.where((t) => t.status == 'running' || t.status == 'queued');
    for (final t in pending) {
      if (!_running) {
        await _runPipeline(t.goal, existing: t);
      }
    }
  }

  void _log(String line) {
    setState(() => _liveLog.add(line));
  }

  Future<void> _start() async {
    final goal = _goal.text.trim();
    if (goal.isEmpty || _running) return;
    _goal.clear();
    final task = await BotTaskStore.enqueue(goal);
    await _reloadTasks();
    await _runPipeline(goal, existing: task);
  }

  Future<void> _runPipeline(String goal, {BotTask? existing}) async {
    setState(() {
      _running = true;
      _liveLog.clear();
      _previewHtml = null;
    });

    final task = existing ??
        BotTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          goal: goal,
          status: 'running',
          logs: [],
          createdAt: DateTime.now(),
        );
    task.status = 'running';

    void push(String s) {
      _log(s);
      task.logs.add(s);
    }

    push('Nimbus: starting long-run job…');
    push('Goal: $goal');

    // 1) Atlas plans
    push('Atlas: planning…');
    final plan = await Ai.agentChat(
      agentId: 'atlas',
      messages: [
        {'role': 'user', 'content': 'Plan this goal in 4–8 steps:\n$goal'},
      ],
    );
    push('Atlas:\n$plan');

    // 2) Pulse may request search
    push('Pulse: checking if web research is needed…');
    final pulse = await Ai.agentChat(
      agentId: 'pulse',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal: $goal\nPlan:\n$plan\nIf you need the web, reply with lines SEARCH: query or OPEN: url. Else say NONE.'
        },
      ],
    );
    push('Pulse:\n$pulse');

    var browserContext = '';
    for (final line in pulse.split('\n')) {
      final t = line.trim();
      if (t.toUpperCase().startsWith('SEARCH:')) {
        final q = t.substring(7).trim();
        push('Pulse: searching “$q”…');
        final r = await BrowserTool.search(q);
        browserContext += '\n$r\n';
        push('Browser: $r');
      } else if (t.toUpperCase().startsWith('OPEN:')) {
        final u = t.substring(5).trim();
        push('Pulse: opening $u…');
        final r = await BrowserTool.openUrl(u);
        browserContext += '\n$u => $r\n';
        push('Browser: opened $u (${r.length} chars)');
      }
    }

    // 3) Mira researches with browser context
    push('Mira: synthesizing research…');
    final research = await Ai.agentChat(
      agentId: 'mira',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal: $goal\nPlan:\n$plan\nBROWSER RESULTS:\n$browserContext\nWrite a clear research brief.'
        },
      ],
    );
    push('Mira:\n$research');

    // 4) Nova codes if useful
    push('Nova: producing deliverable…');
    final code = await Ai.agentChat(
      agentId: 'nova',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal: $goal\nResearch:\n$research\nIf a web UI helps, output a full single HTML file in a ```html block. Otherwise code/docs as needed.'
        },
      ],
    );
    push('Nova:\n$code');

    // Extract HTML for sandbox
    final htmlMatch =
        RegExp(r'```html\s*([\s\S]*?)```', caseSensitive: false).firstMatch(code);
    if (htmlMatch != null) {
      final html = htmlMatch.group(1)!.trim();
      task.previewHtml = html;
      setState(() {
        _previewHtml = html;
        _web = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(html);
      });
      push('Sandbox: HTML preview ready');
      _tabs.animateTo(1);
    }

    // 5) Nimbus final summary
    push('Nimbus: wrapping up…');
    final summary = await Ai.agentChat(
      agentId: 'nimbus',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal: $goal\nPlan:\n$plan\nResearch:\n$research\nDeliverable:\n$code\nWrite a short status for the user.'
        },
      ],
    );
    push('Nimbus:\n$summary');

    task.status = 'done';
    await BotTaskStore.update(task);
    await _reloadTasks();
    setState(() => _running = false);
    push('✓ Job finished (saved on device — resumes if you reopen the app).');
  }

  @override
  void dispose() {
    _goal.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        backgroundColor: Jx.bg,
        title: const Text('JagX Bot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Jx.accent,
          labelColor: Jx.text,
          unselectedLabelColor: Jx.muted,
          tabs: const [
            Tab(text: 'Agents'),
            Tab(text: 'Sandbox'),
            Tab(text: 'Jobs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Agent strip
          SizedBox(
            height: 72,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: Agents.list
                  .map((a) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Jx.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Jx.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(a.name,
                                style: const TextStyle(
                                    color: Jx.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            Text(a.role,
                                style: const TextStyle(
                                    color: Jx.muted, fontSize: 11)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Live log
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_liveLog.isEmpty)
                      const Text(
                        'Give JagX Bot a long-term goal. Atlas plans, Pulse browses, Mira researches, Nova builds, Nimbus summarizes — each on its own free model.\n\nJobs are saved on this device and continue when you reopen the app.',
                        style: TextStyle(color: Jx.muted, height: 1.45),
                      ),
                    ..._liveLog.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SelectableText(l,
                              style: const TextStyle(
                                  color: Jx.text, fontSize: 13, height: 1.4)),
                        )),
                    if (_running)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(
                          color: Jx.accent,
                          backgroundColor: Jx.border,
                        ),
                      ),
                  ],
                ),
                // Sandbox
                _previewHtml == null || _web == null
                    ? const Center(
                        child: Text(
                          'Sandbox preview appears when Nova outputs HTML.',
                          style: TextStyle(color: Jx.muted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : WebViewWidget(controller: _web!),
                // Jobs
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _tasks.length,
                  itemBuilder: (_, i) {
                    final t = _tasks[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Jx.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Jx.border),
                      ),
                      child: ListTile(
                        title: Text(t.goal,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Jx.text)),
                        subtitle: Text(t.status,
                            style: const TextStyle(color: Jx.muted)),
                        trailing: t.status == 'queued' || t.status == 'running'
                            ? TextButton(
                                onPressed: _running
                                    ? null
                                    : () => _runPipeline(t.goal, existing: t),
                                child: const Text('Resume'),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _liveLog
                              ..clear()
                              ..addAll(t.logs);
                            if (t.previewHtml != null) {
                              _previewHtml = t.previewHtml;
                              _web = WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadHtmlString(t.previewHtml!);
                            }
                          });
                          _tabs.animateTo(0);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _goal,
                      style: const TextStyle(color: Jx.text),
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Long-term goal for JagX Bot…',
                        hintStyle: const TextStyle(color: Jx.dim),
                        filled: true,
                        fillColor: Jx.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _start(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _running ? null : _start,
                    style: IconButton.styleFrom(
                      backgroundColor: Jx.accent,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
