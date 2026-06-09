import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/maintenance.dart';
import '../repositories/maintenances_repository.dart';

@lazySingleton
class GetMesMaintenancesUseCase {
  final MaintenancesRepository _repository;

  GetMesMaintenancesUseCase(this._repository);

  Future<Either<Failure, List<Maintenance>>> call({String? statut}) {
    return _repository.getMesMaintenances(statut: statut);
  }
}

@lazySingleton
class GetMaintenanceDetailUseCase {
  final MaintenancesRepository _repository;

  GetMaintenanceDetailUseCase(this._repository);

  Future<Either<Failure, Maintenance>> call(int id) {
    return _repository.getMaintenanceDetail(id);
  }
}

@lazySingleton
class DemarrerMaintenanceUseCase {
  final MaintenancesRepository _repository;

  DemarrerMaintenanceUseCase(this._repository);

  Future<Either<Failure, Maintenance>> call(int id) {
    return _repository.demarrerMaintenance(id);
  }
}

@lazySingleton
class TerminerMaintenanceUseCase {
  final MaintenancesRepository _repository;

  TerminerMaintenanceUseCase(this._repository);

  Future<Either<Failure, Maintenance>> call({
    required int id,
    required String rapport,
    required double cout,
    String? piecesRemplacees,
  }) {
    return _repository.terminerMaintenance(
      id: id,
      rapport: rapport,
      cout: cout,
      piecesRemplacees: piecesRemplacees,
    );
  }
}

@lazySingleton
class GetRecentMaintenancesLocalUseCase {
  final MaintenancesRepository _repository;

  GetRecentMaintenancesLocalUseCase(this._repository);

  Future<Either<Failure, List<Maintenance>>> call() {
    return _repository.getRecentMaintenancesLocal();
  }
}
