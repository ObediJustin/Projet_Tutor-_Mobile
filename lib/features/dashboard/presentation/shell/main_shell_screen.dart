import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/permissions/role_navigation.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  int _selectedIndex(List<RoleNavItem> items, String location) {
    final index = items.indexWhere((item) => location.startsWith(item.route));
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return child;
    }

    final navItems = RoleNavigation.itemsFor(authState.user.appRole);
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(navItems, location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(navItems[index].route);
        },
        destinations: navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
