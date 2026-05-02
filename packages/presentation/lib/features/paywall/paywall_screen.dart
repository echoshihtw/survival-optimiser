import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';

class PaywallScreen extends ConsumerWidget {
  final String trigger;
  const PaywallScreen({super.key, required this.trigger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider).value;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.neonGreen.withAlpha(50)),
            ),
            child: const Icon(Icons.rocket_launch_rounded,
                color: AppColors.neonGreen, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            _titleFor(trigger),
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          if (entitlement != null && !entitlement.isPro) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FREE ENTRIES TODAY',
                      style: AppTextStyles.label),
                  Row(children: List.generate(
                    entitlement.dailyTxLimit,
                    (i) => Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(left: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: i < entitlement.dailyTxCount
                            ? AppColors.hotPink
                            : AppColors.neonGreen.withAlpha(40),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          ..._proFeatures.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.neonGreen, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(f, style: AppTextStyles.body),
            ]),
          )),

          const SizedBox(height: AppSpacing.xl),

          NeoButton(
            label: 'START 7-DAY FREE TRIAL',
            variant: NeoButtonVariant.primary,
            fullWidth: true,
            onPressed: () {
              // TODO: wire RevenueCat
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Then \$4.99/month · Cancel anytime',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          NeoButton(
            label: 'Maybe later',
            variant: NeoButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  String _titleFor(String trigger) => switch (trigger) {
    'daily_limit'   => 'You\'ve used your\n3 free entries today.',
    'subscriptions' => 'Subscriptions is\na Pro feature.',
    'loan_limit'    => 'Multiple loans is\na Pro feature.',
    'simulation'    => 'Unlimited simulations\nis a Pro feature.',
    _               => 'Unlock Awareness Pro.',
  };

  static const _proFeatures = [
    'Unlimited daily entries',
    'Unlimited loans',
    'Subscriptions tracker',
    'Unlimited scenario simulations',
    'Cash timeline chart',
  ];
}

void showPaywall(BuildContext context, {required String trigger}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius)),
    ),
    builder: (_) => PaywallScreen(trigger: trigger),
  );
}
