import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  static const _languages = [
    (label: 'ENGLISH', locale: Locale('en')),
    (label: '繁中', locale: Locale('zh', 'TW')),
    (label: 'FRANÇAIS', locale: Locale('fr')),
    (label: '日本語', locale: Locale('ja')),
    (label: 'ESPAÑOL', locale: Locale('es')),
    (label: 'ITALIANO', locale: Locale('it')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeAsync = ref.watch(localeProvider);
    final currAsync = ref.watch(currencyProvider);
    final currentLocale = localeAsync.value;
    final currentCurr = currAsync.value;

    return TerminalPanel(
      title: l10n.config,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LANGUAGE ──
          Text(l10n.language, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _languages.map((lang) {
              final active =
                  currentLocale?.languageCode == lang.locale.languageCode &&
                  (lang.locale.countryCode == null ||
                      currentLocale?.countryCode == lang.locale.countryCode);
              return GestureDetector(
                onTap: () =>
                    ref.read(localeProvider.notifier).setLocale(lang.locale),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
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
                  child: Text(
                    lang.label,
                    style: AppTextStyles.small.copyWith(
                      color: active
                          ? AppColors.primaryGreen
                          : AppColors.dimGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const TerminalDivider(),

          // ── CURRENCY ──
          Text(l10n.currency, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: supportedCurrencies.map((curr) {
              final active = currentCurr?.code == curr.code;
              return GestureDetector(
                onTap: () =>
                    ref.read(currencyProvider.notifier).setCurrency(curr),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active ? AppColors.safe : AppColors.dimGreen,
                    ),
                    color: active
                        ? AppColors.safe.withAlpha(20)
                        : AppColors.background,
                  ),
                  child: Text(
                    '${curr.symbol} ${curr.code}',
                    style: AppTextStyles.small.copyWith(
                      color: active ? AppColors.safe : AppColors.dimGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
