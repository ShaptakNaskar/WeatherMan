import 'dart:math';
import 'package:flutter/material.dart';

/// Ocean themed splash screen — deep sea blues with wave animations
class OceanSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OceanSplashScreen({super.key, required this.onComplete});

  @override
  State<OceanSplashScreen> createState() => _OceanSplashScreenState();
}

class _OceanSplashScreenState extends State<OceanSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late AnimationController _progressController;
  late List<_Bubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _bubbles = List.generate(
      15,
      (_) => _Bubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 3 + _random.nextDouble() * 8,
        speed: 0.05 + _random.nextDouble() * 0.1,
        phase: _random.nextDouble() * 2 * pi,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _fadeController.forward();
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    _bubbleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628), // Deep ocean black-blue
              Color(0xFF0D2137), // Dark navy
              Color(0xFF134B6B), // Deep teal
              Color(0xFF1A6B8A), // Ocean blue
              Color(0xFF2593B0), // Bright sea
              Color(0xFF4AC4DB), // Light aqua
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Bubbles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bubbleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BubblePainter(_bubbles, _bubbleController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Wave overlays
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WavePainter(_waveController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with water glow
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final pulse =
                            0.97 + sin(_waveController.value * 2 * pi) * 0.03;
                        return Transform.scale(scale: pulse, child: child);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(
                                    0xFF4AC4DB,
                                  ).withValues(alpha: 0.2),
                                  const Color(
                                    0xFF2593B0,
                                  ).withValues(alpha: 0.1),
                                  const Color(
                                    0xFF2593B0,
                                  ).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Logo container
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4AC4DB,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    const Text(
                      'SappyWeather',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8F8FF),
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(color: Color(0x60000000), blurRadius: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Dive into the forecast',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFB8E8F5).withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          width: 140,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4AC4DB,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2593B0),
                                      Color(0xFF4AC4DB),
                                      Color(0xFF7FDCE8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4AC4DB,
                                      ).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  final double x, y, size, speed, phase;
  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double animValue;
  _BubblePainter(this.bubbles, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      // Bubbles rise from bottom
      final y = ((1 - b.y - animValue * b.speed * 3) % 1.2) * size.height;
      final wobble = sin(animValue * 2 * pi * 2 + b.phase) * 5;
      final x = b.x * size.width + wobble;

      final paint = Paint()
        ..color = const Color(0xFF4AC4DB).withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(Offset(x, y), b.size, paint);

      // Inner highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2);
      canvas.drawCircle(
        Offset(x - b.size * 0.3, y - b.size * 0.3),
        b.size * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WavePainter extends CustomPainter {
  final double animValue;
  _WavePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple wave layers
    _drawWave(canvas, size, 0.3, const Color(0xFF4AC4DB), 0.08, 0);
    _drawWave(canvas, size, 0.5, const Color(0xFF2593B0), 0.06, pi / 3);
    _drawWave(canvas, size, 0.7, const Color(0xFF1A6B8A), 0.04, pi / 1.5);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double heightFactor,
    Color color,
    double alpha,
    double phaseOffset,
  ) {
    final path = Path();
    final waveHeight = size.height * heightFactor;
    final phase = animValue * 2 * pi + phaseOffset;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 2) {
      final y =
          waveHeight +
          sin((x / size.width) * 4 * pi + phase) * 15 +
          sin((x / size.width) * 2 * pi + phase * 0.5) * 10;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
