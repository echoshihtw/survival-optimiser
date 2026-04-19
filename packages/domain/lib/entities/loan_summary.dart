import 'loan.dart';

class LoanSummary {
  final Loan loan;
  final double totalRepaid;
  final double remainingBalance;
  final double paidThisMonth;

  const LoanSummary({
    required this.loan,
    required this.totalRepaid,
    required this.remainingBalance,
    required this.paidThisMonth,
  });

  double get repaidRatio =>
      loan.originalAmount > 0
          ? (totalRepaid / loan.originalAmount).clamp(0.0, 1.0)
          : 0.0;

  bool get isFullyPaid => remainingBalance <= 0;

  int get monthsRemaining =>
      loan.monthlyPayment > 0
          ? (remainingBalance / loan.monthlyPayment).ceil().clamp(0, 9999)
          : 0;

  bool get isAheadThisMonth => paidThisMonth >= loan.monthlyPayment;
}
