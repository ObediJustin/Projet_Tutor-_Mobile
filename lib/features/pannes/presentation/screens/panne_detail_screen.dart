import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pannes_bloc.dart';
import '../../domain/entities/panne.dart';

class PanneDetailScreen extends StatefulWidget {
  final int panneId;

  const PanneDetailScreen({
    super.key,
    required this.panneId,
  });

  @override
  State<PanneDetailScreen> createState() => _PanneDetailScreenState();
}

class _PanneDetailScreenState extends State<PanneDetailScreen> {
  late final PannesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PannesBloc>()..add(LoadPanneDetail(widget.panneId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Color _getStatusColor(String statut) {
    switch (statut.toUpperCase()) {
      case 'DECLAREE':
        return Colors.orange;
      case 'DIAGNOSTIQUEE':
      case 'EN_ATTENTE_PIECES':
      case 'EN_VALIDATION':
        return Colors.amber[700]!;
      case 'EN_COURS':
        return AppConstants.primaryColor;
      case 'TERMINEE':
        return AppConstants.successColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String statut) {
    switch (statut.toUpperCase()) {
      case 'DECLAREE':
        return 'Déclarée (Ouverte)';
      case 'DIAGNOSTIQUEE':
        return 'Diagnostiquée';
      case 'EN_ATTENTE_PIECES':
        return 'En attente pièces';
      case 'EN_VALIDATION':
        return 'En validation';
      case 'EN_COURS':
        return 'En cours d\'intervention';
      case 'TERMINEE':
        return 'Résolue';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
    }
  }

  Color _getPriorityColor(String priorite) {
    switch (priorite.toUpperCase()) {
      case 'BASSE':
        return Colors.green;
      case 'MOYENNE':
        return Colors.blue;
      case 'HAUTE':
        return Colors.orange;
      case 'CRITIQUE':
        return AppConstants.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$min';
  }

  void _updateStatus(String newStatus, String label) {
    _bloc.add(UpdatePanneStatut(idPanne: widget.panneId, statut: newStatus));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la panne'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _bloc.add(LoadPanneDetail(widget.panneId)),
            ),
          ],
        ),
        body: BlocConsumer<PannesBloc, PannesState>(
          listener: (context, state) {
            if (state is PanneStatutUpdated) {
              // Notification locale (SnackBar de succès)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Statut mis à jour avec succès : ${_getStatusLabel(state.panne.statut)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Recharger les détails
              _bloc.add(LoadPanneDetail(widget.panneId));
            } else if (state is PannesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PannesLoading && state is! PanneDetailLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PannesError && state is! PanneDetailLoaded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _bloc.add(LoadPanneDetail(widget.panneId)),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            Panne? panne;
            if (state is PanneDetailLoaded) {
              panne = state.panne;
            } else if (state is PanneStatutUpdated) {
              panne = state.panne;
            }

            if (panne == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isClosed = panne.statut == 'TERMINEE' || panne.statut == 'ANNULEE';
            final isNew = panne.statut == 'DECLAREE';
            final isInProgress = panne.statut == 'EN_COURS';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section Bien Concerné
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.widgets_outlined, color: AppConstants.primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Bien concerné',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          panne.bienDesignation ?? 'Bien sans désignation',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code QR / Réf: ${panne.bienReference ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push('/biens/${panne!.idBien}');
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Consulter la fiche du bien'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Panne Informations
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              panne.typePanne,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(panne.statut).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(panne.statut),
                                style: TextStyle(
                                  color: _getStatusColor(panne.statut),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 18, color: _getPriorityColor(panne.priorite)),
                            const SizedBox(width: 8),
                            Text(
                              'Priorité: ${panne.priorite}',
                              style: TextStyle(
                                color: _getPriorityColor(panne.priorite),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Description du problème',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          panne.description,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Actions (Changement de statut)
                if (!isClosed)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Actions d\'intervention',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          if (isNew) ...[
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus('EN_COURS', 'En cours'),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Démarrer l\'intervention'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ] else if (isInProgress) ...[
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus('TERMINEE', 'Résolue'),
                              icon: const Icon(Icons.check),
                              label: const Text('Marquer comme résolue (Terminée)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Dropdown pour modifier manuellement n'importe quel statut
                          PopupMenuButton<String>(
                            onSelected: (val) => _updateStatus(val, _getStatusLabel(val)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Forcer un autre statut...',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'DECLAREE', child: Text('Déclarée (Ouverte)')),
                              const PopupMenuItem(value: 'EN_COURS', child: Text('En cours')),
                              const PopupMenuItem(value: 'TERMINEE', child: Text('Résolue (Terminée)')),
                              const PopupMenuItem(value: 'ANNULEE', child: Text('Annulée')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Section Historique
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Historique de la panne',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _TimelineItem(
                          icon: Icons.add_alert,
                          color: Colors.orange,
                          title: 'Déclaration de la panne',
                          subtitle: _formatDate(panne.dateDeclaration),
                          isFirst: true,
                        ),
                        _TimelineItem(
                          icon: Icons.play_arrow,
                          color: AppConstants.primaryColor,
                          title: 'Début de l\'intervention',
                          subtitle: _formatDate(panne.dateDebut),
                        ),
                        _TimelineItem(
                          icon: Icons.check_circle,
                          color: AppConstants.successColor,
                          title: 'Résolution (Clôture)',
                          subtitle: _formatDate(panne.dateFin),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
