import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'widgets/metrics_panel.dart';
import 'widgets/investable_bar.dart';
import 'widgets/cash_chart.dart';
import 'widgets/life_force_card.dart';
import '../config/config_screen.dart';
import '../loans/liabilities_panel.dart';
import '../subscriptions/subscriptions_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(modelProvider);
    final months = ref.watch(projectedMonthsProvider);

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: Padding(
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
                      Text(
                        'SURVIVAL.EXE',
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: AppColors.neonGreen,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'FINANCIAL INTELLIGENCE',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showConfig(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: AppColors.textSecondary,
                            size: 13,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'CONFIG',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                LifeForceCard(model: model),
                const SizedBox(height: AppSpacing.cardGap),
                MetricsPanel(model: model),
                const SizedBox(height: AppSpacing.cardGap),
                InvestableBar(model: model),
                const SizedBox(height: AppSpacing.cardGap),
                const LiabilitiesPanel(),
                const SizedBox(height: AppSpacing.cardGap),
                const SubscriptionsPanel(),
                const SizedBox(height: AppSpacing.cardGap),
                NeoExpandableCard(
                  title: 'CASH TIMELINE',
                  accentColor: SC.accentTimeline,
                  initiallyExpanded: false,
                  summary: Text(
                    months.isEmpty
                        ? 'Add transactions to see projection'
                        : '${months.length} months projected',
                    style: AppTextStyles.bodySmall,
                  ),
                  details: months.isEmpty
                      ? null
                      : CashChart(months: months, safetyCash: model.safetyCash),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) =>
          const FractionallySizedBox(heightFactor: 0.9, child: ConfigScreen()),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback onConfig;
  const _DashboardHeader({required this.onConfig});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = [
      'SUN',
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
    ][now.weekday % 7];
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}, $weekday';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.neonGreen.withAlpha(60),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '◈',
                style: TextStyle(color: AppColors.neonGreen, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SURVIVAL.EXE',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateStr,
                  style: AppTextStyles.caption.copyWith(letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          // Config button
          GestureDetector(
            onTap: onConfig,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textSecondary,
                    size: 13,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'CONFIG',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
