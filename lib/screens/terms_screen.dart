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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          const Text(
            'JagX AI Terms of Service',
            style: TextStyle(
                color: Jx.text, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Last updated: 4 October 2026',
            style: TextStyle(color: Jx.dim, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'JagX is by JRILICENSE',
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          const Text(
            'These Terms govern your access to and use of JagX AI (the "Service"), '
            'including the mobile app, website, APIs, and related products operated by '
            'JagX and JRILICENSE ("we", "us"). By using the Service you agree to these Terms.',
            style: TextStyle(color: Jx.muted, height: 1.55),
          ),
          const SizedBox(height: 16),
          _h('1. The Service'),
          _p(
            'JagX AI is an AI assistant for chat, coding, learning, and productivity. '
            'Responses may be incomplete, outdated, or incorrect. You must review all '
            'outputs before relying on them, especially for legal, medical, financial, '
            'safety, or academic decisions.',
          ),
          _h('2. Eligibility'),
          _p(
            'You must be at least 13 years old (or the age of digital consent in your '
            'country). If you use JagX on behalf of an organisation, you confirm you '
            'have authority to bind that organisation to these Terms.',
          ),
          _h('3. Accounts'),
          _p(
            'You may use guest mode where available. If you create an account (email '
            'or Google), you are responsible for keeping credentials secure and for '
            'activity under your account. We may suspend or terminate accounts that '
            'abuse the Service or violate these Terms.',
          ),
          _h('4. Acceptable use'),
          _p(
            'You agree not to use JagX to: break the law; defraud or harass others; '
            'produce malware or weapons guidance; exploit children; scrape or attack '
            'our systems; reverse-engineer the Service beyond what the law allows; '
            'or misrepresent AI output as solely human-written where disclosure is required.',
          ),
          _h('5. Finance and trading disclaimer'),
          _p(
            'Any content about money, markets, or trading is educational only and is '
            'not investment, tax, or legal advice. You can lose money. Do your own '
            'research and, where needed, consult a licensed professional.',
          ),
          _h('6. Intellectual property'),
          _p(
            'The JagX name, logos (including the dual-jaguar crest), design, and '
            'software belong to JagX and JRILICENSE. You retain rights in content you '
            'submit. You grant us a worldwide license to host, process, and display '
            'that content solely to operate and improve the Service.',
          ),
          _h('7. Third-party services'),
          _p(
            'The Service may call model providers, hosting, auth (e.g. Supabase), '
            'maps, news feeds, or code sandboxes. Their terms and availability apply. '
            'We are not responsible for third-party outages or policies.',
          ),
          _h('8. Limitation of liability'),
          _p(
            'To the maximum extent permitted by law, the Service is provided "as is" '
            'without warranties. JagX and JRILICENSE are not liable for indirect, '
            'incidental, or consequential damages, or for losses arising from reliance '
            'on AI outputs or temporary unavailability.',
          ),
          _h('9. Changes'),
          _p(
            'We may update these Terms. Continued use after changes means you accept '
            'the updated Terms. Material changes will be reflected by the "Last updated" date.',
          ),
          _h('10. Contact'),
          _p(
            'Questions: use the support channels listed on the JagX project pages, '
            'or open an issue on the official GitHub repository for JagX AI.',
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push('/privacy'),
            child: const Text('Read Privacy Policy'),
          ),
          const SizedBox(height: 8),
          const Text(
            '© JagX · JRILICENSE. All rights reserved.',
            style: TextStyle(color: Jx.dim, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: Jx.text, fontWeight: FontWeight.w700, fontSize: 15)),
      );

  static Widget _p(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t, style: const TextStyle(color: Jx.muted, height: 1.55)),
      );
}
