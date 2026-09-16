import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  static const _kName = 'jx_display_name';
  static const _kDob = 'jx_dob';

  static Future<bool> needsOnboarding() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString(_kName);
    return name == null || name.trim().isEmpty;
  }

  static Future<String?> name() async {
    final p = await SharedPreferences.getInstance();
    final local = p.getString(_kName);
    if (local != null && local.isNotEmpty) return local;
    try {
      final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
      return meta?['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> dob() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kDob);
  }

  static Future<void> save({required String name, required String dob}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name.trim());
    await p.setString(_kDob, dob);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': name.trim(), 'date_of_birth': dob}),
      );
    } catch (_) {}
  }

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
