import 'package:test/test.dart';
import 'package:domain/domain.dart';

Transaction _tx({
  required int year,
  required int month,
  required TransactionType type,
  required double amount,
}) {
  final now = DateTime.now();
  return Transaction(
    id:        '$year-$month-${type.name}',
    date:      DateTime(year, month, 1),
    type:      type,
    amount:    Money(amount),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('aggregateMonths', () {
    test('returns empty list when no transactions', () {
      expect(aggregateMonths([]), isEmpty);
    });

    test('opening balance sets starting cash', () {
      final txs = [
        _tx(year: 2025, month: 1, type: TransactionType.openingBalance, amount: 1000000),
        _tx(year: 2025, month: 1, type: TransactionType.expense, amount: 50000),
      ];
      final months = aggregateMonths(txs);
      expect(months.first.balance, 950000);
    });

    test('netFlow is sum of signed amounts in month', () {
      final txs = [
        _tx(year: 2025, month: 1, type: TransactionType.openingBalance, amount: 500000),
        _tx(year: 2025, month: 2, type: TransactionType.income,  amount: 80000),
        _tx(year: 2025, month: 2, type: TransactionType.expense, amount: 50000),
      ];
      final months = aggregateMonths(txs);
      final feb = months.firstWhere((m) => m.month.value.month == 2);
      expect(feb.netFlow, 30000); // 80k - 50k
    });

    test('balance runs cumulatively across months', () {
      final txs = [
        _tx(year: 2025, month: 1, type: TransactionType.openingBalance, amount: 1000000),
        _tx(year: 2025, month: 1, type: TransactionType.expense, amount: 50000),
        _tx(year: 2025, month: 2, type: TransactionType.expense, amount: 50000),
        _tx(year: 2025, month: 3, type: TransactionType.expense, amount: 50000),
      ];
      final months = aggregateMonths(txs);
      expect(months[0].balance, 950000);
      expect(months[1].balance, 900000);
      expect(months[2].balance, 850000);
    });

    test('months are sorted chronologically', () {
      final txs = [
        _tx(year: 2025, month: 1, type: TransactionType.openingBalance, amount: 500000),
        _tx(year: 2025, month: 3, type: TransactionType.expense, amount: 10000),
        _tx(year: 2025, month: 1, type: TransactionType.expense, amount: 10000),
        _tx(year: 2025, month: 2, type: TransactionType.expense, amount: 10000),
      ];
      final months = aggregateMonths(txs);
      final monthNumbers = months.map((m) => m.month.value.month).toList();
      expect(monthNumbers, [1, 2, 3]);
    });
  });
}
