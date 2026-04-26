import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SURVIVAL OPTIMIZER'**
  String get appTitle;

  /// No description provided for @hudTitle.
  ///
  /// In en, this message translates to:
  /// **'SURVIVAL.EXE'**
  String get hudTitle;

  /// No description provided for @sysOnline.
  ///
  /// In en, this message translates to:
  /// **'SYS: ONLINE'**
  String get sysOnline;

  /// No description provided for @lifeForce.
  ///
  /// In en, this message translates to:
  /// **'LIFE FORCE'**
  String get lifeForce;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In en, this message translates to:
  /// **'PRESSURE'**
  String get pressureLabel;

  /// No description provided for @metrics.
  ///
  /// In en, this message translates to:
  /// **'METRICS'**
  String get metrics;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'CASH'**
  String get cash;

  /// No description provided for @burnPerMonth.
  ///
  /// In en, this message translates to:
  /// **'BURN/MO'**
  String get burnPerMonth;

  /// No description provided for @loanPerMonth.
  ///
  /// In en, this message translates to:
  /// **'DEBT/MO'**
  String get loanPerMonth;

  /// No description provided for @runway.
  ///
  /// In en, this message translates to:
  /// **'RUNWAY'**
  String get runway;

  /// No description provided for @runOut.
  ///
  /// In en, this message translates to:
  /// **'RUN OUT'**
  String get runOut;

  /// No description provided for @investable.
  ///
  /// In en, this message translates to:
  /// **'INVESTABLE'**
  String get investable;

  /// No description provided for @cashTimeline.
  ///
  /// In en, this message translates to:
  /// **'CASH TIMELINE'**
  String get cashTimeline;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'CONFIG'**
  String get config;

  /// No description provided for @monthlyLoanPayment.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY LOAN PAYMENT'**
  String get monthlyLoanPayment;

  /// No description provided for @tapToSet.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SET'**
  String get tapToSet;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clear;

  /// No description provided for @loanAffectsInfo.
  ///
  /// In en, this message translates to:
  /// **'> LOAN/MO AFFECTS PRESSURE RATIO AND INVESTABLE CASH'**
  String get loanAffectsInfo;

  /// No description provided for @transactionLog.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION LOG'**
  String get transactionLog;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'+ NEW'**
  String get newEntry;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'> NO ENTRIES FOUND\n> TAP [+ NEW] TO BEGIN'**
  String get noEntries;

  /// No description provided for @newLogEntry.
  ///
  /// In en, this message translates to:
  /// **'> NEW LOG ENTRY'**
  String get newLogEntry;

  /// No description provided for @modifyEntry.
  ///
  /// In en, this message translates to:
  /// **'> MODIFY ENTRY'**
  String get modifyEntry;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get type;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @calcMonth.
  ///
  /// In en, this message translates to:
  /// **'CALC'**
  String get calcMonth;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'NOTE (OPTIONAL)'**
  String get noteOptional;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @abort.
  ///
  /// In en, this message translates to:
  /// **'ABORT'**
  String get abort;

  /// No description provided for @purgeEntry.
  ///
  /// In en, this message translates to:
  /// **'> PURGE ENTRY?'**
  String get purgeEntry;

  /// No description provided for @scenarioSimulator.
  ///
  /// In en, this message translates to:
  /// **'SCENARIO SIMULATOR'**
  String get scenarioSimulator;

  /// No description provided for @overrideInputs.
  ///
  /// In en, this message translates to:
  /// **'OVERRIDE INPUTS'**
  String get overrideInputs;

  /// No description provided for @burnRateOverride.
  ///
  /// In en, this message translates to:
  /// **'BURN RATE OVERRIDE'**
  String get burnRateOverride;

  /// No description provided for @simulatedIncome.
  ///
  /// In en, this message translates to:
  /// **'SIMULATED INCOME/MO'**
  String get simulatedIncome;

  /// No description provided for @simResults.
  ///
  /// In en, this message translates to:
  /// **'SIM RESULTS'**
  String get simResults;

  /// No description provided for @simRunway.
  ///
  /// In en, this message translates to:
  /// **'SIM RUNWAY'**
  String get simRunway;

  /// No description provided for @simRunOut.
  ///
  /// In en, this message translates to:
  /// **'SIM RUN OUT'**
  String get simRunOut;

  /// No description provided for @simInvestable.
  ///
  /// In en, this message translates to:
  /// **'SIM INVESTABLE'**
  String get simInvestable;

  /// No description provided for @deltaVsActual.
  ///
  /// In en, this message translates to:
  /// **'DELTA vs ACTUAL'**
  String get deltaVsActual;

  /// No description provided for @deltaRunway.
  ///
  /// In en, this message translates to:
  /// **'DELTA RUNWAY'**
  String get deltaRunway;

  /// No description provided for @deltaInvestable.
  ///
  /// In en, this message translates to:
  /// **'DELTA INVESTABLE'**
  String get deltaInvestable;

  /// No description provided for @resetSim.
  ///
  /// In en, this message translates to:
  /// **'RESET SIM'**
  String get resetSim;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'MONTHS'**
  String get months;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get stable;

  /// No description provided for @caution.
  ///
  /// In en, this message translates to:
  /// **'CAUTION'**
  String get caution;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get critical;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get moderate;

  /// No description provided for @highLoad.
  ///
  /// In en, this message translates to:
  /// **'HIGH LOAD'**
  String get highLoad;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @addNoData.
  ///
  /// In en, this message translates to:
  /// **'> ADD TRANSACTIONS TO SEE TIMELINE'**
  String get addNoData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'LOADING...'**
  String get loading;

  /// No description provided for @navHud.
  ///
  /// In en, this message translates to:
  /// **'HUD'**
  String get navHud;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get navLog;

  /// No description provided for @navSim.
  ///
  /// In en, this message translates to:
  /// **'SIM'**
  String get navSim;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get typeExpense;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get typeIncome;

  /// No description provided for @typeLoan.
  ///
  /// In en, this message translates to:
  /// **'LOAN'**
  String get typeLoan;

  /// No description provided for @typeInvest.
  ///
  /// In en, this message translates to:
  /// **'INVEST'**
  String get typeInvest;

  /// No description provided for @typeRepay.
  ///
  /// In en, this message translates to:
  /// **'REPAY'**
  String get typeRepay;

  /// No description provided for @typeOpening.
  ///
  /// In en, this message translates to:
  /// **'OPENING'**
  String get typeOpening;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'LIABILITIES'**
  String get liabilities;

  /// No description provided for @noActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'> NO ACTIVE LOANS'**
  String get noActiveLoans;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get settled;

  /// No description provided for @totalDebtPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DEBT/MO'**
  String get totalDebtPerMonth;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @installment.
  ///
  /// In en, this message translates to:
  /// **'INSTALLMENT'**
  String get installment;

  /// No description provided for @paidThisMo.
  ///
  /// In en, this message translates to:
  /// **'PAID THIS MO'**
  String get paidThisMo;

  /// No description provided for @monthsLeft.
  ///
  /// In en, this message translates to:
  /// **'MONTHS LEFT'**
  String get monthsLeft;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'% REPAID'**
  String get repaid;

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'REPAY'**
  String get repay;

  /// No description provided for @repayTitle.
  ///
  /// In en, this message translates to:
  /// **'> REPAY'**
  String get repayTitle;

  /// No description provided for @extra.
  ///
  /// In en, this message translates to:
  /// **'EXTRA'**
  String get extra;

  /// No description provided for @configButton.
  ///
  /// In en, this message translates to:
  /// **'CFG'**
  String get configButton;

  /// No description provided for @loanWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'LOAN WIZARD'**
  String get loanWizardTitle;

  /// No description provided for @whoAndHowMuch.
  ///
  /// In en, this message translates to:
  /// **'WHO & HOW MUCH'**
  String get whoAndHowMuch;

  /// No description provided for @loanTerms.
  ///
  /// In en, this message translates to:
  /// **'LOAN TERMS'**
  String get loanTerms;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PAYMENT'**
  String get confirmPayment;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'SOURCE'**
  String get source;

  /// No description provided for @nameLender.
  ///
  /// In en, this message translates to:
  /// **'NAME / LENDER'**
  String get nameLender;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'LOAN AMOUNT'**
  String get loanAmount;

  /// No description provided for @annualRate.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL INTEREST RATE % (0 = NO INTEREST)'**
  String get annualRate;

  /// No description provided for @repaymentMonths.
  ///
  /// In en, this message translates to:
  /// **'REPAYMENT MONTHS'**
  String get repaymentMonths;

  /// No description provided for @computedInstallment.
  ///
  /// In en, this message translates to:
  /// **'COMPUTED INSTALLMENT'**
  String get computedInstallment;

  /// No description provided for @overrideInstallment.
  ///
  /// In en, this message translates to:
  /// **'OVERRIDE MONTHLY INSTALLMENT'**
  String get overrideInstallment;

  /// No description provided for @monthlyInstallment.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY INSTALLMENT'**
  String get monthlyInstallment;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get back;

  /// No description provided for @lender.
  ///
  /// In en, this message translates to:
  /// **'LENDER'**
  String get lender;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rate;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTIONS'**
  String get subscriptions;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'> NO ACTIVE SUBSCRIPTIONS'**
  String get noSubscriptions;

  /// No description provided for @subscriptionName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get subscriptionName;

  /// No description provided for @subscriptionAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get subscriptionAmount;

  /// No description provided for @subscriptionCycle.
  ///
  /// In en, this message translates to:
  /// **'BILLING CYCLE'**
  String get subscriptionCycle;

  /// No description provided for @subscriptionCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get subscriptionCategory;

  /// No description provided for @subscriptionNextBilling.
  ///
  /// In en, this message translates to:
  /// **'NEXT BILLING'**
  String get subscriptionNextBilling;

  /// No description provided for @subscriptionDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get subscriptionDaysLeft;

  /// No description provided for @totalPerMonth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL/MO'**
  String get totalPerMonth;

  /// No description provided for @totalPerYear.
  ///
  /// In en, this message translates to:
  /// **'TOTAL/YR'**
  String get totalPerYear;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'+ SUBSCRIPTION'**
  String get newSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'> EDIT SUBSCRIPTION'**
  String get editSubscription;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'> NEW SUBSCRIPTION'**
  String get addSubscription;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS'**
  String get business;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'QUARTERLY'**
  String get quarterly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY'**
  String get yearly;

  /// No description provided for @subscrPerMonth.
  ///
  /// In en, this message translates to:
  /// **'SUBSCR/MO'**
  String get subscrPerMonth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
