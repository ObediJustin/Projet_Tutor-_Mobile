import '../../domain/entities/panne.dart';

class PanneModel extends Panne {
  const PanneModel({
    required super.idPanne,
    required super.idBien,
    required super.idTechnicien,
    required super.dateDeclaration,
    super.dateDebut,
    super.dateFin,
    required super.typePanne,
    required super.priorite,
    required super.statut,
    required super.description,
    super.diagnostic,
    super.solutionApportee,
    required super.coutTotalReparation,
    super.dureeJours,
    super.bienReference,
    super.bienDesignation,
    super.technicienNom,
  });

  factory PanneModel.fromJson(Map<String, dynamic> json) {
    return PanneModel(
      idPanne: json['id_panne'] as int,
      idBien: json['id_bien'] as int,
      idTechnicien: json['id_technicien'] as int,
      dateDeclaration: DateTime.parse(json['date_declaration'] as String),
      dateDebut: json['date_debut'] != null ? DateTime.parse(json['date_debut'] as String) : null,
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin'] as String) : null,
      typePanne: json['type_panne'] as String? ?? 'AUTRE',
      priorite: json['priorite'] as String? ?? 'MOYENNE',
      statut: json['statut'] as String? ?? 'DECLAREE',
      description: json['description'] as String? ?? '',
      diagnostic: json['diagnostic'] as String?,
      solutionApportee: json['solution_apportee'] as String?,
      coutTotalReparation: (json['cout_total_reparation'] as num?)?.toDouble() ?? 0.0,
      dureeJours: json['duree_jours'] as int?,
      bienReference: json['bien_reference'] as String?,
      bienDesignation: json['bien_designation'] as String?,
      technicienNom: json['technicien_nom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_panne': idPanne,
      'id_bien': idBien,
      'id_technicien': idTechnicien,
      'date_declaration': dateDeclaration.toIso8601String(),
      'date_debut': dateDebut?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'type_panne': typePanne,
      'priorite': priorite,
      'statut': statut,
      'description': description,
      'diagnostic': diagnostic,
      'solution_apportee': solutionApportee,
      'cout_total_reparation': coutTotalReparation,
      'duree_jours': dureeJours,
      'bien_reference': bienReference,
      'bien_designation': bienDesignation,
      'technicien_nom': technicienNom,
    };
  }
}
