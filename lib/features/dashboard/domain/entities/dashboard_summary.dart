import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalBiens,
    required this.pannesEnCours,
    required this.statistiquesBiens,
  });

  final int totalBiens;
  final int pannesEnCours;
  final Map<String, int> statistiquesBiens;

  @override
  List<Object?> get props => [totalBiens, pannesEnCours, statistiquesBiens];
}
