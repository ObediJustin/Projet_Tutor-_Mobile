import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../domain/entities/role_dashboard_data.dart';
import 'dashboard_stat_card.dart';
import 'quick_action_card.dart';
import 'recent_biens_section.dart';

class TechnicienDashboardBody extends StatelessWidget {
  const TechnicienDashboardBody({
    super.key,
    required this.data,
  });

  final RoleDashboardData data;

  @override
  Widget build(BuildContext context) {
    final stats = data.technicienStats;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tableau de bord Technicien',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                label: 'Pannes ouvertes',
                value: '${stats?.pannesOuvertes ?? 0}',
                icon: Icons.build_circle_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                label: 'Maintenances en cours',
                value: '${stats?.maintenancesEnCours ?? 0}',
                icon: Icons.handyman_outlined,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        QuickActionCard(
          title: 'Scanner QR Code',
          subtitle: 'Identifier un bien sur le terrain',
          icon: Icons.qr_code_scanner,
          onTap: () => context.go(AppRouter.homeScanner),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Mes Pannes',
          subtitle: 'Suivi des interventions',
          icon: Icons.build_circle_outlined,
          onTap: () => context.go(AppRouter.homePannes),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Mes Maintenances',
          subtitle: 'Planification et suivi',
          icon: Icons.handyman_outlined,
          onTap: () => context.go(AppRouter.homeMaintenances),
        ),
        const SizedBox(height: 24),
        RecentBiensSection(biens: data.recentBiens),
      ],
    );
  }
}
