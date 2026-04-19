import '../enums/transaction_type.dart';
import '../value_objects/money.dart';
import '../value_objects/survival_month.dart';

class Transaction {
  final String id;
  final SurvivalMonth month;
  final TransactionType type;
  final Money amount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.month,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Signed amount — positive for inflows, negative for outflows
  double get signedAmount =>
      type.isInflow ? amount.value : -amount.value;

  Transaction copyWith({
    String? id,
    SurvivalMonth? month,
    TransactionType? type,
    Money? amount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id:        id        ?? this.id,
      month:     month     ?? this.month,
      type:      type      ?? this.type,
      amount:    amount    ?? this.amount,
      note:      note      ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
