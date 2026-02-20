// lib/screens/dashboard_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/trend_summary.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_sizes.dart';
import '../widgets/score_card.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<TrendSummary>> _summaryFuture;
  String _activeFilter = 'All';

  final _filters = ['All', 'Accelerating', 'Emerging', 'Stable', 'Declining'];

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService().fetchSummary();
  }

  void _refresh() {
    setState(() {
      _summaryFuture = ApiService().fetchSummary();
    });
  }

  List<TrendSummary> _applyFilter(List<TrendSummary> items) {
    if (_activeFilter == 'All') return items;
    return items.where((i) => i.classification == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Ambient gradient orbs ──────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accelerating.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<TrendSummary>>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingShimmer();
                      }
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildBody(snapshot.data!);
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

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    final sz = AppSizes(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(16), sz.hPad, sz.s(12)),
      child: Row(
        children: [
          // App name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TrendWise',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: sz.sp(24),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                Text(
                  "Men's Casual · India",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: sz.sp(12),
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          _GlassIconButton(icon: Icons.refresh_rounded, onTap: _refresh),
          SizedBox(width: sz.s(8)),
          // Notification
          _GlassIconButton(icon: Icons.notifications_outlined, onTap: () {}),
          SizedBox(width: sz.s(8)),
          // Avatar — dark glass pill
          ClipRRect(
            borderRadius: BorderRadius.circular(sz.s(12)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: sz.s(36),
                height: sz.s(36),
                decoration: BoxDecoration(
                  color: AppTheme.accentDark,
                  borderRadius: BorderRadius.circular(sz.s(12)),
                ),
                child: Center(
                  child: Text(
                    'TW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sz.sp(11),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body: dark banner + stat grid + filters + list ─────────────
  Widget _buildBody(List<TrendSummary> items) {
    final filtered = _applyFilter(items);
    final sz = AppSizes(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Dark banner card
        SliverToBoxAdapter(child: _buildBannerCard(items, sz)),
        // Stat 2×2 grid
        SliverToBoxAdapter(child: _buildStatGrid(items, sz)),
        // Section header
        SliverToBoxAdapter(child: _buildSectionHeader(filtered.length, sz)),
        // Filter tabs (segmented)
        SliverToBoxAdapter(child: _buildFilterRow(sz)),
        // List or empty
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No trends match "$_activeFilter"',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.only(bottom: sz.s(40)),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ScoreCard(
                  item: filtered[i],
                  onTap: () => Navigator.push(
                    context,
                    _fadeRoute(DetailScreen(keyword: filtered[i].keyword)),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  // ── Dark glassmorphism banner ──────────────────────────────────
  Widget _buildBannerCard(List<TrendSummary> items, AppSizes sz) {
    final best = items.isNotEmpty
        ? items.reduce((a, b) => a.trendScore > b.trendScore ? a : b)
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, 0, sz.hPad, sz.s(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(sz.s(18)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1C28), Color(0xFF2C2C3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Trend',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.50),
                          fontSize: sz.sp(11),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: sz.s(4)),
                      Text(
                        best != null
                            ? best.keyword
                                  .split(' ')
                                  .map(
                                    (w) => w.isEmpty
                                        ? w
                                        : w[0].toUpperCase() + w.substring(1),
                                  )
                                  .join(' ')
                            : '—',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sz.sp(20),
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: sz.s(8)),
                      if (best != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sz.s(10),
                            vertical: sz.s(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.20),
                            ),
                          ),
                          child: Text(
                            best.classification.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.90),
                              fontSize: sz.sp(9),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: sz.s(12)),
                // Big score ring (glass)
                _BannerScoreRing(score: best?.trendScore ?? 0, sz: sz),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 2×2 stat grid ─────────────────────────────────────────────
  Widget _buildStatGrid(List<TrendSummary> items, AppSizes sz) {
    final total = items.length;
    final acc = items.where((i) => i.classification == 'Accelerating').length;
    final em = items.where((i) => i.classification == 'Emerging').length;
    final dec = items.where((i) => i.classification == 'Declining').length;

    final stats = [
      _StatInfo(
        label: 'Total Trends',
        value: '$total',
        sub: 'Keywords tracked',
        color: AppTheme.accentDark,
        icon: Icons.bar_chart_rounded,
        isDark: true,
      ),
      _StatInfo(
        label: 'Accelerating',
        value: '$acc',
        sub: total > 0 ? '${(acc / total * 100).toStringAsFixed(0)}%' : '—',
        color: AppTheme.accelerating,
        icon: Icons.trending_up_rounded,
      ),
      _StatInfo(
        label: 'Emerging',
        value: '$em',
        sub: total > 0 ? '${(em / total * 100).toStringAsFixed(0)}%' : '—',
        color: AppTheme.emerging,
        icon: Icons.rocket_launch_rounded,
      ),
      _StatInfo(
        label: 'Declining',
        value: '$dec',
        sub: total > 0 ? '${(dec / total * 100).toStringAsFixed(0)}%' : '—',
        color: AppTheme.declining,
        icon: Icons.trending_down_rounded,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, 0, sz.hPad, sz.s(4)),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: sz.s(10),
        mainAxisSpacing: sz.s(10),
        childAspectRatio: 1.65,
        children: stats.map((s) => _StatCard(data: s)).toList(),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────
  Widget _buildSectionHeader(int count, AppSizes sz) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(6), sz.hPad, 0),
      child: Row(
        children: [
          Text(
            'Trend Overview',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: sz.sp(16),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(width: sz.s(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sz.s(8),
              vertical: sz.s(2),
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentDark,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: sz.sp(10.5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _refresh,
            child: Text(
              'Refresh',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: sz.sp(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Segmented filter tabs ──────────────────────────────────────
  Widget _buildFilterRow(AppSizes sz) {
    return SizedBox(
      height: sz.s(52),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(12), sz.hPad, 0),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: sz.s(6)),
        itemBuilder: (ctx, i) {
          final f = _filters[i];
          final isActive = f == _activeFilter;
          final activeColor = f == 'All'
              ? AppTheme.accentDark
              : AppTheme.classificationColor(f);

          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: sz.s(14),
                vertical: sz.s(5),
              ),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive ? activeColor : AppTheme.border,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontSize: sz.sp(12),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Loading shimmer ────────────────────────────────────────────
  Widget _buildLoadingShimmer() {
    final sz = AppSizes(context);
    return ListView.builder(
      padding: EdgeInsets.only(top: sz.s(12)),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: sz.cardMarginH,
          vertical: sz.s(5),
        ),
        height: sz.s(152),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border.withOpacity(0.6)),
        ),
        child: const _ShimmerBox(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final sz = AppSizes(context);
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
                Icons.wifi_off_rounded,
                size: sz.s(36),
                color: AppTheme.declining,
              ),
            ),
            SizedBox(height: sz.s(20)),
            Text(
              'Could not reach the server',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: sz.sp(17),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: sz.s(8)),
            Text(
              'Make sure your backend is running\nand your internet is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: sz.sp(13),
                height: 1.6,
              ),
            ),
            SizedBox(height: sz.s(28)),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sz.s(28),
                  vertical: sz.s(14),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentDark,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentDark.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: sz.s(8)),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sz.sp(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No data returned from server.',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  PageRoute _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}

// ── Banner score ring ─────────────────────────────────────────────
class _BannerScoreRing extends StatelessWidget {
  final double score;
  final AppSizes sz;
  const _BannerScoreRing({required this.score, required this.sz});

  @override
  Widget build(BuildContext context) {
    const size = 76.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              strokeWidth: 7,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.85),
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sz.sp(20),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                'TMS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: sz.sp(8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Glass header icon button ───────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sz.s(11)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: sz.s(36),
            height: sz.s(36),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(sz.s(11)),
              border: Border.all(
                color: AppTheme.border.withOpacity(0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: sz.s(16)),
          ),
        ),
      ),
    );
  }
}

// ── Stat info model ───────────────────────────────────────────────
class _StatInfo {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatInfo({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
    this.isDark = false,
  });
}

// ── Stat card with glass ──────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatInfo data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);

    if (data.isDark) {
      // Dark glass card
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.all(sz.s(12)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C1C28), Color(0xFF2A2A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _statCardContent(sz, Colors.white),
          ),
        ),
      );
    }

    // Light glass card
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(sz.s(12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.60), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _statCardContent(sz, AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _statCardContent(AppSizes sz, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                data.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: data.isDark
                      ? Colors.white.withOpacity(0.55)
                      : AppTheme.textSecondary,
                  fontSize: sz.sp(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: sz.s(4)),
            Container(
              width: sz.s(24),
              height: sz.s(24),
              decoration: BoxDecoration(
                color: data.isDark
                    ? Colors.white.withOpacity(0.12)
                    : data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                data.icon,
                color: data.isDark ? Colors.white : data.color,
                size: sz.s(12),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.value,
              style: TextStyle(
                color: data.isDark ? Colors.white : AppTheme.textPrimary,
                fontSize: sz.sp(24),
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
            Text(
              data.sub,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: data.isDark
                    ? Colors.white.withOpacity(0.40)
                    : AppTheme.textMuted,
                fontSize: sz.sp(9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shimmer ────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.35,
      end: 0.80,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.border.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
