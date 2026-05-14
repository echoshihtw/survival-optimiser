import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('calculateRunwayGoalProgress', () {
    test('normalizes current runway against a user target', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 6, targetMonths: 24),
        0.25,
      );
    });

    test('caps progress at 1.0', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 48, targetMonths: 24),
        1.0,
      );
    });

    test('treats infinite runway as complete for any finite goal', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 9999, targetMonths: 24),
        1.0,
      );
    });

    test('returns zero for invalid targets', () {
      expect(
        calculateRunwayGoalProgress(runwayMonths: 6, targetMonths: 0),
        0.0,
      );
    });
  });

  group('calculateRunwayGoalProgressPercent', () {
    test('returns rounded UI percent', () {
      expect(
        calculateRunwayGoalProgressPercent(runwayMonths: 13, targetMonths: 24),
        54,
      );
    });
  });
}
