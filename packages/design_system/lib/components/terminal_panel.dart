import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_text_styles.dart';
import '../tokens/app_spacing.dart';

/// Wraps any widget in a box-drawing border panel.
/// Usage: TerminalPanel(title: 'SYS STATUS', child: ...)
class TerminalPanel extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;

  const TerminalPanel({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor = AppColors.panelBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        color: AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) _buildTitleBar(),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Text(
        '// $title',
        style: AppTextStyles.title,
      ),
    );
  }
}
