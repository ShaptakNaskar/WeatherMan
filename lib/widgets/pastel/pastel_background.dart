import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/config/pastel_theme.dart';
import 'package:weatherman/providers/theme_provider.dart';

/// Pastel/Kawaii themed background with cute weather effects
///
/// 4 distinct effect variants:
/// - Light Mode Day: Bright, cheerful - cherry blossoms, sparkles, rainbows
/// - Light Mode Night: Soft dreamy - moon glow, sleepy stars, fireflies
/// - Dark Mode Day: Cozy twilight - soft glows, gentle particles
/// - Dark Mode Night: Magical night - aurora wisps, glowing moths, mystical particles
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkPastel = themeProvider.currentType == AppThemeType.pastelDark;
    final pastelTheme = isDarkPastel
        ? PastelDarkTheme()
        : CatppuccinLatteTheme();
    final gradient = pastelTheme.getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // Ambient layer (varies by mode)
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _buildAmbientOverlay(isDarkPastel),
                ),
              ),
            ),
          ),
          // Weather particle overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _buildWeatherOverlay(isDarkPastel),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildAmbientOverlay(bool isDark) {
    if (isDark) {
      // Dark pastel modes
      return isDay
          ? const PastelDarkDayAmbient() // Cozy twilight glow
          : const PastelDarkNightAmbient(); // Magical aurora wisps
    } else {
      // Light pastel modes
      return isDay
          ? const PastelLightDayAmbient() // Cheerful sparkles
          : const PastelLightNightAmbient(); // Dreamy moon glow
    }
  }

  Widget _buildWeatherOverlay(bool isDark) {
    // Rain — cute rain drops with splash
    if (_isRainy) {
      return PastelRainOverlay(
        intensity: _getRainIntensity(),
        isDark: isDark,
        isDay: isDay,
      );
    }
    // Snow — sparkly snowflakes
    if (_isSnowy) {
      return PastelSnowOverlay(
        intensity: _getSnowIntensity(),
        isDark: isDark,
        isDay: isDay,
      );
    }
    // Thunderstorm — soft cute lightning with hearts
    if (_isThunderstorm) {
      return PastelStormOverlay(isDark: isDark, isDay: isDay);
    }
    // Clear day — floating elements (blossoms/butterflies/sparkles)
    if (isDay && _isClear) {
      return isDark
          ? const PastelDarkDayFloatingOverlay()
          : const PastelLightDayFloatingOverlay();
    }
    // Clear night — stars/fireflies/moths
    if (!isDay && _isClear) {
      return isDark
          ? const PastelDarkNightStarOverlay()
          : const PastelLightNightStarOverlay();
    }
    // Cloudy — cute drifting clouds
    if (_isCloudy) {
      return PastelCloudOverlay(isDark: isDark, isDay: isDay);
    }
    // Fog — dreamy mist
    if (_isFog) {
      return PastelMistOverlay(isDark: isDark, isDay: isDay);
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
// AMBIENT OVERLAYS - Background ambiance for each mode
// ═══════════════════════════════════════════════════════════════════════════

/// Light Mode Day - Cheerful sparkles and rainbow hints
class PastelLightDayAmbient extends StatefulWidget {
  const PastelLightDayAmbient({super.key});

  @override
  State<PastelLightDayAmbient> createState() => _PastelLightDayAmbientState();
}

class _PastelLightDayAmbientState extends State<PastelLightDayAmbient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    final r = Random(111);
    _sparkles = List.generate(15, (_) => _Sparkle(r));
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
          painter: _LightDayAmbientPainter(_sparkles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Sparkle {
  double x, y, phase, size;
  int colorIndex;
  _Sparkle(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      phase = r.nextDouble() * 2 * pi,
      size = 2 + r.nextDouble() * 3,
      colorIndex = r.nextInt(4);
}

class _LightDayAmbientPainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double tick;
  // Catppuccin Latte accent colors for sparkles
  static const colors = [
    CatppuccinLatteTheme.pink,
    CatppuccinLatteTheme.lavender,
    CatppuccinLatteTheme.teal,
    CatppuccinLatteTheme.yellow,
  ];

  _LightDayAmbientPainter(this.sparkles, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle rainbow arc hint
    final rainbowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    rainbowPaint.shader = const LinearGradient(
      colors: [
        Color(0x08FFB7D5), // pink
        Color(0x08FFE7A0), // yellow
        Color(0x0898E4C9), // mint
        Color(0x08A0D2F0), // blue
        Color(0x08B8A9E8), // lavender
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));

    final arcRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.15),
      width: size.width * 0.8,
      height: size.height * 0.3,
    );
    canvas.drawArc(arcRect, pi, pi, false, rainbowPaint);

    // Sparkles
    for (final s in sparkles) {
      final twinkle = (sin(tick * 2 * pi + s.phase) + 1) / 2;
      if (twinkle > 0.5) {
        final paint = Paint()
          ..color = colors[s.colorIndex].withValues(
            alpha: (twinkle - 0.5) * 0.4,
          );
        final center = Offset(s.x * size.width, s.y * size.height);

        // 4-point star shape
        _drawStar(canvas, center, s.size * twinkle, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(
      center.translate(-size, 0),
      center.translate(size, 0),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      center.translate(0, -size),
      center.translate(0, size),
      paint,
    );
    canvas.drawCircle(center, size * 0.3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_LightDayAmbientPainter old) => old.tick != tick;
}

/// Light Mode Night - Dreamy moon glow
class PastelLightNightAmbient extends StatefulWidget {
  const PastelLightNightAmbient({super.key});

  @override
  State<PastelLightNightAmbient> createState() =>
      _PastelLightNightAmbientState();
}

class _PastelLightNightAmbientState extends State<PastelLightNightAmbient>
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
          painter: _LightNightAmbientPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LightNightAmbientPainter extends CustomPainter {
  final double tick;
  _LightNightAmbientPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.9 + 0.1 * sin(tick * 2 * pi);

    // Moon glow
    final moonCenter = Offset(size.width * 0.8, size.height * 0.12);

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          CatppuccinLatteTheme.yellow.withValues(alpha: 0.08 * pulse),
          CatppuccinLatteTheme.lavender.withValues(alpha: 0.04 * pulse),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 100));
    canvas.drawCircle(moonCenter, 100, glowPaint);

    // Moon
    final moonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(moonCenter, 25, moonPaint);

    // Soft sleepy z's floating up
    final zPhase = (tick * 3) % 1.0;
    final zAlpha = sin(zPhase * pi) * 0.1;
    if (zAlpha > 0.02) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            fontSize: 14 + zPhase * 6,
            color: CatppuccinLatteTheme.lavender.withValues(alpha: zAlpha),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(moonCenter.dx + 30 + zPhase * 15, moonCenter.dy - zPhase * 40),
      );
    }
  }

  @override
  bool shouldRepaint(_LightNightAmbientPainter old) => old.tick != tick;
}

/// Dark Mode Day - Cozy twilight glow with soft particles
class PastelDarkDayAmbient extends StatefulWidget {
  const PastelDarkDayAmbient({super.key});

  @override
  State<PastelDarkDayAmbient> createState() => _PastelDarkDayAmbientState();
}

class _PastelDarkDayAmbientState extends State<PastelDarkDayAmbient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
          painter: _DarkDayAmbientPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _DarkDayAmbientPainter extends CustomPainter {
  final double tick;
  _DarkDayAmbientPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = tick * 2 * pi;

    // Soft warm glow from top
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          const Color(0xFFFFB7D5).withValues(alpha: 0.06 + 0.02 * sin(phase)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Drifting soft orbs
    for (int i = 0; i < 3; i++) {
      final orbPhase = phase + i * 2.1;
      final x = size.width * (0.2 + 0.6 * ((sin(orbPhase * 0.3) + 1) / 2));
      final y = size.height * (0.15 + 0.3 * ((cos(orbPhase * 0.2) + 1) / 2));

      final orbPaint = Paint()
        ..color = const Color(0xFFCBB8F0).withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(Offset(x, y), 60, orbPaint);
    }
  }

  @override
  bool shouldRepaint(_DarkDayAmbientPainter old) => old.tick != tick;
}

/// Dark Mode Night - Magical aurora wisps
class PastelDarkNightAmbient extends StatefulWidget {
  const PastelDarkNightAmbient({super.key});

  @override
  State<PastelDarkNightAmbient> createState() => _PastelDarkNightAmbientState();
}

class _PastelDarkNightAmbientState extends State<PastelDarkNightAmbient>
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
          painter: _DarkNightAmbientPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _DarkNightAmbientPainter extends CustomPainter {
  final double tick;
  _DarkNightAmbientPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = tick * 2 * pi;

    // Aurora wisps
    for (int i = 0; i < 3; i++) {
      final wispPhase = phase * 0.3 + i * 1.2;
      final path = Path();

      final startY = size.height * (0.1 + i * 0.08);
      path.moveTo(0, startY);

      for (double x = 0; x <= size.width; x += 20) {
        final wave =
            sin(x / 80 + wispPhase) * 20 + cos(x / 120 + wispPhase * 0.7) * 15;
        path.lineTo(x, startY + wave);
      }
      path.lineTo(size.width, startY + 50);
      path.lineTo(0, startY + 50);
      path.close();

      final colors = [
        const Color(0xFFCBB8F0), // lavender
        const Color(0xFFFFB7D5), // pink
        const Color(0xFF98E4C9), // mint
      ];

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[i].withValues(alpha: 0.04),
            colors[i].withValues(alpha: 0.02),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, startY, size.width, 60))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DarkNightAmbientPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// RAIN OVERLAY - Cute rain with different styles per mode
// ═══════════════════════════════════════════════════════════════════════════

class _CuteDrop {
  double x, y, speed, length;
  _CuteDrop(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.3 + r.nextDouble() * 0.4,
      length = 12 + r.nextDouble() * 15;
}

class PastelRainOverlay extends StatefulWidget {
  final double intensity;
  final bool isDark;
  final bool isDay;
  const PastelRainOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDark,
    required this.isDay,
  });

  @override
  State<PastelRainOverlay> createState() => _PastelRainOverlayState();
}

class _PastelRainOverlayState extends State<PastelRainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CuteDrop> _drops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    final count = (20 + 25 * widget.intensity).round();
    final r = Random(42);
    _drops = List.generate(count, (_) => _CuteDrop(r));
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
          painter: _PastelRainPainter(
            _drops,
            _controller.value,
            widget.intensity,
            widget.isDark,
            widget.isDay,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelRainPainter extends CustomPainter {
  final List<_CuteDrop> drops;
  final double tick;
  final double intensity;
  final bool isDark;
  final bool isDay;
  _PastelRainPainter(
    this.drops,
    this.tick,
    this.intensity,
    this.isDark,
    this.isDay,
  );

  Color get _dropColor {
    if (isDark) {
      return isDay
          ? const Color(0xFFA0D2F0) // soft blue
          : const Color(0xFFCBB8F0); // lavender
    } else {
      return isDay
          ? CatppuccinLatteTheme.sky
          : const Color(0xFFB8A9E8); // darker lavender
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _dropColor.withValues(alpha: 0.3 + intensity * 0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final d in drops) {
      final y = ((d.y + tick * d.speed * 1.5) % 1.15 - 0.1) * size.height;
      final x = d.x * size.width;

      canvas.drawLine(Offset(x, y), Offset(x, y + d.length), paint);

      // Cute splash at bottom
      if (y > size.height * 0.88) {
        final splashProgress = (y - size.height * 0.88) / (size.height * 0.12);
        final splashPaint = Paint()
          ..color = _dropColor.withValues(alpha: (1.0 - splashProgress) * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        // Multiple expanding rings
        for (int i = 0; i < 2; i++) {
          final ringSize = 3 + splashProgress * 8 + i * 3;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x, y),
              width: ringSize * 2,
              height: ringSize,
            ),
            splashPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PastelRainPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SNOW OVERLAY - Sparkly snowflakes
// ═══════════════════════════════════════════════════════════════════════════

class _CuteFlake {
  double x, y, speed, size, drift, rotation;
  int shape; // 0=circle, 1=star, 2=heart
  _CuteFlake(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.06 + r.nextDouble() * 0.1,
      size = 3 + r.nextDouble() * 5,
      drift = r.nextDouble() * 2 * pi,
      rotation = r.nextDouble() * 2 * pi,
      shape = r.nextInt(3);
}

class PastelSnowOverlay extends StatefulWidget {
  final double intensity;
  final bool isDark;
  final bool isDay;
  const PastelSnowOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDark,
    required this.isDay,
  });

  @override
  State<PastelSnowOverlay> createState() => _PastelSnowOverlayState();
}

class _PastelSnowOverlayState extends State<PastelSnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CuteFlake> _flakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    final count = (20 + 25 * widget.intensity).round();
    final r = Random(77);
    _flakes = List.generate(count, (_) => _CuteFlake(r));
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
          painter: _PastelSnowPainter(
            _flakes,
            _controller.value,
            widget.isDark,
            widget.isDay,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelSnowPainter extends CustomPainter {
  final List<_CuteFlake> flakes;
  final double tick;
  final bool isDark;
  final bool isDay;
  _PastelSnowPainter(this.flakes, this.tick, this.isDark, this.isDay);

  Color get _flakeColor {
    if (isDark) {
      return isDay ? Colors.white : const Color(0xFFE8E0FF);
    } else {
      return isDay ? Colors.white : const Color(0xFFF0E8FF);
    }
  }

  Color get _glowColor {
    if (isDark) {
      return isDay ? CatppuccinLatteTheme.lavender : const Color(0xFFFFB7D5);
    } else {
      return isDay ? CatppuccinLatteTheme.sky : CatppuccinLatteTheme.lavender;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in flakes) {
      final y = ((f.y + tick * f.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(tick * 3 * pi + f.drift) * 12;
      final x = f.x * size.width + drift;
      final rotation = f.rotation + tick * 2 * pi;

      final paint = Paint()..color = _flakeColor.withValues(alpha: 0.6);
      final glowPaint = Paint()
        ..color = _glowColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw based on shape
      if (f.shape == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, f.size / 2, glowPaint);
        canvas.drawCircle(Offset.zero, f.size / 3, paint);
      } else if (f.shape == 1) {
        // 6-point star
        _drawSnowflakeStar(canvas, f.size, paint, glowPaint);
      } else {
        // Tiny heart (on some flakes)
        _drawTinyHeart(canvas, f.size * 0.8, paint, glowPaint);
      }

      canvas.restore();
    }
  }

  void _drawSnowflakeStar(Canvas canvas, double size, Paint paint, Paint glow) {
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final end = Offset(cos(angle) * size, sin(angle) * size);
      canvas.drawLine(Offset.zero, end, glow..strokeWidth = 2);
      canvas.drawLine(Offset.zero, end, paint..strokeWidth = 1);
    }
  }

  void _drawTinyHeart(Canvas canvas, double size, Paint paint, Paint glow) {
    final path = Path();
    path.moveTo(0, size * 0.3);
    path.cubicTo(
      -size * 0.5,
      -size * 0.3,
      -size * 0.5,
      size * 0.1,
      0,
      size * 0.5,
    );
    path.cubicTo(
      size * 0.5,
      size * 0.1,
      size * 0.5,
      -size * 0.3,
      0,
      size * 0.3,
    );
    canvas.drawPath(path, glow..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_PastelSnowPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// STORM OVERLAY - Soft cute lightning
// ═══════════════════════════════════════════════════════════════════════════

class PastelStormOverlay extends StatefulWidget {
  final bool isDark;
  final bool isDay;
  const PastelStormOverlay({
    super.key,
    required this.isDark,
    required this.isDay,
  });

  @override
  State<PastelStormOverlay> createState() => _PastelStormOverlayState();
}

class _PastelStormOverlayState extends State<PastelStormOverlay>
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
      duration: const Duration(milliseconds: 200),
    );
    _scheduleFlash();
  }

  void _scheduleFlash() {
    Future.delayed(Duration(milliseconds: 2500 + _random.nextInt(4000)), () {
      if (!mounted) return;
      _triggerFlash();
      _scheduleFlash();
    });
  }

  void _triggerFlash() {
    _flashCenter = Offset(
      0.2 + _random.nextDouble() * 0.6,
      0.08 + _random.nextDouble() * 0.2,
    );
    _flashOpacity = 0.12 + _random.nextDouble() * 0.08;
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
        // Rain
        PastelRainOverlay(
          intensity: 0.9,
          isDark: widget.isDark,
          isDay: widget.isDay,
        ),
        // Soft flash
        if (_flashOpacity > 0)
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              final fade = 1.0 - _flashController.value;
              return CustomPaint(
                painter: _PastelLightningPainter(
                  _flashCenter,
                  _flashOpacity * fade,
                  widget.isDark,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class _PastelLightningPainter extends CustomPainter {
  final Offset center;
  final double opacity;
  final bool isDark;
  _PastelLightningPainter(this.center, this.opacity, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final color = isDark
        ? const Color(0xFFCBB8F0)
        : CatppuccinLatteTheme.yellow;

    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 1.0],
          ).createShader(
            Rect.fromCircle(center: c, radius: size.longestSide * 0.5),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_PastelLightningPainter old) => old.opacity != opacity;
}

// ═══════════════════════════════════════════════════════════════════════════
// FLOATING OVERLAYS (Clear day) - Different for each mode
// ═══════════════════════════════════════════════════════════════════════════

/// Light Day: Cherry blossoms and butterflies
class PastelLightDayFloatingOverlay extends StatefulWidget {
  const PastelLightDayFloatingOverlay({super.key});

  @override
  State<PastelLightDayFloatingOverlay> createState() =>
      _PastelLightDayFloatingState();
}

class _PastelLightDayFloatingState extends State<PastelLightDayFloatingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatingPetal> _petals;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    final r = Random(222);
    _petals = List.generate(15, (_) => _FloatingPetal(r));
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
          painter: _LightDayFloatingPainter(_petals, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FloatingPetal {
  double x, y, speed, size, drift, rotation;
  int colorIndex;
  _FloatingPetal(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.02 + r.nextDouble() * 0.03,
      size = 4 + r.nextDouble() * 6,
      drift = r.nextDouble() * 2 * pi,
      rotation = r.nextDouble() * 2 * pi,
      colorIndex = r.nextInt(3);
}

class _LightDayFloatingPainter extends CustomPainter {
  final List<_FloatingPetal> petals;
  final double tick;
  // Catppuccin Latte colors for petals
  static const colors = [
    CatppuccinLatteTheme.pink,
    CatppuccinLatteTheme.peach,
    CatppuccinLatteTheme.lavender,
  ];

  _LightDayFloatingPainter(this.petals, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final drift = sin(tick * 2 * pi + p.drift) * 20;
      final yDrift = cos(tick * 2 * pi * 0.5 + p.drift) * 10;
      final x = (p.x * size.width + drift) % size.width;
      final y = ((p.y + tick * p.speed) % 1.0) * size.height + yDrift;
      final rotation = p.rotation + tick * pi;

      final color = colors[p.colorIndex];
      final alpha = 0.35 + 0.15 * sin(tick * 2 * pi + p.drift).abs();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw petal shape
      final path = Path();
      path.moveTo(0, -p.size);
      path.quadraticBezierTo(p.size * 0.6, 0, 0, p.size);
      path.quadraticBezierTo(-p.size * 0.6, 0, 0, -p.size);

      final paint = Paint()..color = color.withValues(alpha: alpha);
      final glow = Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LightDayFloatingPainter old) => old.tick != tick;
}

/// Dark Day: Soft glowing orbs and sparkles
class PastelDarkDayFloatingOverlay extends StatefulWidget {
  const PastelDarkDayFloatingOverlay({super.key});

  @override
  State<PastelDarkDayFloatingOverlay> createState() =>
      _PastelDarkDayFloatingState();
}

class _PastelDarkDayFloatingState extends State<PastelDarkDayFloatingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_GlowOrb> _orbs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    final r = Random(333);
    _orbs = List.generate(12, (_) => _GlowOrb(r));
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
          painter: _DarkDayFloatingPainter(_orbs, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GlowOrb {
  double x, y, speed, size, phase;
  int colorIndex;
  _GlowOrb(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.01 + r.nextDouble() * 0.02,
      size = 6 + r.nextDouble() * 10,
      phase = r.nextDouble() * 2 * pi,
      colorIndex = r.nextInt(3);
}

class _DarkDayFloatingPainter extends CustomPainter {
  final List<_GlowOrb> orbs;
  final double tick;
  static const colors = [
    Color(0xFFCBB8F0), // lavender
    Color(0xFFFFB7D5), // pink
    Color(0xFF98E4C9), // mint
  ];

  _DarkDayFloatingPainter(this.orbs, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    for (final o in orbs) {
      final drift = sin(tick * 2 * pi + o.phase) * 15;
      final yDrift = cos(tick * 2 * pi * 0.3 + o.phase) * 10;
      final x = (o.x * size.width + drift);
      final y = ((o.y + tick * o.speed) % 1.0) * size.height + yDrift;

      final pulse = 0.6 + 0.4 * sin(tick * 4 * pi + o.phase).abs();
      final color = colors[o.colorIndex];

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, o.size);
      canvas.drawCircle(Offset(x, y), o.size * 1.5, glowPaint);

      // Core
      final corePaint = Paint()..color = color.withValues(alpha: 0.4 * pulse);
      canvas.drawCircle(Offset(x, y), o.size * 0.4, corePaint);
    }
  }

  @override
  bool shouldRepaint(_DarkDayFloatingPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// STAR OVERLAYS (Clear night) - Different for each mode
// ═══════════════════════════════════════════════════════════════════════════

/// Light Night: Soft twinkling stars with fireflies
class PastelLightNightStarOverlay extends StatefulWidget {
  const PastelLightNightStarOverlay({super.key});

  @override
  State<PastelLightNightStarOverlay> createState() =>
      _PastelLightNightStarState();
}

class _PastelLightNightStarState extends State<PastelLightNightStarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SoftStar> _stars;
  late List<_Firefly> _fireflies;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    final r = Random(444);
    _stars = List.generate(25, (_) => _SoftStar(r));
    _fireflies = List.generate(8, (_) => _Firefly(r));
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
          painter: _LightNightStarPainter(
            _stars,
            _fireflies,
            _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SoftStar {
  double x, y, phase, size;
  _SoftStar(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble() * 0.6,
      phase = r.nextDouble() * 2 * pi,
      size = 1 + r.nextDouble() * 2;
}

class _Firefly {
  double x, y, phase, speed;
  _Firefly(Random r)
    : x = r.nextDouble(),
      y = 0.5 + r.nextDouble() * 0.4,
      phase = r.nextDouble() * 2 * pi,
      speed = 0.02 + r.nextDouble() * 0.03;
}

class _LightNightStarPainter extends CustomPainter {
  final List<_SoftStar> stars;
  final List<_Firefly> fireflies;
  final double tick;
  _LightNightStarPainter(this.stars, this.fireflies, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    // Stars
    for (final s in stars) {
      final twinkle = 0.3 + 0.7 * sin((tick + s.phase) * pi).abs();
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: twinkle * 0.6);
      final center = Offset(s.x * size.width, s.y * size.height);
      canvas.drawCircle(center, s.size, paint);

      // Soft glow
      final glow = Paint()
        ..color = CatppuccinLatteTheme.yellow.withValues(alpha: twinkle * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, s.size * 2, glow);
    }

    // Fireflies
    for (final f in fireflies) {
      final drift = sin(tick * 2 + f.phase) * 30;
      final yDrift = cos(tick * 1.5 + f.phase) * 20;
      final x = (f.x * size.width + drift);
      final y = f.y * size.height + yDrift;

      final blink = (sin(tick * 6 + f.phase) + 1) / 2;
      if (blink > 0.3) {
        final alpha = (blink - 0.3) * 0.8;
        final paint = Paint()
          ..color = CatppuccinLatteTheme.yellow.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), 4, paint);

        final core = Paint()..color = Colors.white.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), 1.5, core);
      }
    }
  }

  @override
  bool shouldRepaint(_LightNightStarPainter old) => true;
}

/// Dark Night: Magical stars with glowing moths and constellations
class PastelDarkNightStarOverlay extends StatefulWidget {
  const PastelDarkNightStarOverlay({super.key});

  @override
  State<PastelDarkNightStarOverlay> createState() =>
      _PastelDarkNightStarState();
}

class _PastelDarkNightStarState extends State<PastelDarkNightStarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_MagicStar> _stars;
  late List<_GlowMoth> _moths;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    final r = Random(555);
    _stars = List.generate(35, (_) => _MagicStar(r));
    _moths = List.generate(5, (_) => _GlowMoth(r));
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
          painter: _DarkNightStarPainter(_stars, _moths, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MagicStar {
  double x, y, phase, size;
  int colorIndex;
  _MagicStar(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble() * 0.65,
      phase = r.nextDouble() * 2 * pi,
      size = 1 + r.nextDouble() * 2.5,
      colorIndex = r.nextInt(3);
}

class _GlowMoth {
  double x, y, phase, size;
  _GlowMoth(Random r)
    : x = r.nextDouble(),
      y = 0.3 + r.nextDouble() * 0.5,
      phase = r.nextDouble() * 2 * pi,
      size = 8 + r.nextDouble() * 6;
}

class _DarkNightStarPainter extends CustomPainter {
  final List<_MagicStar> stars;
  final List<_GlowMoth> moths;
  final double tick;
  static const starColors = [
    Colors.white,
    Color(0xFFCBB8F0),
    Color(0xFFFFB7D5),
  ];

  _DarkNightStarPainter(this.stars, this.moths, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connection lines between some stars (constellation effect)
    final starPaint = Paint()
      ..color = const Color(0xFFCBB8F0).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (int i = 0; i < stars.length - 1; i++) {
      final s1 = stars[i];
      final s2 = stars[i + 1];
      final p1 = Offset(s1.x * size.width, s1.y * size.height);
      final p2 = Offset(s2.x * size.width, s2.y * size.height);
      if ((p1 - p2).distance < 80) {
        canvas.drawLine(p1, p2, starPaint);
      }
    }

    // Stars
    for (final s in stars) {
      final twinkle = 0.4 + 0.6 * sin((tick * 2 * pi + s.phase)).abs();
      final color = starColors[s.colorIndex];
      final center = Offset(s.x * size.width, s.y * size.height);

      // Glow
      final glow = Paint()
        ..color = color.withValues(alpha: twinkle * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, s.size * 2.5, glow);

      // Core
      final paint = Paint()..color = color.withValues(alpha: twinkle * 0.8);
      canvas.drawCircle(center, s.size, paint);
    }

    // Glowing moths
    for (final m in moths) {
      final drift = sin(tick * 2 * pi + m.phase) * 40;
      final yDrift = cos(tick * 1.5 * pi + m.phase) * 25;
      final x = (m.x * size.width + drift);
      final y = m.y * size.height + yDrift;
      final wingFlap = sin(tick * 20 * pi + m.phase);

      // Glow
      final glowPaint = Paint()
        ..color = const Color(0xFFCBB8F0).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), m.size, glowPaint);

      // Simple moth shape (two wings)
      final wingPaint = Paint()
        ..color = const Color(0xFFCBB8F0).withValues(alpha: 0.3);
      final wingWidth = m.size * 0.7 * (0.7 + 0.3 * wingFlap.abs());
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - wingWidth, y),
          width: wingWidth,
          height: m.size * 0.4,
        ),
        wingPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + wingWidth, y),
          width: wingWidth,
          height: m.size * 0.4,
        ),
        wingPaint,
      );
      // Body
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 3, height: m.size * 0.3),
        Paint()..color = const Color(0xFFE8E0FF).withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_DarkNightStarPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// CLOUD OVERLAY - Cute drifting clouds
// ═══════════════════════════════════════════════════════════════════════════

class PastelCloudOverlay extends StatefulWidget {
  final bool isDark;
  final bool isDay;
  const PastelCloudOverlay({
    super.key,
    required this.isDark,
    required this.isDay,
  });

  @override
  State<PastelCloudOverlay> createState() => _PastelCloudOverlayState();
}

class _PastelCloudOverlayState extends State<PastelCloudOverlay>
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
          painter: _PastelCloudPainter(
            _controller.value,
            widget.isDark,
            widget.isDay,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelCloudPainter extends CustomPainter {
  final double tick;
  final bool isDark;
  final bool isDay;
  _PastelCloudPainter(this.tick, this.isDark, this.isDay);

  Color get _cloudColor {
    if (isDark) {
      return isDay ? const Color(0xFFCBB8F0) : const Color(0xFF887AAA);
    } else {
      return isDay ? Colors.white : const Color(0xFFD4C8E8);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final drift = sin(tick * 2 * pi) * 20;
    final alpha = isDark ? 0.12 : 0.25;

    final paint = Paint()
      ..color = _cloudColor.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    // Multiple soft cloud shapes
    final clouds = [
      (x: 0.2, y: 0.1, w: 180.0, h: 55.0, driftMul: 1.0),
      (x: 0.7, y: 0.18, w: 220.0, h: 65.0, driftMul: -0.7),
      (x: 0.45, y: 0.28, w: 160.0, h: 50.0, driftMul: 0.5),
    ];

    for (final c in clouds) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * c.x + drift * c.driftMul,
            size.height * c.y,
          ),
          width: c.w,
          height: c.h,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PastelCloudPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// MIST OVERLAY - Dreamy fog
// ═══════════════════════════════════════════════════════════════════════════

class PastelMistOverlay extends StatefulWidget {
  final bool isDark;
  final bool isDay;
  const PastelMistOverlay({
    super.key,
    required this.isDark,
    required this.isDay,
  });

  @override
  State<PastelMistOverlay> createState() => _PastelMistOverlayState();
}

class _PastelMistOverlayState extends State<PastelMistOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
          painter: _PastelMistPainter(
            _controller.value,
            widget.isDark,
            widget.isDay,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _PastelMistPainter extends CustomPainter {
  final double tick;
  final bool isDark;
  final bool isDay;
  _PastelMistPainter(this.tick, this.isDark, this.isDay);

  Color get _mistColor {
    if (isDark) {
      return isDay ? const Color(0xFFCBB8F0) : const Color(0xFF887AAA);
    } else {
      return isDay ? const Color(0xFFE8E0F5) : const Color(0xFFBBADD8);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final phase = tick * 2 * pi;
    final alpha = isDark ? 0.08 : 0.12;

    // Flowing mist bands
    final bands = [
      (y: 0.35, h: 0.12),
      (y: 0.50, h: 0.15),
      (y: 0.70, h: 0.14),
      (y: 0.88, h: 0.18),
    ];

    for (int i = 0; i < bands.length; i++) {
      final b = bands[i];
      final drift = sin(phase + i * 1.2) * 0.03;
      final paint = Paint()
        ..color = _mistColor.withValues(alpha: alpha + drift * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawRect(
        Rect.fromLTWH(0, b.y * size.height, size.width, b.h * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PastelMistPainter old) => old.tick != tick;
}
