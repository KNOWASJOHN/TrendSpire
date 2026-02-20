// lib/widgets/signal_bar.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_sizes.dart';
import '../theme/app_theme.dart';

class SignalBar extends StatelessWidget {
  final String label;
  final double score; // 0–100
  final Color color;
  final String? subtitle;

  const SignalBar({
    super.key,
    required this.label,
    required this.score,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    final fraction = (score / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Colored dot
            Container(
              width: sz.s(8),
              height: sz.s(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.40),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: sz.s(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: sz.sp(13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: sz.s(2)),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: sz.sp(10.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: sz.s(10)),
            // Score value with glass pill
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sz.s(10),
                vertical: sz.s(4),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color.withOpacity(0.25), width: 1),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: color,
                  fontSize: sz.sp(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sz.s(10)),
        // Progress bar with glass track
        Stack(
          children: [
            // Track (glass-like)
            Container(
              height: sz.s(7),
              decoration: BoxDecoration(
                color: AppTheme.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            // Fill
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearPercentIndicator(
                percent: fraction,
                lineHeight: sz.s(7),
                backgroundColor: Colors.transparent,
                linearGradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                ),
                barRadius: const Radius.circular(100),
                padding: EdgeInsets.zero,
                animation: true,
                animationDuration: 900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
