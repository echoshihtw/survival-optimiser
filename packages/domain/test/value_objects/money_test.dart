import 'package:test/test.dart';
import 'package:domain/domain.dart';

void main() {
  group('Money', () {
    test('creates valid money', () {
      expect(Money(100).value, 100);
    });

    test('throws on negative value', () {
      expect(() => Money(-1), throwsArgumentError);
    });

    test('throws on NaN', () {
      expect(() => Money(double.nan), throwsArgumentError);
    });

    test('addition works', () {
      expect((Money(100) + Money(200)).value, 300);
    });

    test('zero is zero', () {
      expect(Money.zero().isZero, true);
    });
  });
}
