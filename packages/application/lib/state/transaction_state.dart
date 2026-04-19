import 'package:domain/domain.dart';

enum TransactionStateStatus { initial, loading, loaded, error }

class TransactionState {
  final List<Transaction> transactions;
  final TransactionStateStatus status;
  final String? errorMessage;

  const TransactionState({
    this.transactions = const [],
    this.status = TransactionStateStatus.initial,
    this.errorMessage,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    TransactionStateStatus? status,
    String? errorMessage,
  }) {
    return TransactionState(
      transactions:  transactions  ?? this.transactions,
      status:        status        ?? this.status,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }

  bool get isLoading => status == TransactionStateStatus.loading;
  bool get hasError  => status == TransactionStateStatus.error;
  bool get isEmpty   => transactions.isEmpty;
}
