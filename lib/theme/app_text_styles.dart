import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Light theme text styles
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: AppColors.lightOnSurfaceVariant,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: AppColors.lightOnSurfaceVariant,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: AppColors.lightOnSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: AppColors.lightOnSurfaceVariant,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  );

  /// Dark theme text styles
  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      color: AppColors.darkOnSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: AppColors.darkOnSurfaceVariant,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  );
}

