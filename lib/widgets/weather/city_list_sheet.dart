import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/providers/location_provider.dart';
import 'package:weatherman/providers/weather_provider.dart';
import 'package:weatherman/screens/search_screen.dart';
import 'package:weatherman/widgets/glassmorphic/glass_bottom_sheet.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Bottom sheet listing saved cities.
class CityListSheet extends StatelessWidget {
  const CityListSheet({super.key});

  static Future<void> show(BuildContext context) {
    return GlassBottomSheet.show(
      context,
      child: const CityListSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, WeatherProvider>(
      builder: (context, locP, weatherP, _) {
        final all = locP.allLocations;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Saved Locations', style: DesignSystem.conditionLabel),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacingM),
            if (all.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spacingXL),
                  child: Text('No saved locations', style: DesignSystem.caption),
                ),
              )
            else
              ...all.map((loc) {
                final w = weatherP.getWeather(loc);
                final selected = loc == locP.selectedLocation;
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.spacingS),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      locP.selectLocation(loc);
                      weatherP.fetchWeather(loc);
                      Navigator.pop(context);
                    },
                    child: LightGlassCard(
                    child: Row(
                      children: [
                        Icon(
                          loc.isCurrentLocation
                              ? Icons.my_location_rounded
                              : Icons.location_city_rounded,
                          size: 18,
                          color: DesignSystem.textSecondary,
                        ),
                        const SizedBox(width: DesignSystem.spacingS),
                        Expanded(
                          child: Text(loc.name, style: DesignSystem.bodyText),
                        ),
                        if (w != null)
                          Text('${w.current.temperature.round()}°',
                              style: DesignSystem.metricValue),
                        if (selected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_circle,
                                color: Color(0xFF66BB6A), size: 18),
                          ),
                      ],
                    ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
