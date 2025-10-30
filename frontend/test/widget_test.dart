// Basic Flutter widget test for Text Toner app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:Text_Toner/main.dart';

void main() {
  testWidgets('Text Toner app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TextTonerApp());

    // Verify that the app title is present
    expect(find.text('Text Toner'), findsOneWidget);

    // Verify that the tagline is present
    expect(find.text('Tone your text, instantly'), findsOneWidget);
  });
}
