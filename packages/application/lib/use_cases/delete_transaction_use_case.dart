import 'package:domain/domain.dart';

class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  const DeleteTransactionUseCase(this._repository);

  Future<void> execute(String id) async {
    await _repository.delete(id);
  }
}
