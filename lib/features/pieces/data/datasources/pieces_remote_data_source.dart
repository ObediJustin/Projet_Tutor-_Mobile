import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/piece_rechange_model.dart';

abstract class PiecesRemoteDataSource {
  Future<List<PieceRechangeModel>> getPieces({int skip = 0, int limit = 100, bool? estActive});
  Future<PieceRechangeModel> getPieceById(int id);
}

@LazySingleton(as: PiecesRemoteDataSource)
class PiecesRemoteDataSourceImpl implements PiecesRemoteDataSource {
  PiecesRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<List<PieceRechangeModel>> getPieces({int skip = 0, int limit = 100, bool? estActive}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };
      if (estActive != null) {
        queryParams['est_active'] = estActive;
      }
      
      final response = await apiClient.dio.get(
        ApiEndpoints.pieces,
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data;
      return data.map((json) => PieceRechangeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data?['detail']?.toString() ?? 'Erreur lors de la récupération des pièces',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ServerException(message: 'Erreur de connexion au serveur');
      }
    }
  }

  @override
  Future<PieceRechangeModel> getPieceById(int id) async {
    try {
      final response = await apiClient.dio.get('${ApiEndpoints.pieces}$id');
      return PieceRechangeModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
         throw ServerException(message: 'Pièce non trouvée', statusCode: 404);
      }
      throw ServerException(
          message: e.response?.data?['detail']?.toString() ?? 'Erreur lors de la récupération de la pièce',
          statusCode: e.response?.statusCode,
      );
    }
  }
}
