import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Cyberpunk HUD-style loading widget with animated scan lines,
/// data stream text, and neon pulse effects.
class WeatherLoadingShimmer extends StatefulWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  State<WeatherLoadingShimmer> createState() => _WeatherLoadingShimmerState();
}

class _WeatherLoadingShimmerState extends State<WeatherLoadingShimmer>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _glitchController;
  final List<String> _dataStream = [];
  final Random _rng = Random();
  Timer? _streamTimer;
  int _dotCount = 0;
  Timer? _dotTimer;

  static const _streamLines = [
    'UPLINK_HANDSHAKE...',
    'ATMOSPHERIC_SENSOR [OK]',
    'SAT_FEED SYNC...',
    'WEATHER_MATRIX INIT...',
    'PARSING FORECAST DATA...',
    'NEURAL_NET CALIBRATION...',
    'HUMIDITY_PROBE [OK]',
    'WIND_VECTOR LOCKED',
    'THERMAL_SCAN ACTIVE...',
    'UV_INDEX SAMPLING...',
    'AQI_MONITOR ONLINE',
    'PRECIP_RADAR LINKED',
    'BAROMETER SYNC [OK]',
    'COMPILING RESULTS...',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Stream data lines periodically
    _streamTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() {
        if (_dataStream.length >= 6) _dataStream.removeAt(0);
        _dataStream.add(_streamLines[_rng.nextInt(_streamLines.length)]);
      });
      // Occasional glitch
      if (_rng.nextDouble() < 0.2) {
        _glitchController.forward(from: 0);
      }
    });

    // Animate dots for loading label
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _dotCount = (_dotCount + 1) % 4);
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _glitchController.dispose();
    _streamTimer?.cancel();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    final padded = dots.padRight(3);

    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── HUD ring + scan animation ──
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _scanController.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(120, 120),
                          painter: _HudRingPainter(
                            progress: _scanController.value,
                            color: CyberpunkTheme.neonCyan,
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner pulsing glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 50 + (_pulseController.value * 10),
                        height: 50 + (_pulseController.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CyberpunkTheme.neonCyan.withValues(alpha: 0.3 + _pulseController.value * 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberpunkTheme.neonCyan.withValues(alpha: 0.15 + _pulseController.value * 0.15),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Center icon
                  Icon(
                    Icons.radar_rounded,
                    color: CyberpunkTheme.neonCyan.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Main loading label ──
            Text(
              'SYNCING WEATHER FEED$padded',
              style: const TextStyle(
                fontFamily: CyberpunkTheme.monoFont,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CyberpunkTheme.neonCyan,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: Color(0x8000F0FF), blurRadius: 8),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Data stream panel ──
            AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                final glitching = _glitchController.isAnimating;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.bgPanel.withValues(alpha: 0.8),
                    border: Border.all(
                      color: glitching
                          ? CyberpunkTheme.neonMagenta.withValues(alpha: 0.6)
                          : CyberpunkTheme.glassBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CyberpunkTheme.neonGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: CyberpunkTheme.neonGreen.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DATA_STREAM',
                            style: TextStyle(
                              fontFamily: CyberpunkTheme.monoFont,
                              fontSize: 9,
                              color: CyberpunkTheme.neonCyan.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Stream lines
                      ..._dataStream.asMap().entries.map((entry) {
                        final opacity = 0.3 + (entry.key / _dataStream.length) * 0.7;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '> ${entry.value}',
                            style: TextStyle(
                              fontFamily: CyberpunkTheme.monoFont,
                              fontSize: 10,
                              color: CyberpunkTheme.textPrimary.withValues(alpha: opacity),
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      if (_dataStream.isEmpty)
                        Text(
                          '> AWAITING SIGNAL...',
                          style: TextStyle(
                            fontFamily: CyberpunkTheme.monoFont,
                            fontSize: 10,
                            color: CyberpunkTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ── Bottom scanline bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScanBarPainter(
                        progress: _scanController.value,
                        color: CyberpunkTheme.neonCyan,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a segmented HUD ring with a gap and glow
class _HudRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HudRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer segmented ring
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw segmented arcs
    const segments = 8;
    const gapAngle = 0.15;
    const segAngle = (2 * pi / segments) - gapAngle;

    for (int i = 0; i < segments; i++) {
      final startAngle = i * (segAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segAngle,
        false,
        paint,
      );
    }

    // Active arc (brighter, follows progress)
    final activePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * pi,
      pi / 3,
      false,
      activePaint,
    );

    // Glow for active arc
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 2 * pi,
      pi / 3,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HudRingPainter old) => old.progress != progress;
}

/// Paints a travelling highlight bar
class _ScanBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanBarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final bgPaint = Paint()..color = color.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Moving highlight
    const barWidth = 80.0;
    final x = (size.width + barWidth) * progress - barWidth;
    final gradient = LinearGradient(
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.0),
      ],
    );
    final rect = Rect.fromLTWH(x, 0, barWidth, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanBarPainter old) => old.progress != progress;
}
