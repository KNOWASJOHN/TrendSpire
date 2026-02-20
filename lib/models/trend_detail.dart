// lib/models/trend_detail.dart

class GoogleSignal {
  final double currentInterest;
  final double fourWeekAvg;
  final double growthPct;
  final double normalizedScore;
  final String source;

  GoogleSignal({
    required this.currentInterest,
    required this.fourWeekAvg,
    required this.growthPct,
    required this.normalizedScore,
    required this.source,
  });

  factory GoogleSignal.fromJson(Map<String, dynamic> json) {
    return GoogleSignal(
      currentInterest: (json['current_interest'] as num?)?.toDouble() ?? 50.0,
      fourWeekAvg: (json['four_week_avg'] as num?)?.toDouble() ?? 50.0,
      growthPct: (json['growth_pct'] as num?)?.toDouble() ?? 0.0,
      normalizedScore: (json['normalized_score'] as num?)?.toDouble() ?? 50.0,
      source: json['source'] as String? ?? 'fallback',
    );
  }
}

class MarketplaceSignal {
  final int currentRank;
  final int rank7dAgo;
  final double rankVelocity;
  final double salesGrowthPct;
  final double normalizedScore;

  MarketplaceSignal({
    required this.currentRank,
    required this.rank7dAgo,
    required this.rankVelocity,
    required this.salesGrowthPct,
    required this.normalizedScore,
  });

  factory MarketplaceSignal.fromJson(Map<String, dynamic> json) {
    return MarketplaceSignal(
      currentRank: (json['current_rank'] as num?)?.toInt() ?? 50,
      rank7dAgo: (json['rank_7d_ago'] as num?)?.toInt() ?? 50,
      rankVelocity: (json['rank_velocity'] as num?)?.toDouble() ?? 0.0,
      salesGrowthPct: (json['sales_growth_pct'] as num?)?.toDouble() ?? 0.0,
      normalizedScore: (json['normalized_score'] as num?)?.toDouble() ?? 50.0,
    );
  }
}

class PinterestSignal {
  final int weeklySaves;
  final double saveGrowthPct;
  final int boardCount;
  final double boardGrowthPct;
  final double normalizedScore;

  PinterestSignal({
    required this.weeklySaves,
    required this.saveGrowthPct,
    required this.boardCount,
    required this.boardGrowthPct,
    required this.normalizedScore,
  });

  factory PinterestSignal.fromJson(Map<String, dynamic> json) {
    return PinterestSignal(
      weeklySaves: (json['weekly_saves'] as num?)?.toInt() ?? 0,
      saveGrowthPct: (json['save_growth_pct'] as num?)?.toDouble() ?? 0.0,
      boardCount: (json['board_count'] as num?)?.toInt() ?? 0,
      boardGrowthPct: (json['board_growth_pct'] as num?)?.toDouble() ?? 0.0,
      normalizedScore: (json['normalized_score'] as num?)?.toDouble() ?? 50.0,
    );
  }
}

class TrendDetail {
  final String keyword;
  final double trendScore;
  final String classification;
  final String recommendation;
  final int adjustmentPct;
  final String explanation;
  final GoogleSignal googleSignal;
  final MarketplaceSignal marketplaceSignal;
  final PinterestSignal pinterestSignal;
  final String generatedAt;
  final bool cached;

  TrendDetail({
    required this.keyword,
    required this.trendScore,
    required this.classification,
    required this.recommendation,
    required this.adjustmentPct,
    required this.explanation,
    required this.googleSignal,
    required this.marketplaceSignal,
    required this.pinterestSignal,
    required this.generatedAt,
    required this.cached,
  });

  factory TrendDetail.fromJson(Map<String, dynamic> json) {
    final signals = json['signals'] as Map<String, dynamic>? ?? {};
    return TrendDetail(
      keyword: json['keyword'] as String? ?? '',
      trendScore: (json['trend_score'] as num?)?.toDouble() ?? 0.0,
      classification: json['classification'] as String? ?? 'Stable',
      recommendation: json['recommendation'] as String? ?? 'Maintain',
      adjustmentPct: (json['adjustment_pct'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      generatedAt: json['generated_at'] as String? ?? '',
      cached: json['cached'] as bool? ?? false,
      googleSignal: GoogleSignal.fromJson(
        signals['google_trends'] as Map<String, dynamic>? ?? {},
      ),
      marketplaceSignal: MarketplaceSignal.fromJson(
        signals['marketplace'] as Map<String, dynamic>? ?? {},
      ),
      pinterestSignal: PinterestSignal.fromJson(
        signals['pinterest'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
