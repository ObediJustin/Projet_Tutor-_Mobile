part of 'home_dashboard_bloc.dart';

sealed class HomeDashboardState extends Equatable {
  const HomeDashboardState();

  @override
  List<Object?> get props => [];
}

class HomeDashboardInitial extends HomeDashboardState {}

class HomeDashboardLoading extends HomeDashboardState {}

class HomeDashboardLoaded extends HomeDashboardState {
  const HomeDashboardLoaded(this.data);

  final RoleDashboardData data;

  @override
  List<Object?> get props => [data];
}

class HomeDashboardError extends HomeDashboardState {
  const HomeDashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
