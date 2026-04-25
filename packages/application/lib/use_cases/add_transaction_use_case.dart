import 'package:domain/domain.dart';

class AddTransactionUseCase {
  final TransactionRepository _repository;

  const AddTransactionUseCase(this._repository);

  Future<void> execute(Transaction transaction) async {
    if (transaction.amount.isZero) {
      throw const InvalidTransactionFailure('Amount cannot be zero');
    }
    if (transaction.amount.value > 1e12) {
      throw const InvalidTransactionFailure('Amount exceeds maximum');
    }
    await _repository.add(transaction);
  }
}
