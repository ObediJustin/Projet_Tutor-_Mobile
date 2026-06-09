import '../../domain/entities/maintenance.dart';

class MaintenanceModel extends Maintenance {
  const MaintenanceModel({
    required super.idMaintenance,
    required super.idBien,
    required super.idTechnicien,
    required super.typeMaintenance,
    required super.statut,
    required super.datePlanifiee,
    super.dateDebutReelle,
    super.dateFinReelle,
    super.periodiciteJours,
    required super.cout,
    required super.description,
    super.observation,
    super.piecesRemplacees,
    super.rapport,
    required super.dateCreation,
    super.bienDesignation,
    super.technicienNom,
    super.dureeJours,
    super.joursRestants,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      idMaintenance: json['id_maintenance'] as int,
      idBien: json['id_bien'] as int,
      idTechnicien: json['id_technicien'] as int,
      typeMaintenance: json['type_maintenance'] as String? ?? 'CORRECTIVE',
      statut: json['statut'] as String? ?? 'PLANIFIEE',
      datePlanifiee: DateTime.parse(json['date_planifiee'] as String),
      dateDebutReelle: json['date_debut_reelle'] != null
          ? DateTime.parse(json['date_debut_reelle'] as String)
          : null,
      dateFinReelle: json['date_fin_reelle'] != null
          ? DateTime.parse(json['date_fin_reelle'] as String)
          : null,
      periodiciteJours: json['periodicite_jours'] as int?,
      cout: (json['cout'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      observation: json['observation'] as String?,
      piecesRemplacees: json['pieces_remplacees'] as String?,
      rapport: json['rapport'] as String?,
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'] as String)
          : DateTime.now(),
      bienDesignation: json['bien_designation'] as String?,
      technicienNom: json['technicien_nom'] as String?,
      dureeJours: json['duree_jours'] as int?,
      joursRestants: json['jours_restants'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_maintenance': idMaintenance,
      'id_bien': idBien,
      'id_technicien': idTechnicien,
      'type_maintenance': typeMaintenance,
      'statut': statut,
      'date_planifiee': datePlanifiee.toIso8601String(),
      'date_debut_reelle': dateDebutReelle?.toIso8601String(),
      'date_fin_reelle': dateFinReelle?.toIso8601String(),
      'periodicite_jours': periodiciteJours,
      'cout': cout,
      'description': description,
      'observation': observation,
      'pieces_remplacees': piecesRemplacees,
      'rapport': rapport,
      'date_creation': dateCreation.toIso8601String(),
      'bien_designation': bienDesignation,
      'technicien_nom': technicienNom,
      'duree_jours': dureeJours,
      'jours_restants': joursRestants,
    };
  }
}
