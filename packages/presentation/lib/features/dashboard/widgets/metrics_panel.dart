import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MetricsPanel extends ConsumerWidget {
  final ModelState model;
  const MetricsPanel({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n     = context.l10n;
    final currAsync = ref.watch(currencyProvider);
    final symbol   = currAsync.value?.symbol ?? '¥';

    String fmt(double v) =>
        '$symbol ${NumberFormat('#,##0', 'en_US').format(v.abs())}';

    String fmtDate(DateTime? d) =>
        d == null ? 'N/A' : DateFormat('MMM yyyy').format(d).toUpperCase();

    Color runwayColor() => switch (model.survivalStatus) {
      SurvivalStatus.stable   => AppColors.stable,
      SurvivalStatus.caution  => AppColors.caution,
      SurvivalStatus.critical => AppColors.critical,
    };

    return TerminalPanel(
      title: l10n.metrics,
      child: Column(
        children: [
          _row(l10n.cash,         fmt(model.currentCash),              AppColors.primaryGreen),
          _row(l10n.burnPerMonth, '-${fmt(model.burnRate)}',           AppColors.danger),
          _row(l10n.loanPerMonth, '-${fmt(model.monthlyPayment)}',     AppColors.caution),
          _row(l10n.runway,       '${model.runwayMonths} ${l10n.months}', runwayColor()),
          _row(l10n.runOut,       fmtDate(model.runOutDate),           AppColors.dimGreen),
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
          Text(value, style: AppTextStyles.value.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
