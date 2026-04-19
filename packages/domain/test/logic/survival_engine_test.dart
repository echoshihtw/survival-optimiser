import 'package:test/test.dart';
import 'package:domain/domain.dart';

void main() {
  group('computeModel', () {
    test('returns empty model when no months', () {
      final result = computeModel(months: [], monthlyPayment: 0);
      expect(result.currentCash, 0);
      expect(result.runwayMonths, 0);
      expect(result.investableCash, 0);
    });

    test('computes burnRate as average of negative netFlows', () {
      final months = [
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 1)),
          netFlow: -40000,
          balance: 960000,
        ),
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 2)),
          netFlow: -60000,
          balance: 900000,
        ),
      ];
      final result = computeModel(months: months, monthlyPayment: 0);
      expect(result.burnRate, 50000); // avg of 40k and 60k
    });

    test('runway is count of months before balance hits zero', () {
      final months = List.generate(
        24,
        (i) => MonthlyState(
          month:   SurvivalMonth(DateTime(2025, i + 1)),
          netFlow: -50000,
          balance: 1000000 - (i + 1) * 50000,
        ),
      );
      final result = computeModel(months: months, monthlyPayment: 0);
      expect(result.runwayMonths, 19); // balance hits 0 at month 20
    });

    test('investableCash is zero when below safety threshold', () {
      final months = [
        MonthlyState(
          month:   SurvivalMonth(DateTime(2025, 1)),
          netFlow: -50000,
          balance: 100000, // only 2 months of runway
        ),
      ];
      final result = computeModel(months: months, monthlyPayment: 0);
      expect(result.investableCash, 0);
    });

    test('survivalStatus is stable when runway >= 24', () {
      final months = List.generate(
        30,
        (i) => MonthlyState(
          month:   SurvivalMonth(DateTime(2025, i + 1)),
          netFlow: -50000,
          balance: 2000000 - (i + 1) * 50000,
        ),
      );
      final result = computeModel(months: months, monthlyPayment: 0);
      expect(result.survivalStatus, SurvivalStatus.stable);
    });

    test('survivalStatus is critical when runway < 12', () {
      final months = [
        MonthlyState(
          month:   SurvivalMonth(DateTime(2025, 1)),
          netFlow: -50000,
          balance: 300000, // 6 months runway
        ),
      ];
      final result = computeModel(months: months, monthlyPayment: 0);
      expect(result.survivalStatus, SurvivalStatus.critical);
    });

    test('pressure reduces investableCash', () {
      final months = List.generate(
        30,
        (i) => MonthlyState(
          month:   SurvivalMonth(DateTime(2025, i + 1)),
          netFlow: -50000,
          balance: 3000000 - (i + 1) * 50000,
        ),
      );

      final noPressure   = computeModel(months: months, monthlyPayment: 0);
      final withPressure = computeModel(months: months, monthlyPayment: 25000);

      expect(withPressure.investableCash, lessThan(noPressure.investableCash));
    });
  });
}
