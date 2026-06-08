import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/biens/presentation/screens/bien_detail_screen.dart';
import '../../features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/placeholder_module_screen.dart';
import '../../features/dashboard/presentation/shell/main_shell_screen.dart';
import '../../features/profil/presentation/screens/profil_screen.dart';
import '../../features/qr_code/presentation/screens/scanner_screen.dart';
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

  static GoRouter createRouter(AuthBloc authBloc) {
    final refreshNotifier = GoRouterRefreshStream(authBloc.stream);

    return GoRouter(
      initialLocation: splash,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;

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
              redirect: (_, __) => homeDashboard,
              routes: [
                GoRoute(
                  path: 'dashboard',
                  builder: (context, state) => const HomeDashboardScreen(),
                ),
                GoRoute(
                  path: 'scanner',
                  builder: (context, state) => const ScannerScreen(),
                ),
                GoRoute(
                  path: 'pannes',
                  builder: (context, state) => const PlaceholderModuleScreen(
                    title: 'Mes Pannes',
                    description:
                        'Le suivi complet des pannes sera disponible prochainement.',
                    icon: Icons.build_circle_outlined,
                  ),
                ),
                GoRoute(
                  path: 'maintenances',
                  builder: (context, state) => const PlaceholderModuleScreen(
                    title: 'Mes Maintenances',
                    description:
                        'La gestion des maintenances sera disponible prochainement.',
                    icon: Icons.handyman_outlined,
                  ),
                ),
                GoRoute(
                  path: 'pieces',
                  builder: (context, state) => const PlaceholderModuleScreen(
                    title: 'Stock des pièces',
                    description:
                        'La gestion du stock sera disponible prochainement.',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                GoRoute(
                  path: 'besoins',
                  builder: (context, state) => const PlaceholderModuleScreen(
                    title: 'Besoins à traiter',
                    description:
                        'Le workflow des besoins sera disponible prochainement.',
                    icon: Icons.shopping_cart_outlined,
                  ),
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
            return BienDetailScreen(bienId: id);
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
