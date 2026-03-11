import 'dart:math';
import 'package:flutter/material.dart';

class _RainDrop {
  double x, y, speed, length, opacity;
  _RainDrop(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        speed = 0.4 + r.nextDouble() * 0.6,
        length = 12 + r.nextDouble() * 18,
        opacity = 0.15 + r.nextDouble() * 0.35;
}

/// Animated rain overlay with angle tilt and splash circles.
class RainOverlay extends StatefulWidget {
  final double intensity; // 0.0–1.0
  const RainOverlay({super.key, this.intensity = 0.5});

  @override
  State<RainOverlay> createState() => _RainOverlayState();
}

class _RainOverlayState extends State<RainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_RainDrop> _drops;

  @override
  void initState() {
    super.initState();
    final count = (80 * widget.intensity).round().clamp(20, 120);
    final r = Random(42);
    _drops = List.generate(count, (_) => _RainDrop(r));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
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
          painter: _RainPainter(_drops, _ctrl.value, widget.intensity),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double tick;
  final double intensity;
  _RainPainter(this.drops, this.tick, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final angle = 0.12 * intensity; // slight tilt

    for (final d in drops) {
      final y = ((d.y + tick * d.speed) % 1.05) * size.height;
      final x = (d.x + angle * (y / size.height)) * size.width;
      paint
        ..color = Colors.white.withValues(alpha: d.opacity * intensity)
        ..strokeWidth = 1.2;
      final dx = sin(angle) * d.length;
      final dy = cos(angle) * d.length;
      canvas.drawLine(Offset(x, y), Offset(x + dx, y + dy), paint);

      // Splash at bottom 10%
      if (y > size.height * 0.9) {
        final splashR = 1.5 + (1.0 - (y - size.height * 0.9) / (size.height * 0.1)) * 2;
        paint
          ..color = Colors.white.withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6;
        canvas.drawCircle(Offset(x, y), splashR, paint);
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.tick != tick;
}
