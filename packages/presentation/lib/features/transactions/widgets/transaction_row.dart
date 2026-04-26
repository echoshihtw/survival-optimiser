import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _typeColor => switch (transaction.type) {
    TransactionType.income         => SC.txIncome,
    TransactionType.openingBalance => SC.txOpeningBalance,
    TransactionType.loan           => SC.txLoan,
    TransactionType.expense        => SC.txExpense,
    TransactionType.repayment      => SC.txRepayment,
    TransactionType.investment     => SC.txInvestment,
  };

  IconData get _typeIcon => switch (transaction.type) {
    TransactionType.income         => Icons.arrow_downward_rounded,
    TransactionType.openingBalance => Icons.account_balance_rounded,
    TransactionType.loan           => Icons.credit_score_rounded,
    TransactionType.expense        => Icons.arrow_upward_rounded,
    TransactionType.repayment      => Icons.replay_rounded,
    TransactionType.investment     => Icons.trending_up_rounded,
  };

  String _typeLabel(AppLocalizations l10n) => switch (transaction.type) {
    TransactionType.expense        => l10n.typeExpense,
    TransactionType.income         => l10n.typeIncome,
    TransactionType.loan           => l10n.typeLoan,
    TransactionType.investment     => l10n.typeInvest,
    TransactionType.repayment      => l10n.typeRepay,
    TransactionType.openingBalance => l10n.typeOpening,
  };

  bool get _isPlanned =>
      transaction.date.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = context.l10n;
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final amount = NumberFormat('#,##0', 'en_US')
        .format(transaction.amount.value);
    final sign   = transaction.type.isInflow ? '+' : '-';
    final dateStr = DateFormat('dd MMM').format(transaction.date)
        .toUpperCase();
    final color  = _typeColor;

    return GestureDetector(
      onTap: onEdit,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withAlpha(40), width: 1),
              ),
              child: Icon(_typeIcon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),

            // Label + note + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(_typeLabel(l10n).toUpperCase(),
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    if (_isPlanned) ...[
                      const SizedBox(width: AppSpacing.xs),
                      PixelBadge(
                          label: 'PLANNED',
                          color: AppColors.textDim),
                    ],
                  ]),
                  if (transaction.note != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(transaction.note!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),

            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign$symbol $amount',
                  style: AppTextStyles.metricSmall
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(dateStr,
                    style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
