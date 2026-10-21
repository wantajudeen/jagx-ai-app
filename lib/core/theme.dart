import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Jx {
  static const bg = Color(0xFFF4F3EE);
  static const surface = Color(0xFFF9F8F3);
  static const card = Color(0xFFFFFEFA);
  static const cardHover = Color(0xFFEEEEE7);
  static const border = Color(0xFFDFDED6);
  static const text = Color(0xFF20231F);
  static const muted = Color(0xFF686C64);
  static const dim = Color(0xFF898C83);
  static const accent = Color(0xFF242A20);
  static const accentSoft = Color(0xFFA9CF68);
  static const blue = Color(0xFF486B9B);
  static const violet = Color(0xFF687D5A);
  static const userBubble = Color(0xFFE8E9E1);
  static const success = Color(0xFF46734A);
  static const danger = Color(0xFFB5483F);
}

class JagxTheme {
  static ThemeData get dark {
    final base = ThemeData.light(useMaterial3: true);
    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Jx.text,
      displayColor: Jx.text,
    );
    return base.copyWith(
      scaffoldBackgroundColor: Jx.bg,
      colorScheme: const ColorScheme.light(
        primary: Jx.accent,
        secondary: Jx.accentSoft,
        surface: Jx.surface,
        onPrimary: Colors.white,
        onSurface: Jx.text,
        outline: Jx.border,
      ),
      textTheme: inter,
      appBarTheme: AppBarTheme(
        backgroundColor: Jx.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: inter.titleMedium?.copyWith(
          color: Jx.text,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        iconTheme: const IconThemeData(color: Jx.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Jx.card,
        hintStyle: const TextStyle(color: Jx.dim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Jx.accentSoft),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Jx.text,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: Jx.border,
    );
  }
}

/// Dark subtle JX mark for empty chat (Grok-like quiet presence).
class JagxMark extends StatelessWidget {
  const JagxMark({
    super.key,
    this.size = 48,
    this.color = const Color(0xFF5A5A5A),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _JxMonoPainter(color: color)),
    );
  }
}

class _JxMonoPainter extends CustomPainter {
  _JxMonoPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // J
    final j = Path()
      ..moveTo(w * 0.28, h * 0.22)
      ..lineTo(w * 0.52, h * 0.22)
      ..moveTo(w * 0.40, h * 0.22)
      ..lineTo(w * 0.40, h * 0.58)
      ..quadraticBezierTo(w * 0.40, h * 0.78, w * 0.22, h * 0.78);
    canvas.drawPath(j, p);

    // X
    canvas.drawLine(Offset(w * 0.52, h * 0.28), Offset(w * 0.82, h * 0.72), p);
    canvas.drawLine(Offset(w * 0.82, h * 0.28), Offset(w * 0.52, h * 0.72), p);

    // subtle orbit
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.5), width: w * 0.92, height: h * 0.78),
      -0.5,
      2.0,
      false,
      Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.22),
      w * 0.045,
      Paint()..color = color.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
