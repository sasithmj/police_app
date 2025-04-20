import 'package:flutter/material.dart';

// Define app color constants
class AppColors {
  // Primary colors from provided hex values
  static const Color darkBlue = Color(0xFF213555);
  static const Color mediumBlue = Color.fromARGB(255, 15, 76, 117);
  static const Color taupe = Color(0xFFD8C4B6);
  static const Color offWhite = Color(0xFFF5EFE7);

  // Additional shades for components
  static const Color lightGray = Color(0xFFE2E2E2);
  static const Color mediumGray = Color(0xFFB1B1B1);
  static const Color white = Color(0xFFFAFAFA);
  static const Color errorRed = Color(0xFFD32F2F);
}

ThemeData buildAppTheme() {
  // Base theme using Material 3
  return ThemeData(
    useMaterial3: true,

    // Color Scheme
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.darkBlue,
      onPrimary: AppColors.offWhite,
      secondary: AppColors.mediumBlue,
      onSecondary: AppColors.offWhite,
      tertiary: AppColors.taupe,
      onTertiary: AppColors.darkBlue,
      error: AppColors.errorRed,
      onError: AppColors.white,
      background: Color.fromARGB(255, 246, 250, 255),
      onBackground: AppColors.darkBlue,
      surface: Color.fromARGB(255, 253, 253, 253),
      onSurface: AppColors.darkBlue,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBlue,
      foregroundColor: AppColors.offWhite,
      elevation: 0,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.mediumBlue,
      foregroundColor: AppColors.offWhite,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.offWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mediumBlue,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.offWhite.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.mediumBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.taupe,
      thickness: 1,
      space: 1,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.offWhite,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBlue,
      selectedItemColor: AppColors.taupe,
      unselectedItemColor: AppColors.offWhite,
      type: BottomNavigationBarType.fixed,
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.mediumBlue,
      unselectedLabelColor: AppColors.mediumGray,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.mediumBlue, width: 2),
      ),
    ),

    // Other customizations
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold),
      titleLarge:
          TextStyle(color: AppColors.mediumBlue, fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.darkBlue),
      bodyMedium: TextStyle(color: AppColors.darkBlue),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.mediumBlue,
    ),
  );
}
