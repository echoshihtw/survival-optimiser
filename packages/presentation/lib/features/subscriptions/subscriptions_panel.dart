import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'subscription_form.dart';

class SubscriptionsPanel extends ConsumerWidget {
  const SubscriptionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n      = context.l10n;
    final asyncSubs = ref.watch(subscriptionsProvider);
    final currAsync = ref.watch(currencyProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';
    final nf        = NumberFormat('#,##0', 'en_US');
    final subs      = asyncSubs.value ?? [];
    final active    = subs.where((s) => s.isActive).toList();
    final monthly   = totalSubscriptionMonthlyCost(active);
    final yearly    = totalSubscriptionYearlyCost(active);

    return TerminalPanel(
      title: l10n.subscriptions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add button
          Align(
            alignment: Alignment.centerRight,
            child: TerminalButton(
              label: l10n.newSubscription,
              color: AppColors.safe,
              onPressed: () => _showForm(context, ref, null),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (active.isEmpty)
            Text(l10n.noSubscriptions, style: AppTextStyles.small)
          else ...[
            ...sortedByNextBilling(active).map((s) =>
                _SubscriptionRow(
                  subscription: s,
                  symbol: symbol,
                  nf: nf,
                  onTap: () => _showForm(context, ref, s),
                  onDelete: () => _confirmDelete(context, ref, s),
                )),
            const TerminalDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalPerMonth, style: AppTextStyles.label),
                Text('$symbol ${nf.format(monthly)}',
                    style: AppTextStyles.value
                        .copyWith(color: AppColors.safe)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalPerYear, style: AppTextStyles.label),
                Text('$symbol ${nf.format(yearly)}',
                    style: AppTextStyles.value
                        .copyWith(color: AppColors.dimGreen)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showForm(
      BuildContext context, WidgetRef ref, Subscription? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => SubscriptionForm(
        existing: existing,
        onSubmit: (name, category, amount, cycle, startDate, note) async {
          final now  = DateTime.now();
          final next = computeNextBillingDate(startDate, cycle);
          if (existing == null) {
            final sub = Subscription(
              id:              const Uuid().v4(),
              name:            name,
              category:        category,
              amount:          amount,
              cycle:           cycle,
              startDate:       startDate,
              nextBillingDate: next,
              note:            note,
              createdAt:       now,
              updatedAt:       now,
            );
            await ref.read(addSubscriptionUseCaseProvider).execute(sub);
          } else {
            final sub = existing.copyWith(
              name:            name,
              category:        category,
              amount:          amount,
              cycle:           cycle,
              startDate:       startDate,
              nextBillingDate: next,
              note:            note,
              updatedAt:       now,
            );
            await ref.read(editSubscriptionUseCaseProvider).execute(sub);
          }
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Subscription sub) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(l10n.purgeEntry, style: AppTextStyles.title),
        content: Text(sub.name.toUpperCase(),
            style: AppTextStyles.value.copyWith(color: AppColors.safe)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('[ N ]', style: AppTextStyles.value),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(deleteSubscriptionUseCaseProvider)
                  .execute(sub.id);
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

class _SubscriptionRow extends StatelessWidget {
  final Subscription subscription;
  final String symbol;
  final NumberFormat nf;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SubscriptionRow({
    required this.subscription,
    required this.symbol,
    required this.nf,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n     = context.l10n;
    final s        = subscription;
    final monthly  = nf.format(s.monthlyEquivalent);
    final original = nf.format(s.amount);
    final days     = s.daysUntilNextBilling;
    final cycleLabel = _cycleLabel(s.cycle, l10n);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.panelBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Category indicator
            Container(
              width: 3,
              height: 36,
              color: s.category == SubscriptionCategory.personal
                  ? AppColors.safe
                  : AppColors.gold,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name.toUpperCase(),
                          style: AppTextStyles.value
                              .copyWith(color: AppColors.safe)),
                      Text('$symbol $original / $cycleLabel',
                          style: AppTextStyles.small),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '≈ $symbol $monthly /${l10n.monthly}',
                        style: AppTextStyles.small
                            .copyWith(color: AppColors.dimGreen),
                      ),
                      Text(
                        '$days ${l10n.subscriptionDaysLeft}',
                        style: AppTextStyles.small.copyWith(
                          color: days <= 7
                              ? AppColors.danger
                              : days <= 14
                                  ? AppColors.caution
                                  : AppColors.dimGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cycleLabel(BillingCycle c, AppLocalizations l10n) => switch (c) {
    BillingCycle.weekly    => l10n.weekly,
    BillingCycle.monthly   => l10n.monthly,
    BillingCycle.quarterly => l10n.quarterly,
    BillingCycle.yearly    => l10n.yearly,
  };
}
