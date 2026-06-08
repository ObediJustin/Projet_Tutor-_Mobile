part of 'home_dashboard_bloc.dart';

sealed class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();

  @override
  List<Object?> get props => [];
}

class HomeDashboardRequested extends HomeDashboardEvent {
  const HomeDashboardRequested(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class HomeDashboardRefreshed extends HomeDashboardEvent {
  const HomeDashboardRefreshed(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}
