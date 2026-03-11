import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weatherman/config/design_system.dart';
import 'package:weatherman/widgets/glassmorphic/grain_painter.dart';

// ── Helper: builds the layered glass recipe ──
Widget _buildGlass({
  required Widget child,
  required double blur,
  required double tintOpacity,
  required double borderRadius,
  required Color glassTint,
  required int grainSeed,
  required EdgeInsetsGeometry padding,
  bool useBackdropFilter = true,
  VoidCallback? onTap,
  EdgeInsetsGeometry? margin,
  Color? borderColor,
}) {
  final fill = DesignSystem.glassColor(glassTint, tintOpacity);
  final border = Border.all(
    color: borderColor ?? DesignSystem.glassBorderColor,
    width: DesignSystem.glassBorderWidth,
  );
  final radius = BorderRadius.circular(borderRadius);

  Widget inner = Container(
    decoration: BoxDecoration(color: fill, borderRadius: radius, border: border),
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: GrainPainter(seed: grainSeed)),
        ),
        Padding(padding: padding, child: child),
      ],
    ),
  );

  Widget card;
  if (useBackdropFilter) {
    card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: inner,
      ),
    );
  } else {
    card = ClipRRect(borderRadius: radius, child: inner);
  }

  if (onTap != null) card = GestureDetector(onTap: onTap, child: card);
  if (margin != null) card = Padding(padding: margin, child: card);
  return card;
}

/// Primary glass card — blur 20, tint 0.14. For main content sections.
class PrimaryGlassCard extends StatelessWidget {
  final Widget child;
  final Color glassTint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final int grainSeed;
  final Color? borderColor;

  const PrimaryGlassCard({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
    this.padding,
    this.margin,
    this.onTap,
    this.grainSeed = 42,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => _buildGlass(
        child: child,
        blur: DesignSystem.primaryBlur,
        tintOpacity: DesignSystem.primaryTintOpacity,
        borderRadius: DesignSystem.radiusCard,
        glassTint: glassTint,
        grainSeed: grainSeed,
        padding: padding ?? const EdgeInsets.all(DesignSystem.spacingM),
        onTap: onTap,
        margin: margin,
        borderColor: borderColor,
      );
}

/// Secondary glass card — blur 14, tint 0.10. For grid detail tiles.
class SecondaryGlassCard extends StatelessWidget {
  final Widget child;
  final Color glassTint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final int grainSeed;

  const SecondaryGlassCard({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
    this.padding,
    this.margin,
    this.onTap,
    this.grainSeed = 17,
  });

  @override
  Widget build(BuildContext context) => _buildGlass(
        child: child,
        blur: DesignSystem.secondaryBlur,
        tintOpacity: DesignSystem.secondaryTintOpacity,
        borderRadius: DesignSystem.radiusTile,
        glassTint: glassTint,
        grainSeed: grainSeed,
        padding: padding ?? const EdgeInsets.all(DesignSystem.spacingM),
        onTap: onTap,
        margin: margin,
      );
}

/// Subtle glass card — blur 8, tint 0.07. For hourly/daily rows.
class SubtleGlassCard extends StatelessWidget {
  final Widget child;
  final Color glassTint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final int grainSeed;

  const SubtleGlassCard({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
    this.padding,
    this.margin,
    this.onTap,
    this.grainSeed = 7,
  });

  @override
  Widget build(BuildContext context) => _buildGlass(
        child: child,
        blur: DesignSystem.subtleBlur,
        tintOpacity: DesignSystem.subtleTintOpacity,
        borderRadius: DesignSystem.radiusTile,
        glassTint: glassTint,
        grainSeed: grainSeed,
        padding: padding ?? const EdgeInsets.all(DesignSystem.spacingS),
        useBackdropFilter: false,
        onTap: onTap,
        margin: margin,
      );
}

/// Glass pill — blur 12, tint 0.12. For tags, chips, hourly items.
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color glassTint;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final int grainSeed;
  final bool selected;

  const GlassPill({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
    this.padding,
    this.onTap,
    this.grainSeed = 3,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => _buildGlass(
        child: child,
        blur: DesignSystem.pillBlur,
        tintOpacity:
            selected ? DesignSystem.pillTintOpacity + 0.06 : DesignSystem.pillTintOpacity,
        borderRadius: DesignSystem.radiusPill,
        glassTint: glassTint,
        grainSeed: grainSeed,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingM,
              vertical: DesignSystem.spacingS,
            ),
        useBackdropFilter: false,
        onTap: onTap,
        borderColor:
            selected ? Colors.white.withValues(alpha: 0.35) : null,
      );
}

/// Lightweight glass card — no BackdropFilter. For dense lists.
class LightGlassCard extends StatelessWidget {
  final Widget child;
  final Color glassTint;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const LightGlassCard({
    super.key,
    required this.child,
    this.glassTint = DesignSystem.defaultGlassTint,
    this.padding,
    this.borderRadius = DesignSystem.radiusTile,
  });

  @override
  Widget build(BuildContext context) => _buildGlass(
        child: child,
        blur: 0,
        tintOpacity: DesignSystem.subtleTintOpacity,
        borderRadius: borderRadius,
        glassTint: glassTint,
        grainSeed: 1,
        padding: padding ?? const EdgeInsets.all(DesignSystem.spacingM),
        useBackdropFilter: false,
      );
}
