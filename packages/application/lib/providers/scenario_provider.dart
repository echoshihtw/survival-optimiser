import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scenario_state.dart';

class ScenarioNotifier extends Notifier<ScenarioState> {
  @override
  ScenarioState build() => const ScenarioState();

  void setBurnRateOverride(double? value) {
    state = ScenarioState(
      burnRateOverride: value,
      simulatedIncome: state.simulatedIncome,
      isActive: true, // always activate when user touches input
    );
  }

  void setSimulatedIncome(double? value) {
    state = ScenarioState(
      burnRateOverride: state.burnRateOverride,
      simulatedIncome: value,
      isActive: true, // always activate when user touches input
    );
  }

  void reset() => state = const ScenarioState();
}

final scenarioProvider = NotifierProvider<ScenarioNotifier, ScenarioState>(
  ScenarioNotifier.new,
);
