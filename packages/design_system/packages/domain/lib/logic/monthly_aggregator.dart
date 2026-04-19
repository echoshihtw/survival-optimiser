import '../entities/transaction.dart';
import '../entities/monthly_state.dart';
import '../enums/transaction_type.dart';
import '../value_objects/survival_month.dart';

const _fallbackBurnRate = 50000.0;

/// Groups transactions by month and computes running balance.
/// Pure function — no side effects, no Flutter imports.
List<MonthlyState> aggregateMonths(List<Transaction> transactions) {
  if (transactions.isEmpty) return [];

  // Separate opening balance
  final opening = transactions
      .where((t) => t.type == TransactionType.openingBalance)
      .fold(0.0, (sum, t) => sum + t.signedAmount);

  final regular = transactions
      .where((t) => t.type != TransactionType.openingBalance)
      .toList();

  if (regular.isEmpty) return [];

  // Group by month
  final Map<String, List<Transaction>> byMonth = {};
  for (final t in regular) {
    final key = t.month.toString();
    byMonth.putIfAbsent(key, () => []).add(t);
  }

  // Sort months chronologically
  final sortedKeys = byMonth.keys.toList()..sort();

  // Compute burn rate from negative months for fallback
  final burnRate = _computeBurnRate(byMonth) ?? _fallbackBurnRate;

  // Build monthly states with running balance
  double balance = opening;
  final result = <MonthlyState>[];

  for (final key in sortedKeys) {
    final monthTransactions = byMonth[key]!;
    final netFlow = monthTransactions.fold(
      0.0,
      (sum, t) => sum + t.signedAmount,
    );
    balance += netFlow;
    result.add(MonthlyState(
      month:   monthTransactions.first.month,
      netFlow: netFlow,
      balance: balance,
    ));
  }

  return result;
}

double? _computeBurnRate(Map<String, List<Transaction>> byMonth) {
  final negativeFlows = <double>[];

  for (final transactions in byMonth.values) {
    final netFlow = transactions.fold(
      0.0,
      (sum, t) => sum + t.signedAmount,
    );
    if (netFlow < 0) negativeFlows.add(netFlow.abs());
  }

  if (negativeFlows.isEmpty) return null;
  return negativeFlows.reduce((a, b) => a + b) / negativeFlows.length;
}
