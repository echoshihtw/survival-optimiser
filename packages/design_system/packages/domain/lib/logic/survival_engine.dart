import 'dart:math';
import '../entities/monthly_state.dart';
import '../entities/model_state.dart';

const _safetyMonths    = 12;
const _fallbackBurnRate = 50000.0;

/// Computes full survival model from monthly states.
/// Pure function — no side effects, no Flutter imports.
ModelState computeModel({
  required List<MonthlyState> months,
  required double monthlyPayment,
}) {
  if (months.isEmpty) return ModelState.empty();

  final currentCash  = months.last.balance;
  final burnRate     = _computeBurnRate(months) ?? _fallbackBurnRate;
  final runwayMonths = _computeRunway(months);
  final runOutDate   = _computeRunOutDate(months);

  final safetyCash    = burnRate * _safetyMonths;
  final surplus       = currentCash - safetyCash;
  final riskCapacity  = ((runwayMonths - 12) / 12).clamp(0.0, 1.0);
  final pressureRatio = burnRate > 0 ? monthlyPayment / burnRate : 0.0;
  final pressureFactor = max(0.2, 1 - pressureRatio);
  final investableCash = max(0.0, surplus * riskCapacity * pressureFactor);

  return ModelState(
    currentCash:    currentCash,
    burnRate:       burnRate,
    monthlyPayment: monthlyPayment,
    runwayMonths:   runwayMonths,
    runOutDate:     runOutDate,
    pressureRatio:  pressureRatio,
    safetyCash:     safetyCash,
    surplus:        surplus,
    riskCapacity:   riskCapacity,
    pressureFactor: pressureFactor,
    investableCash: investableCash,
  );
}

double? _computeBurnRate(List<MonthlyState> months) {
  final negativeFlows = months
      .where((m) => m.netFlow < 0)
      .map((m) => m.netFlow.abs())
      .toList();

  if (negativeFlows.isEmpty) return null;
  return negativeFlows.reduce((a, b) => a + b) / negativeFlows.length;
}

int _computeRunway(List<MonthlyState> months) {
  int count = 0;
  for (final m in months) {
    if (m.balance <= 0) break;
    count++;
  }
  return count;
}

DateTime? _computeRunOutDate(List<MonthlyState> months) {
  for (final m in months) {
    if (m.balance <= 0) return m.month.value;
  }
  return null;
}
