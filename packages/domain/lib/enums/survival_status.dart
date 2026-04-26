enum SurvivalStatus {
  stable,
  caution,
  critical;

  String get label => switch (this) {
    SurvivalStatus.stable => 'STABLE',
    SurvivalStatus.caution => 'CAUTION',
    SurvivalStatus.critical => 'CRITICAL',
  };
}
