import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:domain/domain.dart';
import 'package:application/application.dart';

class _MockTransactionRepo extends Mock implements TransactionRepository {}

void main() {
  late _MockTransactionRepo repo;

  setUp(() {
    repo = _MockTransactionRepo();
    registerFallbackValue(_baseTx(amount: 1));
  });

  group('AddTransactionUseCase', () {
    late AddTransactionUseCase useCase;
    setUp(() => useCase = AddTransactionUseCase(repo));

    test('throws InvalidTransactionFailure for zero amount', () {
      expect(
        () => useCase.execute(_baseTx(amount: 0)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
      verifyNever(() => repo.add(any()));
    });

    test('throws InvalidTransactionFailure when amount exceeds 1e12', () {
      expect(
        () => useCase.execute(_baseTx(amount: 1e12 + 1)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
      verifyNever(() => repo.add(any()));
    });

    test('delegates to repository for valid transaction', () async {
      when(() => repo.add(any())).thenAnswer((_) async {});
      final tx = _baseTx(amount: 50000);
      await useCase.execute(tx);
      verify(() => repo.add(tx)).called(1);
    });

    test('accepts the maximum allowed amount (1e12)', () async {
      when(() => repo.add(any())).thenAnswer((_) async {});
      await useCase.execute(_baseTx(amount: 1e12));
      verify(() => repo.add(any())).called(1);
    });
  });

  group('EditTransactionUseCase', () {
    late EditTransactionUseCase useCase;
    setUp(() => useCase = EditTransactionUseCase(repo));

    test('throws InvalidTransactionFailure for zero amount', () {
      expect(
        () => useCase.execute(_baseTx(amount: 0)),
        throwsA(isA<InvalidTransactionFailure>()),
      );
      verifyNever(() => repo.update(any()));
    });

    test('delegates to repository for valid update', () async {
      when(() => repo.update(any())).thenAnswer((_) async {});
      final tx = _baseTx(amount: 25000);
      await useCase.execute(tx);
      verify(() => repo.update(tx)).called(1);
    });
  });

  group('DeleteTransactionUseCase', () {
    late DeleteTransactionUseCase useCase;
    setUp(() => useCase = DeleteTransactionUseCase(repo));

    test('delegates delete call to repository', () async {
      when(() => repo.delete(any())).thenAnswer((_) async {});
      await useCase.execute('tx-42');
      verify(() => repo.delete('tx-42')).called(1);
    });
  });
}

Transaction _baseTx({required double amount}) {
  final now = DateTime(2025, 1, 1);
  return Transaction(
    id: 'tx-1',
    date: now,
    type: TransactionType.expense,
    amount: amount == 0 ? Money.zero() : Money(amount),
    createdAt: now,
    updatedAt: now,
  );
}
