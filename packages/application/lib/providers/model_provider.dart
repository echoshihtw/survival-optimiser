import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'loan_provider.dart';
import 'scenario_provider.dart';
import 'subscription_provider.dart';
import 'budget_provider.dart';
import 'financial_assumptions_provider.dart';

final modelProvider = Provider<ModelState>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment = ref.watch(totalMonthlyLoanPaymentProvider);
  final subscriptionCost = ref.watch(subscriptionMonthlyTotalProvider);
  final budget = ref.watch(budgetProvider).value ?? const Budget();
  final assumptions =
      ref.watch(financialAssumptionsProvider).value ??
      const FinancialAssumptions();

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
        expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
        expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
      );
    },
    loading: () {
      final totalBurn = budget.subtotal + subscriptionCost + monthlyPayment;
      return computeModel(
        months: [],
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
        budgetBurnRate: totalBurn > 0 ? totalBurn : null,
        expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
        expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
      );
    },
    error: (_, __) {
      final totalBurn = budget.subtotal + subscriptionCost + monthlyPayment;
      return computeModel(
        months: [],
        monthlyPayment: monthlyPayment,
        subscriptionMonthlyCost: subscriptionCost,
        budgetBurnRate: totalBurn > 0 ? totalBurn : null,
        expectedMonthlyInflow: assumptions.expectedMonthlyInflow,
        expectedMonthlyBurnOverride: assumptions.expectedMonthlyBurnOverride,
      );
    },
  );
});

final projectedMonthsProvider = Provider<List<MonthlyState>>((ref) {
  final asyncTransactions = ref.watch(transactionsProvider);
  final monthlyPayment = ref.watch(totalMonthlyLoanPaymentProvider);
  final subscriptionCost = ref.watch(subscriptionMonthlyTotalProvider);
  final budget = ref.watch(budgetProvider).value ?? const Budget();
  final assumptions =
      ref.watch(financialAssumptionsProvider).value ??
      const FinancialAssumptions();

  return asyncTransactions.whenOrNull(
        data: (transactions) {
          final months = aggregateMonths(transactions);
          if (months.isEmpty) return <MonthlyState>[];
          final actualBurn = _computeBurnRate(months) ?? 0.0;
          final budgetBase = budget.subtotal;
          final effectiveVar = actualBurn > budgetBase
              ? actualBurn
              : budgetBase;
          final totalOutflow =
              assumptions.expectedMonthlyBurnOverride ??
              effectiveVar + subscriptionCost + monthlyPayment;
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
      final variableBurn = scenario.burnRateOverride ?? realBurnRate;
      final totalBurn = variableBurn + monthlyPayment + subscriptionCost;
      final simulatedIncome = scenario.simulatedIncome ?? 0.0;
      final netBurn = totalBurn - simulatedIncome;

      return _computeScenarioModel(
        startingCash: currentCash,
        variableBurnRate: variableBurn,
        effectiveBurnRate: netBurn > 0 ? netBurn : 0.0,
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

ModelState _computeScenarioModel({
  required double startingCash,
  required double variableBurnRate,
  required double effectiveBurnRate,
  required double monthlyPayment,
  required double subscriptionMonthlyCost,
}) {
  final runwayDays = effectiveBurnRate > 0
      ? (startingCash / effectiveBurnRate * 30).floor()
      : 99999;
  final runwayMonths = effectiveBurnRate > 0
      ? (startingCash / effectiveBurnRate).floor()
      : 9999;
  final now = DateTime.now();

  return ModelState(
    currentCash: startingCash,
    burnRate: variableBurnRate,
    effectiveBurnRate: effectiveBurnRate,
    monthlyPayment: monthlyPayment,
    subscriptionMonthlyCost: subscriptionMonthlyCost,
    runwayMonths: runwayMonths,
    runwayDays: runwayDays,
    runOutDate: effectiveBurnRate > 0
        ? DateTime(now.year, now.month + runwayMonths, 1)
        : null,
    pressureRatio: variableBurnRate > 0
        ? (monthlyPayment + subscriptionMonthlyCost) / variableBurnRate
        : 0.0,
  );
}
