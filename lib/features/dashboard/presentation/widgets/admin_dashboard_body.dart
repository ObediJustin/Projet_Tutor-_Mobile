import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../domain/entities/role_dashboard_data.dart';
import 'dashboard_stat_card.dart';
import 'quick_action_card.dart';
import 'recent_biens_section.dart';

class AdminDashboardBody extends StatelessWidget {
  const AdminDashboardBody({
    super.key,
    required this.data,
  });

  final RoleDashboardData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tableau de bord ${data.role.label}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                label: 'Total biens',
                value: '${summary?.totalBiens ?? 0}',
                icon: Icons.inventory_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                label: 'Pannes en cours',
                value: '${summary?.pannesEnCours ?? 0}',
                icon: Icons.build_circle_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        if (summary != null && summary.statistiquesBiens.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Répartition du parc',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...summary.statistiquesBiens.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        QuickActionCard(
          title: 'Scanner QR Code',
          subtitle: 'Consulter un bien rapidement',
          icon: Icons.qr_code_scanner,
          onTap: () => context.go(AppRouter.homeScanner),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Consultation d\'un bien',
          subtitle: 'Reprendre le dernier bien scanné',
          icon: Icons.search,
          onTap: () {
            final last = data.recentBiens.isNotEmpty ? data.recentBiens.first : null;
            if (last != null) {
              context.push(AppRouter.bienDetailPath(last.idBien));
            } else {
              context.go(AppRouter.homeScanner);
            }
          },
        ),
        const SizedBox(height: 24),
        RecentBiensSection(biens: data.recentBiens),
      ],
    );
  }
}
