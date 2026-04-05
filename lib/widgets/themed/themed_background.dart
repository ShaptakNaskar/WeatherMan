import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/clean/clean_background.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_background.dart';
import 'package:weatherman/widgets/ocean/ocean_background.dart';
import 'package:weatherman/widgets/pastel/pastel_background.dart';
import 'package:weatherman/widgets/sunset/sunset_background.dart';

/// Theme-aware background that delegates to the correct themed background
///
/// Each theme has its own weather effects:
/// - Clean: Classic glassmorphic effects (rain, snow, stars, clouds, fog)
/// - Cyberpunk: Neon HUD effects (data particles, electric storms, grid patterns)
/// - Pastel: Cute kawaii effects (cherry blossoms, fireflies, hearts, soft sparkles)
///   - 4 variants: Light Day, Light Night, Dark Day, Dark Night
/// - Sunset: Golden hour effects (warm dust particles, amber lightning, sun flares)
///   - Day/Night variants
/// - Ocean: Deep sea effects (bubbles, bioluminescence, caustic light, sea foam)
///   - Day/Night variants
class ThemedBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const ThemedBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    switch (theme.currentType) {
      case AppThemeType.cyberpunk:
        return CyberpunkBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
      case AppThemeType.pastel:
        return PastelBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
      case AppThemeType.clean:
        return CleanBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
      case AppThemeType.sunset:
        return SunsetBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
      case AppThemeType.ocean:
        return OceanBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
    }
  }
}
