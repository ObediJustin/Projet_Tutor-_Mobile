// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/api_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/constants.dart';
import '../storage/secure_storage_service.dart';

@lazySingleton
class ApiClient {
  final Dio dio;
  final SecureStorageService _secureStorage;

  static const _authorizationHeader = 'Authorization';

  ApiClient(this._secureStorage) : dio = Dio() {
    final baseUrl = ApiConfig.baseUrl;
    print('🌐 [API_CLIENT]: baseUrl = $baseUrl');

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Injection automatique du token d'accès s'il existe
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers[_authorizationHeader] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Gestion du rafraîchissement du token en cas d'erreur 401 Unauthorized
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != ApiEndpoints.authLogin &&
              error.requestOptions.path != ApiEndpoints.authRefresh) {
            
            final requestOptions = error.requestOptions;
            final isRefreshed = await _refreshAccessToken();
            
            if (isRefreshed) {
              // Si le token a été rafraîchi avec succès, on relance la requête initiale
              final newToken = await _secureStorage.getAccessToken();
              requestOptions.headers[_authorizationHeader] = 'Bearer $newToken';
              
              // Recréer la requête
              final options = Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
                contentType: requestOptions.contentType,
                responseType: requestOptions.responseType,
              );
              
              try {
                final response = await dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: options,
                );
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              // Si le rafraîchissement échoue, on nettoie les tokens
              await _secureStorage.clearAuthData();
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Logger intercepteur pour le débogage en dev
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 [API_CLIENT]: $obj'),
    ));
  }

  /// Méthode interne pour rafraîchir le token d'accès
  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Créer une nouvelle instance de Dio pour le refresh afin d'éviter les boucles infinies d'intercepteurs
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      // Appel de l'API /auth/refresh avec le refresh_token en paramètre de requête (query parameter)
      final response = await refreshDio.post(
        ApiEndpoints.authRefresh,
        queryParameters: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String;
        // Le refresh_token peut être renvoyé ou rester identique
        final newRefreshToken = data['refresh_token'] as String? ?? refreshToken;

        // Sauvegarder les nouveaux tokens
        await _secureStorage.saveAccessToken(newAccessToken);
        await _secureStorage.saveRefreshToken(newRefreshToken);
        
        return true;
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement du token: $e');
    }
    
    return false;
  }
}
