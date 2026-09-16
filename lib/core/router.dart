import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/splash_screen.dart';

bool get _hasSupabase {
  try {
    Supabase.instance.client;
    return true;
  } catch (_) {
    return false;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (!_hasSupabase) {
        if (path != '/' && path != '/auth' && path != '/chat') return '/auth';
        return null;
      }
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      if (!loggedIn && path != '/' && path != '/auth') return '/auth';
      if (loggedIn && (path == '/auth' || path == '/')) return '/chat';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    ],
  );
});
