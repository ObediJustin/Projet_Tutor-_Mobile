import 'package:equatable/equatable.dart';

class Panne extends Equatable {
  final int idPanne;
  final int idBien;
  final int idTechnicien;
  final DateTime dateDeclaration;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String typePanne;
  final String priorite;
  final String statut;
  final String description;
  final String? diagnostic;
  final String? solutionApportee;
  final double coutTotalReparation;
  final int? dureeJours;
  final String? bienReference;
  final String? bienDesignation;
  final String? technicienNom;

  const Panne({
    required this.idPanne,
    required this.idBien,
    required this.idTechnicien,
    required this.dateDeclaration,
    this.dateDebut,
    this.dateFin,
    required this.typePanne,
    required this.priorite,
    required this.statut,
    required this.description,
    this.diagnostic,
    this.solutionApportee,
    required this.coutTotalReparation,
    this.dureeJours,
    this.bienReference,
    this.bienDesignation,
    this.technicienNom,
  });

  @override
  List<Object?> get props => [
        idPanne,
        idBien,
        idTechnicien,
        dateDeclaration,
        dateDebut,
        dateFin,
        typePanne,
        priorite,
        statut,
        description,
        diagnostic,
        solutionApportee,
        coutTotalReparation,
        dureeJours,
        bienReference,
        bienDesignation,
        technicienNom,
      ];
}
