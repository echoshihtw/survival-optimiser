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
    final l10n   = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final budget = ref.watch(budgetProvider).value;
    final nf     = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';

    final hasActual = model.burnRate > 0;
    final hasBudget = budget != null && budget.isSet;

    // Summary — total outflow (the key supporting number)
    final summary = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOTAL / MO', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text('-${fmt(model.totalMonthlyOutflow)}',
                style: AppTextStyles.metric
                    .copyWith(color: SC.metricTotal)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('CASH', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(fmt(model.currentCash),
                style: AppTextStyles.metric
                    .copyWith(color: SC.metricCash)),
          ],
        ),
      ],
    );

    // Details
    final details = Column(
      children: [
        if (hasActual)
          _row(model.isOverBudget
              ? '${l10n.burnPerMonth} ▲'
              : l10n.burnPerMonth,
              '-${fmt(model.burnRate)}', AppColors.red),
        if (hasBudget && !hasActual)
          _row('BUDGET/MO',
              '-${fmt(budget.subtotal)}', AppColors.gold),
        if (model.subscriptionMonthlyCost > 0)
          _row(l10n.subscrPerMonth,
              '-${fmt(model.subscriptionMonthlyCost)}',
              SC.metricSubscr),
        if (model.monthlyPayment > 0)
          _row(l10n.loanPerMonth,
              '-${fmt(model.monthlyPayment)}', AppColors.gold),
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
              Text('TOTAL / MO', style: AppTextStyles.label),
              Text('-${fmt(model.totalMonthlyOutflow)}',
                  style: AppTextStyles.metricSmall
                      .copyWith(color: SC.metricTotal)),
            ],
          ),
        ),
      ],
    );

    return NeoExpandableCard(
      title: 'BREAKDOWN',
      accentColor: AppColors.blue,
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
          Text(value,
              style: AppTextStyles.metricSmall
                  .copyWith(color: color)),
        ],
      ),
    );
  }
}
