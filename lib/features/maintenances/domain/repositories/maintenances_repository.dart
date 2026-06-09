import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/maintenance.dart';

abstract class MaintenancesRepository {
  Future<Either<Failure, List<Maintenance>>> getMesMaintenances({String? statut});

  Future<Either<Failure, Maintenance>> getMaintenanceDetail(int id);

  Future<Either<Failure, Maintenance>> demarrerMaintenance(int id);

  Future<Either<Failure, Maintenance>> terminerMaintenance({
    required int id,
    required String rapport,
    required double cout,
    String? piecesRemplacees,
  });

  Future<Either<Failure, List<Maintenance>>> getRecentMaintenancesLocal();
}
