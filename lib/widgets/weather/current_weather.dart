import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/cyberpunk/glitch_effects.dart';

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
    
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // Location name with glitch
        GlitchText(
          text: locationName.toUpperCase(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 3,
            color: CyberpunkTheme.neonCyan,
          ),
          textAlign: TextAlign.center,
          glitchIntensity: 0.3,
        ),

        const SizedBox(height: 8),

        // Large temperature display
        // Large temperature display
        // Stack used to center the number while hanging the degree symbol
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              (){
                final temp = settings.temperatureUnit == TemperatureUnit.celsius 
                    ? weather.temperature 
                    : UnitConverter.celsiusToFahrenheit(weather.temperature);
                return '${temp.round()}';
              }(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 96,
                fontWeight: FontWeight.w100,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            Positioned(
              right: -30,
              top: 0,
              child: Text(
                '°',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 96,
                  fontWeight: FontWeight.w100,
                  height: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Weather description
        Text(
          WeatherUtils.getWeatherDescription(weather.weatherCode).toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CyberpunkTheme.textSecondary,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
            letterSpacing: 2,
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
                color: CyberpunkTheme.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'L:${settings.formatTempShort(temperatureMin)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CyberpunkTheme.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
      ),
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
                      color: CyberpunkTheme.textSecondary,
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
                  color: CyberpunkTheme.textSecondary,
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
