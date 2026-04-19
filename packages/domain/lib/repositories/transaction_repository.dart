import '../entities/transaction.dart';

abstract interface class TransactionRepository {
  Stream<List<Transaction>> watchAll();
  Future<List<Transaction>> getAll();
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
}
