import 'package:dio/dio.dart';

import 'bot_tasks.dart';
import 'env.dart';

/// Client for JagX server sandbox (run / files / network / GitHub).
class SandboxApi {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static String get _base {
    final b = Env.jagxApiBase.isEmpty
        ? 'https://jagx-ai-v2.onrender.com'
        : Env.jagxApiBase.replaceAll(RegExp(r'/+\$'), '');
    return b;
  }

  static Map<String, dynamic> _headers() {
    final h = <String, dynamic>{'Content-Type': 'application/json'};
    final key = Env.jagxApiKey.trim();
    if (key.isNotEmpty) h['x-api-key'] = key;
    return h;
  }

  static Future<Map<String, dynamic>> run(String code, {String filename = 'main.py'}) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/sandbox/run',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {'user_id': uid, 'code': code, 'filename': filename},
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'run failed'};
  }

  static Future<Map<String, dynamic>> writeFile(String path, String content) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/sandbox/write',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {'user_id': uid, 'path': path, 'content': content},
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'write failed'};
  }

  static Future<Map<String, dynamic>> readFile(String path) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/sandbox/read',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {'user_id': uid, 'path': path},
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'read failed'};
  }

  static Future<Map<String, dynamic>> fetch(String url) async {
    try {
      final res = await _dio.post(
        '$_base/sandbox/fetch',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {'url': url},
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'fetch failed'};
  }

  static Future<Map<String, dynamic>> githubImport({
    required String repo,
    required String path,
    String? token,
  }) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/sandbox/github_import',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {
          'user_id': uid,
          'repo': repo,
          'path': path,
          if (token != null && token.isNotEmpty) 'token': token,
        },
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'import failed'};
  }

  static Future<Map<String, dynamic>> githubExport({
    required String repo,
    required String path,
    String? localPath,
    String? message,
    String? token,
  }) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/sandbox/github_export',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {
          'user_id': uid,
          'repo': repo,
          'path': path,
          'local_path': localPath ?? path,
          'message': message ?? 'JagX export',
          if (token != null && token.isNotEmpty) 'token': token,
        },
      );
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
    return {'ok': false, 'error': 'export failed'};
  }

  /// Save GitHub token to server vault (value never returned later).
  static Future<bool> saveGithubToken(String token) async {
    final uid = await BotTaskStore.userId();
    try {
      final res = await _dio.post(
        '$_base/vault',
        options: Options(headers: _headers(), validateStatus: (s) => s != null && s < 500),
        data: {'user_id': uid, 'key': 'github', 'value': token},
      );
      return res.statusCode == 200 && res.data is Map && (res.data as Map)['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
