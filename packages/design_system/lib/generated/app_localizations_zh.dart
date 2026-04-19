// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '生存優化器';

  @override
  String get hudTitle => '生存系統';

  @override
  String get sysOnline => '系統：上線';

  @override
  String get lifeForce => '生命力';

  @override
  String get statusLabel => '狀態';

  @override
  String get pressureLabel => '壓力';

  @override
  String get metrics => '數據';

  @override
  String get cash => '現金';

  @override
  String get burnPerMonth => '月支出';

  @override
  String get loanPerMonth => '月債務';

  @override
  String get runway => '存活期';

  @override
  String get runOut => '耗盡日';

  @override
  String get investable => '可投資';

  @override
  String get cashTimeline => '現金時間軸';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '每月貸款還款';

  @override
  String get tapToSet => '點擊設定';

  @override
  String get edit => '編輯';

  @override
  String get save => '儲存';

  @override
  String get clear => '清除';

  @override
  String get loanAffectsInfo => '> 月還款影響壓力比例和可投資金額';

  @override
  String get transactionLog => '// 交易記錄';

  @override
  String get newEntry => '+ 新增';

  @override
  String get noEntries => '> 尚無記錄\n> 點擊 [+ 新增] 開始';

  @override
  String get newLogEntry => '> 新增記錄';

  @override
  String get modifyEntry => '> 修改記錄';

  @override
  String get type => '類型';

  @override
  String get date => '日期';

  @override
  String get calcMonth => '計算月份';

  @override
  String get amount => '金額';

  @override
  String get noteOptional => '備註（選填）';

  @override
  String get confirm => '確認';

  @override
  String get abort => '取消';

  @override
  String get purgeEntry => '> 刪除此記錄？';

  @override
  String get scenarioSimulator => '// 情境模擬器';

  @override
  String get overrideInputs => '覆蓋輸入';

  @override
  String get burnRateOverride => '支出覆蓋';

  @override
  String get simulatedIncome => '模擬月收入';

  @override
  String get simResults => '模擬結果';

  @override
  String get simRunway => '模擬存活期';

  @override
  String get simRunOut => '模擬耗盡日';

  @override
  String get simInvestable => '模擬可投資';

  @override
  String get deltaVsActual => '與實際差異';

  @override
  String get deltaRunway => '存活期差異';

  @override
  String get deltaInvestable => '可投資差異';

  @override
  String get resetSim => '重置模擬';

  @override
  String get months => '個月';

  @override
  String get stable => '穩定';

  @override
  String get caution => '警告';

  @override
  String get critical => '危急';

  @override
  String get low => '低';

  @override
  String get moderate => '中等';

  @override
  String get highLoad => '高負荷';

  @override
  String get language => '語言';

  @override
  String get currency => '貨幣';

  @override
  String get addNoData => '> 新增交易以查看時間軸';

  @override
  String get loading => '載入中...';

  @override
  String get navHud => '儀表';

  @override
  String get navLog => '記錄';

  @override
  String get navSim => '模擬';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '收入';

  @override
  String get typeLoan => '貸款';

  @override
  String get typeInvest => '投資';

  @override
  String get typeRepay => '還款';

  @override
  String get typeOpening => '初始';

  @override
  String get liabilities => '负债';

  @override
  String get noActiveLoans => '> 无有效贷款';

  @override
  String get settled => '已结清';

  @override
  String get totalDebtPerMonth => '月债务合计';

  @override
  String get remaining => '剩余';

  @override
  String get installment => '每期还款';

  @override
  String get paidThisMo => '本月已还';

  @override
  String get monthsLeft => '剩余月数';

  @override
  String get repaid => '% 已还';

  @override
  String get repay => '还款';

  @override
  String get repayTitle => '> 还款';

  @override
  String get extra => '额外';

  @override
  String get configButton => '设置';

  @override
  String get loanWizardTitle => '贷款助手';

  @override
  String get whoAndHowMuch => '对象与金额';

  @override
  String get loanTerms => '贷款条件';

  @override
  String get confirmPayment => '确认还款';

  @override
  String get source => '来源';

  @override
  String get nameLender => '名称 / 借款方';

  @override
  String get loanAmount => '贷款金额';

  @override
  String get annualRate => '年利率 % (0 = 无利息)';

  @override
  String get repaymentMonths => '还款月数';

  @override
  String get computedInstallment => '计算每期还款';

  @override
  String get overrideInstallment => '自定每月还款';

  @override
  String get monthlyInstallment => '每月还款';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get lender => '借款方';

  @override
  String get rate => '利率';

  @override
  String get change => '更改';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '生存優化器';

  @override
  String get hudTitle => '生存系統';

  @override
  String get sysOnline => '系統：上線';

  @override
  String get lifeForce => '生命力';

  @override
  String get statusLabel => '狀態';

  @override
  String get pressureLabel => '壓力';

  @override
  String get metrics => '數據';

  @override
  String get cash => '現金';

  @override
  String get burnPerMonth => '月支出';

  @override
  String get loanPerMonth => '月債務';

  @override
  String get runway => '存活期';

  @override
  String get runOut => '耗盡日';

  @override
  String get investable => '可投資';

  @override
  String get cashTimeline => '現金時間軸';

  @override
  String get config => '設定';

  @override
  String get monthlyLoanPayment => '每月貸款還款';

  @override
  String get tapToSet => '點擊設定';

  @override
  String get edit => '編輯';

  @override
  String get save => '儲存';

  @override
  String get clear => '清除';

  @override
  String get loanAffectsInfo => '> 月還款影響壓力比例和可投資金額';

  @override
  String get transactionLog => '// 交易記錄';

  @override
  String get newEntry => '+ 新增';

  @override
  String get noEntries => '> 尚無記錄\n> 點擊 [+ 新增] 開始';

  @override
  String get newLogEntry => '> 新增記錄';

  @override
  String get modifyEntry => '> 修改記錄';

  @override
  String get type => '類型';

  @override
  String get date => '日期';

  @override
  String get calcMonth => '計算月份';

  @override
  String get amount => '金額';

  @override
  String get noteOptional => '備註（選填）';

  @override
  String get confirm => '確認';

  @override
  String get abort => '取消';

  @override
  String get purgeEntry => '> 刪除此記錄？';

  @override
  String get scenarioSimulator => '// 情境模擬器';

  @override
  String get overrideInputs => '覆蓋輸入';

  @override
  String get burnRateOverride => '支出覆蓋';

  @override
  String get simulatedIncome => '模擬月收入';

  @override
  String get simResults => '模擬結果';

  @override
  String get simRunway => '模擬存活期';

  @override
  String get simRunOut => '模擬耗盡日';

  @override
  String get simInvestable => '模擬可投資';

  @override
  String get deltaVsActual => '與實際差異';

  @override
  String get deltaRunway => '存活期差異';

  @override
  String get deltaInvestable => '可投資差異';

  @override
  String get resetSim => '重置模擬';

  @override
  String get months => '個月';

  @override
  String get stable => '穩定';

  @override
  String get caution => '警告';

  @override
  String get critical => '危急';

  @override
  String get low => '低';

  @override
  String get moderate => '中等';

  @override
  String get highLoad => '高負荷';

  @override
  String get language => '語言';

  @override
  String get currency => '貨幣';

  @override
  String get addNoData => '> 新增交易以查看時間軸';

  @override
  String get loading => '載入中...';

  @override
  String get navHud => '儀表';

  @override
  String get navLog => '記錄';

  @override
  String get navSim => '模擬';

  @override
  String get typeExpense => '支出';

  @override
  String get typeIncome => '收入';

  @override
  String get typeLoan => '貸款';

  @override
  String get typeInvest => '投資';

  @override
  String get typeRepay => '還款';

  @override
  String get typeOpening => '初始';

  @override
  String get liabilities => '負債';

  @override
  String get noActiveLoans => '> 無有效貸款';

  @override
  String get settled => '已結清';

  @override
  String get totalDebtPerMonth => '月債務合計';

  @override
  String get remaining => '剩餘';

  @override
  String get installment => '每期還款';

  @override
  String get paidThisMo => '本月已還';

  @override
  String get monthsLeft => '剩餘月數';

  @override
  String get repaid => '% 已還';

  @override
  String get repay => '還款';

  @override
  String get repayTitle => '> 還款';

  @override
  String get extra => '額外';

  @override
  String get configButton => '設定';

  @override
  String get loanWizardTitle => '貸款精靈';

  @override
  String get whoAndHowMuch => '對象與金額';

  @override
  String get loanTerms => '貸款條件';

  @override
  String get confirmPayment => '確認還款';

  @override
  String get source => '來源';

  @override
  String get nameLender => '名稱 / 借款方';

  @override
  String get loanAmount => '貸款金額';

  @override
  String get annualRate => '年利率 % (0 = 無利息)';

  @override
  String get repaymentMonths => '還款月數';

  @override
  String get computedInstallment => '計算每期還款';

  @override
  String get overrideInstallment => '自訂每月還款';

  @override
  String get monthlyInstallment => '每月還款';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get lender => '借款方';

  @override
  String get rate => '利率';

  @override
  String get change => '更改';
}
