import 'package:dio/dio.dart';

import 'agents.dart';
import 'env.dart';

class Ai {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static const _baseSystem = '''
You are JagX AI by JagX & JRILICENSE — Africa-first multipurpose intelligence.
Never name OpenAI, Claude, GPT, Grok, xAI, Llama, Gemini, DeepSeek, Qwen, or other AI brands.
Identity: only JagX AI by JagX & JRILICENSE.
Be clear, useful, strong at code and African context (Naira, Nigeria, Pidgin when appropriate).
Multilingual: reply in the user's language.
Finance: education and analysis only; always include risk warnings. No live trading claims.
If the user asks to generate or draw an image, reply with a short caption and a line starting with IMAGE_PROMPT:
''';

  static String _model(String id) {
    switch (id) {
      case 'jagx-0.3':
        return 'meta-llama/llama-3.3-8b-instruct:free';
      case 'jagx-0.4':
        return 'qwen/qwen3-32b:free';
      case 'forge':
        return 'nvidia/llama-3.3-nemotron-super-49b-v1:free';
      default:
        return 'openrouter/free';
    }
  }

  static Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    if (modelId == 'oracle') {
      return 'Oracle is **Coming soon**. Use Forge, JagX 0.4, or open **JagX Bot**.';
    }

    // 1) Prefer JagX backend on Render
    final jagx = await _jagxChat(messages: messages, agentId: agentId);
    if (jagx != null) return jagx;

    // 2) Fallback OpenRouter free models
    final key = Env.openRouterKey;
    if (key.isEmpty) {
      return 'No AI key configured. Set JAGX_API_KEY (Render backend) or OPENROUTER_API_KEY in GitHub Secrets and rebuild the APK.';
    }

    var system = _baseSystem;
    var model = _model(modelId);

    if (agentId != null) {
      final a = Agents.byId(agentId);
      system = '$_baseSystem\n\nActive agent: **${a.name}** (${a.role}).\n${a.systemHint}';
      model = a.openRouterModel;
    }

    return _openRouter(
      key: key,
      model: model,
      system: system,
      messages: messages,
    );
  }

  static Future<String> agentChat({
    required String agentId,
    required List<Map<String, String>> messages,
  }) async {
    final jagx = await _jagxChat(messages: messages, agentId: agentId);
    if (jagx != null) return jagx;

    final key = Env.openRouterKey;
    if (key.isEmpty) {
      return 'No AI key configured. Set JAGX_API_KEY or OPENROUTER_API_KEY and rebuild.';
    }
    final a = Agents.byId(agentId);
    final system =
        '$_baseSystem\n\nYou are **${a.name}** (${a.role}) of JagX Bot.\n${a.systemHint}';
    return _openRouter(
      key: key,
      model: a.openRouterModel,
      system: system,
      messages: messages,
    );
  }

  /// Calls https://jagx-ai-v2.onrender.com/chat with permanent x-api-key
  static Future<String?> _jagxChat({
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    final base = Env.jagxApiBase;
    final key = Env.jagxApiKey;
    if (base.isEmpty || key.isEmpty) return null;

    final lastUser = messages.reversed
        .firstWhere((m) => m['role'] == 'user', orElse: () => <String, String>{});
    final text = (lastUser['content'] ?? '').toString();
    if (text.isEmpty) return null;

    try {
      final history = messages
          .where((m) => m['role'] == 'user' || m['role'] == 'assistant')
          .map((m) => {'role': m['role']!, 'content': m['content'] ?? ''})
          .toList();
      if (history.isNotEmpty && history.last['role'] == 'user') {
        history.removeLast();
      }

      final res = await _dio.post(
        '$base/chat',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'x-api-key': key,
        }),
        data: {
          'message': text,
          if (history.isNotEmpty) 'history': history,
        },
      );
      final data = res.data;
      if (data is Map && data['response'] != null) {
        return data['response'].toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String> _openRouter({
    required String key,
    required String model,
    required String system,
    required List<Map<String, String>> messages,
  }) async {
    try {
      final res = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $key',
          'HTTP-Referer': 'https://jagxai.name.ng',
          'X-Title': 'JagX AI',
          'Content-Type': 'application/json',
        }),
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

      final choices = res.data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices[0]['message'];
        final content = msg?['content']?.toString();
        if (content != null && content.trim().isNotEmpty) return content;
      }
      return 'JagX returned an empty reply. Try again.';
    } on DioException catch (e) {
      final body = e.response?.data?.toString() ?? e.message ?? '';
      if (body.contains('401') || body.contains('Unauthorized')) {
        return 'API key rejected. Check keys in secrets and rebuild.';
      }
      if (body.contains('rate') || (e.response?.statusCode == 429)) {
        return 'Rate limit. Wait a moment and try again.';
      }
      return 'JagX could not reach the model. (${e.response?.statusCode ?? 'network'})';
    } catch (_) {
      return 'JagX is temporarily unavailable. Try again.';
    }
  }

  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';
  }
}
