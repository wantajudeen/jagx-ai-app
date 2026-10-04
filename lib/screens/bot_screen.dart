import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/agents.dart';
import '../core/ai.dart';
import '../core/bot_tasks.dart';
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
  bool _multi = true;
  List<BotTask> _tasks = [];
  String? _result;
  Agent _agent = Agents.list.first;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _reloadTasks();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _goal.dispose();
    super.dispose();
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
    setState(() {
      _running = true;
      _liveLog.clear();
      _result = null;
    });

    _log('Sending goal to JagX server…');
    final task = await BotTaskStore.enqueue(goal);
    await _reloadTasks();

    if (task.serverSide) {
      _log('Server job ${task.id.substring(0, 8)}…');
      _log('Safe to close the app — work continues on server');
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(seconds: 4), (_) => _pollJob(task.id));
      await _pollJob(task.id);
      return;
    }

    // Local fallback if /jobs is down
    _log('Server offline — running on device');
    try {
      final reply = await Ai.multiAgentRun(goal: goal, onLog: _log);
      task.status = 'done';
      task.result = reply;
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
    } catch (e) {
      _log('Failed: $e');
      if (mounted) setState(() => _running = false);
    }
    await _reloadTasks();
  }

  Future<void> _pollJob(String id) async {
    final t = await BotTaskStore.refreshFromServer(id);
    if (t == null || !mounted) return;
    setState(() {
      _liveLog
        ..clear()
        ..addAll(t.logs);
      if (t.result != null && t.result!.isNotEmpty) _result = t.result;
    });
    await _reloadTasks();
    if (t.status == 'done' || t.status == 'failed') {
      _poll?.cancel();
      if (mounted) setState(() => _running = false);
    }
  }

  void _openTask(BotTask t) async {
    setState(() {
      _liveLog
        ..clear()
        ..addAll(t.logs);
      _result = t.result;
    });
    if (t.serverSide && (t.status == 'queued' || t.status == 'running')) {
      setState(() => _running = true);
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(seconds: 4), (_) => _pollJob(t.id));
      await _pollJob(t.id);
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
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('JagX Bot',
                  style: TextStyle(
                      color: Jx.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Goals run on the server. Close the app anytime; reopen Bot to see progress. Uses tools, plan steps, optional GitHub, and self-learn.',
                style: TextStyle(color: Jx.dim, fontSize: 12, height: 1.4),
              ),
            ),
            SwitchListTile(
              title: const Text('Multi-agent style',
                  style: TextStyle(color: Jx.text)),
              value: _multi,
              activeColor: Jx.text,
              onChanged: (v) => setState(() => _multi = v),
            ),
            ...Agents.list.map((a) {
              final sel = a.id == _agent.id && !_multi;
              return ListTile(
                leading: Text(a.emoji, style: const TextStyle(fontSize: 22)),
                title: Text('${a.name} · ${a.role}',
                    style: const TextStyle(
                        color: Jx.text, fontWeight: FontWeight.w600)),
                trailing:
                    sel ? const Icon(Icons.check, color: Jx.text) : null,
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
          IconButton(
            tooltip: 'Refresh jobs',
            onPressed: _reloadTasks,
            icon: const Icon(Icons.refresh),
          ),
          TextButton(
            onPressed: _pickAgent,
            child: Text(
              _multi ? '🧠 Server bot' : '${_agent.emoji} ${_agent.name}',
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Like Grok Bot',
                          style: TextStyle(
                              color: Jx.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      SizedBox(height: 6),
                      Text(
                        'Work runs on the JagX server. You can close the app. Reopen to see results. Sandbox can import GitHub files, run code, and export back when a token is in Vault.',
                        style: TextStyle(
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
                  const Text('Your jobs',
                      style: TextStyle(
                          color: Jx.text, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._tasks.take(12).map(
                        (t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => _openTask(t),
                          title: Text(t.goal,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Jx.text, fontSize: 13)),
                          subtitle: Text(
                            '${t.status}${t.serverSide ? ' · server' : ' · device'}',
                            style: const TextStyle(
                                color: Jx.dim, fontSize: 11),
                          ),
                          trailing: Icon(
                            t.status == 'done'
                                ? Icons.check_circle_outline
                                : t.status == 'running'
                                    ? Icons.hourglass_top
                                    : Icons.schedule,
                            color: Jx.dim,
                            size: 18,
                          ),
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
                          hintText: 'Bot goal (runs on server)…',
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
