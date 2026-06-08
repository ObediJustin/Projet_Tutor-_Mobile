import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/bien.dart';
import '../../domain/usecases/get_bien_by_id_usecase.dart';

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
  final GetBienByIdUseCase _getBienByIdUseCase = getIt<GetBienByIdUseCase>();
  late Future<Bien> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadBien();
  }

  Future<Bien> _loadBien() async {
    final result = await _getBienByIdUseCase(widget.bienId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (bien) => bien,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche bien'),
      ),
      body: FutureBuilder<Bien>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _loadBien()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bien = snapshot.data!;

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
