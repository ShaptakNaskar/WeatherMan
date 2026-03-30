import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';
import 'package:weatherman/providers/theme_provider.dart';

/// Theme-aware loading widget.
/// Cyberpunk: HUD-style scan lines + data stream.
/// Clean/Pastel: Simple pulsing icon with progress indicator.
class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    if (themeProvider.isCyberpunk) {
      return const _CyberpunkLoading();
    }
    return const _SimpleLoading();
  }
}

// ── Simple themed loading (Clean / Pastel) ────────────────

class _SimpleLoading extends StatefulWidget {
  const _SimpleLoading();

  @override
  State<_SimpleLoading> createState() => _SimpleLoadingState();
}

class _SimpleLoadingState extends State<_SimpleLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.accentColor.withValues(alpha: 0.05 + _ctrl.value * 0.08),
                  border: Border.all(
                    color: t.accentColor.withValues(alpha: 0.2 + _ctrl.value * 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: t.accentColor.withValues(alpha: _ctrl.value * 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.cloud_rounded,
                  size: 36,
                  color: t.accentColor.withValues(alpha: 0.6 + _ctrl.value * 0.4),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: LinearProgressIndicator(
              backgroundColor: t.accentColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(t.accentColor.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading weather...',
            style: TextStyle(
              fontSize: 14,
              color: t.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cyberpunk HUD loading ─────────────────────────────────

class _CyberpunkLoading extends StatefulWidget {
  const _CyberpunkLoading();

  @override
  State<_CyberpunkLoading> createState() => _CyberpunkLoadingState();
}

class _CyberpunkLoadingState extends State<_CyberpunkLoading>
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

    _streamTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() {
        if (_dataStream.length >= 6) _dataStream.removeAt(0);
        _dataStream.add(_streamLines[_rng.nextInt(_streamLines.length)]);
      });
      if (_rng.nextDouble() < 0.2) {
        _glitchController.forward(from: 0);
      }
    });

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
            // HUD ring + scan animation
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 50 + (_pulseController.value * 10),
                        height: 50 + (_pulseController.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CyberpunkTheme.neonCyan.withValues(
                                alpha: 0.3 + _pulseController.value * 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberpunkTheme.neonCyan.withValues(
                                  alpha: 0.15 + _pulseController.value * 0.15),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Icon(
                    Icons.radar_rounded,
                    color: CyberpunkTheme.neonCyan.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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
    final bgPaint = Paint()..color = color.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

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
