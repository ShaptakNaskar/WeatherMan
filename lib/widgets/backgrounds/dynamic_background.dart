import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/theme.dart';

/// Dynamic animated background based on weather conditions
class DynamicBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const DynamicBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // Weather particles overlay - using RepaintBoundary to avoid semantics issues
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _buildWeatherOverlay(context),
                ),
              ),
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildWeatherOverlay(BuildContext context) {
    // Rain effect
    if (_isRainy) {
      return const RainOverlay();
    }
    // Snow effect
    if (_isSnowy) {
      return const SnowOverlay();
    }
    // Stars for night
    if (!isDay && _isClear) {
      return const StarOverlay();
    }
    // Clouds for cloudy weather
    if (_isCloudy) {
      return const CloudOverlay();
    }
    return const SizedBox.shrink();
  }

  bool get _isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82);

  bool get _isSnowy =>
      (weatherCode >= 71 && weatherCode <= 77) ||
      (weatherCode >= 85 && weatherCode <= 86);

  bool get _isClear => weatherCode == 0 || weatherCode == 1;

  bool get _isCloudy => weatherCode == 2 || weatherCode == 3;
}

/// Rain particle overlay - using AnimatedBuilder instead of animate extension
class RainOverlay extends StatefulWidget {
  const RainOverlay({super.key});

  @override
  State<RainOverlay> createState() => _RainOverlayState();
}

class _RainOverlayState extends State<RainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _drops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Generate rain drops
    for (int i = 0; i < 30; i++) {
      _drops.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.5 + _random.nextDouble() * 0.5,
        size: 15 + _random.nextDouble() * 10,
      ));
    }
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
          painter: _RainPainter(_drops, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<_Particle> drops;
  final double animValue;

  _RainPainter(this.drops, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 2, 20));

    for (final drop in drops) {
      final y = ((drop.y + animValue * drop.speed) % 1.0) * size.height;
      final x = drop.x * size.width;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 2, drop.size),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

/// Snow particle overlay
class SnowOverlay extends StatefulWidget {
  const SnowOverlay({super.key});

  @override
  State<SnowOverlay> createState() => _SnowOverlayState();
}

class _SnowOverlayState extends State<SnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _flakes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Generate snowflakes
    for (int i = 0; i < 40; i++) {
      _flakes.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.2,
        size: 4 + _random.nextDouble() * 6,
        drift: (_random.nextDouble() - 0.5) * 0.1,
      ));
    }
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
          painter: _SnowPainter(_flakes, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnowPainter extends CustomPainter {
  final List<_Particle> flakes;
  final double animValue;

  _SnowPainter(this.flakes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (final flake in flakes) {
      final y = ((flake.y + animValue * flake.speed) % 1.0) * size.height;
      final drift = sin(animValue * 2 * pi + flake.x * 10) * 20;
      final x = (flake.x * size.width + drift) % size.width;

      canvas.drawCircle(Offset(x, y), flake.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) => true;
}

/// Star overlay for night sky
class StarOverlay extends StatefulWidget {
  const StarOverlay({super.key});

  @override
  State<StarOverlay> createState() => _StarOverlayState();
}

class _StarOverlayState extends State<StarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Generate stars
    for (int i = 0; i < 50; i++) {
      _stars.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.6, // Only in upper 60% of screen
        speed: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 2,
      ));
    }
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
          painter: _StarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<_Particle> stars;
  final double animValue;

  _StarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Each star twinkles at different phase
      final twinkle = 0.3 + 0.7 * sin((animValue + star.speed) * pi).abs();
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: twinkle)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}

/// Cloud overlay for cloudy weather
class CloudOverlay extends StatefulWidget {
  const CloudOverlay({super.key});

  @override
  State<CloudOverlay> createState() => _CloudOverlayState();
}

class _CloudOverlayState extends State<CloudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _clouds = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Generate clouds
    for (int i = 0; i < 5; i++) {
      _clouds.add(_Particle(
        x: _random.nextDouble(),
        y: 0.1 + _random.nextDouble() * 0.3,
        speed: 0.3 + _random.nextDouble() * 0.4,
        size: 150 + _random.nextDouble() * 100,
      ));
    }
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
          painter: _CloudPainter(_clouds, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final List<_Particle> clouds;
  final double animValue;

  _CloudPainter(this.clouds, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.1);

    for (final cloud in clouds) {
      final x = ((cloud.x + animValue * cloud.speed) % 1.4 - 0.2) * size.width;
      final y = cloud.y * size.height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: cloud.size,
            height: cloud.size * 0.4,
          ),
          Radius.circular(cloud.size * 0.2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => true;
}

/// Simple particle data class
class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double drift;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    this.drift = 0,
  });
}
