import '../value_objects/survival_month.dart';

class MonthlyState {
  final SurvivalMonth month;
  final double netFlow;
  final double balance;

  const MonthlyState({
    required this.month,
    required this.netFlow,
    required this.balance,
  });
}
