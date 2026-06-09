import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/besoin.dart';
import '../../domain/usecases/besoins_usecases.dart';
import 'besoins_event.dart';
import 'besoins_state.dart';

@injectable
class BesoinsBloc extends Bloc<BesoinsEvent, BesoinsState> {
  BesoinsBloc(this.getBesoinsAValider, this.validerBesoin)
      : super(BesoinsInitial()) {
    on<LoadBesoinsAValiderEvent>(_onLoadBesoinsAValider);
    on<ValiderBesoinEvent>(_onValiderBesoin);
    on<SearchBesoinsEvent>(_onSearchBesoins);
    on<FilterBesoinsStatusEvent>(_onFilterBesoinsStatus);
  }

  final GetBesoinsAValider getBesoinsAValider;
  final ValiderBesoin validerBesoin;

  Future<void> _onLoadBesoinsAValider(
    LoadBesoinsAValiderEvent event,
    Emitter<BesoinsState> emit,
  ) async {
    emit(BesoinsLoading());

    final result = await getBesoinsAValider(fromCache: !event.forceRefresh);

    result.fold(
      (failure) => emit(BesoinsError(failure.message)),
      (besoins) => emit(BesoinsLoaded(besoins: besoins, allBesoins: besoins)),
    );
  }

  Future<void> _onValiderBesoin(
    ValiderBesoinEvent event,
    Emitter<BesoinsState> emit,
  ) async {
    if (state is BesoinsLoaded) {
      final currentState = state as BesoinsLoaded;
      emit(currentState.copyWith(isActionLoading: true));

      final result = await validerBesoin(
          event.idBesoin, event.decision, event.commentaire);

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            isActionLoading: false,
            actionError: failure.message,
          ));
        },
        (updatedBesoin) {
          final updatedAllBesoins = currentState.allBesoins.map((b) {
            return b.idBesoin == updatedBesoin.idBesoin ? updatedBesoin : b;
          }).toList();

          final filteredBesoins = _applyFilters(
            updatedAllBesoins,
            currentState.searchQuery,
            currentState.statusFilter,
          );

          emit(currentState.copyWith(
            isActionLoading: false,
            allBesoins: updatedAllBesoins,
            besoins: filteredBesoins,
            actionMessage: event.decision == 'APPROUVE' 
                ? 'Besoin validé avec succès' 
                : 'Besoin rejeté',
          ));
        },
      );
    }
  }

  void _onSearchBesoins(
    SearchBesoinsEvent event,
    Emitter<BesoinsState> emit,
  ) {
    if (state is BesoinsLoaded) {
      final currentState = state as BesoinsLoaded;
      final query = event.query.toLowerCase();
      final filteredBesoins = _applyFilters(
        currentState.allBesoins,
        query,
        currentState.statusFilter,
      );
      emit(currentState.copyWith(
        besoins: filteredBesoins,
        searchQuery: query,
      ));
    }
  }

  void _onFilterBesoinsStatus(
    FilterBesoinsStatusEvent event,
    Emitter<BesoinsState> emit,
  ) {
    if (state is BesoinsLoaded) {
      final currentState = state as BesoinsLoaded;
      final statusFilter = event.statusFilter ?? 'ALL';
      final filteredBesoins = _applyFilters(
        currentState.allBesoins,
        currentState.searchQuery,
        statusFilter,
      );
      emit(currentState.copyWith(
        besoins: filteredBesoins,
        statusFilter: statusFilter,
      ));
    }
  }

  List<Besoin> _applyFilters(
    List<Besoin> allBesoins,
    String query,
    String statusFilter,
  ) {
    return allBesoins.where((besoin) {
      final matchesQuery = besoin.numeroDemande.toLowerCase().contains(query);
      
      bool matchesStatus = true;
      if (statusFilter == 'EN_ATTENTE') {
        matchesStatus = besoin.enAttente;
      } else if (statusFilter == 'VALIDE') {
        matchesStatus = besoin.statut.contains('VALIDE') || besoin.statut == 'APPROUVEE';
      } else if (statusFilter == 'REJETE') {
        matchesStatus = besoin.statut == 'REJETE';
      }

      return matchesQuery && matchesStatus;
    }).toList();
  }
}
