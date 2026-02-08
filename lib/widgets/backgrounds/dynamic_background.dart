import 'dart:math';
import 'package:flutter/material.dart';

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
    final gradient = _getWeatherGradient(weatherCode, isDay);
    final needsDarkOverlay = _needsDarkOverlay(weatherCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // Dark overlay for better text readability on light backgrounds
          if (needsDarkOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          // Weather particles overlay
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

  bool _needsDarkOverlay(int code) {
    // Bright day backgrounds that need overlay for text contrast
    if (isDay) {
      return code == 45 || code == 48 || // Fog (lighter day version)
             (code >= 71 && code <= 77) || // Snow
             (code >= 85 && code <= 86); // Snow showers
    }
    return false;
  }

  LinearGradient _getWeatherGradient(int code, bool isDay) {
    // Clear sky
    if (code == 0 || code == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF90CAF9), Color(0xFFBBDEFB)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070B24), Color(0xFF0F1A3C), Color(0xFF1B2951), Color(0xFF2A3F6F)],
            );
    }

    // Partly cloudy
    if (code == 2) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A8CCB), Color(0xFF7DB1DE), Color(0xFFA8CEE8), Color(0xFFC5DFF0)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF101828), Color(0xFF1E2E45), Color(0xFF2D4360), Color(0xFF3D5474)],
            );
    }

    // Overcast
    if (code == 3) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5), Color(0xFFC5CCD3)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2332), Color(0xFF2A3444), Color(0xFF3A4656), Color(0xFF4A5666)],
            );
    }

    // Fog/Mist
    if (code == 45 || code == 48) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5), Color(0xFFC8D0D8)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E2830), Color(0xFF2E3840), Color(0xFF3E4850), Color(0xFF4E5860)],
            );
    }

    // Drizzle
    if (code >= 51 && code <= 57) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF607D8B), Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF151E28), Color(0xFF222E3A), Color(0xFF2F3E4C), Color(0xFF3C4E5E)],
            );
    }

    // Rain
    if (code >= 61 && code <= 67) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF546E7A), Color(0xFF6B8494), Color(0xFF8298A8), Color(0xFF99ACBC)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1820), Color(0xFF1C2A34), Color(0xFF2A3C48), Color(0xFF384E5C)],
            );
    }

    // Snow
    if (code >= 71 && code <= 77) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7E99A8), Color(0xFF97ADB8), Color(0xFFB0C2CC), Color(0xFFC8D6DE)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2530), Color(0xFF283642), Color(0xFF364854), Color(0xFF445A66)],
            );
    }

    // Rain showers
    if (code >= 80 && code <= 82) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF546E7A), Color(0xFF6B8494), Color(0xFF8298A8), Color(0xFF99ACBC)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1820), Color(0xFF1C2A34), Color(0xFF2A3C48), Color(0xFF384E5C)],
            );
    }

    // Snow showers
    if (code >= 85 && code <= 86) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7E99A8), Color(0xFF97ADB8), Color(0xFFB0C2CC), Color(0xFFC8D6DE)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2530), Color(0xFF283642), Color(0xFF364854), Color(0xFF445A66)],
            );
    }

    // Thunderstorm
    if (code >= 95 && code <= 99) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF37474F), Color(0xFF455A64), Color(0xFF546E7A), Color(0xFF607D8B)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E1A), Color(0xFF141828), Color(0xFF1E2236), Color(0xFF282C44)],
            );
    }

    // Default
    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF90CAF9), Color(0xFFBBDEFB)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070B24), Color(0xFF0F1A3C), Color(0xFF1B2951), Color(0xFF2A3F6F)],
          );
  }

  Widget _buildWeatherOverlay(BuildContext context) {
    // Rain effect with varying intensity
    if (_isRainy) {
      return RainOverlay(intensity: _getRainIntensity());
    }
    // Snow effect with varying intensity
    if (_isSnowy) {
      return SnowOverlay(intensity: _getSnowIntensity());
    }
    // Thunderstorm with lightning
    if (_isThunderstorm) {
      return const ThunderstormOverlay();
    }
    // Stars for night
    if (!isDay && _isClear) {
      return const StarOverlay();
    }
    // Clouds for cloudy weather
    if (_isCloudy) {
      return const CloudOverlay();
    }
    // Fog effect
    if (_isFog) {
      return const FogOverlay();
    }
    return const SizedBox.shrink();
  }

  bool get _isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82);

  bool get _isSnowy =>
      (weatherCode >= 71 && weatherCode <= 77) ||
      (weatherCode >= 85 && weatherCode <= 86);

  bool get _isThunderstorm =>
      weatherCode >= 95 && weatherCode <= 99;

  bool get _isClear => weatherCode == 0 || weatherCode == 1;

  bool get _isCloudy => weatherCode == 2 || weatherCode == 3;

  bool get _isFog => weatherCode == 45 || weatherCode == 48;

  double _getRainIntensity() {
    if (weatherCode == 51 || weatherCode == 61 || weatherCode == 80) return 0.3; // Light
    if (weatherCode == 53 || weatherCode == 63 || weatherCode == 81) return 0.6; // Moderate
    return 1.0; // Heavy
  }

  double _getSnowIntensity() {
    if (weatherCode == 71 || weatherCode == 85) return 0.3; // Light
    if (weatherCode == 73) return 0.6; // Moderate
    return 1.0; // Heavy
  }
}

/// Rain particle overlay with intensity control
class RainOverlay extends StatefulWidget {
  final double intensity;
  const RainOverlay({super.key, this.intensity = 0.5});

  @override
  State<RainOverlay> createState() => _RainOverlayState();
}

class _RainOverlayState extends State<RainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_RainDrop> _drops;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _generateDrops();
  }

  void _generateDrops() {
    // Fewer particles for better performance: 10-30 based on intensity
    final count = (10 + (20 * widget.intensity)).round();
    _drops = List.generate(count, (_) => _RainDrop(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.4 + widget.intensity * 0.6 + _random.nextDouble() * 0.2,
      length: 15 + widget.intensity * 15 + _random.nextDouble() * 10,
    ));
  }

  @override
  void didUpdateWidget(RainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      _generateDrops();
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
          painter: _RainPainter(_drops, _controller.value, widget.intensity),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainDrop {
  final double x;
  double y;
  final double speed;
  final double length;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double animValue;
  final double intensity;

  _RainPainter(this.drops, this.animValue, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 + intensity * 0.2)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      final y = ((drop.y + animValue * drop.speed * 2) % 1.2 - 0.1) * size.height;
      final x = drop.x * size.width;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + 1, y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

/// Snow particle overlay with intensity control
class SnowOverlay extends StatefulWidget {
  final double intensity;
  const SnowOverlay({super.key, this.intensity = 0.5});

  @override
  State<SnowOverlay> createState() => _SnowOverlayState();
}

class _SnowOverlayState extends State<SnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Snowflake> _flakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _generateFlakes();
  }

  void _generateFlakes() {
    // Fewer particles: 15-40 based on intensity
    final count = (15 + (25 * widget.intensity)).round();
    _flakes = List.generate(count, (_) => _Snowflake(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.1 + widget.intensity * 0.15 + _random.nextDouble() * 0.1,
      size: 3 + widget.intensity * 3 + _random.nextDouble() * 3,
      drift: (_random.nextDouble() - 0.5) * 0.3,
    ));
  }

  @override
  void didUpdateWidget(SnowOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      _generateFlakes();
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

class _Snowflake {
  final double x;
  double y;
  final double speed;
  final double size;
  final double drift;

  _Snowflake({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.drift,
  });
}

class _SnowPainter extends CustomPainter {
  final List<_Snowflake> flakes;
  final double animValue;

  _SnowPainter(this.flakes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (final flake in flakes) {
      final y = ((flake.y + animValue * flake.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(animValue * 2 * pi + flake.x * 10) * 15;
      final x = ((flake.x * size.width + drift) % size.width);

      canvas.drawCircle(Offset(x, y), flake.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) => true;
}

/// Thunderstorm overlay with subtle ambient lightning glow and heavy rain
class ThunderstormOverlay extends StatefulWidget {
  const ThunderstormOverlay({super.key});

  @override
  State<ThunderstormOverlay> createState() => _ThunderstormOverlayState();
}

class _ThunderstormOverlayState extends State<ThunderstormOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _lightningController;
  late List<_RainDrop> _drops;
  final Random _random = Random();
  double _lightningOpacity = 0.0;
  Offset _lightningCenter = const Offset(0.5, 0.15);

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat();

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _lightningController.addListener(() {
      // Fade out the lightning glow over the animation duration
      if (mounted) {
        setState(() {
          _lightningOpacity = _lightningOpacity * (1.0 - _lightningController.value);
        });
      }
    });

    // Generate heavy rain
    _drops = List.generate(25, (_) => _RainDrop(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.8 + _random.nextDouble() * 0.4,
      length: 25 + _random.nextDouble() * 15,
    ));

    _scheduleLightning();
  }

  void _scheduleLightning() {
    if (!mounted) return;
    
    // Random lightning every 4-10 seconds (less frequent)
    Future.delayed(Duration(milliseconds: 4000 + _random.nextInt(6000)), () {
      if (!mounted) return;
      _flashLightning();
      _scheduleLightning();
    });
  }

  void _flashLightning() {
    // Randomize where the glow originates (upper portion of screen)
    _lightningCenter = Offset(
      0.2 + _random.nextDouble() * 0.6,
      0.05 + _random.nextDouble() * 0.2,
    );
    _lightningOpacity = 0.15 + _random.nextDouble() * 0.15; // Much subtler: 0.15-0.30
    _lightningController.forward(from: 0).then((_) {
      if (mounted) {
        // Sometimes a second subtle pulse
        if (_random.nextInt(3) == 0) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _lightningOpacity = 0.08 + _random.nextDouble() * 0.08;
              _lightningController.forward(from: 0);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient lightning glow (radial, not full-screen white)
        if (_lightningOpacity > 0.001)
          Positioned.fill(
            child: CustomPaint(
              painter: _LightningGlowPainter(
                center: _lightningCenter,
                opacity: _lightningOpacity,
              ),
            ),
          ),
        // Heavy rain
        AnimatedBuilder(
          animation: _rainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _RainPainter(_drops, _rainController.value, 1.0),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

/// Paints a radial ambient glow to simulate distant lightning
class _LightningGlowPainter extends CustomPainter {
  final Offset center;
  final double opacity;

  _LightningGlowPainter({required this.center, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(center.dx * 2 - 1, center.dy * 2 - 1),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _LightningGlowPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.center != center;
  }
}

/// Star overlay for night sky (optimized)
class StarOverlay extends StatefulWidget {
  const StarOverlay({super.key});

  @override
  State<StarOverlay> createState() => _StarOverlayState();
}

class _StarOverlayState extends State<StarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Fewer stars for performance
    _stars = List.generate(30, (_) => _Star(
      x: _random.nextDouble(),
      y: _random.nextDouble() * 0.6,
      phase: _random.nextDouble(),
      size: 1 + _random.nextDouble() * 1.5,
    ));
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

class _Star {
  final double x;
  final double y;
  final double phase;
  final double size;

  _Star({required this.x, required this.y, required this.phase, required this.size});
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animValue;

  _StarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = 0.3 + 0.7 * sin((animValue + star.phase) * pi).abs();
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: twinkle);

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

/// Cloud overlay (optimized - static)
class CloudOverlay extends StatelessWidget {
  const CloudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StaticCloudPainter(),
      size: Size.infinite,
    );
  }
}

class _StaticCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    
    // Draw a few static cloud shapes
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.2, size.height * 0.15), width: 150, height: 50),
        const Radius.circular(25),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.7, size.height * 0.1), width: 120, height: 40),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.25), width: 180, height: 60),
        const Radius.circular(30),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Static, no repaint needed
}

/// Fog overlay (static for performance)
class FogOverlay extends StatelessWidget {
  const FogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FogPainter(),
      size: Size.infinite,
    );
  }
}

class _FogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal fog bands
    final paint = Paint();
    
    paint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.15),
      paint,
    );
    
    paint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.2),
      paint,
    );
    
    paint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Static
}
