import '../enums/survival_status.dart';
import 'identity_badge.dart';

class ModelState {
  final double currentCash;
  final double burnRate;
  final double effectiveBurnRate;
  final double monthlyPayment;
  final double subscriptionMonthlyCost;
  final int runwayMonths;
  final int runwayDays;
  final DateTime? runOutDate;
  final double pressureRatio;
  final IdentityBadge badge;

  const ModelState({
    required this.currentCash,
    required this.burnRate,
    required this.effectiveBurnRate,
    required this.monthlyPayment,
    required this.subscriptionMonthlyCost,
    required this.runwayMonths,
    required this.runwayDays,
    this.runOutDate,
    required this.pressureRatio,
    required this.badge,
  });

  double get totalMonthlyOutflow => effectiveBurnRate;
  bool get isOverBudget => burnRate > effectiveBurnRate && burnRate > 0;
  SurvivalStatus get survivalStatus => switch (runwayMonths) {
    >= 24 => SurvivalStatus.stable,
    >= 12 => SurvivalStatus.caution,
    _ => SurvivalStatus.critical,
  };

  static ModelState empty() => ModelState(
    currentCash: 0,
    burnRate: 0,
    effectiveBurnRate: 0,
    monthlyPayment: 0,
    subscriptionMonthlyCost: 0,
    runwayMonths: 0,
    runwayDays: 0,
    runOutDate: null,
    pressureRatio: 0,
    badge: IdentityBadge.survivalMode,
  );
}
