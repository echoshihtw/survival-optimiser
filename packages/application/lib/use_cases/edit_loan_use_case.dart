import 'package:domain/domain.dart';

class EditLoanUseCase {
  final LoanRepository _repository;
  const EditLoanUseCase(this._repository);

  Future<void> execute(Loan loan) => _repository.update(loan);
}
