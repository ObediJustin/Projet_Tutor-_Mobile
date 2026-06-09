import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/biens/presentation/bloc/biens_bloc.dart';
import '../../features/biens/presentation/screens/bien_detail_screen.dart';
import '../../features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../../features/dashboard/presentation/shell/main_shell_screen.dart';
import '../../features/pieces/presentation/screens/pieces_screen.dart';
import '../../features/besoins/presentation/screens/besoins_screen.dart';
import '../../features/profil/presentation/screens/profil_screen.dart';
import '../../features/qr_code/presentation/screens/scanner_screen.dart';
import '../../features/pannes/presentation/screens/mes_pannes_screen.dart';
import '../../features/pannes/presentation/screens/panne_detail_screen.dart';
import '../../features/pannes/presentation/screens/declarer_panne_screen.dart';
import '../../features/maintenances/presentation/screens/mes_maintenances_screen.dart';
import '../../features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import '../../features/pieces/presentation/screens/piece_detail_screen.dart';
import '../../features/pieces/presentation/screens/pieces_critiques_screen.dart';
import '../../features/besoins/presentation/screens/besoin_detail_screen.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String homeDashboard = '/home/dashboard';
  static const String homeScanner = '/home/scanner';
  static const String homePannes = '/home/pannes';
  static const String homeMaintenances = '/home/maintenances';
  static const String homePieces = '/home/pieces';
  static const String homeBesoins = '/home/besoins';
  static const String homeProfil = '/home/profil';

  static String bienDetailPath(int id) => '/biens/$id';
  static String declarerPannePath(int bienId) => '/pannes/declarer/$bienId';

  static GoRouter createRouter(AuthBloc authBloc) {
    final refreshNotifier = GoRouterRefreshStream(authBloc.stream);

    return GoRouter(
      initialLocation: splash,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.uri.path;

        if (authState is AuthInitial || authState is AuthLoading) {
          return location == splash ? null : splash;
        }

        final isLoggedIn = authState is Authenticated;

        if (isLoggedIn) {
          if (location == login || location == splash) {
            return homeDashboard;
          }
          return null;
        }

        if (location == login) {
          return null;
        }

        return login;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShellScreen(child: child),
          routes: [
            GoRoute(
              path: home,
              redirect: (context, state) =>
                  state.uri.path == home ? homeDashboard : null,
              routes: [
                GoRoute(
                  path: 'dashboard',
                  builder: (context, state) => const HomeDashboardScreen(),
                ),
                GoRoute(
                  path: 'scanner',
                  builder: (context, state) => BlocProvider<BiensBloc>(
                    create: (_) => getIt<BiensBloc>(),
                    child: const ScannerScreen(),
                  ),
                ),
                GoRoute(
                  path: 'pannes',
                  builder: (context, state) => const MesPannesScreen(),
                ),
                GoRoute(
                  path: 'maintenances',
                  builder: (context, state) => const MesMaintenancesScreen(),
                ),
                GoRoute(
                  path: 'pieces',
                  builder: (context, state) => const PiecesScreen(),
                ),
                GoRoute(
                  path: 'besoins',
                  builder: (context, state) => const BesoinsScreen(),
                ),
                GoRoute(
                  path: 'profil',
                  builder: (context, state) => const ProfilScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/biens/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return BlocProvider<BiensBloc>(
              create: (_) => getIt<BiensBloc>(),
              child: BienDetailScreen(bienId: id),
            );
          },
        ),
        GoRoute(
          path: '/pannes/declarer/:bienId',
          builder: (context, state) {
            final bienId = int.parse(state.pathParameters['bienId']!);
            return DeclarerPanneScreen(bienId: bienId);
          },
        ),
        GoRoute(
          path: '/pieces/critiques',
          builder: (context, state) => const PiecesCritiquesScreen(),
        ),
        GoRoute(
          path: '/pieces/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PieceDetailScreen(pieceId: id);
          },
        ),
        GoRoute(
          path: '/besoins/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return BesoinDetailScreen(besoinId: id);
          },
        ),
        GoRoute(
          path: '/pannes/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return PanneDetailScreen(panneId: id);
          },
        ),
        GoRoute(
          path: '/maintenances/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return MaintenanceDetailScreen(maintenanceId: id);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Route introuvable : ${state.uri}'),
        ),
      ),
    );
  }
}
