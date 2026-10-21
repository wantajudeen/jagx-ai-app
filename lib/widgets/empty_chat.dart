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

  @override
  Widget build(BuildContext context) {
    final prompts = mode == 2
        ? const [
            ('Plan a feature', 'Plan and implement a feature with clear steps, files, and tests.'),
            ('Review code', 'Review this code for correctness, security, and maintainability: '),
            ('Design an API', 'Design a robust API for this requirement: '),
            ('Explain a concept', 'Explain this concept clearly with an example: '),
          ]
        : const [
            ('Research a question', 'Research this question and separate verified facts from assumptions: '),
            ('Write with clarity', 'Help me write a clear, polished draft about: '),
            ('Solve a problem', 'Help me solve this problem step by step: '),
            ('Explore an idea', 'Help me explore and improve this idea: '),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Jx.cardHover,
                      border: Border.all(color: Jx.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const JagxMark(size: 27, color: Color(0xFF6D8B48)),
                  ),
                  if (hello != null && hello!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      hello!,
                      style: const TextStyle(
                        color: Jx.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    mode == 2
                        ? 'Turn a good idea into a working build.'
                        : 'Good work starts with a better question.',
                    style: const TextStyle(
                      color: Jx.text,
                      fontFamily: 'Georgia',
                      fontSize: 34,
                      height: 1.12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Research, write, reason, and build with a workspace designed to help you move from question to useful result.',
                    style: TextStyle(
                      color: Jx.muted,
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    mode == 2 ? 'START WITH A BUILD TASK' : 'A FEW WAYS TO START',
                    style: const TextStyle(
                      color: Jx.dim,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prompts.map((item) {
                      return SizedBox(
                        width: compact ? double.infinity : 300,
                        child: OutlinedButton(
                          onPressed: onPrompt == null
                              ? null
                              : () => onPrompt!(item.$2),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 14,
                            ),
                            side: const BorderSide(color: Jx.border),
                            backgroundColor: Jx.card,
                            foregroundColor: Jx.text,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.north_east_rounded,
                                size: 15,
                                color: Color(0xFF6D8B48),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'JagX AI · by JagX & JRILICENSE',
                    style: TextStyle(
                      color: Jx.dim,
                      fontSize: 10,
                      letterSpacing: .4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
