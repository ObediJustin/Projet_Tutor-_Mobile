import 'package:equatable/equatable.dart';

class LigneBesoin extends Equatable {
  const LigneBesoin({
    required this.idLigne,
    required this.idPiece,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotal,
    this.referencePiece,
    this.designationPiece,
  });

  final int idLigne;
  final int idPiece;
  final int quantite;
  final double prixUnitaire;
  final double prixTotal;
  final String? referencePiece;
  final String? designationPiece;

  @override
  List<Object?> get props => [
        idLigne,
        idPiece,
        quantite,
        prixUnitaire,
        prixTotal,
        referencePiece,
        designationPiece,
      ];
}

class Besoin extends Equatable {
  const Besoin({
    required this.idBesoin,
    required this.idPanne,
    required this.numeroDemande,
    required this.dateCreation,
    required this.montantTotal,
    required this.statut,
    this.observations,
    required this.lignes,
  });

  final int idBesoin;
  final int idPanne;
  final String numeroDemande;
  final DateTime dateCreation;
  final double montantTotal;
  final String statut;
  final String? observations;
  final List<LigneBesoin> lignes;

  bool get enAttente =>
      statut == 'EN_VALIDATION' ||
      statut == 'DG_VALIDE' ||
      statut == 'COMPTABLE_VALIDE';
      
  bool get peutEtreValideParCaisse => 
      statut == 'EN_VALIDATION' || 
      statut == 'DG_VALIDE' || 
      statut == 'COMPTABLE_VALIDE';

  @override
  List<Object?> get props => [
        idBesoin,
        idPanne,
        numeroDemande,
        dateCreation,
        montantTotal,
        statut,
        observations,
        lignes,
      ];
}
