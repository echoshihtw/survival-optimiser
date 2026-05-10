// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Runway';

  @override
  String get hudTitle => 'Runway';

  @override
  String get sysOnline => 'システム：オンライン';

  @override
  String get lifeForce => '生命力';

  @override
  String get statusLabel => 'ステータス';

  @override
  String get pressureLabel => 'プレッシャー';

  @override
  String get metrics => 'メトリクス';

  @override
  String get cash => '現金';

  @override
  String get burnPerMonth => '月間支出';

  @override
  String get loanPerMonth => '月間債務';

  @override
  String get runway => '生存期間';

  @override
  String get runOut => '枯渇日';

  @override
  String get investable => '投資可能';

  @override
  String get cashTimeline => '現金タイムライン';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '月間ローン返済';

  @override
  String get tapToSet => 'タップして設定';

  @override
  String get edit => '編集';

  @override
  String get save => '保存';

  @override
  String get clear => 'クリア';

  @override
  String get loanAffectsInfo => '> 月間返済はプレッシャー比率と投資可能額に影響します';

  @override
  String get transactionLog => '取引ログ';

  @override
  String get newEntry => '+ 新規';

  @override
  String get noEntries => 'No entries yet\nTap + ADD to log your first entry';

  @override
  String get newLogEntry => '> 新規エントリー';

  @override
  String get modifyEntry => '> エントリー修正';

  @override
  String get type => 'タイプ';

  @override
  String get date => '日付';

  @override
  String get calcMonth => '計算月';

  @override
  String get amount => '金額';

  @override
  String get noteOptional => 'メモ（任意）';

  @override
  String get confirm => '確認';

  @override
  String get abort => '中止';

  @override
  String get purgeEntry => '> このエントリーを削除？';

  @override
  String get scenarioSimulator => 'シナリオシミュレーター';

  @override
  String get overrideInputs => 'オーバーライド入力';

  @override
  String get burnRateOverride => '支出オーバーライド';

  @override
  String get simulatedIncome => 'シミュレート収入/月';

  @override
  String get simResults => 'シム結果';

  @override
  String get simRunway => 'シム生存期間';

  @override
  String get simRunOut => 'シム枯渇日';

  @override
  String get simInvestable => 'シム投資可能';

  @override
  String get deltaVsActual => '実際との差分';

  @override
  String get deltaRunway => '生存期間差分';

  @override
  String get deltaInvestable => '投資可能差分';

  @override
  String get resetSim => 'シムリセット';

  @override
  String get months => 'ヶ月';

  @override
  String get stable => '安定';

  @override
  String get caution => '注意';

  @override
  String get critical => '危機';

  @override
  String get low => '低';

  @override
  String get moderate => '中程度';

  @override
  String get highLoad => '高負荷';

  @override
  String get language => '言語';

  @override
  String get currency => '通貨';

  @override
  String get addNoData => '> 取引を追加してタイムラインを表示';

  @override
  String get loading => '読み込み中...';

  @override
  String get navHud => 'HUD';

  @override
  String get navLog => 'ログ';

  @override
  String get navSim => 'シム';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '収入';

  @override
  String get typeLoan => 'ローン';

  @override
  String get typeInvest => '投資';

  @override
  String get typeRepay => '返済';

  @override
  String get typeOpening => '開始残高';

  @override
  String get liabilities => '負債';

  @override
  String get noActiveLoans => '> アクティブなローンなし';

  @override
  String get settled => '完済';

  @override
  String get totalDebtPerMonth => '月間債務合計';

  @override
  String get remaining => '残高';

  @override
  String get installment => '月払い';

  @override
  String get paidThisMo => '今月支払い済み';

  @override
  String get monthsLeft => '残り月数';

  @override
  String get repaid => '% 返済済み';

  @override
  String get repay => '返済';

  @override
  String get repayTitle => '> 返済';

  @override
  String get extra => '追加';

  @override
  String get configButton => '設定';

  @override
  String get loanWizardTitle => 'ローンウィザード';

  @override
  String get whoAndHowMuch => '相手と金額';

  @override
  String get loanTerms => 'ローン条件';

  @override
  String get confirmPayment => '支払い確認';

  @override
  String get source => '種別';

  @override
  String get nameLender => '名前 / 貸し手';

  @override
  String get loanAmount => '借入金額';

  @override
  String get annualRate => '年利率 % (0 = 無利息)';

  @override
  String get repaymentMonths => '返済月数';

  @override
  String get computedInstallment => '計算された月払い';

  @override
  String get overrideInstallment => '月払いを上書き';

  @override
  String get monthlyInstallment => '月払い';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get lender => '貸し手';

  @override
  String get rate => '利率';

  @override
  String get change => '変更';

  @override
  String get subscriptions => 'サブスクリプション';

  @override
  String get noSubscriptions => '> アクティブなサブスクなし';

  @override
  String get subscriptionName => '名前';

  @override
  String get subscriptionAmount => '金額';

  @override
  String get subscriptionCycle => '請求サイクル';

  @override
  String get subscriptionCategory => 'カテゴリ';

  @override
  String get subscriptionNextBilling => '次回請求日';

  @override
  String get subscriptionDaysLeft => '日';

  @override
  String get totalPerMonth => '月合計';

  @override
  String get totalPerYear => '年合計';

  @override
  String get newSubscription => '+ サブスク';

  @override
  String get editSubscription => '> サブスク編集';

  @override
  String get addSubscription => '> 新規サブスク';

  @override
  String get personal => '個人';

  @override
  String get business => 'ビジネス';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get quarterly => '四半期';

  @override
  String get yearly => '毎年';

  @override
  String get subscrPerMonth => 'サブスク/月';

  @override
  String get loans => 'ローン';

  @override
  String activeCount(int count) {
    return '$count 件有効';
  }

  @override
  String get repayLoan => 'ローン返済';

  @override
  String get repaymentAmount => '返済金額';

  @override
  String get cancel => 'キャンセル';

  @override
  String get paid => '✓ 完済';

  @override
  String get subscrPerYear => 'サブスク/年';

  @override
  String get removeConfirm => '削除？';

  @override
  String get remove => '削除';

  @override
  String monthsProjected(int count) {
    return '$countヶ月予測';
  }

  @override
  String get budgetPerMonth => '予算/月';

  @override
  String get breakdown => '明細';

  @override
  String get safetyFund => '安全資金';

  @override
  String get safety => '安全';

  @override
  String get deployableCapital => '運用可能資金 — 生存バッファとは別';

  @override
  String get survivalCharge => 'サバイバルチャージ';

  @override
  String get historyEntries => '履歴 & 入力';

  @override
  String get addEntry => '+ 追加';

  @override
  String get willRemoveLoan => '負債からも削除されます';

  @override
  String get delete => '削除';

  @override
  String get planned => '予定';

  @override
  String get whatIfAnalysis => '仮定分析';

  @override
  String get current => '現在';

  @override
  String get simulate => 'シミュレート';

  @override
  String get simHint => '支出や収入を変更してランウェイへの影響を確認';

  @override
  String get simulation => 'シミュレーション';

  @override
  String get enterValuesToSim => '上の値を入力してシミュレート';

  @override
  String get perMonth => '/ 月';

  @override
  String get prefsBudget => '設定 & 予算';

  @override
  String get close => '閉じる';

  @override
  String get monthlyBudget => '月間予算';

  @override
  String get rentFixed => '家賃 / 固定費';

  @override
  String get livingExpenses => '生活費';

  @override
  String get subtotal => '小計';

  @override
  String get totalBudgetPerMonth => '予算合計/月';

  @override
  String get setBudget => '予算設定';

  @override
  String get rentFixedCosts => '家賃 / 固定費用';

  @override
  String get subscrDebtAuto => 'サブスク + 負債は自動加算';

  @override
  String get display => '表示';

  @override
  String get glassEffect => 'グラスエフェクト';

  @override
  String get glassEffectHint => 'GPU負荷大 — 旧デバイスは無効化推奨';

  @override
  String get runwayBrand => 'RUNWAY';

  @override
  String get bootRunwayCheck => '> RUNWAYチェック...';

  @override
  String get bootIncomeStopped => '> 今日、収入が止まったら...';

  @override
  String get bootCountingCashDays => '> 現金で生きられる日数を計算中...';

  @override
  String get bootRemovingComfortFilter => '> 安心フィルターを解除中...';

  @override
  String get bootRealityCheckReady => '> 現実チェック準備完了。';

  @override
  String get ifIncomeStoppedToday => '今日、収入が止まったら';

  @override
  String get daysUpper => '日';

  @override
  String get yourRunway => 'あなたのランウェイ';

  @override
  String get emotionExposed => 'かなり危険です';

  @override
  String get emotionCloser => '思ったより近いです';

  @override
  String get emotionBreathingRoom => '少し余裕があります';

  @override
  String get emotionSaferMost => '多くの人より安全です';

  @override
  String get emotionAheadMost => '多くの人より先にいます';

  @override
  String youOutlastPeople(int percentile) {
    return 'あなたは$percentile%の人より長く持ちます';
  }

  @override
  String get loseIncome => '収入ゼロ';

  @override
  String get higherExpenses => '支出増加';

  @override
  String get incomeSetToZero => '収入を0に設定';

  @override
  String deltaDays(int days) {
    return '$days日';
  }

  @override
  String get shareSafe => '安全に共有';

  @override
  String get shareSafeHint => '貯金額も支出も出しません。ランウェイだけ。';

  @override
  String get preparing => '準備中...';

  @override
  String get shareImage => '画像を共有';

  @override
  String get shareAsText => 'テキストで共有';

  @override
  String get canYouBeatThis => 'これを超えられますか？';

  @override
  String shareImageText(int days, String identity) {
    return '今日収入が止まったら、私は$days日生きられます。$identity。これを超えられますか？ RUNWAY';
  }

  @override
  String shareTextMessage(int days, String identity, int percentile) {
    return '今日収入が止まったら、私は$days日生きられます。$identity。あなたは$percentile%の人より長く持ちます。これを超えられますか？ RUNWAY';
  }

  @override
  String get badgeSurvivalMode => 'サバイバルモード';

  @override
  String get badgeFinancialRookie => '金融ルーキー';

  @override
  String get badgeGettingBy => 'なんとか持ちこたえ中';

  @override
  String get badgeFinanciallyStable => '経済的に安定';

  @override
  String get badgeFinancialFortress => '金融要塞';

  @override
  String get badgeEscapeVelocity => '脱出速度';
}
