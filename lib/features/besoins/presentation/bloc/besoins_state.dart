import 'package:equatable/equatable.dart';
import '../../domain/entities/besoin.dart';

abstract class BesoinsState extends Equatable {
  const BesoinsState();

  @override
  List<Object?> get props => [];
}

class BesoinsInitial extends BesoinsState {}

class BesoinsLoading extends BesoinsState {}

class BesoinsLoaded extends BesoinsState {
  const BesoinsLoaded({
    required this.besoins,
    required this.allBesoins,
    this.searchQuery = '',
    this.statusFilter = 'ALL',
    this.isActionLoading = false,
    this.actionMessage,
    this.actionError,
  });

  final List<Besoin> besoins;
  final List<Besoin> allBesoins;
  final String searchQuery;
  final String statusFilter;
  final bool isActionLoading;
  final String? actionMessage;
  final String? actionError;

  BesoinsLoaded copyWith({
    List<Besoin>? besoins,
    List<Besoin>? allBesoins,
    String? searchQuery,
    String? statusFilter,
    bool? isActionLoading,
    String? actionMessage,
    String? actionError,
  }) {
    return BesoinsLoaded(
      besoins: besoins ?? this.besoins,
      allBesoins: allBesoins ?? this.allBesoins,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionMessage: actionMessage,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
        besoins,
        allBesoins,
        searchQuery,
        statusFilter,
        isActionLoading,
        actionMessage,
        actionError,
      ];
}

class BesoinsError extends BesoinsState {
  const BesoinsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
