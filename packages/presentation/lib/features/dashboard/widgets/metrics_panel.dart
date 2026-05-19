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
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.monthlyBurn, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '-${fmt(model.totalMonthlyOutflow)}',
          style: AppTextStyles.metric.copyWith(color: SC.numberPrimary),
        ),
      ],
    );

    final details = Column(
      children: [
        _row(
          l10n.historicalBurn,
          model.historicalMonthlyBurn > 0
              ? '-${fmt(model.historicalMonthlyBurn)}'
              : l10n.notEnoughHistory,
          AppColors.textSecondary,
        ),
        if (model.expectedMonthlyInflow != null)
          _row(
            l10n.expectedInflow,
            fmt(model.expectedMonthlyInflow!),
            SC.life,
          ),
        _row(
          l10n.fixedPressure,
          '$fixedPressure%',
          fixedPressure >= 60
              ? SC.statusCritical
              : fixedPressure >= 35
              ? AppColors.gold
              : SC.statusStable,
        ),
        if (hasActual)
          _row(
            model.isOverBudget ? l10n.actualBurnHigh : l10n.actualBurn,
            '-${fmt(model.burnRate)}',
            SC.cost,
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
      ],
    );

    return NeoExpandableCard(
      title: l10n.pressureLabel,
      accentColor: SC.cost,
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
