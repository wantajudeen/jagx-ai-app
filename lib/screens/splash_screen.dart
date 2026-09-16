import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      context.go(session != null ? '/chat' : '/auth');
    } catch (_) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Jx.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Jx.border),
              ),
              child: const Center(
                child: Text(
                  'J',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Jx.text,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'JagX AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Jx.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
