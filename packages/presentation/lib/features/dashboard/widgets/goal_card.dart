import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';

class GoalCard extends ConsumerWidget {
  const GoalCard({super.key, required this.model});

  final ModelState model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(runwayGoalProvider).value;
    if (goal == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final runway = model.runwayMonths.toDouble();
    final progress = calculateRunwayGoalProgress(
      runwayMonths: runway,
      targetMonths: goal.targetMonths,
    );
    final percent = calculateRunwayGoalProgressPercent(
      runwayMonths: runway,
      targetMonths: goal.targetMonths,
    );
    final achieved = progress >= 1.0;
    final color = achieved ? SC.life : AppColors.gold;
    final monthsLeft = (goal.targetMonths - runway.floor()).clamp(0, 9999);

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                goal.name.toUpperCase(),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${model.runwayMonths} / ${goal.targetMonths} mo',
              style: AppTextStyles.metricSmall.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        PixelBar(
          value: progress,
          color: color,
          segments: goal.targetMonths.clamp(4, 36),
          height: 5,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              achieved
                  ? l10n.goalReached
                  : l10n.monthsToGoal(monthsLeft),
              style: AppTextStyles.caption.copyWith(color: color),
            ),
            Text(
              '$percent%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );

    return NeoExpandableCard(
      title: l10n.goal,
      accentColor: color,
      summary: summary,
    );
  }
}
