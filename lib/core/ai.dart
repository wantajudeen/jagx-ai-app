import 'package:dio/dio.dart';

import 'agents.dart';
import 'env.dart';

class Ai {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 180),
  ));

  static const _baseSystem = '''
You are JagX AI by JagX & JRILICENSE — Africa-first multipurpose intelligence.
Never name OpenAI, Claude, GPT, Grok, xAI, Llama, Gemini, DeepSeek, Qwen, or other AI brands.
Identity: only JagX AI by JagX & JRILICENSE.
Be clear, useful, strong at code and African context (Naira, Nigeria, Pidgin when appropriate).
Finance: education and analysis only; always include risk warnings. No live trading claims.
If the user asks to generate or draw an image, reply with a short caption and a line starting with IMAGE_PROMPT:
''';

  /// FREE OpenRouter models only for Ask / Build
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

    final key = Env.openRouterKey;
    if (key.isEmpty) {
      return 'OpenRouter key missing. Add OPENROUTER_API_KEY to GitHub Secrets and rebuild the APK.';
    }

    var system = _baseSystem;
    var model = _model(modelId);

    if (agentId != null) {
      final a = Agents.byId(agentId);
      system = '$_baseSystem\n\nActive agent: **${a.name}** (${a.role}).\n${a.systemHint}';
      model = a.openRouterModel;
    }

    return _complete(key: key, model: model, system: system, messages: messages);
  }

  /// Call a specific Bot agent by id (always free model).
  static Future<String> agentChat({
    required String agentId,
    required List<Map<String, String>> messages,
  }) async {
    final key = Env.openRouterKey;
    if (key.isEmpty) {
      return 'OpenRouter key missing. Add OPENROUTER_API_KEY and rebuild.';
    }
    final a = Agents.byId(agentId);
    final system =
        '$_baseSystem\n\nYou are **${a.name}** (${a.role}) of JagX Bot.\n${a.systemHint}';
    return _complete(
      key: key,
      model: a.openRouterModel,
      system: system,
      messages: messages,
    );
  }

  static Future<String> _complete({
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
          'max_tokens': 8192,
        },
      );

      final choices = res.data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices[0]['message'];
        final content = msg?['content']?.toString();
        if (content != null && content.trim().isNotEmpty) return content;
        final reasoning = msg?['reasoning']?.toString();
        if (reasoning != null && reasoning.trim().isNotEmpty) return reasoning;
      }
      // Fallback free router
      return _complete(
        key: key,
        model: 'openrouter/free',
        system: system,
        messages: messages,
      );
    } on DioException catch (e) {
      final body = e.response?.data?.toString() ?? e.message ?? '';
      if (body.contains('401') || body.contains('Unauthorized')) {
        return 'API key rejected. Check OPENROUTER_API_KEY in secrets and rebuild.';
      }
      if (body.contains('rate') || (e.response?.statusCode == 429)) {
        return 'Free model rate limit. Wait a moment and try again.';
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
