import 'dart:math';
import '../entities/monthly_state.dart';
import '../entities/model_state.dart';

const _safetyMonths     = 12;
const _fallbackBurnRate = 50000.0;
const _maxProjection    = 120; // 10 years max

ModelState computeModel({
  required List<MonthlyState> months,
  required double monthlyPayment,
}) {
  if (months.isEmpty) return ModelState.empty();

  final currentCash = months.last.balance;
  final burnRate    = _computeBurnRate(months) ?? _fallbackBurnRate;

  // Project forward from last known balance using burn rate
  final projected   = _projectForward(months, burnRate);

  final runwayMonths = _computeRunway(projected);
  final runOutDate   = _computeRunOutDate(projected);

  final safetyCash     = burnRate * _safetyMonths;
  final surplus        = currentCash - safetyCash;
  final riskCapacity   = ((runwayMonths - 12) / 12).clamp(0.0, 1.0);
  final pressureRatio  = burnRate > 0 ? monthlyPayment / burnRate : 0.0;
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

/// Projects months forward from last known balance using burn rate
/// until balance hits zero or max projection reached
List<MonthlyState> _projectForward(
  List<MonthlyState> known,
  double burnRate,
) {
  final result  = List<MonthlyState>.from(known);
  var balance   = known.last.balance;
  var lastMonth = known.last.month;

  for (int i = 0; i < _maxProjection; i++) {
    if (balance <= 0) break;
    final nextMonth = lastMonth.next();
    balance        -= burnRate;
    result.add(MonthlyState(
      month:   nextMonth,
      netFlow: -burnRate,
      balance: balance,
    ));
    lastMonth = nextMonth;
  }

  return result;
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

/// Public projection function — used by application layer
List<MonthlyState> projectMonthsForward({
  required List<MonthlyState> known,
  required double burnRate,
  int maxMonths = 120,
}) {
  return _projectForward(known, burnRate);
}
