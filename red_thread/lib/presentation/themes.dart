// Define color themes
import 'package:flutter/material.dart';

final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF651211));


final ThemeData theme = ThemeData.from(
  colorScheme: colorScheme,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
  ),
);