import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/besoin.dart';
import '../../domain/usecases/besoins_usecases.dart';
import '../bloc/besoins_bloc.dart';
import '../bloc/besoins_event.dart';
import '../bloc/besoins_state.dart';

class BesoinDetailScreen extends StatelessWidget {
  const BesoinDetailScreen({super.key, required this.besoinId});
  final int besoinId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BesoinsBloc>(),
      child: _BesoinDetailView(besoinId: besoinId),
    );
  }
}

class _BesoinDetailView extends StatefulWidget {
  const _BesoinDetailView({required this.besoinId});
  final int besoinId;

  @override
  State<_BesoinDetailView> createState() => _BesoinDetailViewState();
}

class _BesoinDetailViewState extends State<_BesoinDetailView> {
  Besoin? _besoin;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBesoin();
  }

  Future<void> _loadBesoin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getBesoinById = getIt<GetBesoinById>();
    final result = await getBesoinById(widget.besoinId);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      },
      (besoin) {
        if (mounted) {
          setState(() {
            _besoin = besoin;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BesoinsBloc, BesoinsState>(
      listener: (context, state) {
        if (state is BesoinsLoaded) {
          if (state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionMessage!), backgroundColor: Colors.green),
            );
            _loadBesoin(); // Recharger le besoin après validation
          }
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionError!), backgroundColor: Colors.red),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails du besoin'),
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBesoin,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_besoin == null) {
      return const Center(child: Text('Besoin introuvable'));
    }

    final b = _besoin!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Color statutColor;
    if (b.enAttente) {
      statutColor = Colors.orange;
    } else if (b.statut == 'REJETE') {
      statutColor = Colors.red;
    } else {
      statutColor = Colors.green;
    }

    return RefreshIndicator(
      onRefresh: _loadBesoin,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
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
                        'Demande ${b.numeroDemande}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statutColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statutColor),
                        ),
                        child: Text(
                          b.statut.replaceAll('_', ' '),
                          style: TextStyle(
                            color: statutColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Date', dateFormat.format(b.dateCreation)),
                  _buildInfoRow('Montant Total', '${b.montantTotal.toStringAsFixed(2)} €'),
                  if (b.observations != null && b.observations!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Observations:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(b.observations!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pièces demandées',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...b.lignes.map((ligne) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.build, color: Colors.white, size: 20),
                ),
                title: Text(
                  ligne.designationPiece ?? 'Pièce #${ligne.idPiece}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Réf: ${ligne.referencePiece ?? 'N/A'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Qté: ${ligne.quantite}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${ligne.prixTotal.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_besoin == null || !_besoin!.peutEtreValideParCaisse) {
      return null;
    }

    return BlocBuilder<BesoinsBloc, BesoinsState>(
      builder: (context, state) {
        final isLoading = state is BesoinsLoaded && state.isActionLoading;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => _showValidationDialog(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Rejeter'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _showValidationDialog(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Valider'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showValidationDialog(bool isValidation) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isValidation ? 'Valider le besoin' : 'Rejeter le besoin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isValidation
                  ? 'Êtes-vous sûr de vouloir valider cette demande ?'
                  : 'Êtes-vous sûr de vouloir rejeter cette demande ?'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (Optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<BesoinsBloc>().add(ValiderBesoinEvent(
                  idBesoin: widget.besoinId,
                  decision: isValidation ? 'APPROUVE' : 'REJETE',
                  commentaire: commentController.text,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isValidation ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(isValidation ? 'Confirmer Validation' : 'Confirmer Rejet'),
            ),
          ],
        );
      },
    );
  }
}
