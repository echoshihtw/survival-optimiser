import '../enums/survival_status.dart';

class ModelState {
  final double currentCash;
  final double burnRate;
  final double effectiveBurnRate;
  final double monthlyPayment;
  final double subscriptionMonthlyCost;
  final double? expectedMonthlyInflow;
  final double? expectedMonthlyBurnOverride;
  final int runwayMonths;
  final int runwayDays;
  final DateTime? runOutDate;
  final double pressureRatio;

  const ModelState({
    required this.currentCash,
    required this.burnRate,
    required this.effectiveBurnRate,
    required this.monthlyPayment,
    required this.subscriptionMonthlyCost,
    this.expectedMonthlyInflow,
    this.expectedMonthlyBurnOverride,
    required this.runwayMonths,
    required this.runwayDays,
    this.runOutDate,
    required this.pressureRatio,
  });

  double get totalMonthlyOutflow => effectiveBurnRate;
  double get historicalMonthlyBurn => burnRate;
  double get emergencyMonthlyBurn => effectiveBurnRate;
  double get sustainableNetMonthlyFlow =>
      (expectedMonthlyInflow ?? 0) - emergencyMonthlyBurn;
  bool get hasSustainableProjection => expectedMonthlyInflow != null;
  bool get isSustainableIndefinitely =>
      hasSustainableProjection && sustainableNetMonthlyFlow >= 0;
  double get sustainableMonthlyShortfall =>
      sustainableNetMonthlyFlow < 0 ? sustainableNetMonthlyFlow.abs() : 0.0;
  int get sustainableRunwayMonths {
    if (!hasSustainableProjection) return runwayMonths;
    if (isSustainableIndefinitely) return 9999;
    if (sustainableMonthlyShortfall <= 0) return 9999;
    return (currentCash / sustainableMonthlyShortfall).floor();
  }

  int get sustainableRunwayDays {
    if (!hasSustainableProjection) return runwayDays;
    if (isSustainableIndefinitely) return 99999;
    if (sustainableMonthlyShortfall <= 0) return 99999;
    return (currentCash / sustainableMonthlyShortfall * 30).floor();
  }

  double get fixedObligations => monthlyPayment + subscriptionMonthlyCost;
  double get fixedPressureRatio => totalMonthlyOutflow > 0
      ? (fixedObligations / totalMonthlyOutflow).clamp(0.0, 1.0)
      : 0.0;
  double get flexibilityRatio => 1.0 - fixedPressureRatio;
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
    expectedMonthlyInflow: null,
    expectedMonthlyBurnOverride: null,
    runwayMonths: 0,
    runwayDays: 0,
    runOutDate: null,
    pressureRatio: 0,
  );
}
