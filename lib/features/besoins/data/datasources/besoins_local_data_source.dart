import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/besoin_model.dart';

abstract class BesoinsLocalDataSource {
  Future<List<BesoinModel>> getCachedBesoinsAValider();
  Future<void> cacheBesoinsAValider(List<BesoinModel> besoins);
}

@LazySingleton(as: BesoinsLocalDataSource)
class BesoinsLocalDataSourceImpl implements BesoinsLocalDataSource {
  BesoinsLocalDataSourceImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
  static const cachedBesoinsAValiderKey = 'CACHED_BESOINS_A_VALIDER';

  @override
  Future<List<BesoinModel>> getCachedBesoinsAValider() {
    final jsonString = sharedPreferences.getString(cachedBesoinsAValiderKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((json) => BesoinModel.fromJson(json)).toList());
    } else {
      throw CacheException(message: 'Aucune donnée en cache');
    }
  }

  @override
  Future<void> cacheBesoinsAValider(List<BesoinModel> besoins) {
    final jsonList = besoins.map((besoin) => besoin.toJson()).toList();
    return sharedPreferences.setString(
      cachedBesoinsAValiderKey,
      json.encode(jsonList),
    );
  }
}
