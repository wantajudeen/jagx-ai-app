import 'package:dio/dio.dart';

import 'agents.dart';
import 'env.dart';

class Ai {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 90),
    sendTimeout: const Duration(seconds: 45),
  ));

  static const _baseSystem = '''
You are JagX AI by JagX & JRILICENSE.
Be clear and useful. Reply in the user's language.
Never name other AI brands. You are only JagX AI.
''';

  static const _orModels = [
    'openai/gpt-oss-20b:free',
    'google/gemma-3n-e4b-it:free',
    'qwen/qwen3-8b:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'openrouter/auto',
  ];

  static Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    if (modelId == 'oracle') {
      return 'Oracle is Coming soon. Use Forge, JagX 0.4, or JagX Bot.';
    }

    final jagx = await _jagxChat(messages: messages);
    if (jagx != null && jagx.trim().isNotEmpty) return jagx;

    final key = Env.openRouterKey.trim();
    if (key.isNotEmpty) {
      var system = _baseSystem;
      if (agentId != null) {
        final a = Agents.byId(agentId);
        system =
            '$_baseSystem\n\nActive agent: ${a.name} (${a.role}).\n${a.systemHint}';
      }
      final or = await _openRouter(
        key: key,
        system: system,
        messages: messages,
      );
      if (or != null) return or;
    }

    return _localFallback(messages);
  }

  static Future<String> agentChat({
    required String agentId,
    required List<Map<String, String>> messages,
  }) async {
    return chat(modelId: 'forge', messages: messages, agentId: agentId);
  }

  static Future<String?> _jagxChat({
    required List<Map<String, String>> messages,
  }) async {
    final base = Env.jagxApiBase.isEmpty
        ? 'https://jagx-ai-v2.onrender.com'
        : Env.jagxApiBase.replaceAll(RegExp(r'/+\$'), '');
    final key = Env.jagxApiKey.trim();

    final lastUser = messages.reversed.firstWhere(
      (m) => m['role'] == 'user',
      orElse: () => <String, String>{},
    );
    final text = (lastUser['content'] ?? '').toString().trim();
    if (text.isEmpty) return null;

    final history = <Map<String, String>>[];
    for (final m in messages) {
      final role = m['role'];
      final content = m['content'] ?? '';
      if (role == 'user' || role == 'assistant') {
        history.add({'role': role!, 'content': content});
      }
    }
    if (history.isNotEmpty && history.last['role'] == 'user') {
      history.removeLast();
    }

    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    if (key.isNotEmpty) headers['x-api-key'] = key;

    // Wake + retry (Render free tier sleeps).
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final res = await _dio.post(
          '$base/chat',
          options: Options(
            headers: headers,
            validateStatus: (s) => s != null && s < 500,
          ),
          data: {
            'message': text,
            if (history.isNotEmpty) 'history': history,
          },
        );
        if (res.statusCode == 200) {
          final data = res.data;
          if (data is Map && data['response'] != null) {
            final out = data['response'].toString().trim();
            if (out.isNotEmpty) return out;
          }
        }
        // 401 without key — no point retrying the same call.
        if (res.statusCode == 401 && key.isEmpty) return null;
        if (res.statusCode == 401) return null;
      } on DioException {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: 2 + attempt * 2));
          continue;
        }
      } catch (_) {
        break;
      }
    }
    return null;
  }

  static Future<String?> _openRouter({
    required String key,
    required String system,
    required List<Map<String, String>> messages,
  }) async {
    for (final model in _orModels) {
      try {
        final res = await _dio.post(
          'https://openrouter.ai/api/v1/chat/completions',
          options: Options(
            headers: {
              'Authorization': 'Bearer $key',
              'HTTP-Referer': 'https://jagxai.name.ng',
              'X-Title': 'JagX AI',
              'Content-Type': 'application/json',
            },
            validateStatus: (s) => s != null && s < 500,
          ),
          data: {
            'model': model,
            'messages': [
              {'role': 'system', 'content': system},
              ...messages,
            ],
            'temperature': 0.35,
            'max_tokens': 1024,
          },
        );
        if (res.statusCode == 200) {
          final choices = res.data['choices'];
          if (choices is List && choices.isNotEmpty) {
            final content = choices[0]['message']?['content']?.toString();
            if (content != null && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static String _localFallback(List<Map<String, String>> messages) {
    final last = messages.reversed
        .firstWhere((m) => m['role'] == 'user', orElse: () => {'content': ''});
    final t = (last['content'] ?? '').toLowerCase().trim();
    if (t.isEmpty) return 'Say something and I will answer.';
    if (RegExp(r'^(hi|hello|hey|yo|sup)\b').hasMatch(t)) {
      return 'Hi — I am JagX AI, built by JagX and JRILICENSE. How can I help?';
    }
    if (t.contains('who are you')) {
      return 'I am JagX AI, created by JagX and JRILICENSE.';
    }
    return 'The cloud model is waking up or the app is missing JAGX_API_KEY. '
        'Add JAGX_API_KEY in GitHub Secrets (a key from your Render /create-key), '
        'rebuild the APK, and try again. On Render you can also set JAGX_ALLOW_PUBLIC_CHAT=true.';
  }

  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';
  }
}
