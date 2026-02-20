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

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Outer neumorphic glass container ──────────────────────
        Container(
          width: size + 28,
          height: size + 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.90),
                blurRadius: 12,
                offset: const Offset(-6, -6),
              ),
            ],
          ),
        ),
        // ── Inner glass shimmer ring ───────────────────────────────
        Container(
          width: size + 10,
          height: size + 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.white.withOpacity(0.80), color.withOpacity(0.06)],
              stops: const [0.55, 1.0],
            ),
          ),
        ),
        // ── Progress indicator ─────────────────────────────────────
        CircularPercentIndicator(
          radius: size / 2,
          lineWidth: 12,
          percent: fraction,
          backgroundColor: AppTheme.border.withOpacity(0.5),
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1200,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'TMS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: size * 0.10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
