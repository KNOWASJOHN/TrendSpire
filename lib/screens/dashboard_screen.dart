// lib/screens/dashboard_screen.dart

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
      body: SafeArea(
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
                  final items = snapshot.data!;
                  return _buildBody(items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    final sz = AppSizes(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, 16, sz.hPad, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TrendWise',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: sz.sp(22),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Men's Casual · India",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: sz.sp(12),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.search_rounded,
            onTap: () {},
          ),
          SizedBox(width: sz.s(8)),
          _HeaderIconButton(
            icon: Icons.refresh_rounded,
            onTap: _refresh,
          ),
          SizedBox(width: sz.s(8)),
          Container(
            width: sz.s(34),
            height: sz.s(34),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'TW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sz.sp(11),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body (stats + filters + list) ───────────────────────────
  Widget _buildBody(List<TrendSummary> items) {
    final filtered = _applyFilter(items);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatCards(items)),
        SliverToBoxAdapter(child: _buildSectionHeader(filtered.length)),
        SliverToBoxAdapter(child: _buildFilterRow()),
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No keywords in "$_activeFilter" right now.',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ScoreCard(
                  item: filtered[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(keyword: filtered[index].keyword),
                      ),
                    );
                  },
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  // ── Summary stat cards (horizontal scroll) ───────────────────
  Widget _buildStatCards(List<TrendSummary> items) {
    final total = items.length;
    final accelerating = items.where((i) => i.classification == 'Accelerating').length;
    final emerging = items.where((i) => i.classification == 'Emerging').length;
    final declining = items.where((i) => i.classification == 'Declining').length;

    final cards = [
      _StatData(
        label: 'Total Trends',
        value: '$total',
        sub: 'Keywords tracked',
        color: AppTheme.accent,
        icon: Icons.bar_chart_rounded,
        isDark: true,
      ),
      _StatData(
        label: 'Accelerating',
        value: '$accelerating',
        sub: total > 0 ? '${(accelerating / total * 100).toStringAsFixed(0)}% of total' : '—',
        color: AppTheme.accelerating,
        icon: Icons.trending_up_rounded,
      ),
      _StatData(
        label: 'Emerging',
        value: '$emerging',
        sub: total > 0 ? '${(emerging / total * 100).toStringAsFixed(0)}% of total' : '—',
        color: AppTheme.emerging,
        icon: Icons.rocket_launch_rounded,
      ),
      _StatData(
        label: 'Declining',
        value: '$declining',
        sub: total > 0 ? '${(declining / total * 100).toStringAsFixed(0)}% of total' : '—',
        color: AppTheme.declining,
        icon: Icons.trending_down_rounded,
      ),
    ];

    final sz = AppSizes(context);
    return SizedBox(
      height: sz.statRowH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(18), sz.hPad, 0),
        itemCount: cards.length,
        separatorBuilder: (_, __) => SizedBox(width: sz.s(10)),
        itemBuilder: (_, i) => _StatCard(data: cards[i]),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────
  Widget _buildSectionHeader(int count) {
    final sz = AppSizes(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(22), sz.hPad, 0),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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

  // ── Filter chips ─────────────────────────────────────────────
  Widget _buildFilterRow() {
    final sz = AppSizes(context);
    return SizedBox(
      height: sz.s(50),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(sz.hPad, sz.s(11), sz.hPad, 0),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: sz.s(7)),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final isActive = f == _activeFilter;
          final color = f == 'All'
              ? AppTheme.accent
              : AppTheme.classificationColor(f);
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: sz.s(sz.isSmall ? 11 : 13),
                vertical: sz.s(5),
              ),
              decoration: BoxDecoration(
                color: isActive ? color : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : AppTheme.border,
                  width: 1,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontSize: sz.sp(12),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Loading shimmer ──────────────────────────────────────────
  Widget _buildLoadingShimmer() {
    final sz = AppSizes(context);
    return ListView.builder(
      padding: EdgeInsets.only(top: sz.s(14)),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: sz.cardMarginH,
          vertical: sz.cardGap,
        ),
        height: sz.s(148),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.declining.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: AppTheme.declining,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not reach the server',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure your backend is running\nand your internet is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
}

// ── Supporting: header icon button ──────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sz.s(34),
        height: sz.s(34),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: sz.s(17)),
      ),
    );
  }
}

// ── Supporting: stat card data model ────────────────────────────
class _StatData {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatData({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
    this.isDark = false,
  });
}

// ── Supporting: stat card widget ────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final sz = AppSizes(context);
    return Container(
      width: sz.statCardW,
      padding: EdgeInsets.all(sz.s(12)),
      decoration: BoxDecoration(
        color: data.isDark ? const Color(0xFF1A1530) : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isDark ? data.color.withOpacity(0.3) : AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: data.isDark
                ? data.color.withOpacity(0.08)
                : const Color(0x10000000),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
                        ? AppTheme.textPrimary.withOpacity(0.7)
                        : AppTheme.textSecondary,
                    fontSize: sz.sp(10),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: sz.s(4)),
              Container(
                width: sz.s(26),
                height: sz.s(26),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: sz.s(13)),
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
                  fontSize: sz.sp(22),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: sz.s(2)),
              Text(
                data.sub,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: data.isDark
                      ? AppTheme.textPrimary.withOpacity(0.5)
                      : AppTheme.textMuted,
                  fontSize: sz.sp(9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple animated shimmer placeholder
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight.withOpacity(_animation.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
