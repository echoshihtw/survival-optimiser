import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'loan_provider.dart';
import 'scenario_provider.dart';

final modelProvider = Provider<ModelState>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment    = ref.watch(totalMonthlyLoanPaymentProvider);

  return asyncTransactions.when(
    data: (transactions) {
      final months = aggregateMonths(transactions);
      return computeModel(months: months, monthlyPayment: monthlyPayment);
    },
    loading: () => ModelState.empty(),
    error:   (_, __) => ModelState.empty(),
  );
});

final projectedMonthsProvider = Provider<List<MonthlyState>>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);

  return asyncTransactions.whenOrNull(
    data: (transactions) {
      final months   = aggregateMonths(transactions);
      if (months.isEmpty) return <MonthlyState>[];
      final burnRate = _computeBurnRate(months) ?? 50000.0;
      return projectMonthsForward(known: months, burnRate: burnRate);
    },
  ) ?? [];
});

final scenarioModelProvider = Provider<ModelState?>((ref) {
  final scenario       = ref.watch(scenarioProvider);
  if (!scenario.isActive) return null;

  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment    = ref.watch(totalMonthlyLoanPaymentProvider);

  return asyncTransactions.whenOrNull(
    data: (transactions) {
      final realMonths      = aggregateMonths(transactions);
      final currentCash     = realMonths.isEmpty ? 0.0 : realMonths.last.balance;
      final realBurnRate    = _computeBurnRate(realMonths) ?? 50000.0;
      final effectiveBurn   = scenario.burnRateOverride ?? realBurnRate;
      final effectiveIncome = scenario.simulatedIncome ?? 0.0;
      final netMonthlyFlow  = effectiveIncome - effectiveBurn;

      final projected = _projectFromCash(
        startingCash:   currentCash,
        netMonthlyFlow: netMonthlyFlow,
        fromDate:       DateTime.now(),
        maxMonths:      120,
      );

      return computeModel(months: projected, monthlyPayment: monthlyPayment);
    },
  );
});

double? _computeBurnRate(List<MonthlyState> months) {
  final negativeFlows = months
      .where((m) => m.netFlow < 0)
      .map((m) => m.netFlow.abs())
      .toList();
  if (negativeFlows.isEmpty) return null;
  return negativeFlows.reduce((a, b) => a + b) / negativeFlows.length;
}

List<MonthlyState> _projectFromCash({
  required double startingCash,
  required double netMonthlyFlow,
  required DateTime fromDate,
  required int maxMonths,
}) {
  final result   = <MonthlyState>[];
  double balance = startingCash;

  for (int i = 0; i < maxMonths; i++) {
    final month = SurvivalMonth(DateTime(fromDate.year, fromDate.month + i));
    balance    += netMonthlyFlow;
    result.add(MonthlyState(month: month, netFlow: netMonthlyFlow, balance: balance));
    if (balance <= 0) break;
  }
  return result;
}
