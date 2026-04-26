import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool glassEnabled;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    required this.accentColor,
    this.borderRadius = AppSpacing.cardRadius,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.glassEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!glassEnabled) {
      // Simple card — no blur, performant
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColors.surface,
          border: Border.all(
            color: accentColor.withAlpha(40),
            width: 1,
          ),
        ),
        padding: padding,
        child: child,
      );
    }

    // Full glass effect — GPU intensive
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(22),
                Colors.white.withAlpha(6),
              ],
            ),
            border: Border.all(
              color: Colors.white.withAlpha(30),
              width: 0.8,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
