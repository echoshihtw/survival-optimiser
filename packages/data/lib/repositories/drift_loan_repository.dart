import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';
import '../mappers/loan_mapper.dart';

class DriftLoanRepository implements domain.LoanRepository {
  final AppDatabase _db;
  const DriftLoanRepository(this._db);

  @override
  Stream<List<domain.Loan>> watchAll() => _db.loanDao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(),
  );

  @override
  Future<List<domain.Loan>> getAll() async =>
      (await _db.loanDao.getAll()).map((r) => r.toDomain()).toList();

  @override
  Future<void> add(domain.Loan loan) =>
      _db.loanDao.insertLoan(loan.toCompanion());

  @override
  Future<void> update(domain.Loan loan) =>
      _db.loanDao.updateLoan(loan.toCompanion());

  @override
  Future<void> delete(String id) => _db.loanDao.deleteLoan(id);
}
