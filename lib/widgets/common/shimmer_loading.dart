import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weatherman/config/design_system.dart';

/// Full-page loading shimmer shown while weather data loads.
class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _shimmerBox(width: 120, height: 14, radius: 6),
          const SizedBox(height: 32),
          _shimmerBox(width: 180, height: 72, radius: 12),
          const SizedBox(height: 16),
          _shimmerBox(width: 140, height: 16, radius: 6),
          const SizedBox(height: 8),
          _shimmerBox(width: 200, height: 12, radius: 6),
          const SizedBox(height: 48),
          _shimmerBox(width: double.infinity, height: 120, radius: DesignSystem.radiusCard),
          const SizedBox(height: 16),
          _shimmerBox(width: double.infinity, height: 180, radius: DesignSystem.radiusCard),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _shimmerBox(width: double.infinity, height: 100, radius: DesignSystem.radiusTile)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(width: double.infinity, height: 100, radius: DesignSystem.radiusTile)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single shimmer skeleton row for search results.
class ShimmerRow extends StatelessWidget {
  const ShimmerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingM,
        vertical: DesignSystem.spacingS,
      ),
      child: Row(
        children: [
          _shimmerBox(width: 32, height: 32, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 140, height: 12, radius: 4),
                const SizedBox(height: 6),
                _shimmerBox(width: 90, height: 10, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _shimmerBox({
  required double width,
  required double height,
  double radius = 8,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.white.withValues(alpha: 0.08),
    highlightColor: Colors.white.withValues(alpha: 0.18),
    child: Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
