import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'loan_provider.dart';
import 'scenario_provider.dart';
import 'subscription_provider.dart';
import 'budget_provider.dart';

final modelProvider = Provider<ModelState>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment = ref.watch(totalMonthlyLoanPaymentProvider);
  final subscriptionCost = ref.watch(subscriptionMonthlyTotalProvider);
  final budget = ref.watch(budgetProvider).value ?? const Budget();

  return asyncTransactions.when(
    data: (transactions) {
      final months = aggregateMonths(transactions);
      final actualBurn = _computeBurnRate(months) ?? 0.0;

      // Budget baseline = rent + living only (subscr + debt added by engine)
      final budgetBase = budget.subtotal;

      // Effective variable burn = max(actual, budget baseline)
      final effectiveVarBurn = actualBurn > budgetBase
          ? actualBurn
          : budgetBase;

      // Total burn passed to engine = variable + subscr + debt
      final totalBurn = effectiveVarBurn + subscriptionCost + monthlyPayment;

      return computeModel(
        months: months,
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
        budgetBurnRate: totalBurn > 0 ? totalBurn : null,
      );
    },
    loading: () {
      final totalBurn = budget.subtotal + subscriptionCost + monthlyPayment;
      return computeModel(
        months: [],
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
        budgetBurnRate: totalBurn > 0 ? totalBurn : null,
      );
    },
    error: (_, __) {
      final totalBurn = budget.subtotal + subscriptionCost + monthlyPayment;
      return computeModel(
        months: [],
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
        budgetBurnRate: totalBurn > 0 ? totalBurn : null,
      );
    },
  );
});

final projectedMonthsProvider = Provider<List<MonthlyState>>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment = ref.watch(totalMonthlyLoanPaymentProvider);
  final subscriptionCost = ref.watch(subscriptionMonthlyTotalProvider);
  final budget = ref.watch(budgetProvider).value ?? const Budget();

  return asyncTransactions.whenOrNull(
        data: (transactions) {
          final months = aggregateMonths(transactions);
          if (months.isEmpty) return <MonthlyState>[];
          final actualBurn = _computeBurnRate(months) ?? 0.0;
          final budgetBase = budget.subtotal;
          final effectiveVar = actualBurn > budgetBase
              ? actualBurn
              : budgetBase;
          final totalOutflow = effectiveVar + subscriptionCost + monthlyPayment;
          return projectMonthsForward(known: months, burnRate: totalOutflow);
        },
      ) ??
      [];
});

final scenarioModelProvider = Provider<ModelState?>((ref) {
  final scenario = ref.watch(scenarioProvider);
  if (!scenario.isActive) return null;

  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment = ref.watch(totalMonthlyLoanPaymentProvider);
  final subscriptionCost = ref.watch(subscriptionMonthlyTotalProvider);

  return asyncTransactions.whenOrNull(
    data: (transactions) {
      final realMonths = aggregateMonths(transactions);
      final currentCash = realMonths.isEmpty ? 0.0 : realMonths.last.balance;
      final realBurnRate = _computeBurnRate(realMonths) ?? 0.0;
      final effectiveBurn = scenario.burnRateOverride ?? realBurnRate;
      final effectiveIncome = scenario.simulatedIncome ?? 0.0;
      final netMonthlyFlow = effectiveIncome - effectiveBurn;

      final projected = _projectFromCash(
        startingCash: currentCash,
        netMonthlyFlow: netMonthlyFlow,
        fromDate: DateTime.now(),
        maxMonths: 120,
      );

      return computeModel(
        months: projected,
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
      );
    },
  );
});

double? _computeBurnRate(List<MonthlyState> months) {
  final outflows = months
      .where((m) => m.grossOutflow > 0)
      .map((m) => m.grossOutflow)
      .toList();
  if (outflows.isEmpty) return null;
  return outflows.reduce((a, b) => a + b) / outflows.length;
}

List<MonthlyState> _projectFromCash({
  required double startingCash,
  required double netMonthlyFlow,
  required DateTime fromDate,
  required int maxMonths,
}) {
  final result = <MonthlyState>[];
  double balance = startingCash;
  for (int i = 0; i < maxMonths; i++) {
    final month = SurvivalMonth(DateTime(fromDate.year, fromDate.month + i));
    balance += netMonthlyFlow;
    result.add(
      MonthlyState(month: month, netFlow: netMonthlyFlow, balance: balance),
    );
    if (balance <= 0) break;
  }
  return result;
}
