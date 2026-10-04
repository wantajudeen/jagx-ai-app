import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// Permanent JagX key (unlimited). Overridden by .env / GitHub Secrets when set.
  static const _defaultJagxKey = 'jagx-984199d487c01240f4515157a11cd6b4';
  static const _defaultBase = 'https://jagx-ai-v2.onrender.com';

  /// Live Supabase project (same as website). Do not typo the ref: xxxyqzuwvavqsccnlkxa
  static const _defaultSupabaseUrl =
      'https://xxxyqzuwvavqsccnlkxa.supabase.co';
  static const _defaultSupabaseAnon =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHlxenV3dmF2cXNjY25sa3hhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NjY4MDcsImV4cCI6MjEwNTE0MjgwN30.pd3D3ULeR90gM7HB8xAlERr8swUyc_aJaIxDqc-vH2Y';

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

  static String get supabaseUrl {
    final v = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    if (v.isEmpty) return _defaultSupabaseUrl;
    // Guard against known typo from older APK builds (quzw vs qzuw)
    if (v.contains('xxxyquzw')) return _defaultSupabaseUrl;
    return v;
  }

  static String get supabaseAnonKey {
    final v = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
    if (v.isEmpty) return _defaultSupabaseAnon;
    return v;
  }

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
