import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MAP.DEV brand theme — dark liquid glass.
class MapDevTheme {
  static const Color bgDeep = Color(0xFF0A0E14);
  static const Color bgPanel = Color(0xFF161B22);
  static const Color border = Color(0xFF30363D);
  static const Color cyan = Color(0xFF58A6FF);
  static const Color green = Color(0xFF3FB950);
  static const Color amber = Color(0xFFD29922);
  static const Color red = Color(0xFFF85149);
  static const Color muted = Color(0xFF8B949E);
  static const Color glassText = Color(0xFFF0F4F8);

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: green,
        surface: bgPanel,
        error: red,
        onPrimary: Colors.white,
        onSurface: glassText,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: glassText,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: glassText),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyan, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: red),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: glassText,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgPanel,
        contentTextStyle: const TextStyle(color: glassText),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.12),
      textTheme: base.textTheme.apply(
        bodyColor: glassText,
        displayColor: glassText,
      ),
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
