import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Advanced weather details — categorized sections in glass cards.
class AdvancedDetailsCard extends StatelessWidget {
  final WeatherData weather;
  final String Function(double, {bool showUnit}) formatTemp;
  final Color glassTint;

  const AdvancedDetailsCard({
    super.key,
    required this.weather,
    required this.formatTemp,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final c = weather.current;
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;
    final timeFmt = DateFormat('h:mm a');

    return Column(
      children: [
        _Section(glassTint: glassTint, icon: Icons.cloud_outlined, title: 'ATMOSPHERE', items: [
          _Item('Dew Point', formatTemp(c.dewPoint)),
          _Item('Visibility', _fmtVis(c.visibility)),
          _Item('Cloud Cover', '${c.cloudCover}%'),
          _Item('Pressure', '${c.pressure.round()} hPa'),
          if (c.surfacePressure > 0) _Item('Surface', '${c.surfacePressure.round()} hPa'),
        ]),
        const SizedBox(height: DesignSystem.spacingM),
        _Section(glassTint: glassTint, icon: Icons.air_rounded, title: 'WIND', items: [
          _Item('Speed', '${c.windSpeed.round()} km/h'),
          _Item('Gusts', '${c.windGusts.round()} km/h'),
          _Item('Direction', WeatherUtils.getWindDirection(c.windDirection)),
          if (today != null && today.windGustsMax > 0)
            _Item('Max Gusts', '${today.windGustsMax.round()} km/h'),
        ]),
        const SizedBox(height: DesignSystem.spacingM),
        _Section(glassTint: glassTint, icon: Icons.water_drop_outlined, title: 'PRECIPITATION', items: [
          if (c.rain > 0) _Item('Rain', '${c.rain.toStringAsFixed(1)} mm'),
          if (c.snowfall > 0) _Item('Snow', '${c.snowfall.toStringAsFixed(1)} cm'),
          if (today != null) ...[
            if (today.rainSum > 0) _Item('Rain Today', '${today.rainSum.toStringAsFixed(1)} mm'),
            if (today.snowfallSum > 0) _Item('Snow Today', '${today.snowfallSum.toStringAsFixed(1)} cm'),
            _Item('Chance', '${today.precipitationProbabilityMax}%'),
          ],
        ]),
        if (today != null) ...[
          const SizedBox(height: DesignSystem.spacingM),
          _Section(glassTint: glassTint, icon: Icons.wb_sunny_outlined, title: 'SUN & DAYLIGHT', items: [
            _Item('Sunrise', timeFmt.format(today.sunrise)),
            _Item('Sunset', timeFmt.format(today.sunset)),
            if (today.daylightDuration > 0) _Item('Daylight', today.daylightDurationFormatted),
            if (today.sunshineDuration > 0) _Item('Sunshine', today.sunshineDurationFormatted),
          ]),
        ],
        const SizedBox(height: DesignSystem.spacingM),
        _Section(glassTint: glassTint, icon: Icons.wb_twilight_rounded, title: 'UV & RADIATION', items: [
          _Item('Current UV', c.uvIndex.toStringAsFixed(1)),
          _Item('Level', WeatherUtils.getUvDescription(c.uvIndex)),
          if (today != null && today.uvIndexMax > 0)
            _Item('Max Today', today.uvIndexMax.toStringAsFixed(1)),
        ]),
      ],
    );
  }

  String _fmtVis(double m) {
    if (m >= 10000) return '${(m / 1000).round()} km';
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
    return '${m.round()} m';
  }
}

class _Item {
  final String label;
  final String value;
  _Item(this.label, this.value);
}

class _Section extends StatelessWidget {
  final Color glassTint;
  final IconData icon;
  final String title;
  final List<_Item> items;

  const _Section({
    required this.glassTint,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final valid = items.where((i) => i.value.isNotEmpty).toList();
    if (valid.isEmpty) return const SizedBox.shrink();

    return SecondaryGlassCard(
      glassTint: glassTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: DesignSystem.textSecondary),
            const SizedBox(width: 6),
            Text(title, style: DesignSystem.sectionHeader),
          ]),
          const SizedBox(height: DesignSystem.spacingS),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: valid.map((i) => SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i.label, style: DesignSystem.metricLabel),
                  const SizedBox(height: 2),
                  Text(i.value, style: DesignSystem.bodyText),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
