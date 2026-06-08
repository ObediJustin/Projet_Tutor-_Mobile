import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/role_dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetRoleDashboardUseCase {
  GetRoleDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, RoleDashboardData>> call(User user) =>
      _repository.getDashboardForUser(user);
}
