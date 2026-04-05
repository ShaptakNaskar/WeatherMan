import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherman/main.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/services/storage_service.dart';

void main() {
  testWidgets('SappyWeather app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(storageService: StorageService()),
        child: const SappyWeatherApp(),
      ),
    );

    // Verify the app launches without crashing
    expect(find.byType(SappyWeatherApp), findsOneWidget);

    // Dispose the app and flush delayed timers from splash boot sequence.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });
}
