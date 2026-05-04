import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config_screen.dart';

const _kDismissedKey = 'getting_started_dismissed';


class GettingStartedCard extends ConsumerStatefulWidget {
  const GettingStartedCard({super.key});

  @override
  ConsumerState<GettingStartedCard> createState() =>
      _GettingStartedCardState();
}

class _GettingStartedCardState extends ConsumerState<GettingStartedCard> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _loadDismissed();
  }

  Future<void> _loadDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_kDismissedKey) ?? false;
    if (dismissed && mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final txns     = ref.watch(transactionsProvider).value ?? [];
    final budget   = ref.watch(budgetProvider).value ?? const Budget();
    final scenario = ref.watch(scenarioProvider);

    final hasBalance = txns.any(
        (t) => t.type == TransactionType.openingBalance);
    final hasBudget  = budget.isSet;
    final hasExpense = txns.any(
        (t) => t.type == TransactionType.expense);
    final hasSim     = scenario.isActive;

    final steps = [
      _Step(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Add your cash balance',
        hint: 'How much do you have right now?',
        done: hasBalance,
        onTap: () => context.go('/transactions'),
      ),
      _Step(
        icon: Icons.tune_rounded,
        label: 'Set your monthly budget',
        hint: 'Rent + living expenses',
        done: hasBudget,
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(ctx).padding.top + 8),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.cardRadius)),
              ),
              child: const ConfigScreen(),
            ),
          ),
        ),
      ),
      _Step(
        icon: Icons.receipt_long_rounded,
        label: 'Log your first expense',
        hint: 'Track where your money goes',
        done: hasExpense,
        onTap: () => context.go('/transactions'),
      ),
      _Step(
        icon: Icons.science_rounded,
        label: 'Try the simulator',
        hint: 'What if you cut expenses?',
        done: hasSim,
        isOptional: true,
        onTap: () => context.go('/scenarios'),
      ),
    ];

    final completedCount = steps.where((s) => s.done).length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.cardPadding, AppSpacing.cardPadding,
                AppSpacing.cardPadding, AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GETTING STARTED',
                        style: AppTextStyles.sectionTitle),
                    Text('$completedCount of ${steps.length} complete',
                        style: AppTextStyles.caption),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() => _dismissed = true);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(_kDismissedKey, true);
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textDim, size: 18),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: completedCount / steps.length,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation(
                    AppColors.neonGreen),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...steps.map((s) => _StepRow(step: s)),
          const SizedBox(height: AppSpacing.sm),

          // Tips
          Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.cardPadding, 0,
                AppSpacing.cardPadding, AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.gold, size: 14),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Tap to edit · Long press or swipe left to delete',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String label;
  final String hint;
  final bool done;
  final bool isOptional;
  final VoidCallback onTap;

  const _Step({
    required this.icon,
    required this.label,
    required this.hint,
    required this.done,
    required this.onTap,
    this.isOptional = false,
  });
}

class _StepRow extends StatelessWidget {
  final _Step step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: step.done ? null : step.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: step.done
                  ? AppColors.neonGreen.withAlpha(20)
                  : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: step.done
                    ? AppColors.neonGreen
                    : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              step.done ? Icons.check_rounded : step.icon,
              color: step.done
                  ? AppColors.neonGreen
                  : AppColors.textSecondary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(step.label,
                      style: AppTextStyles.body.copyWith(
                        color: step.done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: step.done
                            ? TextDecoration.lineThrough
                            : null,
                      )),
                  if (step.isOptional) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.turkishBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('BONUS',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.turkishBlue,
                              fontSize: 9)),
                    ),
                  ],
                ]),
                Text(step.hint, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (!step.done)
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textDim, size: 18),
        ]),
      ),
    );
  }
}
