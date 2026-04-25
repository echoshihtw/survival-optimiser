import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _family = 'JetBrainsMono';

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontSize: 10,
    color: AppColors.dimGreen,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle value = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    color: AppColors.primaryGreen,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    color: AppColors.primaryGreen,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle danger = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    color: AppColors.danger,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle gold = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    color: AppColors.gold,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle safe = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    color: AppColors.safe,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle small = TextStyle(
    fontFamily: _family,
    fontSize: 10,
    color: AppColors.dimGreen,
    fontWeight: FontWeight.w400,
  );
}
