import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// Single metric — label above, large number below
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? sublabel;
  final bool isNegative;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.sublabel,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        valueColor ?? (isNegative ? AppColors.red : AppColors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.metric.copyWith(color: color)),
        if (sublabel != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(sublabel!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
