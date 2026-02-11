import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Cyberpunk boot sequence splash screen
/// Shows a terminal-style initialization sequence before the main app
class CyberpunkSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CyberpunkSplashScreen({super.key, required this.onComplete});

  @override
  State<CyberpunkSplashScreen> createState() => _CyberpunkSplashScreenState();
}

class _CyberpunkSplashScreenState extends State<CyberpunkSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scanController;
  late AnimationController _glitchController;
  final List<_BootLine> _bootLines = [];
  bool _showLogo = false;
  bool _bootComplete = false;
  final Random _random = Random();

  static const _bootSequence = [
    _BootEntry('> INITIALIZING NEURAL INTERFACE...', 300),
    _BootEntry('> LOADING ATMOSPHERIC SENSORS... [OK]', 250),
    _BootEntry('> CALIBRATING WEATHER MATRIX...', 200),
    _BootEntry('> SYNCING SATELLITE UPLINK... [OK]', 250),
    _BootEntry('> COMPILING FORECAST ALGORITHMS...', 200),
    _BootEntry('> ESTABLISHING DATA STREAM... [OK]', 200),
    _BootEntry('> CYBERWARE CHECK: ALL SYSTEMS NOMINAL', 300),
    _BootEntry('', 400), // pause before logo
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _startBootSequence();
  }

  Future<void> _startBootSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));

    for (int i = 0; i < _bootSequence.length; i++) {
      if (!mounted) return;
      final entry = _bootSequence[i];
      if (entry.text.isNotEmpty) {
        setState(() {
          _bootLines.add(_BootLine(entry.text, CyberpunkTheme.neonCyan));
        });
      }
      await Future.delayed(Duration(milliseconds: entry.delayMs));

      // Random glitch on some lines
      if (_random.nextDouble() < 0.3 && mounted) {
        _glitchController.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }

    if (!mounted) return;

    // Show logo
    setState(() => _showLogo = true);
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Boot complete
    setState(() {
      _bootLines.add(_BootLine('> W3ATHER.exe ONLINE', CyberpunkTheme.neonGreen));
      _bootComplete = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scanController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkTheme.bgDarkest,
      body: Stack(
        children: [
          // Scanline
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SplashScanPainter(_scanController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // Grid lines
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(),
                size: Size.infinite,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '// SYSTEM BOOT //',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: CyberpunkTheme.neonCyan.withValues(alpha: 0.5),
                      letterSpacing: 3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 1,
                    color: CyberpunkTheme.neonCyan.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),

                  // Boot log lines
                  ..._bootLines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: AnimatedBuilder(
                      animation: _glitchController,
                      builder: (context, child) {
                        final glitchOffset = _glitchController.isAnimating
                            ? (_random.nextDouble() - 0.5) * 3
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(glitchOffset, 0),
                          child: child,
                        );
                      },
                      child: Text(
                        line.text,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: line.color,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: line.color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),

                  // Cursor blink
                  if (!_bootComplete)
                    _BlinkingCursor(color: CyberpunkTheme.neonCyan),

                  const Spacer(),

                  // Center logo area
                  if (_showLogo)
                    FadeTransition(
                      opacity: _fadeController,
                      child: Center(
                        child: Column(
                          children: [
                            // App name
                            Text(
                              'W3ATHER.exe',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: CyberpunkTheme.neonCyan,
                                letterSpacing: 4,
                                decoration: TextDecoration.none,
                                shadows: CyberpunkTheme.neonCyanGlow,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ATMOSPHERIC INTELLIGENCE NETWORK',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: CyberpunkTheme.textTertiary,
                                letterSpacing: 3,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Loading bar
                            _CyberLoadingBar(isComplete: _bootComplete),
                          ],
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Bottom info
                  Center(
                    child: Text(
                      'v1.0.7_CYBER',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        color: CyberpunkTheme.textTertiary,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootEntry {
  final String text;
  final int delayMs;
  const _BootEntry(this.text, this.delayMs);
}

class _BootLine {
  final String text;
  final Color color;
  _BootLine(this.text, this.color);
}

/// Blinking terminal cursor
class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
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
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 8,
            height: 14,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Cyberpunk-style loading bar with neon glow
class _CyberLoadingBar extends StatefulWidget {
  final bool isComplete;
  const _CyberLoadingBar({required this.isComplete});

  @override
  State<_CyberLoadingBar> createState() => _CyberLoadingBarState();
}

class _CyberLoadingBarState extends State<_CyberLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isComplete
        ? CyberpunkTheme.neonGreen
        : CyberpunkTheme.neonCyan;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 200,
              height: 3,
              decoration: BoxDecoration(
                color: CyberpunkTheme.bgMid,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widget.isComplete ? 1.0 : _controller.value * 0.85,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isComplete
                  ? '[ READY ]'
                  : '[ ${(_controller.value * 85).toInt()}% ]',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                color: color.withValues(alpha: 0.7),
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Subtle moving scanline for splash
class _SplashScanPainter extends CustomPainter {
  final double value;
  _SplashScanPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final bandY = value * size.height * 1.2 - size.height * 0.1;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          CyberpunkTheme.neonCyan.withValues(alpha: 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, bandY, size.width, 80));
    canvas.drawRect(Rect.fromLTWH(0, bandY, size.width, 80), paint);
  }

  @override
  bool shouldRepaint(covariant _SplashScanPainter oldDelegate) => true;
}

/// Subtle background grid
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberpunkTheme.neonCyan.withValues(alpha: 0.015)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
