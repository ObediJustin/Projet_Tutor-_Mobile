import 'package:equatable/equatable.dart';

abstract class BesoinsEvent extends Equatable {
  const BesoinsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBesoinsAValiderEvent extends BesoinsEvent {
  const LoadBesoinsAValiderEvent({this.forceRefresh = false});
  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class ValiderBesoinEvent extends BesoinsEvent {
  const ValiderBesoinEvent({
    required this.idBesoin,
    required this.decision,
    this.commentaire,
  });

  final int idBesoin;
  final String decision;
  final String? commentaire;

  @override
  List<Object?> get props => [idBesoin, decision, commentaire];
}

class SearchBesoinsEvent extends BesoinsEvent {
  const SearchBesoinsEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterBesoinsStatusEvent extends BesoinsEvent {
  const FilterBesoinsStatusEvent(this.statusFilter);
  final String? statusFilter; // 'ALL', 'EN_ATTENTE', 'VALIDE', 'REJETE'

  @override
  List<Object?> get props => [statusFilter];
}
