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
    final l10n      = context.l10n;
    final currAsync = ref.watch(currencyProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';
    final budget    = budgetAsync.value;
    final nf        = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';
    String fmtDate(DateTime? d) =>
        d == null ? 'N/A' : DateFormat('MMM yyyy').format(d).toUpperCase();

    String fmtRunway(int months) {
      if (months >= 9999) return '∞';
      if (months >= 24) return '${(months / 12).toStringAsFixed(1)} YRS';
      return '$months ${l10n.months}';
    }

    Color runwayColor() => switch (model.survivalStatus) {
      SurvivalStatus.stable   => AppColors.stable,
      SurvivalStatus.caution  => AppColors.caution,
      SurvivalStatus.critical => AppColors.critical,
    };

    final hasActual    = model.burnRate > 0;
    final hasBudget    = budget != null && budget.isSet;
    final isOverBudget = model.isOverBudget;

    return TerminalPanel(
      title: l10n.metrics,
      child: Column(
        children: [
          _row(l10n.cash,
              fmt(model.currentCash),             AppColors.primaryGreen),

          // Actual spending (from transactions)
          if (hasActual)
            _row(
              isOverBudget
                  ? '${l10n.burnPerMonth} ▲'
                  : l10n.burnPerMonth,
              '-${fmt(model.burnRate)}',
              isOverBudget ? AppColors.danger : AppColors.danger,
            ),

          // Budget baseline (rent + living) when no actual yet
          if (hasBudget && !hasActual)
            _row('BUDGET/MO',
                '-${fmt(budget.subtotal)}',
                AppColors.caution),

          // Subscriptions
          if (model.subscriptionMonthlyCost > 0)
            _row(l10n.subscrPerMonth,
                '-${fmt(model.subscriptionMonthlyCost)}', AppColors.safe),

          // Debt
          if (model.monthlyPayment > 0)
            _row(l10n.loanPerMonth,
                '-${fmt(model.monthlyPayment)}',   AppColors.gold),

          // Divider + total
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(color: AppColors.panelBorder, height: 1),
          ),
          _row('TOTAL/MO',
              '-${fmt(model.totalMonthlyOutflow)}', AppColors.danger),

          const SizedBox(height: AppSpacing.xs),
          _row(l10n.runway,
              fmtRunway(model.runwayMonths),       runwayColor()),
          _row(l10n.runOut,
              fmtDate(model.runOutDate),           AppColors.dimGreen),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value,
              style: AppTextStyles.value.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
