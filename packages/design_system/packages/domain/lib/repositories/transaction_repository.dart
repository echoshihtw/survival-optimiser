import '../entities/transaction.dart';

abstract interface class TransactionRepository {
  /// Live stream — emits whenever data changes
  Stream<List<Transaction>> watchAll();

  /// One-time fetch
  Future<List<Transaction>> getAll();

  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
}
