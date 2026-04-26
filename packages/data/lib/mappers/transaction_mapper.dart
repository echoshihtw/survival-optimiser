import 'package:drift/drift.dart';
import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';

extension TransactionRowMapper on Transaction {
  domain.Transaction toDomain() => domain.Transaction(
    id: id,
    date: date,
    type: domain.TransactionType.values.byName(type),
    amount: domain.Money(amount),
    note: note,
    loanId: loanId,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TransactionDomainMapper on domain.Transaction {
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    date: Value(date),
    type: Value(type.name),
    amount: Value(amount.value),
    note: Value(note),
    loanId: Value(loanId),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
