import 'dart:math';
import '../entities/monthly_state.dart';
import '../entities/model_state.dart';
import '../value_objects/survival_month.dart';

const _safetyMonths = 12;
const _maxProjection = 120;

ModelState computeModel({
  required List<MonthlyState> months,
  required double monthlyPayment,
  required double subscriptionMonthlyCost,
  double? budgetBurnRate,
}) {
  final currentCash = months.isEmpty ? 0.0 : months.last.balance;
  final txBurnRate = _computeBurnRate(months) ?? 0.0;

  final effectiveBurn = budgetBurnRate != null && budgetBurnRate > 0
      ? budgetBurnRate
      : txBurnRate + subscriptionMonthlyCost + monthlyPayment;

  final burnForModel = effectiveBurn > 0 ? effectiveBurn : 0.0;

  final int runwayMonths;
  final DateTime? runOutDate;

  if (burnForModel <= 0) {
    runwayMonths = 9999;
    runOutDate = null;
  } else {
    final projected = months.isEmpty
        ? _projectFromCash(currentCash, burnForModel)
        : _projectForward(months, burnForModel);

    final knownRunway = _computeRunway(projected);
    final lastBalance = projected.isEmpty
        ? currentCash
        : projected.last.balance;

    if (lastBalance > 0) {
      final extraMonths = (lastBalance / burnForModel).floor();
      runwayMonths = knownRunway + extraMonths;
      final lastDate = projected.isEmpty
          ? DateTime.now()
          : projected.last.month.value;
      runOutDate = DateTime(lastDate.year, lastDate.month + extraMonths, 1);
    } else {
      runwayMonths = knownRunway;
      runOutDate = _computeRunOutDate(projected);
    }
  }

  final safetyCash = burnForModel * _safetyMonths;
  final surplus = currentCash - safetyCash;
  final riskCapacity = ((runwayMonths - 12) / 12).clamp(0.0, 1.0);
  final pressureRatio = txBurnRate > 0
      ? (monthlyPayment + subscriptionMonthlyCost) / txBurnRate
      : 0.0;
  final pressureFactor = max(0.2, 1 - pressureRatio);
  final investableCash = max(0.0, surplus * riskCapacity * pressureFactor);

  return ModelState(
    currentCash: currentCash,
    burnRate: txBurnRate,
    effectiveBurnRate: burnForModel,
    monthlyPayment: monthlyPayment,
    subscriptionMonthlyCost: subscriptionMonthlyCost,
    runwayMonths: runwayMonths,
    runOutDate: runOutDate,
    pressureRatio: pressureRatio,
    safetyCash: safetyCash,
    surplus: surplus,
    riskCapacity: riskCapacity,
    pressureFactor: pressureFactor,
    investableCash: investableCash,
  );
}

List<MonthlyState> projectMonthsForward({
  required List<MonthlyState> known,
  required double burnRate,
  int maxMonths = 120,
}) => _projectForward(known, burnRate);

List<MonthlyState> _projectForward(List<MonthlyState> known, double burnRate) {
  final result = List<MonthlyState>.from(known);
  var balance = known.last.balance;
  var lastMonth = known.last.month;

  for (int i = 0; i < _maxProjection; i++) {
    if (balance <= 0) break;
    final next = lastMonth.next();
    balance -= burnRate;
    result.add(
      MonthlyState(
        month: next,
        netFlow: -burnRate,
        balance: balance,
        grossOutflow: burnRate,
      ),
    );
    lastMonth = next;
  }
  return result;
}

List<MonthlyState> _projectFromCash(double startCash, double burnRate) {
  final result = <MonthlyState>[];
  double balance = startCash;
  final start = DateTime.now();

  for (int i = 0; i < _maxProjection; i++) {
    if (balance <= 0) break;
    final month = SurvivalMonth(DateTime(start.year, start.month + i));
    balance -= burnRate;
    result.add(
      MonthlyState(
        month: month,
        netFlow: -burnRate,
        balance: balance,
        grossOutflow: burnRate,
      ),
    );
  }
  return result;
}

double? _computeBurnRate(List<MonthlyState> months) {
  final outflows = months
      .where((m) => m.grossOutflow > 0)
      .map((m) => m.grossOutflow)
      .toList();
  if (outflows.isEmpty) return null;
  return outflows.reduce((a, b) => a + b) / outflows.length;
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
