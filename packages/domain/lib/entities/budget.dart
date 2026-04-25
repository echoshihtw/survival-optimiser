class Budget {
  final double rent;
  final double living;

  const Budget({
    this.rent   = 0,
    this.living = 0,
  });

  double get subtotal => rent + living;
  double get total    => subtotal;
  bool get isSet => rent > 0 || living > 0;

  Budget copyWith({double? rent, double? living}) => Budget(
    rent:   rent   ?? this.rent,
    living: living ?? this.living,
  );
}
