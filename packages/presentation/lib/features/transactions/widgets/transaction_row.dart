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
    TransactionType.income         => AppColors.safe,
    TransactionType.openingBalance => AppColors.safe,
    TransactionType.loan           => AppColors.safe,
    TransactionType.expense        => AppColors.danger,
    TransactionType.repayment      => AppColors.caution,
    TransactionType.investment     => AppColors.gold,
  };

  String _typeLabel(AppLocalizations l10n) => switch (transaction.type) {
    TransactionType.expense        => l10n.typeExpense,
    TransactionType.income         => l10n.typeIncome,
    TransactionType.loan           => l10n.typeLoan,
    TransactionType.investment     => l10n.typeInvest,
    TransactionType.repayment      => l10n.typeRepay,
    TransactionType.openingBalance => l10n.typeOpening,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n      = context.l10n;
    final currAsync = ref.watch(currencyProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';
    final amount    = NumberFormat('#,##0', 'en_US')
        .format(transaction.amount.value);
    final sign      = transaction.type.isInflow ? '+' : '-';
    final dateStr   = DateFormat('dd MMM yyyy')
        .format(transaction.date).toUpperCase();

    return GestureDetector(
      onLongPress: onDelete,
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.panelBorder, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: AppTextStyles.label),
                Row(
                  children: [
                    Text(_typeLabel(l10n),
                        style: AppTextStyles.label
                            .copyWith(color: _typeColor)),
                    const SizedBox(width: AppSpacing.md),
                    Text('$sign$symbol $amount',
                        style: AppTextStyles.value
                            .copyWith(color: _typeColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text('${l10n.calcMonth}: ${transaction.month}',
                style: AppTextStyles.small
                    .copyWith(color: AppColors.dimGreen)),
            if (transaction.note != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text('> ${transaction.note}',
                  style: AppTextStyles.small),
            ],
          ],
        ),
      ),
    );
  }
}
