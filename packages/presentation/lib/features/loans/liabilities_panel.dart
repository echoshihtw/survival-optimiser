import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'loan_card.dart';

class LiabilitiesPanel extends ConsumerWidget {
  const LiabilitiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n      = context.l10n;
    final summaries = ref.watch(loanSummariesProvider);
    final totalMo   = ref.watch(totalMonthlyLoanPaymentProvider);
    final currAsync = ref.watch(currencyProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';
    final nf        = NumberFormat('#,##0', 'en_US');
    final active    = summaries.where((s) => !s.isFullyPaid).toList();
    final paid      = summaries.where((s) => s.isFullyPaid).toList();

    return TerminalPanel(
      title: l10n.liabilities,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summaries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(l10n.noActiveLoans, style: AppTextStyles.small),
            )
          else ...[
            ...active.map((s) => LoanCard(
              summary: s,
              onTap: () {},
              onRepay: () => _showRepayForm(context, ref, s),
            )),
            if (paid.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(l10n.settled, style: AppTextStyles.label),
              ),
              ...paid.map((s) => LoanCard(
                summary: s,
                onTap: () {},
                onRepay: () {},
              )),
            ],
            const TerminalDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalDebtPerMonth, style: AppTextStyles.label),
                Text('$symbol ${nf.format(totalMo)}',
                    style: AppTextStyles.value
                        .copyWith(color: AppColors.gold)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showRepayForm(
      BuildContext context, WidgetRef ref, LoanSummary summary) {
    final l10n   = context.l10n;
    final ctrl   = TextEditingController(
        text: summary.loan.monthlyPayment.toStringAsFixed(0));
    final symbol = ref.read(currencyProvider).value?.symbol ?? '¥';
    final nf     = NumberFormat('#,##0', 'en_US');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.repayTitle}: ${summary.loan.name.toUpperCase()}',
                style: AppTextStyles.title),
            const TerminalDivider(),
            Text(
              '${l10n.remaining}: $symbol ${nf.format(summary.remainingBalance)}',
              style: AppTextStyles.value.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            TerminalInput(
              label: l10n.installment,
              controller: ctrl,
              keyboardType: TextInputType.number,
              hint: summary.loan.monthlyPayment.toStringAsFixed(0),
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(
                child: TerminalButton(
                  label: l10n.confirm,
                  color: AppColors.gold,
                  onPressed: () async {
                    final amount = double.tryParse(ctrl.text.trim());
                    if (amount == null || amount <= 0) return;
                    final now = DateTime.now();
                    final tx  = Transaction(
                      id:        const Uuid().v4(),
                      date:      now,
                      type:      TransactionType.repayment,
                      amount:    Money(amount),
                      note:      '${l10n.repay}: ${summary.loan.name}',
                      loanId:    summary.loan.id,
                      createdAt: now,
                      updatedAt: now,
                    );
                    await ref
                        .read(addTransactionUseCaseProvider)
                        .execute(tx);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TerminalButton(
                  label: l10n.abort,
                  isDestructive: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
