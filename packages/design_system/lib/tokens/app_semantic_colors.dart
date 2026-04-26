import 'app_colors.dart';
import 'package:flutter/material.dart';

/// Semantic color system — use these instead of raw AppColors
/// Change meaning here, propagates everywhere automatically
abstract final class SC {
  // ── Numbers & amounts ─────────────────────────
  static const numberPrimary  = AppColors.textPrimary;  // neutral facts
  static const numberPositive = AppColors.green;         // inflow, good
  static const numberNegative = AppColors.red;           // outflow, burn
  static const numberWarning  = AppColors.gold;          // debt, caution
  static const numberInfo     = AppColors.blue;          // investable, neutral
  static const numberSpecial  = AppColors.purple;        // subscriptions

  // ── Status ────────────────────────────────────
  static const statusStable   = AppColors.green;
  static const statusCaution  = AppColors.gold;
  static const statusCritical = AppColors.red;

  // ── Section accents (card left bar) ──────────
  static const accentMetrics      = AppColors.blue;
  static const accentInvestable   = AppColors.blue;
  static const accentLiabilities  = AppColors.gold;
  static const accentSubscription = AppColors.purple;
  static const accentTimeline     = AppColors.blue;
  static const accentConfig       = AppColors.green;
  static const accentSimulator    = AppColors.purple;

  // ── Transaction types ─────────────────────────
  static const txExpense        = AppColors.red;
  static const txIncome         = AppColors.green;
  static const txLoan           = AppColors.blue;
  static const txInvestment     = AppColors.purple;
  static const txRepayment      = AppColors.gold;
  static const txOpeningBalance = AppColors.blue;

  // ── Buttons ───────────────────────────────────
  static const btnPrimary     = AppColors.green;
  static const btnLoan        = AppColors.gold;
  static const btnDestructive = AppColors.red;

  // ── Specific metrics ──────────────────────────
  static const metricCash        = numberPrimary;   // cash is neutral fact
  static const metricRunway      = numberPrimary;   // overridden by status
  static const metricBurnRate    = numberNegative;  // always outflow
  static const metricBudget      = numberNegative;  // always outflow
  static const metricDebt        = numberWarning;   // fixed obligation
  static const metricSubscr      = numberSpecial;   // unique category
  static const metricTotal       = numberNegative;  // always outflow
  static const metricInvestable  = numberInfo;      // deployable capital
  static const metricSafetyFund  = numberWarning;   // reserved/locked
  static const metricRunOut      = AppColors.textSecondary; // date fact

  // ── UI elements ───────────────────────────────
  static const labelColor    = AppColors.textSecondary;
  static const captionColor  = AppColors.textDim;
  static const dividerColor  = AppColors.cardBorder;
  static const surfaceColor  = AppColors.surface;
  static const cardColor     = AppColors.surface;
}
