import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:design_system/design_system.dart';
import 'package:presentation/router/app_router.dart';
import 'package:application/application.dart';
import 'package:data/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final txRepo = DriftTransactionRepository(db);
  final loanRepo = DriftLoanRepository(db);
  final subRepo = DriftSubscriptionRepository(db);

  runApp(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(txRepo),
        loanRepositoryProvider.overrideWithValue(loanRepo),
        subscriptionRepositoryProvider.overrideWithValue(subRepo),
      ],
      child: const SurvivalApp(),
    ),
  );
}

class SurvivalApp extends ConsumerWidget {
  const SurvivalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).value;

    return MaterialApp.router(
      title: 'SURVIVAL OPTIMIZER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (locale != null) return locale;
        if (deviceLocale == null) return const Locale('en');
        for (final supported in supportedLocales) {
          if (supported.languageCode == deviceLocale.languageCode) {
            return supported;
          }
        }
        return const Locale('en');
      },
    );
  }
}
