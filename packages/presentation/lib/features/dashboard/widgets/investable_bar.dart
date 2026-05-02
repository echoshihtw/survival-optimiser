import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class InvestableBar extends ConsumerWidget {
  const InvestableBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol  = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf      = NumberFormat('#,##0', 'en_US');
    final txns    = ref.watch(transactionsProvider).value ?? [];

    // Sum all investment transactions
    final totalInvested = txns
        .where((t) => t.type == TransactionType.investment)
        .fold(0.0, (sum, t) => sum + t.amount.value);

    final count = txns
        .where((t) => t.type == TransactionType.investment)
        .length;

    final summary = Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOTAL INVESTED', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$symbol ${nf.format(totalInvested)}',
              style: AppTextStyles.metric
                  .copyWith(color: AppColors.turkishBlue),
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENTRIES', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$count',
              style: AppTextStyles.metric
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    ]);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (count == 0)
          Text('No investments logged yet',
              style: AppTextStyles.bodySmall)
        else
          ...txns
              .where((t) => t.type == TransactionType.investment)
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.note ?? 'Investment',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          '$symbol ${nf.format(t.amount.value)}',
                          style: AppTextStyles.metricSmall
                              .copyWith(
                                  color: AppColors.turkishBlue),
                        ),
                      ],
                    ),
                  )),
      ],
    );

    return NeoExpandableCard(
      title: 'INVESTMENTS',
      accentColor: SC.accentNeutral,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }
}
