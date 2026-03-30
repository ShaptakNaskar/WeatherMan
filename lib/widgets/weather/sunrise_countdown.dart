import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// Sunrise/sunset countdown widget
class SunriseSunsetCard extends StatefulWidget {
  final DailyForecast today;

  const SunriseSunsetCard({super.key, required this.today});

  @override
  State<SunriseSunsetCard> createState() => _SunriseSunsetCardState();
}

class _SunriseSunsetCardState extends State<SunriseSunsetCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final now = DateTime.now();
    final sunrise = widget.today.sunrise;
    final sunset = widget.today.sunset;

    // Determine what to show
    final bool beforeSunrise = now.isBefore(sunrise);
    final bool beforeSunset = now.isBefore(sunset);
    final bool isDayTime = !beforeSunrise && beforeSunset;

    String label;
    String countdown;
    IconData icon;
    Color iconColor;

    if (beforeSunrise) {
      final diff = sunrise.difference(now);
      label = 'Sunrise';
      countdown = _formatDuration(diff);
      icon = Icons.wb_sunny_rounded;
      iconColor = const Color(0xFFFFB74D);
    } else if (isDayTime) {
      final diff = sunset.difference(now);
      label = 'Sunset';
      countdown = _formatDuration(diff);
      icon = Icons.wb_twilight;
      iconColor = const Color(0xFFFF8A65);
      // Golden hour: last ~45 min before sunset
      if (diff.inMinutes <= 45) {
        label = 'Golden hour';
        iconColor = const Color(0xFFFFD54F);
      }
    } else {
      // After sunset — show tomorrow's sunrise if available
      label = 'Sunset passed';
      countdown = _formatTime(sunset);
      icon = Icons.nightlight_round;
      iconColor = t.textSecondary;
    }

    // Daylight progress
    final totalDaylight = sunset.difference(sunrise).inMinutes;
    final elapsed = now.difference(sunrise).inMinutes;
    final progress = totalDaylight > 0
        ? (elapsed / totalDaylight).clamp(0.0, 1.0)
        : 0.0;

    return ThemedLightCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: t.textSecondary),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              countdown,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: iconColor,
                    shadows: t.textShadows,
                  ),
            ),
            const Spacer(),
            // Daylight progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: t.textTertiary.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  iconColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(sunrise),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textTertiary,
                      ),
                ),
                Text(
                  _formatTime(sunset),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textTertiary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) {
      return 'in ${d.inMinutes}m';
    }
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return 'in ${h}h ${m}m';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
