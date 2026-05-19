import 'package:test/test.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'db_helper.dart';

void main() {
  late AppDatabase db;
  late DriftTransactionRepository repo;

  setUp(() {
    db = openTestDatabase();
    repo = DriftTransactionRepository(db);
  });

  tearDown(() => db.close());

  group('DriftTransactionRepository', () {
    test('getAll returns empty list on fresh database', () async {
      expect(await repo.getAll(), isEmpty);
    });

    test('add then getAll round-trips opening balance', () async {
      await repo.add(_tx(id: 'tx-1', amount: 1_000_000));
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.id, 'tx-1');
      expect(all.first.amount.value, 1_000_000);
      expect(all.first.type, TransactionType.openingBalance);
    });

    test('add multiple transactions all appear in getAll', () async {
      await repo.add(_tx(id: 'tx-1', amount: 1_000_000));
      await repo.add(_tx(id: 'tx-2', amount: 50_000, type: TransactionType.expense));
      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('update modifies amount', () async {
      await repo.add(_tx(id: 'tx-1', amount: 500_000));
      await repo.update(_tx(id: 'tx-1', amount: 999_000));
      final all = await repo.getAll();
      expect(all.first.amount.value, 999_000);
    });

    test('delete removes the transaction', () async {
      await repo.add(_tx(id: 'tx-1', amount: 100_000));
      await repo.delete('tx-1');
      expect(await repo.getAll(), isEmpty);
    });

    test('delete unknown id is a no-op', () async {
      await repo.add(_tx(id: 'tx-1', amount: 100_000));
      await repo.delete('does-not-exist');
      expect((await repo.getAll()).length, 1);
    });

    test('watchAll emits updates on add', () async {
      final stream = repo.watchAll();
      await repo.add(_tx(id: 'tx-1', amount: 200_000));
      final snapshot = await stream.first;
      expect(snapshot.length, 1);
    });
  });
}

Transaction _tx({
  required String id,
  required double amount,
  TransactionType type = TransactionType.openingBalance,
}) {
  final now = DateTime(2025, 1, 1);
  return Transaction(
    id: id,
    date: now,
    type: type,
    amount: Money(amount),
    createdAt: now,
    updatedAt: now,
  );
}
