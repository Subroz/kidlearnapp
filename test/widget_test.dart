// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kidlearn_flutter/app.dart';

void main() {
  testWidgets('KidLearn app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KidLearnApp()));

    // Pump a few frames to let the app initialize
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the app renders without errors
    expect(find.byType(KidLearnApp), findsOneWidget);
  });
}
