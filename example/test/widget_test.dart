import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_shockwave_example/main.dart';

void main() {
  testWidgets('ExampleApp smoke test and Light/Dark mode toggle test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    // Verify contact card elements exist
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('Graphics Engineer & Tech Artist'), findsOneWidget);
    expect(find.textContaining('Trigger From Bottom'), findsOneWidget);
    expect(find.textContaining('Top-Edge NameDrop'), findsOneWidget);

    // Verify Light Mode toggle exists
    expect(find.text('Light Mode'), findsOneWidget);

    // Tap Light Mode toggle
    await tester.tap(find.text('Light Mode'));
    await tester.pumpAndSettle();

    // Now it should show Dark Mode button
    expect(find.text('Dark Mode'), findsOneWidget);

    // Tap to switch back to Dark Mode
    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Light Mode'), findsOneWidget);
  });
}
