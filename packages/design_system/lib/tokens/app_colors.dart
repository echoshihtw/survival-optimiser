import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────
  static const background    = Color(0xFF080B0F);
  static const backgroundTop = Color(0xFF0D3D35);  // stronger teal glow
  static const surface       = Color(0xFF111318);
  static const surfaceHigh   = Color(0xFF1A1D24);
  static const cardBorder    = Color(0xFF1E2128);

  // ── Accents ───────────────────────────────────
  static const green         = Color(0xFF00E5A0);  // electric mint
  static const red           = Color(0xFFFF4560);
  static const gold          = Color(0xFFF0B429);
  static const blue          = Color(0xFF4C9EFF);
  static const purple        = Color(0xFF9B6DFF);

  // ── Text ─────────────────────────────────────
  static const textPrimary   = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF8080A0);
  static const textDim       = Color(0xFF404055);

  // ── Status ────────────────────────────────────
  static const stable        = green;
  static const caution       = gold;
  static const critical      = red;
  static const safe          = blue;

  // ── Gradients ─────────────────────────────────
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B4D8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientGold = LinearGradient(
    colors: [Color(0xFFF0B429), Color(0xFFFF8C00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF4C9EFF), Color(0xFF9B6DFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientRed = LinearGradient(
    colors: [Color(0xFFFF4560), Color(0xFFFF6B35)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const gradientBackground = LinearGradient(
    colors: [backgroundTop, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4],
  );

  // ── Legacy aliases ────────────────────────────
  static const primaryGreen  = green;
  static const dimGreen      = textDim;
  static const danger        = red;
  static const panelBorder   = cardBorder;
  static const scanline      = Color(0x00000000);
}
