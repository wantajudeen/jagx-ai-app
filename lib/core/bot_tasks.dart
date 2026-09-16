import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Persisted long-running Bot jobs. Resume when the app is opened again.
/// (True 24/7 when the app is force-killed needs a server worker later.)
class BotTask {
  BotTask({
    required this.id,
    required this.goal,
    required this.status,
    required this.logs,
    this.previewHtml,
    this.createdAt,
  });

  final String id;
  final String goal;
  String status; // queued | running | done | paused
  final List<String> logs;
  String? previewHtml;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'status': status,
        'logs': logs,
        'previewHtml': previewHtml,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  static BotTask fromJson(Map<String, dynamic> j) => BotTask(
        id: j['id'] as String,
        goal: j['goal'] as String,
        status: j['status'] as String? ?? 'queued',
        logs: (j['logs'] as List?)?.map((e) => e.toString()).toList() ?? [],
        previewHtml: j['previewHtml'] as String?,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
      );
}

class BotTaskStore {
  static const _key = 'jx_bot_tasks';

  static Future<List<BotTask>> all() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => BotTask.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<BotTask> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _key, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  static Future<BotTask> enqueue(String goal) async {
    final tasks = await all();
    final t = BotTask(
      id: const Uuid().v4(),
      goal: goal,
      status: 'queued',
      logs: ['Queued: $goal'],
      createdAt: DateTime.now(),
    );
    tasks.insert(0, t);
    await save(tasks);
    return t;
  }

  static Future<void> update(BotTask t) async {
    final tasks = await all();
    final i = tasks.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      tasks[i] = t;
    } else {
      tasks.insert(0, t);
    }
    await save(tasks);
  }
}
