import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get logo => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      );

  static TextStyle get badge => TextStyle(
        color: AppColors.accent,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  static TextStyle get screenTitle => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get screenSubtitle => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get sectionLabel => TextStyle(
        color: AppColors.textMuted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      );

  static TextStyle get cardTitle => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardSubtitle => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get body => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get button => TextStyle(
        color: AppColors.background,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );
}
