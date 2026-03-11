import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/settings_provider.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/widgets/weather/weather_icon_painter.dart';

/// Hero section: large icon, temperature, condition, feels-like.
class CurrentWeatherDisplay extends StatelessWidget {
  final CurrentWeather weather;
  final String locationName;
  final double temperatureMax;
  final double temperatureMin;

  const CurrentWeatherDisplay({
    super.key,
    required this.weather,
    required this.locationName,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final tempValue = settings.temperatureUnit == TemperatureUnit.celsius
        ? weather.temperature
        : UnitConverter.celsiusToFahrenheit(weather.temperature);

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weather icon
          WeatherIconPainter.forCode(
            weather.weatherCode,
            isDay: weather.isDay,
            size: DesignSystem.iconHero,
          ),
          const SizedBox(height: DesignSystem.spacingM),

          // Temperature hero
          Text('${tempValue.round()}°', style: DesignSystem.tempHero),
          const SizedBox(height: DesignSystem.spacingXS),

          // Condition label
          Text(
            WeatherUtils.getWeatherDescription(weather.weatherCode),
            style: DesignSystem.conditionLabel,
          ),
          const SizedBox(height: DesignSystem.spacingS),

          // Feels like + humidity
          Text(
            'Feels like ${settings.formatTempShort(weather.apparentTemperature)}'
            '  ·  Humidity ${weather.relativeHumidity}%',
            style: DesignSystem.caption,
          ),
          const SizedBox(height: DesignSystem.spacingS),

          // High / Low
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'H:${settings.formatTempShort(temperatureMax)}',
                style: DesignSystem.caption.copyWith(color: DesignSystem.textPrimary),
              ),
              const SizedBox(width: DesignSystem.spacingM),
              Text(
                'L:${settings.formatTempShort(temperatureMin)}',
                style: DesignSystem.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
