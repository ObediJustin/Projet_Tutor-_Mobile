import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/role_dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, RoleDashboardData>> getDashboardForUser(User user);
}
