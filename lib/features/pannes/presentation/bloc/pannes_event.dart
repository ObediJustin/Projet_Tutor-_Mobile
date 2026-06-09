part of 'pannes_bloc.dart';

abstract class PannesEvent extends Equatable {
  const PannesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMesPannes extends PannesEvent {
  final String? statut;

  const LoadMesPannes({this.statut});

  @override
  List<Object?> get props => [statut];
}

class LoadPanneDetail extends PannesEvent {
  final int id;

  const LoadPanneDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class SubmitDeclarerPanne extends PannesEvent {
  final int idBien;
  final String typePanne;
  final String priorite;
  final String description;

  const SubmitDeclarerPanne({
    required this.idBien,
    required this.typePanne,
    required this.priorite,
    required this.description,
  });

  @override
  List<Object?> get props => [idBien, typePanne, priorite, description];
}

class UpdatePanneStatut extends PannesEvent {
  final int idPanne;
  final String statut;

  const UpdatePanneStatut({
    required this.idPanne,
    required this.statut,
  });

  @override
  List<Object?> get props => [idPanne, statut];
}
