import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get label => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    color: AppColors.dimGreen,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get value => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get metric => GoogleFonts.jetBrainsMono(
    fontSize: 18,
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get title => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    color: AppColors.primaryGreen,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get danger => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    color: AppColors.danger,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get gold => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    color: AppColors.gold,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get safe => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    color: AppColors.safe,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get small => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    color: AppColors.dimGreen,
    fontWeight: FontWeight.w400,
  );
}
