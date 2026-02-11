import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Cyberpunk-styled glass card with neon border and scanline texture
class CyberGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color borderColor;
  final double glowIntensity;
  final VoidCallback? onTap;

  const CyberGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 4,
    this.borderColor = CyberpunkTheme.neonCyan,
    this.glowIntensity = 0.4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
            color: CyberpunkTheme.bgPanel.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor.withValues(alpha: glowIntensity),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: glowIntensity * 0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// Lightweight cyber card for dense grids (no backdrop filter)
class CyberLightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color borderColor;

  const CyberLightCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 4,
    this.borderColor = CyberpunkTheme.neonCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.bgPanel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.25),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Cyberpunk-styled pill/chip
class CyberPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;

  const CyberPill({
    super.key,
    required this.child,
    this.padding,
    this.borderColor = CyberpunkTheme.neonCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
