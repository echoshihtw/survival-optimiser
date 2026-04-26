import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _rentCtrl   = TextEditingController();
  final _livingCtrl = TextEditingController();
  bool _editingBudget = false;

  static const _languages = [
    (label: 'ENGLISH',  locale: Locale('en')),
    (label: '繁中',      locale: Locale('zh', 'TW')),
    (label: 'FRANÇAIS', locale: Locale('fr')),
    (label: '日本語',    locale: Locale('ja')),
    (label: 'ESPAÑOL',  locale: Locale('es')),
    (label: 'ITALIANO', locale: Locale('it')),
  ];

  @override
  void dispose() {
    _rentCtrl.dispose();
    _livingCtrl.dispose();
    super.dispose();
  }

  void _startEditing(Budget budget) {
    _rentCtrl.text   = budget.rent   > 0
        ? budget.rent.toStringAsFixed(0)   : '';
    _livingCtrl.text = budget.living > 0
        ? budget.living.toStringAsFixed(0) : '';
    setState(() => _editingBudget = true);
  }

  Future<void> _saveBudget() async {
    final rent   = double.tryParse(_rentCtrl.text.trim())   ?? 0;
    final living = double.tryParse(_livingCtrl.text.trim()) ?? 0;
    await ref.read(budgetProvider.notifier).setRent(rent);
    await ref.read(budgetProvider.notifier).setLiving(living);
    setState(() => _editingBudget = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _clearBudget() async {
    await ref.read(budgetProvider.notifier).clear();
    _rentCtrl.clear();
    _livingCtrl.clear();
    setState(() => _editingBudget = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = context.l10n;
    final localeAsync = ref.watch(localeProvider);
    final currAsync   = ref.watch(currencyProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final subCost     = ref.watch(subscriptionMonthlyTotalProvider);
    final debtCost    = ref.watch(totalMonthlyLoanPaymentProvider);

    final currentLocale = localeAsync.value;
    final currentCurr   = currAsync.value;
    final budget        = budgetAsync.value ?? const Budget();
    final symbol        = currentCurr?.symbol ?? '¥';
    final nf            = NumberFormat('#,##0', 'en_US');

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.gradientBackground,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg,
                  AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.config,
                          style: AppTextStyles.title.copyWith(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('PREFERENCES & BUDGET',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: AppColors.cardBorder),
                      ),
                      child: Text('CLOSE',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary, letterSpacing: 1.0)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── MONTHLY BUDGET ────────────────
                    NeoCard(
                      title: 'MONTHLY BUDGET',
                      accentColor: AppColors.green,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          if (!_editingBudget) ...[
                            _budgetRow('RENT / FIXED',
                                budget.rent > 0
                                    ? '$symbol ${nf.format(budget.rent)}'
                                    : '—',
                                AppColors.textPrimary),
                            _budgetRow('LIVING EXPENSES',
                                budget.living > 0
                                    ? '$symbol ${nf.format(budget.living)}'
                                    : '—',
                                AppColors.textPrimary),
                            const Divider(
                                color: AppColors.cardBorder,
                                height: AppSpacing.lg),
                            _budgetRow('SUBTOTAL',
                                '$symbol ${nf.format(budget.subtotal)}',
                                AppColors.green),
                            _budgetRow('+ SUBSCR/MO',
                                '$symbol ${nf.format(subCost)}',
                                AppColors.purple),
                            _budgetRow('+ DEBT/MO',
                                '$symbol ${nf.format(debtCost)}',
                                AppColors.gold),
                            const Divider(
                                color: AppColors.cardBorder,
                                height: AppSpacing.lg),
                            _budgetRow(
                              'TOTAL BUDGET/MO',
                              '$symbol ${nf.format(budget.subtotal + subCost + debtCost)}',
                              AppColors.red,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                NeoButton(
                                  label: budget.isSet
                                      ? l10n.edit
                                      : 'SET BUDGET',
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: () =>
                                      _startEditing(budget),
                                ),
                              ],
                            ),
                          ] else ...[
                            NeoInput(
                              label: 'RENT / FIXED COSTS',
                              controller: _rentCtrl,
                              keyboardType: TextInputType.number,
                              hint: '45000',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            NeoInput(
                              label: 'LIVING EXPENSES',
                              controller: _livingCtrl,
                              keyboardType: TextInputType.number,
                              hint: '35000',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Subscriptions + debt added automatically',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(children: [
                              Expanded(
                                child: NeoButton(
                                  label: l10n.save,
                                  variant: NeoButtonVariant.primary,
                                  fullWidth: true,
                                  onPressed: _saveBudget,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: NeoButton(
                                  label: l10n.clear,
                                  variant: NeoButtonVariant.danger,
                                  fullWidth: true,
                                  onPressed: _clearBudget,
                                ),
                              ),
                            ]),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── LANGUAGE ──────────────────────
                    NeoCard(
                      title: l10n.language,
                      accentColor: AppColors.blue,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _languages.map((lang) {
                          final active =
                              currentLocale?.languageCode ==
                                  lang.locale.languageCode &&
                              (lang.locale.countryCode == null ||
                                  currentLocale?.countryCode ==
                                      lang.locale.countryCode);
                          return GestureDetector(
                            onTap: () => ref
                                .read(localeProvider.notifier)
                                .setLocale(lang.locale),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.green.withAlpha(20)
                                    : AppColors.surfaceHigh,
                                borderRadius:
                                    BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.green
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(lang.label,
                                  style: AppTextStyles.button
                                      .copyWith(
                                    color: active
                                        ? AppColors.green
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── CURRENCY ──────────────────────
                    NeoCard(
                      title: l10n.currency,
                      accentColor: AppColors.gold,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: supportedCurrencies.map((curr) {
                          final active =
                              currentCurr?.code == curr.code;
                          return GestureDetector(
                            onTap: () => ref
                                .read(currencyProvider.notifier)
                                .setCurrency(curr),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.gold.withAlpha(20)
                                    : AppColors.surfaceHigh,
                                borderRadius:
                                    BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.gold
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                '${curr.symbol}  ${curr.code}',
                                style: AppTextStyles.button
                                    .copyWith(
                                  color: active
                                      ? AppColors.gold
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value,
              style: AppTextStyles.metricSmall
                  .copyWith(color: color)),
        ],
      ),
    );
  }
}
