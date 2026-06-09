import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/permissions/role_navigation.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  VoidCallback? _routeListener;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _routeListener = () => setState(() {});
      GoRouter.of(context).routerDelegate.addListener(_routeListener!);
      _listenerAdded = true;
    }
  }

  @override
  void dispose() {
    if (_listenerAdded && _routeListener != null) {
      GoRouter.of(context).routerDelegate.removeListener(_routeListener!);
    }
    super.dispose();
  }

  int _selectedIndex(List<RoleNavItem> items, String location) {
    final index = items.indexWhere((item) => location.startsWith(item.route));
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return widget.child;
    }

    final navItems = RoleNavigation.itemsFor(authState.user.appRole);
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(navItems, location);

    return Scaffold(
      body: widget.child,
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
