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

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_logged_in_user_usecase.dart'
    as _i1024;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
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
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_role_dashboard_usecase.dart'
    as _i339;
import '../../features/dashboard/presentation/bloc/home_dashboard_bloc.dart'
    as _i260;
import '../network/api_client.dart' as _i557;
import '../network/network_info.dart' as _i932;
import '../storage/local_cache_service.dart' as _i266;
import '../storage/secure_storage_service.dart' as _i666;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i266.LocalCacheService>(() => _i266.LocalCacheService());
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(gh<_i666.SecureStorageService>()),
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
    gh.lazySingleton<_i776.GetBienByIdUseCase>(
      () => _i776.GetBienByIdUseCase(gh<_i749.BiensRepository>()),
    );
    gh.lazySingleton<_i122.GetRecentBiensUseCase>(
      () => _i122.GetRecentBiensUseCase(gh<_i749.BiensRepository>()),
    );
    gh.lazySingleton<_i678.ScanQrCodeUseCase>(
      () => _i678.ScanQrCodeUseCase(gh<_i749.BiensRepository>()),
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
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i188.LoginUseCase>(),
        gh<_i1024.GetLoggedInUserUseCase>(),
        gh<_i48.LogoutUseCase>(),
      ),
    );
    gh.lazySingleton<_i339.GetRoleDashboardUseCase>(
      () => _i339.GetRoleDashboardUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i260.HomeDashboardBloc>(
      () => _i260.HomeDashboardBloc(gh<_i339.GetRoleDashboardUseCase>()),
    );
    return this;
  }
}
