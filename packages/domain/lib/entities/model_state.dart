import '../enums/survival_status.dart';

class ModelState {
  final double currentCash;
  final double burnRate;
  final double monthlyPayment;
  final int runwayMonths;
  final DateTime? runOutDate;
  final double pressureRatio;
  final double safetyCash;
  final double surplus;
  final double riskCapacity;
  final double pressureFactor;
  final double investableCash;

  const ModelState({
    required this.currentCash,
    required this.burnRate,
    required this.monthlyPayment,
    required this.runwayMonths,
    this.runOutDate,
    required this.pressureRatio,
    required this.safetyCash,
    required this.surplus,
    required this.riskCapacity,
    required this.pressureFactor,
    required this.investableCash,
  });

  SurvivalStatus get survivalStatus => switch (runwayMonths) {
    >= 24 => SurvivalStatus.stable,
    >= 12 => SurvivalStatus.caution,
    _     => SurvivalStatus.critical,
  };

  int get filledHearts => (riskCapacity * 12).floor().clamp(0, 12);

  static ModelState empty() => const ModelState(
    currentCash:    0,
    burnRate:       50000,
    monthlyPayment: 0,
    runwayMonths:   0,
    runOutDate:     null,
    pressureRatio:  0,
    safetyCash:     0,
    surplus:        0,
    riskCapacity:   0,
    pressureFactor: 1,
    investableCash: 0,
  );
}
