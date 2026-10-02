import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth.dart';
import '../core/env.dart';
import '../core/profile.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _c.forward();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // Guest chat allowed — do not block on auth
    if (await Profile.needsOnboarding()) {
      if (Env.hasSupabase && await Auth.isLoggedIn()) {
        context.go('/onboarding');
        return;
      }
    }
    context.go('/chat');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: FadeTransition(
        opacity: _fade,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              JagxMark(size: 80, color: Color(0xFF8A8A8A)),
              SizedBox(height: 24),
              Text(
                'JagX AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Jx.text,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'JagX & JRILICENSE',
                style: TextStyle(color: Jx.dim, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
