import 'package:domain/domain.dart';

Transaction makeTx({
  required int year,
  required int month,
  required int day,
  required TransactionType type,
  required double amount,
  String? loanId,
  String? note,
}) {
  final now = DateTime.now();
  return Transaction(
    id: '$year-$month-$day-${type.name}',
    date: DateTime(year, month, day),
    type: type,
    amount: Money(amount),
    note: note,
    loanId: loanId,
    createdAt: now,
    updatedAt: now,
  );
}

Loan makeLoan({
  required String id,
  required String name,
  required double originalAmount,
  required double monthlyPayment,
  String source = 'BANK',
  bool isActive = true,
}) {
  final now = DateTime.now();
  return Loan(
    id: id,
    name: name,
    source: source,
    originalAmount: originalAmount,
    monthlyPayment: monthlyPayment,
    startDate: now,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}
