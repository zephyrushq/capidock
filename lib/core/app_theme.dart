import 'package:flutter/material.dart';

abstract final class DockColors {
  static const background = Color(0xFF100F16);
  static const rail = Color(0xFF0C0B11);
  static const surface = Color(0xFF19171F);
  static const elevated = Color(0xFF211E2A);
  static const border = Color(0xFF302B3C);
  static const purple = Color(0xFFA78BFA);
  static const primary = Color(0xFF8B5CF6);
  static const muted = Color(0xFF9D97AC);
  static const text = Color(0xFFF4F0FC);
  static const green = Color(0xFF6BD9AD);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DockColors.primary,
    brightness: Brightness.dark,
    surface: DockColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme.copyWith(
      primary: DockColors.purple,
      onPrimary: DockColors.rail,
      outline: DockColors.border,
      onSurface: DockColors.text,
    ),
    scaffoldBackgroundColor: DockColors.background,
    splashFactory: InkSparkle.splashFactory,
    dividerColor: DockColors.border,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -.8,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
      ),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, height: 1.5, color: DockColors.muted),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
      ),
    ).apply(bodyColor: DockColors.text, displayColor: DockColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: DockColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DockColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DockColors.text,
        side: const BorderSide(color: DockColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DockColors.background,
      labelStyle: const TextStyle(color: DockColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DockColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DockColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DockColors.purple),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DockColors.surface,
      showDragHandle: true,
      dragHandleColor: DockColors.muted,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DockColors.rail,
      indicatorColor: const Color(0xFF33234E),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? DockColors.purple
              : DockColors.muted,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
