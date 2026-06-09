import 'package:equatable/equatable.dart';
import '../../domain/entities/maintenance.dart';

abstract class MaintenancesState extends Equatable {
  const MaintenancesState();

  @override
  List<Object?> get props => [];
}

class MaintenancesInitial extends MaintenancesState {}

class MaintenancesLoading extends MaintenancesState {}

class MaintenancesLoaded extends MaintenancesState {
  final List<Maintenance> maintenances;

  const MaintenancesLoaded(this.maintenances);

  @override
  List<Object?> get props => [maintenances];
}

class MaintenanceDetailLoaded extends MaintenancesState {
  final Maintenance maintenance;

  const MaintenanceDetailLoaded(this.maintenance);

  @override
  List<Object?> get props => [maintenance];
}

class MaintenanceActionSuccess extends MaintenancesState {
  final Maintenance maintenance;
  final String message;

  const MaintenanceActionSuccess(this.maintenance, this.message);

  @override
  List<Object?> get props => [maintenance, message];
}

class MaintenancesError extends MaintenancesState {
  final String message;

  const MaintenancesError(this.message);

  @override
  List<Object?> get props => [message];
}
