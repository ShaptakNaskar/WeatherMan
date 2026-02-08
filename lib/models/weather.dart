import 'package:weatherman/models/location.dart';

/// Complete weather data model
class WeatherData {
  final LocationModel location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

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

    final hourlyList = <HourlyForecast>[];
    for (var i = 0; i < hourlyTimes.length && i < 48; i++) {
      hourlyList.add(HourlyForecast(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: hourlyTemps[i].toDouble(),
        weatherCode: hourlyCodes[i],
        precipitationProbability: hourlyPrecipProb[i] ?? 0,
        isDay: hourlyIsDay[i] == 1,
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
  final int weatherCode;
  final int cloudCover;
  final double pressure;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double uvIndex;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.isDay,
    required this.precipitation,
    required this.rain,
    required this.weatherCode,
    required this.cloudCover,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.uvIndex,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      relativeHumidity: json['relative_humidity_2m'] as int,
      isDay: json['is_day'] == 1,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0,
      weatherCode: json['weather_code'] as int,
      cloudCover: json['cloud_cover'] as int? ?? 0,
      pressure: (json['pressure_msl'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      windDirection: json['wind_direction_10m'] as int? ?? 0,
      windGusts: (json['wind_gusts_10m'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0,
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
      'weatherCode': weatherCode,
      'cloudCover': cloudCover,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'windGusts': windGusts,
      'uvIndex': uvIndex,
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
      weatherCode: json['weatherCode'] as int,
      cloudCover: json['cloudCover'] as int,
      pressure: (json['pressure'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: json['windDirection'] as int,
      windGusts: (json['windGusts'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
    );
  }
}

/// Hourly forecast data
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weatherCode': weatherCode,
      'precipitationProbability': precipitationProbability,
      'isDay': isDay,
    };
  }

  factory HourlyForecast.fromCache(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      precipitationProbability: json['precipitationProbability'] as int,
      isDay: json['isDay'] as bool,
    );
  }
}

/// Daily forecast data
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
  });

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
    );
  }
}
