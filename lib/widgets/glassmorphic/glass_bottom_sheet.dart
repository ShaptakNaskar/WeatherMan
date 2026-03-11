import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/widgets/glassmorphic/grain_painter.dart';

/// Reusable glassmorphic bottom sheet wrapper.
/// Shows a frosted glass sheet at 65% height with drag handle.
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final Color glassTint;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
  });

  /// Convenience launcher.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    Color glassTint = DesignSystem.defaultGlassTint,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassBottomSheet(glassTint: glassTint, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fill = DesignSystem.glassColor(glassTint, DesignSystem.primaryTintOpacity);
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignSystem.radiusCard),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              border: Border(
                top: BorderSide(
                  color: DesignSystem.glassBorderColor,
                  width: DesignSystem.glassBorderWidth,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: const GrainPainter(seed: 99)),
                ),
                Column(
                  children: [
                    const SizedBox(height: DesignSystem.spacingS),
                    // Drag handle
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingM),
                    Expanded(child: child),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
