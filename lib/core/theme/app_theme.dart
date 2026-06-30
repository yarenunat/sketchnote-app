import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for the SketchNote app.
///
/// Inspired by Paper by WeTransfer's minimal, warm, analog aesthetic:
/// cream backgrounds, warm grays, rich ink blacks, and serif typography.
class AppColors {
  AppColors._();

  // ── Light Mode ──────────────────────────────────────────────────────────
  static const Color cream = Color(0xFFF5F0E8);         // Main background
  static const Color parchment = Color(0xFFEDE7D9);     // Card/surface
  static const Color warmWhite = Color(0xFFFAF7F2);     // Canvas/page
  static const Color warmGray100 = Color(0xFFE8E0D5);   // Dividers, borders
  static const Color warmGray300 = Color(0xFFB8A99A);   // Disabled, placeholder
  static const Color warmGray500 = Color(0xFF8B7B6B);   // Secondary text
  static const Color warmGray700 = Color(0xFF5C4A3A);   // Primary text (dark warm)
  static const Color inkBlack = Color(0xFF1A1614);      // Headings, primary actions
  static const Color softBlack = Color(0xFF2D2926);     // Body text

  // ── Dark Mode ────────────────────────────────────────────────────────────
  static const Color darkSlate = Color(0xFF1E2028);     // Main background
  static const Color darkSurface = Color(0xFF282C36);   // Card/surface
  static const Color darkElevated = Color(0xFF323848);  // Elevated components
  static const Color darkBorder = Color(0xFF3D4455);    // Dividers
  static const Color darkMuted = Color(0xFF6B7280);     // Muted text
  static const Color darkSecondary = Color(0xFF9CA3AF); // Secondary text
  static const Color darkPrimary = Color(0xFFE5E7EB);   // Primary text

  // ── Accent & Brand ───────────────────────────────────────────────────────
  static const Color accent = Color(0xFFD4845A);        // Warm terracotta accent
  static const Color accentLight = Color(0xFFE8A882);   // Light accent
  static const Color accentDark = Color(0xFFB5623D);    // Dark accent
  static const Color success = Color(0xFF4CAF82);       // Success green
  static const Color error = Color(0xFFE05C5C);         // Error red

  // ── Drawing palette (Paper app inspired) ────────────────────────────────
  static const List<Color> defaultPalette = [
    Color(0xFF1A1614), // Ink Black
    Color(0xFF5C4A3A), // Warm Brown
    Color(0xFFE05C5C), // Soft Red
    Color(0xFFE8934A), // Amber Orange
    Color(0xFFE8C94A), // Warm Yellow
    Color(0xFF4CAF82), // Sage Green
    Color(0xFF4A90C4), // Slate Blue
    Color(0xFF9B6DB5), // Soft Purple
    Color(0xFFE8A882), // Peach
    Color(0xFFFFFFFF), // White
  ];

  // ── Paper textures (journal cover gradients) ────────────────────────────
  static const List<List<Color>> coverGradients = [
    [Color(0xFF8B1A1A), Color(0xFFFFD700)],   // Deep burgundy / gold
    [Color(0xFF1B3A6B), Color(0xFF7EB8F7)],   // Navy / sky blue
    [Color(0xFF1F4E3D), Color(0xFFA8E6CF)],   // Forest green / mint
    [Color(0xFF4A1C40), Color(0xFFE8A0C0)],   // Plum / rose
    [Color(0xFF8B4513), Color(0xFFF4A261)],   // Saddle brown / amber
    [Color(0xFF2D3250), Color(0xFF7B8FD4)],   // Slate navy / periwinkle
    [Color(0xFF3D1C02), Color(0xFFD4A57A)],   // Dark leather / tan
    [Color(0xFF0D3B2E), Color(0xFF52B788)],   // Cypress / sage
    [Color(0xFF2C1654), Color(0xFFB882E8)],   // Deep violet / lavender
    [Color(0xFF1A3A2A), Color(0xFF82C8A8)],   // Deep forest / mint
  ];
}

class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageFlip = Duration(milliseconds: 380);
}

class AppCurves {
  AppCurves._();
  static const Curve spring = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve snappy = Curves.easeOutCubic;
  static const Curve gentle = Curves.easeInOutSine;
}

/// Central design tokens for the app.
class AppTheme {
  AppTheme._();

  // ── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.inkBlack,
        onPrimary: AppColors.warmWhite,
        primaryContainer: AppColors.warmGray100,
        onPrimaryContainer: AppColors.inkBlack,
        secondary: AppColors.accent,
        onSecondary: AppColors.warmWhite,
        secondaryContainer: AppColors.accentLight,
        onSecondaryContainer: AppColors.inkBlack,
        tertiary: AppColors.warmGray500,
        onTertiary: AppColors.warmWhite,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: AppColors.error,
        surface: AppColors.parchment,
        onSurface: AppColors.softBlack,
        surfaceContainerHighest: AppColors.warmGray100,
        outline: AppColors.warmGray300,
        outlineVariant: AppColors.warmGray100,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.inkBlack,
        onInverseSurface: AppColors.cream,
        inversePrimary: AppColors.warmGray300,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.inkBlack, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.inkBlack, size: 22),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.inkBlack,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.parchment,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.warmGray100, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.inkBlack,
        foregroundColor: AppColors.warmWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warmGray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warmGray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inkBlack, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.warmGray500),
        hintStyle: const TextStyle(color: AppColors.warmGray300),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.warmGray100,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inkBlack,
        contentTextStyle: const TextStyle(color: AppColors.warmWhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.warmWhite,
        modalBackgroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.warmGray500,
        textColor: AppColors.softBlack,
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkSlate,
        primaryContainer: AppColors.darkElevated,
        onPrimaryContainer: AppColors.darkPrimary,
        secondary: AppColors.accentLight,
        onSecondary: AppColors.darkSlate,
        secondaryContainer: AppColors.accentDark,
        onSecondaryContainer: AppColors.warmWhite,
        tertiary: AppColors.darkMuted,
        onTertiary: AppColors.darkPrimary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkPrimary,
        surfaceContainerHighest: AppColors.darkElevated,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkElevated,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.darkPrimary,
        onInverseSurface: AppColors.darkSlate,
        inversePrimary: AppColors.darkSlate,
      ),
      scaffoldBackgroundColor: AppColors.darkSlate,
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkPrimary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.darkPrimary, size: 22),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.darkPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        // Paper pages stay white/warm even in dark mode — like real paper
        color: AppColors.warmWhite,
        elevation: 12,
        shadowColor: Colors.black.withAlpha(100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkSlate,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.darkMuted),
        hintStyle: const TextStyle(color: AppColors.darkBorder),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkElevated,
        contentTextStyle: const TextStyle(color: AppColors.darkPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.darkMuted,
        textColor: AppColors.darkPrimary,
      ),
    );
  }

  // ── Typography ──────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final headingColor = isDark ? AppColors.darkPrimary : AppColors.inkBlack;
    final bodyColor = isDark ? AppColors.darkSecondary : AppColors.softBlack;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.warmGray500;

    return TextTheme(
      // Serif display headings — the "Paper by WeTransfer" signature
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57, fontWeight: FontWeight.w700,
        color: headingColor, letterSpacing: -0.5, height: 1.12,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 45, fontWeight: FontWeight.w700,
        color: headingColor, letterSpacing: -0.3, height: 1.16,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: -0.2, height: 1.22,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: -0.2, height: 1.25,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: -0.1, height: 1.29,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: headingColor, height: 1.33,
      ),
      // Sans-serif body — clean, readable
      titleLarge: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: -0.1, height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: 0.1, height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: headingColor, letterSpacing: 0.1, height: 1.43,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: bodyColor, height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: bodyColor, height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: mutedColor, height: 1.33,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: headingColor, letterSpacing: 0.1, height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: headingColor, letterSpacing: 0.5, height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: mutedColor, letterSpacing: 0.5, height: 1.45,
      ),
    );
  }
}
