import 'package:flutter/material.dart';

/// Static horizontal fog bands with varying opacity.
class FogOverlay extends StatelessWidget {
  const FogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _FogPainter(), size: Size.infinite);
  }
}

class _FogPainter extends CustomPainter {
  const _FogPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const bands = [
      (yFrac: 0.30, height: 0.08, alpha: 0.10),
      (yFrac: 0.45, height: 0.10, alpha: 0.14),
      (yFrac: 0.60, height: 0.12, alpha: 0.12),
      (yFrac: 0.75, height: 0.10, alpha: 0.08),
      (yFrac: 0.88, height: 0.14, alpha: 0.16),
    ];
    for (final b in bands) {
      paint.color = Colors.white.withValues(alpha: b.alpha);
      final rect = Rect.fromLTWH(
        0,
        b.yFrac * size.height,
        size.width,
        b.height * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_FogPainter old) => false;
}
