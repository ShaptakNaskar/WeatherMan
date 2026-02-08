import 'package:weatherman/models/location.dart';

/// Complete weather data model
class WeatherData {
  final LocationModel location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality? airQuality;
  final DateTime fetchedAt;

  WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    this.airQuality,
    required this.fetchedAt,
  });

  WeatherData copyWith({AirQuality? airQuality}) {
    return WeatherData(
      location: location,
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: airQuality ?? this.airQuality,
      fetchedAt: fetchedAt,
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json, LocationModel location) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    // Parse hourly data
    final hourlyTimes = (hourlyJson['time'] as List).cast<String>();
    final hourlyTemps = (hourlyJson['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourlyJson['weather_code'] as List).cast<int>();
    final hourlyPrecipProb = (hourlyJson['precipitation_probability'] as List).cast<int?>();
    final hourlyIsDay = (hourlyJson['is_day'] as List).cast<int>();
    final hourlyHumidity = (hourlyJson['relative_humidity_2m'] as List?)?.cast<int?>() ?? [];
    final hourlyApparent = (hourlyJson['apparent_temperature'] as List?)?.cast<num?>() ?? [];
    final hourlyWindSpeed = (hourlyJson['wind_speed_10m'] as List?)?.cast<num?>() ?? [];
    final hourlyWindDir = (hourlyJson['wind_direction_10m'] as List?)?.cast<int?>() ?? [];
    final hourlyVisibility = (hourlyJson['visibility'] as List?)?.cast<num?>() ?? [];
    final hourlyUv = (hourlyJson['uv_index'] as List?)?.cast<num?>() ?? [];
    final hourlyPrecip = (hourlyJson['precipitation'] as List?)?.cast<num?>() ?? [];
    final hourlyRain = (hourlyJson['rain'] as List?)?.cast<num?>() ?? [];
    final hourlySnow = (hourlyJson['snowfall'] as List?)?.cast<num?>() ?? [];

    final hourlyList = <HourlyForecast>[];
    for (var i = 0; i < hourlyTimes.length && i < 48; i++) {
      hourlyList.add(HourlyForecast(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i].toDouble(),
        weatherCode: hourlyCodes[i],
        precipitationProbability: hourlyPrecipProb[i] ?? 0,
        isDay: hourlyIsDay[i] == 1,
        humidity: i < hourlyHumidity.length ? hourlyHumidity[i] ?? 0 : 0,
        apparentTemperature: i < hourlyApparent.length ? hourlyApparent[i]?.toDouble() ?? 0 : 0,
        windSpeed: i < hourlyWindSpeed.length ? hourlyWindSpeed[i]?.toDouble() ?? 0 : 0,
        windDirection: i < hourlyWindDir.length ? hourlyWindDir[i] ?? 0 : 0,
        visibility: i < hourlyVisibility.length ? hourlyVisibility[i]?.toDouble() ?? 0 : 0,
        uvIndex: i < hourlyUv.length ? hourlyUv[i]?.toDouble() ?? 0 : 0,
        precipitation: i < hourlyPrecip.length ? hourlyPrecip[i]?.toDouble() ?? 0 : 0,
        rain: i < hourlyRain.length ? hourlyRain[i]?.toDouble() ?? 0 : 0,
        snowfall: i < hourlySnow.length ? hourlySnow[i]?.toDouble() ?? 0 : 0,
      ));
    }

    // Parse daily data
    final dailyTimes = (dailyJson['time'] as List).cast<String>();
    final dailyCodes = (dailyJson['weather_code'] as List).cast<int>();
    final dailyMaxTemps = (dailyJson['temperature_2m_max'] as List).cast<num>();
    final dailyMinTemps = (dailyJson['temperature_2m_min'] as List).cast<num>();
    final dailySunrise = (dailyJson['sunrise'] as List).cast<String>();
    final dailySunset = (dailyJson['sunset'] as List).cast<String>();
    final dailyUvMax = (dailyJson['uv_index_max'] as List).cast<num?>();
    final dailyPrecipSum = (dailyJson['precipitation_sum'] as List).cast<num?>();
    final dailyPrecipProb = (dailyJson['precipitation_probability_max'] as List).cast<int?>();
    final dailyWindMax = (dailyJson['wind_speed_10m_max'] as List).cast<num?>();
    final dailyWindGustsMax = (dailyJson['wind_gusts_10m_max'] as List?)?.cast<num?>() ?? [];
    final dailyWindDirDominant = (dailyJson['wind_direction_10m_dominant'] as List?)?.cast<int?>() ?? [];
    final dailyRainSum = (dailyJson['rain_sum'] as List?)?.cast<num?>() ?? [];
    final dailySnowSum = (dailyJson['snowfall_sum'] as List?)?.cast<num?>() ?? [];
    final dailySunshineDuration = (dailyJson['sunshine_duration'] as List?)?.cast<num?>() ?? [];
    final dailyDaylightDuration = (dailyJson['daylight_duration'] as List?)?.cast<num?>() ?? [];

    final dailyList = <DailyForecast>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      dailyList.add(DailyForecast(
        date: DateTime.parse(dailyTimes[i]),
        weatherCode: dailyCodes[i],
        temperatureMax: dailyMaxTemps[i].toDouble(),
        temperatureMin: dailyMinTemps[i].toDouble(),
        sunrise: DateTime.parse(dailySunrise[i]),
        sunset: DateTime.parse(dailySunset[i]),
        uvIndexMax: dailyUvMax[i]?.toDouble() ?? 0,
        precipitationSum: dailyPrecipSum[i]?.toDouble() ?? 0,
        precipitationProbabilityMax: dailyPrecipProb[i] ?? 0,
        windSpeedMax: dailyWindMax[i]?.toDouble() ?? 0,
        windGustsMax: i < dailyWindGustsMax.length ? dailyWindGustsMax[i]?.toDouble() ?? 0 : 0,
        windDirectionDominant: i < dailyWindDirDominant.length ? dailyWindDirDominant[i] ?? 0 : 0,
        rainSum: i < dailyRainSum.length ? dailyRainSum[i]?.toDouble() ?? 0 : 0,
        snowfallSum: i < dailySnowSum.length ? dailySnowSum[i]?.toDouble() ?? 0 : 0,
        sunshineDuration: i < dailySunshineDuration.length ? dailySunshineDuration[i]?.toDouble() ?? 0 : 0,
        daylightDuration: i < dailyDaylightDuration.length ? dailyDaylightDuration[i]?.toDouble() ?? 0 : 0,
      ));
    }

    return WeatherData(
      location: location,
      current: CurrentWeather.fromJson(currentJson),
      hourly: hourlyList,
      daily: dailyList,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'daily': daily.map((d) => d.toJson()).toList(),
      'airQuality': airQuality?.toJson(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory WeatherData.fromCache(Map<String, dynamic> json) {
    return WeatherData(
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      current: CurrentWeather.fromCache(json['current'] as Map<String, dynamic>),
      hourly: (json['hourly'] as List)
          .map((h) => HourlyForecast.fromCache(h as Map<String, dynamic>))
          .toList(),
      daily: (json['daily'] as List)
          .map((d) => DailyForecast.fromCache(d as Map<String, dynamic>))
          .toList(),
      airQuality: json['airQuality'] != null 
          ? AirQuality.fromCache(json['airQuality'] as Map<String, dynamic>)
          : null,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

/// Current weather conditions
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final bool isDay;
  final double precipitation;
  final double rain;
  final double snowfall;
  final int weatherCode;
  final int cloudCover;
  final double pressure;
  final double surfacePressure;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double uvIndex;
  final double visibility;
  final double dewPoint;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.isDay,
    required this.precipitation,
    required this.rain,
    required this.snowfall,
    required this.weatherCode,
    required this.cloudCover,
    required this.pressure,
    required this.surfacePressure,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.uvIndex,
    required this.visibility,
    required this.dewPoint,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      relativeHumidity: json['relative_humidity_2m'] as int,
      isDay: json['is_day'] == 1,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0,
      snowfall: (json['snowfall'] as num?)?.toDouble() ?? 0,
      weatherCode: json['weather_code'] as int,
      cloudCover: json['cloud_cover'] as int? ?? 0,
      pressure: (json['pressure_msl'] as num?)?.toDouble() ?? 0,
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      windDirection: json['wind_direction_10m'] as int? ?? 0,
      windGusts: (json['wind_gusts_10m'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0,
      dewPoint: (json['dew_point_2m'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'relativeHumidity': relativeHumidity,
      'isDay': isDay,
      'precipitation': precipitation,
      'rain': rain,
      'snowfall': snowfall,
      'weatherCode': weatherCode,
      'cloudCover': cloudCover,
      'pressure': pressure,
      'surfacePressure': surfacePressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'windGusts': windGusts,
      'uvIndex': uvIndex,
      'visibility': visibility,
      'dewPoint': dewPoint,
    };
  }

  factory CurrentWeather.fromCache(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      apparentTemperature: (json['apparentTemperature'] as num).toDouble(),
      relativeHumidity: json['relativeHumidity'] as int,
      isDay: json['isDay'] as bool,
      precipitation: (json['precipitation'] as num).toDouble(),
      rain: (json['rain'] as num).toDouble(),
      snowfall: (json['snowfall'] as num?)?.toDouble() ?? 0,
      weatherCode: json['weatherCode'] as int,
      cloudCover: json['cloudCover'] as int,
      pressure: (json['pressure'] as num).toDouble(),
      surfacePressure: (json['surfacePressure'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: json['windDirection'] as int,
      windGusts: (json['windGusts'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0,
      dewPoint: (json['dewPoint'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Hourly forecast data (expanded)
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final bool isDay;
  final int humidity;
  final double apparentTemperature;
  final double windSpeed;
  final int windDirection;
  final double visibility;
  final double uvIndex;
  final double precipitation;
  final double rain;
  final double snowfall;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
    this.humidity = 0,
    this.apparentTemperature = 0,
    this.windSpeed = 0,
    this.windDirection = 0,
    this.visibility = 0,
    this.uvIndex = 0,
    this.precipitation = 0,
    this.rain = 0,
    this.snowfall = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weatherCode': weatherCode,
      'precipitationProbability': precipitationProbability,
      'isDay': isDay,
      'humidity': humidity,
      'apparentTemperature': apparentTemperature,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'precipitation': precipitation,
      'rain': rain,
      'snowfall': snowfall,
    };
  }

  factory HourlyForecast.fromCache(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      precipitationProbability: json['precipitationProbability'] as int,
      isDay: json['isDay'] as bool,
      humidity: json['humidity'] as int? ?? 0,
      apparentTemperature: (json['apparentTemperature'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      windDirection: json['windDirection'] as int? ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0,
      snowfall: (json['snowfall'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Daily forecast data (expanded)
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final double precipitationSum;
  final int precipitationProbabilityMax;
  final double windSpeedMax;
  final double windGustsMax;
  final int windDirectionDominant;
  final double rainSum;
  final double snowfallSum;
  final double sunshineDuration; // in seconds
  final double daylightDuration; // in seconds

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.windSpeedMax,
    this.windGustsMax = 0,
    this.windDirectionDominant = 0,
    this.rainSum = 0,
    this.snowfallSum = 0,
    this.sunshineDuration = 0,
    this.daylightDuration = 0,
  });

  /// Get sunshine duration as formatted string (hours:minutes)
  String get sunshineDurationFormatted {
    final hours = (sunshineDuration / 3600).floor();
    final minutes = ((sunshineDuration % 3600) / 60).floor();
    return '${hours}h ${minutes}m';
  }

  /// Get daylight duration as formatted string (hours:minutes)
  String get daylightDurationFormatted {
    final hours = (daylightDuration / 3600).floor();
    final minutes = ((daylightDuration % 3600) / 60).floor();
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weatherCode': weatherCode,
      'temperatureMax': temperatureMax,
      'temperatureMin': temperatureMin,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'uvIndexMax': uvIndexMax,
      'precipitationSum': precipitationSum,
      'precipitationProbabilityMax': precipitationProbabilityMax,
      'windSpeedMax': windSpeedMax,
      'windGustsMax': windGustsMax,
      'windDirectionDominant': windDirectionDominant,
      'rainSum': rainSum,
      'snowfallSum': snowfallSum,
      'sunshineDuration': sunshineDuration,
      'daylightDuration': daylightDuration,
    };
  }

  factory DailyForecast.fromCache(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date'] as String),
      weatherCode: json['weatherCode'] as int,
      temperatureMax: (json['temperatureMax'] as num).toDouble(),
      temperatureMin: (json['temperatureMin'] as num).toDouble(),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
      uvIndexMax: (json['uvIndexMax'] as num).toDouble(),
      precipitationSum: (json['precipitationSum'] as num).toDouble(),
      precipitationProbabilityMax: json['precipitationProbabilityMax'] as int,
      windSpeedMax: (json['windSpeedMax'] as num).toDouble(),
      windGustsMax: (json['windGustsMax'] as num?)?.toDouble() ?? 0,
      windDirectionDominant: json['windDirectionDominant'] as int? ?? 0,
      rainSum: (json['rainSum'] as num?)?.toDouble() ?? 0,
      snowfallSum: (json['snowfallSum'] as num?)?.toDouble() ?? 0,
      sunshineDuration: (json['sunshineDuration'] as num?)?.toDouble() ?? 0,
      daylightDuration: (json['daylightDuration'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Air Quality data
class AirQuality {
  final double pm10;
  final double pm2_5;
  final double carbonMonoxide;
  final double nitrogenDioxide;
  final double sulphurDioxide;
  final double ozone;
  final int usAqi;
  final int europeanAqi;
  final DateTime fetchedAt;

  AirQuality({
    required this.pm10,
    required this.pm2_5,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.ozone,
    required this.usAqi,
    required this.europeanAqi,
    required this.fetchedAt,
  });

  /// Get the AQI category and color
  AqiCategory get category {
    if (usAqi <= 50) return AqiCategory.good;
    if (usAqi <= 100) return AqiCategory.moderate;
    if (usAqi <= 150) return AqiCategory.unhealthySensitive;
    if (usAqi <= 200) return AqiCategory.unhealthy;
    if (usAqi <= 300) return AqiCategory.veryUnhealthy;
    return AqiCategory.hazardous;
  }

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return AirQuality(
      pm10: (current['pm10'] as num?)?.toDouble() ?? 0,
      pm2_5: (current['pm2_5'] as num?)?.toDouble() ?? 0,
      carbonMonoxide: (current['carbon_monoxide'] as num?)?.toDouble() ?? 0,
      nitrogenDioxide: (current['nitrogen_dioxide'] as num?)?.toDouble() ?? 0,
      sulphurDioxide: (current['sulphur_dioxide'] as num?)?.toDouble() ?? 0,
      ozone: (current['ozone'] as num?)?.toDouble() ?? 0,
      usAqi: current['us_aqi'] as int? ?? 0,
      europeanAqi: current['european_aqi'] as int? ?? 0,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pm10': pm10,
      'pm2_5': pm2_5,
      'carbonMonoxide': carbonMonoxide,
      'nitrogenDioxide': nitrogenDioxide,
      'sulphurDioxide': sulphurDioxide,
      'ozone': ozone,
      'usAqi': usAqi,
      'europeanAqi': europeanAqi,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory AirQuality.fromCache(Map<String, dynamic> json) {
    return AirQuality(
      pm10: (json['pm10'] as num).toDouble(),
      pm2_5: (json['pm2_5'] as num).toDouble(),
      carbonMonoxide: (json['carbonMonoxide'] as num).toDouble(),
      nitrogenDioxide: (json['nitrogenDioxide'] as num).toDouble(),
      sulphurDioxide: (json['sulphurDioxide'] as num).toDouble(),
      ozone: (json['ozone'] as num).toDouble(),
      usAqi: json['usAqi'] as int,
      europeanAqi: json['europeanAqi'] as int,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

/// AQI categories
enum AqiCategory {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous;

  String get label {
    switch (this) {
      case AqiCategory.good:
        return 'Good';
      case AqiCategory.moderate:
        return 'Moderate';
      case AqiCategory.unhealthySensitive:
        return 'Unhealthy for Sensitive Groups';
      case AqiCategory.unhealthy:
        return 'Unhealthy';
      case AqiCategory.veryUnhealthy:
        return 'Very Unhealthy';
      case AqiCategory.hazardous:
        return 'Hazardous';
    }
  }

  int get color {
    switch (this) {
      case AqiCategory.good:
        return 0xFF00E400; // Green
      case AqiCategory.moderate:
        return 0xFFFFFF00; // Yellow
      case AqiCategory.unhealthySensitive:
        return 0xFFFF7E00; // Orange
      case AqiCategory.unhealthy:
        return 0xFFFF0000; // Red
      case AqiCategory.veryUnhealthy:
        return 0xFF8F3F97; // Purple
      case AqiCategory.hazardous:
        return 0xFF7E0023; // Maroon
    }
  }
}
