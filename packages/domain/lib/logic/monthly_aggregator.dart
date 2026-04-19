import '../entities/transaction.dart';
import '../entities/monthly_state.dart';
import '../enums/transaction_type.dart';


List<MonthlyState> aggregateMonths(List<Transaction> transactions) {
  if (transactions.isEmpty) return [];

  final opening = transactions
      .where((t) => t.type == TransactionType.openingBalance)
      .fold(0.0, (sum, t) => sum + t.signedAmount);

  final regular = transactions
      .where((t) => t.type != TransactionType.openingBalance)
      .toList();

  if (regular.isEmpty) return [];

  final Map<String, List<Transaction>> byMonth = {};
  for (final t in regular) {
    final key = t.month.toString();
    byMonth.putIfAbsent(key, () => []).add(t);
  }

  final sortedKeys = byMonth.keys.toList()..sort();

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
