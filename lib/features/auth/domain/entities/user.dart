// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_role.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String nom;
  final String? postNom;
  final String prenom;
  final String? telephone;
  final List<String> roles;
  final bool estActif;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.email,
    required this.nom,
    this.postNom,
    required this.prenom,
    this.telephone,
    required this.roles,
    required this.estActif,
    this.lastLogin,
  });

  String get nomComplet {
    final elements = [prenom, nom, postNom].where((e) => e != null && e.isNotEmpty);
    return elements.join(' ');
  }

  String get rolePrincipal {
    if (roles.isEmpty) return 'Aucun';
    return roles.first;
  }

  AppRole get appRole => AppRole.fromString(rolePrincipal);

  @override
  List<Object?> get props => [
        id,
        email,
        nom,
        postNom,
        prenom,
        telephone,
        roles,
        estActif,
        lastLogin,
      ];
}
