// Basic smoke test for TrendWise app.

import 'package:flutter_test/flutter_test.dart';
import 'package:trendwise_app/main.dart';

void main() {
  testWidgets('App renders TrendWise title', (WidgetTester tester) async {
    await tester.pumpWidget(const TrendWiseApp());
    expect(find.text('TrendWise'), findsOneWidget);
  });
}
