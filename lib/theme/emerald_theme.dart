import 'package:flutter/material.dart';

abstract final class EmeraldTheme {
  static const forest = Color(0xFF123E32);
  static const dark = Color(0xFF193C34);
  static const green = Color(0xFF287457);
  static const mint = Color(0xFFBBD7AC);
  static const paper = Color(0xFFF4F3DE);
  static const ink = Color(0xFF2A463D);
  static const muted = Color(0xFF647366);
  static const line = Color(0xFFB7C6A6);
  static const red = Color(0xFFC85A4D);

  static TextStyle pixel(double size, {Color color = ink}) => TextStyle(
    fontFamily: 'Silkscreen',
    fontSize: size,
    height: 1.35,
    color: color,
  );

  static final theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'SpaceMono',
    scaffoldBackgroundColor: forest,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      surface: paper,
      onSurface: ink,
      primary: green,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 13, color: ink),
      bodySmall: TextStyle(fontSize: 11, color: muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: green,
        foregroundColor: paper,
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(),
        textStyle: pixel(12),
      ),
    ),
  );
}
