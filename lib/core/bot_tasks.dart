import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'env.dart';

class BotTask {
  BotTask({
    required this.id,
    required this.goal,
    required this.status,
    required this.logs,
    this.result,
    this.previewHtml,
    this.createdAt,
    this.serverSide = false,
  });

  final String id;
  final String goal;
  String status;
  final List<String> logs;
  String? result;
  String? previewHtml;
  final DateTime? createdAt;
  final bool serverSide;

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'status': status,
        'logs': logs,
        'result': result,
        'previewHtml': previewHtml,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
        'serverSide': serverSide,
      };

  static BotTask fromJson(Map<String, dynamic> j) => BotTask(
        id: j['id'] as String? ?? const Uuid().v4(),
        goal: j['goal'] as String? ?? '',
        status: j['status'] as String? ?? 'queued',
        logs: (j['logs'] as List?)?.map((e) => e.toString()).toList() ?? [],
        result: j['result'] as String?,
        previewHtml: j['previewHtml'] as String?,
        createdAt: DateTime.tryParse(
            j['created_at'] as String? ?? j['createdAt'] as String? ?? ''),
        serverSide: j['serverSide'] == true,
      );

  static BotTask fromServer(Map<String, dynamic> j) => BotTask(
        id: j['id']?.toString() ?? const Uuid().v4(),
        goal: j['goal']?.toString() ?? '',
        status: j['status']?.toString() ?? 'queued',
        logs: (j['logs'] as List?)?.map((e) => e.toString()).toList() ?? [],
        result: j['result']?.toString(),
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? ''),
        serverSide: true,
      );
}

class BotTaskStore {
  static const _key = 'jx_bot_tasks';
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(seconds: 40),
  ));

  static String get _base {
    final b = Env.jagxApiBase.isEmpty
        ? 'https://jagx-ai-v2.onrender.com'
        : Env.jagxApiBase.replaceAll(RegExp(r'/+\$'), '');
    return b;
  }

  static Future<String> userId() async {
    final p = await SharedPreferences.getInstance();
    var id = p.getString('jx_user_id');
    if (id == null || id.isEmpty) {
      id = 'u_${const Uuid().v4().substring(0, 8)}';
      await p.setString('jx_user_id', id);
    }
    return id;
  }

  static Map<String, dynamic> _headers() {
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    final key = Env.jagxApiKey.trim();
    if (key.isNotEmpty) headers['x-api-key'] = key;
    return headers;
  }

  static Future<List<BotTask>> allLocal() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => BotTask.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<BotTask> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _key, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  /// Prefer server queue so work continues after the app is closed.
  static Future<BotTask> enqueue(String goal) async {
    final uid = await userId();
    try {
      final res = await _dio.post(
        '$_base/jobs',
        options: Options(
          headers: _headers(),
          validateStatus: (s) => s != null && s < 500,
        ),
        data: {'goal': goal, 'user_id': uid},
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        if (data['ok'] == true && data['job'] is Map) {
          final t =
              BotTask.fromServer(Map<String, dynamic>.from(data['job'] as Map));
          final local = await allLocal();
          local.insert(0, t);
          await save(local);
          return t;
        }
      }
    } catch (_) {}

    final tasks = await allLocal();
    final t = BotTask(
      id: const Uuid().v4(),
      goal: goal,
      status: 'queued',
      logs: ['Queued on device (server offline)'],
      createdAt: DateTime.now(),
    );
    tasks.insert(0, t);
    await save(tasks);
    return t;
  }

  static Future<BotTask?> refreshFromServer(String id) async {
    try {
      final res = await _dio.get(
        '$_base/jobs/$id',
        options: Options(
          headers: _headers(),
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        if (data['ok'] == true && data['job'] is Map) {
          final t =
              BotTask.fromServer(Map<String, dynamic>.from(data['job'] as Map));
          final local = await allLocal();
          final i = local.indexWhere((x) => x.id == t.id);
          if (i >= 0) {
            local[i] = t;
          } else {
            local.insert(0, t);
          }
          await save(local);
          return t;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<List<BotTask>> all() async {
    final uid = await userId();
    try {
      final res = await _dio.get(
        '$_base/jobs',
        queryParameters: {'user_id': uid, 'limit': 40},
        options: Options(
          headers: _headers(),
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (res.statusCode == 200 && res.data is Map) {
        final list = (res.data as Map)['jobs'];
        if (list is List && list.isNotEmpty) {
          final remote = list
              .whereType<Map>()
              .map((e) => BotTask.fromServer(Map<String, dynamic>.from(e)))
              .toList();
          await save(remote);
          return remote;
        }
      }
    } catch (_) {}
    return allLocal();
  }

  static Future<void> update(BotTask t) async {
    final tasks = await allLocal();
    final i = tasks.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      tasks[i] = t;
    } else {
      tasks.insert(0, t);
    }
    await save(tasks);
  }
}
