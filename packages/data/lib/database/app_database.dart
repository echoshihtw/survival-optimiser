import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../tables/transactions_table.dart';
import '../tables/loans_table.dart';
import '../daos/transaction_dao.dart';
import '../daos/loan_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Loans],
  daos:   [TransactionDao, LoanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.loanId);
        await m.createTable(loans);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'survival.db'));
    return NativeDatabase.createInBackground(file);
  });
}
