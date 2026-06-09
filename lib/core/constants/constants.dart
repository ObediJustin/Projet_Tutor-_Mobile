// lib/core/constants/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App Title
  static const String appName = 'Gestion des Immobilisations';

  // Secure Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'logged_in_user';
  static const String recentBiensKey = 'recent_biens';
  static const String lastScannedBienKey = 'last_scanned_bien';
  static const String recentPannesKey = 'recent_pannes';
  static const String recentMaintenancesKey = 'recent_maintenances';

  // UI Theme Colors (Sleek Professional Palette)
  static const Color primaryColor = Color(0xFF6C63FF); // Indigo
  static const Color primaryDarkColor = Color(0xFF4A3AFF);
  static const Color secondaryColor = Color(0xFF00B4D8); // Vibrant Teal
  static const Color accentColor = Color(0xFFF72585); // Neon pink for highlights
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD90429);
  static const Color successColor = Color(0xFF38B000);
  static const Color warningColor = Color(0xFFFFB703);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF00B4D8),
  ];

  // Timeout durations
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}
