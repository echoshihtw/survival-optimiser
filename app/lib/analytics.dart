import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics — tracks behavior only, never financial content
/// Rule: log WHAT users do, never HOW MUCH or their financial data
class Analytics {
  static final _fa = FirebaseAnalytics.instance;

  // ── App lifecycle ─────────────────────────────
  static Future<void> appOpened() =>
      _fa.logAppOpen();

  // ── Screen views ──────────────────────────────
  static Future<void> screenHUD() =>
      _fa.logScreenView(screenName: 'hud');
  static Future<void> screenLog() =>
      _fa.logScreenView(screenName: 'transaction_log');
  static Future<void> screenSim() =>
      _fa.logScreenView(screenName: 'simulator');
  static Future<void> screenConfig() =>
      _fa.logScreenView(screenName: 'config');
  static Future<void> screenShare() =>
      _fa.logScreenView(screenName: 'share');

  // ── Transaction events ────────────────────────
  // ✅ tracks type only — never amount
  static Future<void> addTransaction(String type) =>
      _fa.logEvent(name: 'add_transaction', parameters: {
        'type': type, // 'expense', 'income', 'loan', etc
      });

  static Future<void> deleteTransaction(String type) =>
      _fa.logEvent(name: 'delete_transaction', parameters: {
        'type': type,
      });

  // ── Loan events ───────────────────────────────
  // ✅ tracks source only — never amount
  static Future<void> addLoan(String source) =>
      _fa.logEvent(name: 'add_loan', parameters: {
        'source': source, // 'BANK', 'FRIEND', etc
      });

  static Future<void> repayLoan() =>
      _fa.logEvent(name: 'repay_loan');

  // ── Subscription events ───────────────────────
  // ✅ tracks cycle only — never amount
  static Future<void> addSubscription(String cycle) =>
      _fa.logEvent(name: 'add_subscription', parameters: {
        'cycle': cycle, // 'monthly', 'yearly', etc
      });

  static Future<void> deleteSubscription() =>
      _fa.logEvent(name: 'delete_subscription');

  // ── Budget events ─────────────────────────────
  // ✅ tracks that budget was set — never amounts
  static Future<void> setBudget() =>
      _fa.logEvent(name: 'set_budget');

  static Future<void> clearBudget() =>
      _fa.logEvent(name: 'clear_budget');

  // ── Simulator events ──────────────────────────
  static Future<void> runSimulation({
    bool hasBurnOverride = false,
    bool hasIncome = false,
  }) =>
      _fa.logEvent(name: 'run_simulation', parameters: {
        'has_burn_override': hasBurnOverride,
        'has_income': hasIncome,
      });

  static Future<void> resetSimulation() =>
      _fa.logEvent(name: 'reset_simulation');

  // ── Share events ──────────────────────────────
  // ✅ tracks badge identity — not financial amount
  static Future<void> shareImage(String badge) =>
      _fa.logEvent(name: 'share_image', parameters: {
        'badge': badge, // 'Escape Velocity', 'Financial Rookie'
      });

  static Future<void> shareText(String badge) =>
      _fa.logEvent(name: 'share_text', parameters: {
        'badge': badge,
      });

  // ── Config events ─────────────────────────────
  static Future<void> changeLanguage(String locale) =>
      _fa.logEvent(name: 'change_language', parameters: {
        'locale': locale,
      });

  static Future<void> changeCurrency(String code) =>
      _fa.logEvent(name: 'change_currency', parameters: {
        'currency': code,
      });

  static Future<void> toggleGlassEffect(bool enabled) =>
      _fa.logEvent(name: 'toggle_glass_effect', parameters: {
        'enabled': enabled,
      });

  // ── Onboarding events ─────────────────────────
  static Future<void> onboardingStarted() =>
      _fa.logEvent(name: 'onboarding_started');

  static Future<void> onboardingCompleted() =>
      _fa.logEvent(name: 'onboarding_completed');

  static Future<void> onboardingSkipped(int step) =>
      _fa.logEvent(name: 'onboarding_skipped', parameters: {
        'at_step': step,
      });

  // ── Paywall events ────────────────────────────
  static Future<void> paywallShown(String trigger) =>
      _fa.logEvent(name: 'paywall_shown', parameters: {
        'trigger': trigger, // 'loan_limit', 'subscription', etc
      });

  static Future<void> paywallConverted() =>
      _fa.logEvent(name: 'paywall_converted');

  static Future<void> paywallDismissed() =>
      _fa.logEvent(name: 'paywall_dismissed');
}
