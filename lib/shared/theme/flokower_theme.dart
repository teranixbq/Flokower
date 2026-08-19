import 'package:flutter/material.dart';

/// Flokower Design System - Minimalist Monochrome
///
/// Philosophy: Clean, calm, professional. Black/white/gray base
/// with a single muted green accent for positive actions.
/// No pink, no purple, no oversaturated colors.

class FlokowerTheme {
  // ─── Core Palette ───
  static const Color black = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF333333);
  static const Color darkGray = Color(0xFF555555);
  static const Color mediumGray = Color(0xFF888888);
  static const Color lightGray = Color(0xFFCCCCCC);
  static const Color silver = Color(0xFFE8E8E8);
  static const Color offWhite = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Accent (muted, not oversaturated) ───
  static const Color accentGreen = Color(0xFF2D8B4E);
  static const Color accentGreenLight = Color(0xFFE8F5ED);
  static const Color accentOrange = Color(0xFFC67A2E);
  static const Color accentOrangeLight = Color(0xFFFDF3E7);
  static const Color accentRed = Color(0xFFC44536);
  static const Color accentRedLight = Color(0xFFFDECEA);
  static const Color accentBlue = Color(0xFF3A6EA5);
  static const Color accentBlueLight = Color(0xFFEBF2FA);
  static const Color accentTeal = Color(0xFF0FAC93); // Logo color

  // ─── Light Theme ───
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: black,
      onPrimary: white,
      secondary: charcoal,
      onSecondary: white,
      surface: white,
      onSurface: black,
      outline: silver,
      outlineVariant: Color(0xFFF0F0F0),
      error: accentRed,
      onError: white,
    ),
    scaffoldBackgroundColor: offWhite,
    
    // ─── AppBar ───
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),

    // ─── Bottom Navigation ───
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: black,
      unselectedItemColor: mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),

    // ─── Cards ───
    cardTheme: const CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      surfaceTintColor: Colors.transparent,
    ),

    // ─── Elevated Button ───
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentTeal,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // ─── Outlined Button ───
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: black,
        side: const BorderSide(color: silver),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // ─── Text Button ───
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: black,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // ─── Input ───
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: silver),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: silver),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentRed),
      ),
      labelStyle: const TextStyle(color: mediumGray, fontSize: 14),
      hintStyle: const TextStyle(color: lightGray, fontSize: 14),
    ),

    // ─── Dialog ───
    dialogTheme: const DialogThemeData(
      backgroundColor: white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),

    // ─── SnackBar ───
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: black,
      contentTextStyle: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),

    // ─── Chip ───
    chipTheme: ChipThemeData(
      backgroundColor: offWhite,
      selectedColor: black,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),

    // ─── Tab Bar ───
    tabBarTheme: const TabBarThemeData(
      labelColor: black,
      unselectedLabelColor: mediumGray,
      indicatorColor: black,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
