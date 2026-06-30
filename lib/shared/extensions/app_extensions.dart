import 'package:flutter/material.dart';

/// Useful extensions on [Color] for hex conversion and manipulation.
extension ColorX on Color {
  /// Returns a '#RRGGBB' hex string (no alpha).
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${a.round().toRadixString(16).padLeft(2, '0')}'
          '${r.round().toRadixString(16).padLeft(2, '0')}'
          '${g.round().toRadixString(16).padLeft(2, '0')}'
          '${b.round().toRadixString(16).padLeft(2, '0')}';
    }
    return '#${r.round().toRadixString(16).padLeft(2, '0')}'
        '${g.round().toRadixString(16).padLeft(2, '0')}'
        '${b.round().toRadixString(16).padLeft(2, '0')}';
  }

  /// Parses '#RRGGBB' or '#AARRGGBB' hex strings.
  static Color fromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    throw FormatException('Invalid hex color: $hex');
  }

  /// Returns [true] if the color's luminance is dark (useful for deciding
  /// whether overlaid text should be white or black).
  bool get isDark => computeLuminance() < 0.5;

  /// Returns the contrast color (black or white) that's most readable on top.
  Color get contrastColor => isDark ? Colors.white : Colors.black;

  /// Returns a copy of this color with adjusted opacity.
  Color withAlpha01(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// Useful extensions on [BuildContext].
extension BuildContextX on BuildContext {
  // ── Size helpers ─────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  // ── Theme helpers ─────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Navigation helpers ─────────────────────────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> pushNamed<T>(String route, {Object? args}) =>
      Navigator.of(this).pushNamed<T>(route, arguments: args);

  // ── SnackBar ──────────────────────────────────────────────────────────
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Useful extensions on [Duration].
extension DurationX on Duration {
  /// Creates a [Future] that completes after this duration.
  Future<void> get wait => Future.delayed(this);
}

/// Useful extensions on [double] for angle conversions.
extension DoubleAngleX on double {
  double get toRadians => this * 3.141592653589793 / 180.0;
  double get toDegrees => this * 180.0 / 3.141592653589793;
}
