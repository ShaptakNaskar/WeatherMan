/// API endpoints and app constants
class AppConstants {
  static const String appName = 'WeatherMan';
  
  // Open-Meteo API endpoints
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String airQualityBaseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';
  
  // Weather API parameters - Current
  static const String currentParams = 
    'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
    'precipitation,rain,snowfall,weather_code,cloud_cover,pressure_msl,'
    'surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,'
    'uv_index,visibility,dew_point_2m';
  
  // Weather API parameters - Hourly (expanded for advanced view)
  static const String hourlyParams = 
    'temperature_2m,weather_code,precipitation_probability,is_day,'
    'relative_humidity_2m,apparent_temperature,wind_speed_10m,'
    'wind_direction_10m,visibility,uv_index,precipitation,rain,snowfall';
  
  // Weather API parameters - Daily (expanded for advanced view)
  static const String dailyParams = 
    'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,'
    'uv_index_max,precipitation_sum,precipitation_probability_max,'
    'wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,'
    'rain_sum,snowfall_sum,sunshine_duration,daylight_duration';
  
  // Air Quality API parameters
  static const String airQualityParams = 
    'pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,'
    'us_aqi,european_aqi';
  
  // Cache duration
  static const Duration cacheDuration = Duration(minutes: 30);
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
