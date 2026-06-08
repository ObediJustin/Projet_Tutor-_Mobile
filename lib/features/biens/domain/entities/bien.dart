import 'package:equatable/equatable.dart';

/// Entité complète d'un bien (fiche détail).
class Bien extends Equatable {
  const Bien({
    required this.idBien,
    required this.qrCode,
    required this.typeBien,
    required this.reference,
    required this.nom,
    required this.categorie,
    required this.etat,
    this.localisation,
    this.dateAcquisition,
    this.prixAcquisition,
    this.description,
    this.marque,
    this.modele,
    this.immatriculation,
    this.numeroSerie,
    this.fabricant,
    this.processeur,
  });

  final int idBien;
  final String qrCode;
  final String typeBien;
  final String reference;
  final String nom;
  final String categorie;
  final String etat;
  final String? localisation;
  final DateTime? dateAcquisition;
  final double? prixAcquisition;
  final String? description;
  final String? marque;
  final String? modele;
  final String? immatriculation;
  final String? numeroSerie;
  final String? fabricant;
  final String? processeur;

  @override
  List<Object?> get props => [
        idBien,
        qrCode,
        typeBien,
        reference,
        nom,
        categorie,
        etat,
        localisation,
        dateAcquisition,
        prixAcquisition,
        description,
      ];
}
