import 'package:domain/domain.dart';

class EditTransactionUseCase {
  final TransactionRepository _repository;

  const EditTransactionUseCase(this._repository);

  Future<void> execute(Transaction transaction) async {
    if (transaction.amount.isZero) {
      throw const InvalidTransactionFailure('Amount cannot be zero');
    }
    await _repository.update(transaction);
  }
}
