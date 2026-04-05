import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/providers/theme_provider.dart';
import 'package:weatherman/widgets/backgrounds/premium_scene_layer.dart';

/// Clean/Glassmorphic theme background with classic weather effects
/// Imported from deprecated-master branch and adapted for themed system
class CleanBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const CleanBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final gradient = theme.current.getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: PremiumSceneLayer(
                    flavor: PremiumThemeFlavor.clean,
                    weatherCode: weatherCode,
                    isDay: isDay,
                  ),
                ),
              ),
            ),
          ),
          // Weather particle overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(child: _buildWeatherOverlay()),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildWeatherOverlay() {
    // Rain
    if (_isRainy) {
      return CleanRainOverlay(intensity: _getRainIntensity());
    }
    // Snow
    if (_isSnowy) {
      return CleanSnowOverlay(intensity: _getSnowIntensity());
    }
    // Thunderstorm
    if (_isThunderstorm) {
      return const CleanThunderstormOverlay();
    }
    // Clear night — stars
    if (!isDay && _isClear) {
      return const CleanStarOverlay();
    }
    // Clear day — subtle heat shimmer (if hot, otherwise nothing)
    if (isDay && _isClear) {
      return const SizedBox.shrink();
    }
    // Cloudy — drifting clouds
    if (_isCloudy) {
      return const CleanCloudOverlay();
    }
    // Fog
    if (_isFog) {
      return const CleanFogOverlay();
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
  bool get _isFog => weatherCode == 45 || weatherCode == 48;

  double _getRainIntensity() {
    if (weatherCode == 51 || weatherCode == 61 || weatherCode == 80) return 0.3;
    if (weatherCode == 53 || weatherCode == 63 || weatherCode == 81) return 0.6;
    return 1.0;
  }

  double _getSnowIntensity() {
    if (weatherCode == 71 || weatherCode == 85) return 0.3;
    if (weatherCode == 73) return 0.6;
    return 1.0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RAIN OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

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
class CleanRainOverlay extends StatefulWidget {
  final double intensity;
  const CleanRainOverlay({super.key, this.intensity = 0.5});

  @override
  State<CleanRainOverlay> createState() => _CleanRainOverlayState();
}

class _CleanRainOverlayState extends State<CleanRainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_RainDrop> _drops;

  @override
  void initState() {
    super.initState();
    final count = (80 * widget.intensity).round().clamp(20, 120);
    final r = Random(42);
    _drops = List.generate(count, (_) => _RainDrop(r));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
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
        builder: (_, __) => CustomPaint(
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
    final angle = 0.12 * intensity;

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
        final splashR =
            1.5 + (1.0 - (y - size.height * 0.9) / (size.height * 0.1)) * 2;
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

// ═══════════════════════════════════════════════════════════════════════════
// SNOW OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

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
class CleanSnowOverlay extends StatefulWidget {
  final double intensity;
  const CleanSnowOverlay({super.key, this.intensity = 0.5});

  @override
  State<CleanSnowOverlay> createState() => _CleanSnowOverlayState();
}

class _CleanSnowOverlayState extends State<CleanSnowOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Flake> _flakes;

  @override
  void initState() {
    super.initState();
    final count = (60 * widget.intensity).round().clamp(15, 80);
    final r = Random(77);
    _flakes = List.generate(count, (_) => _Flake(r));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
        builder: (_, __) => CustomPaint(
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

// ═══════════════════════════════════════════════════════════════════════════
// THUNDERSTORM OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

/// Thunderstorm overlay: heavy rain + radial lightning glow.
class CleanThunderstormOverlay extends StatefulWidget {
  const CleanThunderstormOverlay({super.key});

  @override
  State<CleanThunderstormOverlay> createState() =>
      _CleanThunderstormOverlayState();
}

class _CleanThunderstormOverlayState extends State<CleanThunderstormOverlay>
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
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(_tick)
          ..repeat();
  }

  void _tick() {
    _frame++;
    if (_frame >= _nextFlashFrame) {
      _flashOpacity = 0.3 + _random.nextDouble() * 0.4;
      _flashCenter = Offset(_random.nextDouble(), _random.nextDouble() * 0.5);
      _nextFlashFrame = _frame + 60 + _random.nextInt(180);
    } else {
      _flashOpacity *= 0.85;
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
          const CleanRainOverlay(intensity: 1.0),
          // Lightning glow
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
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

// ═══════════════════════════════════════════════════════════════════════════
// STAR OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

class _Star {
  final double x, y, radius, phaseOffset;
  _Star(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble() * 0.6,
      radius = 0.6 + r.nextDouble() * 1.2,
      phaseOffset = r.nextDouble() * 2 * pi;
}

/// Twinkling stars with occasional shooting star.
class CleanStarOverlay extends StatefulWidget {
  const CleanStarOverlay({super.key});

  @override
  State<CleanStarOverlay> createState() => _CleanStarOverlayState();
}

class _CleanStarOverlayState extends State<CleanStarOverlay>
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
        builder: (_, __) {
          _frame++;
          _updateShootingStar();
          return CustomPaint(
            painter: _StarPainter(
              _stars,
              _ctrl.value,
              _shootX,
              _shootY,
              _shootProgress,
            ),
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
  _StarPainter(
    this.stars,
    this.tick,
    this.shootX,
    this.shootY,
    this.shootProgress,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final twinkle = (sin(s.phaseOffset + tick * 2 * pi) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.5);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        paint,
      );
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
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx - len * fade, sy - len * 0.3 * fade),
        paint,
      );
      paint.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// CLOUD OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

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
class CleanCloudOverlay extends StatefulWidget {
  const CleanCloudOverlay({super.key});

  @override
  State<CleanCloudOverlay> createState() => _CleanCloudOverlayState();
}

class _CleanCloudOverlayState extends State<CleanCloudOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_CloudShape> _clouds;

  @override
  void initState() {
    super.initState();
    final r = Random(33);
    _clouds = List.generate(4, (_) => _CloudShape(r));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
        builder: (_, __) {
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
      path.addOval(
        Rect.fromCenter(
          center: Offset(cx - s * 0.6, cy),
          width: s * 1.0,
          height: s * 0.6,
        ),
      );
      path.addOval(
        Rect.fromCenter(
          center: Offset(cx, cy - s * 0.2),
          width: s * 1.2,
          height: s * 0.8,
        ),
      );
      path.addOval(
        Rect.fromCenter(
          center: Offset(cx + s * 0.5, cy),
          width: s * 0.9,
          height: s * 0.55,
        ),
      );
      path.addRect(
        Rect.fromLTRB(cx - s * 0.9, cy, cx + s * 0.8, cy + s * 0.25),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CloudPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// FOG OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

/// Static horizontal fog bands with varying opacity.
class CleanFogOverlay extends StatelessWidget {
  const CleanFogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _FogPainter(), size: Size.infinite);
  }
}

class _FogPainter extends CustomPainter {
  const _FogPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const bands = [
      (yFrac: 0.30, height: 0.08, alpha: 0.10),
      (yFrac: 0.45, height: 0.10, alpha: 0.14),
      (yFrac: 0.60, height: 0.12, alpha: 0.12),
      (yFrac: 0.75, height: 0.10, alpha: 0.08),
      (yFrac: 0.88, height: 0.14, alpha: 0.16),
    ];
    for (final b in bands) {
      paint.color = Colors.white.withValues(alpha: b.alpha);
      final rect = Rect.fromLTWH(
        0,
        b.yFrac * size.height,
        size.width,
        b.height * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_FogPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// HEAT SHIMMER OVERLAY - Imported from deprecated-master
// ═══════════════════════════════════════════════════════════════════════════

/// Subtle heat shimmer in the lower 30% of screen.
/// Only shown when temp > 35 C on clear day.
class CleanHeatShimmerOverlay extends StatefulWidget {
  const CleanHeatShimmerOverlay({super.key});

  @override
  State<CleanHeatShimmerOverlay> createState() =>
      _CleanHeatShimmerOverlayState();
}

class _CleanHeatShimmerOverlayState extends State<CleanHeatShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
        builder: (_, __) => CustomPaint(
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
