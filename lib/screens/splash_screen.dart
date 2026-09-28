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
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _scale = Tween(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    // If Supabase configured, require real session; else allow local guest/onboarding flow.
    if (Env.hasSupabase) {
      if (!await Auth.isLoggedIn()) {
        context.go('/auth');
        return;
      }
    } else if (!await Auth.hasChosenEntry()) {
      context.go('/auth');
      return;
    }
    if (await Profile.needsOnboarding()) {
      context.go('/onboarding');
      return;
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
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const JagxMark(size: 88, radius: 24),
                const SizedBox(height: 24),
                const Text(
                  'JagX AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: Jx.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Built by JagX & JRILICENSE',
                  style: TextStyle(color: Jx.muted, fontSize: 13),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Jx.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
