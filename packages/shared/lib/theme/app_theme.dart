import 'package:flutter/material.dart';

class AppColors {
  // Primary teal palette
  static const primary = Color(0xFF0D9488);
  static const primaryDark = Color(0xFF0F766E);
  static const primaryDeep = Color(0xFF134E4A);
  static const primaryLight = Color(0xFFE8F9F5);
  static const primarySoft = Color(0xFFCCFBF1);

  // Accent
  static const accent = Color(0xFFF97316);
  static const accentLight = Color(0xFFFFF3E0);
  static const whatsappGreen = Color(0xFF25D366);

  // Surfaces
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  // Status
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFD1FAE5);
  static const successText = Color(0xFF065F46);
  static const warning = Color(0xFFF97316);
  static const warningBg = Color(0xFFFEF9C3);
  static const warningText = Color(0xFFA16207);
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEF2F2);
  static const errorText = Color(0xFF991B1B);
  static const info = Color(0xFF2563EB);
  static const infoBg = Color(0xFFDBEAFE);

  // Legacy aliases — keeps older screens compiling
  static const navy = primaryDeep;
  static const navyMid = primary;
  static const navyLight = primaryDark;
  static const gold = accent;
  static const goldLight = Color(0xFFFDBA74);
  static const goldDim = Color(0xFFC2410C);
  static const surfaceSecondaryOld = surfaceSecondary;
  static const warningBgOld = warningBg;
  static const errorBgOld = errorBg;
}

ThemeData buildAppTheme({bool isAdmin = false}) {
  const primary = AppColors.primary;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        letterSpacing: 0.1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 0),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceSecondary,
      selectedColor: primary,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
