import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';

/// Procedural grain texture overlay drawn as tiny random dots.
/// Uses a fixed [seed] so the pattern is stable per card instance.
class GrainPainter extends CustomPainter {
  final int seed;
  final double opacity;

  const GrainPainter({this.seed = 0, this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    final count = DesignSystem.grainDotCount;
    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = DesignSystem.grainMinRadius +
          random.nextDouble() *
              (DesignSystem.grainMaxRadius - DesignSystem.grainMinRadius);
      final dotOpacity = DesignSystem.grainMinOpacity +
          random.nextDouble() *
              (DesignSystem.grainMaxOpacity - DesignSystem.grainMinOpacity);
      paint.color = Colors.white.withValues(alpha: dotOpacity * opacity / 0.06);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(GrainPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.opacity != opacity;
}
