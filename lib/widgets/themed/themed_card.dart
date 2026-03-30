import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherman/providers/theme_provider.dart';

/// Theme-aware card widget that adapts styling based on the current theme.
/// Replaces direct CyberGlassCard / glass_card usage.
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(t.cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: t.cardBlurSigma, sigmaY: t.cardBlurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: t.cardColor.withValues(alpha: t.cardColor.a == 1.0 ? 0.85 : t.cardColor.a),
            borderRadius: BorderRadius.circular(t.cardBorderRadius),
            border: Border.all(
              color: t.cardBorderColor,
              width: t.cardBorderWidth,
            ),
            boxShadow: t.cardGlowColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: t.cardGlowColor,
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
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

/// Lightweight themed card (no backdrop filter, for dense grids)
class ThemedLightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ThemedLightCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardColor.withValues(alpha: t.cardColor.a == 1.0 ? 0.7 : t.cardColor.a * 0.8),
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        border: Border.all(
          color: t.cardBorderColor.withValues(alpha: 0.5),
          width: t.cardBorderWidth * 0.5,
        ),
        boxShadow: t.cardGlowColor != Colors.transparent
            ? [
                BoxShadow(
                  color: t.cardGlowColor.withValues(alpha: 0.08),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}
