import 'package:flutter/material.dart';

import '../core/theme.dart';

class EmptyChat extends StatelessWidget {
  final String greeting;
  final void Function(String prompt) onPrompt;

  const EmptyChat({
    super.key,
    required this.greeting,
    required this.onPrompt,
  });

  static const _prompts = [
    ('Write code', 'Write a clean Python function that sorts a list of dicts by key'),
    ('Explain simply', 'Explain how APIs work like I am 12'),
    ('Naira plan', 'Help me plan a small business budget in Naira for 3 months'),
    ('Translate', 'Translate to Tagalog: What do you think about me?'),
    ('Fix bug', 'Review this idea and suggest how to fix a Flutter build failure'),
    ('Pidgin', 'Explain blockchain for me in Nigerian Pidgin'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const SizedBox(height: 28),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('J',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          greeting.isEmpty ? 'How can JagX help?' : greeting,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Jx.text,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ask anything — code, business, languages, ideas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Jx.muted, fontSize: 14),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final p in _prompts)
              InkWell(
                onTap: () => onPrompt(p.\$2),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Jx.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Jx.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.\$1,
                        style: const TextStyle(
                          color: Jx.accentSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.\$2,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Jx.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
