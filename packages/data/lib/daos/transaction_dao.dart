import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<Transaction>> watchAll() => select(transactions).watch();

  Future<List<Transaction>> getAll() => select(transactions).get();

  Future<void> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<void> updateTransaction(TransactionsCompanion entry) => (update(
    transactions,
  )..where((t) => t.id.equals(entry.id.value))).write(entry);

  Future<void> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();
}
