import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

const _fontFamily = 'JetBrainsMono';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.background,
      primary: AppColors.primaryGreen,
      secondary: AppColors.dimGreen,
      error: AppColors.danger,
    ),
    fontFamily: _fontFamily,
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: _fontFamily,
      bodyColor: AppColors.primaryGreen,
      displayColor: AppColors.primaryGreen,
    ),
    dividerColor: AppColors.panelBorder,
    // Kill all Material rounded corners
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: AppColors.background,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.dimGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.dimGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.primaryGreen),
      ),
      labelStyle: TextStyle(color: AppColors.dimGreen),
    ),
    extensions: const [],
  );
}
