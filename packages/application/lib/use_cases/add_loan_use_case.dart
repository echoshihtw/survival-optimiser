import 'package:domain/domain.dart';

class AddLoanUseCase {
  final LoanRepository _repository;
  const AddLoanUseCase(this._repository);

  Future<void> execute(Loan loan) => _repository.add(loan);
}
