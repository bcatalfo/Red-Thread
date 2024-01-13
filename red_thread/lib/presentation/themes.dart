// Define color themes
import 'package:flutter/material.dart';

final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF651211));

// TODO: add dark theme
final ThemeData theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
      color: colorScheme.onSurface,
    ),
  ),
);

class ExtendedTheme {
  final ThemeData themeData;
  final Color surfaceContainerHighest;

  ExtendedTheme({required this.themeData, required this.surfaceContainerHighest});
}

// TODO: This is hacky, but it works for now
final ExtendedTheme extendedTheme = ExtendedTheme(
  themeData: theme,
  surfaceContainerHighest: const Color(0xFFF1DEDC),
);