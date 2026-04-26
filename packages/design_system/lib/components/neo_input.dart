import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

class NeoInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final String? prefix;

  const NeoInput({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTextStyles.body,
          cursorColor: AppColors.green,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
          ),
        ),
      ],
    );
  }
}
