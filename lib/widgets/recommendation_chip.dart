// lib/widgets/recommendation_chip.dart

import 'package:flutter/material.dart';
import '../theme/app_sizes.dart';
import '../theme/app_theme.dart';

class RecommendationChip extends StatelessWidget {
  final String recommendation;
  final int adjustmentPct;
  final bool large;

  const RecommendationChip({
    super.key,
    required this.recommendation,
    required this.adjustmentPct,
    this.large = false,
  });

  String get _label {
    if (adjustmentPct == 0) return recommendation;
    final sign = adjustmentPct > 0 ? '+' : '';
    return '$recommendation $sign$adjustmentPct%';
  }

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    final color = AppTheme.recommendationColor(recommendation);
    final fontSize = large ? sz.sp(13) : sz.sp(11);
    final padding = large
        ? EdgeInsets.symmetric(horizontal: sz.s(13), vertical: sz.s(7))
        : EdgeInsets.symmetric(horizontal: sz.s(10), vertical: sz.s(5));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
