import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class ThisMonthCard extends ConsumerWidget {
  const ThisMonthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final flow = ref.watch(thisMonthFlowProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';

    final netColor = flow.net >= 0 ? SC.life : SC.cost;
    final netPrefix = flow.net >= 0 ? '+' : '-';

    final summary = flow.isEmpty
        ? _EmptyState(l10n: l10n)
        : Column(
            children: [
              _Row(label: l10n.cashIn, value: fmt(flow.income), color: SC.life),
              _Row(
                label: l10n.cashOut,
                value: fmt(flow.expenses),
                color: SC.cost,
              ),
              _Row(
                label: l10n.netLabel,
                value: '$netPrefix${fmt(flow.net)}',
                color: netColor,
                isLast: true,
              ),
            ],
          );

    return NeoExpandableCard(
      title: l10n.thisMonth,
      accentColor: SC.chrome,
      summary: summary,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(
            value,
            style: AppTextStyles.metricSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: SC.chrome.withAlpha(16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SC.chrome.withAlpha(45)),
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: SC.chrome,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l10n.noActivityThisMonth,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}
