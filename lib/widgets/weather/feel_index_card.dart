import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Synthesized comfort score (0–100) with circular gauge.
class FeelIndexCard extends StatelessWidget {
  final CurrentWeather current;
  final Color glassTint;

  const FeelIndexCard({
    super.key,
    required this.current,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final score = _computeScore();
    final desc = _descriptor(score);
    final factor = _dominantFactor();

    return PrimaryGlassCard(
      glassTint: glassTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMFORT INDEX', style: DesignSystem.sectionHeader),
          const SizedBox(height: DesignSystem.spacingM),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _GaugePainter(score / 100),
                child: Center(
                  child: Text('${score.round()}', style: DesignSystem.tempLarge),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Center(child: Text(desc, style: DesignSystem.conditionLabel)),
          const SizedBox(height: DesignSystem.spacingXS),
          Center(child: Text(factor, style: DesignSystem.caption)),
        ],
      ),
    );
  }

  double _computeScore() {
    // Humidity penalty (optimal 40-60)
    double hPenalty = 0;
    if (current.relativeHumidity > 60) {
      hPenalty = (current.relativeHumidity - 60) * 0.5;
    } else if (current.relativeHumidity < 30) {
      hPenalty = (30 - current.relativeHumidity) * 0.4;
    }
    // Apparent temperature penalty (optimal 18-26)
    double tPenalty = 0;
    if (current.apparentTemperature > 26) {
      tPenalty = (current.apparentTemperature - 26) * 2;
    } else if (current.apparentTemperature < 18) {
      tPenalty = (18 - current.apparentTemperature) * 1.5;
    }
    // UV penalty
    double uvPenalty = (current.uvIndex > 6) ? (current.uvIndex - 6) * 3 : 0;
    // Wind penalty
    double wPenalty = (current.windSpeed > 30) ? (current.windSpeed - 30) * 0.4 : 0;

    return (100 - hPenalty - tPenalty - uvPenalty - wPenalty).clamp(0, 100);
  }

  String _descriptor(double s) {
    if (s >= 80) return 'Perfect afternoon';
    if (s >= 60) return 'Pleasant conditions';
    if (s >= 40) return 'Somewhat uncomfortable';
    if (s >= 20) return 'Muggy and warm';
    return 'Stay indoors';
  }

  String _dominantFactor() {
    final h = current.relativeHumidity;
    final t = current.apparentTemperature;
    final u = current.uvIndex;
    if (h > 75) return 'High humidity is the main discomfort factor';
    if (t > 35) return 'Extreme heat is the main discomfort factor';
    if (t < 5) return 'Cold temperatures are the main factor';
    if (u > 8) return 'Very high UV level dominates';
    return 'Conditions are generally balanced';
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction; // 0–1
  _GaugePainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: r);

    // Track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawArc(rect, 0.7 * pi, 1.6 * pi, false, track);

    // Fill with color gradient approximation
    final color = Color.lerp(
      const Color(0xFF4FC3F7),
      const Color(0xFFFF7043),
      fraction,
    )!;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, 0.7 * pi, 1.6 * pi * fraction, false, fill);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.fraction != fraction;
}
