import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/app_role.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/biens_bloc.dart';
import '../bloc/biens_event.dart';
import '../bloc/biens_state.dart';

class BienDetailScreen extends StatefulWidget {
  const BienDetailScreen({
    super.key,
    required this.bienId,
  });

  final int bienId;

  @override
  State<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends State<BienDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BiensBloc>().add(LoadBienDetail(widget.bienId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche bien'),
      ),
      body: BlocBuilder<BiensBloc, BiensState>(
        builder: (context, state) {
          if (state is BiensLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BiensError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<BiensBloc>().add(LoadBienDetail(widget.bienId)),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! BienDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final bien = state.bien;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bien.nom,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(bien.etat),
                        backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _InfoTile(label: 'Référence', value: bien.reference),
              _InfoTile(label: 'Catégorie', value: bien.categorie),
              _InfoTile(label: 'État', value: bien.etat),
              _InfoTile(label: 'Localisation', value: bien.localisation ?? '—'),
              _InfoTile(
                label: 'Date acquisition',
                value: bien.dateAcquisition != null
                    ? _formatDate(bien.dateAcquisition!)
                    : '—',
              ),
              _InfoTile(
                label: 'Valeur acquisition',
                value: bien.prixAcquisition != null
                    ? '${bien.prixAcquisition!.toStringAsFixed(2)} FC'
                    : '—',
              ),
              if (bien.description != null && bien.description!.isNotEmpty)
                _InfoTile(label: 'Description', value: bien.description!),
              if (bien.marque != null)
                _InfoTile(label: 'Marque', value: bien.marque!),
              if (bien.modele != null)
                _InfoTile(label: 'Modèle', value: bien.modele!),
              if (bien.immatriculation != null)
                _InfoTile(label: 'Immatriculation', value: bien.immatriculation!),
              if (bien.numeroSerie != null)
                _InfoTile(label: 'N° série', value: bien.numeroSerie!),
              if (bien.fabricant != null)
                _InfoTile(label: 'Fabricant', value: bien.fabricant!),
              if (bien.processeur != null)
                _InfoTile(label: 'Processeur', value: bien.processeur!),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final authState = context.watch<AuthBloc>().state;
                  if (authState is Authenticated) {
                    final role = authState.user.appRole;
                    if (role == AppRole.technicien || role == AppRole.dg || role == AppRole.admin) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push(AppRouter.declarerPannePath(bien.idBien));
                          },
                          icon: const Icon(Icons.error_outline),
                          label: const Text('Déclarer une panne'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
