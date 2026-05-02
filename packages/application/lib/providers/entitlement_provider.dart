import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDailyTxKey    = 'daily_tx_count';
const _kDailyDateKey  = 'daily_tx_date';
const _kIsPro         = 'is_pro';
const _kFreeLimit     = 3; // transactions per day

class EntitlementNotifier extends AsyncNotifier<EntitlementState> {
  @override
  Future<EntitlementState> build() async {
    final prefs   = await SharedPreferences.getInstance();
    final isPro   = prefs.getBool(_kIsPro) ?? false;
    final today   = _today();
    final date    = prefs.getString(_kDailyDateKey) ?? '';
    final count   = date == today
        ? (prefs.getInt(_kDailyTxKey) ?? 0)
        : 0;

    return EntitlementState(
      isPro: isPro,
      dailyTxCount: count,
      dailyTxLimit: _kFreeLimit,
    );
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<bool> canAddTransaction() async {
    final s = state.value!;
    if (s.isPro) return true;
    return s.dailyTxCount < s.dailyTxLimit;
  }

  Future<void> recordTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final date  = prefs.getString(_kDailyDateKey) ?? '';
    final count = date == today
        ? (prefs.getInt(_kDailyTxKey) ?? 0)
        : 0;

    await prefs.setString(_kDailyDateKey, today);
    await prefs.setInt(_kDailyTxKey, count + 1);

    state = AsyncData(state.value!.copyWith(
      dailyTxCount: count + 1,
    ));
  }

  Future<void> unlockPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
    state = AsyncData(state.value!.copyWith(isPro: true));
  }
}

class EntitlementState {
  final bool isPro;
  final int dailyTxCount;
  final int dailyTxLimit;

  const EntitlementState({
    required this.isPro,
    required this.dailyTxCount,
    required this.dailyTxLimit,
  });

  int get dailyTxRemaining => isPro
      ? 999
      : (dailyTxLimit - dailyTxCount).clamp(0, dailyTxLimit);

  bool get canAddTransaction => isPro || dailyTxCount < dailyTxLimit;
  bool get hasHitDailyLimit => !isPro && dailyTxCount >= dailyTxLimit;

  EntitlementState copyWith({
    bool? isPro,
    int? dailyTxCount,
    int? dailyTxLimit,
  }) =>
      EntitlementState(
        isPro: isPro ?? this.isPro,
        dailyTxCount: dailyTxCount ?? this.dailyTxCount,
        dailyTxLimit: dailyTxLimit ?? this.dailyTxLimit,
      );
}

final entitlementProvider =
    AsyncNotifierProvider<EntitlementNotifier, EntitlementState>(
        EntitlementNotifier.new);
