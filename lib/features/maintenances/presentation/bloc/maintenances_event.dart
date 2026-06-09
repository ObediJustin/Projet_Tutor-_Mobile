import 'package:equatable/equatable.dart';

abstract class MaintenancesEvent extends Equatable {
  const MaintenancesEvent();

  @override
  List<Object?> get props => [];
}

class GetMesMaintenancesEvent extends MaintenancesEvent {
  final String? statut;

  const GetMesMaintenancesEvent({this.statut});

  @override
  List<Object?> get props => [statut];
}

class GetMaintenanceDetailEvent extends MaintenancesEvent {
  final int id;

  const GetMaintenanceDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DemarrerMaintenanceEvent extends MaintenancesEvent {
  final int id;

  const DemarrerMaintenanceEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TerminerMaintenanceEvent extends MaintenancesEvent {
  final int id;
  final String rapport;
  final double cout;
  final String? piecesRemplacees;

  const TerminerMaintenanceEvent({
    required this.id,
    required this.rapport,
    required this.cout,
    this.piecesRemplacees,
  });

  @override
  List<Object?> get props => [id, rapport, cout, piecesRemplacees];
}
