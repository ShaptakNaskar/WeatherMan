import 'dart:math';
import 'package:flutter/material.dart';

/// All weather icons drawn procedurally via CustomPainter.
/// Factory: `WeatherIconPainter.forCode(code, isDay: ..., size: ...)`.
class WeatherIconPainter extends CustomPainter {
  final int code;
  final bool isDay;
  final Color color;

  const WeatherIconPainter({
    required this.code,
    this.isDay = true,
    this.color = Colors.white,
  });

  /// Convenience widget wrapper.
  static Widget forCode(int code, {bool isDay = true, double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: WeatherIconPainter(code: code, isDay: isDay, color: color),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(s / 2, s / 2);
    if (code == 0 || code == 1) {
      isDay ? _drawSun(canvas, c, s) : _drawMoon(canvas, c, s);
    } else if (code == 2) {
      isDay ? _drawPartlyCloudy(canvas, c, s) : _drawMoon(canvas, c, s);
    } else if (code == 3) {
      _drawCloud(canvas, c, s);
    } else if (code == 45 || code == 48) {
      _drawFog(canvas, c, s);
    } else if (code >= 51 && code <= 57) {
      _drawDrizzle(canvas, c, s);
    } else if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      code == 65 || code == 67 || code == 82
          ? _drawHeavyRain(canvas, c, s)
          : _drawRain(canvas, c, s);
    } else if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      _drawSnow(canvas, c, s);
    } else if (code >= 95) {
      _drawThunder(canvas, c, s);
    } else {
      _drawCloud(canvas, c, s);
    }
  }

  Paint get _p => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;

  // ── Sun ──
  void _drawSun(Canvas canvas, Offset c, double s) {
    final r = s * 0.2;
    final paint = _p..style = PaintingStyle.fill;
    canvas.drawCircle(c, r, paint);
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final from = c + Offset(cos(angle) * r * 1.5, sin(angle) * r * 1.5);
      final to = c + Offset(cos(angle) * r * 2.1, sin(angle) * r * 2.1);
      canvas.drawLine(from, to, paint);
    }
  }

  // ── Moon (crescent) ──
  void _drawMoon(Canvas canvas, Offset c, double s) {
    final r = s * 0.28;
    final paint = _p..style = PaintingStyle.fill;
    final path = Path()
      ..addOval(Rect.fromCircle(center: c, radius: r));
    final cutout = Path()
      ..addOval(Rect.fromCircle(center: c + Offset(r * 0.55, -r * 0.25), radius: r * 0.78));
    final moon = Path.combine(PathOperation.difference, path, cutout);
    canvas.drawPath(moon, paint);
  }

  // ── Partly cloudy (small sun + cloud) ──
  void _drawPartlyCloudy(Canvas canvas, Offset c, double s) {
    _drawSun(canvas, c + Offset(-s * 0.12, -s * 0.12), s * 0.6);
    _drawCloud(canvas, c + Offset(s * 0.08, s * 0.08), s * 0.75);
  }

  // ── Cloud ──
  void _drawCloud(Canvas canvas, Offset c, double s) {
    final paint = _p..style = PaintingStyle.fill;
    final r = s * 0.14;
    final base = c.dy + r * 0.5;
    canvas.drawCircle(Offset(c.dx - r * 1.1, base), r * 0.85, paint);
    canvas.drawCircle(Offset(c.dx, base - r * 0.7), r, paint);
    canvas.drawCircle(Offset(c.dx + r * 1.0, base - r * 0.15), r * 0.75, paint);
    canvas.drawRect(
      Rect.fromLTRB(c.dx - r * 1.5, base, c.dx + r * 1.5, base + r * 0.55),
      paint,
    );
  }

  // ── Rain ──
  void _drawRain(Canvas canvas, Offset c, double s) {
    _drawCloud(canvas, c + Offset(0, -s * 0.1), s * 0.8);
    final paint = _p..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final x = c.dx + (i - 1) * s * 0.14;
      final y = c.dy + s * 0.18;
      canvas.drawLine(Offset(x, y), Offset(x - s * 0.04, y + s * 0.14), paint);
    }
  }

  // ── Heavy rain ──
  void _drawHeavyRain(Canvas canvas, Offset c, double s) {
    _drawCloud(canvas, c + Offset(0, -s * 0.12), s * 0.8);
    final paint = _p..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final x = c.dx + (i - 1.5) * s * 0.12;
      final y = c.dy + s * 0.16;
      canvas.drawLine(Offset(x, y), Offset(x - s * 0.05, y + s * 0.18), paint);
    }
  }

  // ── Drizzle ──
  void _drawDrizzle(Canvas canvas, Offset c, double s) {
    _drawCloud(canvas, c + Offset(0, -s * 0.1), s * 0.8);
    final paint = _p..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final x = c.dx + (i - 1) * s * 0.14;
      canvas.drawCircle(Offset(x, c.dy + s * 0.22), s * 0.022, paint);
    }
  }

  // ── Snow ──
  void _drawSnow(Canvas canvas, Offset c, double s) {
    _drawCloud(canvas, c + Offset(0, -s * 0.12), s * 0.8);
    final paint = _p..style = PaintingStyle.stroke;
    final sc = Offset(c.dx, c.dy + s * 0.24);
    final r = s * 0.09;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      canvas.drawLine(sc, sc + Offset(cos(angle) * r, sin(angle) * r), paint);
    }
    canvas.drawCircle(sc, s * 0.015, paint..style = PaintingStyle.fill);
  }

  // ── Thunder ──
  void _drawThunder(Canvas canvas, Offset c, double s) {
    _drawCloud(canvas, c + Offset(0, -s * 0.15), s * 0.8);
    final paint = _p..style = PaintingStyle.fill;
    final bolt = Path()
      ..moveTo(c.dx + s * 0.02, c.dy + s * 0.05)
      ..lineTo(c.dx - s * 0.06, c.dy + s * 0.2)
      ..lineTo(c.dx + s * 0.01, c.dy + s * 0.2)
      ..lineTo(c.dx - s * 0.04, c.dy + s * 0.38)
      ..lineTo(c.dx + s * 0.08, c.dy + s * 0.16)
      ..lineTo(c.dx + s * 0.02, c.dy + s * 0.16)
      ..close();
    canvas.drawPath(bolt, paint);
  }

  // ── Fog ──
  void _drawFog(Canvas canvas, Offset c, double s) {
    final paint = _p
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04;
    for (int i = 0; i < 3; i++) {
      final y = c.dy + (i - 1) * s * 0.18;
      final w = s * (0.5 - i * 0.06);
      paint.color = color.withValues(alpha: 1.0 - i * 0.25);
      canvas.drawLine(Offset(c.dx - w, y), Offset(c.dx + w, y), paint);
    }
  }

  @override
  bool shouldRepaint(WeatherIconPainter old) =>
      old.code != code || old.isDay != isDay || old.color != color;
}
