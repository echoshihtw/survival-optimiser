import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class MetricsPanel extends ConsumerWidget {
  final ModelState model;
  const MetricsPanel({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final budget = ref.watch(budgetProvider).value;
    final nf = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';

    final hasActual = model.burnRate > 0;
    final hasBudget = budget != null && budget.isSet;

    final fixedPressure = (model.fixedPressureRatio * 100).round();
    final flexibility = (model.flexibilityRatio * 100).round();
    final hasAssumptions =
        model.hasSustainableProjection ||
        model.expectedMonthlyBurnOverride != null;
    final summary = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.monthlyBurn, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '-${fmt(model.totalMonthlyOutflow)}',
              style: AppTextStyles.metric.copyWith(color: SC.numberPrimary),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(l10n.flexibility, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$flexibility%',
              style: AppTextStyles.metric.copyWith(color: AppColors.green),
            ),
          ],
        ),
      ],
    );

    final details = Column(
      children: [
        _row(l10n.availableCash, fmt(model.currentCash), AppColors.green),
        _row(
          l10n.historicalBurn,
          model.historicalMonthlyBurn > 0
              ? '-${fmt(model.historicalMonthlyBurn)}'
              : l10n.notEnoughHistory,
          AppColors.textSecondary,
        ),
        if (hasAssumptions)
          _row(l10n.projectionSource, l10n.usingAssumptions, AppColors.blue),
        if (model.expectedMonthlyInflow != null)
          _row(
            l10n.expectedInflow,
            fmt(model.expectedMonthlyInflow!),
            AppColors.green,
          ),
        _row(
          l10n.fixedPressure,
          '$fixedPressure%',
          fixedPressure >= 60
              ? AppColors.red
              : fixedPressure >= 35
              ? AppColors.gold
              : AppColors.green,
        ),
        if (hasActual)
          _row(
            model.isOverBudget ? l10n.actualBurnHigh : l10n.actualBurn,
            '-${fmt(model.burnRate)}',
            AppColors.red,
          ),
        if (hasBudget && !hasActual)
          _row(
            l10n.plannedEssentials,
            '-${fmt(budget.subtotal)}',
            AppColors.gold,
          ),
        if (model.subscriptionMonthlyCost > 0)
          _row(
            l10n.recurringCosts,
            '-${fmt(model.subscriptionMonthlyCost)}',
            SC.metricSubscr,
          ),
        if (model.monthlyPayment > 0)
          _row(
            l10n.debtCommitments,
            '-${fmt(model.monthlyPayment)}',
            AppColors.gold,
          ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalPerMonth, style: AppTextStyles.label),
              Text(
                '-${fmt(model.totalMonthlyOutflow)}',
                style: AppTextStyles.metricSmall.copyWith(
                  color: SC.numberPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return NeoExpandableCard(
      title: l10n.pressureFlexibility,
      accentColor: SC.accentLife,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          Text(value, style: AppTextStyles.metricSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
