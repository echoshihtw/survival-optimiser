import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Scaffold with Kraken-style teal gradient at top
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final bool safeArea;

  const GradientScaffold({
    super.key,
    required this.body,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientBackground,
        ),
        child: safeArea ? SafeArea(child: body) : body,
      ),
    );
  }
}
