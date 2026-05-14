class FinancialAssumptions {
  final double? expectedMonthlyInflow;
  final double? expectedMonthlyBurnOverride;

  const FinancialAssumptions({
    this.expectedMonthlyInflow,
    this.expectedMonthlyBurnOverride,
  });

  bool get hasExpectedMonthlyInflow =>
      expectedMonthlyInflow != null && expectedMonthlyInflow! > 0;

  bool get hasExpectedMonthlyBurnOverride =>
      expectedMonthlyBurnOverride != null && expectedMonthlyBurnOverride! > 0;
}
