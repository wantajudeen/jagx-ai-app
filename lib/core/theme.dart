import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// JagX dark theme — black + violet accent
class Jx {
  static const bg = Color(0xFF050505);
  static const surface = Color(0xFF0C0C0C);
  static const card = Color(0xFF141418);
  static const cardHover = Color(0xFF1A1A22);
  static const border = Color(0xFF2A2A32);
  static const text = Color(0xFFF4F4F5);
  static const muted = Color(0xFF9CA3AF);
  static const dim = Color(0xFF6B7280);
  static const accent = Color(0xFF8B5CF6);
  static const accentSoft = Color(0xFFA78BFA);
  static const userBubble = Color(0xFF1E1B2E);
  static const aiBubble = Color(0xFF111114);
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
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Jx.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Jx.card,
        hintStyle: const TextStyle(color: Jx.dim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Jx.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Jx.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Jx.accent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Jx.card,
        contentTextStyle: const TextStyle(color: Jx.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: Jx.border,
      chipTheme: ChipThemeData(
        backgroundColor: Jx.card,
        selectedColor: Jx.accent.withOpacity(0.25),
        labelStyle: const TextStyle(color: Jx.text, fontSize: 13),
        side: const BorderSide(color: Jx.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}
