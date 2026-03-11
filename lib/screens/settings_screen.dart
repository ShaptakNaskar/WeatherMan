import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/debug_weather_screen.dart';
import 'package:weatherman/screens/search_screen.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tapCount = 0;
  bool _devUnlocked = false;

  void _onCloudTap() {
    setState(() {
      _tapCount++;
      Fluttertoast.cancel();
      if (_tapCount >= 7 && !_devUnlocked) {
        _devUnlocked = true;
        Fluttertoast.showToast(msg: '🎉 Developer options unlocked!');
      } else if (!_devUnlocked && (7 - _tapCount) <= 3) {
        Fluttertoast.showToast(msg: '${7 - _tapCount} more taps...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locP, wP, _) {
        final w = locP.selectedLocation != null
            ? wP.getWeather(locP.selectedLocation!)
            : null;
        return DynamicBackground(
          weatherCode: w?.current.weatherCode ?? 0,
          isDay: w?.current.isDay ?? true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent, elevation: 0,
              title: Text('Settings', style: DesignSystem.conditionLabel),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Consumer<SettingsProvider>(
              builder: (context, settings, _) => ListView(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                children: [
                  _tempUnit(settings),
                  const SizedBox(height: DesignSystem.spacingM),
                  _advancedToggle(settings),
                  const SizedBox(height: DesignSystem.spacingM),
                  _locationRow(),
                  const SizedBox(height: DesignSystem.spacingM),
                  _about(),
                  if (kDebugMode || _devUnlocked) ...[
                    const SizedBox(height: DesignSystem.spacingM),
                    _devOptions(),
                  ],
                  const SizedBox(height: DesignSystem.spacingXL),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tempUnit(SettingsProvider s) => PrimaryGlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('TEMPERATURE UNIT', style: DesignSystem.sectionHeader),
      const SizedBox(height: DesignSystem.spacingM),
      Row(children: [
        Expanded(child: GlassPill(
          selected: s.temperatureUnit == TemperatureUnit.celsius,
          onTap: () { HapticFeedback.selectionClick(); s.setTemperatureUnit(TemperatureUnit.celsius); },
          child: Center(child: Text('°C', style: DesignSystem.metricValue)),
        )),
        const SizedBox(width: DesignSystem.spacingS),
        Expanded(child: GlassPill(
          selected: s.temperatureUnit == TemperatureUnit.fahrenheit,
          onTap: () { HapticFeedback.selectionClick(); s.setTemperatureUnit(TemperatureUnit.fahrenheit); },
          child: Center(child: Text('°F', style: DesignSystem.metricValue)),
        )),
      ]),
    ],
  ));

  Widget _advancedToggle(SettingsProvider s) => PrimaryGlassCard(child: Row(
    children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Advanced View', style: DesignSystem.bodyText),
        const SizedBox(height: 2),
        Text('Extra detailed weather metrics', style: DesignSystem.caption),
      ])),
      Switch(
        value: s.advancedViewEnabled,
        onChanged: s.setAdvancedViewEnabled,
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.white.withValues(alpha: 0.4),
        inactiveThumbColor: Colors.white.withValues(alpha: 0.6),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
      ),
    ],
  ));

  Widget _locationRow() => PrimaryGlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('LOCATION', style: DesignSystem.sectionHeader),
      const SizedBox(height: DesignSystem.spacingM),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Row(children: [
          Icon(Icons.search, size: 18, color: DesignSystem.textSecondary),
          const SizedBox(width: 8),
          Text('Search location', style: DesignSystem.bodyText),
          const Spacer(),
          Icon(Icons.chevron_right, size: 18, color: DesignSystem.textTertiary),
        ]),
      ),
      Divider(color: Colors.white.withValues(alpha: 0.08), height: 24),
      GestureDetector(
        onTap: () async {
          final locP = context.read<LocationProvider>();
          await locP.fetchCurrentLocation();
          if (mounted) Navigator.pop(context);
        },
        child: Row(children: [
          Icon(Icons.my_location, size: 18, color: DesignSystem.textSecondary),
          const SizedBox(width: 8),
          Text('Use current location', style: DesignSystem.bodyText),
        ]),
      ),
    ],
  ));

  Widget _about() => PrimaryGlassCard(child: Column(children: [
    const SizedBox(height: DesignSystem.spacingS),
    GestureDetector(
      onTap: _onCloudTap,
      child: Icon(Icons.cloud_rounded, size: 44, color: DesignSystem.textPrimary),
    ),
    const SizedBox(height: DesignSystem.spacingS),
    Text('WeatherMan', style: DesignSystem.tempLarge),
    Text('v1.0.6', style: DesignSystem.caption),
    const SizedBox(height: DesignSystem.spacingM),
    Text('Made with ❤️ by Sappy', style: DesignSystem.bodyText),
    const SizedBox(height: DesignSystem.spacingXS),
    GestureDetector(
      onTap: () => launchUrl(Uri.parse('https://sappy-dir.vercel.app'), mode: LaunchMode.externalApplication),
      child: Text('Visit my website →', style: DesignSystem.caption.copyWith(
        decoration: TextDecoration.underline, decorationColor: DesignSystem.textTertiary,
      )),
    ),
    const SizedBox(height: DesignSystem.spacingM),
    Divider(color: Colors.white.withValues(alpha: 0.08)),
    const SizedBox(height: DesignSystem.spacingS),
    Text('Weather data by Open-Meteo', style: DesignSystem.caption),
    Text('Built with Flutter', style: DesignSystem.caption),
    const SizedBox(height: DesignSystem.spacingS),
  ]));

  Widget _devOptions() => PrimaryGlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        const Icon(Icons.bug_report_rounded, color: Colors.orange, size: 18),
        const SizedBox(width: 6),
        Text('DEVELOPER', style: DesignSystem.sectionHeader),
      ]),
      const SizedBox(height: DesignSystem.spacingM),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebugWeatherScreen())),
        child: Row(children: [
          Icon(Icons.palette_outlined, size: 18, color: DesignSystem.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text('Weather Styles Preview', style: DesignSystem.bodyText)),
          Icon(Icons.chevron_right, size: 18, color: DesignSystem.textTertiary),
        ]),
      ),
    ],
  ));
}
