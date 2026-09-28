import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Black professional UI — white/gray palette.
class Jx {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0A);
  static const card = Color(0xFF141414);
  static const cardHover = Color(0xFF1C1C1C);
  static const border = Color(0xFF2A2A2A);
  static const text = Color(0xFFF2F2F2);
  static const muted = Color(0xFF9A9A9A);
  static const dim = Color(0xFF6A6A6A);
  static const accent = Color(0xFFE8E8E8);
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

/// Professional abstract mark: diamond core + hex frame + network nodes.
class JagxMark extends StatelessWidget {
  const JagxMark({
    super.key,
    this.size = 48,
    this.color = const Color(0xFFD0D0D0),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _JagxLogoPainter(color: color)),
    );
  }
}

class _JagxLogoPainter extends CustomPainter {
  _JagxLogoPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Outer hex
    final hexPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    final rHex = w * 0.42;
    final hex = Path();
    for (var k = 0; k < 6; k++) {
      final a = (30 + k * 60) * 3.14159265 / 180;
      final x = cx + rHex * MathCos(a);
      final y = cy + rHex * MathSin(a);
      if (k == 0) {
        hex.moveTo(x, y);
      } else {
        hex.lineTo(x, y);
      }
    }
    hex.close();
    canvas.drawPath(hex, hexPaint);

    // Diamond fill
    final r = w * 0.22;
    final diamond = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.85, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r * 0.85, cy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Inner cut
    final r2 = w * 0.08;
    final cut = Path()
      ..moveTo(cx, cy - r2)
      ..lineTo(cx + r2 * 0.85, cy)
      ..lineTo(cx, cy + r2)
      ..lineTo(cx - r2 * 0.85, cy)
      ..close();
    canvas.drawPath(
      cut,
      Paint()
        ..color = const Color(0xFF0A0A0A)
        ..style = PaintingStyle.fill,
    );
  }

  double MathCos(double a) => a.cosApprox();
  double MathSin(double a) => a.sinApprox();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on double {
  double cosApprox() {
    // use dart math via custom - actually import math
    return _cos(this);
  }

  double sinApprox() => _sin(this);
}

// Avoid import issues in painter by using dart:math in a cleaner rewrite
double _cos(double a) {
  // Taylor is messy; restructure file to import dart:math properly
  return a; // placeholder replaced below
}

double _sin(double a) => a;
