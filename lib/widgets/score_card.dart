// lib/widgets/score_card.dart

import 'package:flutter/material.dart';
import '../models/trend_summary.dart';
import '../theme/app_sizes.dart';
import '../theme/app_theme.dart';
import 'recommendation_chip.dart';

class ScoreCard extends StatelessWidget {
  final TrendSummary item;
  final VoidCallback onTap;

  const ScoreCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    final classColor = AppTheme.classificationColor(item.classification);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: sz.cardMarginH,
          vertical: sz.cardGap,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [classColor, classColor.withOpacity(0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(sz.s(13)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatKeyword(item.keyword),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: sz.sp(14),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(height: sz.s(5)),
                                  _ClassificationBadge(
                                    label: item.classification,
                                    color: classColor,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: sz.s(10)),
                            // Score badge
                            Container(
                              width: sz.s(50),
                              height: sz.s(50),
                              decoration: BoxDecoration(
                                color: classColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(sz.s(13)),
                                border: Border.all(
                                  color: classColor.withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.trendScore.toStringAsFixed(0),
                                    style: TextStyle(
                                      color: classColor,
                                      fontSize: sz.sp(18),
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: sz.s(2)),
                                  Text(
                                    'score',
                                    style: TextStyle(
                                      color: classColor.withOpacity(0.6),
                                      fontSize: sz.sp(8),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sz.s(11)),
                        // Signal bars
                        _SignalMiniBar(
                          label: 'Google',
                          score: item.googleScore,
                          color: AppTheme.googleColor,
                        ),
                        SizedBox(height: sz.s(5)),
                        _SignalMiniBar(
                          label: 'Market',
                          score: item.marketplaceScore,
                          color: AppTheme.marketplaceColor,
                        ),
                        SizedBox(height: sz.s(5)),
                        _SignalMiniBar(
                          label: 'Pinterest',
                          score: item.pinterestScore,
                          color: AppTheme.pinterestColor,
                        ),
                        SizedBox(height: sz.s(11)),
                        // Bottom row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RecommendationChip(
                              recommendation: item.recommendation,
                              adjustmentPct: item.adjustmentPct,
                            ),
                            Container(
                              width: sz.s(26),
                              height: sz.s(26),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: sz.s(10),
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatKeyword(String keyword) {
    return keyword
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _ClassificationBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ClassificationBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sz.s(8),
        vertical: sz.s(3),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: sz.sp(8.5),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SignalMiniBar extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _SignalMiniBar({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    final fraction = (score / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: sz.s(44),
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: sz.sp(10),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: sz.s(6)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.8)),
              minHeight: 4,
            ),
          ),
        ),
        SizedBox(width: sz.s(7)),
        SizedBox(
          width: sz.s(26),
          child: Text(
            score.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: sz.sp(10.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}