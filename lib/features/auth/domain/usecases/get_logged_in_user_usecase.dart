// lib/features/auth/domain/usecases/get_logged_in_user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetLoggedInUserUseCase {
  final AuthRepository _repository;

  GetLoggedInUserUseCase(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.getCurrentUser();
  }
}
