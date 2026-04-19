import 'package:drift/drift.dart';
import 'package:domain/domain.dart' as domain;
import '../database/app_database.dart';

extension LoanRowMapper on Loan {
  domain.Loan toDomain() => domain.Loan(
    id:             id,
    name:           name,
    source:         source,
    originalAmount: originalAmount,
    monthlyPayment: monthlyPayment,
    startDate:      startDate,
    note:           note,
    isActive:       isActive,
    createdAt:      createdAt,
    updatedAt:      updatedAt,
  );
}

extension LoanDomainMapper on domain.Loan {
  LoansCompanion toCompanion() => LoansCompanion(
    id:             Value(id),
    name:           Value(name),
    source:         Value(source),
    originalAmount: Value(originalAmount),
    monthlyPayment: Value(monthlyPayment),
    startDate:      Value(startDate),
    note:           Value(note),
    isActive:       Value(isActive),
    createdAt:      Value(createdAt),
    updatedAt:      Value(updatedAt),
  );
}
