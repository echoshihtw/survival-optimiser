import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';
import '../mappers/transaction_mapper.dart';

class DriftTransactionRepository implements domain.TransactionRepository {
  final AppDatabase _db;

  const DriftTransactionRepository(this._db);

  @override
  Stream<List<domain.Transaction>> watchAll() {
    return _db.transactionDao
        .watchAll()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<List<domain.Transaction>> getAll() async {
    final rows = await _db.transactionDao.getAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> add(domain.Transaction transaction) async {
    await _db.transactionDao
        .insertTransaction(transaction.toCompanion());
  }

  @override
  Future<void> update(domain.Transaction transaction) async {
    await _db.transactionDao
        .updateTransaction(transaction.toCompanion());
  }

  @override
  Future<void> delete(String id) async {
    await _db.transactionDao.deleteTransaction(id);
  }
}
