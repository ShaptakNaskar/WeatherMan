import 'dart:math';
import 'package:flutter/material.dart';

class _Star {
  final double x, y, radius, phaseOffset;
  _Star(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble() * 0.6, // upper 60%
        radius = 0.6 + r.nextDouble() * 1.2,
        phaseOffset = r.nextDouble() * 2 * pi;
}

/// Twinkling stars with occasional shooting star.
class StarOverlay extends StatefulWidget {
  const StarOverlay({super.key});

  @override
  State<StarOverlay> createState() => _StarOverlayState();
}

class _StarOverlayState extends State<StarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;
  double _shootX = -1, _shootY = -1, _shootProgress = -1;
  int _nextShoot = 0;
  int _frame = 0;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    final r = Random(55);
    _stars = List.generate(30, (_) => _Star(r));
    _nextShoot = 200 + _rng.nextInt(400);
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
        builder: (_, _) {
          _frame++;
          _updateShootingStar();
          return CustomPaint(
            painter: _StarPainter(_stars, _ctrl.value, _shootX, _shootY, _shootProgress),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  void _updateShootingStar() {
    if (_frame >= _nextShoot && _shootProgress < 0) {
      _shootX = 0.2 + _rng.nextDouble() * 0.6;
      _shootY = _rng.nextDouble() * 0.3;
      _shootProgress = 0;
    }
    if (_shootProgress >= 0) {
      _shootProgress += 0.04;
      if (_shootProgress > 1) {
        _shootProgress = -1;
        _nextShoot = _frame + 300 + _rng.nextInt(600);
      }
    }
  }
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double tick;
  final double shootX, shootY, shootProgress;
  _StarPainter(this.stars, this.tick, this.shootX, this.shootY, this.shootProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final twinkle = (sin(s.phaseOffset + tick * 2 * pi) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.5);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.radius, paint);
    }
    // Shooting star
    if (shootProgress >= 0 && shootProgress <= 1) {
      final len = size.width * 0.12;
      final sx = shootX * size.width + shootProgress * size.width * 0.25;
      final sy = shootY * size.height + shootProgress * size.height * 0.15;
      final fade = 1.0 - shootProgress;
      paint
        ..color = Colors.white.withValues(alpha: 0.8 * fade)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(sx, sy), Offset(sx - len * fade, sy - len * 0.3 * fade), paint);
      paint.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true; // animation-driven
}
