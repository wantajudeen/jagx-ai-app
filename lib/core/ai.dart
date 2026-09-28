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
You are JagX AI by JagX and JRILICENSE.
Write like a clear human tutor. Short sentences when possible.

FORMATTING RULES (important):
- Do NOT use markdown bold with asterisks (**like this**).
- Do NOT wrap every heading in # or **.
- For math: write steps in plain text. Example: Step 1: ... then the equation on its own line.
- Prefer plain numbers and words over heavy symbols decoration.
- Lists can use simple dashes or numbers: 1. 2. 3.
- Never mention other AI brands. You are only JagX AI.

When the user asks for a story, book chapter, essay, or PDF-ready text, write complete clean content they can export.
Reply in the user's language.
''';

  static const _orModels = [
    'openai/gpt-oss-20b:free',
    'google/gemma-3n-e4b-it:free',
    'qwen/qwen3-8b:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'openrouter/auto',
  ];

  static String cleanOutput(String text) {
    var t = text;
    // strip common AI markdown bold/italic noise
    t = t.replaceAllMapped(
        RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(
        RegExp(r'(?<![\w*])\*([^*\n]+)\*(?![\w*])'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(RegExp(r'^#{1,6}\s+', multiLine: true), (m) => '');
    return t.trim();
  }

  static Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    if (modelId == 'oracle') {
      return 'Oracle is Coming soon. Use Forge or JagX Bot.';
    }

    final jagx = await _jagxChat(messages: messages);
    if (jagx != null && jagx.trim().isNotEmpty) return cleanOutput(jagx);

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
      if (or != null) return cleanOutput(or);
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
            'max_tokens': 2048,
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
      return 'Hi. I am JagX AI, built by JagX and JRILICENSE. How can I help?';
    }
    if (t.contains('who are you')) {
      return 'I am JagX AI, created by JagX and JRILICENSE.';
    }
    return 'The model is waking up. Try again in a moment.';
  }

  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';
  }
}
