import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/biens/domain/entities/bien_summary.dart';
import '../constants/constants.dart';

@lazySingleton
class LocalCacheService {
  static const _recentBiensKey = AppConstants.recentBiensKey;
  static const _lastScannedBienKey = AppConstants.lastScannedBienKey;
  static const _recentPannesKey = AppConstants.recentPannesKey;
  static const _recentMaintenancesKey = AppConstants.recentMaintenancesKey;
  static const _maxRecentBiens = 10;

  Future<void> saveCachedPannes(List<Map<String, dynamic>> pannesJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentPannesKey, jsonEncode(pannesJson));
  }

  Future<List<Map<String, dynamic>>> getCachedPannes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentPannesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedMaintenances(List<Map<String, dynamic>> maintenancesJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentMaintenancesKey, jsonEncode(maintenancesJson));
  }

  Future<List<Map<String, dynamic>>> getCachedMaintenances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentMaintenancesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

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

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => BienSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<BienSummary?> getLastScannedBien() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastScannedBienKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BienSummary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentBiensKey);
    await prefs.remove(_lastScannedBienKey);
    await prefs.remove(_recentPannesKey);
    await prefs.remove(_recentMaintenancesKey);
  }
}
