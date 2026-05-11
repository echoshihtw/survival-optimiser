import 'dart:io';

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
  final _rentCtrl = TextEditingController();
  final _livingCtrl = TextEditingController();
  bool _editingBudget = false;

  static const _languages = [
    (label: 'ENGLISH', locale: Locale('en')),
    (label: '中文', locale: Locale('zh', 'TW')),
    (label: 'FRANÇAIS', locale: Locale('fr')),
    (label: '日本語', locale: Locale('ja')),
    (label: 'ESPAÑOL', locale: Locale('es')),
    (label: 'ITALIANO', locale: Locale('it')),
  ];

  @override
  void dispose() {
    _rentCtrl.dispose();
    _livingCtrl.dispose();
    super.dispose();
  }

  void _startEditing(Budget budget) {
    _rentCtrl.text = budget.rent > 0 ? budget.rent.toStringAsFixed(0) : '';
    _livingCtrl.text = budget.living > 0
        ? budget.living.toStringAsFixed(0)
        : '';
    setState(() => _editingBudget = true);
  }

  Future<void> _saveBudget() async {
    final rent = double.tryParse(_rentCtrl.text.trim()) ?? 0;
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

  Future<void> _chooseBackupProvider() async {
    final provider = await showModalBottomSheet<BackupProvider>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose backup provider', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              if (Platform.isIOS)
                NeoButton(
                  label: 'iCloud Backup',
                  variant: NeoButtonVariant.primary,
                  fullWidth: true,
                  onPressed: () =>
                      Navigator.of(context).pop(BackupProvider.icloud),
                ),
              if (Platform.isIOS) const SizedBox(height: AppSpacing.sm),
              if (Platform.isAndroid)
                NeoButton(
                  label: 'Google Backup',
                  variant: NeoButtonVariant.primary,
                  fullWidth: true,
                  onPressed: () =>
                      Navigator.of(context).pop(BackupProvider.google),
                ),
              if (!Platform.isIOS && !Platform.isAndroid)
                Text(
                  'Cloud backup is available on iOS and Android.',
                  style: AppTextStyles.body,
                ),
              const SizedBox(height: AppSpacing.sm),
              NeoButton(
                label: 'Cancel',
                variant: NeoButtonVariant.ghost,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
    if (provider == null) return;
    await ref.read(backupProvider.notifier).enable(provider);
  }

  Future<void> _confirmRestore(BackupMetadata metadata) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Restore backup?', style: AppTextStyles.title),
        content: Text(
          'This will replace all current local data. Continue?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RESTORE DATA'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(backupProvider.notifier).restore(metadata);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backup restored. Restart Runway to reload the database.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeAsync = ref.watch(localeProvider);
    final currAsync = ref.watch(currencyProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final subCost = ref.watch(subscriptionMonthlyTotalProvider);
    final debtCost = ref.watch(totalMonthlyLoanPaymentProvider);
    final backupAsync = ref.watch(backupProvider);

    final currentLocale = localeAsync.value;
    final currentCurr = currAsync.value;
    final budget = budgetAsync.value ?? const Budget();
    final symbol = currentCurr?.symbol ?? '¥';
    final nf = NumberFormat('#,##0', 'en_US');

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.config,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.prefsBudget,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
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
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        l10n.close,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
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
                      title: l10n.monthlyBudget,
                      accentColor: AppColors.green,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_editingBudget) ...[
                            _budgetRow(
                              l10n.rentFixed,
                              budget.rent > 0
                                  ? '$symbol ${nf.format(budget.rent)}'
                                  : '—',
                              AppColors.textPrimary,
                            ),
                            _budgetRow(
                              l10n.livingExpenses,
                              budget.living > 0
                                  ? '$symbol ${nf.format(budget.living)}'
                                  : '—',
                              AppColors.textPrimary,
                            ),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: AppSpacing.lg,
                            ),
                            _budgetRow(
                              l10n.subtotal,
                              '$symbol ${nf.format(budget.subtotal)}',
                              AppColors.green,
                            ),
                            _budgetRow(
                              '+ ${l10n.subscrPerMonth}',
                              '$symbol ${nf.format(subCost)}',
                              AppColors.purple,
                            ),
                            _budgetRow(
                              '+ ${l10n.loanPerMonth}',
                              '$symbol ${nf.format(debtCost)}',
                              AppColors.gold,
                            ),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: AppSpacing.lg,
                            ),
                            _budgetRow(
                              l10n.totalBudgetPerMonth,
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
                                      : l10n.setBudget,
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: () => _startEditing(budget),
                                ),
                              ],
                            ),
                          ] else ...[
                            NeoInput(
                              label: l10n.rentFixedCosts,
                              controller: _rentCtrl,
                              keyboardType: TextInputType.number,
                              hint: '45000',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            NeoInput(
                              label: l10n.livingExpenses,
                              controller: _livingCtrl,
                              keyboardType: TextInputType.number,
                              hint: '35000',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.subscrDebtAuto,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
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
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),

                    _BackupCard(
                      state: backupAsync.value ?? const BackupState.initial(),
                      onEnable: _chooseBackupProvider,
                      onBackUpNow: () =>
                          ref.read(backupProvider.notifier).backUpNow(),
                      onRestore: _confirmRestore,
                      onDisable: () =>
                          ref.read(backupProvider.notifier).disable(),
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
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.green
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                lang.label,
                                style: AppTextStyles.button.copyWith(
                                  color: active
                                      ? AppColors.green
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
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
                          final active = currentCurr?.code == curr.code;
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
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: active
                                      ? AppColors.gold
                                      : AppColors.cardBorder,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                '${curr.symbol}  ${curr.code}',
                                style: AppTextStyles.button.copyWith(
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
                    const SizedBox(height: AppSpacing.cardGap),

                    // ── DISPLAY ───────────────────────
                    NeoCard(
                      title: l10n.display,
                      accentColor: AppColors.turkishBlue,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final glass =
                              ref.watch(displayProvider).value ?? false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.glassEffect,
                                    style: AppTextStyles.body,
                                  ),
                                  Text(
                                    l10n.glassEffectHint,
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () =>
                                    ref.read(displayProvider.notifier).toggle(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: glass
                                        ? AppColors.neonGreen
                                        : AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: glass
                                          ? AppColors.neonGreen
                                          : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: glass
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: glass
                                            ? AppColors.background
                                            : AppColors.textSecondary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.metricSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({
    required this.state,
    required this.onEnable,
    required this.onBackUpNow,
    required this.onRestore,
    required this.onDisable,
  });

  final BackupState state;
  final VoidCallback onEnable;
  final VoidCallback onBackUpNow;
  final ValueChanged<BackupMetadata> onRestore;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final metadata = state.lastBackup;
    final providerLabel = switch (state.provider) {
      BackupProvider.icloud => 'iCloud',
      BackupProvider.google => 'Google Drive',
      null => 'None',
    };
    return NeoCard(
      title: 'BACKUP',
      accentColor: AppColors.turkishBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Status', state.isEnabled ? 'ON' : 'OFF', AppColors.textPrimary),
          _row('Provider', providerLabel, AppColors.textPrimary),
          _row(
            'Last backup',
            metadata == null ? '—' : _relativeTime(metadata.updatedAt),
            AppColors.neonGreen,
          ),
          if (metadata != null)
            _row(
              'Size',
              _formatBytes(metadata.sizeBytes),
              AppColors.textSecondary,
            ),
          if (state.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.hotPink),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (!state.isEnabled)
            NeoButton(
              label: 'Enable Backup',
              variant: NeoButtonVariant.primary,
              fullWidth: true,
              onPressed: onEnable,
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: 'Back Up Now',
                    variant: NeoButtonVariant.primary,
                    fullWidth: true,
                    onPressed: onBackUpNow,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeoButton(
                    label: 'Restore',
                    variant: NeoButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: metadata == null
                        ? null
                        : () => onRestore(metadata),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            NeoButton(
              label: 'Disable Backup',
              variant: NeoButtonVariant.danger,
              fullWidth: true,
              onPressed: onDisable,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime time) {
    final delta = DateTime.now().toUtc().difference(time.toUtc());
    if (delta.inMinutes < 1) return 'just now';
    if (delta.inHours < 1) return '${delta.inMinutes} min ago';
    if (delta.inDays < 1) return '${delta.inHours} hr ago';
    return DateFormat('d MMM yyyy').format(time.toLocal());
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
