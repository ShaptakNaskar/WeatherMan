import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Mini bar chart of hourly precipitation probability (next 24 h).
/// Only rendered if any hour has prob > 10%.
class PrecipitationTimeline extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final Color glassTint;

  const PrecipitationTimeline({
    super.key,
    required this.hourly,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  /// Whether this card should be shown.
  static bool shouldShow(List<HourlyForecast> hourly) {
    final next24 = _next24(hourly);
    return next24.any((h) => h.precipitationProbability > 10);
  }

  static List<HourlyForecast> _next24(List<HourlyForecast> hourly) {
    final now = DateTime.now();
    return hourly.where((h) => h.time.isAfter(now)).take(24).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _next24(hourly);
    if (items.isEmpty) return const SizedBox.shrink();

    // Find peak
    int peakIdx = 0;
    for (int i = 1; i < items.length; i++) {
      if (items[i].precipitationProbability >
          items[peakIdx].precipitationProbability) {
        peakIdx = i;
      }
    }
    final peak = items[peakIdx];
    final peakLabel =
        '${peak.precipitationProbability}% at ${DateFormat('ha').format(peak.time).toLowerCase()}';

    // Now index for indicator
    final nowHour = DateTime.now().hour;
    int nowIdx = 0;
    for (int i = 0; i < items.length; i++) {
      if (items[i].time.hour == nowHour) {
        nowIdx = i;
        break;
      }
    }

    return PrimaryGlassCard(
      glassTint: glassTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PRECIPITATION', style: DesignSystem.sectionHeader),
              const Spacer(),
              Text(peakLabel, style: DesignSystem.caption),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _BarPainter(
                probabilities: items
                    .map((e) => e.precipitationProbability.toDouble())
                    .toList(),
                nowIndex: nowIdx,
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Now', style: DesignSystem.caption),
              Text('+24h', style: DesignSystem.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> probabilities;
  final int nowIndex;
  _BarPainter({required this.probabilities, required this.nowIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (probabilities.isEmpty) return;
    final count = probabilities.length;
    final barW = (size.width - (count - 1) * 1.5) / count;

    for (int i = 0; i < count; i++) {
      final p = probabilities[i] / 100;
      final h = (size.height * p).clamp(2.0, size.height);
      final x = i * (barW + 1.5);
      final y = size.height - h;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15 + p * 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // Now indicator
    if (nowIndex < count) {
      final nx = nowIndex * (barW + 1.5) + barW / 2;
      final line = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(nx, 0), Offset(nx, size.height), line);
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}
