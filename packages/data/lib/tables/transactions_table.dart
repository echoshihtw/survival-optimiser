import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id        => text()();
  DateTimeColumn get date  => dateTime()();
  TextColumn get type      => text()();
  RealColumn get amount    => real()();
  TextColumn get note      => text().nullable()();
  TextColumn get loanId    => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
