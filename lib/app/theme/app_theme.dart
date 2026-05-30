import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFF6D5EF6); // premium fintech violet

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color(0xFF0E1017),
        surfaceContainerHighest: const Color(0xFF151827),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFF0B0D12), // AMOLED-ish
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

