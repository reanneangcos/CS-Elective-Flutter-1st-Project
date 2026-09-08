import 'package:flutter/material.dart';

/// Central design system for the whole application.
///
/// Screens never declare their own colors. Both modes use the same component
/// and typography rules, while their ColorSchemes provide light/dark values.
abstract final class AppTheme {
  // Private palette tokens keep raw color values in this file only.
  static const _ink = Color(0xFF0A0A0A);
  static const _paper = Color(0xFFFFFFFF);
  static const _white = Color(0xFFFFFFFF);
  static const _lime = Color(0xFFD5FF3F);
  static const _lightPanel = Color(0xFFF4F4F1);
  static const _darkPanel = Color(0xFF171717);
  static const _lightOutline = Color(0xFFE1E1DC);
  static const _darkOutline = Color(0xFF3D3D3D);
  static const _error = Color(0xFFFF554A);

  static final ThemeData light = _build(
    const ColorScheme(
      brightness: Brightness.light,
      primary: _ink,
      onPrimary: _white,
      secondary: _lime,
      onSecondary: _ink,
      error: _error,
      onError: _white,
      surface: _paper,
      onSurface: _ink,
      surfaceContainer: _lightPanel,
      outline: _lightOutline,
    ),
  );

  static final ThemeData dark = _build(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: _white,
      onPrimary: _ink,
      secondary: _lime,
      onSecondary: _ink,
      error: _error,
      onError: _ink,
      surface: _ink,
      onSurface: _white,
      surfaceContainer: _darkPanel,
      outline: _darkOutline,
    ),
  );

  static ThemeData _build(ColorScheme colors) {
    // Material 3 supplies accessible defaults that we customize consistently.
    final base = ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
    );

    // copyWith defines shared styling for every AppBar, Card, button, chip,
    // search field, menu, divider, and snackbar in the application.
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.2,
        ),
        shape: Border(
          bottom: BorderSide(color: colors.outline.withValues(alpha: 0.55)),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.outline),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontSize: 38,
          height: 1.05,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: colors.outline),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surface,
        selectedColor: colors.secondary,
        side: BorderSide(color: colors.outline),
        shape: const StadiumBorder(),
        labelStyle: base.textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
        // ChoiceChip uses this style while selected. `onSecondary` is dark
        // enough to remain readable on the lime secondary color in both modes.
        secondaryLabelStyle: base.textTheme.labelMedium?.copyWith(
          color: colors.onSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.outline, thickness: 1),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(colors.surfaceContainer),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.outline),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.onSurface,
        contentTextStyle: TextStyle(color: colors.surface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
