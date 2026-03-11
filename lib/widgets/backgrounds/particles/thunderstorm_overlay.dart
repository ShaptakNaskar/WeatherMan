import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/widgets/backgrounds/particles/rain_overlay.dart';

/// Thunderstorm overlay: heavy rain + radial lightning glow.
class ThunderstormOverlay extends StatefulWidget {
  const ThunderstormOverlay({super.key});

  @override
  State<ThunderstormOverlay> createState() => _ThunderstormOverlayState();
}

class _ThunderstormOverlayState extends State<ThunderstormOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _flashOpacity = 0;
  Offset _flashCenter = Offset.zero;
  final Random _random = Random();
  int _nextFlashFrame = 30;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    _frame++;
    if (_frame >= _nextFlashFrame) {
      _flashOpacity = 0.3 + _random.nextDouble() * 0.4;
      _flashCenter = Offset(
        _random.nextDouble(),
        _random.nextDouble() * 0.5,
      );
      _nextFlashFrame = _frame + 60 + _random.nextInt(180);
    } else {
      _flashOpacity *= 0.85; // decay
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Heavy rain layer
          const RainOverlay(intensity: 1.0),
          // Lightning glow
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => CustomPaint(
              painter: _LightningGlowPainter(_flashOpacity, _flashCenter),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _LightningGlowPainter extends CustomPainter {
  final double opacity;
  final Offset center;
  _LightningGlowPainter(this.opacity, this.center);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final radius = size.longestSide * 0.7;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_LightningGlowPainter old) => old.opacity != opacity;
}
