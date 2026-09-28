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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const JagxMark(size: 64, color: Color(0xFF7A7A7A)),
          if (hello != null && hello!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              hello!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Jx.muted, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }
}
