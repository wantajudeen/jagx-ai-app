import 'package:flutter/material.dart';

import '../core/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Jx.bg,
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Terms of Use',
            style: TextStyle(
                color: Jx.text, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'JagX AI is provided by JagX & JRILICENSE for informational and productivity use. '
            'You are responsible for how you use outputs. Do not use the service for illegal activity, '
            'harm, or to violate others’ rights.\n\n'
            'Finance and trading content is educational only — not investment advice. '
            'You may lose money if you act on market information; always do your own research.\n\n'
            'Accounts may be suspended for abuse. Premium features require a valid access code or subscription.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
          SizedBox(height: 24),
          Text(
            'Privacy',
            style: TextStyle(
                color: Jx.text, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'We store account data (email, name, date of birth) via Supabase when you sign in. '
            'Chat history on this device may be saved locally for your convenience. '
            'API providers process prompts to generate replies. '
            'Do not send passwords or secrets you cannot rotate.\n\n'
            'Contact: support via your JagX project channels.',
            style: TextStyle(color: Jx.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
