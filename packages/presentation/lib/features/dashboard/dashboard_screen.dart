import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'widgets/heart_bar.dart';
import 'widgets/status_badge.dart';
import 'widgets/metrics_panel.dart';
import 'widgets/investable_bar.dart';
import 'widgets/cash_chart.dart';
import '../config/config_screen.dart';
import '../loans/liabilities_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = context.l10n;
    final model  = ref.watch(modelProvider);
    final months = ref.watch(projectedMonthsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.hudTitle, style: AppTextStyles.title),
                    Row(children: [
                      Text(l10n.sysOnline,
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryGreen)),
                      const SizedBox(width: AppSpacing.md),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.background,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          builder: (_) => const FractionallySizedBox(
                            heightFactor: 0.85,
                            child: ConfigScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.dimGreen),
                          ),
                          child: Text('[ ${l10n.configButton} ]',
                              style: AppTextStyles.small),
                        ),
                      ),
                    ]),
                  ],
                ),
                const TerminalDivider(),
                TerminalPanel(
                  title: l10n.lifeForce,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeartBar(filled: model.filledHearts),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        Text('${l10n.statusLabel}  ',
                            style: AppTextStyles.label),
                        StatusBadge(status: model.survivalStatus),
                      ]),
                      const SizedBox(height: AppSpacing.xs),
                      Row(children: [
                        Text('${l10n.pressureLabel}  ',
                            style: AppTextStyles.label),
                        Text(
                          _pressureLabel(model.pressureRatio, l10n),
                          style: AppTextStyles.value.copyWith(
                              color: _pressureColor(model.pressureRatio)),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MetricsPanel(model: model),
                const SizedBox(height: AppSpacing.sm),
                InvestableBar(model: model),
                const SizedBox(height: AppSpacing.sm),
                const LiabilitiesPanel(),
                const SizedBox(height: AppSpacing.sm),
                TerminalPanel(
                  title: l10n.cashTimeline,
                  child: months.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xl),
                          child: Center(
                            child: Text(l10n.addNoData,
                                style: AppTextStyles.small,
                                textAlign: TextAlign.center),
                          ),
                        )
                      : CashChart(
                          months: months,
                          safetyCash: model.safetyCash,
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _pressureLabel(double ratio, AppLocalizations l10n) {
    if (ratio < 0.2) return l10n.low;
    if (ratio < 0.5) return l10n.moderate;
    return l10n.highLoad;
  }

  Color _pressureColor(double ratio) {
    if (ratio < 0.2) return AppColors.stable;
    if (ratio < 0.5) return AppColors.caution;
    return AppColors.critical;
  }
}
