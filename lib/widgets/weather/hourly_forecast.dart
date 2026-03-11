import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';
import 'package:weatherman/widgets/weather/weather_icon_painter.dart';

/// Horizontal scrolling hourly forecast inside a PrimaryGlassCard.
class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final Color glassTint;

  const HourlyForecastCard({
    super.key,
    required this.hourly,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filtered = hourly
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    return PrimaryGlassCard(
      glassTint: glassTint,
      padding: const EdgeInsets.only(top: DesignSystem.spacingM, bottom: DesignSystem.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Text('HOURLY FORECAST', style: DesignSystem.sectionHeader),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(width: DesignSystem.spacingS),
              itemBuilder: (context, i) {
                final h = filtered[i];
                final isNow = i == 0;
                return GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: GlassPill(
                    glassTint: glassTint,
                    selected: isNow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingS + 2,
                      vertical: DesignSystem.spacingS,
                    ),
                    child: _HourlyContent(forecast: h, isNow: isNow),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyContent extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isNow;
  const _HourlyContent({required this.forecast, required this.isNow});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateTimeUtils.formatHourOrNow(forecast.time),
          style: DesignSystem.caption.copyWith(
            color: isNow ? DesignSystem.textPrimary : DesignSystem.textSecondary,
            fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        WeatherIconPainter.forCode(
          forecast.weatherCode,
          isDay: forecast.isDay,
          size: DesignSystem.iconHourly,
        ),
        const SizedBox(height: 4),
        if (forecast.precipitationProbability > 5)
          Text(
            '${forecast.precipitationProbability}%',
            style: DesignSystem.caption.copyWith(
              fontSize: 10,
              color: Colors.lightBlueAccent.withValues(alpha: 0.9),
            ),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 2),
        Text(
          settings.formatTempShort(forecast.temperature),
          style: DesignSystem.bodyText.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
