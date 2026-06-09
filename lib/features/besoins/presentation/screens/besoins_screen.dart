import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../bloc/besoins_bloc.dart';
import '../bloc/besoins_event.dart';
import '../bloc/besoins_state.dart';

class BesoinsScreen extends StatelessWidget {
  const BesoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BesoinsBloc>(
      create: (context) => getIt<BesoinsBloc>()..add(const LoadBesoinsAValiderEvent()),
      child: const _BesoinsView(),
    );
  }
}

class _BesoinsView extends StatefulWidget {
  const _BesoinsView();

  @override
  State<_BesoinsView> createState() => _BesoinsViewState();
}

class _BesoinsViewState extends State<_BesoinsView> {
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
        title: const Text('Besoins à traiter'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher N° de demande...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                context.read<BesoinsBloc>().add(SearchBesoinsEvent(value));
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<BesoinsBloc, BesoinsState>(
            builder: (context, state) {
              if (state is BesoinsLoaded) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'Tous', 'ALL', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'En attente', 'EN_ATTENTE', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Validés', 'VALIDE', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Rejetés', 'REJETE', state.statusFilter),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<BesoinsBloc, BesoinsState>(
              builder: (context, state) {
                if (state is BesoinsInitial || state is BesoinsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BesoinsError) {
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
                            context.read<BesoinsBloc>().add(const LoadBesoinsAValiderEvent(forceRefresh: true));
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BesoinsLoaded) {
                  if (state.besoins.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun besoin trouvé.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BesoinsBloc>().add(const LoadBesoinsAValiderEvent(forceRefresh: true));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.besoins.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final besoin = state.besoins[index];
                        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                        
                        Color statutColor;
                        if (besoin.enAttente) {
                          statutColor = Colors.orange;
                        } else if (besoin.statut == 'REJETE') {
                          statutColor = Colors.red;
                        } else {
                          statutColor = Colors.green;
                        }

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () => context.push('/besoins/${besoin.idBesoin}'),
                            title: Text(
                              'Demande ${besoin.numeroDemande}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Date: ${dateFormat.format(besoin.dateCreation)}'),
                                const SizedBox(height: 4),
                                Text('${besoin.lignes.length} pièce(s) demandée(s)'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statutColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statutColor),
                                      ),
                                      child: Text(
                                        besoin.statut.replaceAll('_', ' '),
                                        style: TextStyle(
                                          color: statutColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
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

  Widget _buildFilterChip(BuildContext context, String label, String value, String currentValue) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        context.read<BesoinsBloc>().add(FilterBesoinsStatusEvent(value));
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
