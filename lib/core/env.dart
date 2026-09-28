import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openRouterKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static String get jagxApiBase =>
      (dotenv.env['JAGX_API_BASE'] ?? 'https://jagx-ai-v2.onrender.com').trim();

  static String get jagxApiKey => (dotenv.env['JAGX_API_KEY'] ?? '').trim();

  static String get supabaseUrl =>
      (dotenv.env['SUPABASE_URL'] ?? '').trim();

  static String get supabaseAnonKey =>
      (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
