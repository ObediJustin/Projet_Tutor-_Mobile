import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../bloc/pieces_bloc.dart';
import '../bloc/pieces_event.dart';
import '../bloc/pieces_state.dart';

class PiecesCritiquesScreen extends StatelessWidget {
  const PiecesCritiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PiecesBloc>(
      create: (context) => getIt<PiecesBloc>()..add(const FilterCritiquesEvent(true))..add(const LoadPiecesEvent()),
      child: const _PiecesCritiquesView(),
    );
  }
}

class _PiecesCritiquesView extends StatelessWidget {
  const _PiecesCritiquesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pièces critiques'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PiecesBloc, PiecesState>(
        builder: (context, state) {
          if (state is PiecesInitial || state is PiecesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PiecesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PiecesBloc>().add(const LoadPiecesEvent(forceRefresh: true));
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is PiecesLoaded) {
            if (state.pieces.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune pièce en stock critique.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PiecesBloc>().add(const LoadPiecesEvent(forceRefresh: true));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.pieces.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final piece = state.pieces[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                    child: ListTile(
                      onTap: () => context.push('/pieces/${piece.idPiece}'),
                      title: Text(
                        piece.designation,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Réf: ${piece.reference ?? 'N/A'}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Stock: '),
                              Text(
                                '${piece.stockActuel}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(' / Min: ${piece.stockMinimum}'),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
