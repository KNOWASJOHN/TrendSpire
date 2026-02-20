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

  IconData get _icon {
    switch (recommendation) {
      case 'Increase':
        return Icons.arrow_upward_rounded;
      case 'Maintain':
        return Icons.remove_rounded;
      case 'Reduce':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    final color = AppTheme.recommendationColor(recommendation);
    final isDark = recommendation == 'Increase';
    final fontSize = large ? sz.sp(13) : sz.sp(11.5);
    final vPad = large ? sz.s(8) : sz.s(5);
    final hPad = large ? sz.s(14) : sz.s(10);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: isDark ? color : color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? color : color.withOpacity(0.30),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: color.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: fontSize * 1.1,
            color: isDark ? Colors.white : color,
          ),
          SizedBox(width: sz.s(4)),
          Text(
            _label,
            style: TextStyle(
              color: isDark ? Colors.white : color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
