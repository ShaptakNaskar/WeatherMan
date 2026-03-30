import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/debug_weather_screen.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/widgets/themed/themed_background.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Easter egg: tap cloud icon 7 times to unlock developer options
  int _tapCount = 0;
  bool _developerOptionsUnlocked = false;
  static const int _requiredTaps = 7;
  WeatherData? _latestWeather;

  void _onCloudTap() {
    setState(() {
      _tapCount++;
      Fluttertoast.cancel();

      if (_tapCount >= _requiredTaps && !_developerOptionsUnlocked) {
        _developerOptionsUnlocked = true;
        Fluttertoast.showToast(
          msg: 'Developer options unlocked!',
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
      title: 'DEBUG — SappyWeather',
      body: 'Notification pipeline is working.',
    );
  }

  Future<void> _sendAllTestNotifications() async {
    if (_latestWeather != null) {
      await NotificationService.instance.showMorningBriefing(_latestWeather!);
    } else {
      await NotificationService.instance.showNow(
        title: 'Good Morning — Test City',
        body: 'Today: Partly cloudy, 18°–28°C. No rain expected this morning.',
      );
    }

    if (_latestWeather != null) {
      await NotificationService.instance.showEveningOutlook(_latestWeather!);
    } else {
      await NotificationService.instance.showNow(
        title: 'Evening Outlook — Test City',
        body:
            'Currently 22°C. Tomorrow: Partly cloudy, 17°–26°C. Week range: 15°–30°C.',
      );
    }

    await NotificationService.instance.showSevereAlert(
      const TrendInsight(
        title: 'Thunderstorm Alert [TEST]',
        body:
            'Thunderstorm expected in ~3h. Secure outdoor gear and find shelter.',
        severity: InsightSeverity.severe,
      ),
    );

    await NotificationService.instance.showInsight(
      const TrendInsight(
        title: 'Warming Trend [TEST]',
        body:
            'Temperatures rising over the next 7 days — highs climbing from 24° to ~31°C.',
      ),
    );

    if (_latestWeather != null) {
      await NotificationService.instance.showPersistent(_latestWeather!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final t = themeProvider.current;

    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locationProvider, weatherProvider, _) {
        final currentLocation = locationProvider.selectedLocation;
        final weather = currentLocation != null
            ? weatherProvider.getWeather(currentLocation)
            : null;
        final weatherCode = weather?.current.weatherCode ?? 0;
        final isDay = weather?.current.isDay ?? true;
        _latestWeather = weather;

        return ThemedBackground(
          weatherCode: weatherCode,
          isDay: isDay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text('Settings', style: TextStyle(shadows: t.textShadows)),
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
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky,
                        overlays: [],
                      );
                      return _buildLandscapeLayout(settings, t);
                    }
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                      overlays: SystemUiOverlay.values,
                    );
                    return _buildPortraitLayout(settings, t);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(SettingsProvider settings, AppThemeData t) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildThemePickerSection(t),
        const SizedBox(height: 16),
        ..._buildControlsSection(settings, t),
        const SizedBox(height: 16),
        _buildAboutSection(t),
        ..._buildDeveloperSection(settings, t),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLandscapeLayout(SettingsProvider settings, AppThemeData t) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAboutSection(t),
                  const SizedBox(height: 16),
                  _buildThemePickerSection(t),
                ],
              ),
            ),
          ),
        ),
        Container(width: 1, color: t.textTertiary.withValues(alpha: 0.15)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._buildControlsSection(settings, t),
              ..._buildDeveloperSection(settings, t),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ── Theme Picker ────────────────────────────────────────
  Widget _buildThemePickerSection(AppThemeData t) {
    final themeProvider = context.read<ThemeProvider>();

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, size: 20, color: t.accentColor),
              const SizedBox(width: 8),
              Text(
                'Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(shadows: t.textShadows),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 500 ? 3 : 3;
              final spacing = 10.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: AppThemeType.values.map((type) {
                  final isSelected = themeProvider.currentType == type;
                  return SizedBox(
                    width: cardWidth,
                    child: _ThemePreviewCard(
                      type: type,
                      isSelected: isSelected,
                      currentTheme: t,
                      onTap: () => themeProvider.setTheme(type),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildControlsSection(
    SettingsProvider settings,
    AppThemeData t,
  ) {
    return [
      // Temperature unit
      ThemedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Unit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(shadows: t.textShadows),
            ),
            const SizedBox(height: 16),
            _TemperatureUnitSelector(
              currentUnit: settings.temperatureUnit,
              onChanged: settings.setTemperatureUnit,
              theme: t,
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Advanced View toggle
      ThemedCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced View',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(shadows: t.textShadows),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Show detailed weather data with extra metrics',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      shadows: t.textShadows,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: settings.advancedViewEnabled,
              onChanged: (value) => settings.setAdvancedViewEnabled(value),
              activeThumbColor: t.accentColor,
              activeTrackColor: t.accentColor.withValues(alpha: 0.4),
              inactiveThumbColor: t.textTertiary,
              inactiveTrackColor: t.textTertiary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Notification Controls
      ThemedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: t.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(shadows: t.textShadows),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _NotifToggle(
              icon: Icons.pin_rounded,
              title: 'Live Weather Status',
              subtitle: 'Ongoing notification with current conditions',
              value: settings.persistentNotificationEnabled,
              theme: t,
              onChanged: (val) async {
                await settings.setPersistentNotificationEnabled(val);
                if (val && _latestWeather != null) {
                  await NotificationService.instance.showPersistent(
                    _latestWeather!,
                  );
                } else if (!val) {
                  await NotificationService.instance.cancelPersistent();
                }
              },
            ),
            Divider(height: 1, color: t.accentColor.withValues(alpha: 0.1)),

            _NotifToggle(
              icon: Icons.wb_sunny_rounded,
              title: 'Morning Briefing',
              subtitle: 'Daily summary at ~7 AM with rain, UV, wind',
              value: settings.morningBriefingEnabled,
              theme: t,
              onChanged: (val) => settings.setMorningBriefingEnabled(val),
            ),
            Divider(height: 1, color: t.accentColor.withValues(alpha: 0.1)),

            _NotifToggle(
              icon: Icons.nightlight_round,
              title: 'Evening Outlook',
              subtitle: 'Tomorrow preview + week range at ~5 PM',
              value: settings.eveningOutlookEnabled,
              theme: t,
              onChanged: (val) => settings.setEveningOutlookEnabled(val),
            ),
            Divider(height: 1, color: t.accentColor.withValues(alpha: 0.1)),

            _NotifToggle(
              icon: Icons.warning_amber_rounded,
              title: 'Severe Weather Alerts',
              subtitle: 'Thunderstorms, extreme heat/cold, heavy rain',
              value: settings.severeAlertsEnabled,
              theme: t,
              onChanged: (val) => settings.setSevereAlertsEnabled(val),
              accentColor: t.dangerColor,
            ),
            Divider(height: 1, color: t.accentColor.withValues(alpha: 0.1)),

            _NotifToggle(
              icon: Icons.insights_rounded,
              title: 'Weather Insights',
              subtitle: 'Warming/cooling trends, rain probability, UV',
              value: settings.trendInsightsEnabled,
              theme: t,
              onChanged: (val) => settings.setTrendInsightsEnabled(val),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildAboutSection(AppThemeData t) {
    return ThemedCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _onCloudTap,
              child: Icon(Icons.cloud_rounded, size: 48, color: t.accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              'SappyWeather',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: t.accentColor,
                letterSpacing: 3,
                shadows: t.subtleGlow,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v2.0.0',
              style: TextStyle(
                fontSize: 12,
                color: t.textTertiary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Coded with love by Sappy',
              style: TextStyle(
                fontSize: 14,
                color: t.accentColorSecondary,
                shadows: t.subtleGlow,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://sappy-dir.vercel.app'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                'Visit Website',
                style: TextStyle(
                  fontSize: 13,
                  color: t.accentColor,
                  decoration: TextDecoration.underline,
                  decorationColor: t.accentColor.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: t.accentColor.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text(
              'Data: Open-Meteo',
              style: TextStyle(
                fontSize: 11,
                color: t.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Framework: Flutter',
              style: TextStyle(
                fontSize: 11,
                color: t.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDeveloperSection(
    SettingsProvider settings,
    AppThemeData t,
  ) {
    if (!kDebugMode && !_developerOptionsUnlocked) {
      return [];
    }

    return [
      const SizedBox(height: 16),
      ThemedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report_rounded, color: t.warningColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Developer Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.warningColor,
                    shadows: t.textShadows,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DebugButton(
              icon: Icons.palette_outlined,
              title: 'Debug Console',
              subtitle: 'Weather FX + Alert simulator',
              theme: t,
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
              title: 'Debug Notification',
              subtitle: 'Send a test briefing notification',
              theme: t,
              onTap: _sendDebugNotification,
            ),
            const SizedBox(height: 12),
            _DebugButton(
              icon: Icons.science,
              title: 'Test Alerts',
              subtitle: 'Test morning, evening, and trend alerts',
              theme: t,
              onTap: _sendAllTestNotifications,
            ),
          ],
        ),
      ),
    ];
  }
}

// ── Theme Preview Card ────────────────────────────────────

class _ThemePreviewCard extends StatelessWidget {
  final AppThemeType type;
  final bool isSelected;
  final AppThemeData currentTheme;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.type,
    required this.isSelected,
    required this.currentTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (String label, List<Color> colors, IconData icon) = switch (type) {
      AppThemeType.clean => (
        'Clean',
        [
          const Color(0xFF1A2340),
          const Color(0xFF2D3561),
          const Color(0xFF4B6CB7),
        ],
        Icons.water_drop_rounded,
      ),
      AppThemeType.cyberpunk => (
        'Cyber',
        [
          const Color(0xFF0a0a1a),
          const Color(0xFF00e5ff),
          const Color(0xFFff2a6d),
        ],
        Icons.bolt_rounded,
      ),
      // AppThemeType.pastel => (
      //     'Pastel',
      //     [const Color(0xFFB8A9E8), const Color(0xFF98E4C9), const Color(0xFFFFC3A0)],
      //     Icons.favorite_rounded,
      //   ),
      AppThemeType.pastelDark => (
        'Pastel Dark',
        [
          const Color(0xFF1A1525),
          const Color(0xFF7B5EAE),
          const Color(0xFFCBB8F0),
        ],
        Icons.nightlight_round,
      ),
      AppThemeType.sunset => (
        'Sunset',
        [
          const Color(0xFF1A1018),
          const Color(0xFFFF8A50),
          const Color(0xFFFF6B8A),
        ],
        Icons.wb_twilight_rounded,
      ),
      AppThemeType.ocean => (
        'Ocean',
        [
          const Color(0xFF0A1520),
          const Color(0xFF00BFA5),
          const Color(0xFF40C4FF),
        ],
        Icons.waves_rounded,
      ),
    };

    final t = currentTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.cardBorderRadius),
          border: Border.all(
            color: isSelected
                ? t.accentColor.withValues(alpha: 0.8)
                : t.textTertiary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? t.accentColor.withValues(alpha: 0.08)
              : t.cardColor.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            // Color preview dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors
                  .map(
                    (c) => Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Icon(
              icon,
              size: 18,
              color: isSelected ? t.accentColor : t.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? t.accentColor : t.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                shadows: t.textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Debug Button ──────────────────────────────────────────

class _DebugButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final AppThemeData theme;

  const _DebugButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.warningColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(t.cardBorderRadius * 0.5),
          border: Border.all(color: t.warningColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: t.warningColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      shadows: t.textShadows,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      shadows: t.textShadows,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.warningColor),
          ],
        ),
      ),
    );
  }
}

// ── Temperature Unit Selector ─────────────────────────────

class _TemperatureUnitSelector extends StatelessWidget {
  final TemperatureUnit currentUnit;
  final ValueChanged<TemperatureUnit> onChanged;
  final AppThemeData theme;

  const _TemperatureUnitSelector({
    required this.currentUnit,
    required this.onChanged,
    required this.theme,
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
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _UnitButton(
            label: 'Fahrenheit',
            symbol: '°F',
            isSelected: currentUnit == TemperatureUnit.fahrenheit,
            onTap: () => onChanged(TemperatureUnit.fahrenheit),
            theme: theme,
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
  final AppThemeData theme;

  const _UnitButton({
    required this.label,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? t.accentColor.withValues(alpha: 0.1)
              : t.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(t.cardBorderRadius * 0.5),
          border: Border.all(
            color: isSelected
                ? t.accentColor.withValues(alpha: 0.5)
                : t.textTertiary.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                shadows: t.textShadows,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? t.textPrimary : t.textSecondary,
                shadows: t.textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Toggle ───────────────────────────────────

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppThemeData theme;
  final Color? accentColor;

  const _NotifToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final color = accentColor ?? t.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    shadows: t.textShadows,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    shadows: t.textShadows,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
            inactiveThumbColor: t.textTertiary,
            inactiveTrackColor: t.textTertiary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
