import '../entities/transaction.dart';
import '../entities/monthly_state.dart';
import '../enums/transaction_type.dart';
import '../value_objects/survival_month.dart';

List<MonthlyState> aggregateMonths(List<Transaction> transactions) {
  if (transactions.isEmpty) return [];

  final opening = transactions
      .where((t) => t.type == TransactionType.openingBalance)
      .fold(0.0, (sum, t) => sum + t.signedAmount);

  final regular = transactions
      .where((t) => t.type != TransactionType.openingBalance)
      .toList();

  if (regular.isEmpty && opening > 0) {
    final now = DateTime.now();
    return [
      MonthlyState(
        month: SurvivalMonth(now),
        netFlow: 0,
        balance: opening,
        grossOutflow: 0,
      ),
    ];
  }

  if (regular.isEmpty) return [];

  final Map<String, List<Transaction>> byMonth = {};
  for (final t in regular) {
    byMonth.putIfAbsent(t.month.toString(), () => []).add(t);
  }

  final sortedKeys = byMonth.keys.toList()..sort();
  double balance = opening;
  final result = <MonthlyState>[];

  for (final key in sortedKeys) {
    final monthTxs = byMonth[key]!;
    final netFlow = monthTxs.fold(0.0, (sum, t) => sum + t.signedAmount);
    final grossOutflow = monthTxs
        .where((t) => !t.type.isInflow && t.type != TransactionType.investment)
        .fold(0.0, (sum, t) => sum + t.amount.value);
    balance += netFlow;
    result.add(
      MonthlyState(
        month: monthTxs.first.month,
        netFlow: netFlow,
        balance: balance,
        grossOutflow: grossOutflow,
      ),
    );
  }

  return result;
}
