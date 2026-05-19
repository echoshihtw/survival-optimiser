import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';

class _MockLoanRepo extends Mock implements LoanRepository {}

void main() {
  late _MockLoanRepo repo;

  setUp(() {
    repo = _MockLoanRepo();
    registerFallbackValue(_baseLoan());
  });

  group('AddLoanUseCase', () {
    late AddLoanUseCase useCase;
    setUp(() => useCase = AddLoanUseCase(repo));

    test('throws when originalAmount is zero', () {
      expect(
        () => useCase.execute(_baseLoan(originalAmount: 0, payment: 10000)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
      verifyNever(() => repo.add(any()));
    });

    test('throws when originalAmount is negative', () {
      expect(
        () => useCase.execute(_baseLoan(originalAmount: -1000, payment: 10000)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('throws when originalAmount exceeds 1e12', () {
      expect(
        () => useCase.execute(_baseLoan(originalAmount: 1e12 + 1, payment: 10000)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('throws when monthlyPayment is zero', () {
      expect(
        () => useCase.execute(_baseLoan(originalAmount: 500000, payment: 0)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('throws when name is blank', () {
      expect(
        () => useCase.execute(_baseLoan(name: '   ')),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('delegates to repository for valid loan', () async {
      when(() => repo.add(any())).thenAnswer((_) async {});
      final loan = _baseLoan();
      await useCase.execute(loan);
      verify(() => repo.add(loan)).called(1);
    });
  });

  group('EditLoanUseCase', () {
    late EditLoanUseCase useCase;
    setUp(() => useCase = EditLoanUseCase(repo));

    test('throws when originalAmount is not positive', () {
      expect(
        () => useCase.execute(_baseLoan(originalAmount: 0, payment: 10000)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('throws when monthlyPayment is not positive', () {
      expect(
        () => useCase.execute(_baseLoan(payment: 0)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('throws when name is empty after trim', () {
      expect(
        () => useCase.execute(_baseLoan(name: '')),
        throwsA(isA<InvalidTransactionFailure>()),
      );
    });

    test('delegates to repository for valid update', () async {
      when(() => repo.update(any())).thenAnswer((_) async {});
      final loan = _baseLoan();
      await useCase.execute(loan);
      verify(() => repo.update(loan)).called(1);
    });
  });

  group('DeleteLoanUseCase', () {
    late DeleteLoanUseCase useCase;
    setUp(() => useCase = DeleteLoanUseCase(repo));

    test('delegates delete call to repository', () async {
      when(() => repo.delete(any())).thenAnswer((_) async {});
      await useCase.execute('loan-99');
      verify(() => repo.delete('loan-99')).called(1);
    });
  });
}

Loan _baseLoan({
  String name = 'TEST LOAN',
  double originalAmount = 500000,
  double payment = 15000,
}) {
  final now = DateTime(2025, 1, 1);
  return Loan(
    id: 'loan-1',
    name: name,
    source: 'BANK',
    originalAmount: originalAmount,
    monthlyPayment: payment,
    originalTermMonths: 36,
    startDate: now,
    createdAt: now,
    updatedAt: now,
  );
}
