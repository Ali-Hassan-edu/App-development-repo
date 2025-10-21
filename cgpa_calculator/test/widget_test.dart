import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:uni_grade_master/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build the main app widget
   // await tester.pumpWidget(const MyApp());

    // Rebuild the widget tree after animations
    await tester.pumpAndSettle();

    // Verify app title or main text is present
    expect(find.text('GPA Calculator'), findsOneWidget);
  });
}
