import 'package:dio/dio.dart';

/// Lightweight web access for JagX Bot (no login automation to third-party accounts).
class BrowserTool {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'JagXBot/1.0 (+https://jagxai.name.ng; research assistant)',
    },
  ));

  /// Fetch page text (HTML stripped roughly).
  static Future<String> openUrl(String url) async {
    try {
      if (!url.startsWith('http')) url = 'https://$url';
      final res = await _dio.get(url);
      final raw = res.data?.toString() ?? '';
      final text = raw
          .replaceAll(
              RegExp(r'<script[^>]*>.*?</script>',
                  caseSensitive: false, dotAll: true),
              ' ')
          .replaceAll(
              RegExp(r'<style[^>]*>.*?</style>',
                  caseSensitive: false, dotAll: true),
              ' ')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text.length > 6000) return '${text.substring(0, 6000)}…';
      return text.isEmpty ? 'Page had no readable text.' : text;
    } catch (_) {
      return 'Could not open $url';
    }
  }

  /// Simple public search via DuckDuckGo HTML (best-effort).
  static Future<String> search(String query) async {
    try {
      final q = Uri.encodeComponent(query);
      final res = await _dio.get(
        'https://html.duckduckgo.com/html/?q=$q',
      );
      final raw = res.data?.toString() ?? '';
      final links = RegExp(r'uddg=([^&]+)')
          .allMatches(raw)
          .map((m) => Uri.decodeComponent(m.group(1)!))
          .where((u) => u.startsWith('http'))
          .take(5)
          .toList();
      if (links.isEmpty) {
        return 'No search results for: $query';
      }
      return 'Search results for "$query":\n${links.map((u) => '- $u').join('\n')}';
    } catch (_) {
      return 'Search failed for: $query';
    }
  }
}
