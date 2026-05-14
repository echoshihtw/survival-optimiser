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
              child: _TransactionsHeader(
                title: l10n.transactionLog,
                subtitle: l10n.historyEntries,
                addLabel: l10n.addEntry,
                onAdd: () => _showAddMenu(context, ref),
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
    final loans = _loanChoices(ref);
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
        loans: loans,
        onSubmit: (type, amount, date, note, category, loanId) async {
          final now = DateTime.now();
          final tx = Transaction(
            id: const Uuid().v4(),
            date: date,
            type: type,
            amount: Money(amount),
            note: note,
            loanId: type == TransactionType.repayment ? loanId : null,
            category: category,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(addTransactionUseCaseProvider).execute(tx);
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Transaction? existing) {
    final loans = _loanChoices(ref, existing: existing);
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
        loans: loans,
        onSubmit: (type, amount, date, note, category, loanId) async {
          final now = DateTime.now();
          if (existing == null) {
            final tx = Transaction(
              id: const Uuid().v4(),
              date: date,
              type: type,
              amount: Money(amount),
              note: note,
              loanId: type == TransactionType.repayment ? loanId : null,
              category: category,
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
              loanId: type == TransactionType.repayment ? loanId : null,
              clearLoanId: type != TransactionType.repayment,
              category: category,
              clearCategory: category == null,
              updatedAt: now,
            );
            await ref.read(editTransactionUseCaseProvider).execute(tx);
          }
        },
      ),
    );
  }

  List<Loan> _loanChoices(WidgetRef ref, {Transaction? existing}) {
    final summaries = ref.read(loanSummariesProvider);
    final loans = activeLoanSummaries(
      summaries,
    ).map((summary) => summary.loan).toList();
    final existingLoanId = existing?.loanId;
    if (existingLoanId != null &&
        !loans.any((loan) => loan.id == existingLoanId)) {
      LoanSummary? existingSummary;
      for (final summary in summaries) {
        if (summary.loan.id == existingLoanId) {
          existingSummary = summary;
          break;
        }
      }
      if (existingSummary != null) loans.add(existingSummary.loan);
    }
    loans.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return loans;
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

class _TransactionsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String addLabel;
  final VoidCallback onAdd;

  const _TransactionsHeader({
    required this.title,
    required this.subtitle,
    required this.addLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.title,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: _HeaderAddButton(label: addLabel, onTap: onAdd),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: AppSpacing.md),
            _HeaderAddButton(label: addLabel, onTap: onAdd),
          ],
        );
      },
    );
  }
}

class _HeaderAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeaderAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                color: AppColors.background,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label.replaceFirst('+', '').trim(),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.background,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
