import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pure black — Grok-like
class Jx {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0A);
  static const card = Color(0xFF141414);
  static const border = Color(0xFF222222);
  static const text = Color(0xFFF5F5F5);
  static const muted = Color(0xFF8B8B8B);
  static const dim = Color(0xFF555555);
  static const accent = Color(0xFFEDEDED);
}

class JagxTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Jx.bg,
      colorScheme: const ColorScheme.dark(
        primary: Jx.accent,
        surface: Jx.surface,
        onPrimary: Colors.black,
        onSurface: Jx.text,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Jx.text,
        displayColor: Jx.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Jx.bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Jx.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Jx.text),
      ),
    );
  }
}
