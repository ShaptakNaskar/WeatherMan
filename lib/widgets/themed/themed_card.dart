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
    final isDark = t.themeData.brightness == Brightness.dark;
    final usingBrightAccent = _relativeLuminance(t.accentColor) > 0.58;
    final baseAlpha = t.cardColor.a == 1.0
        ? (isDark ? 0.24 : 0.64)
        : (t.cardColor.a * (isDark ? 0.82 : 0.92));

    final borderAlpha = isDark ? (usingBrightAccent ? 0.56 : 0.68) : 0.48;
    final sheenAlpha = isDark ? 0.15 : 0.2;
    final glowAlpha = isDark ? (usingBrightAccent ? 0.1 : 0.14) : 0.08;
    final borderColor = usingBrightAccent && isDark
        ? t.textTertiary.withValues(alpha: borderAlpha)
        : t.cardBorderColor.withValues(alpha: borderAlpha);
    final glowColor = usingBrightAccent && isDark
        ? t.accentColorSecondary.withValues(alpha: glowAlpha)
        : t.cardGlowColor.withValues(alpha: glowAlpha);

    final radius = BorderRadius.circular(t.cardBorderRadius);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (t.cardBlurSigma * 1.35).clamp(10.0, 34.0),
                sigmaY: (t.cardBlurSigma * 1.35).clamp(10.0, 34.0),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (t.cardBlurSigma * 0.45).clamp(4.0, 12.0),
                sigmaY: (t.cardBlurSigma * 0.45).clamp(4.0, 12.0),
              ),
              child: Container(
                color: Colors.white.withValues(alpha: isDark ? 0.012 : 0.03),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: t.cardColor.withValues(alpha: baseAlpha),
                borderRadius: radius,
                border: Border.all(
                  color: borderColor,
                  width: t.cardBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(color: glowColor, blurRadius: 20, spreadRadius: 1),
                  if (isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: sheenAlpha),
                      Colors.white.withValues(alpha: sheenAlpha * 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(999),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.2 : 0.32),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -28,
            top: -26,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.09 : 0.18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.06 : 0.12,
                      ),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(padding: padding ?? const EdgeInsets.all(16), child: child),
        ],
      ),
    );

    content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.cardBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.03 : 0.09),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
      child: content,
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

/// Lightweight themed card for dense grids and compact surfaces.
class ThemedLightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radiusScale;

  const ThemedLightCard({
    super.key,
    required this.child,
    this.padding,
    this.radiusScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    final isDark = t.themeData.brightness == Brightness.dark;
    final usingBrightAccent = _relativeLuminance(t.accentColor) > 0.58;
    final radiusValue = (t.cardBorderRadius * radiusScale).clamp(8.0, 36.0);
    final radius = BorderRadius.circular(radiusValue);
    final topSheenHeight = radiusValue < 16 ? 16.0 : 22.0;
    final alpha = t.cardColor.a == 1.0
        ? (isDark ? 0.25 : 0.58)
        : (t.cardColor.a * (isDark ? 0.76 : 0.92));
    final borderColor = usingBrightAccent && isDark
        ? t.textTertiary.withValues(alpha: isDark ? 0.6 : 0.45)
        : t.cardBorderColor.withValues(alpha: isDark ? 0.62 : 0.45);
    final glowColor = usingBrightAccent && isDark
        ? t.accentColorSecondary.withValues(alpha: isDark ? 0.11 : 0.08)
        : t.cardGlowColor.withValues(alpha: isDark ? 0.13 : 0.08);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (t.cardBlurSigma * 1.05).clamp(8.0, 22.0),
                sigmaY: (t.cardBlurSigma * 1.05).clamp(8.0, 22.0),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (t.cardBlurSigma * 0.35).clamp(3.0, 9.0),
                sigmaY: (t.cardBlurSigma * 0.35).clamp(3.0, 9.0),
              ),
              child: Container(
                color: Colors.white.withValues(alpha: isDark ? 0.012 : 0.025),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: t.cardColor.withValues(alpha: alpha),
                borderRadius: radius,
                border: Border.all(
                  color: borderColor,
                  width: t.cardBorderWidth * 0.65,
                ),
                boxShadow: [
                  BoxShadow(color: glowColor, blurRadius: 14, spreadRadius: 0),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.1 : 0.18),
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.06),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.32, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                height: topSheenHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(999),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.16 : 0.28),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: -18,
            child: IgnorePointer(
              child: Container(
                width: 86,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.05 : 0.1,
                      ),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(padding: padding ?? const EdgeInsets.all(16), child: child),
        ],
      ),
    );

    content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.03 : 0.08),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
      child: content,
    );

    return content;
  }
}

double _relativeLuminance(Color color) {
  return color.computeLuminance();
}
