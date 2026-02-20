// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colors ──────────────────────────────────────────────
  static const Color background    = Color(0xFF08080F);
  static const Color surface       = Color(0xFF111119);
  static const Color surfaceLight  = Color(0xFF1C1C28);
  static const Color surfaceCard   = Color(0xFF161622);
  static const Color border        = Color(0xFF222233);
  static const Color borderLight   = Color(0xFF2D2D42);
  static const Color textPrimary   = Color(0xFFF4F4FA);
  static const Color textSecondary = Color(0xFF7878A0);
  static const Color textMuted     = Color(0xFF4A4A65);
  static const Color accent        = Color(0xFF6366F1);
  static const Color accentSoft    = Color(0xFF8B5CF6);

  // ── Classification colors ──────────────────────────────────────
  static const Color accelerating = Color(0xFF10B981);
  static const Color emerging     = Color(0xFF3B82F6);
  static const Color stable       = Color(0xFFF59E0B);
  static const Color declining    = Color(0xFFEF4444);

  // ── Signal colors ──────────────────────────────────────────────
  static const Color googleColor      = Color(0xFF4285F4);
  static const Color marketplaceColor = Color(0xFFFF6B35);
  static const Color pinterestColor   = Color(0xFFE60023);

  // ── Helper: get color for a classification string ──────────────
  static Color classificationColor(String classification) {
    switch (classification) {
      case 'Accelerating': return accelerating;
      case 'Emerging':     return emerging;
      case 'Stable':       return stable;
      case 'Declining':    return declining;
      default:             return textSecondary;
    }
  }

  // ── Helper: get color for a recommendation string ──────────────
  static Color recommendationColor(String recommendation) {
    switch (recommendation) {
      case 'Increase': return accelerating;
      case 'Maintain': return stable;
      case 'Reduce':   return declining;
      default:         return textSecondary;
    }
  }

  // ── Card decoration helper ─────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 16,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? surfaceCard,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: border, width: 1)
          : null,
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSoft,
        surface: surfaceCard,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
          displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary),
          titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
          bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
          labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      dividerColor: border,
    );
  }
}
