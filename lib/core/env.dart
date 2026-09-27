import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get openRouterKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  /// JagX backend on Render (permanent keys)
  static String get jagxApiBase =>
      (dotenv.env['JAGX_API_BASE'] ?? 'https://jagx-ai-v2.onrender.com').trim();

  static String get jagxApiKey => (dotenv.env['JAGX_API_KEY'] ?? '').trim();
}
