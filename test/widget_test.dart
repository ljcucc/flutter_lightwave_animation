import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_shockwave/liquid_shockwave.dart';

void main() {
  testWidgets('LiquidShockwaveContainer mounts and renders child widget',
      (WidgetTester tester) async {
    final key = GlobalKey<LiquidShockwaveContainerState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidShockwaveContainer(
            key: key,
            triggerOnTap: true,
            child: const Text('Target Child Widget'),
          ),
        ),
      ),
    );

    expect(find.text('Target Child Widget'), findsOneWidget);
    expect(key.currentState, isNotNull);
  });

  testWidgets(
      'LiquidShockwaveContainer can be triggered repeatedly from all sides without locking',
      (WidgetTester tester) async {
    final key = GlobalKey<LiquidShockwaveContainerState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidShockwaveContainer(
            key: key,
            duration: const Duration(milliseconds: 300),
            triggerOnTap: true,
            child: const SizedBox(
              width: 300,
              height: 400,
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    final state = key.currentState;
    expect(state, isNotNull);

    // 1st Trigger: Bottom
    await state!.triggerFromSide(ShockwaveSide.bottom);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 2nd Trigger: Top (must work after 1st completion!)
    await state.triggerFromSide(ShockwaveSide.top);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 3rd Trigger: Left
    await state.triggerFromSide(ShockwaveSide.left);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 4th Trigger: Right
    await state.triggerFromSide(ShockwaveSide.right);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // 5th Trigger: Custom duration override
    await state.trigger(const Offset(150, 200), const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify child is healthy
    expect(find.text('Card Content'), findsOneWidget);
  });
}
