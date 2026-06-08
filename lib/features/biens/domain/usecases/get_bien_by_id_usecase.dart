import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/bien.dart';
import '../repositories/biens_repository.dart';

@lazySingleton
class GetBienByIdUseCase {
  GetBienByIdUseCase(this._repository);

  final BiensRepository _repository;

  Future<Either<Failure, Bien>> call(int id) => _repository.getBienById(id);
}
