import 'package:equatable/equatable.dart';
import '../../domain/entities/piece_rechange.dart';

abstract class PiecesState extends Equatable {
  const PiecesState();

  @override
  List<Object?> get props => [];
}

class PiecesInitial extends PiecesState {}

class PiecesLoading extends PiecesState {}

class PiecesLoaded extends PiecesState {
  const PiecesLoaded({
    required this.pieces,
    required this.allPieces,
    this.searchQuery = '',
    this.showOnlyCritiques = false,
  });

  final List<PieceRechange> pieces;
  final List<PieceRechange> allPieces;
  final String searchQuery;
  final bool showOnlyCritiques;

  PiecesLoaded copyWith({
    List<PieceRechange>? pieces,
    List<PieceRechange>? allPieces,
    String? searchQuery,
    bool? showOnlyCritiques,
  }) {
    return PiecesLoaded(
      pieces: pieces ?? this.pieces,
      allPieces: allPieces ?? this.allPieces,
      searchQuery: searchQuery ?? this.searchQuery,
      showOnlyCritiques: showOnlyCritiques ?? this.showOnlyCritiques,
    );
  }

  @override
  List<Object?> get props => [pieces, allPieces, searchQuery, showOnlyCritiques];
}

class PiecesError extends PiecesState {
  const PiecesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
