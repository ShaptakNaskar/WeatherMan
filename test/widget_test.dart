import 'package:flutter_test/flutter_test.dart';
import 'package:weatherman/main.dart';

void main() {
  testWidgets('WeatherMan app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherManApp());

    // Verify the app launches without crashing
    expect(find.byType(WeatherManApp), findsOneWidget);
  });
}
