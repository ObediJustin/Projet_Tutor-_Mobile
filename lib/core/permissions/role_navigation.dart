import 'package:flutter/material.dart';

import '../enums/app_role.dart';
import '../routes/app_router.dart';

class RoleNavItem {
  const RoleNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class RoleNavigation {
  static List<RoleNavItem> itemsFor(AppRole role) {
    switch (role) {
      case AppRole.technicien:
        return const [
          RoleNavItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            route: AppRouter.homeDashboard,
          ),
          RoleNavItem(
            label: 'Scanner',
            icon: Icons.qr_code_scanner,
            route: AppRouter.homeScanner,
          ),
          RoleNavItem(
            label: 'Pannes',
            icon: Icons.build_circle_outlined,
            route: AppRouter.homePannes,
          ),
          RoleNavItem(
            label: 'Maintenances',
            icon: Icons.handyman_outlined,
            route: AppRouter.homeMaintenances,
          ),
          RoleNavItem(
            label: 'Profil',
            icon: Icons.person_outline,
            route: AppRouter.homeProfil,
          ),
        ];
      case AppRole.caisse:
      case AppRole.magasinier:
        return const [
          RoleNavItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            route: AppRouter.homeDashboard,
          ),
          RoleNavItem(
            label: 'Scanner',
            icon: Icons.qr_code_scanner,
            route: AppRouter.homeScanner,
          ),
          RoleNavItem(
            label: 'Pièces',
            icon: Icons.inventory_2_outlined,
            route: AppRouter.homePieces,
          ),
          RoleNavItem(
            label: 'Besoins',
            icon: Icons.shopping_cart_outlined,
            route: AppRouter.homeBesoins,
          ),
          RoleNavItem(
            label: 'Profil',
            icon: Icons.person_outline,
            route: AppRouter.homeProfil,
          ),
        ];
      case AppRole.admin:
      case AppRole.dg:
      case AppRole.comptable:
        return const [
          RoleNavItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            route: AppRouter.homeDashboard,
          ),
          RoleNavItem(
            label: 'Scanner',
            icon: Icons.qr_code_scanner,
            route: AppRouter.homeScanner,
          ),
          RoleNavItem(
            label: 'Profil',
            icon: Icons.person_outline,
            route: AppRouter.homeProfil,
          ),
        ];
      case AppRole.unknown:
        return const [
          RoleNavItem(
            label: 'Accueil',
            icon: Icons.home_outlined,
            route: AppRouter.homeDashboard,
          ),
          RoleNavItem(
            label: 'Scanner',
            icon: Icons.qr_code_scanner,
            route: AppRouter.homeScanner,
          ),
          RoleNavItem(
            label: 'Profil',
            icon: Icons.person_outline,
            route: AppRouter.homeProfil,
          ),
        ];
    }
  }
}
