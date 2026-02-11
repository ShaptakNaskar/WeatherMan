import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/home_screen.dart';
import 'package:weatherman/services/location_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (allow all)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  final storageService = StorageService();
  final weatherService = WeatherService();
  final locationService = LocationService();

  // Create providers
  final settingsProvider = SettingsProvider(storageService: storageService);
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            locationService: locationService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            weatherService: weatherService,
            storageService: storageService,
          ),
        ),
      ],
      child: const WeatherManApp(),
    ),
  );
}

/// WeatherMan App
class WeatherManApp extends StatelessWidget {
  const WeatherManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'W3ATHER.exe',
      debugShowCheckedModeBanner: false,
      theme: CyberpunkTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
