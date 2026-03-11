import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Sun path arc, daylight & sunshine stats, golden/blue hour rows.
class SunDaylightCard extends StatelessWidget {
  final DailyForecast today;
  final Color glassTint;

  const SunDaylightCard({
    super.key,
    required this.today,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final now = DateTime.now();
    final goldenAm = today.sunrise;
    final goldenPm = today.sunset.subtract(const Duration(minutes: 30));
    final blueAm = today.sunrise.subtract(const Duration(minutes: 25));
    final bluePm = today.sunset.add(const Duration(minutes: 5));

    return PrimaryGlassCard(
      glassTint: glassTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUN & DAYLIGHT', style: DesignSystem.sectionHeader),
          const SizedBox(height: DesignSystem.spacingM),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _SunArcPainter(
                sunrise: today.sunrise,
                sunset: today.sunset,
                now: now,
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoCol('Sunrise', timeFmt.format(today.sunrise)),
              _InfoCol('Sunset', timeFmt.format(today.sunset)),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoCol('Daylight', today.daylightDurationFormatted),
              _InfoCol('Sunshine', today.sunshineDurationFormatted),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          _TimeRow(Icons.wb_sunny_outlined, 'Golden hour',
              timeFmt.format(goldenAm), timeFmt.format(goldenPm)),
          const SizedBox(height: DesignSystem.spacingXS),
          _TimeRow(Icons.nights_stay_outlined, 'Blue hour',
              timeFmt.format(blueAm), timeFmt.format(bluePm)),
        ],
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCol(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DesignSystem.metricLabel),
        const SizedBox(height: 2),
        Text(value, style: DesignSystem.metricValue),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String am;
  final String pm;
  const _TimeRow(this.icon, this.label, this.am, this.pm);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: DesignSystem.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: DesignSystem.caption),
        const Spacer(),
        Text('$am  /  $pm', style: DesignSystem.caption),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;
  _SunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final rx = size.width / 2 - 16;
    final ry = size.height - 20;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );

    // Dashed arc track (upper half)
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawArc(rect, pi, pi, false, track);

    // Horizon line
    final horizon = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(16, cy), Offset(size.width - 16, cy), horizon);

    // Sun position
    final total = sunset.difference(sunrise).inSeconds.toDouble();
    if (total <= 0) return;
    final elapsed = now.difference(sunrise).inSeconds.toDouble();
    final fraction = (elapsed / total).clamp(0.0, 1.0);
    final angle = pi + fraction * pi;
    final sx = cx + rx * cos(angle);
    final sy = cy + ry * sin(angle);

    // Lit arc
    final lit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFC107).withValues(alpha: 0.6);
    canvas.drawArc(rect, pi, fraction * pi, false, lit);

    // Sun dot + glow
    final glow = Paint()
      ..color = const Color(0xFFFFC107).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(sx, sy), 8, glow);
    final dot = Paint()..color = const Color(0xFFFFC107);
    canvas.drawCircle(Offset(sx, sy), 4, dot);
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => true;
}
