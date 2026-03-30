import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/providers/theme_provider.dart';

/// Sunset/Golden Hour theme background with warm amber/coral weather effects
/// Day: Golden hour warm tones with sun flares and dust particles
/// Night: Deep amber/burgundy tones with warm starlight
class SunsetBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const SunsetBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  // Sunset color palette
  static const Color goldenAmber = Color(0xFFFF8A50);
  static const Color warmCoral = Color(0xFFFF6B8A);
  static const Color sunGold = Color(0xFFFFD54F);
  static const Color deepRose = Color(0xFFE57373);
  static const Color twilightPurple = Color(0xFF9C7BB8);
  static const Color warmWhite = Color(0xFFFFF8E1);

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
          // Golden hour ambient (day) or warm twilight (night)
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: isDay
                      ? const SunsetGoldenHourOverlay()
                      : const SunsetTwilightOverlay(),
                ),
              ),
            ),
          ),
          // Floating dust/pollen particles
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(child: SunsetDustOverlay(isDay: isDay)),
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
    // Rain — golden rain drops
    if (_isRainy) {
      return SunsetRainOverlay(intensity: _getRainIntensity(), isDay: isDay);
    }
    // Snow — warm-tinted snowflakes
    if (_isSnowy) {
      return SunsetSnowOverlay(intensity: _getSnowIntensity(), isDay: isDay);
    }
    // Thunderstorm — amber lightning
    if (_isThunderstorm) {
      return SunsetStormOverlay(isDay: isDay);
    }
    // Clear night — warm stars
    if (!isDay && _isClear) {
      return const SunsetStarOverlay();
    }
    // Clear day — sun flares
    if (isDay && _isClear) {
      return const SunsetFlareOverlay();
    }
    // Cloudy — golden-lit clouds
    if (_isCloudy) {
      return SunsetCloudOverlay(isDay: isDay);
    }
    // Fog — warm haze
    if (_isFog) {
      return SunsetHazeOverlay(isDay: isDay);
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
// GOLDEN HOUR OVERLAY (Day) - Warm ambient light
// ═══════════════════════════════════════════════════════════════════════════

class SunsetGoldenHourOverlay extends StatefulWidget {
  const SunsetGoldenHourOverlay({super.key});

  @override
  State<SunsetGoldenHourOverlay> createState() =>
      _SunsetGoldenHourOverlayState();
}

class _SunsetGoldenHourOverlayState extends State<SunsetGoldenHourOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
          painter: _GoldenHourPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GoldenHourPainter extends CustomPainter {
  final double tick;
  _GoldenHourPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    // Warm light source from top-right corner
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final phase = tick * 2 * pi;
    final pulse = 0.8 + 0.2 * sin(phase);

    // Primary golden glow
    paint.shader = RadialGradient(
      center: const Alignment(0.6, -0.8),
      radius: 1.2,
      colors: [
        SunsetBackground.sunGold.withValues(alpha: 0.08 * pulse),
        SunsetBackground.goldenAmber.withValues(alpha: 0.04 * pulse),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);

    // Secondary warm glow
    paint.shader = RadialGradient(
      center: Alignment(0.3 + 0.1 * sin(phase * 0.5), -0.5),
      radius: 0.8,
      colors: [
        SunsetBackground.warmCoral.withValues(alpha: 0.05 * pulse),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GoldenHourPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// TWILIGHT OVERLAY (Night) - Deep warm ambient
// ═══════════════════════════════════════════════════════════════════════════

class SunsetTwilightOverlay extends StatefulWidget {
  const SunsetTwilightOverlay({super.key});

  @override
  State<SunsetTwilightOverlay> createState() => _SunsetTwilightOverlayState();
}

class _SunsetTwilightOverlayState extends State<SunsetTwilightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
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
          painter: _TwilightPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _TwilightPainter extends CustomPainter {
  final double tick;
  _TwilightPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final phase = tick * 2 * pi;

    // Horizon glow (remnant of sunset)
    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        SunsetBackground.deepRose.withValues(alpha: 0.06),
        SunsetBackground.twilightPurple.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);

    // Subtle moving warm patches
    for (int i = 0; i < 2; i++) {
      final xOffset = sin(phase * 0.3 + i * 1.5) * 50;
      paint.color = SunsetBackground.goldenAmber.withValues(alpha: 0.03);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * (0.3 + i * 0.4) + xOffset,
            size.height * 0.85,
          ),
          width: 200,
          height: 80,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TwilightPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// DUST OVERLAY - Floating golden dust particles
// ═══════════════════════════════════════════════════════════════════════════

class _DustParticle {
  double x, y, size, speed, drift, phase;
  _DustParticle(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      size = 0.8 + r.nextDouble() * 1.5,
      speed = 0.005 + r.nextDouble() * 0.01,
      drift = r.nextDouble() * 2 * pi,
      phase = r.nextDouble() * 2 * pi;
}

class SunsetDustOverlay extends StatefulWidget {
  final bool isDay;
  const SunsetDustOverlay({super.key, required this.isDay});

  @override
  State<SunsetDustOverlay> createState() => _SunsetDustOverlayState();
}

class _SunsetDustOverlayState extends State<SunsetDustOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DustParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    final r = Random(456);
    _particles = List.generate(20, (_) => _DustParticle(r));
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
          painter: _DustPainter(_particles, _controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _DustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double tick;
  final bool isDay;
  _DustPainter(this.particles, this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? SunsetBackground.sunGold
        : SunsetBackground.warmWhite;

    for (final p in particles) {
      final driftX = sin(tick * 2 * pi + p.drift) * 20;
      final driftY = cos(tick * 2 * pi * 0.5 + p.drift) * 10;
      final x = ((p.x + tick * p.speed) % 1.0) * size.width + driftX;
      final y = p.y * size.height + driftY;

      final twinkle = 0.2 + 0.3 * sin(tick * 4 * pi + p.phase).abs();

      final paint = Paint()
        ..color = baseColor.withValues(alpha: twinkle * (isDay ? 0.4 : 0.25));
      canvas.drawCircle(Offset(x, y), p.size, paint);

      // Soft glow
      final glow = Paint()
        ..color = baseColor.withValues(alpha: twinkle * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), p.size * 2, glow);
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET RAIN OVERLAY - Golden-tinted rain
// ═══════════════════════════════════════════════════════════════════════════

class _GoldenDrop {
  double x, y, speed, length;
  _GoldenDrop(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.4 + r.nextDouble() * 0.5,
      length = 14 + r.nextDouble() * 16;
}

class SunsetRainOverlay extends StatefulWidget {
  final double intensity;
  final bool isDay;
  const SunsetRainOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDay,
  });

  @override
  State<SunsetRainOverlay> createState() => _SunsetRainOverlayState();
}

class _SunsetRainOverlayState extends State<SunsetRainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_GoldenDrop> _drops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    final count = (60 * widget.intensity).round().clamp(20, 100);
    final r = Random(42);
    _drops = List.generate(count, (_) => _GoldenDrop(r));
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
          painter: _SunsetRainPainter(
            _drops,
            _controller.value,
            widget.intensity,
            widget.isDay,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunsetRainPainter extends CustomPainter {
  final List<_GoldenDrop> drops;
  final double tick;
  final double intensity;
  final bool isDay;
  _SunsetRainPainter(this.drops, this.tick, this.intensity, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? SunsetBackground.sunGold
        : SunsetBackground.warmWhite;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.3;

    final angle = 0.1 * intensity;

    for (final d in drops) {
      final y = ((d.y + tick * d.speed) % 1.1 - 0.05) * size.height;
      final x = (d.x + angle * (y / size.height)) * size.width;

      paint.color = baseColor.withValues(alpha: 0.25 * intensity);
      final dx = sin(angle) * d.length;
      final dy = cos(angle) * d.length;
      canvas.drawLine(Offset(x, y), Offset(x + dx, y + dy), paint);

      // Splash
      if (y > size.height * 0.9) {
        final splashAlpha =
            (1.0 - (y - size.height * 0.9) / (size.height * 0.1)) * 0.12;
        paint
          ..color = baseColor.withValues(alpha: splashAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6;
        canvas.drawCircle(Offset(x, y), 2, paint);
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(_SunsetRainPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET SNOW OVERLAY - Warm-tinted snowflakes
// ═══════════════════════════════════════════════════════════════════════════

class _WarmFlake {
  double x, y, speed, size, drift;
  _WarmFlake(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.1 + r.nextDouble() * 0.15,
      size = 2 + r.nextDouble() * 4,
      drift = r.nextDouble() * 2 * pi;
}

class SunsetSnowOverlay extends StatefulWidget {
  final double intensity;
  final bool isDay;
  const SunsetSnowOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDay,
  });

  @override
  State<SunsetSnowOverlay> createState() => _SunsetSnowOverlayState();
}

class _SunsetSnowOverlayState extends State<SunsetSnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_WarmFlake> _flakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    final count = (40 * widget.intensity).round().clamp(15, 60);
    final r = Random(77);
    _flakes = List.generate(count, (_) => _WarmFlake(r));
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
          painter: _SunsetSnowPainter(_flakes, _controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunsetSnowPainter extends CustomPainter {
  final List<_WarmFlake> flakes;
  final double tick;
  final bool isDay;
  _SunsetSnowPainter(this.flakes, this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? SunsetBackground.warmWhite
        : SunsetBackground.warmWhite;
    final accentColor = isDay
        ? SunsetBackground.sunGold
        : SunsetBackground.goldenAmber;

    for (final f in flakes) {
      final y = ((f.y + tick * f.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(tick * 3 * pi + f.drift) * 15;
      final x = f.x * size.width + drift;

      // Main flake
      final paint = Paint()..color = baseColor.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x, y), f.size / 2, paint);

      // Warm glow
      final glow = Paint()
        ..color = accentColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), f.size, glow);
    }
  }

  @override
  bool shouldRepaint(_SunsetSnowPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET STORM OVERLAY - Amber lightning
// ═══════════════════════════════════════════════════════════════════════════

class SunsetStormOverlay extends StatefulWidget {
  final bool isDay;
  const SunsetStormOverlay({super.key, required this.isDay});

  @override
  State<SunsetStormOverlay> createState() => _SunsetStormOverlayState();
}

class _SunsetStormOverlayState extends State<SunsetStormOverlay>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  final Random _random = Random();
  double _flashOpacity = 0;
  Offset _flashCenter = const Offset(0.5, 0.2);

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scheduleFlash();
  }

  void _scheduleFlash() {
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(5000)), () {
      if (!mounted) return;
      _triggerFlash();
      _scheduleFlash();
    });
  }

  void _triggerFlash() {
    _flashCenter = Offset(
      0.2 + _random.nextDouble() * 0.6,
      0.05 + _random.nextDouble() * 0.3,
    );
    _flashOpacity = 0.2 + _random.nextDouble() * 0.15;
    _flashController.forward(from: 0).then((_) {
      if (mounted) setState(() => _flashOpacity = 0);
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Heavy rain
        SunsetRainOverlay(intensity: 1.0, isDay: widget.isDay),
        // Amber lightning flash
        if (_flashOpacity > 0)
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              final fade = 1.0 - _flashController.value;
              return CustomPaint(
                painter: _SunsetLightningPainter(
                  _flashCenter,
                  _flashOpacity * fade,
                  widget.isDay,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class _SunsetLightningPainter extends CustomPainter {
  final Offset center;
  final double opacity;
  final bool isDay;
  _SunsetLightningPainter(this.center, this.opacity, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final color = isDay
        ? SunsetBackground.sunGold
        : SunsetBackground.goldenAmber;

    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ).createShader(
            Rect.fromCircle(center: c, radius: size.longestSide * 0.6),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SunsetLightningPainter old) => old.opacity != opacity;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET STAR OVERLAY (Night clear) - Warm-tinted stars
// ═══════════════════════════════════════════════════════════════════════════

class _WarmStar {
  double x, y, phase, size;
  bool isGolden;
  _WarmStar(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble() * 0.65,
      phase = r.nextDouble() * 2 * pi,
      size = 0.8 + r.nextDouble() * 1.5,
      isGolden = r.nextDouble() > 0.6;
}

class SunsetStarOverlay extends StatefulWidget {
  const SunsetStarOverlay({super.key});

  @override
  State<SunsetStarOverlay> createState() => _SunsetStarOverlayState();
}

class _SunsetStarOverlayState extends State<SunsetStarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_WarmStar> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    final r = Random(55);
    _stars = List.generate(35, (_) => _WarmStar(r));
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
          painter: _SunsetStarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunsetStarPainter extends CustomPainter {
  final List<_WarmStar> stars;
  final double tick;
  _SunsetStarPainter(this.stars, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = 0.3 + 0.7 * sin((tick + s.phase) * pi).abs();
      final color = s.isGolden
          ? SunsetBackground.sunGold
          : SunsetBackground.warmWhite;

      final paint = Paint()..color = color.withValues(alpha: twinkle * 0.7);
      final center = Offset(s.x * size.width, s.y * size.height);
      canvas.drawCircle(center, s.size, paint);

      // Warm glow
      final glow = Paint()
        ..color = SunsetBackground.goldenAmber.withValues(alpha: twinkle * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, s.size * 2.5, glow);
    }
  }

  @override
  bool shouldRepaint(_SunsetStarPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET FLARE OVERLAY (Day clear) - Sun lens flares
// ═══════════════════════════════════════════════════════════════════════════

class SunsetFlareOverlay extends StatefulWidget {
  const SunsetFlareOverlay({super.key});

  @override
  State<SunsetFlareOverlay> createState() => _SunsetFlareOverlayState();
}

class _SunsetFlareOverlayState extends State<SunsetFlareOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
          painter: _FlarePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FlarePainter extends CustomPainter {
  final double tick;
  _FlarePainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = tick * 2 * pi;
    final pulse = 0.7 + 0.3 * sin(phase);

    // Main sun position (top-right area)
    final sunX = size.width * 0.75;
    final sunY = size.height * 0.1;

    // Primary sun glow
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          SunsetBackground.sunGold.withValues(alpha: 0.15 * pulse),
          SunsetBackground.goldenAmber.withValues(alpha: 0.06 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 150));
    canvas.drawCircle(Offset(sunX, sunY), 150, sunPaint);

    // Lens flares (diagonal line from sun)
    final flarePositions = [0.3, 0.5, 0.65, 0.8];
    for (int i = 0; i < flarePositions.length; i++) {
      final t = flarePositions[i];
      final flareX = sunX - (sunX - size.width * 0.3) * t;
      final flareY = sunY + (size.height * 0.7 - sunY) * t;
      final flareSize = 15 + 25 * sin(phase + i).abs();
      final flareAlpha = 0.04 + 0.02 * sin(phase * 2 + i);

      final flarePaint = Paint()
        ..color = SunsetBackground.warmCoral.withValues(alpha: flareAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(flareX, flareY),
          width: flareSize * 1.5,
          height: flareSize,
        ),
        flarePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_FlarePainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET CLOUD OVERLAY (Cloudy) - Golden-lit clouds
// ═══════════════════════════════════════════════════════════════════════════

class SunsetCloudOverlay extends StatefulWidget {
  final bool isDay;
  const SunsetCloudOverlay({super.key, required this.isDay});

  @override
  State<SunsetCloudOverlay> createState() => _SunsetCloudOverlayState();
}

class _SunsetCloudOverlayState extends State<SunsetCloudOverlay>
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
          painter: _SunsetCloudPainter(_controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunsetCloudPainter extends CustomPainter {
  final double tick;
  final bool isDay;
  _SunsetCloudPainter(this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final drift = sin(tick * 2 * pi) * 20;
    final baseColor = isDay
        ? SunsetBackground.goldenAmber
        : SunsetBackground.deepRose;

    final paint = Paint()
      ..color = baseColor.withValues(alpha: isDay ? 0.08 : 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Drifting cloud shapes
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25 + drift, size.height * 0.12),
        width: 180,
        height: 50,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7 - drift * 0.7, size.height * 0.2),
        width: 220,
        height: 65,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45 + drift * 0.5, size.height * 0.32),
        width: 160,
        height: 45,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SunsetCloudPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUNSET HAZE OVERLAY (Fog) - Warm atmospheric haze
// ═══════════════════════════════════════════════════════════════════════════

class SunsetHazeOverlay extends StatefulWidget {
  final bool isDay;
  const SunsetHazeOverlay({super.key, required this.isDay});

  @override
  State<SunsetHazeOverlay> createState() => _SunsetHazeOverlayState();
}

class _SunsetHazeOverlayState extends State<SunsetHazeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
          painter: _SunsetHazePainter(_controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunsetHazePainter extends CustomPainter {
  final double tick;
  final bool isDay;
  _SunsetHazePainter(this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? SunsetBackground.sunGold
        : SunsetBackground.goldenAmber;
    final phase = tick * 2 * pi;

    // Horizontal haze bands
    final bands = [
      (y: 0.35, h: 0.12, alpha: 0.08),
      (y: 0.50, h: 0.15, alpha: 0.10),
      (y: 0.68, h: 0.14, alpha: 0.09),
      (y: 0.85, h: 0.18, alpha: 0.12),
    ];

    for (final b in bands) {
      final drift = sin(phase + b.y * 5) * 0.02;
      final paint = Paint()
        ..color = baseColor.withValues(alpha: b.alpha + drift)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawRect(
        Rect.fromLTWH(0, b.y * size.height, size.width, b.h * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunsetHazePainter old) => old.tick != tick;
}
