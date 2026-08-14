import 'package:flutter_test/flutter_test.dart';
import 'package:sismo_jima/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SismoJima initial render test', (WidgetTester tester) async {
    // Render SismoJima App
    await tester.pumpWidget(const SismoJimaApp());

    // Verify SismoJima app renders widget tree cleanly
    expect(find.byType(SismoJimaApp), findsOneWidget);
  });
}
