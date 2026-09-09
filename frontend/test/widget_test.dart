import 'package:flutter_test/flutter_test.dart';
import 'package:agriintel_app/main.dart';

void main() {
  testWidgets('AgriIntel smoke test and navigation to Home', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriIntelApp());
    expect(find.byType(AgriIntelApp), findsOneWidget);

    // Settle splash timer
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
