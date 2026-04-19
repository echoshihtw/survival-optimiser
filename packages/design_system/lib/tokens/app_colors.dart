import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const background   = Color(0xFF0A0A0A);
  static const panelBorder  = Color(0xFF1A2A1A);
  static const scanline     = Color(0x08000000);

  // Text
  static const primaryGreen = Color(0xFF00FF41);
  static const dimGreen     = Color(0xFF007A1F);

  // States
  static const gold         = Color(0xFFFFD700);
  static const danger       = Color(0xFFFF3131);
  static const safe         = Color(0xFF00FFFF);

  // Status mapping
  static const stable       = primaryGreen;
  static const caution      = gold;
  static const critical     = danger;
}
