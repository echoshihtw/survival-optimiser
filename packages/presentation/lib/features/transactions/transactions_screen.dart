import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'widgets/transaction_row.dart';
import 'widgets/transaction_form.dart';
import 'widgets/loan_wizard.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n     = context.l10n;
    final asyncTxs = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg,
                  AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.transactionLog,
                          style: AppTextStyles.title),
                      Text('HISTORY & ENTRIES',
                          style: AppTextStyles.caption),
                    ],
                  ),
                  Row(children: [
                    NeoButton(
                      label: 'LOAN',
                      variant: NeoButtonVariant.secondary,
                      color: AppColors.gold,
                      onPressed: () => _showLoanWizard(context, ref),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    NeoButton(
                      label: '+ ADD',
                      variant: NeoButtonVariant.primary,
                      onPressed: () => _showForm(context, ref, null),
                    ),
                  ]),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),

            // List
            Expanded(
              child: asyncTxs.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.green, strokeWidth: 1.5),
                ),
                error: (e, _) => Center(
                  child: Text('ERROR: $e',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.red)),
                ),
                data: (txs) {
                  if (txs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              color: AppColors.textDim, size: 40),
                          const SizedBox(height: AppSpacing.sm),
                          Text(l10n.noEntries,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    );
                  }
                  final sorted = [...txs]
                    ..sort((a, b) => b.date.compareTo(a.date));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => TransactionRow(
                      transaction: sorted[i],
                      onEdit: () =>
                          _showForm(context, ref, sorted[i]),
                      onDelete: () =>
                          _confirmDelete(context, ref, sorted[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoanWizard(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
      builder: (_) => LoanWizard(
        onSubmit: (loanAmount, monthlyPayment, termMonths,
            date, note) async {
          final now    = DateTime.now();
          final loanId = const Uuid().v4();
          final parts  = (note ?? '').split(' — ');
          final source = parts.isNotEmpty
              ? parts[0].replaceAll(' LOAN', '') : 'OTHER';
          final name   =
              parts.length > 1 ? parts[1] : 'LOAN';

          final loan = Loan(
            id:                 loanId,
            name:               name,
            source:             source,
            originalAmount:     loanAmount,
            monthlyPayment:     monthlyPayment,
            originalTermMonths: termMonths,
            startDate:          date,
            createdAt:          now,
            updatedAt:          now,
          );
          await ref.read(addLoanUseCaseProvider).execute(loan);

          final tx = Transaction(
            id:        const Uuid().v4(),
            date:      date,
            type:      TransactionType.loan,
            amount:    Money(loanAmount),
            note:      note,
            loanId:    loanId,
            createdAt: now,
            updatedAt: now,
          );
          await ref
              .read(addTransactionUseCaseProvider)
              .execute(tx);
        },
      ),
    );
  }

  void _showForm(
      BuildContext context, WidgetRef ref, Transaction? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
      builder: (_) => TransactionForm(
        existing: existing,
        onSubmit: (type, amount, date, note) async {
          final now = DateTime.now();
          if (existing == null) {
            final tx = Transaction(
              id:        const Uuid().v4(),
              date:      date,
              type:      type,
              amount:    Money(amount),
              note:      note,
              createdAt: now,
              updatedAt: now,
            );
            await ref
                .read(addTransactionUseCaseProvider)
                .execute(tx);
          } else {
            final tx = existing.copyWith(
              date:      date,
              type:      type,
              amount:    Money(amount),
              note:      note,
              updatedAt: now,
            );
            await ref
                .read(editTransactionUseCaseProvider)
                .execute(tx);
          }
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Transaction tx) {
    final l10n   = context.l10n;
    final symbol =
        ref.read(currencyProvider).value?.symbol ?? '¥';
    final amount =
        NumberFormat('#,##0', 'en_US').format(tx.amount.value);
    final sign   = tx.type.isInflow ? '+' : '-';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius)),
        title: Text(l10n.purgeEntry, style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type.label.toUpperCase(),
                style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text('$sign$symbol $amount',
                style: AppTextStyles.metric),
            if (tx.note != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(tx.note!,
                  style: AppTextStyles.bodySmall),
            ],
            if (tx.type == TransactionType.loan) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Will also remove from liabilities',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.gold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(deleteTransactionUseCaseProvider)
                  .execute(tx.id);
              if (tx.type == TransactionType.loan &&
                  tx.loanId != null) {
                await ref
                    .read(deleteLoanUseCaseProvider)
                    .execute(tx.loanId!);
              }
            },
            child: Text('Delete',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
