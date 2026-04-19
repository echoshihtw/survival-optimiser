import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class HeartBar extends StatelessWidget {
  final int filled;
  final int total;

  const HeartBar({
    super.key,
    required this.filled,
    this.total = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = filled >= 8
        ? AppColors.gold
        : filled >= 4
            ? AppColors.caution
            : AppColors.danger;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Icon(
          isFilled ? Icons.favorite : Icons.favorite_border,
          color: isFilled ? color : AppColors.dimGreen,
          size: 16,
        );
      }),
    );
  }
}
