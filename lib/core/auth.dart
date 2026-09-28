import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Real-time auth via Supabase (email + Google).
class Auth {
  static const _kGuest = 'jx_guest';
  static const redirectScheme = 'com.jagx.jagxai://login-callback/';

  static SupabaseClient get _sb => Supabase.instance.client;

  static bool get ready => Env.hasSupabase;

  static User? get user => ready ? _sb.auth.currentUser : null;

  static Session? get session => ready ? _sb.auth.currentSession : null;

  static Future<bool> isLoggedIn() async {
    if (!ready) return false;
    return _sb.auth.currentSession != null;
  }

  static Future<String?> sessionEmail() async {
    final u = user;
    if (u == null) return null;
    return u.email;
  }

  static Future<String?> displayName() async {
    final u = user;
    if (u == null) return null;
    final meta = u.userMetadata;
    final n = meta?['full_name'] ?? meta?['name'] ?? meta?['display_name'];
    if (n is String && n.trim().isNotEmpty) return n.trim();
    return u.email?.split('@').first;
  }

  static Future<bool> isGuest() async {
    if (await isLoggedIn()) return false;
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kGuest) ?? false;
  }

  static Future<bool> hasChosenEntry() async {
    if (await isLoggedIn()) return true;
    // Guests no longer skip auth when Supabase is configured.
    if (ready) return false;
    return isGuest();
  }

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!ready) {
      return 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to GitHub Secrets and rebuild.';
    }
    final e = email.trim().toLowerCase();
    final n = name.trim();
    if (n.isEmpty) return 'Enter your name';
    if (!_validEmail(e)) return 'Enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    try {
      final res = await _sb.auth.signUp(
        email: e,
        password: password,
        data: {'full_name': n, 'name': n},
      );
      if (res.user == null) return 'Could not create account';
      // Email confirmation may be required in Supabase dashboard.
      if (res.session == null) {
        return 'Check your email to confirm the account, then sign in.';
      }
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kGuest, false);
      await p.setString('jx_display_name', n);
      return null;
    } on AuthException catch (err) {
      return err.message;
    } catch (err) {
      return err.toString();
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (!ready) {
      return 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to GitHub Secrets and rebuild.';
    }
    final e = email.trim().toLowerCase();
    if (!_validEmail(e)) return 'Enter a valid email';
    try {
      await _sb.auth.signInWithPassword(email: e, password: password);
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kGuest, false);
      final n = await displayName();
      if (n != null) await p.setString('jx_display_name', n);
      return null;
    } on AuthException catch (err) {
      return err.message;
    } catch (err) {
      return err.toString();
    }
  }

  static Future<String?> signInWithGoogle() async {
    if (!ready) {
      return 'Supabase is not configured.';
    }
    try {
      final ok = await _sb.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!ok) return 'Could not open Google sign-in';
      return null;
    } on AuthException catch (err) {
      return err.message;
    } catch (err) {
      return err.toString();
    }
  }

  static Future<void> continueAsGuest() async {
    // Allowed only when Supabase is not configured (dev fallback).
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kGuest, true);
  }

  static Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kGuest, false);
    if (ready) {
      try {
        await _sb.auth.signOut();
      } catch (_) {}
    }
  }

  static bool _validEmail(String e) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);
}
