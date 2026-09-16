import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Grok-style empty state: mark + greeting, no suggestion chips.
class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key, required this.mode, this.hello});

  final int mode; // 0 ask, 1 imagine, 2 build
  final String? hello;

  @override
  Widget build(BuildContext context) {
    final title = mode == 1
        ? 'What will you imagine?'
        : mode == 2
            ? 'What should we build?'
            : 'How can JagX help?';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(72, 72),
              painter: _JxMarkPainter(),
            ),
            const SizedBox(height: 20),
            if (hello != null)
              Text(
                hello!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Jx.muted),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Jx.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JxMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * 0.32, p);
    canvas.drawLine(
      Offset(c.dx - 8, c.dy - 14),
      Offset(c.dx + 16, c.dy + 18),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
