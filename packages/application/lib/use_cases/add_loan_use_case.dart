import 'package:domain/domain.dart';

class AddLoanUseCase {
  final LoanRepository _repository;
  const AddLoanUseCase(this._repository);

  Future<void> execute(Loan loan) async {
    if (loan.originalAmount <= 0) {
      throw const InvalidTransactionFailure('Loan amount must be positive');
    }
    if (loan.originalAmount > 1e12) {
      throw const InvalidTransactionFailure('Loan amount exceeds maximum');
    }
    if (loan.monthlyPayment <= 0) {
      throw const InvalidTransactionFailure('Monthly payment must be positive');
    }
    if (loan.name.trim().isEmpty) {
      throw const InvalidTransactionFailure('Lender name is required');
    }
    await _repository.add(loan);
  }
}
