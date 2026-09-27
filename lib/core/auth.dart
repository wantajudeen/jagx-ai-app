import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Device-local accounts. No Supabase / no extra plugins (APK-safe).
class Auth {
  static const _kUsers = 'jx_users_v1';
  static const _kSessionEmail = 'jx_session_email';
  static const _kGuest = 'jx_guest';

  static String _hash(String password) {
    final bytes = utf8.encode('jagx|$password|jrilicense');
    var h = 2166136261;
    for (final b in bytes) {
      h ^= b;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }

  static Future<Map<String, Map<String, String>>> _users() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kUsers);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(
            k,
            Map<String, String>.from(v as Map),
          ));
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveUsers(Map<String, Map<String, String>> users) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUsers, jsonEncode(users));
  }

  static Future<String?> sessionEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kSessionEmail);
  }

  static Future<bool> isLoggedIn() async {
    final e = await sessionEmail();
    return e != null && e.isNotEmpty;
  }

  static Future<bool> isGuest() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kGuest) ?? false;
  }

  static Future<bool> hasChosenEntry() async {
    if (await isLoggedIn()) return true;
    return isGuest();
  }

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final n = name.trim();
    if (n.isEmpty) return 'Enter your name';
    if (!_validEmail(e)) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    final users = await _users();
    if (users.containsKey(e)) return 'That email already has an account';
    users[e] = {'name': n, 'hash': _hash(password)};
    await _saveUsers(users);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSessionEmail, e);
    await p.setBool(_kGuest, false);
    await p.setString('jx_display_name', n);
    return null;
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final users = await _users();
    final u = users[e];
    if (u == null) return 'No account for that email';
    if (u['hash'] != _hash(password)) return 'Wrong password';
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSessionEmail, e);
    await p.setBool(_kGuest, false);
    final name = u['name'] ?? '';
    if (name.isNotEmpty) await p.setString('jx_display_name', name);
    return null;
  }

  static Future<void> continueAsGuest() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kGuest, true);
    await p.remove(_kSessionEmail);
  }

  static Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSessionEmail);
    await p.setBool(_kGuest, false);
  }

  static bool _validEmail(String e) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);
}
