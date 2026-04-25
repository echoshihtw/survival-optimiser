import 'package:drift/drift.dart';

class Loans extends Table {
  TextColumn get id                  => text()();
  TextColumn get name                => text()();
  TextColumn get source              => text()();
  RealColumn get originalAmount      => real()();
  RealColumn get monthlyPayment      => real()();
  IntColumn get originalTermMonths   => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate       => dateTime()();
  TextColumn get note                => text().nullable()();
  BoolColumn get isActive            => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt       => dateTime()();
  DateTimeColumn get updatedAt       => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
