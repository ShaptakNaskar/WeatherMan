import 'dart:math';

import 'package:flutter/material.dart';

enum PremiumThemeFlavor { clean, cyberpunk, pastel, sunset, ocean }

/// High-quality atmospheric layer shared by all themes.
///
/// This adds soft cinematic motion (orb drift, particles, ambient accents,
/// and edge vignettes) to make scenes feel premium without external assets.
class PremiumSceneLayer extends StatefulWidget {
  final PremiumThemeFlavor flavor;
  final int weatherCode;
  final bool isDay;

  const PremiumSceneLayer({
    super.key,
    required this.flavor,
    required this.weatherCode,
    required this.isDay,
  });

  @override
  State<PremiumSceneLayer> createState() => _PremiumSceneLayerState();
}

class _PremiumSceneLayerState extends State<PremiumSceneLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_SceneParticle> _particles = const <_SceneParticle>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _reseedParticles();
  }

  @override
  void didUpdateWidget(covariant PremiumSceneLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flavor != widget.flavor ||
        oldWidget.weatherCode != widget.weatherCode ||
        oldWidget.isDay != widget.isDay) {
      _reseedParticles();
    }
  }

  void _reseedParticles() {
    final random = Random(
      widget.flavor.index * 997 +
          widget.weatherCode * 37 +
          (widget.isDay ? 11 : 19),
    );
    final rainy = _isRainCode(widget.weatherCode);
    final snowy = _isSnowCode(widget.weatherCode);
    final storm = _isStormCode(widget.weatherCode);
    final allowParticles = !(rainy || snowy || storm);
    final count = _particleCountForWeather(widget.weatherCode);

    _particles = List.generate(count, (_) {
      final upward =
          widget.flavor == PremiumThemeFlavor.ocean &&
          random.nextDouble() > 0.55;

      return _SceneParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 0.8 + random.nextDouble() * (storm ? 2.2 : 1.8),
        speed: 0.14 + random.nextDouble() * (storm ? 0.7 : 0.45),
        drift: (random.nextDouble() - 0.5) * 0.07,
        phase: random.nextDouble() * pi * 2,
        tone: random.nextInt(3),
        sparkle: allowParticles && random.nextDouble() > 0.62,
        upward: allowParticles && upward,
      );
    });
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
          painter: _PremiumScenePainter(
            flavor: widget.flavor,
            weatherCode: widget.weatherCode,
            isDay: widget.isDay,
            tick: _controller.value,
            particles: _particles,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  static int _particleCountForWeather(int code) {
    if (_isStormCode(code) || _isRainCode(code) || _isSnowCode(code)) return 0;
    if (_isCloudCode(code) || _isFogCode(code)) return 16;
    return 20;
  }
}

class _PremiumScenePainter extends CustomPainter {
  final PremiumThemeFlavor flavor;
  final int weatherCode;
  final bool isDay;
  final double tick;
  final List<_SceneParticle> particles;

  _PremiumScenePainter({
    required this.flavor,
    required this.weatherCode,
    required this.isDay,
    required this.tick,
    required this.particles,
  });

  bool get _isStorm => _isStormCode(weatherCode);

  bool get _isRain => _isRainCode(weatherCode);

  bool get _isSnow => _isSnowCode(weatherCode);

  bool get _isCloud => _isCloudCode(weatherCode);

  bool get _isFog => _isFogCode(weatherCode);

  @override
  void paint(Canvas canvas, Size size) {
    final palette = _paletteFor(flavor, isDay);
    final weatherDrive = _weatherDrive();
    final isPrecipWeather = _isRain || _isSnow || _isStorm;

    if (isPrecipWeather) {
      _drawAuraOrbs(canvas, size, palette, weatherDrive * 0.55);
      _drawEdgeTreatments(canvas, size, palette, weatherDrive * 0.9);
      return;
    }

    _drawAuraOrbs(canvas, size, palette, weatherDrive);
    _drawFlavorAccent(canvas, size, palette, weatherDrive);
    if (particles.isNotEmpty) {
      _drawParticles(canvas, size, palette, weatherDrive);
    }
    _drawEdgeTreatments(canvas, size, palette, weatherDrive);
  }

  double _weatherDrive() {
    if (_isStorm) return 1.35;
    if (_isRain || _isSnow) return 1.12;
    if (_isCloud || _isFog) return 0.92;
    return 0.82;
  }

  void _drawAuraOrbs(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final phase = tick * 2 * pi;
    final baseAlpha =
        (_isStorm ? 0.22 : (_isRain || _isSnow ? 0.17 : 0.13)) * weatherDrive;

    for (var i = 0; i < 3; i++) {
      final xWave = sin(phase * (0.42 + i * 0.11) + i * 1.6);
      final yWave = cos(phase * (0.31 + i * 0.13) + i * 0.9);
      final center = Offset(
        size.width * (0.18 + i * 0.34) + xWave * size.width * 0.14,
        size.height * (0.14 + i * 0.15) + yWave * size.height * 0.08,
      );
      final radius = size.shortestSide * (0.38 + i * 0.08);
      final color = palette.aura[i % palette.aura.length];

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: baseAlpha),
            color.withValues(alpha: baseAlpha * 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawFlavorAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    switch (flavor) {
      case PremiumThemeFlavor.clean:
        _drawCleanAccent(canvas, size, palette, weatherDrive);
      case PremiumThemeFlavor.cyberpunk:
        _drawCyberAccent(canvas, size, palette, weatherDrive);
      case PremiumThemeFlavor.pastel:
        _drawPastelAccent(canvas, size, palette, weatherDrive);
      case PremiumThemeFlavor.sunset:
        _drawSunsetAccent(canvas, size, palette, weatherDrive);
      case PremiumThemeFlavor.ocean:
        _drawOceanAccent(canvas, size, palette, weatherDrive);
    }
  }

  void _drawCleanAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    if (isDay && !_isStorm) {
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.rim.withValues(alpha: 0.14 * weatherDrive),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      for (var i = 0; i < 3; i++) {
        final baseX =
            size.width * (0.16 + i * 0.31) +
            sin(tick * pi * 2 + i) * size.width * 0.04;
        final path = Path()
          ..moveTo(baseX, 0)
          ..lineTo(baseX + 36, 0)
          ..lineTo(baseX + 116, size.height)
          ..lineTo(baseX + 72, size.height)
          ..close();
        canvas.drawPath(path, beamPaint);
      }
      return;
    }

    final moonCenter = Offset(size.width * 0.82, size.height * 0.12);
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [palette.rim.withValues(alpha: 0.16), Colors.transparent],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 120));
    canvas.drawCircle(moonCenter, 120, moonPaint);
  }

  void _drawCyberAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final scanline = Paint()
      ..color = Colors.black.withValues(alpha: isDay ? 0.035 : 0.07);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), scanline);
    }

    final gridPaint = Paint()
      ..color = palette.rim.withValues(alpha: 0.05 * weatherDrive)
      ..strokeWidth = 0.65;

    for (double x = 0; x <= size.width; x += 48) {
      final wiggle = sin((tick * 2 * pi) + x * 0.01) * 1.8;
      canvas.drawLine(
        Offset(x + wiggle, 0),
        Offset(x - wiggle, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += 44) {
      final wiggle = cos((tick * 2 * pi) + y * 0.01) * 1.5;
      canvas.drawLine(
        Offset(0, y + wiggle),
        Offset(size.width, y - wiggle),
        gridPaint,
      );
    }
  }

  void _drawPastelAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.12 + i * 0.14);
      final path = Path()..moveTo(0, y);

      for (double x = 0; x <= size.width; x += 18) {
        final wave = sin((x / 80) + (tick * 2 * pi) + i) * 14;
        path.lineTo(x, y + wave);
      }

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            palette.aura[i % palette.aura.length].withValues(alpha: 0.06),
            palette.aura[(i + 1) % palette.aura.length].withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      canvas.drawPath(path, stroke);
    }

    if (!_isRain && !_isStorm) {
      final float = tick * pi * 2;
      final heartCenter = Offset(
        size.width * 0.84,
        size.height * 0.18 + sin(float) * 8,
      );
      final heart = Path()
        ..moveTo(heartCenter.dx, heartCenter.dy + 8)
        ..cubicTo(
          heartCenter.dx - 14,
          heartCenter.dy - 6,
          heartCenter.dx - 20,
          heartCenter.dy + 6,
          heartCenter.dx,
          heartCenter.dy + 18,
        )
        ..cubicTo(
          heartCenter.dx + 20,
          heartCenter.dy + 6,
          heartCenter.dx + 14,
          heartCenter.dy - 6,
          heartCenter.dx,
          heartCenter.dy + 8,
        );
      final heartPaint = Paint()
        ..color = palette.rim.withValues(alpha: 0.18 * weatherDrive)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(heart, heartPaint);
    }
  }

  void _drawSunsetAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final horizon = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          palette.rim.withValues(alpha: 0.18 * weatherDrive),
          palette.rim.withValues(alpha: 0.06 * weatherDrive),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, horizon);

    if (isDay) {
      final sunCenter = Offset(size.width * 0.78, size.height * 0.14);
      final sun = Paint()
        ..shader = RadialGradient(
          colors: [
            palette.aura.first.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 120));
      canvas.drawCircle(sunCenter, 120, sun);
    }
  }

  void _drawOceanAccent(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2
      ..color = palette.rim.withValues(alpha: 0.07 * weatherDrive)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.12 + i * 0.11);
      final phase = tick * 2 * pi * (0.7 + i * 0.08) + i;
      final path = Path()..moveTo(0, y);

      for (double x = 0; x <= size.width; x += 14) {
        final wave = sin((x / 70) + phase) * 8 + cos((x / 120) + phase) * 5;
        path.lineTo(x, y + wave);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawParticles(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final movement = (_isStorm ? 1.55 : 1.0) * weatherDrive;

    for (final particle in particles) {
      final phase = tick * 2 * pi + particle.phase;
      final lateral = sin(phase) * 0.015;
      final travel = tick * (0.42 + particle.speed * movement);

      final x = _wrap01(particle.x + lateral + particle.drift * 2.2);

      final y = particle.upward
          ? _wrap01(particle.y - travel * 0.34)
          : _wrap01(particle.y + travel * 0.36);

      final center = Offset(x * size.width, y * size.height);
      final pulse = 0.25 + 0.75 * (sin(phase).abs());
      final color = palette.particles[particle.tone % palette.particles.length]
          .withValues(alpha: 0.5 * pulse);

      final dot = Paint()..color = color;
      canvas.drawCircle(center, particle.size, dot);

      final glow = Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, particle.size * 2.1, glow);

      if (particle.sparkle && !_isRain) {
        final sparkle = Paint()
          ..color = color.withValues(alpha: 0.45)
          ..strokeWidth = 1;
        canvas.drawLine(
          center.translate(-particle.size * 2, 0),
          center.translate(particle.size * 2, 0),
          sparkle,
        );
        canvas.drawLine(
          center.translate(0, -particle.size * 2),
          center.translate(0, particle.size * 2),
          sparkle,
        );
      }
    }
  }

  void _drawEdgeTreatments(
    Canvas canvas,
    Size size,
    _FlavorPalette palette,
    double weatherDrive,
  ) {
    final topLift = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.08 * weatherDrive),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, topLift);

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          palette.shadow.withValues(alpha: isDay ? 0.25 : 0.42),
        ],
        stops: const [0.56, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _PremiumScenePainter oldDelegate) {
    return oldDelegate.tick != tick ||
        oldDelegate.weatherCode != weatherCode ||
        oldDelegate.isDay != isDay ||
        oldDelegate.flavor != flavor ||
        oldDelegate.particles != particles;
  }
}

class _SceneParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final double phase;
  final int tone;
  final bool sparkle;
  final bool upward;

  const _SceneParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.tone,
    required this.sparkle,
    required this.upward,
  });
}

class _FlavorPalette {
  final List<Color> aura;
  final List<Color> particles;
  final Color rim;
  final Color shadow;

  const _FlavorPalette({
    required this.aura,
    required this.particles,
    required this.rim,
    required this.shadow,
  });
}

_FlavorPalette _paletteFor(PremiumThemeFlavor flavor, bool isDay) {
  switch (flavor) {
    case PremiumThemeFlavor.clean:
      return _FlavorPalette(
        aura: isDay
            ? const [Color(0xFF7BC7FF), Color(0xFF6D9BFF), Color(0xFF8CE6FF)]
            : const [Color(0xFF5C79D4), Color(0xFF34487A), Color(0xFF8DB6FF)],
        particles: isDay
            ? const [Color(0xFFE9F8FF), Color(0xFFD5EEFF), Color(0xFFA8D8FF)]
            : const [Color(0xFFD3E2FF), Color(0xFF9CB9FF), Color(0xFF7EA3FF)],
        rim: isDay ? const Color(0xFFB9E5FF) : const Color(0xFF88A8FF),
        shadow: const Color(0xFF040A14),
      );
    case PremiumThemeFlavor.cyberpunk:
      return _FlavorPalette(
        aura: const [Color(0xFF00F0FF), Color(0xFFFF2E97), Color(0xFF00A8FF)],
        particles: const [
          Color(0xFF8DFBFF),
          Color(0xFFFF8EC4),
          Color(0xFF8EA8FF),
        ],
        rim: const Color(0xFF00F0FF),
        shadow: const Color(0xFF03050C),
      );
    case PremiumThemeFlavor.pastel:
      return _FlavorPalette(
        aura: isDay
            ? const [Color(0xFFFFCCE3), Color(0xFFCDBBFF), Color(0xFFBEEEDB)]
            : const [Color(0xFFCBB8F0), Color(0xFFFFB7D5), Color(0xFFA0D2F0)],
        particles: isDay
            ? const [Color(0xFFFFF8FF), Color(0xFFEADFFF), Color(0xFFFDE3EE)]
            : const [Color(0xFFF3ECFF), Color(0xFFD7C6FF), Color(0xFFFFD4E8)],
        rim: isDay ? const Color(0xFFFFC1DD) : const Color(0xFFCBB8F0),
        shadow: const Color(0xFF120D1A),
      );
    case PremiumThemeFlavor.sunset:
      return _FlavorPalette(
        aura: const [Color(0xFFFFAA6C), Color(0xFFFF7A8C), Color(0xFFFFD27A)],
        particles: const [
          Color(0xFFFFF1D9),
          Color(0xFFFFD1A6),
          Color(0xFFFFC4BA),
        ],
        rim: const Color(0xFFFFAF66),
        shadow: const Color(0xFF140A0F),
      );
    case PremiumThemeFlavor.ocean:
      return _FlavorPalette(
        aura: const [Color(0xFF37C9FF), Color(0xFF00CFAF), Color(0xFF65EFFF)],
        particles: const [
          Color(0xFFCCFAFF),
          Color(0xFF99F0FF),
          Color(0xFF72E1E6),
        ],
        rim: const Color(0xFF5EE8FF),
        shadow: const Color(0xFF030D14),
      );
  }
}

bool _isRainCode(int code) {
  return (code >= 51 && code <= 67) || (code >= 80 && code <= 82);
}

bool _isSnowCode(int code) {
  return (code >= 71 && code <= 77) || (code >= 85 && code <= 86);
}

bool _isStormCode(int code) {
  return code >= 95 && code <= 99;
}

bool _isCloudCode(int code) {
  return code == 2 || code == 3;
}

bool _isFogCode(int code) {
  return code == 45 || code == 48;
}

double _wrap01(double value) {
  final wrapped = value % 1.0;
  return wrapped < 0 ? wrapped + 1.0 : wrapped;
}
