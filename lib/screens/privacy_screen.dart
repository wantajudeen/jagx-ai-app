import 'package:flutter/material.dart';

import '../core/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: const [
          Text(
            'JagX AI Privacy Policy',
            style: TextStyle(color: Jx.text, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('Last updated: 27 September 2026', style: TextStyle(color: Jx.dim, fontSize: 12)),
          SizedBox(height: 18),
          _H('Who we are'),
          _P(
            'JagX AI is built by JagX and JRILICENSE. This policy explains what data the app may collect and how it is used.',
          ),
          _H('Data we may collect'),
          _P(
            'Account data if you sign in (email, display name). Optional profile details you type (name). Chat messages you send. Device-local chat history. Technical logs needed to keep the service running.',
          ),
          _H('How we use data'),
          _P(
            'To create your account, generate replies, improve reliability, and prevent abuse. Prompts are sent to the JagX backend and/or configured model providers so the app can answer you.',
          ),
          _H('Storage'),
          _P(
            'On-device history uses local storage on your phone. Account data may be stored with Supabase if you enable sign-in. We do not sell your personal data.',
          ),
          _H('Do not send secrets'),
          _P(
            'Do not paste passwords, bank PINs, private keys, or one-time codes you cannot rotate. Treat chats as not fully private.',
          ),
          _H('Children'),
          _P(
            'JagX AI is not directed at children under 13. If you believe a child provided personal data, contact us to request deletion.',
          ),
          _H('Your choices'),
          _P(
            'You can use guest mode without creating an account. You can clear local chat history in the app. You can request account deletion via JagX support channels.',
          ),
          _H('Contact'),
          _P('JagX & JRILICENSE — use your project support channel or the GitHub repository issues page.'),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(text, style: const TextStyle(color: Jx.text, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Jx.muted, height: 1.5, fontSize: 14)),
    );
  }
}
