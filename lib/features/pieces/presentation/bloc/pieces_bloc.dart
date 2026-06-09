import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/piece_rechange.dart';
import '../../domain/usecases/get_pieces.dart';
import 'pieces_event.dart';
import 'pieces_state.dart';

@injectable
class PiecesBloc extends Bloc<PiecesEvent, PiecesState> {
  PiecesBloc(this.getPieces) : super(PiecesInitial()) {
    on<LoadPiecesEvent>(_onLoadPieces);
    on<SearchPiecesEvent>(_onSearchPieces);
    on<FilterCritiquesEvent>(_onFilterCritiques);
  }

  final GetPieces getPieces;

  Future<void> _onLoadPieces(
    LoadPiecesEvent event,
    Emitter<PiecesState> emit,
  ) async {
    emit(PiecesLoading());

    final result = await getPieces(
      fromCache: !event.forceRefresh,
      estActive: true,
      limit: 500,
    );

    result.fold(
      (failure) => emit(PiecesError(failure.message)),
      (pieces) => emit(PiecesLoaded(pieces: pieces, allPieces: pieces)),
    );
  }

  void _onSearchPieces(
    SearchPiecesEvent event,
    Emitter<PiecesState> emit,
  ) {
    if (state is PiecesLoaded) {
      final currentState = state as PiecesLoaded;
      final query = event.query.toLowerCase();
      final filteredPieces = _applyFilters(
        currentState.allPieces,
        query,
        currentState.showOnlyCritiques,
      );
      emit(currentState.copyWith(
        pieces: filteredPieces,
        searchQuery: query,
      ));
    }
  }

  void _onFilterCritiques(
    FilterCritiquesEvent event,
    Emitter<PiecesState> emit,
  ) {
    if (state is PiecesLoaded) {
      final currentState = state as PiecesLoaded;
      final filteredPieces = _applyFilters(
        currentState.allPieces,
        currentState.searchQuery,
        event.showOnlyCritiques,
      );
      emit(currentState.copyWith(
        pieces: filteredPieces,
        showOnlyCritiques: event.showOnlyCritiques,
      ));
    }
  }

  List<PieceRechange> _applyFilters(
    List<PieceRechange> allPieces,
    String query,
    bool showOnlyCritiques,
  ) {
    return allPieces.where((piece) {
      final matchesQuery = piece.designation.toLowerCase().contains(query) ||
          (piece.reference?.toLowerCase().contains(query) ?? false);
      final matchesCritique = !showOnlyCritiques || piece.estCritique;
      return matchesQuery && matchesCritique;
    }).toList();
  }
}
