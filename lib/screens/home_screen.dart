import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/search_screen.dart';
import 'package:weatherman/screens/settings_screen.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/common/shimmer_loading.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';
import 'package:weatherman/widgets/weather/air_quality_card.dart';
import 'package:weatherman/widgets/weather/advanced_details.dart';
import 'package:weatherman/widgets/weather/city_list_sheet.dart';
import 'package:weatherman/widgets/weather/current_weather.dart';
import 'package:weatherman/widgets/weather/daily_forecast.dart';
import 'package:weatherman/widgets/weather/detail_grid.dart';
import 'package:weatherman/widgets/weather/feel_index_card.dart';
import 'package:weatherman/widgets/weather/hourly_forecast.dart';
import 'package:weatherman/widgets/weather/precipitation_timeline.dart';
import 'package:weatherman/widgets/weather/sun_daylight_card.dart';
import 'package:weatherman/widgets/weather/weather_icon_painter.dart';

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
    final locP = context.read<LocationProvider>();
    final wP = context.read<WeatherProvider>();
    await locP.init();
    await locP.fetchCurrentLocation();
    final sel = locP.selectedLocation;
    if (sel != null) await wP.fetchWeather(sel);
  }

  Future<void> _refresh() async {
    final sel = context.read<LocationProvider>().selectedLocation;
    if (sel != null) await context.read<WeatherProvider>().refreshWeather(sel);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Consumer3<LocationProvider, WeatherProvider, SettingsProvider>(
      builder: (context, locP, wP, settings, _) {
        final sel = locP.selectedLocation;
        final weather = sel != null ? wP.getWeather(sel) : null;
        final code = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;
        final today = weather?.daily.isNotEmpty == true ? weather!.daily.first : null;

        return DynamicBackground(
          weatherCode: code,
          isDay: isDay,
          sunrise: today?.sunrise,
          sunset: today?.sunset,
          temperature: weather?.current.temperature,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: _body(locP, wP, settings, weather),
            ),
          ),
        );
      },
    );
  }

  Widget _body(LocationProvider locP, WeatherProvider wP,
      SettingsProvider settings, WeatherData? weather) {
    if (wP.isLoading && weather == null) return const WeatherLoadingShimmer();
    if (wP.state == WeatherState.error && weather == null) {
      return _error(wP.error ?? 'Unknown error');
    }
    if (locP.selectedLocation == null) return _noLocation();
    if (weather == null) {
      if (!wP.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          wP.fetchWeather(locP.selectedLocation!);
        });
      }
      return const WeatherLoadingShimmer();
    }
    return _content(weather, wP.isRefreshing, settings);
  }

  Widget _content(WeatherData w, bool refreshing, SettingsProvider settings) {
    final today = w.daily.isNotEmpty ? w.daily.first : null;
    final glassTint = DesignSystem.defaultGlassTint;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.15),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _appBar(w),
          _sliver(CurrentWeatherDisplay(
            weather: w.current,
            locationName: w.location.name,
            temperatureMax: today?.temperatureMax ?? w.current.temperature,
            temperatureMin: today?.temperatureMin ?? w.current.temperature,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.04, end: 0, duration: 500.ms)),
          if (refreshing) _sliver(_refreshPill()),
          _sliver(Padding(
            padding: const EdgeInsets.only(top: DesignSystem.spacingS),
            child: Center(child: Text(
              'Updated ${DateTimeUtils.formatRelativeTime(w.fetchedAt)}',
              style: DesignSystem.caption,
            )),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingL)),
          _sliver(HourlyForecastCard(hourly: w.hourly, glassTint: glassTint)
              .animate().fadeIn(duration: 600.ms, delay: 150.ms)),
          if (PrecipitationTimeline.shouldShow(w.hourly)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
            _sliver(PrecipitationTimeline(hourly: w.hourly, glassTint: glassTint)
                .animate().fadeIn(duration: 600.ms, delay: 200.ms)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
          _sliver(DailyForecastCard(daily: w.daily, glassTint: glassTint)
              .animate().fadeIn(duration: 600.ms, delay: 300.ms)),
          const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
          _sliver(DetailGrid(current: w.current, glassTint: glassTint)
              .animate().fadeIn(duration: 600.ms, delay: 400.ms)),
          const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
          _sliver(FeelIndexCard(current: w.current, glassTint: glassTint)
              .animate().fadeIn(duration: 600.ms, delay: 450.ms)),
          if (today != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
            _sliver(SunDaylightCard(today: today, glassTint: glassTint)
                .animate().fadeIn(duration: 600.ms, delay: 500.ms)),
          ],
          if (w.airQuality != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingM)),
            _sliver(AirQualityCard(airQuality: w.airQuality!, glassTint: glassTint)
                .animate().fadeIn(duration: 600.ms, delay: 550.ms)),
          ],
          if (settings.advancedViewEnabled) ...[
            const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spacingL)),
            _sliver(AdvancedDetailsCard(weather: w, formatTemp: settings.formatTemp, glassTint: glassTint)
                .animate().fadeIn(duration: 600.ms, delay: 600.ms)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  SliverAppBar _appBar(WeatherData w) => SliverAppBar(
    backgroundColor: Colors.transparent, elevation: 0, floating: true,
    leading: IconButton(
      icon: const Icon(Icons.location_on_outlined, size: 22),
      onPressed: () => CityListSheet.show(context),
    ),
    title: Text(w.location.name, style: DesignSystem.bodyText),
    centerTitle: true,
    actions: [
      IconButton(icon: const Icon(Icons.search_rounded, size: 22),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
      IconButton(icon: const Icon(Icons.more_horiz_rounded, size: 22),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ],
  );

  Widget _refreshPill() => Center(
    child: GlassPill(child: Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 14, height: 14,
        child: CircularProgressIndicator(strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.7)))),
      const SizedBox(width: 8),
      Text('Updating...', style: DesignSystem.caption),
    ])),
  );

  SliverToBoxAdapter _sliver(Widget w) => SliverToBoxAdapter(
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM), child: w),
  );

  Widget _error(String msg) => Center(child: Padding(
    padding: const EdgeInsets.all(DesignSystem.spacingXL),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      WeatherIconPainter.forCode(3, size: 64),
      const SizedBox(height: DesignSystem.spacingM),
      Text("Couldn't load weather", style: DesignSystem.conditionLabel),
      const SizedBox(height: DesignSystem.spacingS),
      Text(msg, style: DesignSystem.caption, textAlign: TextAlign.center),
      const SizedBox(height: DesignSystem.spacingL),
      GlassPill(onTap: _refresh, child: Text('Try again', style: DesignSystem.bodyText)),
    ]),
  ));

  Widget _noLocation() => Center(child: Padding(
    padding: const EdgeInsets.all(DesignSystem.spacingXL),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.location_off_rounded, size: 64, color: DesignSystem.textSecondary),
      const SizedBox(height: DesignSystem.spacingM),
      Text('No location selected', style: DesignSystem.conditionLabel),
      const SizedBox(height: DesignSystem.spacingS),
      Text('Add a city or enable location services', style: DesignSystem.caption, textAlign: TextAlign.center),
      const SizedBox(height: DesignSystem.spacingL),
      GlassPill(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Text('Add City', style: DesignSystem.bodyText),
      ),
    ]),
  ));
}

