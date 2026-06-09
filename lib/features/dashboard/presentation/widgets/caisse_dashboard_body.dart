import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../domain/entities/role_dashboard_data.dart';
import 'dashboard_stat_card.dart';
import 'quick_action_card.dart';
import 'recent_biens_section.dart';

class CaisseDashboardBody extends StatelessWidget {
  const CaisseDashboardBody({
    super.key,
    required this.data,
  });

  final RoleDashboardData data;

  @override
  Widget build(BuildContext context) {
    final stats = data.caisseStats;
    final title = data.role.label;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tableau de bord $title',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                label: 'Total pièces',
                value: '${stats?.totalPieces ?? 0}',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                label: 'Pièces critiques',
                value: '${stats?.piecesCritiques ?? 0}',
                icon: Icons.warning_amber_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DashboardStatCard(
          label: 'Demandes en attente',
          value: '${stats?.demandesEnAttente ?? 0}',
          icon: Icons.shopping_cart_outlined,
          color: Colors.teal,
        ),
        const SizedBox(height: 20),
        QuickActionCard(
          title: 'Scanner QR Code',
          subtitle: 'Vérifier un bien ou une pièce',
          icon: Icons.qr_code_scanner,
          onTap: () => context.go(AppRouter.homeScanner),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Stock des pièces',
          subtitle: 'Consulter l\'inventaire',
          icon: Icons.inventory_2_outlined,
          onTap: () => context.go(AppRouter.homePieces),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Besoins à traiter',
          subtitle: 'Demandes en attente de validation',
          icon: Icons.shopping_cart_outlined,
          onTap: () => context.go(AppRouter.homeBesoins),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Alertes de stock',
          subtitle: 'Pièces sous le seuil minimum',
          icon: Icons.warning_amber_outlined,
          color: Colors.orange,
          onTap: () => context.push('/pieces/critiques'),
        ),
        const SizedBox(height: 24),
        RecentBiensSection(biens: data.recentBiens),
      ],
    );
  }
}
