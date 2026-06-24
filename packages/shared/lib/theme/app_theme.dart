import 'package:flutter/material.dart';

class AppColors {
  // Core palette
  static const navy = Color(0xFF0A1628);
  static const navyMid = Color(0xFF152840);
  static const navyLight = Color(0xFF1E3A57);
  static const gold = Color(0xFFC9A84C);
  static const goldLight = Color(0xFFDFC278);
  static const goldDim = Color(0xFF8B6F2E);

  // Surfaces
  static const background = Color(0xFFFAF9F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF4F3F0);
  static const border = Color(0xFFE8E6E1);
  static const borderLight = Color(0xFFF0EEE9);

  // Text
  static const textPrimary = Color(0xFF0A1628);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFFADB5BD);

  // Status
  static const success = Color(0xFF0D7377);
  static const successBg = Color(0xFFE6F4F4);
  static const warning = Color(0xFF92400E);
  static const warningBg = Color(0xFFFEF3C7);
  static const error = Color(0xFF991B1B);
  static const errorBg = Color(0xFFFEF2F2);

  // Utility
  static const whatsappGreen = Color(0xFF25D366);
}

ThemeData buildAppTheme({bool isAdmin = false}) {
  final primary = isAdmin ? AppColors.gold : AppColors.navy;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: isAdmin ? AppColors.navy : AppColors.gold,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 0),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
