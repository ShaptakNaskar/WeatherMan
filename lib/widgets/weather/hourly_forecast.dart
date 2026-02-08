import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Horizontal scrolling hourly forecast widget
class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const HourlyForecastCard({
    super.key,
    required this.hourly,
  });

  @override
  Widget build(BuildContext context) {
    // Get next 24 hours starting from current hour
    final now = DateTime.now();
    final filteredHourly = hourly.where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1)))).take(24).toList();

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'HOURLY FORECAST',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          
          // Divider
          Divider(
            color: AppTheme.glassBorder,
            height: 1,
          ),

          const SizedBox(height: 12),

          // Scrollable hourly items
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredHourly.length,
              itemBuilder: (context, index) {
                return _HourlyItem(
                  forecast: filteredHourly[index],
                  isFirst: index == 0,
                )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: index * 50),
                    )
                    .slideX(begin: 0.2, end: 0);
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _HourlyItem extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isFirst;

  const _HourlyItem({
    required this.forecast,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          Text(
            DateTimeUtils.formatHourOrNow(forecast.time),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isFirst ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
            ),
          ),

          // Icon
          Icon(
            WeatherUtils.getWeatherIcon(forecast.weatherCode, isDay: forecast.isDay),
            size: 28,
            color: WeatherUtils.getWeatherIconColor(forecast.weatherCode, isDay: forecast.isDay),
          ),

          // Precipitation probability
          if (forecast.precipitationProbability > 0)
            Text(
              '${forecast.precipitationProbability}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64B5F6),
                fontWeight: FontWeight.w500,
              ),
            )
          else
            const SizedBox(height: 14),

          // Temperature
          Text(
            settings.formatTempShort(forecast.temperature),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
