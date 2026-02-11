import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_background.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_glass_card.dart';
import 'package:weatherman/widgets/cyberpunk/glitch_effects.dart';
import 'package:weatherman/widgets/cyberpunk/hud_warnings.dart';

/// Debug screen to preview weather styles AND test warning/danger alerts
class DebugWeatherScreen extends StatefulWidget {
  const DebugWeatherScreen({super.key});

  @override
  State<DebugWeatherScreen> createState() => _DebugWeatherScreenState();
}

class _DebugWeatherScreenState extends State<DebugWeatherScreen>
    with SingleTickerProviderStateMixin {
  int _currentWeatherCode = 0;
  bool _isDay = true;
  int _currentTab = 0; // 0 = weather, 1 = alerts

  // Alert debug sliders
  double _debugAqi = 0;
  double _debugTemp = 22;
  double _debugHumidity = 50;
  double _debugUv = 3;
  double _debugWind = 10;
  double _debugVisibility = 10000;

  // Weather code presets
  static const List<_WeatherPreset> _presets = [
    _WeatherPreset(code: 0, name: 'CLEAR', icon: Icons.wb_sunny),
    _WeatherPreset(code: 1, name: 'CLEAR+', icon: Icons.wb_sunny_outlined),
    _WeatherPreset(code: 2, name: 'CLOUD', icon: Icons.cloud_outlined),
    _WeatherPreset(code: 3, name: 'OVRCAST', icon: Icons.cloud),
    _WeatherPreset(code: 51, name: 'DRIZZLE', icon: Icons.grain),
    _WeatherPreset(code: 61, name: 'RAIN_L', icon: Icons.water_drop_outlined),
    _WeatherPreset(code: 63, name: 'RAIN_M', icon: Icons.water_drop),
    _WeatherPreset(code: 65, name: 'RAIN_H', icon: Icons.thunderstorm),
    _WeatherPreset(code: 71, name: 'SNOW_L', icon: Icons.ac_unit_outlined),
    _WeatherPreset(code: 75, name: 'SNOW_H', icon: Icons.ac_unit),
    _WeatherPreset(code: 95, name: 'STORM', icon: Icons.flash_on),
    _WeatherPreset(code: 45, name: 'FOG', icon: Icons.blur_on),
  ];

  List<EnvironmentAlert> get _debugAlerts {
    final mockCurrent = CurrentWeather(
      temperature: _debugTemp,
      apparentTemperature: _debugTemp,
      relativeHumidity: _debugHumidity.round(),
      isDay: _isDay,
      precipitation: 0,
      rain: 0,
      snowfall: 0,
      weatherCode: _currentWeatherCode,
      cloudCover: 0,
      pressure: 1013,
      surfacePressure: 1013,
      windSpeed: _debugWind,
      windDirection: 0,
      windGusts: _debugWind * 1.3,
      uvIndex: _debugUv,
      visibility: _debugVisibility,
      dewPoint: 10,
    );
    return AlertEvaluator.evaluate(
      current: mockCurrent,
      debugAqi: _debugAqi > 0 ? _debugAqi : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _currentTab == 1 ? _debugAlerts : <EnvironmentAlert>[];
    final hasDanger = alerts.any((a) => a.severity == AlertSeverity.danger);
    final hasWarning = alerts.any((a) => a.severity == AlertSeverity.warning);

    return DangerFlashOverlay(
      hasDanger: hasDanger,
      child: CyberpunkBackground(
        weatherCode: _currentWeatherCode,
        isDay: _isDay,
        child: Stack(
          children: [
            Positioned.fill(
              child: CyberpunkVignette(
                hasDanger: hasDanger,
                hasWarning: hasWarning,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: GlitchText(
                  text: '// DEBUG_CONSOLE //',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    color: CyberpunkTheme.neonCyan,
                    letterSpacing: 2,
                    shadows: CyberpunkTheme.subtleCyanGlow,
                  ),
                  glitchIntensity: 0.4,
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: CyberpunkTheme.neonCyan),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky,
                      overlays: [],
                    );
                  } else {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                      overlays: SystemUiOverlay.values,
                    );
                  }
                  return _buildContent();
                },
              ),
            ),
            if (_currentTab == 1)
              IgnorePointer(
                child: HudWarningOverlay(alerts: alerts),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _currentTab == 0
              ? _buildWeatherTab()
              : _buildAlertsTab(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab(0, 'WEATHER_FX', Icons.cloud_outlined),
          const SizedBox(width: 8),
          _buildTab(1, 'ALERT_SIM', Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;
    final color = isSelected ? CyberpunkTheme.neonCyan : CyberpunkTheme.textTertiary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? CyberpunkTheme.neonCyan.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: isSelected
                  ? CyberpunkTheme.neonCyan.withValues(alpha: 0.5)
                  : CyberpunkTheme.textTertiary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === WEATHER TAB ===
  Widget _buildWeatherTab() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(child: _buildWeatherPreviewCard()),
        ),
        _buildDayNightToggle(),
        const SizedBox(height: 12),
        Expanded(
          flex: 3,
          child: _buildPresetsGrid(),
        ),
        _buildSliderControl(),
      ],
    );
  }

  Widget _buildWeatherPreviewCard() {
    return CyberGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CODE: $_currentWeatherCode',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: CyberpunkTheme.neonCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          GlitchText(
            text: _presets.firstWhere(
              (p) => p.code == _currentWeatherCode,
              orElse: () => _WeatherPreset(
                code: _currentWeatherCode,
                name: 'UNKNOWN',
                icon: Icons.help,
              ),
            ).name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 3,
            ),
            glitchIntensity: 0.5,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isDay ? Icons.wb_sunny : Icons.nightlight_round,
                size: 36,
                color: _isDay ? CyberpunkTheme.neonYellow : CyberpunkTheme.neonMagenta,
              ),
              const SizedBox(width: 8),
              Text(
                _isDay ? 'DAY' : 'NIGHT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  color: CyberpunkTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayNightToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CyberGlassCard(
        child: Row(
          children: [
            Icon(Icons.wb_sunny, color: CyberpunkTheme.neonYellow, size: 20),
            const SizedBox(width: 8),
            Text('DAY', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: CyberpunkTheme.textSecondary)),
            const Spacer(),
            Switch(
              value: _isDay,
              onChanged: (value) => setState(() => _isDay = value),
              activeThumbColor: CyberpunkTheme.neonCyan,
              activeTrackColor: CyberpunkTheme.neonCyan.withValues(alpha: 0.3),
            ),
            const Spacer(),
            Text('NIGHT', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: CyberpunkTheme.textSecondary)),
            const SizedBox(width: 8),
            Icon(Icons.nightlight_round, color: CyberpunkTheme.neonMagenta, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _presets.length,
      itemBuilder: (context, index) {
        final preset = _presets[index];
        final isSelected = preset.code == _currentWeatherCode;
        final color = isSelected ? CyberpunkTheme.neonCyan : CyberpunkTheme.textTertiary;

        return GestureDetector(
          onTap: () => setState(() => _currentWeatherCode = preset.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? CyberpunkTheme.neonCyan.withValues(alpha: 0.1)
                  : CyberpunkTheme.bgPanel.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? CyberpunkTheme.neonCyan.withValues(alpha: 0.6)
                    : CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 0.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15), blurRadius: 8)]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(preset.icon, size: 28, color: color),
                const SizedBox(height: 6),
                Text(
                  preset.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderControl() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CyberGlassCard(
        child: Row(
          children: [
            Text('CODE:', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: CyberpunkTheme.textSecondary)),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: CyberpunkTheme.neonCyan,
                  inactiveTrackColor: CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
                  thumbColor: CyberpunkTheme.neonCyan,
                  overlayColor: CyberpunkTheme.neonCyan.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: _currentWeatherCode.toDouble(),
                  min: 0,
                  max: 99,
                  divisions: 99,
                  label: _currentWeatherCode.toString(),
                  onChanged: (value) =>
                      setState(() => _currentWeatherCode = value.round()),
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                _currentWeatherCode.toString(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: CyberpunkTheme.neonCyan,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === ALERTS TAB ===
  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAlertStatus(),
        const SizedBox(height: 16),
        _buildAlertSlider('AQI', _debugAqi, 0, 500, CyberpunkTheme.neonMagenta,
            (v) => setState(() => _debugAqi = v),
            formatValue: (v) => v.round().toString(),
            warningThreshold: 100, dangerThreshold: 200),
        _buildAlertSlider('TEMP °C', _debugTemp, -30, 55, CyberpunkTheme.neonRed,
            (v) => setState(() => _debugTemp = v),
            formatValue: (v) => '${v.round()}°',
            warningThreshold: 38, dangerThreshold: 45),
        _buildAlertSlider('HUMIDITY %', _debugHumidity, 0, 100, CyberpunkTheme.neonCyan,
            (v) => setState(() => _debugHumidity = v),
            formatValue: (v) => '${v.round()}%',
            warningThreshold: 75, dangerThreshold: 90),
        _buildAlertSlider('UV INDEX', _debugUv, 0, 15, CyberpunkTheme.neonYellow,
            (v) => setState(() => _debugUv = v),
            formatValue: (v) => v.toStringAsFixed(1),
            warningThreshold: 8, dangerThreshold: 11),
        _buildAlertSlider('WIND km/h', _debugWind, 0, 120, CyberpunkTheme.neonGreen,
            (v) => setState(() => _debugWind = v),
            formatValue: (v) => '${v.round()}',
            warningThreshold: 50, dangerThreshold: 90),
        _buildAlertSlider('VISIBILITY m', _debugVisibility, 0, 20000, CyberpunkTheme.neonPurple,
            (v) => setState(() => _debugVisibility = v),
            formatValue: (v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}km' : '${v.round()}m',
            warningThreshold: 1000, dangerThreshold: 200, invertThreshold: true),
        const SizedBox(height: 16),
        _buildQuickPresets(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAlertStatus() {
    final alerts = _debugAlerts;
    final dangers = alerts.where((a) => a.severity == AlertSeverity.danger).length;
    final warnings = alerts.where((a) => a.severity == AlertSeverity.warning).length;

    Color statusColor;
    String statusText;
    if (dangers > 0) {
      statusColor = CyberpunkTheme.neonRed;
      statusText = '▲ $dangers DANGER${dangers > 1 ? 'S' : ''} ACTIVE';
    } else if (warnings > 0) {
      statusColor = CyberpunkTheme.neonYellow;
      statusText = '⚠ $warnings WARNING${warnings > 1 ? 'S' : ''} ACTIVE';
    } else {
      statusColor = CyberpunkTheme.neonGreen;
      statusText = '● ALL SYSTEMS NOMINAL';
    }

    return NeonBorderContainer(
      glowColor: statusColor,
      padding: const EdgeInsets.all(16),
      animate: dangers > 0,
      child: Row(
        children: [
          Icon(
            dangers > 0
                ? Icons.dangerous_rounded
                : warnings > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENVIRONMENT STATUS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: CyberpunkTheme.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    shadows: [Shadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSlider(
    String label,
    double value,
    double min,
    double max,
    Color color,
    ValueChanged<double> onChanged, {
    required String Function(double) formatValue,
    required double warningThreshold,
    required double dangerThreshold,
    bool invertThreshold = false,
  }) {
    AlertSeverity severity = AlertSeverity.normal;
    if (invertThreshold) {
      if (value <= dangerThreshold && value > 0) {
        severity = AlertSeverity.danger;
      } else if (value <= warningThreshold) {
        severity = AlertSeverity.warning;
      }
    } else {
      if (value >= dangerThreshold) {
        severity = AlertSeverity.danger;
      } else if (value >= warningThreshold) {
        severity = AlertSeverity.warning;
      }
    }

    Color activeColor;
    switch (severity) {
      case AlertSeverity.danger:
        activeColor = CyberpunkTheme.neonRed;
        break;
      case AlertSeverity.warning:
        activeColor = CyberpunkTheme.neonYellow;
        break;
      case AlertSeverity.normal:
        activeColor = color;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CyberGlassCard(
        borderColor: activeColor,
        glowIntensity: severity == AlertSeverity.normal ? 0.2 : 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: CyberpunkTheme.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Text(
                  formatValue(value),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 4)],
                  ),
                ),
                if (severity != AlertSeverity.normal) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: activeColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      severity == AlertSeverity.danger ? 'DANGER' : 'WARN',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        color: activeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: activeColor,
                inactiveTrackColor: activeColor.withValues(alpha: 0.15),
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.1),
                trackHeight: 3,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return CyberGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// QUICK_PRESETS //',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: CyberpunkTheme.textTertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetButton('NOMINAL', CyberpunkTheme.neonGreen, () {
                setState(() {
                  _debugAqi = 30;
                  _debugTemp = 22;
                  _debugHumidity = 50;
                  _debugUv = 3;
                  _debugWind = 10;
                  _debugVisibility = 15000;
                });
              }),
              _presetButton('WARN ALL', CyberpunkTheme.neonYellow, () {
                setState(() {
                  _debugAqi = 120;
                  _debugTemp = 40;
                  _debugHumidity = 80;
                  _debugUv = 9;
                  _debugWind = 60;
                  _debugVisibility = 800;
                });
              }),
              _presetButton('DANGER ALL', CyberpunkTheme.neonRed, () {
                setState(() {
                  _debugAqi = 350;
                  _debugTemp = 48;
                  _debugHumidity = 95;
                  _debugUv = 13;
                  _debugWind = 100;
                  _debugVisibility = 100;
                });
              }),
              _presetButton('AQI CRIT', CyberpunkTheme.neonMagenta, () {
                setState(() {
                  _debugAqi = 400;
                  _debugTemp = 22;
                  _debugHumidity = 50;
                  _debugUv = 3;
                  _debugWind = 10;
                  _debugVisibility = 15000;
                });
              }),
              _presetButton('EXTREME COLD', CyberpunkTheme.neonPurple, () {
                setState(() {
                  _debugAqi = 30;
                  _debugTemp = -25;
                  _debugHumidity = 50;
                  _debugUv = 1;
                  _debugWind = 60;
                  _debugVisibility = 500;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _WeatherPreset {
  final int code;
  final String name;
  final IconData icon;

  const _WeatherPreset({
    required this.code,
    required this.name,
    required this.icon,
  });
}

/// Extension to check if debug mode
extension DebugMode on BuildContext {
  static bool get isDebugMode => kDebugMode;
}
