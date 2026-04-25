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
    _rentCtrl.text   = budget.rent   > 0 ? budget.rent.toStringAsFixed(0)   : '';
    _livingCtrl.text = budget.living > 0 ? budget.living.toStringAsFixed(0) : '';
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
    final l10n          = context.l10n;
    final localeAsync   = ref.watch(localeProvider);
    final currAsync     = ref.watch(currencyProvider);
    final budgetAsync   = ref.watch(budgetProvider);
    final currentLocale = localeAsync.value;
    final currentCurr   = currAsync.value;
    final budget        = budgetAsync.value ?? const Budget();
    final symbol        = currentCurr?.symbol ?? '¥';
    final nf            = NumberFormat('#,##0', 'en_US');
    final subCost       = ref.watch(subscriptionMonthlyTotalProvider);
    final debtCost      = ref.watch(totalMonthlyLoanPaymentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineOverlay(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.config, style: AppTextStyles.title),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('[ X ]',
                          style: AppTextStyles.value
                              .copyWith(color: AppColors.danger)),
                    ),
                  ],
                ),
              ),
              const TerminalDivider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── MONTHLY BUDGET ──
                      TerminalPanel(
                        title: 'MONTHLY BUDGET',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_editingBudget) ...[
                              _budgetRow('RENT / FIXED',
                                  budget.rent > 0
                                      ? '$symbol ${nf.format(budget.rent)}'
                                      : '—',
                                  AppColors.primaryGreen),
                              _budgetRow('LIVING EXPENSES',
                                  budget.living > 0
                                      ? '$symbol ${nf.format(budget.living)}'
                                      : '—',
                                  AppColors.primaryGreen),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs),
                                child: Divider(
                                    color: AppColors.panelBorder, height: 1),
                              ),
                              _budgetRow('SUBTOTAL',
                                  '$symbol ${nf.format(budget.subtotal)}',
                                  AppColors.primaryGreen),
                              _budgetRow('+ SUBSCR/MO',
                                  '$symbol ${nf.format(subCost)}',
                                  AppColors.safe),
                              _budgetRow('+ DEBT/MO',
                                  '$symbol ${nf.format(debtCost)}',
                                  AppColors.gold),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs),
                                child: Divider(
                                    color: AppColors.panelBorder, height: 1),
                              ),
                              _budgetRow(
                                'TOTAL BUDGET/MO',
                                '$symbol ${nf.format(budget.subtotal + subCost + debtCost)}',
                                AppColors.danger,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TerminalButton(
                                label: budget.isSet ? l10n.edit : 'SET BUDGET',
                                fullWidth: true,
                                onPressed: () => _startEditing(budget),
                              ),
                            ] else ...[
                              TerminalInput(
                                label: 'RENT / FIXED COSTS',
                                controller: _rentCtrl,
                                keyboardType: TextInputType.number,
                                hint: '45000',
                                onChanged: (_) {},
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TerminalInput(
                                label: 'LIVING EXPENSES (FOOD, TRANSPORT, OTHER)',
                                controller: _livingCtrl,
                                keyboardType: TextInputType.number,
                                hint: '35000',
                                onChanged: (_) {},
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '> SUBSCRIPTIONS + DEBT ARE ADDED AUTOMATICALLY',
                                style: AppTextStyles.small,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(children: [
                                Expanded(
                                  child: TerminalButton(
                                    label: l10n.save,
                                    fullWidth: true,
                                    onPressed: _saveBudget,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: TerminalButton(
                                    label: l10n.clear,
                                    fullWidth: true,
                                    isDestructive: true,
                                    onPressed: _clearBudget,
                                  ),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── LANGUAGE ──
                      TerminalPanel(
                        title: l10n.language,
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
                                    vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: active
                                        ? AppColors.primaryGreen
                                        : AppColors.dimGreen,
                                  ),
                                  color: active
                                      ? AppColors.primaryGreen.withAlpha(20)
                                      : AppColors.background,
                                ),
                                child: Text(lang.label,
                                    style: AppTextStyles.value.copyWith(
                                      color: active
                                          ? AppColors.primaryGreen
                                          : AppColors.dimGreen,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── CURRENCY ──
                      TerminalPanel(
                        title: l10n.currency,
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: supportedCurrencies.map((curr) {
                            final active = currentCurr?.code == curr.code;
                            return GestureDetector(
                              onTap: () => ref
                                  .read(currencyProvider.notifier)
                                  .setCurrency(curr),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: active
                                        ? AppColors.safe
                                        : AppColors.dimGreen,
                                  ),
                                  color: active
                                      ? AppColors.safe.withAlpha(20)
                                      : AppColors.background,
                                ),
                                child: Text(
                                  '${curr.symbol}  ${curr.code}',
                                  style: AppTextStyles.value.copyWith(
                                    color: active
                                        ? AppColors.safe
                                        : AppColors.dimGreen,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _budgetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.value.copyWith(color: color)),
        ],
      ),
    );
  }
}
