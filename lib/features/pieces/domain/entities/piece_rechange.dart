import 'package:equatable/equatable.dart';

class PieceRechange extends Equatable {
  const PieceRechange({
    required this.idPiece,
    required this.designation,
    required this.stockActuel,
    required this.stockMinimum,
    required this.prixAchat,
    this.numeroSerie,
    this.prixVente,
    this.compatibleAvec,
    this.compatibleDisplay,
    this.fournisseur,
    this.estActive = true,
    this.reference,
  });

  final int idPiece;
  final String designation;
  final int stockActuel;
  final int stockMinimum;
  final double prixAchat;
  final String? numeroSerie;
  final double? prixVente;
  final String? compatibleAvec;
  final String? compatibleDisplay;
  final String? fournisseur;
  final bool estActive;
  final String? reference;

  bool get estCritique => stockActuel <= stockMinimum;

  @override
  List<Object?> get props => [
        idPiece,
        designation,
        stockActuel,
        stockMinimum,
        prixAchat,
        numeroSerie,
        prixVente,
        compatibleAvec,
        compatibleDisplay,
        fournisseur,
        estActive,
        reference,
      ];
}
