import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

/// Auth is optional — guests go straight to chat.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/chat');
    });
    return const Scaffold(
      backgroundColor: Jx.bg,
      body: Center(
        child: CircularProgressIndicator(color: Jx.accent),
      ),
    );
  }
}
