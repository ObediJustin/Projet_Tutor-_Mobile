import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/piece_rechange.dart';
import '../../domain/usecases/get_pieces.dart';

class PieceDetailScreen extends StatefulWidget {
  const PieceDetailScreen({super.key, required this.pieceId});
  final int pieceId;

  @override
  State<PieceDetailScreen> createState() => _PieceDetailScreenState();
}

class _PieceDetailScreenState extends State<PieceDetailScreen> {
  PieceRechange? _piece;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPiece();
  }

  Future<void> _loadPiece() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getPieceById = getIt<GetPieceById>();
    final result = await getPieceById(widget.pieceId);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      },
      (piece) {
        if (mounted) {
          setState(() {
            _piece = piece;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la pièce'),
      ),
      body: _buildBody(),
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
              onPressed: _loadPiece,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_piece == null) {
      return const Center(child: Text('Pièce introuvable'));
    }

    final p = _piece!;

    return RefreshIndicator(
      onRefresh: _loadPiece,
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
                  Text(
                    p.designation,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Référence: ${p.reference ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  if (p.fournisseur != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Fournisseur: ${p.fournisseur}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Stock',
            icon: Icons.inventory_2_outlined,
            children: [
              _buildInfoRow('En stock', '${p.stockActuel}', 
                valueColor: p.estCritique ? Colors.red : Colors.green),
              _buildInfoRow('Seuil minimum', '${p.stockMinimum}'),
              if (p.estCritique)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Stock critique', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Compatibilité',
            icon: Icons.build_circle_outlined,
            children: [
              _buildInfoRow('Type', p.compatibleDisplay ?? p.compatibleAvec ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Prix',
            icon: Icons.euro_outlined,
            children: [
              _buildInfoRow('Prix d\'achat', '${p.prixAchat.toStringAsFixed(2)} €'),
              if (p.prixVente != null)
                _buildInfoRow('Prix de vente', '${p.prixVente!.toStringAsFixed(2)} €'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
