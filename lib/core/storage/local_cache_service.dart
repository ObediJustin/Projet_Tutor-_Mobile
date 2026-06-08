import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/biens/domain/entities/bien_summary.dart';
import '../constants/constants.dart';

@lazySingleton
class LocalCacheService {
  static const _recentBiensKey = AppConstants.recentBiensKey;
  static const _lastScannedBienKey = AppConstants.lastScannedBienKey;
  static const _maxRecentBiens = 10;

  Future<void> saveRecentBien(BienSummary bien) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await getRecentBiens();

    final updated = [
      bien,
      ...recent.where((item) => item.idBien != bien.idBien),
    ].take(_maxRecentBiens).toList();

    await prefs.setString(
      _recentBiensKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_lastScannedBienKey, jsonEncode(bien.toJson()));
  }

  Future<List<BienSummary>> getRecentBiens() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentBiensKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => BienSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BienSummary?> getLastScannedBien() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastScannedBienKey);
    if (raw == null || raw.isEmpty) return null;
    return BienSummary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentBiensKey);
    await prefs.remove(_lastScannedBienKey);
  }
}
