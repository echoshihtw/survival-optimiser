import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:application/application.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  static const _languages = [
    (label: 'ENGLISH',  locale: Locale('en')),
    (label: '繁中',      locale: Locale('zh', 'TW')),
    (label: 'FRANÇAIS', locale: Locale('fr')),
    (label: '日本語',    locale: Locale('ja')),
    (label: 'ESPAÑOL',  locale: Locale('es')),
    (label: 'ITALIANO', locale: Locale('it')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n          = context.l10n;
    final localeAsync   = ref.watch(localeProvider);
    final currAsync     = ref.watch(currencyProvider);
    final currentLocale = localeAsync.value;
    final currentCurr   = currAsync.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineOverlay(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.config, style: AppTextStyles.title),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('[ X ]',
                          style: AppTextStyles.value.copyWith(
                              color: AppColors.danger)),
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
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: active
                                        ? AppColors.primaryGreen
                                        : AppColors.dimGreen,
                                  ),
                                  color: active
                                      ? AppColors.primaryGreen
                                          .withAlpha(20)
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
                                  vertical: AppSpacing.sm,
                                ),
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
}
