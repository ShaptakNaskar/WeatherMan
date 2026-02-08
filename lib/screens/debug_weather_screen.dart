import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weatherman/config/theme.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Debug screen to preview different weather styles
class DebugWeatherScreen extends StatefulWidget {
  const DebugWeatherScreen({super.key});

  @override
  State<DebugWeatherScreen> createState() => _DebugWeatherScreenState();
}

class _DebugWeatherScreenState extends State<DebugWeatherScreen> {
  int _currentWeatherCode = 0;
  bool _isDay = true;

  // Weather code presets for testing
  static const List<_WeatherPreset> _presets = [
    _WeatherPreset(code: 0, name: 'Clear Sky', icon: Icons.wb_sunny),
    _WeatherPreset(code: 1, name: 'Mainly Clear', icon: Icons.wb_sunny_outlined),
    _WeatherPreset(code: 2, name: 'Partly Cloudy', icon: Icons.cloud_outlined),
    _WeatherPreset(code: 3, name: 'Overcast', icon: Icons.cloud),
    _WeatherPreset(code: 51, name: 'Light Drizzle', icon: Icons.grain),
    _WeatherPreset(code: 61, name: 'Light Rain', icon: Icons.water_drop_outlined),
    _WeatherPreset(code: 63, name: 'Moderate Rain', icon: Icons.water_drop),
    _WeatherPreset(code: 65, name: 'Heavy Rain', icon: Icons.thunderstorm),
    _WeatherPreset(code: 71, name: 'Light Snow', icon: Icons.ac_unit_outlined),
    _WeatherPreset(code: 75, name: 'Heavy Snow', icon: Icons.ac_unit),
    _WeatherPreset(code: 95, name: 'Thunderstorm', icon: Icons.flash_on),
    _WeatherPreset(code: 45, name: 'Fog', icon: Icons.blur_on),
  ];

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      weatherCode: _currentWeatherCode,
      isDay: _isDay,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Debug: Weather Styles'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Display area showing current weather code
            Expanded(
              flex: 2,
              child: Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Weather Code: $_currentWeatherCode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _presets.firstWhere(
                          (p) => p.code == _currentWeatherCode,
                          orElse: () => _WeatherPreset(
                            code: _currentWeatherCode,
                            name: 'Unknown',
                            icon: Icons.help,
                          ),
                        ).name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDay ? Icons.wb_sunny : Icons.nightlight_round,
                            size: 48,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDay ? 'Day' : 'Night',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Day/Night toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny),
                    const SizedBox(width: 8),
                    const Text('Day Mode'),
                    const Spacer(),
                    Switch(
                      value: _isDay,
                      onChanged: (value) => setState(() => _isDay = value),
                      activeColor: Colors.white,
                    ),
                    const Spacer(),
                    const Text('Night Mode'),
                    const SizedBox(width: 8),
                    const Icon(Icons.nightlight_round),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weather presets grid
            Expanded(
              flex: 3,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _presets.length,
                itemBuilder: (context, index) {
                  final preset = _presets[index];
                  final isSelected = preset.code == _currentWeatherCode;

                  return GestureDetector(
                    onTap: () => setState(() => _currentWeatherCode = preset.code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            preset.icon,
                            size: 32,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Custom code input
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                child: Row(
                  children: [
                    const Text('Custom Code:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _currentWeatherCode.toDouble(),
                        min: 0,
                        max: 99,
                        divisions: 99,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                        label: _currentWeatherCode.toString(),
                        onChanged: (value) =>
                            setState(() => _currentWeatherCode = value.round()),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        _currentWeatherCode.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
