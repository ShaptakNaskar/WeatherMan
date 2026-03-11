import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system — all visual tokens live here.
/// Never hardcode visual values outside this file.
class DesignSystem {
  DesignSystem._();

  // ── Radius Tokens ──
  static const double radiusCard = 24.0;
  static const double radiusPill = 50.0;
  static const double radiusTile = 18.0;

  // ── Spacing Tokens ──
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ── Animation Tokens ──
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 450);
  static const Duration durationSlow = Duration(milliseconds: 800);
  static const Duration durationBackground = Duration(milliseconds: 1400);
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveBackground = Curves.easeInOut;

  // ── Glass Recipe Constants ──
  static const double primaryBlur = 20.0;
  static const double primaryTintOpacity = 0.14;
  static const double secondaryBlur = 14.0;
  static const double secondaryTintOpacity = 0.10;
  static const double subtleBlur = 8.0;
  static const double subtleTintOpacity = 0.07;
  static const double pillBlur = 12.0;
  static const double pillTintOpacity = 0.12;
  static const double glassBorderOpacity = 0.18;
  static const double glassBorderWidth = 0.8;
  static const int grainDotCount = 4000;
  static const double grainMinRadius = 0.4;
  static const double grainMaxRadius = 0.8;
  static const double grainMinOpacity = 0.04;
  static const double grainMaxOpacity = 0.07;

  // ── Color Tokens ──
  static const Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white.withValues(alpha: 0.75);
  static Color textTertiary = Colors.white.withValues(alpha: 0.50);
  static Color glassBorderColor = Colors.white.withValues(alpha: glassBorderOpacity);

  /// Compute blended glass fill from a tint color.
  static Color glassColor(Color glassTint, double tintOpacity) {
    return Color.alphaBlend(
      glassTint.withValues(alpha: tintOpacity),
      Colors.white.withValues(alpha: 0.06),
    );
  }

  // ── Text Shadow ──
  static const List<Shadow> textShadow = [
    Shadow(
      color: Color(0x60000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];

  // ── Typography Tokens (Inter via Google Fonts) ──
  static TextStyle get tempHero => GoogleFonts.inter(
        fontSize: 88,
        fontWeight: FontWeight.w200,
        color: textPrimary,
        shadows: textShadow,
      );

  static TextStyle get tempLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: textPrimary,
        shadows: textShadow,
      );

  static TextStyle get conditionLabel => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        shadows: textShadow,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 2.0,
        shadows: textShadow,
      );

  static TextStyle get metricValue => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        shadows: textShadow,
      );

  static TextStyle get metricLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 1.5,
        shadows: textShadow,
      );

  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        shadows: textShadow,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        shadows: textShadow,
      );

  // ── Default Glass Tint (clear day fallback) ──
  static const Color defaultGlassTint = Color(0xFF4A90D9);

  // ── Icon Sizes ──
  static const double iconHero = 80.0;
  static const double iconSection = 24.0;
  static const double iconHourly = 18.0;
  static const double iconDetail = 20.0;

  // ── Hero Parallax ──
  static const double heroParallaxFactor = 0.4;
}
