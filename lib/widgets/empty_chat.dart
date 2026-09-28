import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Minimal empty state — logo only, like modern AI apps.
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const JagxMark(size: 72, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 28),
          if (hello != null && hello!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                hello!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Jx.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
