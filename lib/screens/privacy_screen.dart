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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: const [
          Text(
            'JagX AI Privacy Policy',
            style: TextStyle(
                color: Jx.text, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('Last updated: 4 October 2026',
              style: TextStyle(color: Jx.dim, fontSize: 12)),
          SizedBox(height: 8),
          Text(
            'JagX is by JRILICENSE',
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 18),
          _H('Who we are'),
          _P(
            'JagX AI is built and operated by JagX and JRILICENSE. This policy '
            'explains what information we process when you use the app or website.',
          ),
          _H('Data we may collect'),
          _P(
            '• Account data if you sign in (email, display name, auth provider IDs).\n'
            '• Messages and files you send so the assistant can reply.\n'
            '• Optional profile details you enter (e.g. name, preferences).\n'
            '• Device-local chat history stored on your phone.\n'
            '• Technical logs (errors, rate limits) needed to keep the Service reliable.\n'
            '• Approximate location only if you ask for maps/weather features.',
          ),
          _H('How we use data'),
          _P(
            'To authenticate you, generate answers, improve quality and safety, '
            'prevent abuse, and provide features you request (code, search, files, news). '
            'Prompts may be sent to the JagX backend and configured model providers.',
          ),
          _H('Storage and processors'),
          _P(
            'Local history stays on your device until you clear it. Account data may '
            'be stored with Supabase when you enable sign-in. Hosting and AI providers '
            'process requests to deliver the Service. We do not sell your personal data.',
          ),
          _H('Do not send secrets'),
          _P(
            'Do not paste passwords, bank PINs, private keys, recovery phrases, or '
            'one-time codes you cannot rotate. Treat chats as not fully private.',
          ),
          _H('Children'),
          _P(
            'JagX AI is not directed at children under 13. If you believe a child '
            'provided personal data, contact us to request deletion.',
          ),
          _H('Your choices'),
          _P(
            'You can use guest mode where available, clear local history in the app, '
            'sign out, or request account deletion via JagX support channels or the '
            'project GitHub issues page.',
          ),
          _H('International transfer'),
          _P(
            'Processing may occur in countries where our providers operate. By using '
            'the Service you understand that data may leave your country of residence.',
          ),
          _H('Changes'),
          _P(
            'We may update this policy. The "Last updated" date will change when we do. '
            'Continued use after an update means you accept the revised policy.',
          ),
          _H('Contact'),
          _P(
            'JagX & JRILICENSE — use project support channels or the official '
            'JagX AI GitHub repository.',
          ),
          SizedBox(height: 12),
          Text(
            '© JagX · JRILICENSE. All rights reserved.',
            style: TextStyle(color: Jx.dim, fontSize: 12),
          ),
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
      child: Text(text,
          style: const TextStyle(
              color: Jx.text, fontSize: 16, fontWeight: FontWeight.w700)),
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
      child: Text(text,
          style: const TextStyle(color: Jx.muted, height: 1.55, fontSize: 14)),
    );
  }
}
