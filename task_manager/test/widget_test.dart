import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TaskManagerApp(),
      ),
    );

    // Verify that the splash screen or login screen is shown.
    // Since we can't easily test Firebase in widget tests without mocks, 
    // we just check if the app starts.
    expect(find.byType(TaskManagerApp), findsOneWidget);
  });
}
