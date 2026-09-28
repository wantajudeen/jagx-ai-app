import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// Permanent JagX key (unlimited). Overridden by .env / GitHub Secrets when set.
  static const _defaultJagxKey = 'jagx-984199d487c01240f4515157a11cd6b4';
  static const _defaultBase = 'https://jagx-ai-v2.onrender.com';

  static String get openRouterKey =>
      (dotenv.env['OPENROUTER_API_KEY'] ?? '').trim();

  static String get jagxApiBase {
    final v = (dotenv.env['JAGX_API_BASE'] ?? '').trim();
    if (v.isEmpty) return _defaultBase;
    return v.replaceAll(RegExp(r'/+\$'), '');
  }

  static String get jagxApiKey {
    final v = (dotenv.env['JAGX_API_KEY'] ?? '').trim();
    if (v.isEmpty) return _defaultJagxKey;
    return v;
  }

  static String get supabaseUrl => (dotenv.env['SUPABASE_URL'] ?? '').trim();

  static String get supabaseAnonKey =>
      (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
