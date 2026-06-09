import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/maintenances_bloc.dart';
import '../bloc/maintenances_event.dart';
import '../bloc/maintenances_state.dart';
import '../../domain/entities/maintenance.dart';

class MesMaintenancesScreen extends StatefulWidget {
  const MesMaintenancesScreen({super.key});

  @override
  State<MesMaintenancesScreen> createState() => _MesMaintenancesScreenState();
}

class _MesMaintenancesScreenState extends State<MesMaintenancesScreen> with SingleTickerProviderStateMixin {
  late final MaintenancesBloc _bloc;
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = getIt<MaintenancesBloc>()..add(const GetMesMaintenancesEvent());
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

  List<Maintenance> _filterMaintenances(List<Maintenance> allMaintenances) {
    // 1. Filtrage par onglet
    List<Maintenance> filteredByTab = allMaintenances;
    switch (_tabController.index) {
      case 1: // Planifiée
        filteredByTab = allMaintenances.where((m) => m.statut.toUpperCase() == 'PLANIFIEE').toList();
        break;
      case 2: // En cours
        filteredByTab = allMaintenances.where((m) => m.statut.toUpperCase() == 'EN_COURS').toList();
        break;
      case 3: // Clôturée / Terminée
        filteredByTab = allMaintenances.where((m) => 
          m.statut.toUpperCase() == 'TERMINEE' || 
          m.statut.toUpperCase() == 'CLOTUREE'
        ).toList();
        break;
      default: // Toutes
        break;
    }

    // 2. Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredByTab = filteredByTab.where((m) =>
        m.description.toLowerCase().contains(q) ||
        m.typeMaintenance.toLowerCase().contains(q) ||
        (m.bienDesignation != null && m.bienDesignation!.toLowerCase().contains(q)) ||
        (m.technicienNom != null && m.technicienNom!.toLowerCase().contains(q))
      ).toList();
    }

    return filteredByTab;
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
        return 'Terminée';
      case 'CLOTUREE':
        return 'Clôturée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Maintenances'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Toutes'),
              Tab(text: 'Planifiées'),
              Tab(text: 'En cours'),
              Tab(text: 'Clôturées'),
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
                  hintText: 'Recherche rapide (bien, description...)',
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
              child: BlocBuilder<MaintenancesBloc, MaintenancesState>(
                builder: (context, state) {
                  if (state is MaintenancesLoading && state is! MaintenancesLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MaintenancesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _bloc.add(const GetMesMaintenancesEvent()),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  List<Maintenance> allMaintenances = [];
                  if (state is MaintenancesLoaded) {
                    allMaintenances = state.maintenances;
                  }

                  final maintenances = _filterMaintenances(allMaintenances);

                  if (maintenances.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Aucune maintenance ne correspond à votre recherche.'
                                  : 'Aucune maintenance dans cette catégorie.',
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
                      _bloc.add(const GetMesMaintenancesEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: maintenances.length,
                      itemBuilder: (context, index) {
                        final maintenance = maintenances[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push('/maintenances/${maintenance.idMaintenance}').then((_) {
                                _bloc.add(const GetMesMaintenancesEvent());
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
                                          maintenance.bienDesignation ?? 'Bien #${maintenance.idBien}',
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
                                          color: _getStatusColor(maintenance.statut).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _getStatusLabel(maintenance.statut),
                                          style: TextStyle(
                                            color: _getStatusColor(maintenance.statut),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.build, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text(
                                        maintenance.typeMaintenance,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    maintenance.description,
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
                                          Icon(Icons.calendar_month, size: 16, color: Colors.blue[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Prévu: ${_formatDate(maintenance.datePlanifiee)}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (maintenance.cout > 0)
                                        Text(
                                          '${maintenance.cout.toStringAsFixed(2)} FC',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.primaryColor,
                                            fontSize: 14,
                                          ),
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
