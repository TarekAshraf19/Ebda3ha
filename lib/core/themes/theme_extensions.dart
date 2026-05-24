import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

extension ThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get appScaffoldBg =>
      isDark ? AppColors.darkScaffold : AppColors.lightScaffold;

  Color get appSurface =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get appCard =>
      isDark ? AppColors.darkCard : AppColors.lightCard;

  Color get appTextPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get appTextSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get appDivider =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get appSearchBg =>
      isDark ? AppColors.darkSearchBg : AppColors.lightSearchBg;

  Color get appSearchText =>
      isDark ? AppColors.darkSearchText : AppColors.lightSearchText;

  Color get appSearchHint =>
      isDark ? AppColors.darkSearchHint : AppColors.lightSearchHint;

  Color get appBottomNavBg =>
      isDark ? AppColors.darkBottomNavBg : AppColors.lightBottomNavBg;
}