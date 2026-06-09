import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/panne.dart';
import '../../domain/repositories/pannes_repository.dart';
import '../models/panne_model.dart';

@LazySingleton(as: PannesRepository)
class PannesRepositoryImpl implements PannesRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final LocalCacheService _localCache;

  PannesRepositoryImpl(
    this._apiClient,
    this._networkInfo,
    this._localCache,
  );

  @override
  Future<Either<Failure, List<Panne>>> getMesPannes({String? statut}) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      try {
        final cached = await _localCache.getCachedPannes();
        final models = cached.map((e) => PanneModel.fromJson(e)).toList();
        if (statut != null && statut.isNotEmpty) {
          final filtered = models.where((p) => p.statut.toUpperCase() == statut.toUpperCase()).toList();
          return Right(filtered);
        }
        return Right(models);
      } catch (e) {
        return Left(CacheFailure('Impossible de charger le cache local: $e'));
      }
    }

    try {
      final queryParams = <String, dynamic>{};
      if (statut != null && statut.isNotEmpty) {
        queryParams['statut'] = statut;
      }
      final response = await _apiClient.dio.get(
        ApiEndpoints.pannesMesPannes,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final pannes = data.map((json) => PanneModel.fromJson(json as Map<String, dynamic>)).toList();
        
        if (statut == null || statut.isEmpty) {
          final cacheList = pannes.map((p) => p.toJson()).toList();
          await _localCache.saveCachedPannes(cacheList);
        }
        
        return Right(pannes);
      }
      return const Left(ServerFailure(message: 'Impossible de récupérer la liste des pannes.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur lors du chargement des pannes.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Panne>> getPanneDetail(int id) async {
    if (!await _networkInfo.isConnected) {
      try {
        final cached = await _localCache.getCachedPannes();
        final models = cached.map((e) => PanneModel.fromJson(e)).toList();
        final panne = models.firstWhere((p) => p.idPanne == id);
        return Right(panne);
      } catch (_) {
        return const Left(NetworkFailure('Pas de connexion internet pour charger le détail.'));
      }
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.panneDetail(id));
      if (response.statusCode == 200) {
        final panne = PanneModel.fromJson(response.data as Map<String, dynamic>);
        return Right(panne);
      }
      return const Left(ServerFailure(message: 'Panne introuvable.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur lors du chargement de la panne.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Panne>> declarerPanne({
    required int idBien,
    required String typePanne,
    required String priorite,
    required String description,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet pour déclarer une panne.'));
    }

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.pannes,
        data: {
          'id_bien': idBien,
          'type_panne': typePanne,
          'priorite': priorite,
          'description': description,
          'diagnostic': null,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final panne = PanneModel.fromJson(response.data as Map<String, dynamic>);
        return Right(panne);
      }
      return const Left(ServerFailure(message: 'Erreur lors de la déclaration de la panne.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Échec de déclaration de la panne.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Panne>> changerStatutPanne(int id, String statut) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet pour changer le statut.'));
    }

    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.panneUpdateStatut(id),
        queryParameters: {'statut': statut},
      );

      if (response.statusCode == 200) {
        final panne = PanneModel.fromJson(response.data as Map<String, dynamic>);
        return Right(panne);
      }
      return const Left(ServerFailure(message: 'Erreur lors de la mise à jour du statut.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Échec de la mise à jour du statut.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Panne>>> getRecentPannesLocal() async {
    try {
      final cached = await _localCache.getCachedPannes();
      final pannes = cached.map((e) => PanneModel.fromJson(e)).toList();
      return Right(pannes);
    } catch (e) {
      return Left(CacheFailure('Impossible de lire les pannes locales: $e'));
    }
  }

  String _mapDioError(DioException error, {required String fallback}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Impossible de joindre le serveur.";
      case DioExceptionType.connectionError:
        return "Connexion refusée.";
      default:
        return error.response?.data?['detail']?.toString() ?? fallback;
    }
  }
}
