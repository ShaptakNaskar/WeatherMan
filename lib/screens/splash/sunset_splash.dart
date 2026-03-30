import 'dart:math';
import 'package:flutter/material.dart';

/// Sunset themed splash screen — warm amber/coral tones with sun rays
class SunsetSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SunsetSplashScreen({super.key, required this.onComplete});

  @override
  State<SunsetSplashScreen> createState() => _SunsetSplashScreenState();
}

class _SunsetSplashScreenState extends State<SunsetSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _sunController;
  late AnimationController _raysController;
  late AnimationController _progressController;
  late List<_SunRay> _rays;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _rays = List.generate(
      8,
      (i) => _SunRay(
        angle: (i / 8) * 2 * pi,
        length: 120 + _random.nextDouble() * 60,
        width: 2 + _random.nextDouble() * 2,
        opacity: 0.1 + _random.nextDouble() * 0.15,
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
    _sunController.dispose();
    _raysController.dispose();
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
              Color(0xFF1A1520), // Deep purple-black sky
              Color(0xFF2D1F35), // Dark purple
              Color(0xFF4A2848), // Purple-magenta
              Color(0xFF8B4557), // Dusty rose
              Color(0xFFD4756A), // Coral
              Color(0xFFE8A87C), // Soft amber
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Sun rays
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _raysController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SunRaysPainter(
                      _rays,
                      _raysController.value,
                      MediaQuery.of(context).size,
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
                    // Sun/logo with glow
                    AnimatedBuilder(
                      animation: _sunController,
                      builder: (context, child) {
                        final pulse = 0.95 + _sunController.value * 0.1;
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
                                    0xFFFFB366,
                                  ).withValues(alpha: 0.25),
                                  const Color(
                                    0xFFFF8C66,
                                  ).withValues(alpha: 0.1),
                                  const Color(
                                    0xFFFF8C66,
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
                                    0xFFFFB366,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 30,
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
                        color: Color(0xFFFFF5EB),
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(color: Color(0x60000000), blurRadius: 10),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Golden hour awaits',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFFFE4C9).withValues(alpha: 0.8),
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
                              0xFFFFB366,
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
                                      Color(0xFFFFB366),
                                      Color(0xFFFF8C66),
                                      Color(0xFFE8A87C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFB366,
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

class _SunRay {
  final double angle, length, width, opacity;
  _SunRay({
    required this.angle,
    required this.length,
    required this.width,
    required this.opacity,
  });
}

class _SunRaysPainter extends CustomPainter {
  final List<_SunRay> rays;
  final double animValue;
  final Size screenSize;
  _SunRaysPainter(this.rays, this.animValue, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final rotation = animValue * 2 * pi * 0.1; // Slow rotation

    for (final ray in rays) {
      final angle = ray.angle + rotation;
      final endX = center.dx + cos(angle) * ray.length;
      final endY = center.dy + sin(angle) * ray.length;

      final paint = Paint()
        ..color = const Color(0xFFFFB366).withValues(alpha: ray.opacity)
        ..strokeWidth = ray.width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
