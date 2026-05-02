import 'package:application/application.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  final _fa = FirebaseAnalytics.instance;

  @override
  Future<void> logScreen(String name) =>
      _fa.logScreenView(screenName: name);

  @override
  Future<void> logAddTransaction(String type) =>
      _fa.logEvent(name: 'add_transaction', parameters: {'type': type});

  @override
  Future<void> logDeleteTransaction(String type) =>
      _fa.logEvent(name: 'delete_transaction', parameters: {'type': type});

  @override
  Future<void> logAddLoan(String source) =>
      _fa.logEvent(name: 'add_loan', parameters: {'source': source});

  @override
  Future<void> logRepayLoan() =>
      _fa.logEvent(name: 'repay_loan');

  @override
  Future<void> logAddSubscription(String cycle) =>
      _fa.logEvent(name: 'add_subscription', parameters: {'cycle': cycle});

  @override
  Future<void> logDeleteSubscription() =>
      _fa.logEvent(name: 'delete_subscription');

  @override
  Future<void> logSetBudget() =>
      _fa.logEvent(name: 'set_budget');

  @override
  Future<void> logRunSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) =>
      _fa.logEvent(name: 'run_simulation', parameters: {
        'has_burn_override': hasBurnOverride,
        'has_income': hasIncome,
      });

  @override
  Future<void> logShare(String badge) =>
      _fa.logEvent(name: 'share', parameters: {'badge': badge});

  @override
  Future<void> logChangeLanguage(String locale) =>
      _fa.logEvent(name: 'change_language', parameters: {'locale': locale});

  @override
  Future<void> logChangeCurrency(String code) =>
      _fa.logEvent(name: 'change_currency', parameters: {'currency': code});
}
