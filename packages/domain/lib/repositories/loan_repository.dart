import '../entities/loan.dart';

abstract interface class LoanRepository {
  Stream<List<Loan>> watchAll();
  Future<List<Loan>> getAll();
  Future<void> add(Loan loan);
  Future<void> update(Loan loan);
  Future<void> delete(String id);
}
