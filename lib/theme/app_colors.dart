import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); 

  // Primary Colors - Teal/Green family
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color primaryTealDark = Color(0xFF00897B);
  static const Color primaryTealLight = Color(0xFF4DD0E1);
  
  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF26A69A);
  static const Color secondaryTealDark = Color(0xFF00695C);
  static const Color secondaryTealLight = Color(0xFF80CBC4);

  // Accent Colors
  static const Color accentGreen = Color(0xFF69F0AE);
  static const Color accentGreenDark = Color(0xFF00E676);
  static const Color accentGreenLight = Color(0xFFB9F6CA);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE8F5E9);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF424242);
  static const Color lightOutline = Color(0xFFBDBDBD);
  static const Color lightOutlineVariant = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkOutlineVariant = Color(0xFF64748B);

  // Semantic Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF1B5E20);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1565C0);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);
}

class AppThemeColors {
  AppThemeColors._();

  /// Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primaryTeal,
    onPrimary: AppColors.onError, // White
    primaryContainer: AppColors.primaryTealLight,
    onPrimaryContainer: AppColors.primaryTealDark,
    
    secondary: AppColors.secondaryTeal,
    onSecondary: AppColors.onError, // White
    secondaryContainer: AppColors.secondaryTealLight,
    onSecondaryContainer: AppColors.secondaryTealDark,
    
    tertiary: AppColors.accentGreen,
    onTertiary: AppColors.darkBackground,
    tertiaryContainer: AppColors.accentGreenLight,
    onTertiaryContainer: AppColors.accentGreenDark,
    
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.errorDark,
    
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    
    shadow: AppColors.neutral900,
    scrim: AppColors.neutral900,
    inverseSurface: AppColors.darkSurface,
    onInverseSurface: AppColors.darkOnSurface,
    inversePrimary: AppColors.primaryTealDark,
  );

  /// Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.accentGreen,
    onPrimary: AppColors.darkBackground,
    primaryContainer: AppColors.accentGreenDark,
    onPrimaryContainer: AppColors.accentGreenLight,
    
    secondary: AppColors.secondaryTeal,
    onSecondary: AppColors.darkBackground,
    secondaryContainer: AppColors.secondaryTealDark,
    onSecondaryContainer: AppColors.secondaryTealLight,
    
    tertiary: AppColors.primaryTeal,
    onTertiary: AppColors.darkBackground,
    tertiaryContainer: AppColors.primaryTealDark,
    onTertiaryContainer: AppColors.primaryTealLight,
    
    error: AppColors.errorLight,
    onError: AppColors.onError,
    errorContainer: AppColors.error,
    onErrorContainer: AppColors.errorLight,
    
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    
    shadow: AppColors.neutral900,
    scrim: AppColors.neutral900,
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.lightOnSurface,
    inversePrimary: AppColors.primaryTeal,
  );
}

