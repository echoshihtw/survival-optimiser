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
import '../subscriptions/subscription_form.dart';
import '../paywall/paywall_screen.dart';

class TransactionsScreen extends ConsumerWidget {
  final bool openAddOnLoad;
  final String? firstTransactionType;
  const TransactionsScreen({
    super.key,
    this.openAddOnLoad = false,
    this.firstTransactionType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncTxs = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.transactionLog, style: AppTextStyles.title),
                      Text(l10n.historyEntries, style: AppTextStyles.caption),
                    ],
                  ),
                  NeoButton(
                    label: l10n.addEntry,
                    variant: NeoButtonVariant.primary,
                    onPressed: () => _showAddMenu(context, ref),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),

            Expanded(
              child: asyncTxs.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.green,
                    strokeWidth: 1.5,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'ERROR: $e',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
                data: (txs) {
                  if (txs.isEmpty) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => _showFormWithType(
                          context,
                          ref,
                          TransactionType.openingBalance,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.textDim,
                              size: 40,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.noEntries,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '+ ADD OPENING BALANCE',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final sorted = [...txs]
                    ..sort((a, b) => b.date.compareTo(a.date));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => Dismissible(
                      key: Key(sorted[i].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.hotPink.withAlpha(30),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.hotPink,
                          size: 22,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        _confirmDelete(context, ref, sorted[i]);
                        return false; // let _confirmDelete handle deletion
                      },
                      child: TransactionRow(
                        transaction: sorted[i],
                        onEdit: () => _showForm(context, ref, sorted[i]),
                        onDelete: () => _confirmDelete(context, ref, sorted[i]),
                      ),
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

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    void openAfterClose(VoidCallback open) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) open();
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('ADD TO LOG', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              NeoButton(
                label: 'ENTRY',
                variant: NeoButtonVariant.primary,
                fullWidth: true,
                onPressed: () =>
                    openAfterClose(() => _showForm(context, ref, null)),
              ),
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: l10n.typeLoan,
                variant: NeoButtonVariant.secondary,
                color: AppColors.gold,
                fullWidth: true,
                onPressed: () =>
                    openAfterClose(() => _showLoanWizard(context, ref)),
              ),
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: l10n.subscriptions,
                variant: NeoButtonVariant.secondary,
                color: AppColors.purple,
                fullWidth: true,
                onPressed: () =>
                    openAfterClose(() => _showSubscriptionForm(context, ref)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLoanWizard(BuildContext context, WidgetRef ref) async {
    // Free users can only have 1 loan
    final isPro =
        FeatureFlags.devProEntitlement ||
        (ref.read(entitlementProvider).value?.isPro ?? false);
    if (!isPro) {
      final loans = await ref.read(loansProvider.future);
      if (!context.mounted) return;
      if (loans.isNotEmpty) {
        showPaywall(context, trigger: 'loan_limit');
        return;
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => LoanWizard(
        onSubmit: (loanAmount, monthlyPayment, termMonths, date, note) async {
          final now = DateTime.now();
          final loanId = const Uuid().v4();
          final parts = (note ?? '').split(' — ');
          final source = parts.isNotEmpty
              ? parts[0].replaceAll(' LOAN', '')
              : 'OTHER';
          final name = parts.length > 1 ? parts[1] : 'LOAN';

          final loan = Loan(
            id: loanId,
            name: name,
            source: source,
            originalAmount: loanAmount,
            monthlyPayment: monthlyPayment,
            originalTermMonths: termMonths,
            startDate: date,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addLoanUseCaseProvider).execute(loan);

          final tx = Transaction(
            id: const Uuid().v4(),
            date: date,
            type: TransactionType.loan,
            amount: Money(loanAmount),
            note: note,
            loanId: loanId,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addTransactionUseCaseProvider).execute(tx);
        },
      ),
    );
  }

  void _showSubscriptionForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => SubscriptionForm(
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          final isPro =
              FeatureFlags.devProEntitlement ||
              (ref.read(entitlementProvider).value?.isPro ?? false);
          if (!isPro) {
            showPaywall(context, trigger: 'subscriptions');
            return false;
          }

          final now = DateTime.now();
          await ref
              .read(addSubscriptionUseCaseProvider)
              .execute(
                Subscription(
                  id: const Uuid().v4(),
                  name: name,
                  category: category,
                  amount: amount,
                  cycle: cycle,
                  startDate: startDate,
                  nextBillingDate: computeNextBillingDate(startDate, cycle),
                  note: note,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          return true;
        },
      ),
    );
  }

  void _showFormWithType(
    BuildContext context,
    WidgetRef ref,
    TransactionType preselectedType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => TransactionForm(
        existing: null,
        preselectedType: preselectedType,
        onSubmit: (type, amount, date, note) async {
          final now = DateTime.now();
          final tx = Transaction(
            id: const Uuid().v4(),
            date: date,
            type: type,
            amount: Money(amount),
            note: note,
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => TransactionForm(
        existing: existing,
        onSubmit: (type, amount, date, note) async {
          final now = DateTime.now();
          if (existing == null) {
            final tx = Transaction(
              id: const Uuid().v4(),
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              createdAt: now,
              updatedAt: now,
            );
            await ref.read(addTransactionUseCaseProvider).execute(tx);
          } else {
            final tx = existing.copyWith(
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              updatedAt: now,
            );
            await ref.read(editTransactionUseCaseProvider).execute(tx);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Transaction tx) {
    final l10n = context.l10n;
    final symbol = ref.read(currencyProvider).value?.symbol ?? '¥';
    final amount = NumberFormat('#,##0', 'en_US').format(tx.amount.value);
    final sign = tx.type.isInflow ? '+' : '-';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(l10n.purgeEntry, style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.type.label.toUpperCase(), style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Text('$sign$symbol $amount', style: AppTextStyles.metric),
            if (tx.note != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(tx.note!, style: AppTextStyles.bodySmall),
            ],
            if (tx.type == TransactionType.loan) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.willRemoveLoan,
                style: AppTextStyles.caption.copyWith(color: AppColors.gold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(deleteTransactionUseCaseProvider).execute(tx.id);
              if (tx.type == TransactionType.loan && tx.loanId != null) {
                await ref.read(deleteLoanUseCaseProvider).execute(tx.loanId!);
              }
            },
            child: Text(
              l10n.delete,
              style: AppTextStyles.body.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
