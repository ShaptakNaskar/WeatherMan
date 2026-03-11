import 'dart:math';
import 'package:flutter/material.dart';

/// Subtle heat shimmer in the lower 30% of screen.
/// Only shown when temp > 35 °C on clear day.
class HeatShimmerOverlay extends StatefulWidget {
  const HeatShimmerOverlay({super.key});

  @override
  State<HeatShimmerOverlay> createState() => _HeatShimmerOverlayState();
}

class _HeatShimmerOverlayState extends State<HeatShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _HeatPainter(_ctrl.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HeatPainter extends CustomPainter {
  final double tick;
  _HeatPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final top = size.height * 0.7;
    final bottom = size.height;
    for (int i = 0; i < 6; i++) {
      final y = top + (bottom - top) * (i / 6);
      final phase = tick * 2 * pi + i * 0.8;
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 8) {
        final dy = sin(phase + x / 60) * 2.5;
        path.lineTo(x, y + dy);
      }
      paint.color = Colors.white.withValues(alpha: 0.04);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_HeatPainter old) => old.tick != tick;
}
