import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// Displays smart weather insights inline on the home screen
class WeatherInsightsCard extends StatefulWidget {
  final WeatherData weather;

  const WeatherInsightsCard({super.key, required this.weather});

  @override
  State<WeatherInsightsCard> createState() => _WeatherInsightsCardState();
}

class _WeatherInsightsCardState extends State<WeatherInsightsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final accent = t.primaryUiAccent;
    final style = context.watch<ThemeProvider>().textStyle;
    final insights = TrendAnalyzer.detectAll(widget.weather, style);
    if (insights.isEmpty) return const SizedBox.shrink();

    final displayCount = _expanded
        ? insights.length
        : insights.length.clamp(0, 3);
    final hasMore = insights.length > 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ThemedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.insights_rounded, color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'INSIGHTS',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    shadows: t.subtleGlow,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      t.cardBorderRadius * 0.5,
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    '${insights.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Insight items
            ...insights
                .take(displayCount)
                .map((insight) => _InsightItem(insight: insight)),

            // Show more / less
            if (hasMore) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: accent.withValues(alpha: 0.75),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded ? 'Show less' : '+${insights.length - 3} more',
                      style: TextStyle(
                        fontSize: 11,
                        color: accent.withValues(alpha: 0.75),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final TrendInsight insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final color = t.severityColor(insight.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ThemedLightCard(
        radiusScale: 0.5,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(t.cardBorderRadius * 0.5),
            border: Border(
              left: BorderSide(color: color.withValues(alpha: 0.62), width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (insight.severity == InsightSeverity.severe)
                    _AnimatedAlertBadge(color: color, theme: t)
                  else if (insight.severity == InsightSeverity.warning)
                    _WarnBadge(color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                insight.body,
                style: TextStyle(
                  fontSize: 12,
                  color: t.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarnBadge extends StatelessWidget {
  final Color color;

  const _WarnBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return ThemedLightCard(
      radiusScale: 0.35,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          'WARN',
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

/// Pulsing ALERT badge for severe insights
class _AnimatedAlertBadge extends StatefulWidget {
  final Color color;
  final AppThemeData theme;
  const _AnimatedAlertBadge({required this.color, required this.theme});

  @override
  State<_AnimatedAlertBadge> createState() => _AnimatedAlertBadgeState();
}

class _AnimatedAlertBadgeState extends State<_AnimatedAlertBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ThemedLightCard(
          radiusScale: 0.35,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1 + _ctrl.value * 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.4 + _ctrl.value * 0.4),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _ctrl.value * 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              'ALERT',
              style: TextStyle(
                fontSize: 9,
                color: widget.color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
