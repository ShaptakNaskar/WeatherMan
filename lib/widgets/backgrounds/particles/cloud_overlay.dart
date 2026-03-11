import 'dart:math';
import 'package:flutter/material.dart';

class _CloudShape {
  final double y, scale, speed;
  double x;
  _CloudShape(Random r)
      : x = r.nextDouble() * 1.4 - 0.2,
        y = 0.05 + r.nextDouble() * 0.45,
        scale = 0.6 + r.nextDouble() * 0.5,
        speed = 0.008 + r.nextDouble() * 0.012;
}

/// Animated drifting clouds using bezier paths.
class CloudOverlay extends StatefulWidget {
  const CloudOverlay({super.key});

  @override
  State<CloudOverlay> createState() => _CloudOverlayState();
}

class _CloudOverlayState extends State<CloudOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_CloudShape> _clouds;

  @override
  void initState() {
    super.initState();
    final r = Random(33);
    _clouds = List.generate(4, (_) => _CloudShape(r));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
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
        builder: (_, _) {
          for (final c in _clouds) {
            c.x += c.speed * 0.002;
            if (c.x > 1.3) c.x = -0.4;
          }
          return CustomPaint(
            painter: _CloudPainter(List.of(_clouds)),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final List<_CloudShape> clouds;
  _CloudPainter(this.clouds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final c in clouds) {
      paint.color = Colors.white.withValues(alpha: 0.08 * c.scale);
      final cx = c.x * size.width;
      final cy = c.y * size.height;
      final s = c.scale * size.width * 0.12;
      final path = Path();
      // Build a cloud from overlapping ellipses
      path.addOval(Rect.fromCenter(center: Offset(cx - s * 0.6, cy), width: s * 1.0, height: s * 0.6));
      path.addOval(Rect.fromCenter(center: Offset(cx, cy - s * 0.2), width: s * 1.2, height: s * 0.8));
      path.addOval(Rect.fromCenter(center: Offset(cx + s * 0.5, cy), width: s * 0.9, height: s * 0.55));
      path.addRect(Rect.fromLTRB(cx - s * 0.9, cy, cx + s * 0.8, cy + s * 0.25));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CloudPainter old) => true; // animation-driven
}
