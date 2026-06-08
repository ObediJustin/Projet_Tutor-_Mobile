import 'package:equatable/equatable.dart';

/// Représentation légère d'un bien (scan QR, historique local).
class BienSummary extends Equatable {
  const BienSummary({
    required this.idBien,
    required this.qrCode,
    required this.typeBien,
    required this.nom,
    this.marque,
    this.modele,
    this.etat,
    this.localisation,
    this.consultedAt,
  });

  final int idBien;
  final String qrCode;
  final String typeBien;
  final String nom;
  final String? marque;
  final String? modele;
  final String? etat;
  final String? localisation;
  final DateTime? consultedAt;

  String get categorie => typeBien;

  Map<String, dynamic> toJson() => {
        'id_bien': idBien,
        'qr_code': qrCode,
        'type_bien': typeBien,
        'nom': nom,
        'marque': marque,
        'modele': modele,
        'etat': etat,
        'localisation': localisation,
        'consulted_at': consultedAt?.toIso8601String(),
      };

  factory BienSummary.fromJson(Map<String, dynamic> json) {
    return BienSummary(
      idBien: json['id_bien'] as int,
      qrCode: json['qr_code'] as String? ?? '',
      typeBien: json['type_bien'] as String? ?? 'bien',
      nom: json['nom'] as String? ?? 'Bien ${json['id_bien']}',
      marque: json['marque'] as String?,
      modele: json['modele'] as String?,
      etat: json['etat']?.toString(),
      localisation: json['localisation'] as String?,
      consultedAt: json['consulted_at'] != null
          ? DateTime.tryParse(json['consulted_at'] as String)
          : null,
    );
  }

  BienSummary copyWith({DateTime? consultedAt}) {
    return BienSummary(
      idBien: idBien,
      qrCode: qrCode,
      typeBien: typeBien,
      nom: nom,
      marque: marque,
      modele: modele,
      etat: etat,
      localisation: localisation,
      consultedAt: consultedAt ?? this.consultedAt,
    );
  }

  @override
  List<Object?> get props => [
        idBien,
        qrCode,
        typeBien,
        nom,
        marque,
        modele,
        etat,
        localisation,
        consultedAt,
      ];
}
