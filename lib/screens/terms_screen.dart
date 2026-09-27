import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Terms of Service')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const Text(
            'JagX AI Terms of Service',
            style: TextStyle(color: Jx.text, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Last updated: 27 September 2026', style: TextStyle(color: Jx.dim, fontSize: 12)),
          const SizedBox(height: 18),
          const Text(
            'These terms govern use of JagX AI, provided by JagX and JRILICENSE. By using the app you agree to them.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('1. The service', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'JagX AI is a text and coding assistant. Outputs can be wrong. You must review answers before you rely on them, especially for law, medicine, finance, or safety.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('2. Acceptable use', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Do not use JagX for illegal activity, scams, harassment, or to violate other people\'s rights. We may suspend access for abuse.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('3. Finance disclaimer', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Any money, trading, or investment content is educational only and is not advice. You can lose money. Do your own research.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('4. Accounts', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'You may use guest mode. If you create an account, keep your login details safe. Premium features may require a valid access code or plan.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('5. Intellectual property', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'The JagX name, app design, and branding belong to JagX and JRILICENSE. You keep rights to content you submit, and grant us a license to process it so the product can function.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('6. Limitation of liability', style: TextStyle(color: Jx.text, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'The app is provided as-is. To the maximum extent allowed by law, JagX and JRILICENSE are not liable for losses from use of the service.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.push('/privacy'),
            child: const Text('Read Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
