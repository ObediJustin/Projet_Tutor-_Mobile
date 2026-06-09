import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/piece_rechange_model.dart';

abstract class PiecesLocalDataSource {
  Future<List<PieceRechangeModel>> getCachedPieces();
  Future<void> cachePieces(List<PieceRechangeModel> pieces);
}

@LazySingleton(as: PiecesLocalDataSource)
class PiecesLocalDataSourceImpl implements PiecesLocalDataSource {
  PiecesLocalDataSourceImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
  static const cachedPiecesKey = 'CACHED_PIECES';

  @override
  Future<List<PieceRechangeModel>> getCachedPieces() {
    final jsonString = sharedPreferences.getString(cachedPiecesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((json) => PieceRechangeModel.fromJson(json)).toList());
    } else {
      throw CacheException(message: 'Aucune donnée en cache');
    }
  }

  @override
  Future<void> cachePieces(List<PieceRechangeModel> pieces) {
    final jsonList = pieces.map((piece) => piece.toJson()).toList();
    return sharedPreferences.setString(
      cachedPiecesKey,
      json.encode(jsonList),
    );
  }
}
