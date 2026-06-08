import '../../domain/entities/bien.dart';
import '../../domain/entities/bien_summary.dart';

class BienModel extends Bien {
  const BienModel({
    required super.idBien,
    required super.qrCode,
    required super.typeBien,
    required super.reference,
    required super.nom,
    required super.categorie,
    required super.etat,
    super.localisation,
    super.dateAcquisition,
    super.prixAcquisition,
    super.description,
    super.marque,
    super.modele,
    super.immatriculation,
    super.numeroSerie,
    super.fabricant,
    super.processeur,
  });

  factory BienModel.fromJson(Map<String, dynamic> json) {
    final typeBien = json['type_bien'] as String? ?? 'bien';
    final marque = json['marque'] as String? ?? json['fabricant'] as String?;
    final modele = json['modele'] as String?;
    final immatriculation = json['immatriculation'] as String?;
    final numeroSerie = json['numero_serie'] as String?;
    final description = json['description'] as String?;

    return BienModel(
      idBien: json['id_bien'] as int,
      qrCode: json['qr_code'] as String? ?? '',
      typeBien: typeBien,
      reference: json['qr_code'] as String? ?? 'BIEN-${json['id_bien']}',
      nom: _buildNom(
        typeBien: typeBien,
        marque: marque,
        modele: modele,
        immatriculation: immatriculation,
        numeroSerie: numeroSerie,
        description: description,
      ),
      categorie: _formatCategorie(typeBien),
      etat: json['etat']?.toString() ?? 'INCONNU',
      localisation: json['localisation'] as String?,
      dateAcquisition: json['date_acquisition'] != null
          ? DateTime.tryParse(json['date_acquisition'] as String)
          : null,
      prixAcquisition: _parseDouble(json['prix_acquisition']),
      description: description,
      marque: marque,
      modele: modele,
      immatriculation: immatriculation,
      numeroSerie: numeroSerie,
      fabricant: json['fabricant'] as String?,
      processeur: json['processeur'] as String?,
    );
  }

  BienSummary toSummary() {
    return BienSummary(
      idBien: idBien,
      qrCode: qrCode,
      typeBien: typeBien,
      nom: nom,
      marque: marque,
      modele: modele,
      etat: etat,
      localisation: localisation,
      consultedAt: DateTime.now(),
    );
  }

  static BienSummary summaryFromScanJson(Map<String, dynamic> json) {
    final marque = json['marque'] as String?;
    final modele = json['modele'] as String?;
    final typeBien = json['type_bien'] as String? ?? 'bien';

    return BienSummary(
      idBien: json['id_bien'] as int,
      qrCode: json['qr_code'] as String? ?? '',
      typeBien: typeBien,
      nom: _buildNom(
        typeBien: typeBien,
        marque: marque,
        modele: modele,
      ),
      marque: marque,
      modele: modele,
      etat: json['etat']?.toString(),
      localisation: json['localisation'] as String?,
      consultedAt: DateTime.now(),
    );
  }

  static String _buildNom({
    required String typeBien,
    String? marque,
    String? modele,
    String? immatriculation,
    String? numeroSerie,
    String? description,
  }) {
    final label = [marque, modele].where((e) => e != null && e.isNotEmpty).join(' ');
    if (label.isNotEmpty) return label;
    if (immatriculation != null && immatriculation.isNotEmpty) {
      return immatriculation;
    }
    if (numeroSerie != null && numeroSerie.isNotEmpty) return numeroSerie;
    if (description != null && description.isNotEmpty) return description;
    return _formatCategorie(typeBien);
  }

  static String _formatCategorie(String typeBien) {
    switch (typeBien.toLowerCase()) {
      case 'vehicule':
        return 'Véhicule';
      case 'machine':
        return 'Machine';
      case 'ordinateur':
        return 'Ordinateur';
      default:
        return typeBien;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
