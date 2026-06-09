part of 'pannes_bloc.dart';

abstract class PannesState extends Equatable {
  const PannesState();

  @override
  List<Object?> get props => [];
}

class PannesInitial extends PannesState {}

class PannesLoading extends PannesState {}

class MesPannesLoaded extends PannesState {
  final List<Panne> pannes;

  const MesPannesLoaded(this.pannes);

  @override
  List<Object?> get props => [pannes];
}

class PanneDetailLoaded extends PannesState {
  final Panne panne;

  const PanneDetailLoaded(this.panne);

  @override
  List<Object?> get props => [panne];
}

class PanneDeclareSuccess extends PannesState {
  final Panne panne;

  const PanneDeclareSuccess(this.panne);

  @override
  List<Object?> get props => [panne];
}

class PanneStatutUpdated extends PannesState {
  final Panne panne;

  const PanneStatutUpdated(this.panne);

  @override
  List<Object?> get props => [panne];
}

class PannesError extends PannesState {
  final String message;

  const PannesError(this.message);

  @override
  List<Object?> get props => [message];
}
