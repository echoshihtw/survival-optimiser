import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke', () {
    testWidgets('app launches without crashing', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If we reach here the app rendered without throwing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('getting started card appears for fresh user', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('GETTING STARTED'), findsOneWidget);
    });

    testWidgets('tune icon opens config sheet', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.text('FORECAST'), findsOneWidget);
    });
  });
}
