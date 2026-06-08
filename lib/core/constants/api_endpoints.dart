/// Chemins relatifs à [ApiConfig.baseUrl] (`/api/v1`).
class ApiEndpoints {
  // Auth
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Biens & QR
  static String bienDetail(int id) => '/biens/$id';
  static const String qrCodeScan = '/qr-code/scan';

  // Pannes
  static const String pannesMesPannes = '/pannes/mes-pannes';
  static const String pannesStatistiques = '/pannes/statistiques/summary';

  // Maintenances
  static const String maintenancesMes = '/maintenances/mes-maintenances';

  // Pièces & besoins
  static const String pieces = '/pieces/';
  static const String besoinsAValider = '/besoins/a-valider';
  static const String besoins = '/besoins/';
}
