/// Temperature unit enum
enum TemperatureUnit { celsius, fahrenheit }

/// Unit conversion utilities
class UnitConverter {
  /// Convert Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Format temperature with unit
  static String formatTemperature(double celsius, TemperatureUnit unit, {bool showUnit = true}) {
    final temp = unit == TemperatureUnit.celsius ? celsius : celsiusToFahrenheit(celsius);
    final rounded = temp.round();
    if (showUnit) {
      return '$rounded°${unit == TemperatureUnit.celsius ? 'C' : 'F'}';
    }
    return '$rounded°';
  }

  /// Format temperature without unit symbol (just number and degree)
  static String formatTemperatureShort(double celsius, TemperatureUnit unit) {
    final temp = unit == TemperatureUnit.celsius ? celsius : celsiusToFahrenheit(celsius);
    return '${temp.round()}°';
  }

  /// Convert km/h to mph
  static double kmhToMph(double kmh) {
    return kmh * 0.621371;
  }

  /// Format wind speed
  static String formatWindSpeed(double kmh, {bool useMetric = true}) {
    if (useMetric) {
      return '${kmh.round()} km/h';
    }
    return '${kmhToMph(kmh).round()} mph';
  }

  /// Format pressure in hPa
  static String formatPressure(double hPa) {
    return '${hPa.round()} hPa';
  }

  /// Format precipitation in mm
  static String formatPrecipitation(double mm) {
    if (mm < 0.1) return '0 mm';
    if (mm < 1) return '${mm.toStringAsFixed(1)} mm';
    return '${mm.round()} mm';
  }

  /// Format percentage
  static String formatPercentage(int value) {
    return '$value%';
  }
}
