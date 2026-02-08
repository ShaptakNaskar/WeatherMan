import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// 10-day forecast list widget
class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;

  const DailyForecastCard({
    super.key,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    // Find min and max temps for the bar visualization
    final allTemps = daily.expand((d) => [d.temperatureMax, d.temperatureMin]).toList();
    final globalMin = allTemps.reduce((a, b) => a < b ? a : b);
    final globalMax = allTemps.reduce((a, b) => a > b ? a : b);
    final tempRange = globalMax - globalMin;

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
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '10-DAY FORECAST',
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

          // Daily items
          ...daily.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isLast = index == daily.length - 1;
            
            return _DailyItem(
              forecast: day,
              globalMin: globalMin,
              tempRange: tempRange,
              settings: settings,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _DailyItem extends StatelessWidget {
  final DailyForecast forecast;
  final double globalMin;
  final double tempRange;
  final SettingsProvider settings;
  final bool showDivider;

  const _DailyItem({
    required this.forecast,
    required this.globalMin,
    required this.tempRange,
    required this.settings,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate positions for the temperature bar
    final lowPercent = tempRange > 0 ? (forecast.temperatureMin - globalMin) / tempRange : 0.0;
    final highPercent = tempRange > 0 ? (forecast.temperatureMax - globalMin) / tempRange : 1.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Day name
              SizedBox(
                width: 60,
                child: Text(
                  DateTimeUtils.formatDayName(forecast.date),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: DateTimeUtils.isToday(forecast.date)
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),

              // Weather icon
              SizedBox(
                width: 40,
                child: Icon(
                  WeatherUtils.getWeatherIcon(forecast.weatherCode),
                  size: 24,
                  color: WeatherUtils.getWeatherIconColor(forecast.weatherCode),
                ),
              ),

              // Precipitation probability
              SizedBox(
                width: 40,
                child: forecast.precipitationProbabilityMax > 0
                    ? Text(
                        '${forecast.precipitationProbabilityMax}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64B5F6),
                        ),
                      )
                    : null,
              ),

              // Low temp
              SizedBox(
                width: 40,
                child: Text(
                  settings.formatTempShort(forecast.temperatureMin),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(width: 12),

              // Temperature bar
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    final leftMargin = barWidth * lowPercent;
                    final barLength = barWidth * (highPercent - lowPercent);

                    return Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: leftMargin,
                            child: Container(
                              width: barLength.clamp(8.0, barWidth),
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF64B5F6),
                                    const Color(0xFFFFB74D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // High temp
              SizedBox(
                width: 40,
                child: Text(
                  settings.formatTempShort(forecast.temperatureMax),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: AppTheme.glassBorder,
              height: 1,
            ),
          ),
      ],
    );
  }
}
