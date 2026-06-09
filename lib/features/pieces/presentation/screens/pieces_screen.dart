import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../bloc/pieces_bloc.dart';
import '../bloc/pieces_event.dart';
import '../bloc/pieces_state.dart';

class PiecesScreen extends StatelessWidget {
  const PiecesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PiecesBloc>(
      create: (context) => getIt<PiecesBloc>()..add(const LoadPiecesEvent()),
      child: const _PiecesView(),
    );
  }
}

class _PiecesView extends StatefulWidget {
  const _PiecesView();

  @override
  State<_PiecesView> createState() => _PiecesViewState();
}

class _PiecesViewState extends State<_PiecesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock des pièces'),
        actions: [
          BlocBuilder<PiecesBloc, PiecesState>(
            builder: (context, state) {
              if (state is PiecesLoaded) {
                return Row(
                  children: [
                    const Text('Critiques', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: state.showOnlyCritiques,
                      onChanged: (value) {
                        context.read<PiecesBloc>().add(FilterCritiquesEvent(value));
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une pièce...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                context.read<PiecesBloc>().add(SearchPiecesEvent(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PiecesBloc, PiecesState>(
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
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune pièce trouvée.',
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                      style: TextStyle(
                                        color: piece.estCritique ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(' / Min: ${piece.stockMinimum}'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: piece.estCritique
                                ? const Icon(Icons.warning_amber_rounded, color: Colors.red)
                                : const Icon(Icons.check_circle_outline, color: Colors.green),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
