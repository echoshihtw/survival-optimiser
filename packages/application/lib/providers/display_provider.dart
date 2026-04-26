import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _glassKey = 'display_glass_effect';

class DisplayNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_glassKey) ?? false; // off by default
  }

  Future<void> toggle() async {
    final current = state.value ?? false;
    final prefs   = await SharedPreferences.getInstance();
    await prefs.setBool(_glassKey, !current);
    state = AsyncData(!current);
  }
}

final displayProvider =
    AsyncNotifierProvider<DisplayNotifier, bool>(DisplayNotifier.new);
