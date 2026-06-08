import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_role.dart';
import '../../../biens/domain/entities/bien_summary.dart';
import 'dashboard_summary.dart';

class TechnicienDashboardStats extends Equatable {
  const TechnicienDashboardStats({
    required this.pannesOuvertes,
    required this.maintenancesEnCours,
  });

  final int pannesOuvertes;
  final int maintenancesEnCours;

  @override
  List<Object?> get props => [pannesOuvertes, maintenancesEnCours];
}

class CaisseDashboardStats extends Equatable {
  const CaisseDashboardStats({
    required this.totalPieces,
    required this.piecesCritiques,
    required this.demandesEnAttente,
  });

  final int totalPieces;
  final int piecesCritiques;
  final int demandesEnAttente;

  @override
  List<Object?> get props => [totalPieces, piecesCritiques, demandesEnAttente];
}

class RoleDashboardData extends Equatable {
  const RoleDashboardData({
    required this.role,
    required this.recentBiens,
    this.summary,
    this.technicienStats,
    this.caisseStats,
  });

  final AppRole role;
  final List<BienSummary> recentBiens;
  final DashboardSummary? summary;
  final TechnicienDashboardStats? technicienStats;
  final CaisseDashboardStats? caisseStats;

  @override
  List<Object?> get props => [role, recentBiens, summary, technicienStats, caisseStats];
}
