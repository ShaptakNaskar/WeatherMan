import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/search_screen.dart';
import 'package:weatherman/screens/settings_screen.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/themed/themed_background.dart';
import 'package:weatherman/widgets/cyberpunk/glitch_effects.dart';
import 'package:weatherman/widgets/cyberpunk/hud_warnings.dart';
import 'package:weatherman/widgets/common/shimmer_loading.dart';
import 'package:weatherman/widgets/weather/current_weather.dart';
import 'package:weatherman/widgets/weather/daily_forecast.dart';
import 'package:weatherman/widgets/weather/hourly_forecast.dart';
import 'package:weatherman/widgets/weather/weather_details.dart';
import 'package:weatherman/widgets/weather/advanced_details.dart';
import 'package:weatherman/widgets/weather/weather_insights.dart';
import 'package:weatherman/widgets/weather/clothing_advice.dart';
import 'package:weatherman/widgets/weather/rain_timeline.dart';
import 'package:weatherman/widgets/weather/sunrise_countdown.dart';
import 'package:weatherman/widgets/cyberpunk/system_status_bar.dart';
import 'package:weatherman/services/widget_service.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/services/push_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

/// Main home screen displaying weather for selected location
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final settings = context.read<SettingsProvider>();
    final storage = StorageService();

    await locationProvider.init();

    // On first launch (no saved/last location), show rationale before requesting GPS
    if (locationProvider.selectedLocation == null &&
        locationProvider.currentDeviceLocation == null) {
      if (mounted) await _showLocationRationale();
    }

    await locationProvider.fetchCurrentLocation();

    final selectedLocation = locationProvider.selectedLocation;
    if (selectedLocation != null) {
      await weatherProvider.fetchWeather(selectedLocation);
      final weather = weatherProvider.getWeather(selectedLocation);
      if (weather != null) {
        await WidgetService.update(weather);
        if (settings.persistentNotificationEnabled) {
          await NotificationService.instance.showPersistent(weather);
        }
      }
    }

    await _runFirstLaunchPrompts(storage);
  }

  Future<void> _refreshWeather() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final settings = context.read<SettingsProvider>();

    final selectedLocation = locationProvider.selectedLocation;
    if (selectedLocation != null) {
      await weatherProvider.refreshWeather(selectedLocation);
      final weather = weatherProvider.getWeather(selectedLocation);
      if (weather != null) {
        await WidgetService.update(weather);
        if (settings.persistentNotificationEnabled) {
          await NotificationService.instance.showPersistent(weather);
        }
      }
    }

    // Permission prompts are now handled in onboarding
    // await _runFirstLaunchPrompts(storage);
  }

  // Legacy first-launch prompts - now handled in OnboardingScreen
  // Kept for reference but no longer called
  Future<void> _runFirstLaunchPrompts(StorageService storage) async {
    if (!mounted) return;

    final notifPrompted = await storage.getNotificationPrompted();
    if (!notifPrompted) {
      final allow = await _showNotificationRationale();
      if (allow == true) {
        await NotificationService.instance.requestPermission();
        await PushService.instance.init(requestPermission: true);
      }
      await storage.setNotificationPrompted();
    }

    if (Platform.isAndroid) {
      final batteryPrompted = await storage.getBatteryPrompted();
      if (!batteryPrompted) {
        final allow = await _showBatteryRationale();
        if (allow == true) {
          await _openBatterySettings();
        }
        await storage.setBatteryPrompted();
      }
    }
  }

  Future<void> _showLocationRationale() async {
    final t = context.read<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: t.themeData.brightness == Brightness.light
            ? Colors.white
            : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on_rounded, color: accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Location Access',
              style: TextStyle(
                color: t.themeData.brightness == Brightness.light
                    ? t.textPrimary
                    : Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'SappyWeather needs your location to show weather for where you are. '
          'Please allow location access on the next prompt to get started!',
          style: TextStyle(
            color: t.themeData.brightness == Brightness.light
                ? t.textSecondary
                : Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showNotificationRationale() {
    final t = context.read<ThemeProvider>().current;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: t.themeData.brightness == Brightness.light
            ? Colors.white
            : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
        ),
        title: Text(
          'Enable notifications?',
          style: TextStyle(
            color: t.themeData.brightness == Brightness.light
                ? t.textPrimary
                : Colors.white,
          ),
        ),
        content: Text(
          'Get morning/evening briefings, severe weather alerts, and trend insights.',
          style: TextStyle(
            color: t.themeData.brightness == Brightness.light
                ? t.textSecondary
                : Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBatteryRationale() {
    final t = context.read<ThemeProvider>().current;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: t.themeData.brightness == Brightness.light
            ? Colors.white
            : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
        ),
        title: Text(
          'Allow background access?',
          style: TextStyle(
            color: t.themeData.brightness == Brightness.light
                ? t.textPrimary
                : Colors.white,
          ),
        ),
        content: Text(
          'Keep widgets and briefings up to date. You can revoke in system settings.',
          style: TextStyle(
            color: t.themeData.brightness == Brightness.light
                ? t.textSecondary
                : Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBatterySettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:${Uri.encodeComponent('com.sappy.weather')}',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeProvider.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Consumer3<LocationProvider, WeatherProvider, SettingsProvider>(
      builder: (context, locationProvider, weatherProvider, settings, _) {
        final selectedLocation = locationProvider.selectedLocation;
        final weather = selectedLocation != null
            ? weatherProvider.getWeather(selectedLocation)
            : null;

        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;

        // HUD alerts (cyberpunk only shows the overlay, but evaluate for all)
        final alerts = weather != null
            ? AlertEvaluator.evaluate(
                current: weather.current,
                airQuality: weather.airQuality,
              )
            : <EnvironmentAlert>[];
        final hasDanger = alerts.any((a) => a.severity == AlertSeverity.danger);

        Widget body = ThemedBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: _buildBody(locationProvider, weatherProvider, weather),
                ),
              ),
              // HUD warnings only for cyberpunk
              if (themeProvider.isCyberpunk) HudWarningOverlay(alerts: alerts),
            ],
          ),
        );

        // Danger flash only for cyberpunk
        if (themeProvider.isCyberpunk) {
          body = DangerFlashOverlay(hasDanger: hasDanger, child: body);
        }

        return body;
      },
    );
  }

  Widget _buildBody(
    LocationProvider locationProvider,
    WeatherProvider weatherProvider,
    WeatherData? weather,
  ) {
    final selectedLocation = locationProvider.selectedLocation;

    if (weatherProvider.isLoading && weather == null) {
      return const WeatherLoadingShimmer();
    }

    if (weatherProvider.state == WeatherState.error && weather == null) {
      return _buildErrorState(weatherProvider.error ?? 'Unknown error');
    }

    // Show loading state while GPS is being fetched (first launch)
    if (selectedLocation == null && locationProvider.isLoadingLocation) {
      return _buildLocationLoadingState();
    }

    if (selectedLocation == null) {
      return _buildNoLocationState();
    }

    if (weather != null) {
      return _buildWeatherContent(weather, weatherProvider.isRefreshing);
    }

    if (!weatherProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        weatherProvider.fetchWeather(selectedLocation);
      });
    }

    return const WeatherLoadingShimmer();
  }

  Widget _buildWeatherContent(WeatherData weather, bool isRefreshing) {
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          );
          return _buildLandscapeContent(weather, today, isRefreshing);
        }
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values,
        );
        return _buildPortraitContent(weather, today, isRefreshing);
      },
    );
  }

  Widget _buildPortraitContent(
    WeatherData weather,
    DailyForecast? today,
    bool isRefreshing,
  ) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;

    return RefreshIndicator(
      onRefresh: _refreshWeather,
      color: accent,
      backgroundColor: t.cardColor.withValues(alpha: 0.8),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildAppBar(),

          SliverToBoxAdapter(
            child:
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CurrentWeatherDisplay(
                        weather: weather.current,
                        locationName: weather.location.name,
                        temperatureMax:
                            today?.temperatureMax ??
                            weather.current.temperature,
                        temperatureMin:
                            today?.temperatureMin ??
                            weather.current.temperature,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
          ),

          if (isRefreshing) _buildRefreshingIndicator(),

          _buildStatusLine(weather),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Clothing advice (new feature)
          SliverToBoxAdapter(
            child: ClothingAdviceCard(
              weather: weather,
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Rain timeline (new feature — only shows when rain expected)
          SliverToBoxAdapter(
            child: RainTimelineCard(
              hourly: weather.hourly,
            ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Sunrise/sunset countdown
          if (today != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SunriseSunsetCard(
                  today: today,
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          ..._buildForecastSlivers(weather, today),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(
    WeatherData weather,
    DailyForecast? today,
    bool isRefreshing,
  ) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;

    return Row(
      children: [
        // Left panel
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => _openCityList(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () => _openSearch(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _openSettings(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CurrentWeatherDisplay(
                          weather: weather.current,
                          locationName: weather.location.name,
                          temperatureMax:
                              today?.temperatureMax ??
                              weather.current.temperature,
                          temperatureMin:
                              today?.temperatureMin ??
                              weather.current.temperature,
                        ),
                        const SizedBox(height: 16),
                        if (isRefreshing)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                t.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        Text(
                          'Updated ${DateTimeUtils.formatRelativeTime(weather.fetchedAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: t.textTertiary.withValues(alpha: 0.28)),
        // Right panel
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshWeather,
            color: accent,
            backgroundColor: t.cardColor.withValues(alpha: 0.8),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Clothing advice
                SliverToBoxAdapter(child: ClothingAdviceCard(weather: weather)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Rain timeline
                SliverToBoxAdapter(
                  child: RainTimelineCard(hourly: weather.hourly),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Sunrise/sunset countdown
                if (today != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SunriseSunsetCard(today: today),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                ..._buildForecastSlivers(weather, today),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => _openCityList(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _openSearch(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _openSettings(),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildRefreshingIndicator() {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                accent.withValues(alpha: 0.72),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatusLine(WeatherData weather) {
    final themeProvider = context.watch<ThemeProvider>();
    final t = themeProvider.current;

    if (themeProvider.isCyberpunk) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: GlitchText(
              text:
                  '// UPDATED ${DateTimeUtils.formatRelativeTime(weather.fetchedAt).toUpperCase()} //',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: t.textTertiary,
                letterSpacing: 2,
              ),
              glitchIntensity: 0.3,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      );
    }

    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            'Updated ${DateTimeUtils.formatRelativeTime(weather.fetchedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textTertiary,
              shadows: t.textShadows,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForecastSlivers(
    WeatherData weather,
    DailyForecast? today,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return [
      // Hourly forecast
      SliverToBoxAdapter(
        child: HourlyForecastCard(hourly: weather.hourly)
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(
              begin: 0.03,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Daily forecast
      SliverToBoxAdapter(
        child: DailyForecastCard(daily: weather.daily)
            .animate()
            .fadeIn(duration: 600.ms, delay: 350.ms)
            .slideY(
              begin: 0.03,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Weather insights
      SliverToBoxAdapter(
        child: WeatherInsightsCard(weather: weather)
            .animate()
            .fadeIn(duration: 600.ms, delay: 425.ms)
            .slideY(
              begin: 0.03,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Weather details
      if (today != null)
        SliverToBoxAdapter(
          child:
              WeatherDetailsGrid(
                    current: weather.current,
                    today: today,
                    airQuality: weather.airQuality,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 500.ms)
                  .slideY(
                    begin: 0.03,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
        ),

      // Advanced details
      Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.advancedViewEnabled) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverToBoxAdapter(
            child:
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          AdvancedDetailsCard(
                            weather: weather,
                            formatTemp: settings.formatTemp,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 650.ms)
                    .slideY(
                      begin: 0.03,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
          );
        },
      ),

      // System status bar (cyberpunk only)
      if (themeProvider.isCyberpunk)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 4),
            child: SystemStatusBar(weather: weather),
          ).animate().fadeIn(duration: 600.ms, delay: 750.ms),
        ),
    ];
  }

  Widget _buildErrorState(String error) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: t.dangerColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: t.dangerColor,
                shadows: t.textShadows,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                shadows: t.textShadows,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.cardColor.withValues(alpha: 0.68),
                foregroundColor: t.textPrimary,
                side: BorderSide(color: accent.withValues(alpha: 0.72)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(t.cardBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationLoadingState() {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Getting your location...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.textPrimary,
                shadows: t.textShadows,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching weather for your area',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                shadows: t.textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationState() {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gps_off_rounded,
              size: 64,
              color: t.warningColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No location selected',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: t.warningColor,
                shadows: t.textShadows,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for a city to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
                shadows: t.textShadows,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openSearch(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add city'),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.cardColor.withValues(alpha: 0.68),
                foregroundColor: t.textPrimary,
                side: BorderSide(color: accent.withValues(alpha: 0.75)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(t.cardBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _openCityList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CityListBottomSheet(),
    );
  }
}

/// Bottom sheet for city list
class _CityListBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;

    return Consumer3<LocationProvider, WeatherProvider, SettingsProvider>(
      builder: (context, locationProvider, weatherProvider, settings, _) {
        final allLocations = locationProvider.allLocations;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: t.themeData.brightness == Brightness.light
                ? Colors.white.withValues(alpha: 0.95)
                : t.backgroundColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(t.cardBorderRadius),
            ),
            border: Border.all(color: t.textTertiary.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.textTertiary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Saved Locations',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: accent),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // City list
              Flexible(
                child: allLocations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No saved locations',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textSecondary),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allLocations.length,
                        itemBuilder: (context, index) {
                          final location = allLocations[index];
                          final weather = weatherProvider.getWeather(location);
                          final isSelected =
                              location == locationProvider.selectedLocation;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accent.withValues(alpha: 0.1)
                                  : t.cardColor.withValues(alpha: 0.5),
                              border: Border.all(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.58)
                                    : t.cardBorderColor.withValues(alpha: 0.3),
                                width: isSelected ? 1 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                t.cardBorderRadius,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 2,
                              ),
                              leading: Icon(
                                location.isCurrentLocation
                                    ? Icons.my_location_rounded
                                    : Icons.location_city_rounded,
                                color: isSelected ? accent : t.textSecondary,
                                size: 20,
                              ),
                              title: Text(
                                location.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? accent : t.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: weather != null
                                  ? Text(
                                      '${settings.formatTemp(weather.current.temperature)} · ${WeatherUtils.getWeatherDescription(weather.current.weatherCode)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: t.textTertiary,
                                      ),
                                    )
                                  : null,
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: t.successColor,
                                      size: 18,
                                    )
                                  : weather != null
                                  ? Text(
                                      settings.formatTempShort(
                                        weather.current.temperature,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: t.textPrimary.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                locationProvider.selectLocation(location);
                                weatherProvider.fetchWeather(location);
                                Navigator.pop(context);
                              },
                              onLongPress: () {
                                if (!location.isCurrentLocation) {
                                  _showDeleteDialog(
                                    context,
                                    locationProvider,
                                    location,
                                    t,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LocationProvider locationProvider,
    dynamic location,
    AppThemeData t,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: t.themeData.brightness == Brightness.light
            ? Colors.white
            : t.backgroundColor.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
          side: BorderSide(color: t.dangerColor.withValues(alpha: 0.4)),
        ),
        title: Text(
          'Remove location?',
          style: TextStyle(color: t.dangerColor, fontSize: 16),
        ),
        content: Text(
          'Remove ${location.name} from saved locations?',
          style: TextStyle(color: t.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: t.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              locationProvider.removeLocation(location);
              Navigator.pop(context);
            },
            child: Text('Remove', style: TextStyle(color: t.dangerColor)),
          ),
        ],
      ),
    );
  }
}
