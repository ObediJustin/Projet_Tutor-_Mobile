import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/maintenances_usecases.dart';
import 'maintenances_event.dart';
import 'maintenances_state.dart';

@injectable
class MaintenancesBloc extends Bloc<MaintenancesEvent, MaintenancesState> {
  final GetMesMaintenancesUseCase _getMesMaintenances;
  final GetMaintenanceDetailUseCase _getMaintenanceDetail;
  final DemarrerMaintenanceUseCase _demarrerMaintenance;
  final TerminerMaintenanceUseCase _terminerMaintenance;

  MaintenancesBloc(
    this._getMesMaintenances,
    this._getMaintenanceDetail,
    this._demarrerMaintenance,
    this._terminerMaintenance,
  ) : super(MaintenancesInitial()) {
    on<GetMesMaintenancesEvent>(_onGetMesMaintenances);
    on<GetMaintenanceDetailEvent>(_onGetMaintenanceDetail);
    on<DemarrerMaintenanceEvent>(_onDemarrerMaintenance);
    on<TerminerMaintenanceEvent>(_onTerminerMaintenance);
  }

  Future<void> _onGetMesMaintenances(
    GetMesMaintenancesEvent event,
    Emitter<MaintenancesState> emit,
  ) async {
    emit(MaintenancesLoading());
    final result = await _getMesMaintenances(statut: event.statut);
    result.fold(
      (failure) => emit(MaintenancesError(failure.message)),
      (maintenances) => emit(MaintenancesLoaded(maintenances)),
    );
  }

  Future<void> _onGetMaintenanceDetail(
    GetMaintenanceDetailEvent event,
    Emitter<MaintenancesState> emit,
  ) async {
    emit(MaintenancesLoading());
    final result = await _getMaintenanceDetail(event.id);
    result.fold(
      (failure) => emit(MaintenancesError(failure.message)),
      (maintenance) => emit(MaintenanceDetailLoaded(maintenance)),
    );
  }

  Future<void> _onDemarrerMaintenance(
    DemarrerMaintenanceEvent event,
    Emitter<MaintenancesState> emit,
  ) async {
    emit(MaintenancesLoading());
    final result = await _demarrerMaintenance(event.id);
    result.fold(
      (failure) => emit(MaintenancesError(failure.message)),
      (maintenance) => emit(MaintenanceActionSuccess(
        maintenance,
        'La maintenance a été démarrée avec succès.',
      )),
    );
  }

  Future<void> _onTerminerMaintenance(
    TerminerMaintenanceEvent event,
    Emitter<MaintenancesState> emit,
  ) async {
    emit(MaintenancesLoading());
    final result = await _terminerMaintenance(
      id: event.id,
      rapport: event.rapport,
      cout: event.cout,
      piecesRemplacees: event.piecesRemplacees,
    );
    result.fold(
      (failure) => emit(MaintenancesError(failure.message)),
      (maintenance) => emit(MaintenanceActionSuccess(
        maintenance,
        'La maintenance a été clôturée avec succès.',
      )),
    );
  }
}
