import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/repositories/maintenances_repository.dart';
import '../models/maintenance_model.dart';

@LazySingleton(as: MaintenancesRepository)
class MaintenancesRepositoryImpl implements MaintenancesRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final LocalCacheService _localCache;

  MaintenancesRepositoryImpl(
    this._apiClient,
    this._networkInfo,
    this._localCache,
  );

  @override
  Future<Either<Failure, List<Maintenance>>> getMesMaintenances({String? statut}) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      try {
        final cached = await _localCache.getCachedMaintenances();
        final models = cached.map((e) => MaintenanceModel.fromJson(e)).toList();
        if (statut != null && statut.isNotEmpty) {
          return Right(models.where((m) => m.statut.toUpperCase() == statut.toUpperCase()).toList());
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
        ApiEndpoints.maintenancesMes,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final maintenances = data
            .map((json) => MaintenanceModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache la liste complète (sans filtre)
        if (statut == null || statut.isEmpty) {
          await _localCache.saveCachedMaintenances(
            maintenances.map((m) => m.toJson()).toList(),
          );
        }

        return Right(maintenances);
      }
      return const Left(ServerFailure(message: 'Impossible de récupérer les maintenances.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur lors du chargement des maintenances.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Maintenance>> getMaintenanceDetail(int id) async {
    if (!await _networkInfo.isConnected) {
      try {
        final cached = await _localCache.getCachedMaintenances();
        final models = cached.map((e) => MaintenanceModel.fromJson(e)).toList();
        final m = models.firstWhere((m) => m.idMaintenance == id);
        return Right(m);
      } catch (_) {
        return const Left(NetworkFailure('Pas de connexion internet pour charger le détail.'));
      }
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.maintenanceDetail(id));
      if (response.statusCode == 200) {
        return Right(MaintenanceModel.fromJson(response.data as Map<String, dynamic>));
      }
      return const Left(ServerFailure(message: 'Maintenance introuvable.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur lors du chargement.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Maintenance>> demarrerMaintenance(int id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }

    try {
      final response = await _apiClient.dio.post(ApiEndpoints.maintenanceDemarrer(id));
      if (response.statusCode == 200) {
        return Right(MaintenanceModel.fromJson(response.data as Map<String, dynamic>));
      }
      return const Left(ServerFailure(message: 'Impossible de démarrer la maintenance.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Échec du démarrage.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, Maintenance>> terminerMaintenance({
    required int id,
    required String rapport,
    required double cout,
    String? piecesRemplacees,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.maintenanceTerminer(id),
        data: {
          'rapport': rapport,
          'cout': cout,
          'pieces_remplacees': piecesRemplacees,
        },
      );
      if (response.statusCode == 200) {
        return Right(MaintenanceModel.fromJson(response.data as Map<String, dynamic>));
      }
      return const Left(ServerFailure(message: 'Impossible de terminer la maintenance.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Échec de la terminaison.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Maintenance>>> getRecentMaintenancesLocal() async {
    try {
      final cached = await _localCache.getCachedMaintenances();
      return Right(cached.map((e) => MaintenanceModel.fromJson(e)).toList());
    } catch (e) {
      return Left(CacheFailure('Impossible de lire les maintenances locales: $e'));
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
