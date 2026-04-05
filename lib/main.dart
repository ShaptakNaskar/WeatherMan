import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/home_screen.dart';
import 'package:weatherman/screens/onboarding_screen.dart';
import 'package:weatherman/screens/splash_screen.dart';
import 'package:weatherman/screens/splash/clean_splash.dart';
// import 'package:weatherman/screens/splash/pastel_splash.dart';
import 'package:weatherman/screens/splash/pastel_dark_splash.dart';
import 'package:weatherman/screens/splash/sunset_splash.dart';
import 'package:weatherman/screens/splash/ocean_splash.dart';
import 'package:weatherman/services/location_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/services/weather_service.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/services/background_sync.dart';
import 'package:weatherman/services/push_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  await NotificationService.instance.init();
  await PushService.instance.init(requestPermission: false);
  await Workmanager().initialize(callbackDispatcher);
  await BackgroundSync.register();

  // Create providers
  final settingsProvider = SettingsProvider(storageService: storageService);
  await settingsProvider.init();

  final themeProvider = ThemeProvider(storageService: storageService);
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: themeProvider),
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
      child: const SappyWeatherApp(),
    ),
  );
}

/// SappyWeather app
class SappyWeatherApp extends StatelessWidget {
  const SappyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Adjust status bar brightness based on theme
    final brightness = themeProvider.isDark
        ? Brightness.light
        : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: brightness,
      ),
    );

    return MaterialApp(
      title: 'SappyWeather',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const _AppEntry(),
    );
  }
}

/// Entry point: shows splash -> onboarding (if first launch) -> home
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

enum _AppState { splash, onboarding, home }

class _AppEntryState extends State<_AppEntry> {
  _AppState _state = _AppState.splash;
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final storage = StorageService();
    final complete = await storage.getOnboardingComplete();
    if (mounted) {
      setState(() => _onboardingComplete = complete);
    }
  }

  void _onSplashComplete() {
    if (!mounted) return;
    if (_onboardingComplete == true) {
      setState(() => _state = _AppState.home);
    } else {
      setState(() => _state = _AppState.onboarding);
    }
  }

  void _onOnboardingComplete() {
    if (mounted) setState(() => _state = _AppState.home);
  }

  @override
  Widget build(BuildContext context) {
    // Show appropriate screen based on state
    switch (_state) {
      case _AppState.home:
        return const HomeScreen();
      case _AppState.onboarding:
        return OnboardingScreen(onComplete: _onOnboardingComplete);
      case _AppState.splash:
        return _buildSplashScreen();
    }
  }

  Widget _buildSplashScreen() {
    final themeProvider = context.watch<ThemeProvider>();

    switch (themeProvider.currentType) {
      case AppThemeType.cyberpunk:
        return CyberpunkSplashScreen(onComplete: _onSplashComplete);
      case AppThemeType.clean:
        return CleanSplashScreen(onComplete: _onSplashComplete);
      case AppThemeType.sunset:
        return SunsetSplashScreen(onComplete: _onSplashComplete);
      case AppThemeType.ocean:
        return OceanSplashScreen(onComplete: _onSplashComplete);
      // case AppThemeType.pastel:
      //   return PastelSplashScreen(onComplete: _onSplashComplete);
      case AppThemeType.pastel:
        return PastelDarkSplashScreen(onComplete: _onSplashComplete);
    }
  }
}
