import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/screens/debug_weather_screen.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.clearDayGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Temperature unit
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temperature Unit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _TemperatureUnitSelector(
                        currentUnit: settings.temperatureUnit,
                        onChanged: settings.setTemperatureUnit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // About
                GlassCard(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        // App icon/name
                        Icon(
                        Icons.cloud_rounded,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'WeatherMan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Made with love
                      Text(
                        'Made with ❤️ by Sappy',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse('https://sappy-dir.vercel.app'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          'Visit my website →',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withValues(alpha: 0.12)),
                      const SizedBox(height: 12),
                      // Data source
                      Text(
                        'Weather data by Open-Meteo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                        const SizedBox(height: 4),
                        Text(
                          'Built with Flutter',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Debug section (only in debug mode)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bug_report_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Developer Options',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DebugButton(
                          icon: Icons.palette_outlined,
                          title: 'Weather Styles Preview',
                          subtitle: 'Test different weather backgrounds',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DebugWeatherScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DebugButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DebugButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _TemperatureUnitSelector extends StatelessWidget {
  final TemperatureUnit currentUnit;
  final ValueChanged<TemperatureUnit> onChanged;

  const _TemperatureUnitSelector({
    required this.currentUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _UnitButton(
            label: 'Celsius',
            symbol: '°C',
            isSelected: currentUnit == TemperatureUnit.celsius,
            onTap: () => onChanged(TemperatureUnit.celsius),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _UnitButton(
            label: 'Fahrenheit',
            symbol: '°F',
            isSelected: currentUnit == TemperatureUnit.fahrenheit,
            onTap: () => onChanged(TemperatureUnit.fahrenheit),
          ),
        ),
      ],
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final String symbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitButton({
    required this.label,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (removed unused _AboutItem and _AboutLinkItem)
