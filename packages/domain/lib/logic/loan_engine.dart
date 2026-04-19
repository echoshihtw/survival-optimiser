import '../entities/loan.dart';
import '../entities/loan_summary.dart';
import '../entities/transaction.dart';
import '../enums/transaction_type.dart';

List<LoanSummary> computeLoanSummaries({
  required List<Loan> loans,
  required List<Transaction> transactions,
}) {
  final now        = DateTime.now();
  final repayments = transactions
      .where((t) => t.type == TransactionType.repayment && t.loanId != null);

  return loans.map((loan) {
    final loanRepayments = repayments.where((t) => t.loanId == loan.id);

    final totalRepaid = loanRepayments
        .fold(0.0, (sum, t) => sum + t.amount.value);

    final paidThisMonth = loanRepayments
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.value);

    final remaining =
        (loan.originalAmount - totalRepaid).clamp(0.0, double.infinity);

    return LoanSummary(
      loan:             loan,
      totalRepaid:      totalRepaid,
      remainingBalance: remaining,
      paidThisMonth:    paidThisMonth,
    );
  }).toList();
}

double totalMonthlyPayment(List<Loan> loans) {
  return loans
      .where((l) => l.isActive)
      .fold(0.0, (sum, l) => sum + l.monthlyPayment);
}
