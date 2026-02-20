// lib/models/trend_summary.dart

class TrendSummary {
  final String keyword;
  final double trendScore;
  final String classification;
  final String recommendation;
  final int adjustmentPct;
  final double googleScore;
  final double marketplaceScore;
  final double pinterestScore;

  TrendSummary({
    required this.keyword,
    required this.trendScore,
    required this.classification,
    required this.recommendation,
    required this.adjustmentPct,
    required this.googleScore,
    required this.marketplaceScore,
    required this.pinterestScore,
  });

  factory TrendSummary.fromJson(Map<String, dynamic> json) {
    final signals = json['signals'] as Map<String, dynamic>? ?? {};
    return TrendSummary(
      keyword: json['keyword'] as String? ?? '',
      trendScore: (json['trend_score'] as num?)?.toDouble() ?? 0.0,
      classification: json['classification'] as String? ?? 'Stable',
      recommendation: json['recommendation'] as String? ?? 'Maintain',
      adjustmentPct: (json['adjustment_pct'] as num?)?.toInt() ?? 0,
      googleScore: (signals['google_trends_score'] as num?)?.toDouble() ?? 50.0,
      marketplaceScore:
          (signals['marketplace_score'] as num?)?.toDouble() ?? 50.0,
      pinterestScore: (signals['pinterest_score'] as num?)?.toDouble() ?? 50.0,
    );
  }
}
