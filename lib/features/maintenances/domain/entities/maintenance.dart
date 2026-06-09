import 'package:equatable/equatable.dart';

/// Entité complète d'une maintenance.
class Maintenance extends Equatable {
  final int idMaintenance;
  final int idBien;
  final int idTechnicien;
  final String typeMaintenance;
  final String statut;
  final DateTime datePlanifiee;
  final DateTime? dateDebutReelle;
  final DateTime? dateFinReelle;
  final int? periodiciteJours;
  final double cout;
  final String description;
  final String? observation;
  final String? piecesRemplacees;
  final String? rapport;
  final DateTime dateCreation;
  final String? bienDesignation;
  final String? technicienNom;
  final int? dureeJours;
  final int? joursRestants;

  const Maintenance({
    required this.idMaintenance,
    required this.idBien,
    required this.idTechnicien,
    required this.typeMaintenance,
    required this.statut,
    required this.datePlanifiee,
    this.dateDebutReelle,
    this.dateFinReelle,
    this.periodiciteJours,
    required this.cout,
    required this.description,
    this.observation,
    this.piecesRemplacees,
    this.rapport,
    required this.dateCreation,
    this.bienDesignation,
    this.technicienNom,
    this.dureeJours,
    this.joursRestants,
  });

  @override
  List<Object?> get props => [
        idMaintenance,
        idBien,
        idTechnicien,
        typeMaintenance,
        statut,
        datePlanifiee,
        dateDebutReelle,
        dateFinReelle,
        periodiciteJours,
        cout,
        description,
        observation,
        piecesRemplacees,
        rapport,
        dateCreation,
        bienDesignation,
        technicienNom,
        dureeJours,
        joursRestants,
      ];
}
