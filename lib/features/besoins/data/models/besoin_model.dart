import '../../domain/entities/besoin.dart';

class LigneBesoinModel extends LigneBesoin {
  const LigneBesoinModel({
    required super.idLigne,
    required super.idPiece,
    required super.quantite,
    required super.prixUnitaire,
    required super.prixTotal,
    super.referencePiece,
    super.designationPiece,
  });

  factory LigneBesoinModel.fromJson(Map<String, dynamic> json) {
    return LigneBesoinModel(
      idLigne: json['id_ligne'] as int,
      idPiece: json['id_piece'] as int,
      quantite: json['quantite'] as int,
      prixUnitaire: (json['prix_unitaire'] as num).toDouble(),
      prixTotal: (json['prix_total'] as num).toDouble(),
      referencePiece: json['reference_piece'] as String?,
      designationPiece: json['designation_piece'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ligne': idLigne,
      'id_piece': idPiece,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'prix_total': prixTotal,
      'reference_piece': referencePiece,
      'designation_piece': designationPiece,
    };
  }
}

class BesoinModel extends Besoin {
  const BesoinModel({
    required super.idBesoin,
    required super.idPanne,
    required super.numeroDemande,
    required super.dateCreation,
    required super.montantTotal,
    required super.statut,
    super.observations,
    required super.lignes,
  });

  factory BesoinModel.fromJson(Map<String, dynamic> json) {
    return BesoinModel(
      idBesoin: json['id_besoin'] as int,
      idPanne: json['id_panne'] as int,
      numeroDemande: json['numero_demande'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      montantTotal: (json['montant_total'] as num).toDouble(),
      statut: json['statut'] as String,
      observations: json['observations'] as String?,
      lignes: (json['lignes'] as List<dynamic>)
          .map((e) => LigneBesoinModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_besoin': idBesoin,
      'id_panne': idPanne,
      'numero_demande': numeroDemande,
      'date_creation': dateCreation.toIso8601String(),
      'montant_total': montantTotal,
      'statut': statut,
      'observations': observations,
      'lignes': lignes.map((e) => (e as LigneBesoinModel).toJson()).toList(),
    };
  }
}
