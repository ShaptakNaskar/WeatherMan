import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// 2×3 detail grid (Feels Like, Humidity, Wind, Pressure, Visibility, UV).
class DetailGrid extends StatelessWidget {
  final CurrentWeather current;
  final Color glassTint;

  const DetailGrid({
    super.key,
    required this.current,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final tiles = [
      _Tile(Icons.thermostat_outlined, 'FEELS LIKE',
          settings.formatTempShort(current.apparentTemperature), _feelsDesc()),
      _Tile(Icons.water_drop_outlined, 'HUMIDITY',
          '${current.relativeHumidity}%', 'Dew point ${current.dewPoint.round()}°'),
      _Tile(Icons.air, 'WIND',
          '${current.windSpeed.round()} km/h',
          '${WeatherUtils.getWindDirection(current.windDirection)} · Gusts ${current.windGusts.round()}'),
      _Tile(Icons.speed_outlined, 'PRESSURE',
          '${current.pressure.round()} hPa', _pressureDesc()),
      _Tile(Icons.visibility_outlined, 'VISIBILITY',
          '${(current.visibility / 1000).toStringAsFixed(1)} km', _visDesc()),
      _Tile(Icons.wb_sunny_outlined, 'UV INDEX',
          current.uvIndex.toStringAsFixed(0), WeatherUtils.getUvDescription(current.uvIndex)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles.asMap().entries.map((e) {
        final t = e.value;
        final idx = e.key;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 32 - 12) / 2,
          child: SecondaryGlassCard(
            glassTint: glassTint,
            grainSeed: 100 + idx,
            onTap: () => HapticFeedback.lightImpact(),
            child: _TileContent(tile: t, isUv: idx == 5, uvValue: current.uvIndex),
          ),
        );
      }).toList(),
    );
  }

  String _feelsDesc() {
    final diff = current.apparentTemperature - current.temperature;
    if (diff.abs() < 2) return 'Comfortable';
    return diff > 0 ? 'Humid' : 'Cold';
  }

  String _pressureDesc() {
    final diff = current.pressure - current.surfacePressure;
    if (diff.abs() < 2) return 'Steady';
    return diff > 0 ? 'Rising' : 'Falling';
  }

  String _visDesc() {
    final km = current.visibility / 1000;
    if (km > 10) return 'Clear';
    if (km > 4) return 'Hazy';
    return 'Poor';
  }
}

class _Tile {
  final IconData icon;
  final String label, value, sub;
  const _Tile(this.icon, this.label, this.value, this.sub);
}

class _TileContent extends StatelessWidget {
  final _Tile tile;
  final bool isUv;
  final double uvValue;
  const _TileContent({required this.tile, this.isUv = false, this.uvValue = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(tile.icon, size: 16, color: DesignSystem.textSecondary),
            const SizedBox(width: 6),
            Text(tile.label, style: DesignSystem.metricLabel),
          ]),
          const SizedBox(height: 8),
          Text(tile.value, style: DesignSystem.metricValue),
          const Spacer(),
          if (isUv) _UvArc(value: uvValue) else Text(tile.sub, style: DesignSystem.caption),
        ],
      ),
    );
  }
}

/// Mini UV arc indicator.
class _UvArc extends StatelessWidget {
  final double value;
  const _UvArc({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 20,
          child: CustomPaint(painter: _UvArcPainter(value)),
        ),
        const SizedBox(width: 6),
        Text(WeatherUtils.getUvDescription(value), style: DesignSystem.caption),
      ],
    );
  }
}

class _UvArcPainter extends CustomPainter {
  final double value;
  _UvArcPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    // Track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawArc(rect, pi, pi, false, track);
    // Fill
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.8);
    final sweep = (value.clamp(0, 11) / 11) * pi;
    canvas.drawArc(rect, pi, sweep, false, fill);
  }

  @override
  bool shouldRepaint(_UvArcPainter old) => old.value != value;
}
