import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Main current weather display widget
class CurrentWeatherDisplay extends StatelessWidget {
  final CurrentWeather weather;
  final String locationName;
  final double temperatureMax;
  final double temperatureMin;

  const CurrentWeatherDisplay({
    super.key,
    required this.weather,
    required this.locationName,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Location name
        Text(
          locationName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Large temperature display
        Text(
          settings.formatTempShort(weather.temperature),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 96,
            fontWeight: FontWeight.w100,
            height: 1,
          ),
        ),

        const SizedBox(height: 4),

        // Weather description
        Text(
          WeatherUtils.getWeatherDescription(weather.weatherCode),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 8),

        // High/Low temperature
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'H:${settings.formatTempShort(temperatureMax)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'L:${settings.formatTempShort(temperatureMin)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact current weather for list views
class CompactWeatherDisplay extends StatelessWidget {
  final CurrentWeather weather;
  final String locationName;
  final bool isCurrentLocation;

  const CompactWeatherDisplay({
    super.key,
    required this.weather,
    required this.locationName,
    this.isCurrentLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isCurrentLocation) ...[
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      locationName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                WeatherUtils.getWeatherDescription(weather.weatherCode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              WeatherUtils.getWeatherIcon(weather.weatherCode, isDay: weather.isDay),
              size: 32,
              color: WeatherUtils.getWeatherIconColor(weather.weatherCode, isDay: weather.isDay),
            ),
            const SizedBox(width: 12),
            Text(
              settings.formatTempShort(weather.temperature),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
