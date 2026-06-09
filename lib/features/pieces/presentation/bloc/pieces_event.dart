import 'package:equatable/equatable.dart';

abstract class PiecesEvent extends Equatable {
  const PiecesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPiecesEvent extends PiecesEvent {
  const LoadPiecesEvent({this.forceRefresh = false});
  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class SearchPiecesEvent extends PiecesEvent {
  const SearchPiecesEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterCritiquesEvent extends PiecesEvent {
  const FilterCritiquesEvent(this.showOnlyCritiques);
  final bool showOnlyCritiques;

  @override
  List<Object?> get props => [showOnlyCritiques];
}
