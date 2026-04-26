import 'app_colors.dart';

/// Semantic color system
/// Mint #B2FFCA = primary (life, growth, positive)
/// Pink #FFB2D0 = secondary (danger, burn, alerts)
/// Turkish Blue #007FAE = supporting (info, neutral)
abstract final class SC {
  // ── Primary = Mint ────────────────────────────
  static const primary = AppColors.neonGreen; // #B2FFCA
  static const secondary = AppColors.hotPink; // #FFB2D0
  static const info = AppColors.turkishBlue; // #007FAE

  // ── Numbers ───────────────────────────────────
  static const numberPrimary = AppColors.textPrimary;
  static const numberPositive = AppColors.neonGreen; // mint — inflow
  static const numberNegative = AppColors.hotPink; // pink — outflow
  static const numberWarning = AppColors.gold;
  static const numberInfo = AppColors.turkishBlue;
  static const numberSpecial = AppColors.purple;

  // ── Status ────────────────────────────────────
  static const statusStable = AppColors.neonGreen; // mint
  static const statusCaution = AppColors.gold;
  static const statusCritical = AppColors.hotPink; // pink

  // ── Section accents ───────────────────────────
  static const accentMetrics = AppColors.neonGreen; // mint — your survival
  static const accentInvestable = AppColors.turkishBlue; // blue — your future
  static const accentLiabilities = AppColors.hotPink; // pink — your costs
  static const accentSubscription = AppColors.hotPink; // pink — your costs
  static const accentTimeline = AppColors.turkishBlue; // blue — your future
  static const accentConfig = AppColors.neonGreen; // mint — your survival
  static const accentSimulator = AppColors.turkishBlue; // blue — your future

  // ── Transaction icons ─────────────────────────
  static const txExpense = AppColors.hotPink;
  static const txIncome = AppColors.neonGreen;
  static const txLoan = AppColors.turkishBlue;
  static const txInvestment = AppColors.purple;
  static const txRepayment = AppColors.gold;
  static const txOpeningBalance = AppColors.turkishBlue;

  // ── Buttons ───────────────────────────────────
  static const btnPrimary = AppColors.neonGreen; // mint
  static const btnSecondary = AppColors.hotPink; // pink
  static const btnLoan = AppColors.gold;
  static const btnDestructive = AppColors.hotPink;

  // ── Specific metrics ──────────────────────────
  static const metricCash = AppColors.neonGreen; // mint — it\'s good
  static const metricRunway = numberPrimary; // overridden by status
  static const metricBurnRate = AppColors.hotPink; // pink — outflow
  static const metricBudget = AppColors.hotPink; // pink — outflow
  static const metricDebt = AppColors.gold;
  static const metricSubscr = AppColors.purple;
  static const metricTotal = AppColors.hotPink; // pink — total burn
  static const metricInvestable = AppColors.neonGreen; // mint — deployable
  static const metricSafetyFund = AppColors.turkishBlue;
  static const metricRunOut = AppColors.textSecondary;

  // ── UI ────────────────────────────────────────
  static const labelColor = AppColors.textSecondary;
  static const captionColor = AppColors.textDim;
  static const dividerColor = AppColors.cardBorder;
}
