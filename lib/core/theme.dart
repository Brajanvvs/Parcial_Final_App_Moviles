import 'package:flutter/material.dart';

/// Paleta inspirada en Alkosto: azul institucional + naranja de oferta.
class AlkostoColors {
  static const navy = Color(0xFF003B7A);
  static const blue = Color(0xFF0056A4);
  static const sky = Color(0xFF0072CE);
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE55E00);
  static const surface = Color(0xFFF4F6F8);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1C2430);
  static const muted = Color(0xFF667085);
  static const chip = Color(0xFFE8EEF5);
  static const promoBar = Color(0xFFFFF1E6);
}

ThemeData buildTheme() {
  const seed = AlkostoColors.blue;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: seed,
        primary: AlkostoColors.blue,
        secondary: AlkostoColors.orange,
        surface: AlkostoColors.card,
      ).copyWith(
        primaryContainer: const Color(0xFFD6E7F8),
        secondaryContainer: const Color(0xFFFFE0C2),
        onPrimaryContainer: AlkostoColors.navy,
        onSecondaryContainer: AlkostoColors.orangeDark,
      );

  final rounded = BorderRadius.circular(12);

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: AlkostoColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AlkostoColors.navy,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: rounded),
      enabledBorder: OutlineInputBorder(
        borderRadius: rounded,
        borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: rounded,
        borderSide: const BorderSide(color: AlkostoColors.sky, width: 1.6),
      ),
    ),
    cardTheme: CardThemeData(
      color: AlkostoColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE6EBF0)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AlkostoColors.chip,
      selectedColor: AlkostoColors.blue.withValues(alpha: 0.14),
      labelStyle: const TextStyle(
        color: AlkostoColors.ink,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(color: AlkostoColors.navy),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AlkostoColors.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: rounded),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AlkostoColors.sky,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AlkostoColors.orange.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AlkostoColors.orangeDark : AlkostoColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AlkostoColors.orangeDark : AlkostoColors.muted,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AlkostoColors.navy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerColor: const Color(0xFFE4E9EF),
  );
}
