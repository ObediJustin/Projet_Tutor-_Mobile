// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;
  final LocalCacheService _localCache;

  AuthRepositoryImpl(
    this._apiClient,
    this._secureStorage,
    this._networkInfo,
    this._localCache,
  );

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure("Pas de connexion internet."));
    }

    try {
      // Le backend FastAPI attend 'email' et 'mot_de_passe' comme query parameters pour /auth/login
      final response = await _apiClient.dio.post(
        ApiEndpoints.authLogin,
        queryParameters: {
          'email': email,
          'mot_de_passe': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tokenData = data['token'];
        final userData = data['user'];

        // Extraction des tokens
        final accessToken = tokenData['access_token'] as String;
        final refreshToken = tokenData['refresh_token'] as String;

        // Sauvegarde sécurisée
        await _secureStorage.saveAccessToken(accessToken);
        await _secureStorage.saveRefreshToken(refreshToken);

        // Parsing de l'utilisateur
        final user = UserModel.fromJson(userData);
        return Right(user);
      } else {
        return const Left(ServerFailure(message: "Erreur lors de la connexion."));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: "Identifiants incorrects ou erreur serveur."),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: "Une erreur inattendue est survenue: $e"));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // Vérification de la présence d'un token d'accès avant tout appel réseau
    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      return const Left(AuthFailure("Aucun jeton de session trouvé."));
    }

    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure("Pas de connexion internet."));
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.authMe);
      
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        return Right(user);
      } else {
        return const Left(ServerFailure(message: "Impossible de récupérer le profil."));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: "Erreur d'authentification."),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: "Erreur inattendue: $e"));
    }
  }

  String _mapDioError(DioException error, {required String fallback}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Impossible de joindre le serveur. Vérifiez que le backend est démarré "
            "et que BASE_URL pointe vers ${_apiClient.dio.options.baseUrl}.";
      case DioExceptionType.connectionError:
        return "Connexion refusée vers ${_apiClient.dio.options.baseUrl}. "
            "Sur Chrome/Web utilisez localhost, sur émulateur Android utilisez 10.0.2.2.";
      default:
        return error.response?.data?['detail']?.toString() ?? fallback;
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Tentative d'appel de l'API logout pour notifier le serveur (optionnel)
      if (await _networkInfo.isConnected) {
        await _apiClient.dio.post(ApiEndpoints.authLogout);
      }
    } catch (e) {
      // Ignorer l'erreur réseau pour le logout local
      // Échec silencieux du logout API
    } finally {
      await _secureStorage.clearAuthData();
      await _localCache.clearCache();
    }
    return const Right(unit);
  }
}
