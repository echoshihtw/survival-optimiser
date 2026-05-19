/// Feature flags — toggle features for launch readiness
abstract final class FeatureFlags {
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
