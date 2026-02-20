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
          vertical: sz.s(5),
        ),
        decoration: AppTheme.cardDecoration(radius: 22),
        child: Padding(
          padding: EdgeInsets.all(sz.s(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: icon + keyword + score badge ──────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Classification icon container
                  Container(
                    width: sz.s(42),
                    height: sz.s(42),
                    decoration: BoxDecoration(
                      color: classColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(sz.s(13)),
                      border: Border.all(
                        color: classColor.withOpacity(0.22),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _classificationIcon(item.classification),
                      color: classColor,
                      size: sz.s(18),
                    ),
                  ),
                  SizedBox(width: sz.s(12)),
                  // Keyword + badge
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
                            fontSize: sz.sp(14.5),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: sz.s(4)),
                        _ClassificationBadge(
                          label: item.classification,
                          color: classColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: sz.s(10)),
                  // Dark score badge (glassmorphism-style pill)
                  GlassCard(
                    radius: 14,
                    blur: 10,
                    tint: AppTheme.accentDark,
                    tintOpacity: 0.90,
                    padding: EdgeInsets.symmetric(
                      horizontal: sz.s(10),
                      vertical: sz.s(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.trendScore.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sz.sp(18),
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: sz.s(2)),
                        Text(
                          'TMS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: sz.sp(8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sz.s(14)),
              // ── Signal bars ────────────────────────────────────────
              _SignalMiniBar(
                label: 'Google',
                score: item.googleScore,
                color: AppTheme.googleColor,
                sz: sz,
              ),
              SizedBox(height: sz.s(6)),
              _SignalMiniBar(
                label: 'Market',
                score: item.marketplaceScore,
                color: AppTheme.marketplaceColor,
                sz: sz,
              ),
              SizedBox(height: sz.s(6)),
              _SignalMiniBar(
                label: 'Pinterest',
                score: item.pinterestScore,
                color: AppTheme.pinterestColor,
                sz: sz,
              ),
              SizedBox(height: sz.s(14)),
              // ── Bottom row ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RecommendationChip(
                    recommendation: item.recommendation,
                    adjustmentPct: item.adjustmentPct,
                  ),
                  Container(
                    width: sz.s(28),
                    height: sz.s(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: sz.s(12),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _classificationIcon(String c) {
    switch (c) {
      case 'Accelerating':
        return Icons.trending_up_rounded;
      case 'Emerging':
        return Icons.rocket_launch_rounded;
      case 'Stable':
        return Icons.horizontal_rule_rounded;
      case 'Declining':
        return Icons.trending_down_rounded;
      default:
        return Icons.bar_chart_rounded;
    }
  }

  String _formatKeyword(String keyword) {
    return keyword
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

// ── Classification badge ───────────────────────────────────────────
class _ClassificationBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ClassificationBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sz.s(8), vertical: sz.s(3)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: sz.sp(8.5),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

// ── Signal mini bar ────────────────────────────────────────────────
class _SignalMiniBar extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  final AppSizes sz;

  const _SignalMiniBar({
    required this.label,
    required this.score,
    required this.color,
    required this.sz,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (score / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        // Dot indicator
        Container(
          width: sz.s(6),
          height: sz.s(6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: sz.s(7)),
        SizedBox(
          width: sz.s(46),
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: sz.sp(10),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withOpacity(0.80),
              ),
              minHeight: 5,
            ),
          ),
        ),
        SizedBox(width: sz.s(8)),
        SizedBox(
          width: sz.s(26),
          child: Text(
            score.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: sz.sp(10.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
