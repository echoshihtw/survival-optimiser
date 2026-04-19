import 'package:test/test.dart';
import 'package:domain/domain.dart';

List<MonthlyState> makeMonths({
  required double startBalance,
  required double netFlowPerMonth,
  required int count,
}) {
  final result   = <MonthlyState>[];
  double balance = startBalance;
  for (int i = 0; i < count; i++) {
    balance += netFlowPerMonth;
    result.add(MonthlyState(
      month:   SurvivalMonth(DateTime(2025, i + 1)),
      netFlow: netFlowPerMonth,
      balance: balance,
    ));
  }
  return result;
}

void main() {
  group('computeModel', () {
    test('returns empty model for no months', () {
      final m = computeModel(months: [], monthlyPayment: 0);
      expect(m.currentCash, 0);
      expect(m.runwayMonths, 0);
      expect(m.investableCash, 0);
    });

    test('currentCash is last balance', () {
      final months = makeMonths(
          startBalance: 1000000, netFlowPerMonth: -50000, count: 3);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.currentCash, 850000);
    });

    test('burnRate is average of negative netFlows', () {
      final months = [
        MonthlyState(month: SurvivalMonth(DateTime(2025, 1)),
            netFlow: -40000, balance: 960000),
        MonthlyState(month: SurvivalMonth(DateTime(2025, 2)),
            netFlow: -60000, balance: 900000),
      ];
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.burnRate, 50000);
    });

    test('burnRate falls back to 50000 if no negative flows', () {
      final months = [
        MonthlyState(month: SurvivalMonth(DateTime(2025, 1)),
            netFlow: 80000, balance: 1080000),
      ];
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.burnRate, 50000);
    });

    test('runway projects beyond known months', () {
      final months = makeMonths(
          startBalance: 950000, netFlowPerMonth: -50000, count: 2);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.runwayMonths, greaterThan(2));
    });

    test('runOutDate is null when projected balance never hits zero', () {
      // Very high balance, positive flow — will never run out in 120 months
      final months = makeMonths(
          startBalance: 100000000, netFlowPerMonth: 10000, count: 12);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.runOutDate, isNull);
    });

    test('runOutDate is set when balance hits zero', () {
      final months = makeMonths(
          startBalance: 100000, netFlowPerMonth: -50000, count: 2);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.runOutDate, isNotNull);
    });

    test('survivalStatus stable when runway >= 24', () {
      final months = makeMonths(
          startBalance: 2000000, netFlowPerMonth: -50000, count: 5);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.survivalStatus, SurvivalStatus.stable);
    });

    test('survivalStatus caution when runway 12-23', () {
      final months = makeMonths(
          startBalance: 850000, netFlowPerMonth: -50000, count: 3);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.survivalStatus, SurvivalStatus.caution);
    });

    test('survivalStatus critical when runway < 12', () {
      final months = makeMonths(
          startBalance: 300000, netFlowPerMonth: -50000, count: 2);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.survivalStatus, SurvivalStatus.critical);
    });

    test('investableCash is zero below safety threshold', () {
      final months = makeMonths(
          startBalance: 100000, netFlowPerMonth: -50000, count: 2);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.investableCash, 0);
    });

    test('pressure reduces investableCash', () {
      final months = makeMonths(
          startBalance: 3000000, netFlowPerMonth: -50000, count: 5);
      final noPressure   = computeModel(months: months, monthlyPayment: 0);
      final withPressure = computeModel(months: months, monthlyPayment: 25000);
      expect(withPressure.investableCash,
          lessThan(noPressure.investableCash));
    });

    test('filledHearts clamps between 0 and 12', () {
      final empty = computeModel(months: [], monthlyPayment: 0);
      expect(empty.filledHearts, 0);

      final months = makeMonths(
          startBalance: 10000000, netFlowPerMonth: -50000, count: 5);
      final m = computeModel(months: months, monthlyPayment: 0);
      expect(m.filledHearts, inInclusiveRange(0, 12));
    });
  });
}
