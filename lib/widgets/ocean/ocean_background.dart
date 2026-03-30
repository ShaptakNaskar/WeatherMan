import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/providers/theme_provider.dart';

/// Ocean theme background with deep sea / aquatic weather effects
/// Day: Lighter turquoise/teal tones with caustic light patterns
/// Night: Deep abyss blues with bioluminescent effects
class OceanBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const OceanBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  // Ocean color palette
  static const Color deepTeal = Color(0xFF00BFA5);
  static const Color lightAqua = Color(0xFF40C4FF);
  static const Color abyssBiolum = Color(0xFF00E5FF);
  static const Color seaFoam = Color(0xFF80DEEA);
  static const Color deepBlue = Color(0xFF0277BD);
  static const Color coralAccent = Color(0xFFFF8A80);

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
          // Underwater caustic light (day) or deep sea ambient (night)
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: isDay
                      ? const OceanCausticOverlay()
                      : const OceanAbyssOverlay(),
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
          // Floating bubbles ambient
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: OceanBubbleOverlay(isDay: isDay),
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
    // Rain — underwater rain effect (falling water drops from surface)
    if (_isRainy) {
      return OceanRainOverlay(intensity: _getRainIntensity(), isDay: isDay);
    }
    // Snow — sea foam / ice crystals
    if (_isSnowy) {
      return OceanSnowOverlay(intensity: _getSnowIntensity(), isDay: isDay);
    }
    // Thunderstorm — electric jellyfish / deep sea lightning
    if (_isThunderstorm) {
      return OceanStormOverlay(isDay: isDay);
    }
    // Clear night — bioluminescent plankton
    if (!isDay && _isClear) {
      return const OceanBiolumOverlay();
    }
    // Clear day — sun rays through water
    if (isDay && _isClear) {
      return const OceanSunRaysOverlay();
    }
    // Cloudy — murky water / kelp shadows
    if (_isCloudy) {
      return OceanMurkOverlay(isDay: isDay);
    }
    // Fog — deep sea mist / thermal vents
    if (_isFog) {
      return OceanMistOverlay(isDay: isDay);
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
// CAUSTIC LIGHT OVERLAY (Day) - Underwater sun patterns
// ═══════════════════════════════════════════════════════════════════════════

class OceanCausticOverlay extends StatefulWidget {
  const OceanCausticOverlay({super.key});

  @override
  State<OceanCausticOverlay> createState() => _OceanCausticOverlayState();
}

class _OceanCausticOverlayState extends State<OceanCausticOverlay>
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
          painter: _CausticPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CausticPainter extends CustomPainter {
  final double tick;
  _CausticPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Multiple caustic light patches
    for (int i = 0; i < 5; i++) {
      final phase = tick * 2 * pi + i * 1.3;
      final x = size.width * (0.2 + 0.6 * ((sin(phase * 0.7 + i) + 1) / 2));
      final y =
          size.height * (0.1 + 0.4 * ((cos(phase * 0.5 + i * 0.8) + 1) / 2));
      final scale = 80 + 40 * sin(phase + i);
      final alpha = 0.03 + 0.02 * sin(phase * 2);

      paint.color = OceanBackground.lightAqua.withValues(alpha: alpha);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: scale * 2, height: scale),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CausticPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// ABYSS OVERLAY (Night) - Deep sea ambient darkness
// ═══════════════════════════════════════════════════════════════════════════

class OceanAbyssOverlay extends StatefulWidget {
  const OceanAbyssOverlay({super.key});

  @override
  State<OceanAbyssOverlay> createState() => _OceanAbyssOverlayState();
}

class _OceanAbyssOverlayState extends State<OceanAbyssOverlay>
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
          painter: _AbyssPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AbyssPainter extends CustomPainter {
  final double tick;
  _AbyssPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle deep sea currents
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    for (int i = 0; i < 3; i++) {
      final phase = tick * 2 * pi + i * 2.1;
      final x = size.width * (0.3 + 0.4 * sin(phase * 0.3));
      final y = size.height * (0.4 + 0.3 * cos(phase * 0.2 + i));

      paint.color = OceanBackground.deepBlue.withValues(alpha: 0.08);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 300, height: 150),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AbyssPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// BUBBLE OVERLAY - Floating bubbles
// ═══════════════════════════════════════════════════════════════════════════

class _Bubble {
  double x, y, size, speed, wobblePhase;
  _Bubble(Random r)
    : x = r.nextDouble(),
      y = 1.0 + r.nextDouble() * 0.2,
      size = 2 + r.nextDouble() * 6,
      speed = 0.03 + r.nextDouble() * 0.05,
      wobblePhase = r.nextDouble() * 2 * pi;
}

class OceanBubbleOverlay extends StatefulWidget {
  final bool isDay;
  const OceanBubbleOverlay({super.key, required this.isDay});

  @override
  State<OceanBubbleOverlay> createState() => _OceanBubbleOverlayState();
}

class _OceanBubbleOverlayState extends State<OceanBubbleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    final r = Random(123);
    _bubbles = List.generate(12, (_) => _Bubble(r));
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
          painter: _BubblePainter(_bubbles, _controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double tick;
  final bool isDay;
  _BubblePainter(this.bubbles, this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? OceanBackground.seaFoam
        : OceanBackground.abyssBiolum;

    for (final b in bubbles) {
      final y = ((b.y - tick * b.speed) % 1.3 - 0.1) * size.height;
      final wobble = sin(tick * 4 * pi + b.wobblePhase) * 8;
      final x = b.x * size.width + wobble;

      // Bubble outline
      final paint = Paint()
        ..color = baseColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(x, y), b.size, paint);

      // Highlight
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x - b.size * 0.3, y - b.size * 0.3),
        b.size * 0.2,
        highlight,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// OCEAN RAIN OVERLAY - Drops falling from surface
// ═══════════════════════════════════════════════════════════════════════════

class _OceanDrop {
  double x, y, speed, length;
  _OceanDrop(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.3 + r.nextDouble() * 0.4,
      length = 15 + r.nextDouble() * 20;
}

class OceanRainOverlay extends StatefulWidget {
  final double intensity;
  final bool isDay;
  const OceanRainOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDay,
  });

  @override
  State<OceanRainOverlay> createState() => _OceanRainOverlayState();
}

class _OceanRainOverlayState extends State<OceanRainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_OceanDrop> _drops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    final count = (50 * widget.intensity).round().clamp(15, 80);
    final r = Random(42);
    _drops = List.generate(count, (_) => _OceanDrop(r));
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
          painter: _OceanRainPainter(
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

class _OceanRainPainter extends CustomPainter {
  final List<_OceanDrop> drops;
  final double tick;
  final double intensity;
  final bool isDay;
  _OceanRainPainter(this.drops, this.tick, this.intensity, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay
        ? OceanBackground.lightAqua
        : OceanBackground.abyssBiolum;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    for (final d in drops) {
      final y = ((d.y + tick * d.speed) % 1.1 - 0.05) * size.height;
      final x = d.x * size.width;
      paint.color = baseColor.withValues(alpha: 0.25 * intensity);
      canvas.drawLine(Offset(x, y), Offset(x, y + d.length), paint);

      // Ripple at bottom
      if (y > size.height * 0.85) {
        final rippleAlpha =
            (1.0 - (y - size.height * 0.85) / (size.height * 0.15)) * 0.15;
        paint
          ..color = baseColor.withValues(alpha: rippleAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 12, height: 4),
          paint,
        );
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(_OceanRainPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// OCEAN SNOW OVERLAY - Sea foam / ice crystals
// ═══════════════════════════════════════════════════════════════════════════

class _SeaFoam {
  double x, y, speed, size, drift;
  _SeaFoam(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.08 + r.nextDouble() * 0.12,
      size = 3 + r.nextDouble() * 5,
      drift = r.nextDouble() * 2 * pi;
}

class OceanSnowOverlay extends StatefulWidget {
  final double intensity;
  final bool isDay;
  const OceanSnowOverlay({
    super.key,
    this.intensity = 0.5,
    required this.isDay,
  });

  @override
  State<OceanSnowOverlay> createState() => _OceanSnowOverlayState();
}

class _OceanSnowOverlayState extends State<OceanSnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SeaFoam> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    final count = (40 * widget.intensity).round().clamp(15, 60);
    final r = Random(88);
    _particles = List.generate(count, (_) => _SeaFoam(r));
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
          painter: _SeaFoamPainter(_particles, _controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SeaFoamPainter extends CustomPainter {
  final List<_SeaFoam> particles;
  final double tick;
  final bool isDay;
  _SeaFoamPainter(this.particles, this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDay ? OceanBackground.seaFoam : Colors.white;

    for (final p in particles) {
      final y = ((p.y + tick * p.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(tick * 3 * pi + p.drift) * 12;
      final x = p.x * size.width + drift;

      // Glowing particle
      final paint = Paint()
        ..color = baseColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.size / 2, paint);

      // Soft glow
      final glow = Paint()
        ..color = baseColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), p.size, glow);
    }
  }

  @override
  bool shouldRepaint(_SeaFoamPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// OCEAN STORM OVERLAY - Electric / jellyfish lightning
// ═══════════════════════════════════════════════════════════════════════════

class OceanStormOverlay extends StatefulWidget {
  final bool isDay;
  const OceanStormOverlay({super.key, required this.isDay});

  @override
  State<OceanStormOverlay> createState() => _OceanStormOverlayState();
}

class _OceanStormOverlayState extends State<OceanStormOverlay>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  final Random _random = Random();
  double _flashOpacity = 0;
  Offset _flashCenter = const Offset(0.5, 0.3);

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scheduleFlash();
  }

  void _scheduleFlash() {
    Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(4000)), () {
      if (!mounted) return;
      _triggerFlash();
      _scheduleFlash();
    });
  }

  void _triggerFlash() {
    _flashCenter = Offset(
      0.2 + _random.nextDouble() * 0.6,
      0.1 + _random.nextDouble() * 0.4,
    );
    _flashOpacity = 0.15 + _random.nextDouble() * 0.1;
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
        OceanRainOverlay(intensity: 1.0, isDay: widget.isDay),
        // Electric flash
        if (_flashOpacity > 0)
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              final fade = 1.0 - _flashController.value;
              return CustomPaint(
                painter: _OceanLightningPainter(
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

class _OceanLightningPainter extends CustomPainter {
  final Offset center;
  final double opacity;
  final bool isDay;
  _OceanLightningPainter(this.center, this.opacity, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final color = isDay
        ? OceanBackground.lightAqua
        : OceanBackground.abyssBiolum;

    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(
            Rect.fromCircle(center: c, radius: size.longestSide * 0.5),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_OceanLightningPainter old) => old.opacity != opacity;
}

// ═══════════════════════════════════════════════════════════════════════════
// BIOLUMINESCENCE OVERLAY (Night clear) - Glowing plankton
// ═══════════════════════════════════════════════════════════════════════════

class _BioParticle {
  double x, y, phase, size, speed;
  _BioParticle(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      phase = r.nextDouble() * 2 * pi,
      size = 1 + r.nextDouble() * 2,
      speed = 0.01 + r.nextDouble() * 0.02;
}

class OceanBiolumOverlay extends StatefulWidget {
  const OceanBiolumOverlay({super.key});

  @override
  State<OceanBiolumOverlay> createState() => _OceanBiolumOverlayState();
}

class _OceanBiolumOverlayState extends State<OceanBiolumOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_BioParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    final r = Random(321);
    _particles = List.generate(40, (_) => _BioParticle(r));
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
          painter: _BiolumPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BiolumPainter extends CustomPainter {
  final List<_BioParticle> particles;
  final double tick;
  _BiolumPainter(this.particles, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final pulse = (sin(tick * 2 * pi + p.phase) + 1) / 2;
      final alpha = 0.2 + 0.5 * pulse;

      final drift = sin(tick * 2 * pi + p.phase) * 5;
      final x = p.x * size.width + drift;
      final y = ((p.y + tick * p.speed) % 1.0) * size.height;

      // Glowing particle
      final paint = Paint()
        ..color = OceanBackground.abyssBiolum.withValues(alpha: alpha * 0.8);
      canvas.drawCircle(Offset(x, y), p.size, paint);

      // Glow
      final glow = Paint()
        ..color = OceanBackground.abyssBiolum.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), p.size * 3, glow);
    }
  }

  @override
  bool shouldRepaint(_BiolumPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUN RAYS OVERLAY (Day clear) - Light shafts through water
// ═══════════════════════════════════════════════════════════════════════════

class OceanSunRaysOverlay extends StatefulWidget {
  const OceanSunRaysOverlay({super.key});

  @override
  State<OceanSunRaysOverlay> createState() => _OceanSunRaysOverlayState();
}

class _OceanSunRaysOverlayState extends State<OceanSunRaysOverlay>
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
          painter: _SunRaysPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  final double tick;
  _SunRaysPainter(this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Multiple angled light rays
    for (int i = 0; i < 5; i++) {
      final phase = tick * 2 * pi + i * 0.8;
      final sway = sin(phase) * 20;
      final alpha = 0.03 + 0.02 * sin(phase * 2);

      final path = Path();
      final startX = size.width * (0.15 + i * 0.18) + sway;
      path.moveTo(startX, 0);
      path.lineTo(startX + 40, 0);
      path.lineTo(startX + 80 + sway * 0.5, size.height);
      path.lineTo(startX + 20 + sway * 0.5, size.height);
      path.close();

      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          OceanBackground.lightAqua.withValues(alpha: alpha),
          OceanBackground.lightAqua.withValues(alpha: alpha * 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SunRaysPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// MURK OVERLAY (Cloudy) - Kelp shadows / murky water
// ═══════════════════════════════════════════════════════════════════════════

class OceanMurkOverlay extends StatefulWidget {
  final bool isDay;
  const OceanMurkOverlay({super.key, required this.isDay});

  @override
  State<OceanMurkOverlay> createState() => _OceanMurkOverlayState();
}

class _OceanMurkOverlayState extends State<OceanMurkOverlay>
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
          painter: _MurkPainter(_controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MurkPainter extends CustomPainter {
  final double tick;
  final bool isDay;
  _MurkPainter(this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    final baseColor = isDay
        ? OceanBackground.deepBlue
        : const Color(0xFF0A1520);

    // Drifting murky patches
    for (int i = 0; i < 4; i++) {
      final phase = tick * 2 * pi + i * 1.5;
      final x = size.width * (0.2 + 0.6 * sin(phase * 0.3 + i));
      final y = size.height * (0.2 + 0.6 * cos(phase * 0.2 + i * 0.7));

      paint.color = baseColor.withValues(alpha: 0.08);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 200, height: 100),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MurkPainter old) => old.tick != tick;
}

// ═══════════════════════════════════════════════════════════════════════════
// MIST OVERLAY (Fog) - Thermal vents / deep sea mist
// ═══════════════════════════════════════════════════════════════════════════

class OceanMistOverlay extends StatefulWidget {
  final bool isDay;
  const OceanMistOverlay({super.key, required this.isDay});

  @override
  State<OceanMistOverlay> createState() => _OceanMistOverlayState();
}

class _OceanMistOverlayState extends State<OceanMistOverlay>
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
          painter: _OceanMistPainter(_controller.value, widget.isDay),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OceanMistPainter extends CustomPainter {
  final double tick;
  final bool isDay;
  _OceanMistPainter(this.tick, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final color = isDay ? OceanBackground.seaFoam : OceanBackground.deepTeal;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Rising thermal vent mist
    for (int i = 0; i < 5; i++) {
      final phase = tick * 2 * pi + i * 1.2;
      final baseX = size.width * (0.15 + i * 0.18);
      final rise = (tick + i * 0.2) % 1.0;
      final y = size.height * (1.0 - rise * 0.8);
      final spread = 40 + rise * 60;
      final alpha = 0.06 * (1.0 - rise);

      paint.color = color.withValues(alpha: alpha);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(baseX + sin(phase) * 15, y),
          width: spread,
          height: spread * 0.5,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OceanMistPainter old) => old.tick != tick;
}
