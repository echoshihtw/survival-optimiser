import 'package:domain/domain.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rentKey   = 'budget_rent';
const _livingKey = 'budget_living';

class BudgetNotifier extends AsyncNotifier<Budget> {
  @override
  Future<Budget> build() async {
    final prefs = await SharedPreferences.getInstance();
    return Budget(
      rent:   prefs.getDouble(_rentKey)   ?? 0,
      living: prefs.getDouble(_livingKey) ?? 0,
    );
  }

  Future<void> setRent(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rentKey, value);
    state = AsyncData(state.value!.copyWith(rent: value));
  }

  Future<void> setLiving(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_livingKey, value);
    state = AsyncData(state.value!.copyWith(living: value));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rentKey);
    await prefs.remove(_livingKey);
    state = const AsyncData(Budget());
  }
}

final budgetProvider =
    AsyncNotifierProvider<BudgetNotifier, Budget>(BudgetNotifier.new);
