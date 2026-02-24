import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Pushes cached weather into the home screen widget via home_widget
class WidgetService {
  static const String _providerName = 'WeatherHomeWidgetProvider';

  /// Update widget with latest data
  static Future<void> update(WeatherData data) async {
    final current = data.current;
    final today = data.daily.isNotEmpty ? data.daily.first : null;
    final nextHours = data.hourly.take(3).toList();

    final hourSummary = nextHours
        .map((h) =>
            '${DateFormat.H().format(h.time)}h ${h.temperature.toStringAsFixed(0)}°')
        .join(' • ');

    await HomeWidget.saveWidgetData<String>('widget_temp', '${current.temperature.toStringAsFixed(1)}°');
    await HomeWidget.saveWidgetData<String>('widget_condition', WeatherUtils.getWeatherDescription(current.weatherCode));
    await HomeWidget.saveWidgetData<String>('widget_high', today != null ? today.temperatureMax.toStringAsFixed(0) : '--');
    await HomeWidget.saveWidgetData<String>('widget_low', today != null ? today.temperatureMin.toStringAsFixed(0) : '--');
    await HomeWidget.saveWidgetData<String>('widget_hours', hourSummary);
    await HomeWidget.saveWidgetData<String>('widget_bg', _bgKey(current.weatherCode));

    await HomeWidget.updateWidget(name: _providerName);
  }

  static String _bgKey(int code) {
    if (code >= 61 && code <= 67 || code >= 80 && code <= 82) return 'rain';
    if (code >= 71 && code <= 77 || code >= 85 && code <= 86) return 'snow';
    if (code == 2 || code == 3 || code == 45 || code == 48) return 'cloud';
    return 'clear';
  }
}
