import '../../domain/entities/piece_rechange.dart';

class PieceRechangeModel extends PieceRechange {
  const PieceRechangeModel({
    required super.idPiece,
    required super.designation,
    required super.stockActuel,
    required super.stockMinimum,
    required super.prixAchat,
    super.numeroSerie,
    super.prixVente,
    super.compatibleAvec,
    super.compatibleDisplay,
    super.fournisseur,
    super.estActive = true,
    super.reference,
  });

  factory PieceRechangeModel.fromJson(Map<String, dynamic> json) {
    return PieceRechangeModel(
      idPiece: json['id_piece'] as int,
      designation: json['designation'] as String,
      stockActuel: (json['stock_actuel'] as num?)?.toInt() ?? 0,
      stockMinimum: (json['stock_minimum'] as num?)?.toInt() ?? 0,
      prixAchat: (json['prix_achat'] as num?)?.toDouble() ?? 0.0,
      numeroSerie: json['numero_serie'] as String?,
      prixVente: (json['prix_vente'] as num?)?.toDouble(),
      compatibleAvec: json['compatible_avec'] as String?,
      compatibleDisplay: json['compatible_display'] as String?,
      fournisseur: json['fournisseur'] as String?,
      estActive: json['est_active'] as bool? ?? true,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_piece': idPiece,
      'designation': designation,
      'stock_actuel': stockActuel,
      'stock_minimum': stockMinimum,
      'prix_achat': prixAchat,
      'numero_serie': numeroSerie,
      'prix_vente': prixVente,
      'compatible_avec': compatibleAvec,
      'compatible_display': compatibleDisplay,
      'fournisseur': fournisseur,
      'est_active': estActive,
      'reference': reference,
    };
  }
}
