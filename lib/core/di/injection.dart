import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/biens/domain/usecases/get_bien_by_id_usecase.dart';
import '../../features/biens/domain/usecases/scan_qr_code_usecase.dart';
import '../../features/biens/presentation/bloc/biens_bloc.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
  _registerCustom();
}

void _registerCustom() {
  final di = getIt;
  if (!di.isRegistered<BiensBloc>()) {
    di.registerFactory<BiensBloc>(
      () => BiensBloc(
        di<GetBienByIdUseCase>(),
        di<ScanQrCodeUseCase>(),
      ),
    );
  }
}
