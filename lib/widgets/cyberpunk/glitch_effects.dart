import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Cyberpunk glitch text effect — periodically distorts text with RGB split & character replacement
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double glitchIntensity; // 0.0-1.0
  final bool enableGlitch;

  const GlitchText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.glitchIntensity = 0.5,
    this.enableGlitch = true,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  Timer? _glitchTimer;
  bool _isGlitching = false;
  String _displayText = '';
  double _xOffset = 0;

  static const String _glitchChars = '!@#\$%^&*()_+-=[]{}|;:<>?~/\\█▓▒░▄▀▐▌';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    if (widget.enableGlitch) {
      _scheduleGlitch();
    }
  }

  @override
  void didUpdateWidget(GlitchText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayText = widget.text;
    }
  }

  void _scheduleGlitch() {
    if (!mounted) return;
    final delay = 2000 + _random.nextInt(5000);
    _glitchTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _doGlitch();
      _scheduleGlitch();
    });
  }

  void _doGlitch() {
    if (!mounted) return;
    setState(() {
      _isGlitching = true;
      _xOffset = (_random.nextDouble() - 0.5) * 4 * widget.glitchIntensity;
      // Corrupt some characters
      final chars = widget.text.split('');
      final corruptCount = (chars.length * 0.3 * widget.glitchIntensity).round().clamp(1, chars.length);
      for (var i = 0; i < corruptCount; i++) {
        final idx = _random.nextInt(chars.length);
        chars[idx] = _glitchChars[_random.nextInt(_glitchChars.length)];
      }
      _displayText = chars.join();
    });

    // Restore after a brief flicker
    Future.delayed(Duration(milliseconds: 50 + _random.nextInt(100)), () {
      if (!mounted) return;
      setState(() {
        _isGlitching = false;
        _displayText = widget.text;
        _xOffset = 0;
      });
    });
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableGlitch || !_isGlitching) {
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    return Stack(
      children: [
        // Red channel offset
        Transform.translate(
          offset: Offset(_xOffset - 1.5, 0),
          child: Text(
            _displayText,
            style: widget.style?.copyWith(
              color: CyberpunkTheme.neonBlue.withValues(alpha: 0.5),
            ),
            textAlign: widget.textAlign,
          ),
        ),
        // Cyan channel offset
        Transform.translate(
          offset: Offset(_xOffset + 1.5, 0),
          child: Text(
            _displayText,
            style: widget.style?.copyWith(
              color: CyberpunkTheme.neonCyan.withValues(alpha: 0.5),
            ),
            textAlign: widget.textAlign,
          ),
        ),
        // Main text
        Transform.translate(
          offset: Offset(_xOffset, 0),
          child: Text(
            _displayText,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        ),
      ],
    );
  }
}

/// Scanline overlay effect
class ScanlineOverlay extends StatefulWidget {
  final double opacity;
  const ScanlineOverlay({super.key, this.opacity = 0.05});

  @override
  State<ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
          painter: _ScanlinePainter(
            offset: _controller.value,
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double offset;
  final double opacity;

  _ScanlinePainter({required this.offset, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: opacity);

    // Horizontal scanlines every 3px
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Moving bright scanline band
    final bandY = (offset * size.height * 1.3) - size.height * 0.15;
    final bandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          CyberpunkTheme.neonCyan.withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, bandY, size.width, 100));

    canvas.drawRect(Rect.fromLTWH(0, bandY, size.width, 100), bandPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => true;
}

/// Periodic screen flicker effect that wraps a child widget
class FlickerContainer extends StatefulWidget {
  final Widget child;
  final double flickerChance; // 0.0-1.0, how often flicker occurs

  const FlickerContainer({
    super.key,
    required this.child,
    this.flickerChance = 0.3,
  });

  @override
  State<FlickerContainer> createState() => _FlickerContainerState();
}

class _FlickerContainerState extends State<FlickerContainer> {
  final Random _random = Random();
  Timer? _flickerTimer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scheduleFlicker();
  }

  void _scheduleFlicker() {
    if (!mounted) return;
    final delay = 3000 + _random.nextInt(8000);
    _flickerTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (_random.nextDouble() < widget.flickerChance) {
        _doFlicker();
      }
      _scheduleFlicker();
    });
  }

  void _doFlicker() {
    if (!mounted) return;
    setState(() => _opacity = 0.7 + _random.nextDouble() * 0.2);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() => _opacity = 1.0);
      Future.delayed(const Duration(milliseconds: 30), () {
        if (!mounted) return;
        setState(() => _opacity = 0.8);
        Future.delayed(const Duration(milliseconds: 40), () {
          if (!mounted) return;
          setState(() => _opacity = 1.0);
        });
      });
    });
  }

  @override
  void dispose() {
    _flickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

/// Neon border glow effect around a container
class NeonBorderContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool animate;

  const NeonBorderContainer({
    super.key,
    required this.child,
    this.glowColor = CyberpunkTheme.neonCyan,
    this.borderRadius = 4,
    this.glowIntensity = 0.6,
    this.padding,
    this.margin,
    this.animate = false,
  });

  @override
  State<NeonBorderContainer> createState() => _NeonBorderContainerState();
}

class _NeonBorderContainerState extends State<NeonBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
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
        final intensity = widget.animate 
            ? 0.3 + _controller.value * 0.7 
            : widget.glowIntensity;
            
        return Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.glowColor.withValues(alpha: 0.05),
            border: Border.all(
              color: widget.glowColor.withValues(alpha: intensity * 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: intensity * 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: widget.glowColor.withValues(alpha: intensity * 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Digital noise/static overlay
class DigitalNoiseOverlay extends StatefulWidget {
  final double intensity;
  const DigitalNoiseOverlay({super.key, this.intensity = 0.03});

  @override
  State<DigitalNoiseOverlay> createState() => _DigitalNoiseOverlayState();
}

class _DigitalNoiseOverlayState extends State<DigitalNoiseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
          painter: _NoisePainter(
            seed: _random.nextInt(10000),
            intensity: widget.intensity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _NoisePainter extends CustomPainter {
  final int seed;
  final double intensity;

  _NoisePainter({required this.seed, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint();

    // Random glitch bars
    for (int i = 0; i < 3; i++) {
      if (random.nextDouble() < intensity * 10) {
        final y = random.nextDouble() * size.height;
        final h = 1.0 + random.nextDouble() * 3;
        final xOffset = (random.nextDouble() - 0.5) * 10;
        paint.color = CyberpunkTheme.neonCyan.withValues(alpha: intensity * random.nextDouble());
        canvas.drawRect(
          Rect.fromLTWH(xOffset, y, size.width + 10, h),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.seed != seed;
}

/// Horizontal glitch bar that randomly appears
class GlitchBar extends StatefulWidget {
  final Widget child;

  const GlitchBar({super.key, required this.child});

  @override
  State<GlitchBar> createState() => _GlitchBarState();
}

class _GlitchBarState extends State<GlitchBar> {
  final Random _random = Random();
  Timer? _timer;
  double _clipOffset = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    if (!mounted) return;
    _timer = Timer(Duration(milliseconds: 4000 + _random.nextInt(8000)), () {
      if (!mounted) return;
      setState(() {
        _clipOffset = (_random.nextDouble() - 0.5) * 8;
      });
      Future.delayed(Duration(milliseconds: 40 + _random.nextInt(80)), () {
        if (!mounted) return;
        setState(() {
          _clipOffset = 0;
        });
      });
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_clipOffset, 0),
      child: widget.child,
    );
  }
}
