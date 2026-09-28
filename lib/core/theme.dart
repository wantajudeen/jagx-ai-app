import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pure black UI — white/gray type, soft silver accent (no blue).
class Jx {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0A);
  static const card = Color(0xFF141414);
  static const cardHover = Color(0xFF1C1C1C);
  static const border = Color(0xFF2A2A2A);
  static const text = Color(0xFFF2F2F2);
  static const muted = Color(0xFF9A9A9A);
  static const dim = Color(0xFF6A6A6A);
  static const accent = Color(0xFFE8E8E8); // soft white
  static const accentSoft = Color(0xFFCFCFCF);
  static const userBubble = Color(0xFF1A1A1A);
  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFF87171);
}

class JagxTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Jx.text,
      displayColor: Jx.text,
    );
    return base.copyWith(
      scaffoldBackgroundColor: Jx.bg,
      colorScheme: const ColorScheme.dark(
        primary: Jx.accent,
        secondary: Jx.accentSoft,
        surface: Jx.surface,
        onPrimary: Colors.black,
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Jx.border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Jx.card,
        contentTextStyle: const TextStyle(color: Jx.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: Jx.border,
    );
  }
}

/// Abstract JagX mark — ring with diagonal slash (distinct, minimal).
class JagxMark extends StatelessWidget {
  const JagxMark({
    super.key,
    this.size = 48,
    this.color = const Color(0xFF7A7A7A),
    this.strokeWidth,
  });

  final double size;
  final Color color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _JagxLogoPainter(
          color: color,
          stroke: strokeWidth ?? size * 0.09,
        ),
      ),
    );
  }
}

class _JagxLogoPainter extends CustomPainter {
  _JagxLogoPainter({required this.color, required this.stroke});
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;

    // open ring (gap on lower-right)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -2.2,
      4.6,
      false,
      p,
    );

    // diagonal slash through the ring
    final slash = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 1.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.78),
      Offset(size.width * 0.78, size.height * 0.22),
      slash,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
