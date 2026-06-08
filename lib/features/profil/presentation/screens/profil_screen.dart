import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/enums/app_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Color _roleColor(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return AppConstants.errorColor;
      case AppRole.dg:
        return AppConstants.warningColor;
      case AppRole.comptable:
        return AppConstants.primaryColor;
      case AppRole.technicien:
        return AppConstants.secondaryColor;
      case AppRole.caisse:
      case AppRole.magasinier:
        return AppConstants.successColor;
      case AppRole.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;
        final role = user.appRole;

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.nomComplet,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(user.email, style: TextStyle(color: Colors.grey[600])),
                if (user.telephone != null) ...[
                  const SizedBox(height: 4),
                  Text(user.telephone!, style: TextStyle(color: Colors.grey[600])),
                ],
                const SizedBox(height: 16),
                Chip(
                  label: Text(role.label),
                  backgroundColor: _roleColor(role).withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: _roleColor(role)),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.errorColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
