import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/panne.dart';
import '../repositories/pannes_repository.dart';

@lazySingleton
class GetMesPannesUseCase {
  final PannesRepository _repository;

  GetMesPannesUseCase(this._repository);

  Future<Either<Failure, List<Panne>>> call({String? statut}) {
    return _repository.getMesPannes(statut: statut);
  }
}

@lazySingleton
class GetPanneDetailUseCase {
  final PannesRepository _repository;

  GetPanneDetailUseCase(this._repository);

  Future<Either<Failure, Panne>> call(int id) {
    return _repository.getPanneDetail(id);
  }
}

@lazySingleton
class DeclarerPanneUseCase {
  final PannesRepository _repository;

  DeclarerPanneUseCase(this._repository);

  Future<Either<Failure, Panne>> call({
    required int idBien,
    required String typePanne,
    required String priorite,
    required String description,
  }) {
    return _repository.declarerPanne(
      idBien: idBien,
      typePanne: typePanne,
      priorite: priorite,
      description: description,
    );
  }
}

@lazySingleton
class ChangerStatutPanneUseCase {
  final PannesRepository _repository;

  ChangerStatutPanneUseCase(this._repository);

  Future<Either<Failure, Panne>> call({
    required int idPanne,
    required String statut,
  }) {
    return _repository.changerStatutPanne(idPanne, statut);
  }
}

@lazySingleton
class GetRecentPannesLocalUseCase {
  final PannesRepository _repository;

  GetRecentPannesLocalUseCase(this._repository);

  Future<Either<Failure, List<Panne>>> call() {
    return _repository.getRecentPannesLocal();
  }
}
