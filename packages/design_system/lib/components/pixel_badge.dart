import 'package:flutter/material.dart';
import '../tokens/app_text_styles.dart';
import '../tokens/app_spacing.dart';

class PixelBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulse;

  const PixelBadge({
    super.key,
    required this.label,
    required this.color,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600,
                      letterSpacing: 1.0)),
        ],
      ),
    );
  }
}
