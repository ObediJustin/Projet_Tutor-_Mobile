import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/maintenances_bloc.dart';
import '../bloc/maintenances_event.dart';
import '../bloc/maintenances_state.dart';
import '../../domain/entities/maintenance.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final int maintenanceId;

  const MaintenanceDetailScreen({
    super.key,
    required this.maintenanceId,
  });

  @override
  State<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  late final MaintenancesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<MaintenancesBloc>()..add(GetMaintenanceDetailEvent(widget.maintenanceId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Color _getStatusColor(String statut) {
    switch (statut.toUpperCase()) {
      case 'PLANIFIEE':
        return Colors.blue;
      case 'EN_COURS':
        return AppConstants.primaryColor;
      case 'TERMINEE':
      case 'CLOTUREE':
        return AppConstants.successColor;
      case 'ANNULEE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String statut) {
    switch (statut.toUpperCase()) {
      case 'PLANIFIEE':
        return 'Planifiée';
      case 'EN_COURS':
        return 'En cours';
      case 'TERMINEE':
        return 'Terminée / Clôturée';
      case 'CLOTUREE':
        return 'Clôturée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
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

  void _demarrerMaintenance() {
    _bloc.add(DemarrerMaintenanceEvent(widget.maintenanceId));
  }

  void _showTerminerDialog(double currentCout) {
    final formKey = GlobalKey<FormState>();
    final rapportController = TextEditingController();
    final coutController = TextEditingController(text: currentCout.toString());
    final piecesController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clôturer la maintenance'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: rapportController,
                    decoration: const InputDecoration(
                      labelText: 'Rapport d\'intervention *',
                      hintText: 'Décrivez le travail effectué...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Le rapport est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: coutController,
                    decoration: const InputDecoration(
                      labelText: 'Coût final (FC) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Le coût est obligatoire';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: piecesController,
                    decoration: const InputDecoration(
                      labelText: 'Pièces remplacées (optionnel)',
                      hintText: 'ex: Filtre à huile, ampoule...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  _bloc.add(TerminerMaintenanceEvent(
                    id: widget.maintenanceId,
                    rapport: rapportController.text.trim(),
                    cout: double.parse(coutController.text.trim()),
                    piecesRemplacees: piecesController.text.trim().isEmpty
                        ? null
                        : piecesController.text.trim(),
                  ));
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détail Maintenance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _bloc.add(GetMaintenanceDetailEvent(widget.maintenanceId)),
            ),
          ],
        ),
        body: BlocConsumer<MaintenancesBloc, MaintenancesState>(
          listener: (context, state) {
            if (state is MaintenanceActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _bloc.add(GetMaintenanceDetailEvent(widget.maintenanceId));
            } else if (state is MaintenancesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MaintenancesLoading && state is! MaintenanceDetailLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MaintenancesError && state is! MaintenanceDetailLoaded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _bloc.add(GetMaintenanceDetailEvent(widget.maintenanceId)),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            Maintenance? maintenance;
            if (state is MaintenanceDetailLoaded) {
              maintenance = state.maintenance;
            } else if (state is MaintenanceActionSuccess) {
              maintenance = state.maintenance;
            }

            if (maintenance == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isPlanned = maintenance.statut.toUpperCase() == 'PLANIFIEE';
            final isInProgress = maintenance.statut.toUpperCase() == 'EN_COURS';
            final isClosed = maintenance.statut.toUpperCase() == 'TERMINEE' || 
                             maintenance.statut.toUpperCase() == 'CLOTUREE';

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
                          maintenance.bienDesignation ?? 'Bien #${maintenance.idBien}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push('/biens/${maintenance!.idBien}');
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Consulter la fiche du bien'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Maintenance Informations
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
                              maintenance.typeMaintenance,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(maintenance.statut).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(maintenance.statut),
                                style: TextStyle(
                                  color: _getStatusColor(maintenance.statut),
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
                        Text(
                          'Description :',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          maintenance.description,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        if (maintenance.observation != null && maintenance.observation!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Observation / Note interne :',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            maintenance.observation!,
                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ],
                        if (maintenance.piecesRemplacees != null && maintenance.piecesRemplacees!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Pièces remplacées :',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            maintenance.piecesRemplacees!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        if (maintenance.rapport != null && maintenance.rapport!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Rapport d\'intervention :',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            maintenance.rapport!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Coût et Périodicité
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Coût :',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${maintenance.cout.toStringAsFixed(2)} FC',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (maintenance.periodiciteJours != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Périodicité :'),
                              Text('Tous les ${maintenance.periodiciteJours} jours'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Actions d'intervention
                if (!isClosed)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Actions de maintenance',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          if (isPlanned)
                            ElevatedButton.icon(
                              onPressed: _demarrerMaintenance,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Démarrer la maintenance'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          else if (isInProgress)
                            ElevatedButton.icon(
                              onPressed: () => _showTerminerDialog(maintenance!.cout),
                              icon: const Icon(Icons.check),
                              label: const Text('Terminer & Clôturer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Section Historique (Timeline)
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
                              'Historique',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _TimelineItem(
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                          title: 'Date planifiée',
                          subtitle: _formatDate(maintenance.datePlanifiee),
                          isFirst: true,
                        ),
                        _TimelineItem(
                          icon: Icons.play_arrow,
                          color: AppConstants.primaryColor,
                          title: 'Début réel d\'intervention',
                          subtitle: _formatDate(maintenance.dateDebutReelle),
                        ),
                        _TimelineItem(
                          icon: Icons.check_circle,
                          color: AppConstants.successColor,
                          title: 'Fin réelle (Clôture)',
                          subtitle: _formatDate(maintenance.dateFinReelle),
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
