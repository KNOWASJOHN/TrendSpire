// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trend_summary.dart';
import '../models/trend_detail.dart';

class ApiService {
  // ─── CHANGE THIS to your actual Render URL ────────────────────
  static const String _baseUrl = 'http://127.0.0.1:5000';
  // ──────────────────────────────────────────────────────────────

  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches the summary list for all 15 keywords.
  /// Used by the Dashboard screen.
  Future<List<TrendSummary>> fetchSummary() async {
    final uri = Uri.parse('$_baseUrl/api/trends/summary');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final dataList = body['data'] as List<dynamic>;
        return dataList
            .map((item) => TrendSummary.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch summary: $e');
    }
  }

  /// Fetches the full breakdown for one keyword.
  /// Used by the Detail screen.
  Future<TrendDetail> fetchDetail(String keyword) async {
    final uri = Uri.parse(
      '$_baseUrl/api/trends/detail?keyword=${Uri.encodeComponent(keyword)}',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return TrendDetail.fromJson(body);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch detail for "$keyword": $e');
    }
  }

  /// Checks if the backend is alive.
  /// Call this at app startup to confirm the server is awake.
  Future<bool> checkHealth() async {
    final uri = Uri.parse('$_baseUrl/api/health');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
