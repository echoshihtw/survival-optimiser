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
      body: ScanlineOverlay(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.transactionLog, style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.sm),
                    Row(children: [
                      Expanded(
                        child: TerminalButton(
                          label: l10n.newEntry, icon: "+",
                          onPressed: () => _showForm(context, ref, null),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TerminalButton(
                          label: '⚡ LOAN WIZARD',
                          color: AppColors.gold,
                          onPressed: () => _showLoanWizard(context, ref),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const TerminalDivider(),
              Expanded(
                child: asyncTxs.when(
                  loading: () => Center(
                    child: Text(l10n.loading,
                        style: const TextStyle(
                            color: AppColors.dimGreen,
                            fontFamily: 'JetBrainsMono')),
                  ),
                  error: (e, _) => Center(
                    child: Text('ERROR: $e',
                        style: const TextStyle(
                            color: AppColors.danger,
                            fontFamily: 'JetBrainsMono')),
                  ),
                  data: (txs) {
                    if (txs.isEmpty) {
                      return Center(
                        child: Text(l10n.noEntries,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.small),
                      );
                    }
                    final sorted = [...txs]
                      ..sort((a, b) => b.date.compareTo(a.date));
                    return ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (_, i) => TransactionRow(
                        transaction: sorted[i],
                        onEdit: () => _showForm(context, ref, sorted[i]),
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
      ),
    );
  }

  void _showLoanWizard(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => LoanWizard(
        onSubmit: (loanAmount, monthlyPayment, date, note) async {
          final now    = DateTime.now();
          final loanId = const Uuid().v4();

          // Parse source and name from note
          final parts  = (note ?? '').split(' — ');
          final source = parts.isNotEmpty
              ? parts[0].replaceAll(' LOAN', '')
              : 'OTHER';
          final name   = parts.length > 1 ? parts[1] : 'LOAN';

          // Create loan entity
          final loan = Loan(
            id:             loanId,
            name:           name,
            source:         source,
            originalAmount: loanAmount,
            monthlyPayment: monthlyPayment,
            startDate:      date,
            note:           note,
            createdAt:      now,
            updatedAt:      now,
          );
          await ref.read(addLoanUseCaseProvider).execute(loan);

          // Create loan transaction (cash inflow)
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
          await ref.read(addTransactionUseCaseProvider).execute(tx);
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Transaction? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
            await ref.read(addTransactionUseCaseProvider).execute(tx);
          } else {
            final tx = existing.copyWith(
              date:      date,
              type:      type,
              amount:    Money(amount),
              note:      note,
              updatedAt: now,
            );
            await ref.read(editTransactionUseCaseProvider).execute(tx);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    final l10n   = context.l10n;
    final symbol = ref.read(currencyProvider).value?.symbol ?? '¥';
    final amount = NumberFormat('#,##0', 'en_US').format(tx.amount.value);
    final sign   = tx.type.isInflow ? '+' : '-';

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(l10n.purgeEntry, style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type.label, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text('$sign$symbol $amount', style: AppTextStyles.metric),
            if (tx.note != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('> ${tx.note}', style: AppTextStyles.small),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('[ N ]', style: AppTextStyles.value),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(deleteTransactionUseCaseProvider)
                  .execute(tx.id);
            },
            child: Text('[ Y ]',
                style: AppTextStyles.value
                    .copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
