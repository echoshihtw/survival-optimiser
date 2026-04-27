import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';
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
    final l10n = context.l10n;
    final model = ref.watch(modelProvider);
    final months = ref.watch(projectedMonthsProvider);

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(onConfig: () => _showConfig(context)),
          ),

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
                  title: l10n.cashTimeline,
                  accentColor: SC.accentNeutral,
                  initiallyExpanded: false,
                  summary: Text(
                    months.isEmpty
                        ? l10n.addNoData
                        : l10n.monthsProjected(months.length),
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
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('d MMM yyyy, EEE', locale)
        .format(DateTime.now())
        .toUpperCase();

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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hudTitle,
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
                    l10n.config,
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
