import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/widgets/backgrounds/dynamic_background.dart';
import 'package:weatherman/widgets/backgrounds/weather_gradient_system.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';
import 'package:weatherman/widgets/weather/weather_icon_painter.dart';

class DebugWeatherScreen extends StatefulWidget {
  const DebugWeatherScreen({super.key});
  @override
  State<DebugWeatherScreen> createState() => _DebugWeatherScreenState();
}

class _DebugWeatherScreenState extends State<DebugWeatherScreen> {
  int _code = 0;
  bool _isDay = true;

  static const _presets = [
    (code: 0, name: 'Clear Sky'),
    (code: 1, name: 'Mainly Clear'),
    (code: 2, name: 'Partly Cloudy'),
    (code: 3, name: 'Overcast'),
    (code: 51, name: 'Light Drizzle'),
    (code: 61, name: 'Light Rain'),
    (code: 63, name: 'Moderate Rain'),
    (code: 65, name: 'Heavy Rain'),
    (code: 71, name: 'Light Snow'),
    (code: 75, name: 'Heavy Snow'),
    (code: 95, name: 'Thunderstorm'),
    (code: 45, name: 'Fog'),
  ];

  @override
  Widget build(BuildContext context) {
    final style = WeatherGradientSystem.fromCode(_code, _isDay);
    return DynamicBackground(
      weatherCode: _code,
      isDay: _isDay,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          title: Text('Weather Styles', style: DesignSystem.conditionLabel),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Column(children: [
          Expanded(flex: 2, child: Center(child: _info(style))),
          _dayNight(),
          const SizedBox(height: DesignSystem.spacingS),
          Expanded(flex: 3, child: _grid()),
          _slider(),
        ]),
      ),
    );
  }

  Widget _info(dynamic style) => PrimaryGlassCard(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      WeatherIconPainter.forCode(_code, isDay: _isDay, size: 48),
      const SizedBox(height: DesignSystem.spacingS),
      Text('Code: $_code', style: DesignSystem.metricValue),
      const SizedBox(height: DesignSystem.spacingXS),
      Text(
        _presets.where((p) => p.code == _code).firstOrNull?.name ?? 'Code $_code',
        style: DesignSystem.conditionLabel,
      ),
      const SizedBox(height: DesignSystem.spacingS),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 20,
          decoration: BoxDecoration(color: style.glassTint, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(_isDay ? 'Day' : 'Night', style: DesignSystem.caption),
      ]),
    ],
  ));

  Widget _dayNight() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
    child: SecondaryGlassCard(child: Row(children: [
      Icon(Icons.wb_sunny, size: 18, color: DesignSystem.textSecondary),
      const SizedBox(width: 6),
      Text('Day', style: DesignSystem.caption),
      const Spacer(),
      Switch(value: _isDay, onChanged: (v) => setState(() => _isDay = v),
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.white.withValues(alpha: 0.4),
        inactiveThumbColor: Colors.white.withValues(alpha: 0.6),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.15)),
      const Spacer(),
      Text('Night', style: DesignSystem.caption),
      const SizedBox(width: 6),
      Icon(Icons.nightlight_round, size: 18, color: DesignSystem.textSecondary),
    ])),
  );

  Widget _grid() => GridView.builder(
    padding: const EdgeInsets.all(DesignSystem.spacingM),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, childAspectRatio: 1,
      crossAxisSpacing: 10, mainAxisSpacing: 10),
    itemCount: _presets.length,
    itemBuilder: (context, i) {
      final p = _presets[i];
      final sel = p.code == _code;
      return GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(() => _code = p.code); },
        child: AnimatedContainer(
          duration: DesignSystem.durationFast,
          transform: sel ? Matrix4.diagonal3Values(1.05, 1.05, 1.0) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: sel ? 0.22 : 0.08),
            borderRadius: BorderRadius.circular(DesignSystem.radiusTile),
            border: Border.all(
              color: Colors.white.withValues(alpha: sel ? 0.5 : 0.15),
              width: sel ? 1.5 : 0.8)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            WeatherIconPainter.forCode(p.code, isDay: _isDay, size: 28),
            const SizedBox(height: 6),
            Text(p.name, style: DesignSystem.metricLabel, textAlign: TextAlign.center, maxLines: 2),
          ]),
        ),
      );
    },
  );

  Widget _slider() => Padding(
    padding: const EdgeInsets.all(DesignSystem.spacingM),
    child: SecondaryGlassCard(child: Row(children: [
      Text('Code', style: DesignSystem.metricLabel),
      const SizedBox(width: 8),
      Expanded(child: Slider(
        value: _code.toDouble(), min: 0, max: 99, divisions: 99,
        activeColor: Colors.white, inactiveColor: Colors.white24,
        label: _code.toString(),
        onChanged: (v) => setState(() => _code = v.round()))),
      SizedBox(width: 36, child: Text('$_code', style: DesignSystem.metricValue, textAlign: TextAlign.center)),
    ])),
  );
}

extension DebugMode on BuildContext {
  static bool get isDebugMode => kDebugMode;
}
