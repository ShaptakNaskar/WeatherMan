import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/widgets/backgrounds/weather_style.dart';
import 'package:weatherman/widgets/backgrounds/weather_gradient_system.dart';
import 'package:weatherman/widgets/backgrounds/sky_phase_calculator.dart';
import 'package:weatherman/widgets/backgrounds/particles/rain_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/snow_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/thunderstorm_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/star_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/cloud_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/fog_overlay.dart';
import 'package:weatherman/widgets/backgrounds/particles/heat_shimmer_overlay.dart';

/// Orchestrator widget — resolves the [WeatherStyle] and renders
/// animated gradient + particle overlays behind [child].
class DynamicBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? temperature;

  const DynamicBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
    this.sunrise,
    this.sunset,
    this.temperature,
  });

  WeatherStyle get _style {
    final condition = conditionFromCode(weatherCode);
    SkyPhase phase;
    if (sunrise != null && sunset != null) {
      phase = SkyPhaseCalculator.calculate(DateTime.now(), sunrise!, sunset!);
    } else {
      phase = isDay ? SkyPhase.midDay : SkyPhase.nightDeep;
    }
    return WeatherGradientSystem.resolve(
      condition: condition,
      phase: phase,
      isDay: isDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return AnimatedContainer(
      duration: DesignSystem.durationBackground,
      curve: DesignSystem.curveBackground,
      decoration: BoxDecoration(gradient: style.gradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: _buildParticleOverlay(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildParticleOverlay() {
    if (_isThunderstorm) return const ThunderstormOverlay();
    if (_isRainy) return RainOverlay(intensity: _rainIntensity);
    if (_isSnowy) return SnowOverlay(intensity: _snowIntensity);
    if (_isFog) return const FogOverlay();
    if (!isDay && _isClear) return const StarOverlay();
    if (_isCloudy) return const CloudOverlay();
    if (isDay && _isClear && (temperature ?? 0) > 35) {
      return const HeatShimmerOverlay();
    }
    return const SizedBox.shrink();
  }

  // ── condition flags ──
  bool get _isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82);
  bool get _isSnowy =>
      (weatherCode >= 71 && weatherCode <= 77) ||
      (weatherCode >= 85 && weatherCode <= 86);
  bool get _isThunderstorm => weatherCode >= 95 && weatherCode <= 99;
  bool get _isClear => weatherCode == 0 || weatherCode == 1;
  bool get _isCloudy => weatherCode == 2 || weatherCode == 3;
  bool get _isFog => weatherCode == 45 || weatherCode == 48;

  double get _rainIntensity {
    if (weatherCode == 51 || weatherCode == 61 || weatherCode == 80) return 0.3;
    if (weatherCode == 53 || weatherCode == 63 || weatherCode == 81) return 0.6;
    return 1.0;
  }

  double get _snowIntensity {
    if (weatherCode == 71 || weatherCode == 85) return 0.3;
    if (weatherCode == 73) return 0.6;
    return 1.0;
  }
}
