import 'package:flutter_test/flutter_test.dart';
import 'package:cookcraft/main.dart';

void main() {
  testWidgets('CookCraft app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CookCraftApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CookCraftApp), findsOneWidget);
  });
}
