import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/pastel_theme.dart';

/// Pastel/Kawaii splash screen — cute bouncing cloud with soft gradient,
/// floating shapes, sparkles, and gentle animations
class PastelSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PastelSplashScreen({super.key, required this.onComplete});

  @override
  State<PastelSplashScreen> createState() => _PastelSplashScreenState();
}

class _PastelSplashScreenState extends State<PastelSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late AnimationController _heartController;
  late Animation<double> _bounceAnimation;
  late List<_FloatingShape> _shapes;
  late List<_Sparkle> _sparkles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -10, end: 10).animate(
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

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shapes = List.generate(
      12,
      (_) => _FloatingShape(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 8 + _random.nextDouble() * 24,
        speed: 0.2 + _random.nextDouble() * 0.6,
        color: [
          PastelTheme.lavender,
          PastelTheme.babyPink,
          PastelTheme.mint,
          PastelTheme.peach,
          const Color(0xFFFFE4E1), // misty rose
          const Color(0xFFE0BBE4), // thistle
        ][_random.nextInt(6)],
        type: _random.nextInt(3), // 0=circle, 1=heart, 2=star
      ),
    );

    _sparkles = List.generate(
      20,
      (_) => _Sparkle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 4,
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
    _bounceController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    _sparkleController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD4ECFF),
              Color(0xFFF0E6FF),
              Color(0xFFFFF0F5),
              Color(0xFFE8F5E9),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating shapes
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FloatingShapesPainter(
                      _shapes,
                      _bounceController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Sparkles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SparklePainter(
                      _sparkles,
                      _sparkleController.value,
                    ),
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
                    // Bouncing cloud with halo
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
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  PastelTheme.lavender.withValues(alpha: 0.15),
                                  PastelTheme.lavender.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Cloud container
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: PastelTheme.lavender.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: PastelTheme.babyPink.withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cloud_rounded,
                              size: 64,
                              color: PastelTheme.lavender,
                            ),
                          ),
                          // Floating heart near cloud
                          Positioned(
                            right: 2,
                            top: 8,
                            child: AnimatedBuilder(
                              animation: _heartController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, -_heartController.value * 6),
                                  child: Opacity(
                                    opacity: 0.4 + _heartController.value * 0.4,
                                    child: child,
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.favorite,
                                size: 16,
                                color: PastelTheme.babyPink,
                              ),
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
                        color: Color(0xFF4A3D6B),
                        letterSpacing: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'cute weather, cute day ~',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A6B9E),
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Soft progress bar with rounded ends and gradient
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          width: 140,
                          height: 8,
                          decoration: BoxDecoration(
                            color: PastelTheme.lavender.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      PastelTheme.lavender,
                                      PastelTheme.babyPink,
                                      PastelTheme.mint,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PastelTheme.lavender.withValues(alpha: 0.4),
                                      blurRadius: 6,
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

class _FloatingShape {
  final double x, y, size, speed;
  final Color color;
  final int type; // 0=circle, 1=heart, 2=star
  _FloatingShape({
    required this.x, required this.y, required this.size,
    required this.speed, required this.color, required this.type,
  });
}

class _Sparkle {
  final double x, y, size, phase;
  _Sparkle({required this.x, required this.y, required this.size, required this.phase});
}

class _FloatingShapesPainter extends CustomPainter {
  final List<_FloatingShape> shapes;
  final double animValue;
  _FloatingShapesPainter(this.shapes, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in shapes) {
      final drift = sin(animValue * pi * 2 + s.speed * 5) * 12;
      final cx = s.x * size.width + drift;
      final cy = s.y * size.height + cos(animValue * pi * 2 + s.speed * 3) * 10;
      final paint = Paint()
        ..color = s.color.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      if (s.type == 0) {
        // Circle
        canvas.drawCircle(Offset(cx, cy), s.size, paint);
      } else if (s.type == 1) {
        // Simple heart shape (using two circles + triangle)
        final r = s.size * 0.5;
        canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.2), r, paint);
        canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.2), r, paint);
        final path = Path()
          ..moveTo(cx - r * 1.1, cy)
          ..lineTo(cx, cy + r * 1.4)
          ..lineTo(cx + r * 1.1, cy)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        // Star shape (diamond)
        final path = Path()
          ..moveTo(cx, cy - s.size)
          ..lineTo(cx + s.size * 0.4, cy)
          ..lineTo(cx, cy + s.size)
          ..lineTo(cx - s.size * 0.4, cy)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double animValue;
  _SparklePainter(this.sparkles, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final twinkle = (sin(animValue * pi * 2 + s.phase) + 1) / 2;
      if (twinkle < 0.3) continue; // hide when dim
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: twinkle * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final cx = s.x * size.width;
      final cy = s.y * size.height;
      // Draw a tiny cross sparkle
      final r = s.size * twinkle;
      canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint..strokeWidth = 1.5);
      canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
