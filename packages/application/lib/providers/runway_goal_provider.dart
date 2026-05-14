import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kRunwayGoal = 'runway_goal';

final runwayGoalProvider =
    AsyncNotifierProvider<RunwayGoalNotifier, RunwayGoal?>(
      RunwayGoalNotifier.new,
    );

class RunwayGoalNotifier extends AsyncNotifier<RunwayGoal?> {
  @override
  Future<RunwayGoal?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRunwayGoal);
    if (raw == null) return null;
    return RunwayGoal.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveGoal({
    required String name,
    required int targetMonths,
    DateTime? targetDate,
  }) async {
    if (targetMonths <= 0) return;
    final existing = state.value;
    final goal = RunwayGoal(
      id: existing?.id ?? const Uuid().v4(),
      name: name.trim().isEmpty ? 'Runway goal' : name.trim(),
      targetMonths: targetMonths,
      targetDate: targetDate,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRunwayGoal, jsonEncode(goal.toJson()));
    state = AsyncData(goal);
  }

  Future<void> clearGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRunwayGoal);
    state = const AsyncData(null);
  }
}
