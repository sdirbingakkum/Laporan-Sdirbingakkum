import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const background = Color(0xFF071A12);
    const surface = Color(0xFF0B2118);
    const gold = Color(0xFFF1D37A);
    const text = Color(0xFFF8F5EC);
    const muted = Color(0xFFB7C2BC);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFD7A93C),
          brightness: Brightness.dark,
        ).copyWith(
          surface: surface,
          onSurface: text,
          primary: gold,
          onPrimary: const Color(0xFF10140F),
        );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.72)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
