import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'widgets/metrics_panel.dart';
import 'widgets/investable_bar.dart';
import 'widgets/cash_chart.dart';
import 'widgets/life_force_card.dart';
import 'widgets/getting_started_card.dart';
import '../config/config_screen.dart';
import '../loans/liabilities_panel.dart';
import '../subscriptions/subscriptions_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(ctx).padding.top + 8),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.cardRadius),
            ),
          ),
          child: const ConfigScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const GettingStartedCard(),
                LifeForceCard(model: model),
                const SizedBox(height: AppSpacing.cardGap),
                MetricsPanel(model: model),
                const SizedBox(height: AppSpacing.cardGap),
                if (FeatureFlags.investments) const InvestableBar(),
                if (FeatureFlags.investments)
                  const SizedBox(height: AppSpacing.cardGap),
                const LiabilitiesPanel(),
                const SizedBox(height: AppSpacing.cardGap),
                const SubscriptionsPanel(),
                const SizedBox(height: AppSpacing.cardGap),
                NeoExpandableCard(
                  title: 'CASH TIMELINE',
                  accentColor: SC.accentNeutral,
                  initiallyExpanded: false,
                  summary: Text(
                    '${months.length} months projected',
                    style: AppTextStyles.bodySmall,
                  ),
                  details: CashChart(months: months),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
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
          const _RunwayBadge(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUNWAY',
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
                    'CONFIG',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
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

class _RunwayBadge extends StatefulWidget {
  const _RunwayBadge();

  @override
  State<_RunwayBadge> createState() => _RunwayBadgeState();
}

class _RunwayBadgeState extends State<_RunwayBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lift;
  late final Animation<double> _turn;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _lift = Tween<double>(
      begin: 0,
      end: -2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _turn = Tween<double>(begin: -0.025, end: 0.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _glow = Tween<double>(
      begin: 0.12,
      end: 0.38,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final child = _BadgeFrame(glow: disableAnimations ? 0.18 : null);

    if (disableAnimations) return child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _lift.value),
          child: Transform.rotate(
            angle: _turn.value,
            child: _BadgeFrame(glow: _glow.value),
          ),
        );
      },
    );
  }
}

class _BadgeFrame extends StatelessWidget {
  final double? glow;
  const _BadgeFrame({this.glow});

  @override
  Widget build(BuildContext context) {
    final glowAlpha = ((glow ?? 0.18) * 255).round();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neonGreen.withAlpha(80), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withAlpha(glowAlpha),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/brand/runway-icon-1024.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
