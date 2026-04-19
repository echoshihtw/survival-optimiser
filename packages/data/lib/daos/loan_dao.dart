import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/loans_table.dart';

part 'loan_dao.g.dart';

@DriftAccessor(tables: [Loans])
class LoanDao extends DatabaseAccessor<AppDatabase>
    with _$LoanDaoMixin {
  LoanDao(super.db);

  Stream<List<Loan>> watchAll() => select(loans).watch();
  Future<List<Loan>> getAll()   => select(loans).get();

  Future<void> insertLoan(LoansCompanion entry) =>
      into(loans).insert(entry);

  Future<void> updateLoan(LoansCompanion entry) =>
      (update(loans)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteLoan(String id) =>
      (delete(loans)..where((t) => t.id.equals(id))).go();
}
