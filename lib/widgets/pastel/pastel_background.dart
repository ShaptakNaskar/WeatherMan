import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/pastel_theme.dart';

/// Pastel/Kawaii themed background with soft particle effects
class PastelBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const PastelBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = PastelTheme().getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // Soft floating particles
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _buildWeatherOverlay(),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildWeatherOverlay() {
    // Rain — soft blue drops
    if (_isRainy) {
      return _PastelRainOverlay(intensity: _getRainIntensity());
    }
    // Snow — sparkly snowflakes
    if (_isSnowy) {
      return const _PastelSnowOverlay();
    }
    // Thunderstorm — soft lightning
    if (_isThunderstorm) {
      return _PastelRainOverlay(intensity: 0.8);
    }
    // Clear day — floating bubbles / cherry blossoms
    if (isDay && _isClear) {
      return const _PastelFloatingParticles();
    }
    // Clear night — soft stars
    if (!isDay && _isClear) {
      return const _PastelStarOverlay();
    }
    // Cloudy — drifting soft clouds
    if (_isCloudy) {
      return const _PastelCloudOverlay();
    }
    return const SizedBox.shrink();
  }

  bool get _isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82);
  bool get _isSnowy =>
      (weatherCode >= 71 && weatherCode <= 77) ||
      (weatherCode >= 85 && weatherCode <= 86);
  bool get _isThunderstorm => weatherCode >= 95 && weatherCode <= 99;
  bool get _isClear => weatherCode == 0 || weatherCode == 1;
  bool get _isCloudy => weatherCode == 2 || weatherCode == 3;

  double _getRainIntensity() {
    if (weatherCode == 51 || weatherCode == 61 || weatherCode == 80) return 0.3;
    if (weatherCode == 53 || weatherCode == 63 || weatherCode == 81) return 0.6;
    return 1.0;
  }
}

/// Soft pastel rain drops
class _PastelRainOverlay extends StatefulWidget {
  final double intensity;
  const _PastelRainOverlay({this.intensity = 0.5});

  @override
  State<_PastelRainOverlay> createState() => _PastelRainOverlayState();
}

class _PastelRainOverlayState extends State<_PastelRainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SoftDrop> _drops;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _generateDrops();
  }

  void _generateDrops() {
    final count = (10 + (15 * widget.intensity)).round();
    _drops = List.generate(
      count,
      (_) => _SoftDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.3 + widget.intensity * 0.4 + _random.nextDouble() * 0.2,
        length: 12 + widget.intensity * 10 + _random.nextDouble() * 8,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PastelRainPainter(_drops, _controller.value, widget.intensity),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SoftDrop {
  final double x;
  double y;
  final double speed;
  final double length;
  _SoftDrop({required this.x, required this.y, required this.speed, required this.length});
}

class _PastelRainPainter extends CustomPainter {
  final List<_SoftDrop> drops;
  final double animValue;
  final double intensity;
  _PastelRainPainter(this.drops, this.animValue, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    for (final drop in drops) {
      final y = ((drop.y + animValue * drop.speed * 2) % 1.2 - 0.1) * size.height;
      final x = drop.x * size.width;
      final paint = Paint()
        ..color = PastelTheme.babyBlue.withValues(alpha: 0.3 + intensity * 0.15)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y), Offset(x, y + drop.length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Soft sparkly snowflakes
class _PastelSnowOverlay extends StatefulWidget {
  const _PastelSnowOverlay();

  @override
  State<_PastelSnowOverlay> createState() => _PastelSnowOverlayState();
}

class _PastelSnowOverlayState extends State<_PastelSnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SoftFlake> _flakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _flakes = List.generate(
      25,
      (_) => _SoftFlake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.05 + _random.nextDouble() * 0.08,
        size: 2 + _random.nextDouble() * 4,
        phase: _random.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PastelSnowPainter(_flakes, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SoftFlake {
  final double x, y, speed, size, phase;
  _SoftFlake({required this.x, required this.y, required this.speed, required this.size, required this.phase});
}

class _PastelSnowPainter extends CustomPainter {
  final List<_SoftFlake> flakes;
  final double animValue;
  _PastelSnowPainter(this.flakes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final flake in flakes) {
      final y = ((flake.y + animValue * flake.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(animValue * 2 * pi + flake.phase * 10) * 10;
      final x = ((flake.x * size.width + drift) % size.width);
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(x, y), flake.size / 2, paint);
      // Soft glow
      final glow = Paint()
        ..color = PastelTheme.lavender.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), flake.size, glow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Floating pastel particles (cherry blossom-like)
class _PastelFloatingParticles extends StatefulWidget {
  const _PastelFloatingParticles();

  @override
  State<_PastelFloatingParticles> createState() => _PastelFloatingParticlesState();
}

class _PastelFloatingParticlesState extends State<_PastelFloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(
      12,
      (_) => _FloatParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.02 + _random.nextDouble() * 0.03,
        size: 3 + _random.nextDouble() * 5,
        phase: _random.nextDouble(),
        colorIndex: _random.nextInt(3),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FloatParticle {
  final double x, y, speed, size, phase;
  final int colorIndex;
  _FloatParticle({
    required this.x, required this.y, required this.speed,
    required this.size, required this.phase, required this.colorIndex,
  });
}

class _FloatParticlePainter extends CustomPainter {
  final List<_FloatParticle> particles;
  final double animValue;
  static const _colors = [PastelTheme.babyPink, PastelTheme.lavender, PastelTheme.peach];

  _FloatParticlePainter(this.particles, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final drift = sin((animValue + p.phase) * 2 * pi) * 15;
      final yDrift = cos((animValue + p.phase) * 2 * pi * 0.5) * 8;
      final cx = (p.x * size.width + drift) % size.width;
      final cy = ((p.y + animValue * p.speed) % 1.0) * size.height + yDrift;
      final color = _colors[p.colorIndex];
      final alpha = 0.3 + 0.2 * sin((animValue + p.phase) * pi).abs();

      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(cx, cy), p.size, paint);

      final glow = Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(cx, cy), p.size * 1.8, glow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Soft stars for pastel night
class _PastelStarOverlay extends StatefulWidget {
  const _PastelStarOverlay();

  @override
  State<_PastelStarOverlay> createState() => _PastelStarOverlayState();
}

class _PastelStarOverlayState extends State<_PastelStarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_PastelStar> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _stars = List.generate(
      30,
      (_) => _PastelStar(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.7,
        phase: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 2,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PastelStarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelStar {
  final double x, y, phase, size;
  _PastelStar({required this.x, required this.y, required this.phase, required this.size});
}

class _PastelStarPainter extends CustomPainter {
  final List<_PastelStar> stars;
  final double animValue;
  _PastelStarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = 0.3 + 0.7 * sin((animValue + star.phase) * pi).abs();
      final paint = Paint()..color = Colors.white.withValues(alpha: twinkle * 0.7);
      final center = Offset(star.x * size.width, star.y * size.height);
      canvas.drawCircle(center, star.size, paint);
      // Soft glow
      final glow = Paint()
        ..color = PastelTheme.softYellow.withValues(alpha: twinkle * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, star.size * 2, glow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Soft drifting cloud shapes
class _PastelCloudOverlay extends StatefulWidget {
  const _PastelCloudOverlay();

  @override
  State<_PastelCloudOverlay> createState() => _PastelCloudOverlayState();
}

class _PastelCloudOverlayState extends State<_PastelCloudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PastelCloudPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelCloudPainter extends CustomPainter {
  final double animValue;
  _PastelCloudPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final drift = sin(animValue * 2 * pi) * 15;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25 + drift, size.height * 0.1),
        width: 160,
        height: 50,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7 - drift * 0.7, size.height * 0.18),
        width: 200,
        height: 60,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
