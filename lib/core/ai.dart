import 'package:dio/dio.dart';

import 'agents.dart';
import 'connectors_store.dart';
import 'env.dart';

class Ai {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 120),
    sendTimeout: const Duration(seconds: 45),
  ));

  static const _baseSystem = '''
You are JagX AI by JagX and JRILICENSE.
Write like a clear human. Short sentences when possible.
Do NOT use markdown bold with asterisks (**like this**).
For math: plain numbered steps, no ** stars.
Never name other AI brands. You are only JagX AI.
Reply in the user's language.
When TOOL RESULT is provided, use it as ground truth and answer from it.
''';

  static const _orModels = [
    'openai/gpt-oss-20b:free',
    'google/gemma-3n-e4b-it:free',
    'qwen/qwen3-8b:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'openrouter/auto',
  ];

  static String get _base {
    final b = Env.jagxApiBase.isEmpty
        ? 'https://jagx-ai-v2.onrender.com'
        : Env.jagxApiBase.replaceAll(RegExp(r'/+\$'), '');
    return b;
  }

  static String cleanOutput(String text) {
    var t = text;
    t = t.replaceAllMapped(
        RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(
        RegExp(r'(?<![\w*])\*([^*\n]+)\*(?![\w*])'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(RegExp(r'^#{1,6}\s+', multiLine: true), (m) => '');
    return t.trim();
  }

  /// Run connected connectors / free tools, return context string or null.
  static Future<String?> runTools(String userText) async {
    final connectors = await ConnectorsStore.enabled();
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    final key = Env.jagxApiKey.trim();
    if (key.isNotEmpty) headers['x-api-key'] = key;

    // Prefer backend MCP proxy when deployed
    try {
      final res = await _dio.post(
        '$_base/mcp/run',
        options: Options(
          headers: headers,
          validateStatus: (s) => s != null && s < 500,
          receiveTimeout: const Duration(seconds: 40),
        ),
        data: {
          'message': userText,
          'connectors': connectors,
        },
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        if (data['ok'] == true && (data['text']?.toString().isNotEmpty ?? false)) {
          return data['text'].toString();
        }
      }
    } catch (_) {}

    // Fallback: existing free endpoints on live backend
    final lower = userText.toLowerCase();
    final ids = connectors.map((c) => c['id']?.toString() ?? '').toSet();
    final any = ids.isEmpty; // if none connected, still allow built-ins lightly

    try {
      if ((any || ids.contains('jagx_news')) &&
          RegExp(r'\b(news|headline|breaking)\b').hasMatch(lower)) {
        final topic = ['nigeria', 'africa', 'world', 'tech']
            .firstWhere((w) => lower.contains(w), orElse: () => '');
        final r = await _dio.get(
          '$_base/news',
          queryParameters: {if (topic.isNotEmpty) 'topic': topic},
          options: Options(headers: headers, validateStatus: (s) => s != null && s < 500),
        );
        if (r.statusCode == 200 && r.data is Map && r.data['news'] != null) {
          return r.data['news'].toString();
        }
      }
      if ((any || ids.contains('jagx_weather') || ids.contains('jagx_maps')) &&
          RegExp(r'\b(weather|temperature|forecast)\b').hasMatch(lower)) {
        final place = userText
            .replaceAll(RegExp(r'.*\b(in|for|at)\s+', caseSensitive: false), '')
            .trim();
        final r = await _dio.get(
          '$_base/weather',
          queryParameters: {'place': place.isEmpty ? 'Lagos' : place},
          options: Options(headers: headers, validateStatus: (s) => s != null && s < 500),
        );
        if (r.statusCode == 200 && r.data is Map && r.data['result'] != null) {
          return r.data['result'].toString();
        }
      }
      if ((any || ids.contains('jagx_maps')) &&
          RegExp(r'\b(where is|map of|locate|geocode)\b').hasMatch(lower)) {
        final q = userText
            .replaceAll(
                RegExp(r'.*\b(where is|map of|locate|geocode)\s+',
                    caseSensitive: false),
                '')
            .trim();
        final r = await _dio.get(
          '$_base/geo',
          queryParameters: {'q': q.isEmpty ? userText : q},
          options: Options(headers: headers, validateStatus: (s) => s != null && s < 500),
        );
        if (r.statusCode == 200 && r.data is Map && r.data['result'] != null) {
          return r.data['result'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    String? agentId,
  }) async {
    final lastUser = messages.reversed.firstWhere(
      (m) => m['role'] == 'user',
      orElse: () => <String, String>{},
    );
    final userText = (lastUser['content'] ?? '').toString().trim();

    // Tool pass (connectors + free JagX tools)
    String? toolCtx;
    if (userText.isNotEmpty) {
      toolCtx = await runTools(userText);
    }

    final enriched = List<Map<String, String>>.from(messages);
    if (toolCtx != null && toolCtx.isNotEmpty && enriched.isNotEmpty) {
      final last = Map<String, String>.from(enriched.last);
      if (last['role'] == 'user') {
        last['content'] =
            '${last['content']}\n\n[TOOL RESULT — use this data]\n$toolCtx';
        enriched[enriched.length - 1] = last;
      }
    }

    if (agentId != null) {
      final orFirst = await _agentOpenRouter(agentId, enriched);
      if (orFirst != null) return cleanOutput(orFirst);
    }

    final jagx = await _jagxChat(messages: enriched);
    if (jagx != null && jagx.trim().isNotEmpty) return cleanOutput(jagx);

    // If tools returned data but model failed, still show tool result
    if (toolCtx != null && toolCtx.trim().isNotEmpty) {
      return cleanOutput(toolCtx);
    }

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
        messages: enriched,
        preferModel: agentId != null ? Agents.byId(agentId).openRouterModel : null,
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

  static Future<String> multiAgentRun({
    required String goal,
    required void Function(String log) onLog,
    String? webContext,
  }) async {
    final tool = await runTools(goal);
    final ctx = [
      goal,
      if (webContext != null && webContext.isNotEmpty) 'WEB CONTEXT:\n$webContext',
      if (tool != null && tool.isNotEmpty) 'TOOL RESULT:\n$tool',
    ].join('\n\n');

    onLog('Nimbus engaged · multi-agent');
    onLog('Atlas planning…');
    final plan = await agentChat(
      agentId: 'atlas',
      messages: [
        {'role': 'user', 'content': 'Plan only for this goal:\n$ctx'}
      ],
    );

    onLog('Nova coding pass…');
    final code = await agentChat(
      agentId: 'nova',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal:\n$ctx\n\nPlan:\n$plan\n\nIf code is needed, write it. If not, say none.'
        }
      ],
    );

    onLog('Mira research pass…');
    final research = await agentChat(
      agentId: 'mira',
      messages: [
        {
          'role': 'user',
          'content': 'Goal:\n$ctx\n\nPlan:\n$plan\n\nSummarize useful facts only.'
        }
      ],
    );

    onLog('Nimbus merging final answer…');
    final finalAns = await agentChat(
      agentId: 'nimbus',
      messages: [
        {
          'role': 'user',
          'content':
              'Goal:\n$ctx\n\nPlan:\n$plan\n\nCoder notes:\n$code\n\nResearch:\n$research\n\nWrite the final useful answer for the user. Plain text only.'
        }
      ],
    );
    onLog('Done');
    return cleanOutput(finalAns);
  }

  static Future<String?> _agentOpenRouter(
    String agentId,
    List<Map<String, String>> messages,
  ) async {
    final key = Env.openRouterKey.trim();
    if (key.isEmpty) return null;
    final a = Agents.byId(agentId);
    final system =
        '$_baseSystem\n\nYou are ${a.name} (${a.role}) of JagX Bot.\n${a.systemHint}';
    return _openRouter(
      key: key,
      system: system,
      messages: messages,
      preferModel: a.openRouterModel,
    );
  }

  static Future<String?> _jagxChat({
    required List<Map<String, String>> messages,
  }) async {
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
          '$_base/chat',
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
    String? preferModel,
  }) async {
    final models = <String>[
      if (preferModel != null && preferModel.isNotEmpty) preferModel,
      ..._orModels,
    ];
    for (final model in models) {
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
    return 'The model is waking up. Try again in a moment.';
  }

  static Future<String?> imagine(String prompt) async {
    final encoded = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encoded?width=1024&height=1024&nologo=true';
  }
}
