import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/agents.dart';
import '../core/ai.dart';
import '../core/bot_tasks.dart';
import '../core/browser_tool.dart';
import '../core/theme.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final _goal = TextEditingController();
  final List<String> _liveLog = [];
  bool _running = false;
  bool _multi = true; // multi-agent like Grok Bot by default
  List<BotTask> _tasks = [];
  String? _result;
  Agent _agent = Agents.list.first;

  @override
  void initState() {
    super.initState();
    _reloadTasks();
  }

  Future<void> _reloadTasks() async {
    final t = await BotTaskStore.all();
    if (mounted) setState(() => _tasks = t);
  }

  void _log(String line) {
    if (!mounted) return;
    setState(() => _liveLog.add(line));
  }

  Future<void> _start() async {
    final goal = _goal.text.trim();
    if (goal.isEmpty || _running) return;
    _goal.clear();
    final task = await BotTaskStore.enqueue(goal);
    await _reloadTasks();
    await _run(goal, existing: task);
  }

  Future<void> _run(String goal, {BotTask? existing}) async {
    setState(() {
      _running = true;
      _liveLog.clear();
      _result = null;
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
    await BotTaskStore.update(task);

    try {
      String research = '';
      try {
        _log('Pulse · web context…');
        research = await BrowserTool.search(goal);
        if (research.isNotEmpty) _log('Web context ready');
      } catch (_) {
        _log('Web skipped');
      }

      String reply;
      if (_multi || _agent.id == 'nimbus') {
        reply = await Ai.multiAgentRun(
          goal: goal,
          webContext: research,
          onLog: _log,
        );
      } else {
        _log('${_agent.emoji} ${_agent.name} · ${_agent.role}');
        final prompt = research.isEmpty
            ? goal
            : '$goal\n\nWEB CONTEXT:\n$research';
        reply = await Ai.agentChat(
          agentId: _agent.id,
          messages: [
            {'role': 'user', 'content': prompt}
          ],
        );
        _log('Done');
      }

      task.status = 'done';
      task.logs
        ..clear()
        ..addAll(_liveLog);
      await BotTaskStore.update(task);

      if (mounted) {
        setState(() {
          _result = reply;
          _running = false;
        });
      }
      await _reloadTasks();
    } catch (e) {
      task.status = 'failed';
      await BotTaskStore.update(task);
      _log('Failed: $e');
      if (mounted) setState(() => _running = false);
    }
  }

  void _pickAgent() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Jx.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('JagX Bot agents',
                  style: TextStyle(
                      color: Jx.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
            ),
            SwitchListTile(
              title: const Text('Multi-agent team',
                  style: TextStyle(color: Jx.text)),
              subtitle: const Text(
                  'Nimbus → Atlas → Nova → Mira → final answer',
                  style: TextStyle(color: Jx.dim, fontSize: 12)),
              value: _multi,
              activeColor: Jx.text,
              onChanged: (v) => setState(() => _multi = v),
            ),
            const Divider(color: Jx.border),
            ...Agents.list.map((a) {
              final sel = a.id == _agent.id && !_multi;
              return ListTile(
                leading: Text(a.emoji, style: const TextStyle(fontSize: 22)),
                title: Text('${a.name} · ${a.role}',
                    style: const TextStyle(
                        color: Jx.text, fontWeight: FontWeight.w600)),
                subtitle: Text(a.description,
                    style: const TextStyle(color: Jx.dim, fontSize: 12)),
                trailing: sel
                    ? const Icon(Icons.check, color: Jx.text)
                    : null,
                onTap: () {
                  setState(() {
                    _agent = a;
                    _multi = a.id == 'nimbus';
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(
        title: const Text('JagX Bot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _pickAgent,
            child: Text(
              _multi
                  ? '🧠 Multi-agent'
                  : '${_agent.emoji} ${_agent.name}',
              style: const TextStyle(color: Jx.text),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Jx.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Jx.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _multi
                            ? '🧠 Multi-agent team'
                            : '${_agent.emoji} ${_agent.name} · ${_agent.role}',
                        style: const TextStyle(
                            color: Jx.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _multi
                            ? 'Like Grok Bot: Nimbus leads Atlas (plan), Nova (code), Mira (research), then merges one answer. Uses OpenRouter when configured.'
                            : _agent.description,
                        style: const TextStyle(
                            color: Jx.muted, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_liveLog.isNotEmpty) ...[
                  const Text('Activity',
                      style: TextStyle(
                          color: Jx.text, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._liveLog.map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $l',
                          style: const TextStyle(
                              color: Jx.muted, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_result != null) ...[
                  const Text('Result',
                      style: TextStyle(
                          color: Jx.text, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SelectableText(
                    _result!,
                    style: const TextStyle(
                        color: Jx.text, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_tasks.isNotEmpty) ...[
                  const Text('Recent tasks',
                      style: TextStyle(
                          color: Jx.text, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._tasks.take(8).map(
                        (t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.goal,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Jx.text, fontSize: 13)),
                          subtitle: Text(t.status,
                              style: const TextStyle(
                                  color: Jx.dim, fontSize: 11)),
                        ),
                      ),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Jx.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goal,
                        style: const TextStyle(color: Jx.text),
                        decoration: const InputDecoration(
                          hintText: 'Bot goal…',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _start(),
                      ),
                    ),
                    IconButton(
                      onPressed: _running ? null : _start,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: _running ? Jx.dim : Jx.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
