// lib/widgets/score_ring.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';

class ScoreRing extends StatelessWidget {
  final double score; // 0–100
  final String classification;
  final double size;

  const ScoreRing({
    super.key,
    required this.score,
    required this.classification,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.classificationColor(classification);
    final fraction = (score / 100).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 10,
      percent: fraction,
      backgroundColor: AppTheme.border,
      progressColor: color,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1000,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: size * 0.21,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'TMS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: size * 0.10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
