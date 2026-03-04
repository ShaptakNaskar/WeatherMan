import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_glass_card.dart';

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
    final insights = TrendAnalyzer.detectAll(widget.weather);
    if (insights.isEmpty) return const SizedBox.shrink();

    // Show up to 3 insights by default, expand for all
    final displayCount = _expanded ? insights.length : insights.length.clamp(0, 3);
    final hasMore = insights.length > 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CyberGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: CyberpunkTheme.neonCyan,
                  size: 18,
                  shadows: CyberpunkTheme.subtleCyanGlow,
                ),
                const SizedBox(width: 8),
                Text(
                  'INTEL FEED',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: CyberpunkTheme.neonCyan,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    shadows: CyberpunkTheme.subtleCyanGlow,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.neonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: CyberpunkTheme.neonCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${insights.length}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: CyberpunkTheme.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Insight items
            ...insights.take(displayCount).map((insight) => _InsightItem(
              insight: insight,
            )),

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
                      color: CyberpunkTheme.neonCyan.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded
                          ? 'Collapse feed'
                          : '+${insights.length - 3} intel${insights.length - 3 > 1 ? '' : ''}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: CyberpunkTheme.neonCyan.withValues(alpha: 0.7),
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
    final color = _severityColor(insight.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: color.withValues(alpha: 0.6), width: 2),
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
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (insight.severity == InsightSeverity.severe)
                _AnimatedAlertBadge(color: color)
              else if (insight.severity == InsightSeverity.warning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'WARN',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            insight.body,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.severe:
        return CyberpunkTheme.neonRed;
      case InsightSeverity.warning:
        return CyberpunkTheme.neonYellow;
      case InsightSeverity.info:
        return CyberpunkTheme.neonCyan;
    }
  }
}

/// Pulsing ALERT badge for severe insights
class _AnimatedAlertBadge extends StatefulWidget {
  final Color color;
  const _AnimatedAlertBadge({required this.color});

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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
              fontFamily: 'monospace',
              fontSize: 9,
              color: widget.color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}
