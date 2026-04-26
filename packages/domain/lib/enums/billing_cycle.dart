enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get label => switch (this) {
    BillingCycle.weekly => 'WEEKLY',
    BillingCycle.monthly => 'MONTHLY',
    BillingCycle.quarterly => 'QUARTERLY',
    BillingCycle.yearly => 'YEARLY',
  };

  /// Normalized cost per month
  double monthlyEquivalent(double amount) => switch (this) {
    BillingCycle.weekly => amount * 52 / 12,
    BillingCycle.monthly => amount,
    BillingCycle.quarterly => amount / 3,
    BillingCycle.yearly => amount / 12,
  };

  /// Days between billing cycles
  int get intervalDays => switch (this) {
    BillingCycle.weekly => 7,
    BillingCycle.monthly => 30,
    BillingCycle.quarterly => 90,
    BillingCycle.yearly => 365,
  };
}
