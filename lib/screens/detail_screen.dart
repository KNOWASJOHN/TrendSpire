// lib/screens/detail_screen.dart

import 'dart:ui';
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

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<TrendDetail> _detailFuture;
  late TabController _tabController;

  static const _tabs = ['Google', 'Marketplace', 'Pinterest'];

  @override
  void initState() {
    super.initState();
    _detailFuture = ApiService().fetchDetail(widget.keyword);
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatKeyword(String keyword) {
    return keyword
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Ambient orbs ──────────────────────────────────────
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentSoft.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.emerging.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(sz),
                Expanded(
                  child: FutureBuilder<TrendDetail>(
                    future: _detailFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                            strokeWidth: 2.5,
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return _buildError(snap.error.toString(), sz);
                      }
                      if (!snap.hasData) {
                        return const Center(
                          child: Text(
                            'No data',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        );
                      }
                      return _buildContent(snap.data!, sz);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────
  Widget _buildAppBar(AppSizes sz) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(12), sz.hPad, sz.s(10)),
      child: Row(
        children: [
          // Back button — glass pill
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(sz.s(12)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: sz.s(38),
                  height: sz.s(38),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(sz.s(12)),
                    border: Border.all(color: AppTheme.border.withOpacity(0.7)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
          Expanded(
            child: Center(
              child: Text(
                _formatKeyword(widget.keyword),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: sz.sp(16),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          // More options glass pill
          ClipRRect(
            borderRadius: BorderRadius.circular(sz.s(12)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: sz.s(38),
                height: sz.s(38),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(sz.s(12)),
                  border: Border.all(color: AppTheme.border.withOpacity(0.7)),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────
  Widget _buildContent(TrendDetail detail, AppSizes sz) {
    final classColor = AppTheme.classificationColor(detail.classification);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: sz.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score ring on glass card ────────────────────────
          _buildScoreCard(detail, classColor, sz),
          SizedBox(height: sz.s(20)),
          // ── Segmented tab selector ──────────────────────────
          _buildSegmentedTabs(sz),
          SizedBox(height: sz.s(16)),
          // ── Tab content ─────────────────────────────────────
          _buildTabViews(detail, sz),
          SizedBox(height: sz.s(20)),
          // ── Why this recommendation ─────────────────────────
          _sectionLabel('Why This Recommendation', sz),
          SizedBox(height: sz.s(10)),
          _buildExplanationCard(detail, sz),
          SizedBox(height: sz.s(20)),
          // ── Formula breakdown ───────────────────────────────
          _sectionLabel('Score Formula', sz),
          SizedBox(height: sz.s(10)),
          _buildFormulaCard(detail, sz),
          SizedBox(height: sz.s(20)),
          // ── Cache indicator ─────────────────────────────────
          Row(
            children: [
              Icon(
                detail.cached ? Icons.bolt_rounded : Icons.cloud_done_rounded,
                size: 12,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                detail.cached ? 'Served from cache' : 'Live data',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
          SizedBox(height: sz.s(16)),
          // ── CTA button ──────────────────────────────────────
          _buildCTAButton(sz),
          SizedBox(height: sz.s(36)),
        ],
      ),
    );
  }

  // ── Glass score card ───────────────────────────────────────────
  Widget _buildScoreCard(TrendDetail detail, Color classColor, AppSizes sz) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: sz.s(28),
            horizontal: sz.s(20),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: classColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ScoreRing(
                score: detail.trendScore,
                classification: detail.classification,
                size: sz.scoreRingSize,
              ),
              SizedBox(height: sz.s(18)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sz.s(14),
                      vertical: sz.s(6),
                    ),
                    decoration: BoxDecoration(
                      color: classColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: classColor.withOpacity(0.30)),
                    ),
                    child: Text(
                      detail.classification.toUpperCase(),
                      style: TextStyle(
                        color: classColor,
                        fontSize: sz.sp(11),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: sz.s(10)),
                  RecommendationChip(
                    recommendation: detail.recommendation,
                    adjustmentPct: detail.adjustmentPct,
                    large: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Segmented tab control ──────────────────────────────────────
  Widget _buildSegmentedTabs(AppSizes sz) {
    return Container(
      height: sz.s(44),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          return Row(
            children: List.generate(_tabs.length, (i) {
              final isActive = _tabController.index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabController.animateTo(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accentDark
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.accentDark.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: sz.sp(12.5),
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ── Tab views ─────────────────────────────────────────────────
  Widget _buildTabViews(TrendDetail detail, AppSizes sz) {
    final tab = _tabController.index;
    switch (tab) {
      case 0:
        return _buildSignalPanel(
          icon: Icons.search_rounded,
          title: 'Google Trends',
          color: AppTheme.googleColor,
          weight: '45%',
          sz: sz,
          children: [
            SignalBar(
              label: 'Current Interest',
              score: detail.googleSignal.normalizedScore,
              color: AppTheme.googleColor,
              subtitle: detail.googleSignal.source == 'live'
                  ? 'Live data'
                  : 'Fallback (rate limited)',
            ),
            SizedBox(height: sz.s(16)),
            _statRow(
              'Current Week Score',
              detail.googleSignal.currentInterest.toStringAsFixed(1),
              sz,
            ),
            _statRow(
              '4-Week Average',
              detail.googleSignal.fourWeekAvg.toStringAsFixed(1),
              sz,
            ),
            _statRow(
              'Growth vs Avg',
              _formatGrowth(detail.googleSignal.growthPct),
              sz,
            ),
          ],
        );
      case 1:
        return _buildSignalPanel(
          icon: Icons.storefront_rounded,
          title: 'Marketplace',
          color: AppTheme.marketplaceColor,
          weight: '35%',
          sz: sz,
          children: [
            SignalBar(
              label: 'Velocity Score',
              score: detail.marketplaceSignal.normalizedScore,
              color: AppTheme.marketplaceColor,
              subtitle: 'Rank change + sales growth',
            ),
            SizedBox(height: sz.s(16)),
            _statRow(
              'Current Rank',
              '#${detail.marketplaceSignal.currentRank}',
              sz,
            ),
            _statRow(
              'Rank 7 Days Ago',
              '#${detail.marketplaceSignal.rank7dAgo}',
              sz,
            ),
            _statRow(
              'Rank Change',
              _formatRankChange(detail.marketplaceSignal.rankVelocity),
              sz,
            ),
            _statRow(
              'Sales Growth',
              _formatGrowth(detail.marketplaceSignal.salesGrowthPct),
              sz,
            ),
          ],
        );
      case 2:
      default:
        return _buildSignalPanel(
          icon: Icons.push_pin_rounded,
          title: 'Pinterest',
          color: AppTheme.pinterestColor,
          weight: '20%',
          sz: sz,
          children: [
            SignalBar(
              label: 'Engagement Score',
              score: detail.pinterestSignal.normalizedScore,
              color: AppTheme.pinterestColor,
              subtitle: 'Save + board growth',
            ),
            SizedBox(height: sz.s(16)),
            _statRow(
              'Weekly Saves',
              _formatNumber(detail.pinterestSignal.weeklySaves),
              sz,
            ),
            _statRow(
              'Save Growth',
              _formatGrowth(detail.pinterestSignal.saveGrowthPct),
              sz,
            ),
            _statRow(
              'Active Boards',
              detail.pinterestSignal.boardCount.toString(),
              sz,
            ),
            _statRow(
              'Board Growth',
              _formatGrowth(detail.pinterestSignal.boardGrowthPct),
              sz,
            ),
          ],
        );
    }
  }

  // ── Signal panel — glass card ──────────────────────────────────
  Widget _buildSignalPanel({
    required IconData icon,
    required String title,
    required Color color,
    required String weight,
    required AppSizes sz,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(sz.s(16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: sz.s(32),
                    height: sz.s(32),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: sz.s(15), color: color),
                  ),
                  SizedBox(width: sz.s(10)),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: sz.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sz.s(8),
                      vertical: sz.s(3),
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Weight $weight',
                      style: TextStyle(
                        color: color,
                        fontSize: sz.sp(9.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sz.s(16)),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // ── Explanation card ───────────────────────────────────────────
  Widget _buildExplanationCard(TrendDetail detail, AppSizes sz) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(sz.s(16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            detail.explanation,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: sz.sp(13.5),
              height: 1.65,
            ),
          ),
        ),
      ),
    );
  }

  // ── Formula card ───────────────────────────────────────────────
  Widget _buildFormulaCard(TrendDetail detail, AppSizes sz) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(sz.s(16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                sz,
              ),
              Divider(
                color: AppTheme.border.withOpacity(0.60),
                height: sz.s(22),
              ),
              _formulaRow(
                'Marketplace (35%)',
                detail.marketplaceSignal.normalizedScore,
                0.35,
                AppTheme.marketplaceColor,
                sz,
              ),
              Divider(
                color: AppTheme.border.withOpacity(0.60),
                height: sz.s(22),
              ),
              _formulaRow(
                'Pinterest (20%)',
                detail.pinterestSignal.normalizedScore,
                0.20,
                AppTheme.pinterestColor,
                sz,
              ),
              Divider(
                color: AppTheme.border.withOpacity(0.60),
                height: sz.s(22),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trend Momentum Score',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: sz.sp(13),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    detail.trendScore.toStringAsFixed(1),
                    style: TextStyle(
                      color: AppTheme.classificationColor(
                        detail.classification,
                      ),
                      fontSize: sz.sp(18),
                      fontWeight: FontWeight.w800,
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

  // ── Dark CTA button ────────────────────────────────────────────
  Widget _buildCTAButton(AppSizes sz) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: () {}, // future: export or share report
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: sz.s(16)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1C28), Color(0xFF2C2C3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentDark.withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: sz.s(8)),
                Text(
                  'VIEW FULL REPORT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sz.sp(13),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────
  Widget _sectionLabel(String text, AppSizes sz) {
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
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: sz.sp(10.5),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, AppSizes sz) {
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

  Widget _formulaRow(
    String label,
    double score,
    double weight,
    Color color,
    AppSizes sz,
  ) {
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
          '= ${(score * weight).toStringAsFixed(1)}',
          style: TextStyle(
            color: color,
            fontSize: sz.sp(12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error, AppSizes sz) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sz.s(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassCard(
              radius: 22,
              blur: 14,
              tint: AppTheme.declining,
              tintOpacity: 0.08,
              padding: EdgeInsets.all(sz.s(16)),
              child: Icon(
                Icons.error_outline_rounded,
                size: sz.s(34),
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sz.s(24),
                  vertical: sz.s(13),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentDark,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sz.sp(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
