import 'package:flutter/material.dart';

/// Clean/minimal splash screen — simple fade-in with app logo
class CleanSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CleanSplashScreen({super.key, required this.onComplete});

  @override
  State<CleanSplashScreen> createState() => _CleanSplashScreenState();
}

class _CleanSplashScreenState extends State<CleanSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
            colors: [Color(0xFF4A90D9), Color(0xFF87CEEB), Color(0xFFB0E0E6)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40000000), blurRadius: 20),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SappyWeather',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2,
                    decoration: TextDecoration.none,
                    shadows: [Shadow(color: Color(0x40000000), blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your weather companion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    decoration: TextDecoration.none,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
