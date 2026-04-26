import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';

class StatusBadge extends StatelessWidget {
  final SurvivalStatus status;
  const StatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
    SurvivalStatus.stable => AppColors.stable,
    SurvivalStatus.caution => AppColors.caution,
    SurvivalStatus.critical => AppColors.critical,
  };

  String _label(AppLocalizations l10n) => switch (status) {
    SurvivalStatus.stable => l10n.stable,
    SurvivalStatus.caution => l10n.caution,
    SurvivalStatus.critical => l10n.critical,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: _color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          _label(context.l10n),
          style: AppTextStyles.value.copyWith(color: _color),
        ),
      ],
    );
  }
}
