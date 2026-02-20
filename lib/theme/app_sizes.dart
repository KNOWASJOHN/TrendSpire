// lib/theme/app_sizes.dart

import 'package:flutter/material.dart';

/// Responsive sizing helper.
/// Instantiate once at the top of every build() method:
///   final sz = AppSizes(context);
///
/// Base design reference width: 390 px (iPhone 14 / Pixel 8).
/// Scales proportionally down for smaller phones (≥ 320 px) and
/// up for larger phones / tablets (≤ 430 px) with sensible clamps.
class AppSizes {
  AppSizes(BuildContext context)
      : screenW = MediaQuery.sizeOf(context).width,
        screenH = MediaQuery.sizeOf(context).height;

  final double screenW;
  final double screenH;

  static const double _base = 390.0;

  // ── Core scale helpers ──────────────────────────────────────

  /// Scale a layout dimension proportionally to screen width.
  double s(double val) => val * (screenW / _base);

  /// Scale a font size – slightly compressed clamp to avoid extremes.
  double sp(double val) => val * (screenW / _base).clamp(0.82, 1.15);

  // ── Named layout values ──────────────────────────────────────

  /// Horizontal page padding (edges of screen).
  double get hPad {
    if (screenW < 350) return 12.0;
    if (screenW < 390) return 16.0;
    if (screenW >= 430) return 22.0;
    return 20.0;
  }

  /// Vertical gap between list cards.
  double get cardGap => screenW < 360 ? 4.0 : 5.0;

  /// Horizontal margin on list cards.
  double get cardMarginH => screenW < 360 ? 12.0 : (screenW >= 430 ? 18.0 : 16.0);

  /// Width of a stat summary card in the horizontal scroll row.
  double get statCardW {
    if (screenW < 350) return 120.0;
    if (screenW < 390) return 130.0;
    if (screenW >= 430) return 154.0;
    return 142.0;
  }

  /// Height of the stat card scroll row container (including top padding).
  double get statRowH {
    if (screenW < 360) return 116.0;
    if (screenW >= 430) return 132.0;
    return 124.0;
  }

  /// Score ring diameter for detail screen.
  double get scoreRingSize => (screenW * 0.36).clamp(110.0, 160.0);

  /// Inner padding for surface cards.
  double get cardPad => screenW < 360 ? 12.0 : 16.0;

  // ── State helpers ─────────────────────────────────────────────

  bool get isSmall => screenW < 360;
  bool get isCompact => screenW < 400;
  bool get isLarge => screenW >= 430;
}
