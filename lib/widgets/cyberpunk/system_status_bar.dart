import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/weather.dart';

/// Cyberpunk HUD-style system status bar showing data feed health,
/// last sync timestamp & source attribution — displayed at the bottom
/// of the main scroll view for a polished "netrunner console" look.
class SystemStatusBar extends StatefulWidget {
  final WeatherData weather;

  const SystemStatusBar({super.key, required this.weather});

  @override
  State<SystemStatusBar> createState() => _SystemStatusBarState();
}

class _SystemStatusBarState extends State<SystemStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _refreshTimer;
  String _relativeTime = '';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _updateRelativeTime();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _updateRelativeTime();
    });
  }

  void _updateRelativeTime() {
    final diff = DateTime.now().difference(widget.weather.fetchedAt);
    String text;
    if (diff.inSeconds < 60) {
      text = 'LIVE';
    } else if (diff.inMinutes < 60) {
      text = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      text = '${diff.inHours}h ago';
    } else {
      text = '${diff.inDays}d ago';
    }
    if (mounted) setState(() => _relativeTime = text);
  }

  @override
  void didUpdateWidget(covariant SystemStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.fetchedAt != widget.weather.fetchedAt) {
      _updateRelativeTime();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = _relativeTime == 'LIVE';
    final diff = DateTime.now().difference(widget.weather.fetchedAt);
    final isStale = diff.inMinutes > 30;

    // Feed quality indicator
    final feedColor = isStale
        ? CyberpunkTheme.neonYellow
        : CyberpunkTheme.neonGreen;
    final feedLabel = isStale ? 'STALE' : 'NOMINAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CyberpunkTheme.bgPanel.withValues(alpha: 0.6),
        border: Border.all(
          color: CyberpunkTheme.glassBorder,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Feed status dot
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLive
                      ? feedColor.withValues(alpha: 0.6 + _pulseCtrl.value * 0.4)
                      : feedColor,
                  boxShadow: [
                    if (isLive)
                      BoxShadow(
                        color: feedColor.withValues(alpha: _pulseCtrl.value * 0.5),
                        blurRadius: 8,
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // Feed label
          Text(
            'FEED: $feedLabel',
            style: TextStyle(
              fontFamily: CyberpunkTheme.monoFont,
              fontSize: 9,
              color: feedColor.withValues(alpha: 0.8),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 12),

          // Separator
          Container(
            width: 1,
            height: 10,
            color: CyberpunkTheme.neonCyan.withValues(alpha: 0.2),
          ),

          const SizedBox(width: 12),

          // Last sync
          Text(
            'SYNC: $_relativeTime',
            style: TextStyle(
              fontFamily: CyberpunkTheme.monoFont,
              fontSize: 9,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 1.2,
            ),
          ),

          const Spacer(),

          // Source tag
          Text(
            'SRC: OPEN-METEO',
            style: TextStyle(
              fontFamily: CyberpunkTheme.monoFont,
              fontSize: 8,
              color: CyberpunkTheme.textTertiary.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
