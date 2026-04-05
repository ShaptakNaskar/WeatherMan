import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// Visual rain timeline — shows when rain starts/stops in next 12h
class RainTimelineCard extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const RainTimelineCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    final now = DateTime.now();
    final next12h = hourly
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(12)
        .toList();

    if (next12h.isEmpty) return const SizedBox.shrink();

    // Find rain periods
    final hasAnyRain = next12h.any((h) => h.precipitationProbability > 30);
    if (!hasAnyRain) return const SizedBox.shrink();

    // Determine summary
    final summary = _buildSummary(next12h, now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ThemedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 16,
                  color: t.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'RAIN TIMELINE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: t.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Smart summary
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                shadows: t.textShadows,
              ),
            ),

            const SizedBox(height: 12),

            // Visual bar
            SizedBox(
              height: 40,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  return Column(
                    children: [
                      // Bar
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: t.textTertiary.withValues(alpha: 0.15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: next12h.map((h) {
                              final prob = h.precipitationProbability;
                              final width = barWidth / next12h.length;
                              Color color;
                              if (prob > 70) {
                                color = accent.withValues(alpha: 0.72);
                              } else if (prob > 30) {
                                color = accent.withValues(alpha: 0.42);
                              } else {
                                color = Colors.transparent;
                              }
                              return Container(width: width, color: color);
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Now',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: t.textTertiary),
                          ),
                          Text(
                            '+6h',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: t.textTertiary),
                          ),
                          Text(
                            '+12h',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: t.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSummary(List<HourlyForecast> hours, DateTime now) {
    final isRainingNow =
        hours.isNotEmpty && hours.first.precipitationProbability > 50;

    if (isRainingNow) {
      // Find when rain stops
      int stopsIn = 0;
      for (final h in hours) {
        if (h.precipitationProbability <= 30) break;
        stopsIn++;
      }
      if (stopsIn >= hours.length) {
        return 'Rain expected to continue for 12+ hours';
      }
      return 'Rain likely for the next ~${stopsIn}h, then clearing up';
    } else {
      // Find when rain starts
      int startsIn = 0;
      for (final h in hours) {
        if (h.precipitationProbability > 50) break;
        startsIn++;
      }
      if (startsIn >= hours.length) {
        return 'Slight chance of rain in the next 12h';
      }
      // Find duration
      int duration = 0;
      for (int i = startsIn; i < hours.length; i++) {
        if (hours[i].precipitationProbability <= 30) break;
        duration++;
      }
      final durationStr = duration > 0 ? ', lasting ~${duration}h' : '';
      if (startsIn <= 1) {
        return 'Rain starting very soon$durationStr';
      }
      return 'Rain expected in ~${startsIn}h$durationStr';
    }
  }
}
