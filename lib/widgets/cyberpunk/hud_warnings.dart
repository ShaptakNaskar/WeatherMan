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
    if (aqi > 200) {
      alerts.add(EnvironmentAlert(
        label: 'AQI',
        value: aqi.round().toString(),
        description: 'HAZARDOUS AIR // SEAL RESPIRATOR NOW',
        severity: AlertSeverity.danger,
        icon: Icons.air_rounded,
      ));
    } else if (aqi > 100) {
      alerts.add(EnvironmentAlert(
        label: 'AQI',
        value: aqi.round().toString(),
        description: 'TOXIC PARTICLES DETECTED // MASK UP, CHOOM',
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
        description: 'LETHAL HEAT // STAY INSIDE, COOLANT LOW',
        severity: AlertSeverity.danger,
        icon: Icons.thermostat,
      ));
    } else if (temp > 38) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'THERMAL OVERLOAD // HYDRATE & SEEK SHADE',
        severity: AlertSeverity.warning,
        icon: Icons.thermostat,
      ));
    } else if (temp < -20) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'CRYO-HAZARD // FROSTBITE RISK CRITICAL',
        severity: AlertSeverity.danger,
        icon: Icons.ac_unit,
      ));
    } else if (temp < -10) {
      alerts.add(EnvironmentAlert(
        label: 'TEMP',
        value: '${temp.round()}°C',
        description: 'SUB-ZERO ALERT // INSULATE CYBERWARE',
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
        description: 'MOISTURE SATURATION // CORROSION RISK ON IMPLANTS',
        severity: AlertSeverity.danger,
        icon: Icons.water_drop,
      ));
    } else if (humidity > 75) {
      alerts.add(EnvironmentAlert(
        label: 'HUMIDITY',
        value: '${humidity.round()}%',
        description: 'HIGH HUMIDITY // CONDENSATION ON OPTICS',
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
        description: 'EXTREME UV // SKIN BURN IN <10 MIN, COVER UP',
        severity: AlertSeverity.danger,
        icon: Icons.wb_sunny,
      ));
    } else if (uv > 8) {
      alerts.add(EnvironmentAlert(
        label: 'UV INDEX',
        value: uv.toStringAsFixed(1),
        description: 'UV SPIKE // DERMAL SHIELD RECOMMENDED',
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
        description: 'STORM FORCE // DEBRIS HAZARD, STAY ANCHORED',
        severity: AlertSeverity.danger,
        icon: Icons.storm,
      ));
    } else if (wind > 50) {
      alerts.add(EnvironmentAlert(
        label: 'WIND',
        value: '${wind.round()} km/h',
        description: 'HIGH WIND // SECURE LOOSE GEAR, BRACE',
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
        description: 'NEAR BLIND // SWITCH TO THERMAL OPTICS',
        severity: AlertSeverity.danger,
        icon: Icons.visibility_off,
      ));
    } else if (vis > 0 && vis < 1000) {
      alerts.add(EnvironmentAlert(
        label: 'VISIBILITY',
        value: '${vis.round()}m',
        description: 'LOW VIS // ENGAGE ENHANCED SENSORS',
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
  late AnimationController _iconCycleController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _collapsed = false;
  bool _expandedByTap = false;
  int _currentIconIndex = 0; // 0 = warning sign, 1+ = alert icons

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    _iconCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scheduleCollapse();
    _startIconCycling();
  }

  void _startIconCycling() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _cycleNextIcon();
    });
  }

  void _cycleNextIcon() {
    if (!mounted || widget.alerts.isEmpty) return;
    // total icons = 1 (warning sign) + alert count
    final totalIcons = 1 + widget.alerts.length;
    setState(() {
      _currentIconIndex = (_currentIconIndex + 1) % totalIcons;
    });
    // Animate the transition
    _iconCycleController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _cycleNextIcon();
    });
  }

  void _scheduleCollapse() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_collapsed && !_expandedByTap) {
        setState(() => _collapsed = true);
      }
    });
  }

  @override
  void didUpdateWidget(HudWarningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alerts.length != oldWidget.alerts.length) {
      _currentIconIndex = 0;
      setState(() {
        _collapsed = false;
        _expandedByTap = false;
      });
      _slideController.forward(from: 0);
      _scheduleCollapse();
      
      // If we went from empty to having alerts, the cycle loop likely died. Restart it.
      if (oldWidget.alerts.isEmpty && widget.alerts.isNotEmpty) {
        _startIconCycling();
      }
    }
  }

  void _onPillTap() {
    setState(() {
      _expandedByTap = true;
      _collapsed = false;
    });
    _slideController.forward(from: 0);
  }

  void _onDismiss() {
    setState(() {
      _expandedByTap = false;
      _collapsed = true;
    });
  }

  /// Red if ANY alert is danger, yellow if all warnings
  Color get _pillColor {
    if (widget.alerts.isEmpty) return CyberpunkTheme.neonYellow;
    final hasDanger = widget.alerts.any((a) => a.severity == AlertSeverity.danger);
    return hasDanger ? CyberpunkTheme.neonRed : CyberpunkTheme.neonYellow;
  }

  /// Get the icon for the current cycle index
  IconData get _currentCycleIcon {
    if (_currentIconIndex == 0) return Icons.warning_amber_rounded;
    final alertIndex = _currentIconIndex - 1;
    if (alertIndex < widget.alerts.length) {
      return widget.alerts[alertIndex].icon;
    }
    return Icons.warning_amber_rounded;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _iconCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    final dangers = widget.alerts.where((a) => a.severity == AlertSeverity.danger).toList();
    final warnings = widget.alerts.where((a) => a.severity == AlertSeverity.warning).toList();
    final topPadding = MediaQuery.of(context).padding.top;

    // Tapped-expand: dimmed scrim + badges sliding out from top-right
    if (_expandedByTap) {
      return SizedBox.expand(
        child: GestureDetector(
          onTap: _onDismiss,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: CyberpunkTheme.bgDarkest.withValues(alpha: 0.85),
            child: Stack(
              children: [
                Positioned(
                  top: topPadding + 48,
                  right: 12,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: DefaultTextStyle(
                      style: const TextStyle(decoration: TextDecoration.none),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 270),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...dangers.map((a) => _buildAlertBadge(a, true)),
                            ...warnings.map((a) => _buildAlertBadge(a, false)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Collapsed: cycling icon pill (tappable)
    if (_collapsed) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 48, right: 12),
          child: GestureDetector(
            onTap: _onPillTap,
            child: _buildCyclingPill(),
          ),
        ),
      );
    }

    // Initial auto-expand (non-interactive, will collapse after 4s)
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 48, right: 12),
        child: IgnorePointer(
          child: SlideTransition(
            position: _slideAnimation,
            child: DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...dangers.map((a) => _buildAlertBadge(a, true)),
                    ...warnings.map((a) => _buildAlertBadge(a, false)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pulsing icon that cycles: ⚠ → temp → humidity → ... → repeat
  Widget _buildCyclingPill() {
    final color = _pillColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25 * _pulseAnimation.value),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  _currentCycleIcon,
                  key: ValueKey<int>(_currentIconIndex),
                  color: color,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertBadge(EnvironmentAlert alert, bool isDanger) {
    final color = isDanger ? CyberpunkTheme.neonRed : CyberpunkTheme.neonYellow;
    final label = isDanger ? '▲ DANGER' : '⚠ WARNING';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final alpha = isDanger ? _pulseAnimation.value : 1.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Opacity(
            opacity: alpha,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(alert.icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$label // ${alert.label}: ${alert.value}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1,
                            decoration: TextDecoration.none,
                            shadows: [
                              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          alert.description,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8,
                            color: color.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        /*
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                final opacity = (1.0 - _flashController.value) * 0.15;
                if (opacity <= 0.001) return const SizedBox.shrink();
                return Container(
                  // User requested removal of this overlay
                  color: CyberpunkTheme.neonBlue.withValues(alpha: opacity),
                );
              },
            ),
          ),
        ),
        */
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
    Color vignetteColor = const Color(0xFF050A18); // Deep blue-black
    double vignetteOpacity = 0.5;

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
