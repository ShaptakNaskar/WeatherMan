import 'package:flutter/material.dart';
import 'package:weatherman/widgets/glassmorphic/glass_card.dart';

/// Simple loading placeholder without shimmer
class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading weather...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
