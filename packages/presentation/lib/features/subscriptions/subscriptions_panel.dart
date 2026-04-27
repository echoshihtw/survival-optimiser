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
    final l10n   = context.l10n;
    final subs   = ref.watch(subscriptionsProvider).value ?? [];
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf     = NumberFormat('#,##0', 'en_US');
    final active = subs.where((s) => s.isActive).toList();
    final monthly = totalSubscriptionMonthlyCost(active);
    final yearly  = totalSubscriptionYearlyCost(active);

    // Show category tags only when both personal AND business exist
    final hasPersonal  = active.any(
        (s) => s.category == SubscriptionCategory.personal);
    final hasBusiness  = active.any(
        (s) => s.category == SubscriptionCategory.business);
    final showCatLabel = hasPersonal && hasBusiness;

    final summary = active.isEmpty
        ? Text(l10n.noSubscriptions, style: AppTextStyles.bodySmall)
        : Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.subscrPerMonth, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xxs),
                Text('$symbol ${nf.format(monthly)}',
                    style: AppTextStyles.metric
                        .copyWith(color: AppColors.purple)),
              ],
            )),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.subscrPerYear, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xxs),
                Text('$symbol ${nf.format(yearly)}',
                    style: AppTextStyles.metric
                        .copyWith(color: AppColors.textSecondary)),
              ],
            )),
          ]);

    final details = Column(
      children: [
        NeoButton(
          label: l10n.newSubscription,
          variant: NeoButtonVariant.ghost,
          fullWidth: true,
          onPressed: () => _showForm(context, ref, null),
        ),
        if (active.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ...sortedByNextBilling(active).map((s) => _SubRow(
            sub: s,
            symbol: symbol,
            nf: nf,
            showCategoryLabel: showCatLabel,
            onTap: () => _showForm(context, ref, s),
            onDelete: () => _delete(context, ref, s),
          )),
        ],
      ],
    );

    return NeoExpandableCard(
      title: l10n.subscriptions,
      accentColor: AppColors.purple,
      initiallyExpanded: false,
      summary: summary,
      details: details,
    );
  }

  void _showForm(BuildContext context, WidgetRef ref,
      Subscription? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
      builder: (_) => SubscriptionForm(
        existing: existing,
        onSubmit: (name, category, amount, cycle,
            startDate, note) async {
          final now  = DateTime.now();
          final next = computeNextBillingDate(startDate, cycle);
          if (existing == null) {
            await ref
                .read(addSubscriptionUseCaseProvider)
                .execute(Subscription(
                  id: const Uuid().v4(),
                  name: name,
                  category: category,
                  amount: amount,
                  cycle: cycle,
                  startDate: startDate,
                  nextBillingDate: next,
                  note: note,
                  createdAt: now,
                  updatedAt: now,
                ));
          } else {
            await ref
                .read(editSubscriptionUseCaseProvider)
                .execute(existing.copyWith(
                  name: name,
                  category: category,
                  amount: amount,
                  cycle: cycle,
                  startDate: startDate,
                  nextBillingDate: next,
                  note: note,
                  updatedAt: now,
                ));
          }
        },
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref, Subscription sub) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius)),
        title: Text(l10n.removeConfirm, style: AppTextStyles.title),
        content: Text(sub.name,
            style: AppTextStyles.body
                .copyWith(color: AppColors.purple)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(deleteSubscriptionUseCaseProvider)
                  .execute(sub.id);
            },
            child: Text(l10n.remove,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.hotPink)),
          ),
        ],
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final Subscription sub;
  final String symbol;
  final NumberFormat nf;
  final bool showCategoryLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SubRow({
    required this.sub,
    required this.symbol,
    required this.nf,
    required this.onTap,
    required this.onDelete,
    this.showCategoryLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n      = context.l10n;
    final days      = sub.daysUntilNextBilling;
    final daysColor = days <= 7
        ? AppColors.hotPink
        : days <= 14
            ? AppColors.gold
            : AppColors.textDim;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder),
          ),
        ),
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(3),
            ),
            margin: const EdgeInsets.only(
                right: AppSpacing.sm, top: 2),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(sub.name.toUpperCase(),
                      style: AppTextStyles.body),
                  if (showCategoryLabel) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withAlpha(20),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: AppColors.purple
                                .withAlpha(60)),
                      ),
                      child: Text(
                        sub.category == SubscriptionCategory.personal
                            ? l10n.personal
                            : l10n.business,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.purple,
                            fontSize: 9),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${sub.cycle.label} · '
                  '$symbol ${nf.format(sub.amount)} · '
                  '≈ $symbol ${nf.format(sub.monthlyEquivalent)}/mo',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '$days d',
            style: AppTextStyles.caption
                .copyWith(color: daysColor),
          ),
        ]),
      ),
    );
  }
}
