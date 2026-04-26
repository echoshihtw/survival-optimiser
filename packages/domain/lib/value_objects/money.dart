class Money {
  final double value;

  const Money._(this.value);

  factory Money(double value) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError('Invalid money value: $value');
    }
    if (value < 0) {
      throw ArgumentError('Money must be non-negative. Got: $value');
    }
    return Money._(value);
  }

  factory Money.zero() => const Money._(0);

  Money operator +(Money other) => Money._(value + other.value);
  Money operator -(Money other) => Money._(value - other.value);
  Money operator *(double factor) => Money._(value * factor);

  bool get isZero => value == 0;
  bool get isPositive => value > 0;

  @override
  String toString() => value.toStringAsFixed(0);

  @override
  bool operator ==(Object other) => other is Money && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
