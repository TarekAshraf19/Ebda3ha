import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightScaffold,
    primaryColor: AppColors.kPrimaryPink,
    colorScheme: const ColorScheme.light(
      primary: AppColors.kPrimaryPink,
      surface: AppColors.lightSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightScaffold,
      foregroundColor: AppColors.blackColor,
      elevation: 0,
    ),
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightBorder,

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      isDense: true,
      contentPadding: EdgeInsets.zero,
      hintStyle: const TextStyle(
        color: AppColors.kTextGrey,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    primaryColor: AppColors.kPrimaryPink,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.kPrimaryPink,
      surface: AppColors.darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkScaffold,
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
    ),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      isDense: true,
      contentPadding: EdgeInsets.zero,
      hintStyle: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
    ),
  );
}