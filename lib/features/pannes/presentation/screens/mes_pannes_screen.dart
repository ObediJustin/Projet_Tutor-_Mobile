import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pannes_bloc.dart';
import '../../domain/entities/panne.dart';

class MesPannesScreen extends StatefulWidget {
  const MesPannesScreen({super.key});

  @override
  State<MesPannesScreen> createState() => _MesPannesScreenState();
}

class _MesPannesScreenState extends State<MesPannesScreen> with SingleTickerProviderStateMixin {
  late final PannesBloc _bloc;
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PannesBloc>()..add(const LoadMesPannes());
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {}); // Déclenche un rebuild pour appliquer le filtre de l'onglet
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _bloc.close();
    super.dispose();
  }

  List<Panne> _filterPannes(List<Panne> allPannes) {
    // 1. Filtrage par onglet
    List<Panne> filteredByTab = allPannes;
    switch (_tabController.index) {
      case 1: // Ouverte
        filteredByTab = allPannes.where((p) => 
          p.statut == 'DECLAREE' || 
          p.statut == 'DIAGNOSTIQUEE' || 
          p.statut == 'EN_ATTENTE_PIECES' || 
          p.statut == 'EN_VALIDATION'
        ).toList();
        break;
      case 2: // En cours
        filteredByTab = allPannes.where((p) => p.statut == 'EN_COURS').toList();
        break;
      case 3: // Résolue
        filteredByTab = allPannes.where((p) => p.statut == 'TERMINEE').toList();
        break;
      default: // Toutes
        break;
    }

    // 2. Filtrage par recherche rapide (titre/description/bien)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredByTab = filteredByTab.where((p) =>
        p.description.toLowerCase().contains(q) ||
        p.typePanne.toLowerCase().contains(q) ||
        (p.bienReference != null && p.bienReference!.toLowerCase().contains(q)) ||
        (p.bienDesignation != null && p.bienDesignation!.toLowerCase().contains(q))
      ).toList();
    }

    return filteredByTab;
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
        return 'Déclarée';
      case 'DIAGNOSTIQUEE':
        return 'Diagnostiquée';
      case 'EN_ATTENTE_PIECES':
        return 'En attente pièces';
      case 'EN_VALIDATION':
        return 'En validation';
      case 'EN_COURS':
        return 'En cours';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Pannes'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Toutes'),
              Tab(text: 'Ouvertes'),
              Tab(text: 'En cours'),
              Tab(text: 'Résolues'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Recherche rapide...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<PannesBloc, PannesState>(
                builder: (context, state) {
                  if (state is PannesLoading && state is! MesPannesLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PannesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _bloc.add(const LoadMesPannes()),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  List<Panne> allPannes = [];
                  if (state is MesPannesLoaded) {
                    allPannes = state.pannes;
                  }

                  final pannes = _filterPannes(allPannes);

                  if (pannes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Aucune panne ne correspond à votre recherche.'
                                  : 'Aucune panne signalée dans cette catégorie.',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _bloc.add(const LoadMesPannes());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: pannes.length,
                      itemBuilder: (context, index) {
                        final panne = pannes[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push('/pannes/${panne.idPanne}').then((_) {
                                // Recharger la liste quand on revient de l'écran détail
                                _bloc.add(const LoadMesPannes());
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          panne.bienDesignation ?? 'Bien ${panne.idBien}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(panne.statut).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _getStatusLabel(panne.statut),
                                          style: TextStyle(
                                            color: _getStatusColor(panne.statut),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Type: ${panne.typePanne}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    panne.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.flag_outlined, size: 16, color: _getPriorityColor(panne.priorite)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Priorité: ${panne.priorite}',
                                            style: TextStyle(
                                              color: _getPriorityColor(panne.priorite),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(panne.dateDeclaration),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
