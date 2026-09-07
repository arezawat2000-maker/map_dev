import 'package:flutter/material.dart';

/// MAP.DEV brand theme.
class MapDevTheme {
  static const Color bgDeep = Color(0xFF0D1117);
  static const Color bgPanel = Color(0xFF161B22);
  static const Color border = Color(0xFF30363D);
  static const Color cyan = Color(0xFF58A6FF);
  static const Color green = Color(0xFF3FB950);
  static const Color amber = Color(0xFFD29922);
  static const Color red = Color(0xFFF85149);
  static const Color muted = Color(0xFF8B949E);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      appBarTheme: AppBarTheme(
        backgroundColor: bgPanel,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: cyan,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        iconTheme: const IconThemeData(color: cyan),
      ),
      cardTheme: CardThemeData(
        color: bgPanel,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgPanel,
        labelStyle: const TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: red),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: bgDeep,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyan,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: green,
        surface: bgPanel,
        error: red,
      ),
      dividerColor: border,
    );
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'in_progress':
        return cyan;
      case 'completed':
        return green;
      case 'declined':
        return red;
      case 'pending':
      case 'reviewing':
      default:
        return muted;
    }
  }
}
