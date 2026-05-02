enum IdentityBadge {
  survivalMode,
  financialRookie,
  gettingBy,
  financiallyStable,
  financialFortress,
  escapeVelocity,
}

extension IdentityBadgeX on IdentityBadge {
  String get emoji => switch (this) {
    IdentityBadge.survivalMode      => '🔴',
    IdentityBadge.financialRookie   => '🐣',
    IdentityBadge.gettingBy         => '🌊',
    IdentityBadge.financiallyStable => '🌿',
    IdentityBadge.financialFortress => '🏰',
    IdentityBadge.escapeVelocity    => '🚀',
  };

  String get title => switch (this) {
    IdentityBadge.survivalMode      => 'Survival Mode',
    IdentityBadge.financialRookie   => 'Financial Rookie',
    IdentityBadge.gettingBy         => 'Getting By',
    IdentityBadge.financiallyStable => 'Financially Stable',
    IdentityBadge.financialFortress => 'Financial Fortress',
    IdentityBadge.escapeVelocity    => 'Escape Velocity',
  };

  String get description => switch (this) {
    IdentityBadge.survivalMode      => 'Every day counts. Time to act.',
    IdentityBadge.financialRookie   => "You're just getting started.",
    IdentityBadge.gettingBy         => 'Staying afloat, but barely.',
    IdentityBadge.financiallyStable => 'You have breathing room.',
    IdentityBadge.financialFortress => 'Strong position. Well done.',
    IdentityBadge.escapeVelocity    => "You've cracked the code.",
  };

  int get percentile => switch (this) {
    IdentityBadge.survivalMode      => 5,
    IdentityBadge.financialRookie   => 20,
    IdentityBadge.gettingBy         => 40,
    IdentityBadge.financiallyStable => 65,
    IdentityBadge.financialFortress => 85,
    IdentityBadge.escapeVelocity    => 97,
  };

  static IdentityBadge fromDays(int days) {
    if (days < 30)   return IdentityBadge.survivalMode;
    if (days < 90)   return IdentityBadge.financialRookie;
    if (days < 180)  return IdentityBadge.gettingBy;
    if (days < 365)  return IdentityBadge.financiallyStable;
    if (days < 730)  return IdentityBadge.financialFortress;
    return           IdentityBadge.escapeVelocity;
  }
}
