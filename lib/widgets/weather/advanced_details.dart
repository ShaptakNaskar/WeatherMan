import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/themed/themed_card.dart';

/// Advanced weather details widget with categorized data
class AdvancedDetailsCard extends StatelessWidget {
  final WeatherData weather;
  final String Function(double, {bool showUnit}) formatTemp;

  const AdvancedDetailsCard({
    super.key,
    required this.weather,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final current = weather.current;
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;
    final airQuality = weather.airQuality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Detailed Conditions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  shadows: t.textShadows,
                ),
          ),
        ),

        // Atmosphere Section
        _buildSection(
          context,
          t,
          icon: Icons.cloud_outlined,
          title: 'Atmosphere',
          items: [
            _DetailItem('Dew Point', formatTemp(current.dewPoint)),
            _DetailItem('Visibility', _formatVisibility(current.visibility)),
            _DetailItem('Cloud Cover', '${current.cloudCover}%'),
            _DetailItem('Pressure', '${current.pressure.round()} hPa'),
            if (current.surfacePressure > 0)
              _DetailItem('Surface Pressure', '${current.surfacePressure.round()} hPa'),
          ],
        ),

        const SizedBox(height: 12),

        // Wind Section
        _buildSection(
          context,
          t,
          icon: Icons.air_rounded,
          title: 'Wind',
          items: [
            _DetailItem('Speed', '${current.windSpeed.round()} km/h'),
            _DetailItem('Gusts', '${current.windGusts.round()} km/h'),
            _DetailItem('Direction', _formatWindDirection(current.windDirection)),
            if (today != null && today.windGustsMax > 0)
              _DetailItem('Max Gusts Today', '${today.windGustsMax.round()} km/h'),
          ],
        ),

        const SizedBox(height: 12),

        // Precipitation Section
        _buildSection(
          context,
          t,
          icon: Icons.water_drop_outlined,
          title: 'Precipitation',
          items: [
            if (current.rain > 0)
              _DetailItem('Rain', '${current.rain.toStringAsFixed(1)} mm'),
            if (current.snowfall > 0)
              _DetailItem('Snowfall', '${current.snowfall.toStringAsFixed(1)} cm'),
            if (today != null) ...[
              if (today.rainSum > 0)
                _DetailItem('Rain Today', '${today.rainSum.toStringAsFixed(1)} mm'),
              if (today.snowfallSum > 0)
                _DetailItem('Snow Today', '${today.snowfallSum.toStringAsFixed(1)} cm'),
              _DetailItem('Chance', '${today.precipitationProbabilityMax}%'),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Sun & Daylight Section
        if (today != null)
          _buildSection(
            context,
            t,
            icon: Icons.wb_sunny_outlined,
            title: 'Sun & Daylight',
            items: [
              _DetailItem('Sunrise', _formatTime(today.sunrise)),
              _DetailItem('Sunset', _formatTime(today.sunset)),
              if (today.daylightDuration > 0)
                _DetailItem('Daylight', today.daylightDurationFormatted),
              if (today.sunshineDuration > 0)
                _DetailItem('Sunshine', today.sunshineDurationFormatted),
            ],
          ),

        const SizedBox(height: 12),

        // UV Section
        _buildSection(
          context,
          t,
          icon: Icons.wb_twilight_rounded,
          title: 'UV & Radiation',
          items: [
            _DetailItem('Current UV', current.uvIndex.toStringAsFixed(1)),
            _DetailItem('UV Level', _getUvLevel(current.uvIndex)),
            if (today != null && today.uvIndexMax > 0)
              _DetailItem('Max UV Today', today.uvIndexMax.toStringAsFixed(1)),
          ],
        ),

        // Air Quality Section (if available)
        if (airQuality != null) ...[
          const SizedBox(height: 12),
          _buildAirQualitySection(context, t, airQuality),
        ],
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    dynamic t, {
    required IconData icon,
    required String title,
    required List<_DetailItem> items,
  }) {
    final validItems = items.where((item) => item.value.isNotEmpty).toList();
    if (validItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: t.textSecondary, shadows: t.textShadows),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      shadows: t.textShadows,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: validItems.map((item) => _buildDetailItem(context, t, item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, dynamic t, _DetailItem item) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  shadows: t.textShadows,
                ),
          ),
          Text(
            item.value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  shadows: t.textShadows,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualitySection(BuildContext context, dynamic t, AirQuality aq) {
    final category = aq.category;

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air_rounded, size: 20, color: t.textSecondary, shadows: t.textShadows),
              const SizedBox(width: 8),
              Text(
                'Air Quality',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      shadows: t.textShadows,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(category.color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AQI ${aq.usAqi}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(category.color),
                  fontWeight: FontWeight.w500,
                  shadows: t.textShadows,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildDetailItem(context, t, _DetailItem('PM2.5', '${aq.pm2_5.round()} µg/m³')),
              _buildDetailItem(context, t, _DetailItem('PM10', '${aq.pm10.round()} µg/m³')),
              _buildDetailItem(context, t, _DetailItem('Ozone', '${aq.ozone.round()} µg/m³')),
              _buildDetailItem(context, t, _DetailItem('NO₂', '${aq.nitrogenDioxide.round()} µg/m³')),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVisibility(double meters) {
    if (meters >= 10000) {
      return '${(meters / 1000).round()} km';
    } else if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${meters.round()} m';
    }
  }

  String _formatWindDirection(int degrees) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return '${directions[index]} ($degrees°)';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getUvLevel(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }
}

/// Helper class for detail items
class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}
