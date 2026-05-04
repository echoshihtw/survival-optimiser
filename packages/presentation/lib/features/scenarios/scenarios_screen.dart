import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import '../paywall/paywall_screen.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scenario = ref.watch(scenarioProvider);
    final realModel = ref.watch(modelProvider);
    final simModel = ref.watch(scenarioModelProvider);
    final symbol = ref.watch(currencyProvider).value?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    String fmt(double v) => '$symbol ${nf.format(v.abs())}';
    String fmtRunway(int m) {
      if (m >= 9999) return '∞';
      if (m >= 24) return '${(m / 12).toStringAsFixed(1)} YRS';
      return '$m MO';
    }

    Color runwayColor(SurvivalStatus s) => switch (s) {
      SurvivalStatus.stable => AppColors.green,
      SurvivalStatus.caution => AppColors.gold,
      SurvivalStatus.critical => AppColors.red,
    };

    return GradientScaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.scenarioSimulator, style: AppTextStyles.title),
              Text(
                l10n.whatIfAnalysis,
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: AppSpacing.xl),

              NeoCard(
                title: l10n.current,
                accentColor: AppColors.green,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _tile(
                            l10n.runway,
                            fmtRunway(realModel.runwayMonths),
                            runwayColor(realModel.survivalStatus),
                          ),
                        ),
                        Expanded(
                          child: _tile(
                            l10n.totalPerMonth,
                            '-${fmt(realModel.totalMonthlyOutflow)}',
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _tile(
                            l10n.cash,
                            fmt(realModel.currentCash),
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),

              NeoCard(
                title: l10n.simulate,
                accentColor: AppColors.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.simHint, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.md),
                    _SimInput(
                      label: l10n.burnRateOverride,
                      hint: realModel.burnRate > 0
                          ? realModel.burnRate.toStringAsFixed(0)
                          : '50000',
                      initialValue: scenario.burnRateOverride?.toStringAsFixed(0),
                      onChanged: (v) {
                        final isPro = ref.read(entitlementProvider).value?.isPro ?? false;
                        if (!isPro && scenario.isActive) {
                          showPaywall(context, trigger: 'simulation');
                          return;
                        }
                        ref.read(scenarioProvider.notifier).setBurnRateOverride(double.tryParse(v));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SimInput(
                      label: l10n.simulatedIncome,
                      hint: '0',
                      initialValue: scenario.simulatedIncome?.toStringAsFixed(0),
                      onChanged: (v) {
                        final isPro = ref.read(entitlementProvider).value?.isPro ?? false;
                        if (!isPro && scenario.isActive) {
                          showPaywall(context, trigger: 'simulation');
                          return;
                        }
                        ref.read(scenarioProvider.notifier).setSimulatedIncome(double.tryParse(v));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NeoButton(
                      label: l10n.resetSim,
                      variant: NeoButtonVariant.ghost,
                      fullWidth: true,
                      onPressed: () {
                        final isPro = ref.read(entitlementProvider).value?.isPro ?? false;
                        final isActive = ref.read(scenarioProvider).isActive;
                        if (!isPro && isActive) {
                          showPaywall(context, trigger: 'simulation');
                          return;
                        }
                        ref.read(scenarioProvider.notifier).reset();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),

              if (scenario.isActive && simModel != null && realModel.currentCash > 0) ...[
                NeoCard(
                  title: l10n.simulation,
                  accentColor: AppColors.blue,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _tile(
                              l10n.simRunway,
                              fmtRunway(simModel.runwayMonths),
                              runwayColor(simModel.survivalStatus),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(color: AppColors.cardBorder, height: 1),
                      const SizedBox(height: AppSpacing.md),

                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.deltaRunway, style: AppTextStyles.label),
                            Row(
                              children: [
                                Icon(
                                  simModel.runwayMonths >= realModel.runwayMonths
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: simModel.runwayMonths >= realModel.runwayMonths
                                      ? AppColors.green
                                      : AppColors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${simModel.runwayMonths > realModel.runwayMonths ? "+" : ""}${simModel.runwayMonths - realModel.runwayMonths} MO',
                                  style: AppTextStyles.metric.copyWith(
                                    color: simModel.runwayMonths >= realModel.runwayMonths
                                        ? AppColors.green
                                        : AppColors.red,
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
              ] else if (realModel.currentCash == 0) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.textDim, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Add your opening balance first',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Go to LOG → + ADD → Opening Balance',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center),
                ]),
              ),
            ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.science_outlined,
                          color: AppColors.textDim,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.enterValuesToSim,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.metricSmall.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SimInput extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const _SimInput({
    required this.label,
    required this.hint,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<_SimInput> createState() => _SimInputState();
}

class _SimInputState extends State<_SimInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeoInput(
      label: widget.label,
      controller: _ctrl,
      inputType: NeoInputType.numeric,
      hint: widget.hint,
      onChanged: widget.onChanged,
    );
  }
}
