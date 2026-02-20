// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import '../models/trend_detail.dart';
import '../services/api_service.dart';
import '../theme/app_sizes.dart';
import '../theme/app_theme.dart';
import '../widgets/recommendation_chip.dart';
import '../widgets/signal_bar.dart';
import '../widgets/score_ring.dart';

class DetailScreen extends StatefulWidget {
  final String keyword;

  const DetailScreen({super.key, required this.keyword});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<TrendDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = ApiService().fetchDetail(widget.keyword);
  }

  String _formatKeyword(String keyword) {
    return keyword
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _formatKeyword(widget.keyword),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<TrendDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No data',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(TrendDetail detail) {
    final sz = AppSizes(context);
    final classColor = AppTheme.classificationColor(detail.classification);

    return SingleChildScrollView(
      padding: EdgeInsets.all(sz.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score ring + classification ──────────────────────
          Center(
            child: Column(
              children: [
                ScoreRing(
                  score: detail.trendScore,
                  classification: detail.classification,
                  size: sz.scoreRingSize,
                ),
                SizedBox(height: sz.s(14)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sz.s(14),
                    vertical: sz.s(6),
                  ),
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: classColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    detail.classification.toUpperCase(),
                    style: TextStyle(
                      color: classColor,
                      fontSize: sz.sp(12),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: sz.s(10)),
                RecommendationChip(
                  recommendation: detail.recommendation,
                  adjustmentPct: detail.adjustmentPct,
                  large: true,
                ),
              ],
            ),
          ),
          SizedBox(height: sz.s(24)),

          // ── Explanation ──────────────────────────────────────
          _sectionLabel('Why This Recommendation'),
          SizedBox(height: sz.s(9)),
          Container(
            padding: EdgeInsets.all(sz.cardPad),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              detail.explanation,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: sz.sp(13.5),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: sz.s(24)),

          // ── Signal scores ─────────────────────────────────────
          _sectionLabel('Signal Scores'),
          SizedBox(height: sz.s(12)),
          _buildSignalCard(
            icon: Icons.search_rounded,
            title: 'Google Trends',
            color: AppTheme.googleColor,
            weight: '45%',
            child: Column(
              children: [
                SignalBar(
                  label: 'Current Interest',
                  score: detail.googleSignal.normalizedScore,
                  color: AppTheme.googleColor,
                  subtitle: detail.googleSignal.source == 'live'
                      ? 'Live data'
                      : 'Fallback (rate limited)',
                ),
                const SizedBox(height: 20),
                _statRow(
                  'Current Week Score',
                  detail.googleSignal.currentInterest.toStringAsFixed(1),
                ),
                _statRow(
                  '4-Week Average',
                  detail.googleSignal.fourWeekAvg.toStringAsFixed(1),
                ),
                _statRow(
                  'Growth vs Avg',
                  _formatGrowth(detail.googleSignal.growthPct),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSignalCard(
            icon: Icons.storefront_rounded,
            title: 'Marketplace',
            color: AppTheme.marketplaceColor,
            weight: '35%',
            child: Column(
              children: [
                SignalBar(
                  label: 'Velocity Score',
                  score: detail.marketplaceSignal.normalizedScore,
                  color: AppTheme.marketplaceColor,
                  subtitle: 'Rank change + sales growth',
                ),
                const SizedBox(height: 20),
                _statRow(
                  'Current Rank',
                  '#${detail.marketplaceSignal.currentRank}',
                ),
                _statRow(
                  'Rank 7 Days Ago',
                  '#${detail.marketplaceSignal.rank7dAgo}',
                ),
                _statRow(
                  'Rank Change',
                  _formatRankChange(detail.marketplaceSignal.rankVelocity),
                ),
                _statRow(
                  'Sales Growth',
                  _formatGrowth(detail.marketplaceSignal.salesGrowthPct),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSignalCard(
            icon: Icons.push_pin_rounded,
            title: 'Pinterest',
            color: AppTheme.pinterestColor,
            weight: '20%',
            child: Column(
              children: [
                SignalBar(
                  label: 'Engagement Score',
                  score: detail.pinterestSignal.normalizedScore,
                  color: AppTheme.pinterestColor,
                  subtitle: 'Save + board growth',
                ),
                const SizedBox(height: 20),
                _statRow(
                  'Weekly Saves',
                  _formatNumber(detail.pinterestSignal.weeklySaves),
                ),
                _statRow(
                  'Save Growth',
                  _formatGrowth(detail.pinterestSignal.saveGrowthPct),
                ),
                _statRow(
                  'Active Boards',
                  detail.pinterestSignal.boardCount.toString(),
                ),
                _statRow(
                  'Board Growth',
                  _formatGrowth(detail.pinterestSignal.boardGrowthPct),
                ),
              ],
            ),
          ),
          SizedBox(height: sz.s(24)),

          // ── Formula breakdown ─────────────────────────────────
          _sectionLabel('Score Formula'),
          SizedBox(height: sz.s(10)),
          Container(
            padding: EdgeInsets.all(sz.cardPad),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _formulaRow(
                  'Google (45%)',
                  detail.googleSignal.normalizedScore,
                  0.45,
                  AppTheme.googleColor,
                ),
                const Divider(color: AppTheme.border, height: 20),
                _formulaRow(
                  'Marketplace (35%)',
                  detail.marketplaceSignal.normalizedScore,
                  0.35,
                  AppTheme.marketplaceColor,
                ),
                const Divider(color: AppTheme.border, height: 20),
                _formulaRow(
                  'Pinterest (20%)',
                  detail.pinterestSignal.normalizedScore,
                  0.20,
                  AppTheme.pinterestColor,
                ),
                const Divider(color: AppTheme.border, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trend Momentum Score',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      detail.trendScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppTheme.classificationColor(
                          detail.classification,
                        ),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Cache status indicator
          Row(
            children: [
              Icon(
                detail.cached ? Icons.bolt_rounded : Icons.cloud_done_rounded,
                size: 12,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                detail.cached ? 'Served from cache' : 'Live data',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalCard({
    required IconData icon,
    required String title,
    required Color color,
    required String weight,
    required Widget child,
  }) {
    final sz = AppSizes(context);
    return Container(
      padding: EdgeInsets.all(sz.cardPad),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: sz.s(15), color: color),
              SizedBox(width: sz.s(7)),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: sz.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sz.s(7),
                  vertical: sz.s(2),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Weight: $weight',
                  style: TextStyle(
                    color: color,
                    fontSize: sz.sp(10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sz.s(14)),
          child,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    final sz = AppSizes(context);
    return Padding(
      padding: EdgeInsets.only(bottom: sz.s(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: sz.sp(12),
              ),
            ),
          ),
          SizedBox(width: sz.s(8)),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: sz.sp(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formulaRow(String label, double score, double weight, Color color) {
    final sz = AppSizes(context);
    final contribution = score * weight;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: sz.sp(11.5),
            ),
          ),
        ),
        Text(
          '${score.toStringAsFixed(1)} × $weight',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: sz.sp(11.5),
          ),
        ),
        SizedBox(width: sz.s(8)),
        Text(
          '= ${contribution.toStringAsFixed(1)}',
          style: TextStyle(
            color: color,
            fontSize: sz.sp(12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    final sz = AppSizes(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sz.s(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sz.s(60),
              height: sz.s(60),
              decoration: BoxDecoration(
                color: AppTheme.declining.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: sz.s(30),
                color: AppTheme.declining,
              ),
            ),
            SizedBox(height: sz.s(18)),
            Text(
              'Failed to load details',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: sz.sp(16),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: sz.s(8)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: sz.sp(12),
              ),
            ),
            SizedBox(height: sz.s(22)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGrowth(double pct) {
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  String _formatRankChange(double velocity) {
    if (velocity > 0) return '+${velocity.toStringAsFixed(0)} positions ↑';
    if (velocity < 0) return '${velocity.toStringAsFixed(0)} positions ↓';
    return 'No change';
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
