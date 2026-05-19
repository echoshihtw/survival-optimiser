import 'package:test/test.dart';
import 'package:domain/domain.dart';
import 'package:data/data.dart' hide Transaction, Loan, Subscription;
import 'db_helper.dart';

void main() {
  late AppDatabase db;
  late DriftLoanRepository repo;

  setUp(() {
    db = openTestDatabase();
    repo = DriftLoanRepository(db);
  });

  tearDown(() => db.close());

  group('DriftLoanRepository', () {
    test('getAll returns empty list on fresh database', () async {
      expect(await repo.getAll(), isEmpty);
    });

    test('add then getAll round-trips a loan', () async {
      await repo.add(_loan(id: 'loan-1', amount: 3_000_000, payment: 100_000));
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.id, 'loan-1');
      expect(all.first.originalAmount, 3_000_000);
      expect(all.first.monthlyPayment, 100_000);
    });

    test('update modifies monthly payment', () async {
      await repo.add(_loan(id: 'loan-1', amount: 3_000_000, payment: 100_000));
      await repo.update(_loan(id: 'loan-1', amount: 3_000_000, payment: 80_000));
      final all = await repo.getAll();
      expect(all.first.monthlyPayment, 80_000);
    });

    test('delete removes the loan', () async {
      await repo.add(_loan(id: 'loan-1', amount: 1_000_000, payment: 50_000));
      await repo.delete('loan-1');
      expect(await repo.getAll(), isEmpty);
    });

    test('multiple loans coexist', () async {
      await repo.add(_loan(id: 'loan-1', amount: 1_000_000, payment: 30_000));
      await repo.add(_loan(id: 'loan-2', amount: 2_000_000, payment: 60_000));
      expect((await repo.getAll()).length, 2);
    });

    test('watchAll emits updated list after add', () async {
      final stream = repo.watchAll();
      await repo.add(_loan(id: 'loan-1', amount: 1_000_000, payment: 30_000));
      final snapshot = await stream.first;
      expect(snapshot.length, 1);
      expect(snapshot.first.id, 'loan-1');
    });

    test('watchAll emits updated list after delete', () async {
      await repo.add(_loan(id: 'loan-1', amount: 1_000_000, payment: 30_000));
      await repo.add(_loan(id: 'loan-2', amount: 2_000_000, payment: 60_000));
      final stream = repo.watchAll();
      await repo.delete('loan-1');
      final snapshot = await stream.first;
      expect(snapshot.length, 1);
      expect(snapshot.first.id, 'loan-2');
    });

    test('round-trips all Loan fields correctly', () async {
      final start = DateTime(2024, 3, 1);
      final now = DateTime(2025, 1, 1);
      final loan = Loan(
        id: 'loan-full',
        name: 'Home Loan',
        source: 'Bank ABC',
        originalAmount: 5_000_000,
        monthlyPayment: 120_000,
        originalTermMonths: 48,
        startDate: start,
        note: 'refinanced',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );
      await repo.add(loan);
      final fetched = (await repo.getAll()).first;
      expect(fetched.name, 'Home Loan');
      expect(fetched.source, 'Bank ABC');
      expect(fetched.originalTermMonths, 48);
      expect(fetched.note, 'refinanced');
      expect(fetched.isActive, false);
    });
  });
}

Loan _loan({
  required String id,
  required double amount,
  required double payment,
}) {
  final now = DateTime(2025, 1, 1);
  return Loan(
    id: id,
    name: 'TEST LOAN',
    source: 'BANK',
    originalAmount: amount,
    monthlyPayment: payment,
    originalTermMonths: 36,
    startDate: now,
    createdAt: now,
    updatedAt: now,
  );
}
