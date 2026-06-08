import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Résout l'URL de base de l'API selon la plateforme.
///
/// Backend : préfixe global `/api/v1` (voir `backend/app/main.py`).
class ApiConfig {
  static const String apiPrefix = '/api/v1';
  static const int defaultPort = 8000;

  static String get baseUrl {
    final fromEnv = dotenv.env['BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return _platformDefaultBaseUrl;
  }

  static String get _platformDefaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$defaultPort$apiPrefix';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Adresse spéciale de l'émulateur Android vers la machine hôte.
      return 'http://10.0.2.2:$defaultPort$apiPrefix';
    }

    // Windows, macOS, Linux, iOS Simulator.
    return 'http://localhost:$defaultPort$apiPrefix';
  }
}
