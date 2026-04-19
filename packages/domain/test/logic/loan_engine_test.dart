import 'package:test/test.dart';
import 'package:domain/domain.dart';
import '../helpers/transaction_helper.dart';

void main() {
  group('computeLoanSummaries', () {
    test('returns empty for no loans', () {
      final result = computeLoanSummaries(loans: [], transactions: []);
      expect(result, isEmpty);
    });

    test('totalRepaid is zero with no repayments', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 500000, monthlyPayment: 15000,
      );
      final result = computeLoanSummaries(
          loans: [loan], transactions: []);
      expect(result.first.totalRepaid, 0);
      expect(result.first.remainingBalance, 500000);
    });

    test('totalRepaid sums matching repayments', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 500000, monthlyPayment: 15000,
      );
      final txs = [
        makeTx(year: 2025, month: 1, day: 1,
            type: TransactionType.repayment,
            amount: 15000, loanId: 'loan1'),
        makeTx(year: 2025, month: 2, day: 1,
            type: TransactionType.repayment,
            amount: 15000, loanId: 'loan1'),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.totalRepaid, 30000);
      expect(result.first.remainingBalance, 470000);
    });

    test('ignores repayments for other loans', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 500000, monthlyPayment: 15000,
      );
      final txs = [
        makeTx(year: 2025, month: 1, day: 1,
            type: TransactionType.repayment,
            amount: 15000, loanId: 'loan2'),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.totalRepaid, 0);
    });

    test('remainingBalance clamps to zero', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 10000, monthlyPayment: 5000,
      );
      final txs = [
        makeTx(year: 2025, month: 1, day: 1,
            type: TransactionType.repayment,
            amount: 15000, loanId: 'loan1'),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.remainingBalance, 0);
      expect(result.first.isFullyPaid, true);
    });

    test('repaidRatio calculates correctly', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 100000, monthlyPayment: 10000,
      );
      final txs = [
        makeTx(year: 2025, month: 1, day: 1,
            type: TransactionType.repayment,
            amount: 25000, loanId: 'loan1'),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.repaidRatio, 0.25);
    });

    test('monthsRemaining calculates correctly', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 120000, monthlyPayment: 10000,
      );
      final txs = [
        makeTx(year: 2025, month: 1, day: 1,
            type: TransactionType.repayment,
            amount: 20000, loanId: 'loan1'),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.monthsRemaining, 10);
    });

    test('isAheadThisMonth true when paid >= installment', () {
      final loan = makeLoan(
        id: 'loan1', name: 'Test',
        originalAmount: 500000, monthlyPayment: 15000,
      );
      final now = DateTime.now();
      final txs = [
        Transaction(
          id: 'tx1', date: now,
          type: TransactionType.repayment,
          amount: Money(20000),
          loanId: 'loan1',
          createdAt: now, updatedAt: now,
        ),
      ];
      final result = computeLoanSummaries(
          loans: [loan], transactions: txs);
      expect(result.first.isAheadThisMonth, true);
      expect(result.first.paidThisMonth, 20000);
    });
  });

  group('totalMonthlyPayment', () {
    test('sums active loan payments', () {
      final loans = [
        makeLoan(id: 'l1', name: 'A',
            originalAmount: 100000, monthlyPayment: 10000),
        makeLoan(id: 'l2', name: 'B',
            originalAmount: 200000, monthlyPayment: 15000),
      ];
      expect(totalMonthlyPayment(loans), 25000);
    });

    test('excludes inactive loans', () {
      final loans = [
        makeLoan(id: 'l1', name: 'A',
            originalAmount: 100000, monthlyPayment: 10000, isActive: true),
        makeLoan(id: 'l2', name: 'B',
            originalAmount: 200000, monthlyPayment: 15000, isActive: false),
      ];
      expect(totalMonthlyPayment(loans), 10000);
    });

    test('returns zero for empty list', () {
      expect(totalMonthlyPayment([]), 0);
    });
  });
}
