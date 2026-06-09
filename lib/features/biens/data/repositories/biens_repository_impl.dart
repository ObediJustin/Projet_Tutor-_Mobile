import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/bien.dart';
import '../../domain/entities/bien_summary.dart';
import '../../domain/repositories/biens_repository.dart';
import '../models/bien_model.dart';

@LazySingleton(as: BiensRepository)
class BiensRepositoryImpl implements BiensRepository {
  BiensRepositoryImpl(
    this._apiClient,
    this._networkInfo,
    this._localCache,
  );

  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final LocalCacheService _localCache;

  @override
  Future<Either<Failure, Bien>> getBienById(int id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.bienDetail(id));
      if (response.statusCode == 200) {
        final bien = BienModel.fromJson(response.data as Map<String, dynamic>);
        await _localCache.saveRecentBien(bien.toSummary());
        return Right(bien);
      }
      return const Left(ServerFailure(message: 'Bien introuvable.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur lors du chargement du bien.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, BienSummary>> scanQrCode(String qrData) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.qrCodeScan,
        queryParameters: {'qr_data': qrData.trim()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final bienJson = data['bien'] as Map<String, dynamic>;
        final summary = BienModel.summaryFromScanJson(bienJson);
        await _localCache.saveRecentBien(summary);
        return Right(summary);
      }
      return const Left(ServerFailure(message: 'QR code non reconnu.'));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Échec du scan QR.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BienSummary>>> getRecentBiens() async {
    try {
      final recent = await _localCache.getRecentBiens();
      return Right(recent);
    } catch (e) {
      return Left(CacheFailure('Impossible de lire l\'historique local: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveRecentBien(BienSummary bien) async {
    try {
      await _localCache.saveRecentBien(
        bien.copyWith(consultedAt: DateTime.now()),
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Impossible d\'enregistrer le bien: $e'));
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
