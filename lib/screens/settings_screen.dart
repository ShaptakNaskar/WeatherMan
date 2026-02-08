import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/debug_weather_screen.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Text shadows for legibility on light backgrounds
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // Easter egg: tap cloud icon 7 times to unlock developer options
  int _tapCount = 0;
  bool _developerOptionsUnlocked = false;
  static const int _requiredTaps = 7;

  void _onCloudTap() {
    setState(() {
      _tapCount++;
      // Cancel any existing toast first (override, don't queue)
      Fluttertoast.cancel();
      
      if (_tapCount >= _requiredTaps && !_developerOptionsUnlocked) {
        _developerOptionsUnlocked = true;
        Fluttertoast.showToast(
          msg: '🎉 Developer options unlocked!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else if (!_developerOptionsUnlocked) {
        final remaining = _requiredTaps - _tapCount;
        if (remaining <= 3 && remaining > 0) {
          Fluttertoast.showToast(
            msg: '$remaining more taps to unlock developer options...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locationProvider, weatherProvider, _) {
        // Get the current weather code and isDay, fallback to clear day
        final currentLocation = locationProvider.selectedLocation;
        final weather = currentLocation != null
            ? weatherProvider.getWeather(currentLocation)
            : null;
        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;

        return DynamicBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Settings',
                style: TextStyle(shadows: _textShadows),
              ),
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              shadows: _textShadows,
                            ),
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

                    // Advanced View toggle
                    GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advanced View',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    shadows: _textShadows,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Show detailed weather data with extra metrics',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    shadows: _textShadows,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.advancedViewEnabled,
                            onChanged: (value) => settings.setAdvancedViewEnabled(value),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white.withValues(alpha: 0.5),
                            inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
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
                            // App icon/name - tap 7 times to unlock developer options
                            GestureDetector(
                              onTap: _onCloudTap,
                              child: Icon(
                                Icons.cloud_rounded,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: _textShadows,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'WeatherMan',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.5,
                                shadows: _textShadows,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v1.0.3',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                                shadows: _textShadows,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Made with love
                            Text(
                              'Made with ❤️ by Sappy',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w400,
                                shadows: _textShadows,
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
                                  color: Colors.white.withValues(alpha: 0.8),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withValues(alpha: 0.5),
                                  shadows: _textShadows,
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
                                shadows: _textShadows,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Built with Flutter',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                                shadows: _textShadows,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // Debug section (visible in debug mode OR when unlocked via easter egg)
                    if (kDebugMode || _developerOptionsUnlocked) ...[
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
                                  shadows: _textShadows,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Developer Options',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    shadows: _textShadows,
                                  ),
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
      },
    );
  }
}

class _DebugButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  // Text shadows for legibility
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

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
            Icon(icon, color: Colors.orange, shadows: _textShadows),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      shadows: _textShadows,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      shadows: _textShadows,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, shadows: _textShadows),
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

  // Text shadows for legibility
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

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
                shadows: _textShadows,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                shadows: _textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
