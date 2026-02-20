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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: sz.sp(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: sz.s(2)),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: sz.sp(11),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontSize: sz.sp(15),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: sz.s(8)),
        LinearPercentIndicator(
          percent: fraction,
          lineHeight: 6,
          backgroundColor: AppTheme.border,
          progressColor: color,
          barRadius: const Radius.circular(3),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 800,
        ),
      ],
    );
  }
}
