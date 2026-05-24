import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static TextStyle regular12Text = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle regular11SalePrice = GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle regular14Text = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle regular18White = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.whiteColor,
  );

  static TextStyle light14SearchHint = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.lightHintText,
  );

  static TextStyle light16White = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.whiteColor,
  );

  static TextStyle light18HintText = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.lightHintText,
  );

  static TextStyle semi16TextWhite = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteColor,
  );

  static TextStyle semi20Primary = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle semi24White = GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteColor,
  );

  static TextStyle medium14Category = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle medium14LightPrimary = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle medium14PrimaryDark = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle medium18Header = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.kPrimaryPink,
  );

  static TextStyle medium18White = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );

  static TextStyle medium20White = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );

  // Extra helpers for new theme system
  static TextStyle body14Dark = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle body14Light = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle hint14Dark = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.darkHintText,
  );

  static TextStyle hint14Light = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.lightHintText,
  );

  static TextStyle title18Dark = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  static TextStyle title18Light = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );
}