// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nom,
    super.postNom,
    required super.prenom,
    super.telephone,
    required super.roles,
    required super.estActif,
    super.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nom: json['nom'] as String,
      postNom: json['post_nom'] as String?,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      estActif: json['est_actif'] as bool? ?? true,
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'post_nom': postNom,
      'prenom': prenom,
      'telephone': telephone,
      'roles': roles,
      'est_actif': estActif,
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}
