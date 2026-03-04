import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/debug_weather_screen.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_background.dart';
import 'package:weatherman/widgets/cyberpunk/cyber_glass_card.dart';

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
  WeatherData? _latestWeather;

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

  Future<void> _sendDebugNotification() async {
    await NotificationService.instance.showNow(
      title: 'DEBUG PING // CYBERWEATHER',
      body: 'Notif pipeline hotwired. Rerouting signals to your HUD.',
    );
  }

  Future<void> _sendAllTestNotifications() async {
    // Test morning briefing
    if (_latestWeather != null) {
      await NotificationService.instance.showMorningBriefing(_latestWeather!);
    } else {
      await NotificationService.instance.showNow(
        title: '☀️ Good Morning — Test City',
        body: 'Today: Partly cloudy, 18°–28°C. No rain expected this morning.',
      );
    }

    // Test evening outlook
    if (_latestWeather != null) {
      await NotificationService.instance.showEveningOutlook(_latestWeather!);
    } else {
      await NotificationService.instance.showNow(
        title: '🌙 Evening Outlook — Test City',
        body: 'Currently 22°C. Tomorrow: Partly cloudy, 17°–26°C. Week range: 15°–30°C.',
      );
    }

    // Test severe alert
    await NotificationService.instance.showSevereAlert(const TrendInsight(
      title: '⚡ Thunderstorm Alert [TEST]',
      body: 'Thunderstorm expected in ~3h. Secure outdoor gear and find shelter.',
      severity: InsightSeverity.severe,
    ));

    // Test insight
    await NotificationService.instance.showInsight(const TrendInsight(
      title: '📈 Warming Trend [TEST]',
      body: 'Temperatures rising over the next 7 days — highs climbing from 24° to ~31°C.',
    ));

    // Persistent preview
    if (_latestWeather != null) {
      await NotificationService.instance.showPersistent(_latestWeather!);
    }
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
        _latestWeather = weather;

        return CyberpunkBackground(
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
                return OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      // Enable immersive fullscreen mode in landscape
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky,
                        overlays: [],
                      );
                      return _buildLandscapeLayout(settings);
                    }
                    // Restore normal UI in portrait
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                      overlays: SystemUiOverlay.values,
                    );
                    return _buildPortraitLayout(settings);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(SettingsProvider settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._buildControlsSection(settings),
        const SizedBox(height: 16),
        _buildAboutSection(),
        ..._buildDeveloperSection(settings),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLandscapeLayout(SettingsProvider settings) {
    return Row(
      children: [
        // Left panel - About section (static)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildAboutSection(),
            ),
          ),
        ),
        // Divider
        Container(
          width: 1,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        // Right panel - Controls (scrollable)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._buildControlsSection(settings),
              ..._buildDeveloperSection(settings),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildControlsSection(SettingsProvider settings) {
    return [
      // Temperature unit
      CyberGlassCard(
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
      CyberGlassCard(
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
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // ── Notification Controls ────────────────────────────────
      CyberGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: CyberpunkTheme.neonCyan,
                  size: 20,
                  shadows: CyberpunkTheme.subtleCyanGlow,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    shadows: _textShadows,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Persistent weather status
            _NotifToggle(
              icon: Icons.pin_rounded,
              title: 'Live Weather Status',
              subtitle: 'Ongoing notification with current conditions',
              value: settings.persistentNotificationEnabled,
              onChanged: (val) async {
                await settings.setPersistentNotificationEnabled(val);
                if (val && _latestWeather != null) {
                  await NotificationService.instance.showPersistent(_latestWeather!);
                } else if (!val) {
                  await NotificationService.instance.cancelPersistent();
                }
              },
            ),
            _notifDivider(),

            // Morning briefing
            _NotifToggle(
              icon: Icons.wb_sunny_rounded,
              title: 'Morning Briefing',
              subtitle: 'Daily summary at ~7 AM with rain, UV, wind',
              value: settings.morningBriefingEnabled,
              onChanged: (val) => settings.setMorningBriefingEnabled(val),
            ),
            _notifDivider(),

            // Evening outlook
            _NotifToggle(
              icon: Icons.nightlight_round,
              title: 'Evening Outlook',
              subtitle: 'Tomorrow preview + week range at ~5 PM',
              value: settings.eveningOutlookEnabled,
              onChanged: (val) => settings.setEveningOutlookEnabled(val),
            ),
            _notifDivider(),

            // Severe weather alerts
            _NotifToggle(
              icon: Icons.warning_amber_rounded,
              title: 'Severe Weather Alerts',
              subtitle: 'Thunderstorms, extreme heat/cold, heavy rain',
              value: settings.severeAlertsEnabled,
              onChanged: (val) => settings.setSevereAlertsEnabled(val),
              accentColor: CyberpunkTheme.neonRed,
            ),
            _notifDivider(),

            // Trend insights
            _NotifToggle(
              icon: Icons.insights_rounded,
              title: 'Weather Insights',
              subtitle: 'Warming/cooling trends, rain probability, UV',
              value: settings.trendInsightsEnabled,
              onChanged: (val) => settings.setTrendInsightsEnabled(val),
            ),
          ],
        ),
      ),

    ];
  }

  Widget _notifDivider() {
    return Divider(
      height: 1,
      color: CyberpunkTheme.neonCyan.withValues(alpha: 0.1),
    );
  }

  Widget _buildAboutSection() {
    return CyberGlassCard(
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
                color: CyberpunkTheme.neonCyan,
                shadows: CyberpunkTheme.neonCyanGlow,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'CyberWeather',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CyberpunkTheme.neonCyan,
                letterSpacing: 3,
                shadows: CyberpunkTheme.subtleCyanGlow,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.1.0_CYBER',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Coded with ❤️ by Sappy',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: CyberpunkTheme.neonBlue,
                shadows: CyberpunkTheme.neonCyanGlow,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://sappy-dir.vercel.app'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                '> VISIT_NODE →',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: CyberpunkTheme.neonCyan,
                  decoration: TextDecoration.underline,
                  decorationColor: CyberpunkTheme.neonCyan.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text(
              '// DATA_SRC: Open-Meteo //',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '// FRAMEWORK: Flutter //',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: CyberpunkTheme.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDeveloperSection(SettingsProvider settings) {
    if (!kDebugMode && !_developerOptionsUnlocked) {
      return [];
    }

    return [
      const SizedBox(height: 16),
      CyberGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report_rounded,
                  color: CyberpunkTheme.neonYellow,
                  size: 20,
                  shadows: CyberpunkTheme.neonYellowGlow,
                ),
                const SizedBox(width: 8),
                Text(
                  '// DEV_OPTIONS //',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: CyberpunkTheme.neonYellow,
                    letterSpacing: 2,
                    shadows: CyberpunkTheme.neonYellowGlow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DebugButton(
              icon: Icons.palette_outlined,
              title: 'DEBUG_CONSOLE',
              subtitle: 'Weather FX + Alert simulator',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugWeatherScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _DebugButton(
              icon: Icons.notifications_active,
              title: 'DEBUG_NOTIFICATION',
              subtitle: 'Send a test briefing notification',
              onTap: _sendDebugNotification,
            ),
            const SizedBox(height: 12),
            _DebugButton(
              icon: Icons.science,
              title: 'TEST_ALERTS',
              subtitle: 'Test morning, evening, and trend alerts',
              onTap: _sendAllTestNotifications,
            ),
          ],
        ),
      ),
    ];
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
          color: CyberpunkTheme.neonYellow.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: CyberpunkTheme.neonYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: CyberpunkTheme.neonYellow, shadows: CyberpunkTheme.neonYellowGlow),
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
                      color: CyberpunkTheme.textSecondary,
                      shadows: _textShadows,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: CyberpunkTheme.neonYellow),
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
              ? CyberpunkTheme.neonCyan.withValues(alpha: 0.1)
              : CyberpunkTheme.bgPanel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? CyberpunkTheme.neonCyan.withValues(alpha: 0.5)
                : CyberpunkTheme.neonCyan.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 0.5,
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
                color: isSelected ? CyberpunkTheme.textPrimary : CyberpunkTheme.textSecondary,
                shadows: _textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification toggle row widget
class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? accentColor;

  // Text shadows for legibility
  static const List<Shadow> _textShadows = [
    Shadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  const _NotifToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? CyberpunkTheme.neonCyan;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20, shadows: [
            Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
          ]),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    shadows: _textShadows,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: color.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.7),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
