import 'dart:math';
import 'package:flutter/material.dart';

/// Pastel Dark splash screen — dreamy night aesthetic with muted pastels
class PastelDarkSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PastelDarkSplashScreen({super.key, required this.onComplete});

  @override
  State<PastelDarkSplashScreen> createState() => _PastelDarkSplashScreenState();
}

class _PastelDarkSplashScreenState extends State<PastelDarkSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _starController;
  late Animation<double> _bounceAnimation;
  late List<_DreamyStar> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _stars = List.generate(
      25,
      (_) => _DreamyStar(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.7,
        size: 1 + _random.nextDouble() * 2,
        phase: _random.nextDouble() * 2 * pi,
        color: [
          const Color(0xFFCBB8F0), // lavender
          const Color(0xFFFFB7D5), // pink
          const Color(0xFFA0D2F0), // blue
          Colors.white,
        ][_random.nextInt(4)],
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
    _bounceController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    _starController.dispose();
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
              Color(0xFF100C18), // Deep dark
              Color(0xFF1A1525), // Purple-black
              Color(0xFF2A2040), // Dark purple
              Color(0xFF3A2D55), // Muted purple
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dreamy stars
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _DreamyStarPainter(_stars, _starController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Soft aurora effect
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300,
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _AuroraPainter(_bounceController.value),
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
                    // Bouncing moon/cloud with halo
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft halo glow
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(
                                    0xFFCBB8F0,
                                  ).withValues(alpha: 0.12),
                                  const Color(
                                    0xFFCBB8F0,
                                  ).withValues(alpha: 0.05),
                                  const Color(
                                    0xFFCBB8F0,
                                  ).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Cloud container
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2A2235,
                              ).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFF4A3D65,
                                ).withValues(alpha: 0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFCBB8F0,
                                  ).withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.nights_stay_rounded,
                              size: 64,
                              color: Color(0xFFCBB8F0),
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0EAF8),
                        letterSpacing: 1,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(color: Color(0x40CBB8F0), blurRadius: 12),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'dreamy nights await ~',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFBBAADD).withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Soft progress bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          width: 140,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A3D65,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFCBB8F0),
                                      Color(0xFFFFB7D5),
                                      Color(0xFFA0D2F0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFCBB8F0,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
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

class _DreamyStar {
  final double x, y, size, phase;
  final Color color;
  _DreamyStar({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.color,
  });
}

class _DreamyStarPainter extends CustomPainter {
  final List<_DreamyStar> stars;
  final double animValue;
  _DreamyStarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (sin(animValue * 2 * pi + star.phase) + 1) / 2;
      final alpha = 0.2 + twinkle * 0.6;
      final paint = Paint()..color = star.color.withValues(alpha: alpha);
      final center = Offset(star.x * size.width, star.y * size.height);

      canvas.drawCircle(center, star.size * (0.8 + twinkle * 0.4), paint);

      // Soft glow
      final glow = Paint()
        ..color = star.color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, star.size * 2, glow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AuroraPainter extends CustomPainter {
  final double animValue;
  _AuroraPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final wave = sin(animValue * pi) * 20;

    // Draw soft aurora bands
    _drawAuroraBand(canvas, size, const Color(0xFFCBB8F0), 0.06, wave, 0);
    _drawAuroraBand(
      canvas,
      size,
      const Color(0xFFFFB7D5),
      0.04,
      -wave * 0.7,
      50,
    );
    _drawAuroraBand(
      canvas,
      size,
      const Color(0xFFA0D2F0),
      0.03,
      wave * 0.5,
      100,
    );
  }

  void _drawAuroraBand(
    Canvas canvas,
    Size size,
    Color color,
    double alpha,
    double wave,
    double yOffset,
  ) {
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 4) {
      final y =
          yOffset +
          sin((x / size.width) * pi * 2 + wave * 0.05) * 30 +
          sin((x / size.width) * pi * 4) * 15;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
