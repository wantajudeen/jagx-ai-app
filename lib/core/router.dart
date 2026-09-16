import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/connectors_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import 'profile.dart';

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
    redirect: (context, state) async {
      final path = state.matchedLocation;
      if (!_hasSupabase) return null;

      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;

      if (!loggedIn && path != '/' && path != '/auth') return '/auth';
      if (loggedIn && (path == '/auth' || path == '/')) {
        final need = await Profile.needsOnboarding();
        return need ? '/onboarding' : '/chat';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/connectors', builder: (_, __) => const ConnectorsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});
