import 'package:flutter/material.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Weather details grid showing UV index, humidity, wind, etc.
class WeatherDetailsGrid extends StatelessWidget {
  final CurrentWeather current;
  final DailyForecast today;
  final AirQuality? airQuality;

  const WeatherDetailsGrid({
    super.key,
    required this.current,
    required this.today,
    this.airQuality,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 3 columns in landscape (wider), 2 in portrait
        final isWide = constraints.maxWidth > 600;
        final columns = isWide ? 3 : 2;
        final spacing = 12.0;
        final cardWidth = (constraints.maxWidth - 32 - (spacing * (columns - 1))) / columns;

        final cards = <Widget>[
          // UV Index
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.wb_sunny_outlined,
              title: 'UV INDEX',
              value: current.uvIndex.toStringAsFixed(0),
              subtitle: WeatherUtils.getUvDescription(current.uvIndex),
              valueColor: WeatherUtils.getUvColor(current.uvIndex),
            ),
          ),
          // Sunset
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.wb_twilight,
              title: 'SUNSET',
              value: DateTimeUtils.formatTime(today.sunset),
              subtitle: 'Sunrise: ${DateTimeUtils.formatTime(today.sunrise)}',
            ),
          ),
          // Wind
          SizedBox(
            width: cardWidth,
            child: _WindCard(
              speed: current.windSpeed,
              direction: current.windDirection,
              gusts: current.windGusts,
            ),
          ),
          // Feels Like
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.thermostat_outlined,
              title: 'FEELS LIKE',
              value: '${current.apparentTemperature.round()}°',
              subtitle: _getFeelsLikeDescription(current),
            ),
          ),
          // Humidity
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.water_drop_outlined,
              title: 'HUMIDITY',
              value: '${current.relativeHumidity}%',
              subtitle: _getHumidityDescription(current.relativeHumidity),
            ),
          ),
          // Rainfall
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.umbrella_outlined,
              title: 'RAINFALL',
              value: UnitConverter.formatPrecipitation(today.precipitationSum),
              subtitle: 'Expected today',
            ),
          ),
          // Pressure
          SizedBox(
            width: cardWidth,
            child: _PressureCard(pressure: current.pressure),
          ),
          // Cloud Cover
          SizedBox(
            width: cardWidth,
            child: _DetailCard(
              icon: Icons.cloud_outlined,
              title: 'CLOUD COVER',
              value: '${current.cloudCover}%',
              subtitle: _getCloudDescription(current.cloudCover),
            ),
          ),
          // Visibility
          SizedBox(
            width: cardWidth,
            child: _VisibilityCard(visibility: current.visibility),
          ),
          // AQI
          SizedBox(
            width: cardWidth,
            child: airQuality != null
                ? _AqiCard(airQuality: airQuality!)
                : _DetailCard(
                    icon: Icons.air_rounded,
                    title: 'AIR QUALITY',
                    value: '--',
                    subtitle: 'Data unavailable',
                  ),
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards,
          ),
        );
      },
    );
  }

  String _getFeelsLikeDescription(CurrentWeather current) {
    final diff = current.apparentTemperature - current.temperature;
    if (diff.abs() < 2) return 'Similar to actual temperature';
    if (diff > 0) return 'Humidity is making it feel warmer';
    return 'Wind is making it feel cooler';
  }

  String _getHumidityDescription(int humidity) {
    if (humidity < 30) return 'Dry air';
    if (humidity < 50) return 'Comfortable';
    if (humidity < 70) return 'Slightly humid';
    return 'High humidity';
  }

  String _getCloudDescription(int cloudCover) {
    if (cloudCover < 20) return 'Clear sky';
    if (cloudCover < 50) return 'Partly cloudy';
    if (cloudCover < 80) return 'Mostly cloudy';
    return 'Overcast';
  }
}

/// Generic detail card
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return LightGlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Value
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),

            if (subtitle != null) ...[
              const Spacer(),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wind card with compass direction
class _WindCard extends StatelessWidget {
  final double speed;
  final int direction;
  final double gusts;

  const _WindCard({
    required this.speed,
    required this.direction,
    required this.gusts,
  });

  @override
  Widget build(BuildContext context) {
    return LightGlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(Icons.air, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'WIND',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Wind speed and direction
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${speed.round()}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'km/h',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                // Compass arrow
                Transform.rotate(
                  angle: direction * 3.14159 / 180,
                  child: Icon(
                    Icons.navigation_rounded,
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              '${WeatherUtils.getWindDirection(direction)} · Gusts ${gusts.round()} km/h',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pressure card with gauge
class _PressureCard extends StatelessWidget {
  final double pressure;

  const _PressureCard({required this.pressure});

  @override
  Widget build(BuildContext context) {
    // Normal range is roughly 980-1050 hPa
    String description;
    if (pressure < 1000) {
      description = 'Low pressure';
    } else if (pressure < 1020) {
      description = 'Normal';
    } else {
      description = 'High pressure';
    }

    return LightGlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(Icons.speed_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'PRESSURE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pressure value
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pressure.round().toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'hPa',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Visibility card
class _VisibilityCard extends StatelessWidget {
  final double visibility;

  const _VisibilityCard({required this.visibility});

  @override
  Widget build(BuildContext context) {
    String description;
    if (visibility >= 10000) {
      description = 'Excellent';
    } else if (visibility >= 5000) {
      description = 'Good';
    } else if (visibility >= 1000) {
      description = 'Moderate';
    } else {
      description = 'Poor';
    }

    String value;
    if (visibility >= 10000) {
      value = '${(visibility / 1000).round()} km';
    } else if (visibility >= 1000) {
      value = '${(visibility / 1000).toStringAsFixed(1)} km';
    } else {
      value = '${visibility.round()} m';
    }

    return LightGlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(Icons.visibility_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'VISIBILITY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Visibility value
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const Spacer(),

            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Air Quality Index card
class _AqiCard extends StatelessWidget {
  final AirQuality airQuality;

  const _AqiCard({required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final category = airQuality.category;

    return LightGlassCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(Icons.air_rounded, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'AIR QUALITY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // AQI value with color indicator
            Row(
              children: [
                Text(
                  '${airQuality.usAqi}',
                  style: Theme.of(context).textTheme.headlineMedium, // Monochromatic (White)
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(category.color),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              category.label.length > 15 
                  ? category.label.split(' ').first 
                  : category.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary, // Monochromatic
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
