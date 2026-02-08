/// API endpoints and app constants
class AppConstants {
  static const String appName = 'WeatherMan';
  
  // Open-Meteo API endpoints
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  
  // Weather API parameters
  static const String currentParams = 
    'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
    'precipitation,rain,weather_code,cloud_cover,pressure_msl,'
    'wind_speed_10m,wind_direction_10m,wind_gusts_10m,uv_index';
  
  static const String hourlyParams = 
    'temperature_2m,weather_code,precipitation_probability,is_day';
  
  static const String dailyParams = 
    'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,'
    'uv_index_max,precipitation_sum,precipitation_probability_max,'
    'wind_speed_10m_max';
  
  // Cache duration
  static const Duration cacheDuration = Duration(minutes: 30);
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
