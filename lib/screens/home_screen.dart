import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/search_screen.dart';
import 'package:weatherman/screens/settings_screen.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/common/shimmer_loading.dart';
import 'package:weatherman/widgets/weather/current_weather.dart';
import 'package:weatherman/widgets/weather/daily_forecast.dart';
import 'package:weatherman/widgets/weather/hourly_forecast.dart';
import 'package:weatherman/widgets/weather/weather_details.dart';
import 'package:weatherman/widgets/weather/advanced_details.dart';

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

    // Initialize providers
    await locationProvider.init();

    // Try to get current location
    await locationProvider.fetchCurrentLocation();

    // Fetch weather for selected location
    final selectedLocation = locationProvider.selectedLocation;
    if (selectedLocation != null) {
      await weatherProvider.fetchWeather(selectedLocation);
    }
  }

  Future<void> _refreshWeather() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();

    final selectedLocation = locationProvider.selectedLocation;
    if (selectedLocation != null) {
      await weatherProvider.refreshWeather(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Consumer3<LocationProvider, WeatherProvider, SettingsProvider>(
      builder: (context, locationProvider, weatherProvider, settings, _) {
        final selectedLocation = locationProvider.selectedLocation;
        final weather = selectedLocation != null
            ? weatherProvider.getWeather(selectedLocation)
            : null;

        // Determine background based on weather
        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;

        return DynamicBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: _buildBody(
                locationProvider,
                weatherProvider,
                weather,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    LocationProvider locationProvider,
    WeatherProvider weatherProvider,
    WeatherData? weather,
  ) {
    final selectedLocation = locationProvider.selectedLocation;

    // Loading state
    if (weatherProvider.isLoading && weather == null) {
      return const WeatherLoadingShimmer();
    }

    // Error state with no cached data
    if (weatherProvider.state == WeatherState.error && weather == null) {
      return _buildErrorState(weatherProvider.error ?? 'Unknown error');
    }

    // No location selected
    if (selectedLocation == null) {
      return _buildNoLocationState();
    }

    // Weather data available
    if (weather != null) {
      return _buildWeatherContent(weather, weatherProvider.isRefreshing);
    }

    // Fetch weather if not already loading
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
          // Enable immersive fullscreen mode in landscape
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          );
          return _buildLandscapeContent(weather, today, isRefreshing);
        }
        // Restore normal UI in portrait
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values,
        );
        return _buildPortraitContent(weather, today, isRefreshing);
      },
    );
  }

  Widget _buildPortraitContent(WeatherData weather, DailyForecast? today, bool isRefreshing) {
    return RefreshIndicator(
      onRefresh: _refreshWeather,
      color: AppTheme.textPrimary,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // App bar with actions
          _buildAppBar(),

          // Current weather display
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CurrentWeatherDisplay(
                weather: weather.current,
                locationName: weather.location.name,
                temperatureMax: today?.temperatureMax ?? weather.current.temperature,
                temperatureMin: today?.temperatureMin ?? weather.current.temperature,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOut),
          ),

          // Refresh indicator
          if (isRefreshing) _buildRefreshingIndicator(),

          // Last updated
          _buildLastUpdated(weather),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Forecasts and details
          ..._buildForecastSlivers(weather, today),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(WeatherData weather, DailyForecast? today, bool isRefreshing) {
    return Row(
      children: [
        // Left panel - Static weather display
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Column(
            children: [
              // App bar actions
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
              // Current weather display
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
                          temperatureMax: today?.temperatureMax ?? weather.current.temperature,
                          temperatureMin: today?.temperatureMin ?? weather.current.temperature,
                        ),
                        const SizedBox(height: 16),
                        if (isRefreshing)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        Text(
                          'Updated ${DateTimeUtils.formatRelativeTime(weather.fetchedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Container(
          width: 1,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        // Right panel - Scrollable forecasts
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshWeather,
            color: AppTheme.textPrimary,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLastUpdated(WeatherData weather) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            'Updated ${DateTimeUtils.formatRelativeTime(weather.fetchedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
    );
  }

  List<Widget> _buildForecastSlivers(WeatherData weather, DailyForecast? today) {
    return [
      // Hourly forecast
      SliverToBoxAdapter(
        child: HourlyForecastCard(hourly: weather.hourly)
            .animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.03, end: 0, duration: 500.ms, curve: Curves.easeOut),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Daily forecast
      SliverToBoxAdapter(
        child: DailyForecastCard(daily: weather.daily)
            .animate().fadeIn(duration: 600.ms, delay: 350.ms).slideY(begin: 0.03, end: 0, duration: 500.ms, curve: Curves.easeOut),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Weather details
      if (today != null)
        SliverToBoxAdapter(
          child: WeatherDetailsGrid(
            current: weather.current,
            today: today,
            airQuality: weather.airQuality,
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.03, end: 0, duration: 500.ms, curve: Curves.easeOut),
        ),

      // Advanced details (if enabled in settings)
      Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.advancedViewEnabled) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverToBoxAdapter(
            child: Padding(
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
            ).animate().fadeIn(duration: 600.ms, delay: 650.ms).slideY(begin: 0.03, end: 0, duration: 500.ms, curve: Curves.easeOut),
          );
        },
      ),
    ];
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No location selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a city or enable location services to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openSearch(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add City'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openCityList() {
    // Show bottom sheet with saved cities
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
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locationProvider, weatherProvider, _) {
        final allLocations = locationProvider.allLocations;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: Colors.white.withValues(alpha: 0.3),
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
                      style: Theme.of(context).textTheme.titleLarge,
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allLocations.length,
                        itemBuilder: (context, index) {
                          final location = allLocations[index];
                          final weather = weatherProvider.getWeather(location);
                          final isSelected = location == locationProvider.selectedLocation;

                          return ListTile(
                            leading: location.isCurrentLocation
                                ? const Icon(Icons.my_location_rounded)
                                : const Icon(Icons.location_city_rounded),
                            title: Text(location.name),
                            subtitle: weather != null
                                ? Text('${weather.current.temperature.round()}°')
                                : null,
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: () {
                              locationProvider.selectLocation(location);
                              weatherProvider.fetchWeather(location);
                              Navigator.pop(context);
                            },
                            onLongPress: () {
                              if (!location.isCurrentLocation) {
                                _showDeleteDialog(context, locationProvider, location);
                              }
                            },
                          );
                        },
                      ),
              ),

              // Safe area padding
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
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Location'),
        content: Text('Remove ${location.name} from saved locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              locationProvider.removeLocation(location);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
