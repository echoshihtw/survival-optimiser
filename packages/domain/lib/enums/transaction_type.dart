enum TransactionType {
  expense,
  income,
  loan,
  investment,
  repayment,
  openingBalance;

  String get label => switch (this) {
    TransactionType.expense        => 'EXPENSE',
    TransactionType.income         => 'INCOME',
    TransactionType.loan           => 'LOAN',
    TransactionType.investment     => 'INVEST',
    TransactionType.repayment      => 'REPAY',
    TransactionType.openingBalance => 'OPENING',
  };

  bool get isInflow => switch (this) {
    TransactionType.income         => true,
    TransactionType.loan           => true,
    TransactionType.openingBalance => true,
    _                              => false,
  };
}
