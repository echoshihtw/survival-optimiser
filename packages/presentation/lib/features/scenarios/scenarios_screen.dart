import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:intl/intl.dart';

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n      = context.l10n;
    final currAsync = ref.watch(currencyProvider);
    final symbol    = currAsync.value?.symbol ?? '¥';
    final realModel = ref.watch(modelProvider);
    final simModel  = ref.watch(scenarioModelProvider);

    String fmt(double v) =>
        '$symbol ${NumberFormat('#,##0', 'en_US').format(v.abs())}';

    String fmtDate(DateTime? d) {
      if (d == null) return 'N/A';
      return DateFormat('MMM yyyy').format(d).toUpperCase();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scenarioSimulator, style: AppTextStyles.title),
                const TerminalDivider(),
                TerminalPanel(
                  title: l10n.overrideInputs,
                  child: Column(
                    children: [
                      _SimInput(
                        label: l10n.burnRateOverride,
                        hint: realModel.burnRate.toStringAsFixed(0),
                        onChanged: (v) => ref
                            .read(scenarioProvider.notifier)
                            .setBurnRateOverride(double.tryParse(v)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SimInput(
                        label: l10n.simulatedIncome,
                        hint: '0',
                        onChanged: (v) => ref
                            .read(scenarioProvider.notifier)
                            .setSimulatedIncome(double.tryParse(v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (simModel != null) ...[
                  TerminalPanel(
                    title: l10n.simResults,
                    child: Column(
                      children: [
                        _resultRow(l10n.simRunway,
                            '${simModel.runwayMonths} ${l10n.months}',
                            AppColors.primaryGreen),
                        _resultRow(l10n.simRunOut,
                            fmtDate(simModel.runOutDate),
                            AppColors.dimGreen),
                        _resultRow(l10n.simInvestable,
                            fmt(simModel.investableCash),
                            AppColors.safe),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TerminalPanel(
                    title: l10n.deltaVsActual,
                    child: Column(
                      children: [
                        _deltaRow(
                          l10n.deltaRunway,
                          simModel.runwayMonths - realModel.runwayMonths,
                          suffix: ' ${l10n.months}',
                          symbol: symbol,
                        ),
                        _deltaRow(
                          l10n.deltaInvestable,
                          simModel.investableCash - realModel.investableCash,
                          prefix: '$symbol ',
                          symbol: symbol,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TerminalButton(
                    label: l10n.resetSim,
                    isDestructive: true,
                    onPressed: () =>
                        ref.read(scenarioProvider.notifier).reset(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.value.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _deltaRow(String label, num delta,
      {String prefix = '', String suffix = '', required String symbol}) {
    final isPositive = delta >= 0;
    final color  = isPositive ? AppColors.safe : AppColors.danger;
    final arrow  = isPositive ? '▲' : '▼';
    final amount = NumberFormat('#,##0', 'en_US').format(delta.abs());
    final value  = '$arrow $prefix$amount$suffix';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.value.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SimInput extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SimInput({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TerminalInput(
      label: label,
      hint: hint,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
