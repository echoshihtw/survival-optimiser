class SurvivalMonth {
  final DateTime value;

  SurvivalMonth._(this.value);

  factory SurvivalMonth(DateTime date) {
    return SurvivalMonth._(DateTime(date.year, date.month, 1));
  }

  factory SurvivalMonth.fromYearMonth(int year, int month) {
    return SurvivalMonth._(DateTime(year, month, 1));
  }

  SurvivalMonth next() =>
      SurvivalMonth(DateTime(value.year, value.month + 1, 1));

  bool isBefore(SurvivalMonth other) => value.isBefore(other.value);
  bool isAfter(SurvivalMonth other) => value.isAfter(other.value);

  bool operator <(SurvivalMonth other) => isBefore(other);
  bool operator >(SurvivalMonth other) => isAfter(other);

  @override
  bool operator ==(Object other) =>
      other is SurvivalMonth && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}';
}
