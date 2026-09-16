import 'package:dio/dio.dart';

import 'agents.dart';
import 'env.dart';

class Ai {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
  ));

  static const _baseSystem = '''
You are JagX AI by JagX & JRILICENSE — Africa-first multipurpose intelligence.
Never name OpenAI, Claude, GPT, Grok, xAI, Llama, or other AI brands.
Identity: only JagX AI by JagX & JRILICENSE.
Be clear, useful, strong at code and African context (Naira, Nigeria, Pidgin when appropriate).
Finance: education and analysis only; always include risk warnings. No live trading claims.
''';

  static String _model(String id) {
    switch (id) {
      case 'jagx-0.3':
        return 'meta-llama/llama-3.1-8b-instruct';
      case 'jagx-0.4':
      case 'forge':
      case 'bot':
        return 'meta-llama/llama-3.1-70b-instruct';
      default:
        return 'meta-llama/llama-3.1-8b-instruct';
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
      return 'Set OPENROUTER_API_KEY in .env / GitHub Secrets, then rebuild.';
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
          'temperature': modelId == 'jagx-0.3' ? 0.7 : 0.35,
          'max_tokens': modelId == 'jagx-0.3' ? 2048 : 8192,
        },
      );
      return res.data['choices'][0]['message']['content']?.toString() ??
          'No response.';
    } catch (_) {
      return 'JagX AI is temporarily unavailable. Check API key and try again.';
    }
  }

  /// Prefer pollinations (no key) then OpenRouter image models
  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    // Reliable public image endpoint for demos / production fallback
    final pollinations =
        'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';

    final key = Env.openRouterKey;
    if (key.isNotEmpty) {
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
            'model': 'google/gemini-2.0-flash-exp:free',
            'messages': [
              {
                'role': 'user',
                'content':
                    'Return ONLY one direct image URL for this prompt (no markdown): $prompt',
              }
            ],
          },
        );
        final content =
            res.data['choices']?[0]?['message']?['content']?.toString() ?? '';
        final match = RegExp(r'https?://[^\s)\]"]+').firstMatch(content);
        if (match != null) return match.group(0);
      } catch (_) {}
    }

    return pollinations;
  }
}
