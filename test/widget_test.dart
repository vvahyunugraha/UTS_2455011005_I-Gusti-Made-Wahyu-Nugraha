import 'package:flutter_test/flutter_test.dart';
import 'package:cookcraft/main.dart';

void main() {
  testWidgets('CookCraft app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CookCraftApp());
    expect(find.byType(CookCraftApp), findsOneWidget);
  });
}
