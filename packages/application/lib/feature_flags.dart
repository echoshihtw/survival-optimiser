/// Feature flags — toggle features for launch readiness
abstract final class FeatureFlags {
  /// Investments section — shows total invested from transaction log
  static const investments = true;

  /// Share screen
  static const shareScreen = true;

  /// Scenario simulator
  static const scenarioSim = true;

  /// Local development override for paid features.
  ///
  /// Enable with:
  /// `--dart-define=DEV_PRO_ENTITLEMENT=true`
  static const devProEntitlement =
      !bool.fromEnvironment('dart.vm.product') &&
      bool.fromEnvironment('DEV_PRO_ENTITLEMENT');
}
