import 'package:domain/domain.dart';

class DeleteLoanUseCase {
  final LoanRepository _repository;
  const DeleteLoanUseCase(this._repository);

  Future<void> execute(String id) => _repository.delete(id);
}
