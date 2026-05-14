import 'package:test/test.dart';
import 'package:domain/domain.dart';

List<MonthlyState> makeMonths({
  required double startBalance,
  required double netFlowPerMonth,
  required int count,
  double? grossOutflowPerMonth,
}) {
  final result = <MonthlyState>[];
  double balance = startBalance;
  for (int i = 0; i < count; i++) {
    balance += netFlowPerMonth;
    result.add(
      MonthlyState(
        month: SurvivalMonth(DateTime(2025, i + 1)),
        netFlow: netFlowPerMonth,
        balance: balance,
        grossOutflow: grossOutflowPerMonth ?? netFlowPerMonth.abs(),
      ),
    );
  }
  return result;
}

void main() {
  group('computeModel', () {
    test('returns model with subscription cost even for no months', () {
      final m = computeModel(
        months: [],
        monthlyPayment: 0,
        subscriptionMonthlyCost: 5000,
      );
      expect(m.subscriptionMonthlyCost, 5000);
    });

    test('currentCash is last balance', () {
      final months = makeMonths(
        startBalance: 1000000,
        netFlowPerMonth: -50000,
        count: 3,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.currentCash, 850000);
    });

    test('burnRate uses grossOutflow not netFlow', () {
      final months = [
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 1)),
          netFlow: 30000,
          balance: 1030000,
          grossOutflow: 50000,
        ),
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 2)),
          netFlow: -10000,
          balance: 1020000,
          grossOutflow: 60000,
        ),
      ];
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.burnRate, 55000);
    });

    test('burnRate is 0 when no gross outflows', () {
      final months = [
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 1)),
          netFlow: 80000,
          balance: 1080000,
          grossOutflow: 0,
        ),
      ];
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.burnRate, 0);
    });

    test('runway projects beyond known months', () {
      final months = makeMonths(
        startBalance: 950000,
        netFlowPerMonth: -50000,
        count: 2,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.runwayMonths, greaterThan(2));
    });

    test('runOutDate is null when burn rate is zero', () {
      final months = makeMonths(
        startBalance: 1000000,
        netFlowPerMonth: 0,
        count: 3,
        grossOutflowPerMonth: 0,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.runOutDate, isNull);
    });

    test('runOutDate is set when balance hits zero', () {
      final months = makeMonths(
        startBalance: 100000,
        netFlowPerMonth: -50000,
        count: 2,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.runOutDate, isNotNull);
    });

    test('runway calculates mathematically beyond projection cap', () {
      // 300,000 / 167 = ~1,796 months
      final months = [
        MonthlyState(
          month: SurvivalMonth(DateTime(2025, 1)),
          netFlow: -167,
          balance: 300000,
          grossOutflow: 167,
        ),
      ];
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.runwayMonths, greaterThan(120));
    });

    test('survivalStatus stable when runway >= 24', () {
      final months = makeMonths(
        startBalance: 2000000,
        netFlowPerMonth: -50000,
        count: 5,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.survivalStatus, SurvivalStatus.stable);
    });

    test('survivalStatus caution when runway 12-23', () {
      final months = makeMonths(
        startBalance: 850000,
        netFlowPerMonth: -50000,
        count: 3,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.survivalStatus, SurvivalStatus.caution);
    });

    test('survivalStatus critical when runway < 12', () {
      final months = makeMonths(
        startBalance: 300000,
        netFlowPerMonth: -50000,
        count: 2,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(m.survivalStatus, SurvivalStatus.critical);
    });

    test('subscription cost reduces runway', () {
      final months = makeMonths(
        startBalance: 1000000,
        netFlowPerMonth: -50000,
        count: 3,
      );
      final withSub = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 10000,
      );
      final noSub = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      expect(withSub.runwayMonths, lessThan(noSub.runwayMonths));
    });

    test(
      'expected inflow creates sustainable runway without changing history',
      () {
        final months = makeMonths(
          startBalance: 100000,
          netFlowPerMonth: -50000,
          count: 3,
        );
        final m = computeModel(
          months: months,
          monthlyPayment: 0,
          subscriptionMonthlyCost: 0,
          expectedMonthlyInflow: 60000,
        );

        expect(m.historicalMonthlyBurn, 50000);
        expect(m.emergencyMonthlyBurn, 50000);
        expect(m.sustainableNetMonthlyFlow, 10000);
        expect(m.isSustainableIndefinitely, isTrue);
      },
    );

    test('expected burn override is a future assumption, not history', () {
      final months = makeMonths(
        startBalance: 300000,
        netFlowPerMonth: -50000,
        count: 3,
      );
      final historical = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
      );
      final m = computeModel(
        months: months,
        monthlyPayment: 0,
        subscriptionMonthlyCost: 0,
        expectedMonthlyBurnOverride: 25000,
      );

      expect(m.historicalMonthlyBurn, 50000);
      expect(m.emergencyMonthlyBurn, 25000);
      expect(m.runwayMonths, greaterThan(historical.runwayMonths));
    });
  });
}
