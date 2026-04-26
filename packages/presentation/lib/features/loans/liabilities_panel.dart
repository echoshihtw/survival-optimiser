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
    final symbol    = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf        = NumberFormat('#,##0', 'en_US');
    final total     = ref.watch(totalMonthlyLoanPaymentProvider);
    final active    = summaries.where((s) => s.loan.isActive).toList();

    final summary = active.isEmpty
        ? Text('No active loans', style: AppTextStyles.bodySmall)
        : Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEBT/MO', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xxs),
                Text('$symbol ${nf.format(total)}',
                    style: AppTextStyles.metric
                        .copyWith(color: AppColors.gold)),
              ],
            )),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LOANS', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xxs),
                Text('${active.length} ACTIVE',
                    style: AppTextStyles.metric
                        .copyWith(color: AppColors.textSecondary)),
              ],
            )),
          ]);

    final details = active.isEmpty
        ? null
        : Column(
            children: active.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: LoanCard(
                summary: s,
                onTap: () {},
                onRepay: () => _showRepay(context, ref, s),
              ),
            )).toList(),
          );

    return NeoExpandableCard(
      title: l10n.liabilities,
      accentColor: AppColors.gold,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }

  void _showRepay(
      BuildContext context, WidgetRef ref, LoanSummary summary) {
    final amountCtrl = TextEditingController(
        text: summary.loan.monthlyPayment.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
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
            Text('REPAY LOAN', style: AppTextStyles.title
                .copyWith(color: AppColors.gold)),
            const SizedBox(height: AppSpacing.xs),
            Text(summary.loan.name.toUpperCase(),
                style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            NeoInput(
              label: 'REPAYMENT AMOUNT',
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              hint: summary.loan.monthlyPayment.toStringAsFixed(0),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(
                child: NeoButton(
                  label: 'CONFIRM',
                  variant: NeoButtonVariant.primary,
                  color: AppColors.gold,
                  fullWidth: true,
                  onPressed: () async {
                    final amount = double.tryParse(
                        amountCtrl.text.trim());
                    if (amount == null || amount <= 0) return;
                    Navigator.of(ctx).pop();
                    final now = DateTime.now();
                    final tx  = Transaction(
                      id:        const Uuid().v4(),
                      date:      now,
                      type:      TransactionType.repayment,
                      amount:    Money(amount),
                      loanId:    summary.loan.id,
                      note:      'Repayment — ${summary.loan.name}',
                      createdAt: now,
                      updatedAt: now,
                    );
                    await ref
                        .read(addTransactionUseCaseProvider)
                        .execute(tx);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NeoButton(
                  label: 'CANCEL',
                  variant: NeoButtonVariant.ghost,
                  fullWidth: true,
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
