/// Rôles alignés sur le backend (`scripts/seed_roles.py`).
enum AppRole {
  technicien,
  caisse,
  magasinier,
  admin,
  dg,
  comptable,
  unknown;

  static AppRole fromString(String? value) {
    if (value == null || value.isEmpty) return AppRole.unknown;
    switch (value.toUpperCase()) {
      case 'TECHNICIEN':
        return AppRole.technicien;
      case 'CAISSE':
        return AppRole.caisse;
      case 'MAGASINIER':
        return AppRole.magasinier;
      case 'ADMIN':
        return AppRole.admin;
      case 'DG':
        return AppRole.dg;
      case 'COMPTABLE':
        return AppRole.comptable;
      default:
        return AppRole.unknown;
    }
  }

  bool get isTechnicien => this == AppRole.technicien;

  bool get isCaisseOrMagasinier =>
      this == AppRole.caisse || this == AppRole.magasinier;

  bool get isConsultationRole =>
      this == AppRole.admin || this == AppRole.dg || this == AppRole.comptable;

  String get label {
    switch (this) {
      case AppRole.technicien:
        return 'Technicien';
      case AppRole.caisse:
        return 'Caisse';
      case AppRole.magasinier:
        return 'Magasinier';
      case AppRole.admin:
        return 'Administrateur';
      case AppRole.dg:
        return 'Direction Générale';
      case AppRole.comptable:
        return 'Comptable';
      case AppRole.unknown:
        return 'Utilisateur';
    }
  }
}
