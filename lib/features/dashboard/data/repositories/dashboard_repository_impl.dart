import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/enums/app_role.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../biens/domain/entities/bien_summary.dart';
import '../../../biens/domain/repositories/biens_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/role_dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(
    this._apiClient,
    this._networkInfo,
    this._biensRepository,
  );

  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final BiensRepository _biensRepository;

  @override
  Future<Either<Failure, RoleDashboardData>> getDashboardForUser(User user) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }

    try {
      final role = user.appRole;
      final recentResult = await _biensRepository.getRecentBiens();
      final recentBiens = recentResult.getOrElse(() => <BienSummary>[]);

      switch (role) {
        case AppRole.technicien:
          return Right(RoleDashboardData(
            role: role,
            recentBiens: recentBiens,
            technicienStats: await _loadTechnicienStats(),
          ));
        case AppRole.caisse:
        case AppRole.magasinier:
          return Right(RoleDashboardData(
            role: role,
            recentBiens: recentBiens,
            caisseStats: await _loadCaisseStats(role),
          ));
        case AppRole.admin:
        case AppRole.dg:
        case AppRole.comptable:
          return Right(RoleDashboardData(
            role: role,
            recentBiens: recentBiens,
            summary: await _loadSummary(),
          ));
        case AppRole.unknown:
          return Right(RoleDashboardData(
            role: role,
            recentBiens: recentBiens,
            summary: await _loadSummary(),
          ));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: _mapDioError(e, fallback: 'Erreur dashboard.'),
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inattendue: $e'));
    }
  }

  Future<TechnicienDashboardStats> _loadTechnicienStats() async {
    var pannesOuvertes = 0;
    var maintenancesEnCours = 0;

    try {
      final pannesStats = await _apiClient.dio.get(ApiEndpoints.pannesStatistiques);
      pannesOuvertes = (pannesStats.data['en_cours'] as num?)?.toInt() ?? 0;
    } catch (_) {}

    try {
      final maintenances = await _apiClient.dio.get(ApiEndpoints.maintenancesMes);
      final list = maintenances.data as List<dynamic>;
      maintenancesEnCours = list
          .where((item) => (item as Map<String, dynamic>)['statut'] == 'EN_COURS')
          .length;
    } catch (_) {}

    return TechnicienDashboardStats(
      pannesOuvertes: pannesOuvertes,
      maintenancesEnCours: maintenancesEnCours,
    );
  }

  Future<CaisseDashboardStats> _loadCaisseStats(AppRole role) async {
    var totalPieces = 0;
    var piecesCritiques = 0;
    var demandesEnAttente = 0;

    try {
      final piecesResponse = await _apiClient.dio.get(
        ApiEndpoints.pieces,
        queryParameters: {'limit': 500, 'est_active': true},
      );
      final pieces = piecesResponse.data as List<dynamic>;
      totalPieces = pieces.length;
      piecesCritiques = pieces.where((item) {
        final map = item as Map<String, dynamic>;
        final stock = (map['stock_actuel'] as num?)?.toInt() ?? 0;
        final minimum = (map['stock_minimum'] as num?)?.toInt() ?? 0;
        return stock <= minimum;
      }).length;
    } catch (_) {}

    try {
      if (role == AppRole.caisse) {
        final besoinsResponse = await _apiClient.dio.get(ApiEndpoints.besoinsAValider);
        demandesEnAttente = (besoinsResponse.data as List<dynamic>).length;
      } else {
        final besoinsResponse = await _apiClient.dio.get(
          ApiEndpoints.besoins,
          queryParameters: {'limit': 200},
        );
        final besoins = besoinsResponse.data as List<dynamic>;
        demandesEnAttente = besoins.where((item) {
          final statut = (item as Map<String, dynamic>)['statut']?.toString() ?? '';
          return statut == 'EN_VALIDATION' ||
              statut == 'DG_VALIDE' ||
              statut == 'COMPTABLE_VALIDE';
        }).length;
      }
    } catch (_) {}

    return CaisseDashboardStats(
      totalPieces: totalPieces,
      piecesCritiques: piecesCritiques,
      demandesEnAttente: demandesEnAttente,
    );
  }

  Future<DashboardSummary> _loadSummary() async {
    final response = await _apiClient.dio.get(ApiEndpoints.dashboardSummary);
    final data = response.data as Map<String, dynamic>;
    final stats = data['statistiques_biens'] as Map<String, dynamic>? ?? {};

    return DashboardSummary(
      totalBiens: (data['total_biens'] as num?)?.toInt() ?? 0,
      pannesEnCours: (data['pannes_en_cours'] as num?)?.toInt() ?? 0,
      statistiquesBiens: stats.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
    );
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
