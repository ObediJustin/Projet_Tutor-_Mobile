import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/enums/app_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_dashboard_bloc.dart';
import '../widgets/admin_dashboard_body.dart';
import '../widgets/caisse_dashboard_body.dart';
import '../widgets/technicien_dashboard_body.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final HomeDashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<HomeDashboardBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  void _loadDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _bloc.add(HomeDashboardRequested(authState.user));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _bloc.add(HomeDashboardRefreshed(authState.user)),
            ),
          ],
        ),
        body: BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
          builder: (context, state) {
            if (state is HomeDashboardLoading || state is HomeDashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeDashboardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _bloc.add(
                          HomeDashboardRefreshed(authState.user),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is HomeDashboardLoaded) {
              final data = state.data;
              switch (data.role) {
                case AppRole.technicien:
                  return TechnicienDashboardBody(data: data);
                case AppRole.caisse:
                case AppRole.magasinier:
                  return CaisseDashboardBody(data: data);
                case AppRole.admin:
                case AppRole.dg:
                case AppRole.comptable:
                case AppRole.unknown:
                  return AdminDashboardBody(data: data);
              }
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
