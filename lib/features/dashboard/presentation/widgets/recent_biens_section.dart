import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../biens/domain/entities/bien_summary.dart';

class RecentBiensSection extends StatelessWidget {
  const RecentBiensSection({
    super.key,
    required this.biens,
  });

  final List<BienSummary> biens;

  @override
  Widget build(BuildContext context) {
    if (biens.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aucun bien consulté récemment. Scannez un QR code pour commencer.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biens consultés récemment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...biens.map(
          (bien) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(bien.typeBien.substring(0, 1).toUpperCase()),
              ),
              title: Text(bien.nom),
              subtitle: Text(
                [bien.etat, bien.localisation]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(' • '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRouter.bienDetailPath(bien.idBien)),
            ),
          ),
        ),
      ],
    );
  }
}
