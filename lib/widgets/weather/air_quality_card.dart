import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Large AQI number + category label + pollutant bar rows.
class AirQualityCard extends StatelessWidget {
  final AirQuality airQuality;
  final Color glassTint;

  const AirQualityCard({
    super.key,
    required this.airQuality,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final cat = airQuality.category;
    final catColor = Color(cat.color);

    return PrimaryGlassCard(
      glassTint: glassTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AIR QUALITY', style: DesignSystem.sectionHeader),
          const SizedBox(height: DesignSystem.spacingM),
          Row(
            children: [
              Text(
                '${airQuality.usAqi}',
                style: DesignSystem.tempLarge.copyWith(color: catColor),
              ),
              const SizedBox(width: DesignSystem.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.label, style: DesignSystem.conditionLabel),
                    const SizedBox(height: 2),
                    Text('US AQI', style: DesignSystem.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingL),
          _PollutantRow('PM2.5', airQuality.pm2_5, 75),
          const SizedBox(height: DesignSystem.spacingS),
          _PollutantRow('PM10', airQuality.pm10, 150),
          const SizedBox(height: DesignSystem.spacingS),
          _PollutantRow('O₃', airQuality.ozone, 180),
          const SizedBox(height: DesignSystem.spacingS),
          _PollutantRow('NO₂', airQuality.nitrogenDioxide, 200),
        ],
      ),
    );
  }
}

class _PollutantRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxRef; // WHO guideline-ish reference for bar scale

  const _PollutantRow(this.label, this.value, this.maxRef);

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxRef).clamp(0.0, 1.0);
    final barColor = Color.lerp(
      const Color(0xFF4CAF50),
      const Color(0xFFFF5252),
      fraction,
    )!;

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(label, style: DesignSystem.metricLabel),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            value.toStringAsFixed(1),
            style: DesignSystem.caption,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
