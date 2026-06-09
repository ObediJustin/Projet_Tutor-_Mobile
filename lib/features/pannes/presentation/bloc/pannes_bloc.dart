import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/panne.dart';
import '../../domain/usecases/pannes_usecases.dart';

part 'pannes_event.dart';
part 'pannes_state.dart';

@injectable
class PannesBloc extends Bloc<PannesEvent, PannesState> {
  final GetMesPannesUseCase _getMesPannesUseCase;
  final GetPanneDetailUseCase _getPanneDetailUseCase;
  final DeclarerPanneUseCase _declarerPanneUseCase;
  final ChangerStatutPanneUseCase _changerStatutPanneUseCase;

  PannesBloc(
    this._getMesPannesUseCase,
    this._getPanneDetailUseCase,
    this._declarerPanneUseCase,
    this._changerStatutPanneUseCase,
  ) : super(PannesInitial()) {
    on<LoadMesPannes>(_onLoadMesPannes);
    on<LoadPanneDetail>(_onLoadPanneDetail);
    on<SubmitDeclarerPanne>(_onSubmitDeclarerPanne);
    on<UpdatePanneStatut>(_onUpdatePanneStatut);
  }

  Future<void> _onLoadMesPannes(LoadMesPannes event, Emitter<PannesState> emit) async {
    emit(PannesLoading());
    final result = await _getMesPannesUseCase(statut: event.statut);
    result.fold(
      (failure) => emit(PannesError(failure.message)),
      (pannes) => emit(MesPannesLoaded(pannes)),
    );
  }

  Future<void> _onLoadPanneDetail(LoadPanneDetail event, Emitter<PannesState> emit) async {
    emit(PannesLoading());
    final result = await _getPanneDetailUseCase(event.id);
    result.fold(
      (failure) => emit(PannesError(failure.message)),
      (panne) => emit(PanneDetailLoaded(panne)),
    );
  }

  Future<void> _onSubmitDeclarerPanne(SubmitDeclarerPanne event, Emitter<PannesState> emit) async {
    emit(PannesLoading());
    final result = await _declarerPanneUseCase(
      idBien: event.idBien,
      typePanne: event.typePanne,
      priorite: event.priorite,
      description: event.description,
    );
    result.fold(
      (failure) => emit(PannesError(failure.message)),
      (panne) => emit(PanneDeclareSuccess(panne)),
    );
  }

  Future<void> _onUpdatePanneStatut(UpdatePanneStatut event, Emitter<PannesState> emit) async {
    emit(PannesLoading());
    final result = await _changerStatutPanneUseCase(
      idPanne: event.idPanne,
      statut: event.statut,
    );
    result.fold(
      (failure) => emit(PannesError(failure.message)),
      (panne) => emit(PanneStatutUpdated(panne)),
    );
  }
}
