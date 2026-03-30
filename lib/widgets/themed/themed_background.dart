import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_background.dart';
import 'package:weatherman/widgets/pastel/pastel_background.dart';

/// Theme-aware background that delegates to the correct themed background
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
      case AppThemeType.pastelDark:
        return PastelBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: child,
        );
      case AppThemeType.clean:
      case AppThemeType.sunset:
      case AppThemeType.ocean:
        return _CleanBackground(
          gradient: theme.current.getWeatherGradient(weatherCode, isDay),
          child: child,
        );
    }
  }
}

/// Simple gradient background for the clean theme
class _CleanBackground extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;

  const _CleanBackground({
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
