import 'dart:math';
import 'package:flutter/material.dart';

class _Flake {
  double x, y, speed, radius, drift;
  _Flake(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        speed = 0.15 + r.nextDouble() * 0.35,
        radius = 1.2 + r.nextDouble() * 2.5,
        drift = r.nextDouble() * 2 * pi;
}

/// Drifting snow overlay with sine-wave horizontal drift.
class SnowOverlay extends StatefulWidget {
  final double intensity;
  const SnowOverlay({super.key, this.intensity = 0.5});

  @override
  State<SnowOverlay> createState() => _SnowOverlayState();
}

class _SnowOverlayState extends State<SnowOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Flake> _flakes;

  @override
  void initState() {
    super.initState();
    final count = (60 * widget.intensity).round().clamp(15, 80);
    final r = Random(77);
    _flakes = List.generate(count, (_) => _Flake(r));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
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
          painter: _SnowPainter(_flakes, _ctrl.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final List<_Flake> flakes;
  final double tick;
  _SnowPainter(this.flakes, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final f in flakes) {
      final y = ((f.y + tick * f.speed) % 1.05) * size.height;
      final sineOffset = sin(f.drift + tick * 4) * 15;
      final x = f.x * size.width + sineOffset;
      paint.color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(x, y), f.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter old) => old.tick != tick;
}
