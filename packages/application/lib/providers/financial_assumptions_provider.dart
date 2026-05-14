import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _expectedInflowKey = 'assumptions_expected_monthly_inflow';
const _expectedBurnKey = 'assumptions_expected_monthly_burn';

final financialAssumptionsProvider =
    AsyncNotifierProvider<FinancialAssumptionsNotifier, FinancialAssumptions>(
      FinancialAssumptionsNotifier.new,
    );

class FinancialAssumptionsNotifier extends AsyncNotifier<FinancialAssumptions> {
  @override
  Future<FinancialAssumptions> build() async {
    final prefs = await SharedPreferences.getInstance();
    return FinancialAssumptions(
      expectedMonthlyInflow: prefs.getDouble(_expectedInflowKey),
      expectedMonthlyBurnOverride: prefs.getDouble(_expectedBurnKey),
    );
  }

  Future<void> save({
    double? expectedMonthlyInflow,
    double? expectedMonthlyBurnOverride,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeOptionalDouble(
      prefs,
      _expectedInflowKey,
      expectedMonthlyInflow,
    );
    await _writeOptionalDouble(
      prefs,
      _expectedBurnKey,
      expectedMonthlyBurnOverride,
    );
    state = AsyncData(
      FinancialAssumptions(
        expectedMonthlyInflow: expectedMonthlyInflow,
        expectedMonthlyBurnOverride: expectedMonthlyBurnOverride,
      ),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expectedInflowKey);
    await prefs.remove(_expectedBurnKey);
    state = const AsyncData(FinancialAssumptions());
  }

  Future<void> _writeOptionalDouble(
    SharedPreferences prefs,
    String key,
    double? value,
  ) async {
    if (value == null || value <= 0) {
      await prefs.remove(key);
    } else {
      await prefs.setDouble(key, value);
    }
  }
}
