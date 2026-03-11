import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/date_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';
import 'package:weatherman/widgets/weather/weather_icon_painter.dart';

/// 10-day forecast list inside a PrimaryGlassCard.
class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;
  final Color glassTint;

  const DailyForecastCard({
    super.key,
    required this.daily,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final allTemps = daily.expand((d) => [d.temperatureMax, d.temperatureMin]);
    final gMin = allTemps.reduce((a, b) => a < b ? a : b);
    final gMax = allTemps.reduce((a, b) => a > b ? a : b);
    final range = gMax - gMin;

    return PrimaryGlassCard(
      glassTint: glassTint,
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Text('10-DAY FORECAST', style: DesignSystem.sectionHeader),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          ...daily.map((d) => _DailyRow(
                forecast: d,
                gMin: gMin,
                range: range,
                settings: settings,
                glassTint: glassTint,
              )),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyForecast forecast;
  final double gMin;
  final double range;
  final SettingsProvider settings;
  final Color glassTint;

  const _DailyRow({
    required this.forecast,
    required this.gMin,
    required this.range,
    required this.settings,
    required this.glassTint,
  });

  @override
  Widget build(BuildContext context) {
    final lowPct = range > 0 ? (forecast.temperatureMin - gMin) / range : 0.0;
    final highPct = range > 0 ? (forecast.temperatureMax - gMin) / range : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingM,
        vertical: 6,
      ),
      child: Row(
        children: [
          // Day
          SizedBox(
            width: 78,
            child: Text(
              DateTimeUtils.formatDayName(forecast.date),
              style: DesignSystem.bodyText.copyWith(
                fontWeight: DateTimeUtils.isToday(forecast.date)
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          // Icon
          SizedBox(
            width: 28,
            child: WeatherIconPainter.forCode(
              forecast.weatherCode,
              size: DesignSystem.iconDetail,
            ),
          ),
          const SizedBox(width: 4),
          // Precip
          SizedBox(
            width: 36,
            child: forecast.precipitationProbabilityMax > 5
                ? Text(
                    '${forecast.precipitationProbabilityMax}%',
                    style: DesignSystem.caption.copyWith(
                      color: Colors.lightBlueAccent.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Min temp
          SizedBox(
            width: 36,
            child: Text(
              settings.formatTempShort(forecast.temperatureMin),
              style: DesignSystem.bodyText.copyWith(color: DesignSystem.textTertiary),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          // Gradient bar
          Expanded(child: _TempBar(lowPct: lowPct, highPct: highPct)),
          const SizedBox(width: 8),
          // Max temp
          SizedBox(
            width: 36,
            child: Text(
              settings.formatTempShort(forecast.temperatureMax),
              style: DesignSystem.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  final double lowPct, highPct;
  const _TempBar({required this.lowPct, required this.highPct});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      final left = w * lowPct;
      final bar = (w * (highPct - lowPct)).clamp(6.0, w);
      return Container(
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Stack(children: [
          Positioned(
            left: left,
            child: Container(
              width: bar,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ]),
      );
    });
  }
}
