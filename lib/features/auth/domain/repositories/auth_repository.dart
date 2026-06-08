// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Connexion de l'utilisateur
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Récupération du profil de l'utilisateur connecté (depuis le serveur ou le cache)
  Future<Either<Failure, User>> getCurrentUser();

  /// Déconnexion de l'utilisateur
  Future<Either<Failure, Unit>> logout();
}
