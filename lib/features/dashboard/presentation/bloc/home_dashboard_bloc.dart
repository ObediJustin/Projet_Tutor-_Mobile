import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/role_dashboard_data.dart';
import '../../domain/usecases/get_role_dashboard_usecase.dart';

part 'home_dashboard_event.dart';
part 'home_dashboard_state.dart';

@injectable
class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  HomeDashboardBloc(this._getRoleDashboardUseCase) : super(HomeDashboardInitial()) {
    on<HomeDashboardRequested>(_onRequested);
    on<HomeDashboardRefreshed>(_onRequested);
  }

  final GetRoleDashboardUseCase _getRoleDashboardUseCase;

  Future<void> _onRequested(
    HomeDashboardEvent event,
    Emitter<HomeDashboardState> emit,
  ) async {
    final user = event is HomeDashboardRequested
        ? event.user
        : (event as HomeDashboardRefreshed).user;

    emit(HomeDashboardLoading());
    final result = await _getRoleDashboardUseCase(user);
    result.fold(
      (failure) => emit(HomeDashboardError(failure.message)),
      (data) => emit(HomeDashboardLoaded(data)),
    );
  }
}
