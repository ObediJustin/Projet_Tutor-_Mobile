// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_logged_in_user_usecase.dart'
    as _i1024;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/besoins/data/datasources/besoins_local_data_source.dart'
    as _i695;
import '../../features/besoins/data/datasources/besoins_remote_data_source.dart'
    as _i229;
import '../../features/besoins/data/repositories/besoins_repository_impl.dart'
    as _i709;
import '../../features/besoins/domain/repositories/besoins_repository.dart'
    as _i202;
import '../../features/besoins/domain/usecases/besoins_usecases.dart' as _i751;
import '../../features/besoins/presentation/bloc/besoins_bloc.dart' as _i332;
import '../../features/biens/data/repositories/biens_repository_impl.dart'
    as _i874;
import '../../features/biens/domain/repositories/biens_repository.dart'
    as _i749;
import '../../features/biens/domain/usecases/get_bien_by_id_usecase.dart'
    as _i776;
import '../../features/biens/domain/usecases/get_recent_biens_usecase.dart'
    as _i122;
import '../../features/biens/domain/usecases/scan_qr_code_usecase.dart'
    as _i678;
import '../../features/biens/presentation/bloc/biens_bloc.dart' as _i36;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_role_dashboard_usecase.dart'
    as _i339;
import '../../features/dashboard/presentation/bloc/home_dashboard_bloc.dart'
    as _i260;
import '../../features/maintenances/data/repositories/maintenances_repository_impl.dart'
    as _i392;
import '../../features/maintenances/domain/repositories/maintenances_repository.dart'
    as _i791;
import '../../features/maintenances/domain/usecases/maintenances_usecases.dart'
    as _i103;
import '../../features/maintenances/presentation/bloc/maintenances_bloc.dart'
    as _i898;
import '../../features/pannes/data/repositories/pannes_repository_impl.dart'
    as _i574;
import '../../features/pannes/domain/repositories/pannes_repository.dart'
    as _i876;
import '../../features/pannes/domain/usecases/pannes_usecases.dart' as _i429;
import '../../features/pannes/presentation/bloc/pannes_bloc.dart' as _i119;
import '../../features/pieces/data/datasources/pieces_local_data_source.dart'
    as _i846;
import '../../features/pieces/data/datasources/pieces_remote_data_source.dart'
    as _i286;
import '../../features/pieces/data/repositories/pieces_repository_impl.dart'
    as _i517;
import '../../features/pieces/domain/repositories/pieces_repository.dart'
    as _i1034;
import '../../features/pieces/domain/usecases/get_pieces.dart' as _i686;
import '../../features/pieces/presentation/bloc/pieces_bloc.dart' as _i188;
import '../network/api_client.dart' as _i557;
import '../network/network_info.dart' as _i932;
import '../storage/local_cache_service.dart' as _i266;
import '../storage/secure_storage_service.dart' as _i666;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i266.LocalCacheService>(() => _i266.LocalCacheService());
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i695.BesoinsLocalDataSource>(
      () => _i695.BesoinsLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i846.PiecesLocalDataSource>(
      () => _i846.PiecesLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i229.BesoinsRemoteDataSource>(
      () => _i229.BesoinsRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i202.BesoinsRepository>(
      () => _i709.BesoinsRepositoryImpl(
        gh<_i229.BesoinsRemoteDataSource>(),
        gh<_i695.BesoinsLocalDataSource>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i791.MaintenancesRepository>(
      () => _i392.MaintenancesRepositoryImpl(
        gh<_i557.ApiClient>(),
        gh<_i932.NetworkInfo>(),
        gh<_i266.LocalCacheService>(),
      ),
    );
    gh.lazySingleton<_i749.BiensRepository>(
      () => _i874.BiensRepositoryImpl(
        gh<_i557.ApiClient>(),
        gh<_i932.NetworkInfo>(),
        gh<_i266.LocalCacheService>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i557.ApiClient>(),
        gh<_i666.SecureStorageService>(),
        gh<_i932.NetworkInfo>(),
        gh<_i266.LocalCacheService>(),
      ),
    );
    gh.lazySingleton<_i876.PannesRepository>(
      () => _i574.PannesRepositoryImpl(
        gh<_i557.ApiClient>(),
        gh<_i932.NetworkInfo>(),
        gh<_i266.LocalCacheService>(),
      ),
    );
    gh.lazySingleton<_i103.GetMesMaintenancesUseCase>(
      () => _i103.GetMesMaintenancesUseCase(gh<_i791.MaintenancesRepository>()),
    );
    gh.lazySingleton<_i103.GetMaintenanceDetailUseCase>(
      () =>
          _i103.GetMaintenanceDetailUseCase(gh<_i791.MaintenancesRepository>()),
    );
    gh.lazySingleton<_i103.DemarrerMaintenanceUseCase>(
      () =>
          _i103.DemarrerMaintenanceUseCase(gh<_i791.MaintenancesRepository>()),
    );
    gh.lazySingleton<_i103.TerminerMaintenanceUseCase>(
      () =>
          _i103.TerminerMaintenanceUseCase(gh<_i791.MaintenancesRepository>()),
    );
    gh.lazySingleton<_i103.GetRecentMaintenancesLocalUseCase>(
      () => _i103.GetRecentMaintenancesLocalUseCase(
        gh<_i791.MaintenancesRepository>(),
      ),
    );
    gh.lazySingleton<_i776.GetBienByIdUseCase>(
      () => _i776.GetBienByIdUseCase(gh<_i749.BiensRepository>()),
    );
    gh.lazySingleton<_i122.GetRecentBiensUseCase>(
      () => _i122.GetRecentBiensUseCase(gh<_i749.BiensRepository>()),
    );
    gh.lazySingleton<_i678.ScanQrCodeUseCase>(
      () => _i678.ScanQrCodeUseCase(gh<_i749.BiensRepository>()),
    );
    gh.lazySingleton<_i429.GetMesPannesUseCase>(
      () => _i429.GetMesPannesUseCase(gh<_i876.PannesRepository>()),
    );
    gh.lazySingleton<_i429.GetPanneDetailUseCase>(
      () => _i429.GetPanneDetailUseCase(gh<_i876.PannesRepository>()),
    );
    gh.lazySingleton<_i429.DeclarerPanneUseCase>(
      () => _i429.DeclarerPanneUseCase(gh<_i876.PannesRepository>()),
    );
    gh.lazySingleton<_i429.ChangerStatutPanneUseCase>(
      () => _i429.ChangerStatutPanneUseCase(gh<_i876.PannesRepository>()),
    );
    gh.lazySingleton<_i429.GetRecentPannesLocalUseCase>(
      () => _i429.GetRecentPannesLocalUseCase(gh<_i876.PannesRepository>()),
    );
    gh.lazySingleton<_i286.PiecesRemoteDataSource>(
      () => _i286.PiecesRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i1024.GetLoggedInUserUseCase>(
      () => _i1024.GetLoggedInUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i665.DashboardRepository>(
      () => _i509.DashboardRepositoryImpl(
        gh<_i557.ApiClient>(),
        gh<_i932.NetworkInfo>(),
        gh<_i749.BiensRepository>(),
      ),
    );
    gh.lazySingleton<_i751.GetBesoinsAValider>(
      () => _i751.GetBesoinsAValider(gh<_i202.BesoinsRepository>()),
    );
    gh.lazySingleton<_i751.GetBesoinById>(
      () => _i751.GetBesoinById(gh<_i202.BesoinsRepository>()),
    );
    gh.lazySingleton<_i751.ValiderBesoin>(
      () => _i751.ValiderBesoin(gh<_i202.BesoinsRepository>()),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i188.LoginUseCase>(),
        gh<_i1024.GetLoggedInUserUseCase>(),
        gh<_i48.LogoutUseCase>(),
      ),
    );
    gh.factory<_i898.MaintenancesBloc>(
      () => _i898.MaintenancesBloc(
        gh<_i103.GetMesMaintenancesUseCase>(),
        gh<_i103.GetMaintenanceDetailUseCase>(),
        gh<_i103.DemarrerMaintenanceUseCase>(),
        gh<_i103.TerminerMaintenanceUseCase>(),
      ),
    );
    gh.lazySingleton<_i1034.PiecesRepository>(
      () => _i517.PiecesRepositoryImpl(
        gh<_i286.PiecesRemoteDataSource>(),
        gh<_i846.PiecesLocalDataSource>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.factory<_i332.BesoinsBloc>(
      () => _i332.BesoinsBloc(
        gh<_i751.GetBesoinsAValider>(),
        gh<_i751.ValiderBesoin>(),
      ),
    );
    gh.factory<_i36.BiensBloc>(
      () => _i36.BiensBloc(
        gh<_i776.GetBienByIdUseCase>(),
        gh<_i678.ScanQrCodeUseCase>(),
      ),
    );
    gh.factory<_i119.PannesBloc>(
      () => _i119.PannesBloc(
        gh<_i429.GetMesPannesUseCase>(),
        gh<_i429.GetPanneDetailUseCase>(),
        gh<_i429.DeclarerPanneUseCase>(),
        gh<_i429.ChangerStatutPanneUseCase>(),
      ),
    );
    gh.lazySingleton<_i339.GetRoleDashboardUseCase>(
      () => _i339.GetRoleDashboardUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.lazySingleton<_i686.GetPieces>(
      () => _i686.GetPieces(gh<_i1034.PiecesRepository>()),
    );
    gh.lazySingleton<_i686.GetPieceById>(
      () => _i686.GetPieceById(gh<_i1034.PiecesRepository>()),
    );
    gh.factory<_i260.HomeDashboardBloc>(
      () => _i260.HomeDashboardBloc(gh<_i339.GetRoleDashboardUseCase>()),
    );
    gh.factory<_i188.PiecesBloc>(() => _i188.PiecesBloc(gh<_i686.GetPieces>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
