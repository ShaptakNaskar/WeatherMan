import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/widgets/cyberpunk/glitch_effects.dart';

/// Cyberpunk-styled dynamic background with neon weather overlays
class CyberpunkBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final Widget child;

  const CyberpunkBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = CyberpunkTheme.getWeatherGradient(weatherCode, isDay);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // Grid pattern overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _CyberGridPainter(opacity: 0.03),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          // Weather particle overlay (cyberpunk style)
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _buildWeatherOverlay(context),
                ),
              ),
            ),
          ),
          // Scanlines
          const Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ScanlineOverlay(opacity: 0.03),
                ),
              ),
            ),
          ),
          // Digital noise
          const Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: DigitalNoiseOverlay(intensity: 0.02),
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
    // Neon rain
    if (_isRainy) {
      return CyberRainOverlay(intensity: _getRainIntensity());
    }
    // Neon snow/data particles
    if (_isSnowy) {
      return CyberSnowOverlay(intensity: _getSnowIntensity());
    }
    // Electric storm
    if (_isThunderstorm) {
      return const CyberStormOverlay();
    }
    // Neon stars / data nodes
    if (!isDay && _isClear) {
      return const CyberStarOverlay();
    }
    // Clear day — subtle floating data motes
    if (isDay && _isClear) {
      return const CyberDataMoteOverlay();
    }
    // Digital clouds
    if (_isCloudy) {
      return const CyberCloudOverlay();
    }
    // Data fog
    if (_isFog) {
      return const CyberFogOverlay();
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

/// Cyberpunk grid pattern painter
class _CyberGridPainter extends CustomPainter {
  final double opacity;
  _CyberGridPainter({this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Neon cyan rain drops
class CyberRainOverlay extends StatefulWidget {
  final double intensity;
  const CyberRainOverlay({super.key, this.intensity = 0.5});

  @override
  State<CyberRainOverlay> createState() => _CyberRainOverlayState();
}

class _CyberRainOverlayState extends State<CyberRainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CyberDrop> _drops;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _generateDrops();
  }

  void _generateDrops() {
    final count = (12 + (20 * widget.intensity)).round();
    _drops = List.generate(count, (_) => _CyberDrop(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.4 + widget.intensity * 0.6 + _random.nextDouble() * 0.2,
      length: 20 + widget.intensity * 20 + _random.nextDouble() * 10,
      isCyan: _random.nextDouble() > 0.3,
    ));
  }

  @override
  void didUpdateWidget(CyberRainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) _generateDrops();
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
          painter: _CyberRainPainter(_drops, _controller.value, widget.intensity),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberDrop {
  final double x;
  double y;
  final double speed;
  final double length;
  final bool isCyan;

  _CyberDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.isCyan,
  });
}

class _CyberRainPainter extends CustomPainter {
  final List<_CyberDrop> drops;
  final double animValue;
  final double intensity;

  _CyberRainPainter(this.drops, this.animValue, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    for (final drop in drops) {
      final y = ((drop.y + animValue * drop.speed * 2) % 1.2 - 0.1) * size.height;
      final x = drop.x * size.width;
      final color = drop.isCyan 
          ? CyberpunkTheme.neonCyan.withValues(alpha: 0.4 + intensity * 0.2)
          : CyberpunkTheme.neonMagenta.withValues(alpha: 0.2 + intensity * 0.1);

      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y), Offset(x + 0.5, y + drop.length), paint);

      // Neon glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(Offset(x, y), Offset(x + 0.5, y + drop.length), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberRainPainter oldDelegate) => true;
}

/// Cyberpunk snow — glowing data particles
class CyberSnowOverlay extends StatefulWidget {
  final double intensity;
  const CyberSnowOverlay({super.key, this.intensity = 0.5});

  @override
  State<CyberSnowOverlay> createState() => _CyberSnowOverlayState();
}

class _CyberSnowOverlayState extends State<CyberSnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CyberFlake> _flakes;
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
    final count = (15 + (25 * widget.intensity)).round();
    _flakes = List.generate(count, (_) => _CyberFlake(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.08 + widget.intensity * 0.12 + _random.nextDouble() * 0.08,
      size: 2 + widget.intensity * 3 + _random.nextDouble() * 3,
      isHex: _random.nextDouble() > 0.5,
    ));
  }

  @override
  void didUpdateWidget(CyberSnowOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) _generateFlakes();
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
          painter: _CyberSnowPainter(_flakes, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberFlake {
  final double x;
  double y;
  final double speed;
  final double size;
  final bool isHex;

  _CyberFlake({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.isHex,
  });
}

class _CyberSnowPainter extends CustomPainter {
  final List<_CyberFlake> flakes;
  final double animValue;

  _CyberSnowPainter(this.flakes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final flake in flakes) {
      final y = ((flake.y + animValue * flake.speed) % 1.1 - 0.05) * size.height;
      final drift = sin(animValue * 2 * pi + flake.x * 10) * 12;
      final x = ((flake.x * size.width + drift) % size.width);

      final color = flake.isHex ? CyberpunkTheme.neonCyan : CyberpunkTheme.neonMagenta;

      // Glowing particle
      final paint = Paint()..color = color.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(x, y), flake.size / 2, paint);

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), flake.size, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberSnowPainter oldDelegate) => true;
}

/// Cyberpunk thunderstorm — electric lightning + neon rain
class CyberStormOverlay extends StatefulWidget {
  const CyberStormOverlay({super.key});

  @override
  State<CyberStormOverlay> createState() => _CyberStormOverlayState();
}

class _CyberStormOverlayState extends State<CyberStormOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _lightningController;
  late List<_CyberDrop> _drops;
  final Random _random = Random();
  double _lightningOpacity = 0.0;
  Offset _lightningCenter = const Offset(0.5, 0.15);
  Color _lightningColor = CyberpunkTheme.neonCyan;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat();

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _lightningController.addListener(() {
      if (mounted) {
        setState(() {
          _lightningOpacity = _lightningOpacity * (1.0 - _lightningController.value);
        });
      }
    });

    _drops = List.generate(25, (_) => _CyberDrop(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.8 + _random.nextDouble() * 0.4,
      length: 25 + _random.nextDouble() * 15,
      isCyan: _random.nextDouble() > 0.3,
    ));

    _scheduleLightning();
  }

  void _scheduleLightning() {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(5000)), () {
      if (!mounted) return;
      _flashLightning();
      _scheduleLightning();
    });
  }

  void _flashLightning() {
    _lightningCenter = Offset(
      0.2 + _random.nextDouble() * 0.6,
      0.05 + _random.nextDouble() * 0.2,
    );
    _lightningColor = _random.nextBool() ? CyberpunkTheme.neonCyan : CyberpunkTheme.neonMagenta;
    _lightningOpacity = 0.2 + _random.nextDouble() * 0.15;
    _lightningController.forward(from: 0).then((_) {
      if (mounted && _random.nextInt(3) == 0) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _lightningOpacity = 0.1 + _random.nextDouble() * 0.08;
            _lightningController.forward(from: 0);
          }
        });
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
        // Neon lightning glow
        if (_lightningOpacity > 0.001)
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberLightningPainter(
                center: _lightningCenter,
                opacity: _lightningOpacity,
                color: _lightningColor,
              ),
            ),
          ),
        // Neon rain
        AnimatedBuilder(
          animation: _rainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _CyberRainPainter(_drops, _rainController.value, 1.0),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class _CyberLightningPainter extends CustomPainter {
  final Offset center;
  final double opacity;
  final Color color;

  _CyberLightningPainter({
    required this.center,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(center.dx * 2 - 1, center.dy * 2 - 1),
        radius: 0.8,
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CyberLightningPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.center != center;
  }
}

/// Cyberpunk stars — neon data nodes in the night sky
class CyberStarOverlay extends StatefulWidget {
  const CyberStarOverlay({super.key});

  @override
  State<CyberStarOverlay> createState() => _CyberStarOverlayState();
}

class _CyberStarOverlayState extends State<CyberStarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CyberStar> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _stars = List.generate(35, (_) => _CyberStar(
      x: _random.nextDouble(),
      y: _random.nextDouble() * 0.6,
      phase: _random.nextDouble(),
      size: 1 + _random.nextDouble() * 2,
      isCyan: _random.nextDouble() > 0.3,
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
          painter: _CyberStarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberStar {
  final double x;
  final double y;
  final double phase;
  final double size;
  final bool isCyan;

  _CyberStar({
    required this.x,
    required this.y,
    required this.phase,
    required this.size,
    required this.isCyan,
  });
}

class _CyberStarPainter extends CustomPainter {
  final List<_CyberStar> stars;
  final double animValue;

  _CyberStarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = 0.3 + 0.7 * sin((animValue + star.phase) * pi).abs();
      final color = star.isCyan ? CyberpunkTheme.neonCyan : CyberpunkTheme.neonMagenta;

      final paint = Paint()..color = color.withValues(alpha: twinkle * 0.8);
      final center = Offset(star.x * size.width, star.y * size.height);

      canvas.drawCircle(center, star.size, paint);

      // Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: twinkle * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, star.size * 2, glowPaint);

      // Connection lines between nearby stars (circuit board effect)
      for (final other in stars) {
        if (other == star) continue;
        final otherCenter = Offset(other.x * size.width, other.y * size.height);
        final dist = (center - otherCenter).distance;
        if (dist < 80) {
          final linePaint = Paint()
            ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.05 * (1 - dist / 80))
            ..strokeWidth = 0.5;
          canvas.drawLine(center, otherCenter, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CyberStarPainter oldDelegate) => true;
}

/// Cyberpunk cloud overlay — drifting digital glitch clouds
class CyberCloudOverlay extends StatefulWidget {
  const CyberCloudOverlay({super.key});

  @override
  State<CyberCloudOverlay> createState() => _CyberCloudOverlayState();
}

class _CyberCloudOverlayState extends State<CyberCloudOverlay>
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
          painter: _CyberCloudPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberCloudPainter extends CustomPainter {
  final double animValue;
  _CyberCloudPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final drift = sin(animValue * 2 * pi) * 20;
    final drift2 = cos(animValue * 2 * pi) * 15;

    final paint = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.2 + drift, size.height * 0.12),
          width: 180,
          height: 40,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    final paint2 = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.7 + drift2, size.height * 0.08),
          width: 150,
          height: 30,
        ),
        const Radius.circular(4),
      ),
      paint2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5 - drift * 0.7, size.height * 0.22),
          width: 220,
          height: 50,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Lower cloud band
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.35 + drift2 * 0.5, size.height * 0.35),
          width: 160,
          height: 35,
        ),
        const Radius.circular(4),
      ),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant _CyberCloudPainter oldDelegate) => true;
}

/// Subtle floating data motes for clear sky daytime
class CyberDataMoteOverlay extends StatefulWidget {
  const CyberDataMoteOverlay({super.key});

  @override
  State<CyberDataMoteOverlay> createState() => _CyberDataMoteOverlayState();
}

class _CyberDataMoteOverlayState extends State<CyberDataMoteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DataMote> _motes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _motes = List.generate(15, (_) => _DataMote(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      phase: _random.nextDouble(),
      speed: 0.3 + _random.nextDouble() * 0.5,
      size: 1.0 + _random.nextDouble() * 1.5,
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
          painter: _DataMotePainter(_motes, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _DataMote {
  final double x, y, phase, speed, size;
  _DataMote({
    required this.x, required this.y, required this.phase,
    required this.speed, required this.size,
  });
}

class _DataMotePainter extends CustomPainter {
  final List<_DataMote> motes;
  final double animValue;

  _DataMotePainter(this.motes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final mote in motes) {
      final drift = sin((animValue * mote.speed + mote.phase) * 2 * pi);
      final alpha = 0.15 + 0.15 * drift.abs();

      final cx = mote.x * size.width + drift * 8;
      final cy = (mote.y + animValue * mote.speed * 0.05) % 1.0 * size.height;
      final center = Offset(cx, cy);

      final paint = Paint()..color = CyberpunkTheme.neonCyan.withValues(alpha: alpha);
      canvas.drawCircle(center, mote.size, paint);

      final glowPaint = Paint()
        ..color = CyberpunkTheme.neonCyan.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, mote.size * 2.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DataMotePainter oldDelegate) => true;
}

/// Cyberpunk fog — horizontal data stream bands
class CyberFogOverlay extends StatefulWidget {
  const CyberFogOverlay({super.key});

  @override
  State<CyberFogOverlay> createState() => _CyberFogOverlayState();
}

class _CyberFogOverlayState extends State<CyberFogOverlay>
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
          painter: _CyberFogPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberFogPainter extends CustomPainter {
  final double animValue;
  _CyberFogPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Moving horizontal bands of neon fog
    final bands = [
      _FogBand(0.3, 0.12, CyberpunkTheme.neonCyan, 0.06, 0.3),
      _FogBand(0.5, 0.18, CyberpunkTheme.neonMagenta, 0.04, -0.2),
      _FogBand(0.75, 0.15, CyberpunkTheme.neonCyan, 0.05, 0.15),
    ];

    for (final band in bands) {
      final xOffset = sin(animValue * 2 * pi + band.speed) * 30;
      final paint = Paint()
        ..color = band.color.withValues(alpha: band.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawRect(
        Rect.fromLTWH(
          -20 + xOffset,
          band.yCenter * size.height - band.height * size.height / 2,
          size.width + 40,
          band.height * size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CyberFogPainter oldDelegate) => true;
}

class _FogBand {
  final double yCenter;
  final double height;
  final Color color;
  final double opacity;
  final double speed;

  _FogBand(this.yCenter, this.height, this.color, this.opacity, this.speed);
}
