import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// JagX visual system — near-black surfaces, soft white type, blue accent like modern AI apps.
class Jx {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF111111);
  static const card = Color(0xFF171717);
  static const cardHover = Color(0xFF1F1F1F);
  static const border = Color(0xFF2A2A2A);
  static const text = Color(0xFFF5F5F5);
  static const muted = Color(0xFFA3A3A3);
  static const dim = Color(0xFF737373);
  static const accent = Color(0xFF3B82F6); // blue primary like Grok CTA
  static const accentSoft = Color(0xFF60A5FA);
  static const violet = Color(0xFF8B5CF6);
  static const userBubble = Color(0xFF1C1C1E);
  static const success = Color(0xFF34D399);
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
        secondary: Jx.violet,
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
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Jx.accent, width: 1.2),
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
      listTileTheme: const ListTileThemeData(
        iconColor: Jx.muted,
        textColor: Jx.text,
      ),
    );
  }
}

/// Shared logo mark widget
class JagxMark extends StatelessWidget {
  const JagxMark({super.key, this.size = 40, this.radius = 12});
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(painter: _JxGlyphPainter()),
    );
  }
}

class _JxGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    // Stylized X made of two strokes (JagX mark)
    canvas.drawLine(Offset(w * 0.28, h * 0.28), Offset(w * 0.72, h * 0.72), p);
    canvas.drawLine(Offset(w * 0.72, h * 0.28), Offset(w * 0.28, h * 0.72), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
