import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/besoin_model.dart';

abstract class BesoinsRemoteDataSource {
  Future<List<BesoinModel>> getBesoinsAValider();
  Future<BesoinModel> getBesoinById(int id);
  Future<BesoinModel> validerBesoin(int id, String decision, String? commentaire);
}

@LazySingleton(as: BesoinsRemoteDataSource)
class BesoinsRemoteDataSourceImpl implements BesoinsRemoteDataSource {
  BesoinsRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<List<BesoinModel>> getBesoinsAValider() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.besoinsAValider);
      final List<dynamic> data = response.data;
      return data.map((json) => BesoinModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data?['detail']?.toString() ?? 'Erreur lors de la récupération des besoins à valider',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw ServerException(message: 'Erreur de connexion au serveur');
      }
    }
  }

  @override
  Future<BesoinModel> getBesoinById(int id) async {
    try {
      final response = await apiClient.dio.get('${ApiEndpoints.besoins}$id');
      return BesoinModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
         throw ServerException(message: 'Besoin non trouvé', statusCode: 404);
      }
      throw ServerException(
          message: e.response?.data?['detail']?.toString() ?? 'Erreur lors de la récupération du besoin',
          statusCode: e.response?.statusCode,
      );
    }
  }
  
  @override
  Future<BesoinModel> validerBesoin(int id, String decision, String? commentaire) async {
    try {
      final queryParams = {
        'decision': decision,
      };
      if (commentaire != null && commentaire.isNotEmpty) {
        queryParams['commentaire'] = commentaire;
      }
      
      final response = await apiClient.dio.post(
        '${ApiEndpoints.besoins}$id/valider',
        queryParameters: queryParams,
      );
      return BesoinModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['detail']?.toString() ?? 'Erreur lors de la validation du besoin',
          statusCode: e.response?.statusCode,
      );
    }
  }
}
