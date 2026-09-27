import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/agents.dart';
import '../core/ai.dart';
import '../core/bot_tasks.dart';
import '../core/browser_tool.dart';
import '../core/theme.dart';

/// JagX Bot — multi-agent goals without WebView (APK-safe).
class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final _goal = TextEditingController();
  final List<String> _liveLog = [];
  bool _running = false;
  List<BotTask> _tasks = [];
  String? _result;

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
    await _runPipeline(goal, existing: task);
  }

  Future<void> _runPipeline(String goal, {BotTask? existing}) async {
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
      _log('Planning…');
      final agent = Agents.list.isNotEmpty ? Agents.list.first : null;
      final agentId = agent?.id;

      _log('Research (optional)…');
      String research = '';
      try {
        research = await BrowserTool.search(goal);
        if (research.isNotEmpty) _log('Research notes ready');
      } catch (_) {
        _log('Research skipped');
      }

      _log('Asking JagX…');
      final prompt = research.isEmpty
          ? goal
          : '$goal\n\nContext:\n$research';

      final reply = agentId == null
          ? await Ai.chat(
              modelId: 'forge',
              messages: [
                {'role': 'user', 'content': prompt},
              ],
            )
          : await Ai.agentChat(
              agentId: agentId,
              messages: [
                {'role': 'user', 'content': prompt},
              ],
            );

      task.status = 'done';
      task.logs
        ..clear()
        ..addAll(_liveLog)
        ..add('Done');
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
        backgroundColor: Jx.bg,
        title: const Text('JagX Bot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Describe a goal. Bot plans, researches, and answers.',
                  style: TextStyle(color: Jx.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
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
                        color: Jx.text, fontSize: 14, height: 1.45),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _goal,
                      style: const TextStyle(color: Jx.text),
                      decoration: const InputDecoration(
                        hintText: 'Bot goal…',
                      ),
                      onSubmitted: (_) => _start(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _running ? null : _start,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      color: _running ? Jx.dim : Jx.accent,
                    ),
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
