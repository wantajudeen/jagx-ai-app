import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/bot_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/connectors_screen.dart';
import '../screens/github_connect_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/terms_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/bot', builder: (_, __) => const BotScreen()),
      GoRoute(path: '/connectors', builder: (_, __) => const ConnectorsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
      GoRoute(path: '/github', builder: (_, __) => const GithubConnectScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      // legacy paths → chat
      GoRoute(path: '/auth', redirect: (_, __) => '/chat'),
    ],
  );
});
