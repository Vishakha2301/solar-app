import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme = const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}
