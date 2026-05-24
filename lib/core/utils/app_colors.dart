import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color kPrimaryPink = Color(0xFFB71A6B);
  static const Color kSoftPink = Color(0xFFFFE5F0);
  static const Color kBorderPink = Color(0xFFF5D7E4);
  static const Color kLightPink = Color(0xFFFFE3ED);

  // Existing app colors
  static const Color kTextGrey = Color(0xFF888888);
  static const Color kPageBg = Color(0xFFF8F8F8);
  static const Color kPaymentBg = Color(0xFFF5F0F4);
  static const Color kPaymentBorder = Color(0xFFD7D1D6);
  static const Color primary30Opacity = Color(0x4DB71A6B);
  static const Color orangeColor = Color(0xFFF4B400);
  static const Color yellowColor = Color(0xFFFDD835);
  static const Color lightYellowColor = Color(0xFFFFFF8D);
  static const Color lightBlack = Color(0xFF2F2929);
  static const Color redColor = Color(0xFFBC3018);
  static const Color greenColor = Color(0xFF02B935);
  static const Color lightRedColor = Color(0xFFFF645A);
  static const Color skyBlueColor = Color(0xFF1999A2);

  // Basics
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color transparentColor = Colors.transparent;

  // Light theme semantic colors
  static const Color lightScaffold = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xB3000000);
  static const Color lightBorder = Color(0xFFE9E9E9);
  static const Color lightInputFill = Color(0xFFF8F8F8);
  static const Color lightHintText = Color(0xFF757575);

  // Dark theme semantic colors
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkInputFill = Color(0xFF232323);
  static const Color darkHintText = Color(0x99FFFFFF);

  // Drawer
  static const Color lightDrawerBg = kPrimaryPink;
  static const Color darkDrawerBg = kPrimaryPink;

  static const Color lightDrawerSelectedTile = whiteColor;
  static const Color darkDrawerSelectedTile = whiteColor;

  static const Color lightDrawerSelectedText = blackColor;
  static const Color darkDrawerSelectedText = blackColor;

  static const Color lightDrawerUnselectedText = whiteColor;
  static const Color darkDrawerUnselectedText = whiteColor;

  static const Color lightThemeToggleBg = whiteColor;
  static const Color darkThemeToggleBg = kPrimaryPink;

  static const Color lightThemeToggleActive = Color(0xFFF7F1F4);
  static const Color darkThemeToggleActive = whiteColor;

  static const Color lightThemeToggleInactive = Color(0xFF8A8A8A);
  static const Color darkThemeToggleInactive = Color(0xCCFFFFFF);

  // Bottom nav
  static const Color lightBottomNavBg = kPrimaryPink;
  static const Color darkBottomNavBg = darkScaffold;

  static const Color lightBottomNavSelectedBg = whiteColor;
  static const Color darkBottomNavSelectedBg = whiteColor;

  static const Color lightBottomNavSelectedIcon = kPrimaryPink;
  static const Color darkBottomNavSelectedIcon = kPrimaryPink;

  static const Color lightBottomNavUnselectedIcon = whiteColor;
  static const Color darkBottomNavUnselectedIcon = Color(0xCCFFFFFF);

  // Search
  static const Color lightSearchBg = whiteColor;
  static const Color darkSearchBg = Color(0xFF242428);

  static const Color lightSearchText = blackColor;
  static const Color darkSearchText = whiteColor;

  static const Color lightSearchHint = Color(0xFF757575);
  static const Color darkSearchHint = Color(0x99FFFFFF);

  static const Color lightSearchBorder = kPrimaryPink;
  static const Color darkSearchBorder = kPrimaryPink;

  // Section helpers
  static const Color sectionTitleColor = blackColor;
  static const Color sectionSeeAllColor = kPrimaryPink;
}