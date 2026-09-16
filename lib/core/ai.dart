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
Never name OpenAI, Claude, GPT, Grok, xAI, Llama, Gemini, DeepSeek, or other AI brands.
Identity: only JagX AI by JagX & JRILICENSE.
Be clear, useful, strong at code and African context (Naira, Nigeria, Pidgin when appropriate).
Finance: education and analysis only; always include risk warnings. No live trading claims.
''';

  /// OpenRouter model IDs — distinct power per JagX product line
  static String _model(String id) {
    switch (id) {
      case 'jagx-0.3':
        // Fast everyday
        return 'google/gemini-2.0-flash-001';
      case 'jagx-0.4':
        // Expert reasoning & code
        return 'deepseek/deepseek-chat';
      case 'forge':
        // Strongest regular
        return 'qwen/qwen-2.5-72b-instruct';
      case 'bot':
        // Agentic teammate
        return 'deepseek/deepseek-r1';
      default:
        return 'google/gemini-2.0-flash-001';
    }
  }

  static Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    if (modelId == 'oracle') {
      return 'Oracle is **Coming soon**. Use JagX Bot, Forge, or JagX 0.4.';
    }

    final key = Env.openRouterKey;
    if (key.isEmpty) {
      return 'OpenRouter key missing. Add OPENROUTER_API_KEY to GitHub Secrets and rebuild the APK.';
    }

    var system = _baseSystem;
    if (modelId == 'bot' && agentId != null) {
      final a = Agents.byId(agentId);
      system =
          '$system\n\nActive agent: **${a.name}** (${a.role}).\n${a.systemHint}';
    } else if (modelId == 'bot') {
      system = '''$system

You are JagX Bot with named agents: Atlas (plan), Nova (code), Mira (research), Kofi (finance), Zara (design), Rex (GitHub).
Say which agent is speaking when useful, e.g. **Nova:** ...
''';
    } else if (modelId == 'forge' || modelId == 'jagx-0.4') {
      system =
          '$system\nPrefer complete, production-ready answers for code and architecture.';
    }

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
          'model': _model(modelId),
          'messages': [
            {'role': 'system', 'content': system},
            ...messages,
          ],
          'temperature': modelId == 'jagx-0.3' ? 0.7 : 0.3,
          'max_tokens': modelId == 'jagx-0.3' ? 4096 : 12000,
        },
      );

      final choices = res.data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices[0]['message'];
        final content = msg?['content']?.toString();
        // Some models put reasoning in a separate field
        if (content != null && content.trim().isNotEmpty) return content;
        final reasoning = msg?['reasoning']?.toString();
        if (reasoning != null && reasoning.trim().isNotEmpty) return reasoning;
      }
      return 'No response from JagX. Try again or switch model.';
    } on DioException catch (e) {
      final body = e.response?.data?.toString() ?? e.message ?? '';
      if (body.contains('401') || body.contains('Unauthorized')) {
        return 'API key rejected. Check OPENROUTER_API_KEY in secrets and rebuild.';
      }
      if (body.contains('402') || body.contains('credits')) {
        return 'OpenRouter credits low. Top up at openrouter.ai then retry.';
      }
      return 'JagX could not reach the model. (${e.response?.statusCode ?? 'network'})';
    } catch (e) {
      return 'JagX is temporarily unavailable. Try again.';
    }
  }

  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    final pollinations =
        'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';
    return pollinations;
  }
}
