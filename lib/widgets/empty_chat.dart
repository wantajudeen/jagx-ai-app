import 'package:flutter/material.dart';

import '../core/theme.dart';

class EmptyChat extends StatelessWidget {
  final int mode;
  final String? hello;
  final void Function(String prompt)? onPrompt;

  const EmptyChat({
    super.key,
    this.mode = 0,
    this.hello,
    this.onPrompt,
  });

  List<List<String>> get _prompts {
    if (mode == 2) {
      return const [
        ['Landing page', 'Modern fintech landing page for Nigeria'],
        ['Flutter UI', 'Dark chat screen with bubbles in Flutter'],
        ['API backend', 'FastAPI /chat with permanent API keys'],
        ['Database', 'Postgres schema for users and messages'],
      ];
    }
    if (mode == 1) {
      return const [
        ['Imagine', 'Imagine a Lagos skyline at golden hour, cinematic'],
        ['Logo', 'Imagine a minimal app icon for JagX, blue and violet'],
        ['Poster', 'Imagine a concert poster for Afrobeat night'],
        ['Product', 'Imagine a sleek smartphone on black marble'],
      ];
    }
    return const [
      ['Write code', 'Python: sort a list of dicts by a key'],
      ['Explain', 'Explain APIs like I am 12'],
      ['Naira plan', '3-month small business budget in Naira'],
      ['Translate', 'Translate to Tagalog: Take care always'],
      ['Fix bug', 'Flutter APK fails on GitHub Actions — how to fix?'],
      ['Pidgin', 'Explain blockchain in Nigerian Pidgin'],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = (hello == null || hello!.isEmpty)
        ? (mode == 2
            ? 'What should we build?'
            : mode == 1
                ? 'What should we imagine?'
                : 'What do you want to know?')
        : hello!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const SizedBox(height: 40),
        const Center(child: JagxMark(size: 56, radius: 16)),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: Jx.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode == 2
              ? 'Describe an app, site, or API.'
              : mode == 1
                  ? 'Describe an image — JagX will generate a link.'
                  : 'Ask anything. Code, business, languages, ideas.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Jx.muted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        ..._prompts.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPrompt == null ? null : () => onPrompt!(p[1]),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Jx.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Jx.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p[0],
                                style: const TextStyle(
                                    color: Jx.text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(p[1],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Jx.muted, fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Jx.dim),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
