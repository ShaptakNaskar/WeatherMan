import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/weather.dart';

/// Alert severity levels
enum AlertSeverity { normal, warning, danger }

/// A single environment alert
class EnvironmentAlert {
  final String label;
  final String value;
  final String description;
  final AlertSeverity severity;
  final IconData icon;

  const EnvironmentAlert({
    required this.label,
    required this.value,
    required this.description,
    required this.severity,
    required this.icon,
  });
}

/// Evaluates weather data and produces alerts
class AlertEvaluator {
  /// Evaluate all environmental conditions and return alerts
  static List<EnvironmentAlert> evaluate({
    required CurrentWeather current,
    AirQuality? airQuality,
    // Debug overrides
    double? debugAqi,
    double? debugTemp,
    double? debugHumidity,
    double? debugUv,
    double? debugWind,
    double? debugVisibility,
  }) {
    final alerts = <EnvironmentAlert>[];

    // AQI
    final aqi = debugAqi ?? airQuality?.usAqi.toDouble() ?? 0;
    if (aqi > 150) {
      alerts.add(EnvironmentAlert(
        label: 'AQI',
        value: aqi.round().toString(),
        description: aqi > 200 ? 'HAZARDOUS AIR // AVOID EXPOSURE' : 'UNHEALTHY AIR // LIMIT EXPOSURE',
        severity: aqi > 200 ? AlertSeverity.danger : AlertSeverity.warning,
        icon: Icons.air_rounded,
      ));
    } else if (aqi > 100) {
      alerts.add(EnvironmentAlert(
        label: 'AQI',
        value: aqi.round().toString(),
        description: 'SENSITIVE GROUPS AT RISK',
        severity: AlertSeverity.warning,
        icon: Icons.air_rounded,
      ));
    }

    // Temperature
    final temp = debugTemp ?? current.temperature;
    if (temp > 45) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'EXTREME HEAT // DANGER',
        severity: AlertSeverity.danger,
        icon: Icons.thermostat,
      ));
    } else if (temp > 38) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'HIGH TEMPERATURE WARNING',
        severity: AlertSeverity.warning,
        icon: Icons.thermostat,
      ));
    } else if (temp < -20) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'EXTREME COLD // DANGER',
        severity: AlertSeverity.danger,
        icon: Icons.ac_unit,
      ));
    } else if (temp < -10) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'SEVERE COLD WARNING',
        severity: AlertSeverity.warning,
        icon: Icons.ac_unit,
      ));
    }

    // Humidity
    final humidity = debugHumidity ?? current.relativeHumidity.toDouble();
    if (humidity > 90) {
      alerts.add(EnvironmentAlert(
        label: 'HUMIDITY',
        value: '${humidity.round()}%',
        description: 'EXTREME HUMIDITY // RESPIRATORY RISK',
        severity: AlertSeverity.danger,
        icon: Icons.water_drop,
      ));
    } else if (humidity > 75) {
      alerts.add(EnvironmentAlert(
        label: 'HUMIDITY',
        value: '${humidity.round()}%',
        description: 'HIGH HUMIDITY DETECTED',
        severity: AlertSeverity.warning,
        icon: Icons.water_drop_outlined,
      ));
    }

    // UV Index
    final uv = debugUv ?? current.uvIndex;
    if (uv > 11) {
      alerts.add(EnvironmentAlert(
        label: 'UV INDEX',
        value: uv.toStringAsFixed(1),
        description: 'EXTREME UV // AVOID SUN EXPOSURE',
        severity: AlertSeverity.danger,
        icon: Icons.wb_sunny,
      ));
    } else if (uv > 8) {
      alerts.add(EnvironmentAlert(
        label: 'UV INDEX',
        value: uv.toStringAsFixed(1),
        description: 'VERY HIGH UV RADIATION',
        severity: AlertSeverity.warning,
        icon: Icons.wb_sunny_outlined,
      ));
    }

    // Wind
    final wind = debugWind ?? current.windSpeed;
    if (wind > 90) {
      alerts.add(EnvironmentAlert(
        label: 'WIND',
        value: '${wind.round()} km/h',
        description: 'STORM FORCE WINDS // DANGER',
        severity: AlertSeverity.danger,
        icon: Icons.storm,
      ));
    } else if (wind > 50) {
      alerts.add(EnvironmentAlert(
        label: 'WIND',
        value: '${wind.round()} km/h',
        description: 'HIGH WIND WARNING',
        severity: AlertSeverity.warning,
        icon: Icons.air,
      ));
    }

    // Visibility
    final vis = debugVisibility ?? current.visibility;
    if (vis > 0 && vis < 200) {
      alerts.add(EnvironmentAlert(
        label: 'VISIBILITY',
        value: '${vis.round()}m',
        description: 'NEAR ZERO VISIBILITY // DANGER',
        severity: AlertSeverity.danger,
        icon: Icons.visibility_off,
      ));
    } else if (vis > 0 && vis < 1000) {
      alerts.add(EnvironmentAlert(
        label: 'VISIBILITY',
        value: '${vis.round()}m',
        description: 'LOW VISIBILITY WARNING',
        severity: AlertSeverity.warning,
        icon: Icons.visibility_outlined,
      ));
    }

    return alerts;
  }
}

/// Cyberpunk 2077-style HUD warning overlay
/// Designed like V's cyberware malfunction warnings
class HudWarningOverlay extends StatefulWidget {
  final List<EnvironmentAlert> alerts;

  const HudWarningOverlay({super.key, required this.alerts});

  @override
  State<HudWarningOverlay> createState() => _HudWarningOverlayState();
}

class _HudWarningOverlayState extends State<HudWarningOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _collapseController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Auto-collapse after 4 seconds
    _scheduleCollapse();
  }

  void _scheduleCollapse() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_collapsed) {
        setState(() => _collapsed = true);
        _collapseController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(HudWarningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If alerts change, briefly expand again
    if (widget.alerts.length != oldWidget.alerts.length) {
      setState(() => _collapsed = false);
      _collapseController.reverse();
      _slideController.forward(from: 0);
      _scheduleCollapse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _collapseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    final dangers = widget.alerts.where((a) => a.severity == AlertSeverity.danger).toList();
    final warnings = widget.alerts.where((a) => a.severity == AlertSeverity.warning).toList();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 48,
      right: 12,
      child: IgnorePointer(
        child: SlideTransition(
          position: _slideAnimation,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _collapsed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildExpandedBadges(dangers, warnings),
            secondChild: _buildCollapsedPill(dangers.length, warnings.length),
          ),
        ),
      ),
    );
  }

  /// Full detail view — shown briefly on appear
  Widget _buildExpandedBadges(List<EnvironmentAlert> dangers, List<EnvironmentAlert> warnings) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...dangers.map((a) => _buildAlertBadge(a, true)),
          ...warnings.map((a) => _buildAlertBadge(a, false)),
        ],
      ),
    );
  }

  /// Compact pill — replaces badges after auto-collapse
  Widget _buildCollapsedPill(int dangerCount, int warningCount) {
    final hasDanger = dangerCount > 0;
    final color = hasDanger ? CyberpunkTheme.neonRed : CyberpunkTheme.neonYellow;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final alpha = hasDanger ? _pulseAnimation.value : 1.0;
        return Opacity(
          opacity: alpha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasDanger ? Icons.dangerous_rounded : Icons.warning_amber_rounded,
                  color: color,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  hasDanger
                      ? '▲ $dangerCount${warningCount > 0 ? ' + $warningCount' : ''}'
                      : '⚠ $warningCount',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                    shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertBadge(EnvironmentAlert alert, bool isDanger) {
    final color = isDanger ? CyberpunkTheme.neonRed : CyberpunkTheme.neonYellow;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final alpha = isDanger ? _pulseAnimation.value : 1.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Opacity(
            opacity: alpha,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 6),
                ],
              ),
              child: Text(
                '${isDanger ? '▲' : '⚠'} ${alert.label}: ${alert.value}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full-screen danger flash effect (flashes once on trigger change)
class DangerFlashOverlay extends StatefulWidget {
  final bool hasDanger;
  final Widget child;

  const DangerFlashOverlay({
    super.key,
    required this.hasDanger,
    required this.child,
  });

  @override
  State<DangerFlashOverlay> createState() => _DangerFlashOverlayState();
}

class _DangerFlashOverlayState extends State<DangerFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  bool _previousDanger = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _previousDanger = widget.hasDanger;
  }

  @override
  void didUpdateWidget(DangerFlashOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flash when danger state transitions to true
    if (widget.hasDanger && !_previousDanger) {
      _flashController.forward(from: 0);
    }
    _previousDanger = widget.hasDanger;
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Red flash overlay
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              final opacity = (1.0 - _flashController.value) * 0.15;
              if (opacity <= 0.001) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: CyberpunkTheme.neonRed.withValues(alpha: opacity),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Edge vignette with optional danger tint
class CyberpunkVignette extends StatelessWidget {
  final bool hasDanger;
  final bool hasWarning;

  const CyberpunkVignette({
    super.key,
    this.hasDanger = false,
    this.hasWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color vignetteColor = Colors.black;
    double vignetteOpacity = 0.4;

    if (hasDanger) {
      vignetteColor = CyberpunkTheme.neonRed;
      vignetteOpacity = 0.15;
    } else if (hasWarning) {
      vignetteColor = CyberpunkTheme.neonYellow;
      vignetteOpacity = 0.08;
    }

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              vignetteColor.withValues(alpha: vignetteOpacity),
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
