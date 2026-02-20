// lib/theme/app_theme.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF0F0F5); // lavender-tinted page
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F8);
  static const Color border = Color(0xFFE2E2EA);
  static const Color borderLight = Color(0xFFD0D0DC);

  static const Color textPrimary = Color(0xFF111118);
  static const Color textSecondary = Color(0xFF8E8E9A);
  static const Color textMuted = Color(0xFFB0B0BE);

  // Dark accent (replaces green as primary pill/badge color)
  static const Color accentDark = Color(0xFF1C1C28);
  // Subtle blue accent for interactive highlights
  static const Color accent = Color(0xFF4F7FFF);
  static const Color accentSoft = Color(0xFF7BA3FF);

  // ── Classification colors ────────────────────────────────────
  static const Color accelerating = Color(0xFF10B981);
  static const Color emerging = Color(0xFF6366F1);
  static const Color stable = Color(0xFFF59E0B);
  static const Color declining = Color(0xFFEF4444);

  // ── Signal source colors ─────────────────────────────────────
  static const Color googleColor = Color(0xFF4285F4);
  static const Color marketplaceColor = Color(0xFFFF6B35);
  static const Color pinterestColor = Color(0xFFE60023);

  // ── Shadow ───────────────────────────────────────────────────
  static const Color cardShadow = Color(0x0C000000);
  static const Color deepShadow = Color(0x18000000);

  // ── Glassmorphism helpers ────────────────────────────────────

  /// Frosted glass card decoration — light glass look on colored backgrounds
  static BoxDecoration glassDecoration({
    double radius = 22,
    Color tint = Colors.white,
    double opacity = 0.55,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: tint.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: Colors.white.withOpacity(0.45), width: 1.2)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.6),
          blurRadius: 1,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  /// Dark frosted glass — for elevated panels on dark backgrounds
  static BoxDecoration darkGlassDecoration({
    double radius = 22,
    double opacity = 0.40,
  }) {
    return BoxDecoration(
      color: const Color(0xFF1C1C28).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  /// Regular white card decoration (non-glass)
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 20,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? surfaceCard,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: border.withOpacity(0.8), width: 1)
          : null,
      boxShadow: const [
        BoxShadow(color: cardShadow, blurRadius: 16, offset: Offset(0, 6)),
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // ── Classification color helper ──────────────────────────────
  static Color classificationColor(String classification) {
    switch (classification) {
      case 'Accelerating':
        return accelerating;
      case 'Emerging':
        return emerging;
      case 'Stable':
        return stable;
      case 'Declining':
        return declining;
      default:
        return textSecondary;
    }
  }

  // ── Recommendation color helper ──────────────────────────────
  static Color recommendationColor(String recommendation) {
    switch (recommendation) {
      case 'Increase':
        return accelerating;
      case 'Maintain':
        return stable;
      case 'Reduce':
        return declining;
      default:
        return textSecondary;
    }
  }

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentSoft,
        surface: surfaceCard,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border.withOpacity(0.8), width: 1),
        ),
        shadowColor: cardShadow,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -1.0,
          ),
          displayMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1.1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      dividerColor: border,
    );
  }
}

/// Glassmorphism wrapper widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final Color tint;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 22,
    this.blur = 18,
    this.tint = Colors.white,
    this.tintOpacity = 0.55,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration:
              decoration ??
              AppTheme.glassDecoration(
                radius: radius,
                tint: tint,
                opacity: tintOpacity,
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Dark glassmorphism wrapper
class DarkGlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;

  const DarkGlassCard({
    super.key,
    required this.child,
    this.radius = 22,
    this.blur = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: AppTheme.darkGlassDecoration(radius: radius),
          child: child,
        ),
      ),
    );
  }
}
