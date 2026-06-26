import 'package:flutter/material.dart';

/// Central design tokens for the app.
///
/// Cursor TODO:
/// - Replace placeholder seed colors with the final brand palette.
/// - Define a distinct "paper" neutral scale (warm off-white for light mode,
///   true dark charcoal — not pure black — for dark mode canvas background).
/// - Add custom text styles for toolbar labels vs. canvas UI vs. library grid.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF3A6FF8);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F2EF),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      );
}
