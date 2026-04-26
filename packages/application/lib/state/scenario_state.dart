class ScenarioState {
  final double? burnRateOverride;
  final double? simulatedIncome;
  final bool isActive;

  const ScenarioState({
    this.burnRateOverride,
    this.simulatedIncome,
    this.isActive = false,
  });

  ScenarioState copyWith({
    double? burnRateOverride,
    double? simulatedIncome,
    bool? isActive,
  }) {
    return ScenarioState(
      burnRateOverride: burnRateOverride ?? this.burnRateOverride,
      simulatedIncome: simulatedIncome ?? this.simulatedIncome,
      isActive: isActive ?? this.isActive,
    );
  }

  ScenarioState reset() => const ScenarioState();
}
